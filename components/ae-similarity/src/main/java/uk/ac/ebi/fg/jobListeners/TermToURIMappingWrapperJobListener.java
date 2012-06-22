package uk.ac.ebi.fg.jobListeners;

import org.apache.commons.configuration.Configuration;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import uk.ac.ebi.arrayexpress.utils.controller.IJobsController;
import uk.ac.ebi.fg.jobs.LuceneEFOIndexJob;
import uk.ac.ebi.fg.utils.ApplicationJobListener;
import uk.ac.ebi.fg.utils.objects.StaticJobController;

/**
 * After EFO has been indexed starts data extraction from experiments
 */
public class TermToURIMappingWrapperJobListener extends ApplicationJobListener
{
    public TermToURIMappingWrapperJobListener(String name)
    {
        super(name);
    }

    public void jobExecuted(JobExecutionContext jobExecutionContext) throws Exception
    {
        JobDetail jobDetail = jobExecutionContext.getJobDetail();

        if (jobDetail.getJobClass().equals(LuceneEFOIndexJob.class)) {
            IJobsController jobController = StaticJobController.getJobController();

            jobController.executeJob("TermToURIMappingWrapperJob", ((Configuration) jobDetail.getJobDataMap().get("properties")).getString("quartz_job_group_name"));

        }
    }
}