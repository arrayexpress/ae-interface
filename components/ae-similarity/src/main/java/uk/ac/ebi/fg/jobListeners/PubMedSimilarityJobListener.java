package uk.ac.ebi.fg.jobListeners;

import org.apache.commons.configuration.Configuration;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import uk.ac.ebi.arrayexpress.utils.controller.IJobsController;
import uk.ac.ebi.fg.jobs.PubMedUpdateFileJob;
import uk.ac.ebi.fg.utils.ApplicationJobListener;
import uk.ac.ebi.fg.utils.objects.StaticJobController;

/**
 * After PubMed file has been updated starts PubMed similarity job
 */
public class PubMedSimilarityJobListener extends ApplicationJobListener
{
    public PubMedSimilarityJobListener(String name)
    {
        super(name);
    }

    public void jobExecuted(JobExecutionContext jobExecutionContext) throws Exception
    {
        JobDetail jobDetail = jobExecutionContext.getJobDetail();

        if (jobDetail.getJobClass().equals(PubMedUpdateFileJob.class)) {
            IJobsController jobsController = StaticJobController.getJobController();

            jobsController.executeJob("PubMedSimilarityJob", ((Configuration) jobDetail.getJobDataMap().get("properties")).getString("quartz_job_group_name"));
        }
    }
}
