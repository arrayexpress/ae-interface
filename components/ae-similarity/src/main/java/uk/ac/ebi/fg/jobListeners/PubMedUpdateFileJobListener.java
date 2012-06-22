package uk.ac.ebi.fg.jobListeners;

import org.apache.commons.configuration.Configuration;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import uk.ac.ebi.arrayexpress.utils.controller.IJobsController;
import uk.ac.ebi.fg.jobs.PubMedDataMinerJob;
import uk.ac.ebi.fg.jobs.PubMedDataMinerWrapperJob;
import uk.ac.ebi.fg.utils.ApplicationJobListener;
import uk.ac.ebi.fg.utils.objects.StaticJobController;

import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * After new PubMed ids have been downloaded starts job that writes PubMed information to file
 */
public class PubMedUpdateFileJobListener extends ApplicationJobListener
{
    public PubMedUpdateFileJobListener(String name)
    {
        super(name);
    }

    synchronized public void jobExecuted(JobExecutionContext jobExecutionContext) throws Exception
    {
        JobDetail jobDetail = jobExecutionContext.getJobDetail();

        if (jobDetail.getJobClass().equals(PubMedDataMinerWrapperJob.class) && ((Set<String>)jobDetail.getJobDataMap().get("pubMedNewIds")).isEmpty() ) {

            IJobsController jobsController = StaticJobController.getJobController();
            jobsController.executeJob("PubMedUpdateFileJob", ((Configuration) jobDetail.getJobDataMap().get("properties")).getString("quartz_job_group_name"));

        } else if ( jobDetail.getJobClass().equals(PubMedDataMinerJob.class) ) {

            int counter = ((AtomicInteger)jobDetail.getJobDataMap().get("pubMedCounter")).get();
            if ( ((Set<String>)jobDetail.getJobDataMap().get("pubMedNewIds")).size() == counter) {

                IJobsController jobsController = StaticJobController.getJobController();
                jobsController.executeJob("PubMedUpdateFileJob", ((Configuration) jobDetail.getJobDataMap().get("properties")).getString("quartz_job_group_name"));
            }
        }
    }
}
