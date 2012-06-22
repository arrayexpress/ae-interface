package uk.ac.ebi.fg.jobListeners;

import org.apache.commons.configuration.Configuration;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.SchedulerException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.utils.controller.IJobsController;
import uk.ac.ebi.fg.jobs.OntologySimilarityJob;
import uk.ac.ebi.fg.jobs.PubMedSimilarityJob;
import uk.ac.ebi.fg.utils.ApplicationJobListener;
import uk.ac.ebi.fg.utils.OntologyDistanceCalculator;
import uk.ac.ebi.fg.utils.objects.EfoTerm;
import uk.ac.ebi.fg.utils.objects.ExperimentId;
import uk.ac.ebi.fg.utils.objects.StaticJobController;

import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.concurrent.ConcurrentHashMap;

/**
 * After PubMed and ontology jobs have finished starts XmlWriterJob
 */
public class XmlWriterJobListener extends ApplicationJobListener
{
    private final Logger logger = LoggerFactory.getLogger(getClass());
    private Set<String> jobsFinished = new TreeSet<String>();

    public XmlWriterJobListener(String name)
    {
        super(name);
    }

    public void jobExecuted(JobExecutionContext jobExecutionContext) throws Exception
    {
        JobDetail jobDetail = jobExecutionContext.getJobDetail();

        if (jobDetail.getJobClass().equals(PubMedSimilarityJob.class) ) {
            jobsFinished.add(jobDetail.getJobClass().toString());

            startWriteJob(((Configuration) jobDetail.getJobDataMap().get("properties")).getString("quartz_job_group_name"));
        }

        if (jobDetail.getJobClass().equals(OntologySimilarityJob.class) ) {
            int total = ((Map<ExperimentId, SortedSet<EfoTerm>>) jobDetail.getJobDataMap().get("expToURIMap")).size();
            int ready = ((ConcurrentHashMap<ExperimentId, SortedSet<ExperimentId>>)jobDetail.getJobDataMap().get("ontologyResults")).size();
            if ( total == ready ) {
                logger.info("Ontology jobs finished");
                jobsFinished.add(jobDetail.getJobClass().toString());
                ((Map<String, SortedSet<ExperimentId>>)jobDetail.getJobDataMap().get("uriToExpMap")).clear();
                ((SortedSet<String>)jobDetail.getJobDataMap().get("lowPriorityOntologyURIs")).clear();
                ((OntologyDistanceCalculator)jobDetail.getJobDataMap().get("distanceCalculator")).clear();

                startWriteJob( ((Configuration) jobDetail.getJobDataMap().get("properties")).getString("quartz_job_group_name") );
            }
        }
    }

    private void startWriteJob( String group ) throws SchedulerException
    {
        if ( jobsFinished.size() == 2 ) {
            IJobsController jobsController = StaticJobController.getJobController();

            jobsController.executeJob("XmlWriterJob", group);
        }
    }
}