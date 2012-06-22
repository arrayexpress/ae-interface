package uk.ac.ebi.fg.jobs;

import net.sf.saxon.om.DocumentInfo;
import org.apache.commons.lang.StringEscapeUtils;
import org.quartz.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.fg.utils.ApplicationJob;
import uk.ac.ebi.fg.utils.ExperimentComparator;
import uk.ac.ebi.fg.utils.ReceivingType;
import uk.ac.ebi.fg.utils.objects.EfoTerm;
import uk.ac.ebi.fg.utils.objects.ExperimentId;
import uk.ac.ebi.fg.utils.objects.StaticJobController;
import uk.ac.ebi.fg.utils.objects.StaticSimilarityComponent;
import uk.ac.ebi.fg.utils.saxon.IXPathEngine;

import java.util.*;

/**
 * Creates xml file containing similarity results
 */
public class XmlWriterJob extends ApplicationJob
{
    private final Logger logger = LoggerFactory.getLogger(getClass());
    Map<ExperimentId, SortedSet<ExperimentId>> ontologyResults;
    Map<String, SortedSet<ExperimentId>> pubMedResults;
    Map<ExperimentId, SortedSet<EfoTerm>> expToURIMap;

    public XmlWriterJob() {}

    public void doExecute(JobExecutionContext jobExecutionContext) throws Exception
    {
        JobDataMap dataMap = jobExecutionContext.getMergedJobDataMap();

        ontologyResults = (Map<ExperimentId, SortedSet<ExperimentId>>)dataMap.get("ontologyResults");
        pubMedResults = (Map<String, SortedSet<ExperimentId>>) dataMap.get("pubMedResults");
        expToURIMap = (Map<ExperimentId, SortedSet<EfoTerm>>)dataMap.get("expToURIMap");
        IXPathEngine saxonEngine = (IXPathEngine) dataMap.get("saxonEngine");

        logger.info("XmlWriterJob started");

        Set<String> allExperimentAccessions = getAccessions();
        logger.info("There are " + allExperimentAccessions.size() + " experiments to write.");

        StringBuilder xml = new StringBuilder("<?xml version=\"1.0\"?><similarity>");
        for ( String accession : allExperimentAccessions )
            xml.append(getSimilarity(accession));
        xml.append("</similarity>");

        DocumentInfo similarityXml = saxonEngine.buildDocument(xml.toString());
        StaticSimilarityComponent.getComponent().setDocument(similarityXml);

        // release resources
        releaseResources(jobExecutionContext.getScheduler());

        logger.info("Xml has been written. ");
    }

    /**
     * Creates String containing experiment with similar experiments within xml tags
     *
     * @param accession     experiment accession
     * @return              experiment with similarity results in xml tags
     */
    private String getSimilarity(String accession)
    {
        String ontologyResult = ontologyResult(accession);
        String pubMedResult = pubMedResult(accession);

        if ( !ontologyResult.equals("") || !pubMedResult.equals("") ) {
            StringBuilder sb = new StringBuilder("<experiment><accession>" + accession + "</accession>");

            sb.append(ontologyResult);
            sb.append(pubMedResult);

            sb.append("</experiment>");

            return sb.toString();
        }

        return "";
    }

    /**
     * Returns String containing experiment's PubMed results with xml tags
     *
     * @param accession     experiment accession
     * @return              PubMed similarity or empty String
     */
    private String pubMedResult ( String accession )
    {
        StringBuilder sb = new StringBuilder("");

        if ( pubMedResults.containsKey(accession) && !pubMedResults.get(accession).isEmpty() ) {

            sb.append("<similarPubMedExperiments>");
            List<ExperimentId> sortedExpList = new LinkedList<ExperimentId>(pubMedResults.get(accession));
            Collections.sort(sortedExpList, new ExperimentComparator());

            for ( ExperimentId exp : sortedExpList ) {
                sb.append("<similarExperiment>" +
                        "<accession>" + exp.getAccession() + "</accession>" +
                        "<distance>" + exp.getPubMedDistance() + "</distance>" +
                        "</similarExperiment>"
                );
            }

            sb.append("</similarPubMedExperiments>");
        }

        return sb.toString();
    }

    /**
     * Returns String containing experiment's ontology results with xml tags
     *
     * @param accession     experiment accession
     * @return              ontology similarity or empty string
     */
    private String ontologyResult ( String accession )
    {
        StringBuilder sb = new StringBuilder("");
        ExperimentId dummyExperiment = new ExperimentId(accession, ReceivingType.OWL, 0);

        if ( ontologyResults.containsKey(dummyExperiment) && !ontologyResults.get(dummyExperiment).isEmpty() ) {
            sb.append("<ontologyURIs>");
            for ( EfoTerm efoTerm : expToURIMap.get(dummyExperiment) ) {
                sb.append("<URI term=\"" + StringEscapeUtils.escapeXml(efoTerm.getTextValue()) + "\">" + StringEscapeUtils.escapeXml(efoTerm.getUri()) + "</URI>");
            }
            sb.append("</ontologyURIs>");


            sb.append("<similarOntologyExperiments>");
            List<ExperimentId> sortedExpList = new LinkedList<ExperimentId>(ontologyResults.get(dummyExperiment));
            Collections.sort(sortedExpList, new ExperimentComparator());

            for ( ExperimentId exp : sortedExpList ) {
                sb.append("<similarExperiment>" +
                        "<accession>" + exp.getAccession() + "</accession>" +
                        "<numberOfMatchedURIs>" + exp.getNumbOfMatches() + "</numberOfMatchedURIs>" +
                        "<calculatedDistance>" + exp.getCalculatedDistance() + "</calculatedDistance>" +
                        "<ontologyURIs>"
                );

                for ( EfoTerm efoTerm : expToURIMap.get(exp) ) {
                    sb.append("<URI term=\"" + StringEscapeUtils.escapeXml(efoTerm.getTextValue()) + "\">" + StringEscapeUtils.escapeXml(efoTerm.getUri()) + "</URI>");
                }

                sb.append("</ontologyURIs></similarExperiment>");
            }
            sb.append("</similarOntologyExperiments>");
        }

        return sb.toString();
    }

    /**
     * Creates a set of experiment accessions that have similarity results
     *
     * @return      experiment accessions
     */
    private Set<String> getAccessions()
    {
        Set<String> result = new TreeSet<String>();
        result.addAll(pubMedResults.keySet());

        for ( ExperimentId exp : ontologyResults.keySet() )
            result.add(exp.getAccession());

        return result;
    }

    /**
     * Releases all resources
     *
     * @param scheduler             job scheduler
     * @throws SchedulerException
     */
    private void releaseResources( Scheduler scheduler ) throws SchedulerException
    {
        ontologyResults.clear();
        pubMedResults.clear();
        expToURIMap.clear();
        StaticJobController.setJobController(null);
        List<JobListener> jobListeners = scheduler.getListenerManager().getJobListeners();

        // remove jobListeners
        for ( JobListener jobListener : jobListeners ) {
            if ( jobListener.getClass().getName().startsWith("uk.ac.ebi.fg.jobListeners.") ) {
                boolean wasRemoved = scheduler.getListenerManager().removeJobListener(jobListener.getName());
                if (wasRemoved)
                    logger.info(jobListener.getClass().getName() + " removed from jobListeners");
            }
        }

        StaticSimilarityComponent.setComponent(null);
    }
}
