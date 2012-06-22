package uk.ac.ebi.fg.jobListeners;

import org.quartz.TriggerKey;
import org.quartz.TriggerListener;
import org.quartz.impl.matchers.GroupMatcher;
import uk.ac.ebi.arrayexpress.utils.controller.IJobsController;
import uk.ac.ebi.fg.utils.objects.StaticJobController;

public class PubMedSimilarityJobTriggerListener implements TriggerListener
{
    String name;

    public PubMedSimilarityJobTriggerListener ( String name )
    {
        this.name = name;
    }

    public String getName()
    {
        return name;
    }

    public void triggerFired(org.quartz.Trigger trigger, org.quartz.JobExecutionContext jobExecutionContext)
    {}

    public boolean vetoJobExecution(org.quartz.Trigger trigger, org.quartz.JobExecutionContext jobExecutionContext)
    {
        return false;
    }

    public void triggerMisfired(org.quartz.Trigger trigger)
    {}

    public void triggerComplete(org.quartz.Trigger trigger, org.quartz.JobExecutionContext jobExecutionContext, org.quartz.Trigger.CompletedExecutionInstruction completedExecutionInstruction)
    {
        try {
            if ( jobExecutionContext.getScheduler().getTriggerKeys(GroupMatcher.<TriggerKey>groupEquals("pubMedDataMinerJob")).size() == 1 ) {
                IJobsController jobsController = StaticJobController.getJobController();

                jobsController.executeJob("PubMedSimilarityJob");
            }
        } catch (Exception ex ) {
            ex.printStackTrace();
        }
    }
}
