package uk.ac.ebi.arrayexpress.jobListeners;

import org.quartz.JobExecutionContext;
import org.quartz.JobListener;
import org.quartz.SchedulerException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.components.JobsController;
import uk.ac.ebi.arrayexpress.components.Similarity;
import uk.ac.ebi.arrayexpress.jobs.ReloadExperimentsFromAE2Job;

import java.util.List;

public class AE2ExperimentReloadJobListener implements JobListener
{      
    private String name;
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public AE2ExperimentReloadJobListener(String name)
    {
        this.name = name;
    }

    public String getName()
    {
        return name;
    }

    public void jobToBeExecuted(org.quartz.JobExecutionContext jobExecutionContext)
    {}

    public void jobExecutionVetoed(org.quartz.JobExecutionContext jobExecutionContext)
    {}

    public void jobWasExecuted(org.quartz.JobExecutionContext jobExecutionContext, org.quartz.JobExecutionException e)
    {
        try {
            if (jobExecutionContext.getJobDetail().getJobClass().equals(ReloadExperimentsFromAE2Job.class) ) {
                List<JobExecutionContext> runningJobs = jobExecutionContext.getScheduler().getCurrentlyExecutingJobs();
                boolean running = false;

                for ( JobExecutionContext jec : runningJobs ) {
                    if ( jec.getJobDetail().getKey().getGroup().equals((Application.getAppComponent("Similarity")).getPreferences().getString("ae.similarity.properties.quartz_job_group_name")) )
                        running = true;
                }

                if ( !running )
                    ((JobsController) Application.getAppComponent("JobsController")).executeJob("similarity");
            }
        } catch ( SchedulerException ex ) {
            logger.error("Scheduler exception while executing " + getName() + " : " + ex.getMessage());
            ((Similarity) Application.getAppComponent("similarity")).sendExceptionReport("Scheduler exception while executing " + getName(), ex);
        }
    }
}
