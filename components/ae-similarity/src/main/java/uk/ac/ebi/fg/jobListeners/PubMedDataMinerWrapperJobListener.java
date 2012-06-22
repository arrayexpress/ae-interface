package uk.ac.ebi.fg.jobListeners;

import org.apache.commons.configuration.Configuration;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import uk.ac.ebi.arrayexpress.utils.controller.IJobsController;
import uk.ac.ebi.fg.jobs.PubMedLoadFromFileJob;
import uk.ac.ebi.fg.utils.ApplicationJobListener;
import uk.ac.ebi.fg.utils.objects.StaticJobController;

/**
 * After PubMed information has been loaded from file starts PubMedMiner jobs
 */
public class PubMedDataMinerWrapperJobListener extends ApplicationJobListener
{
    public PubMedDataMinerWrapperJobListener(String name)
    {
        super(name);
    }

    public void jobExecuted(JobExecutionContext jobExecutionContext) throws Exception
    {
        JobDetail jobDetail = jobExecutionContext.getJobDetail();

        if (jobDetail.getJobClass().equals(PubMedLoadFromFileJob.class)) {
            IJobsController jobsController = StaticJobController.getJobController();

            jobsController.executeJob("PubMedDataMinerWrapperJob", ((Configuration) jobDetail.getJobDataMap().get("properties")).getString("quartz_job_group_name"));
        }
    }
}
