package uk.ac.ebi.fg.jobListeners;

import org.apache.commons.configuration.Configuration;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.utils.controller.IJobsController;
import uk.ac.ebi.fg.jobs.TermToURIMappingJob;
import uk.ac.ebi.fg.jobs.TermToURIMappingWrapperJob;
import uk.ac.ebi.fg.utils.ApplicationJobListener;
import uk.ac.ebi.fg.utils.lucene.IndexedDocumentController;
import uk.ac.ebi.fg.utils.objects.StaticIndexedEFODocument;
import uk.ac.ebi.fg.utils.objects.StaticJobController;

import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Launches ontology and PubMed jobs after required data has been extracted from experiments
 */
public class ExperimentDataExtractionFinishListener extends ApplicationJobListener
{
    private final Logger logger = LoggerFactory.getLogger(getClass());
    private int jobsRunning = 0;
    private int total = 0;
    String jobGroup = "";

    public ExperimentDataExtractionFinishListener(String name)
    {
        super(name);
    }

    public void jobExecuted(JobExecutionContext jobExecutionContext) throws Exception
    {
        JobDetail jobDetail = jobExecutionContext.getJobDetail();

        if (jobDetail.getJobClass().equals(TermToURIMappingWrapperJob.class)) {
            if ( jobsRunning <= 0 ) {
                total = ((List) jobDetail.getJobDataMap().get("experiments")).size();
                ((List) jobDetail.getJobDataMap().get("experiments")).clear();
                jobGroup = ((Configuration) jobDetail.getJobDataMap().get("properties")).getString("quartz_job_group_name");
            }
        }

        if (jobDetail.getJobClass().equals(TermToURIMappingJob.class)) {

            if ( jobsRunning <= 0 && total != 0 ) {
                int jobsSeparatedAt = (Integer) jobDetail.getJobDataMap().get("separateAt");

                jobsRunning = (total + jobsSeparatedAt - 1 ) / jobsSeparatedAt + jobsRunning;
            }

            --jobsRunning;

            if ( jobsRunning == 0 ) {
                printSynonymProblems(StaticIndexedEFODocument.getDoc());
                StaticIndexedEFODocument.setDoc(null);
                logger.info("Term to URI mapping jobs finished");

                IJobsController jobsController = StaticJobController.getJobController();

                jobsController.executeJob("OntologySimilarityWrapperJob", jobGroup);
                jobsController.executeJob("PubMedLoadFromFileJob", jobGroup);
            }
        }
    }

    /**
     * Prints out terms that matched to several URIs
     *
     * @param indexedDocumentController
     */
    private void printSynonymProblems( IndexedDocumentController indexedDocumentController )
    {
        for ( Map.Entry<String, Set<String>> entry : indexedDocumentController.getLoggedURIsAndTerms().entrySet() ) {
            logger.warn("Found " + entry.getValue().size() + " URIs for term " + entry.getKey());
            for ( String uri : entry.getValue() ) {
                logger.warn("URI: " + uri);
            }
        }
    }
}
