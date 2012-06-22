package uk.ac.ebi.fg.jobs;

import org.apache.commons.configuration.Configuration;
import org.quartz.JobDataMap;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.SchedulerException;
import uk.ac.ebi.arrayexpress.utils.controller.IJobsController;
import uk.ac.ebi.fg.utils.ApplicationJob;
import uk.ac.ebi.fg.utils.PubMedRetriever;
import uk.ac.ebi.fg.utils.objects.PubMedId;

import java.util.Set;
import java.util.SortedSet;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

import static org.quartz.JobBuilder.newJob;

/**
 * Separates PubMed id list into smaller lists and creates concurrent jobs for gathering similar PubMed ids
 */
public class PubMedDataMinerWrapperJob extends ApplicationJob
{
    public PubMedDataMinerWrapperJob()
    {}

    public void doExecute(JobExecutionContext jobExecutionContext) throws SchedulerException, InterruptedException
    {
        JobDataMap dataMap = jobExecutionContext.getMergedJobDataMap();

        Set<String> pubMedNewIds = (Set<String>) dataMap.get("pubMedNewIds");
        ConcurrentHashMap<String, SortedSet<PubMedId>> pubMedIdRelationMap = (ConcurrentHashMap<String, SortedSet<PubMedId>>)dataMap.get("pubMedIdRelationMap");
        Configuration properties = (Configuration)dataMap.get("properties");
        PubMedRetriever pubMedRetriever = (PubMedRetriever) dataMap.get("pubMedRetriever");
        IJobsController jobsController = (IJobsController) dataMap.get("jobsController");
        String jobGroup = properties.getString("quartz_job_group_name");

        AtomicInteger pubMedCounter = new AtomicInteger();
        int i = 0;

        if ( !pubMedNewIds.isEmpty() ) {
            for (String entry : pubMedNewIds) {
                ++i;

                JobDetail pubMedJobDetail = newJob(PubMedDataMinerJob.class)
                        .withIdentity("pubMedDataMinerJob" + i, jobGroup)
                        .storeDurably(true)
                        .requestRecovery(false)
                        .build();

                pubMedJobDetail.getJobDataMap().put("pubMedNewIds", pubMedNewIds);
                pubMedJobDetail.getJobDataMap().put("pubMedIdRelationMap", pubMedIdRelationMap);
                pubMedJobDetail.getJobDataMap().put("properties", properties);
                pubMedJobDetail.getJobDataMap().put("pubMedCounter", pubMedCounter);
                pubMedJobDetail.getJobDataMap().put("pubMedRetriever", pubMedRetriever);
                pubMedJobDetail.getJobDataMap().put("entry", entry);

                jobsController.addJob("pubMedDataMinerJob" + i, PubMedDataMinerJob.class, pubMedJobDetail);

                Thread.currentThread().wait(1);
            }

            // start first 3 jobs
            jobsController.executeJob("pubMedDataMinerJob"+1, jobGroup);
            if ( i > 1 ) {
                jobsController.executeJob("pubMedDataMinerJob"+2, jobGroup);
                if ( i > 2 )
                    jobsController.executeJob("pubMedDataMinerJob"+3, jobGroup);
            }
        }
    }
}
