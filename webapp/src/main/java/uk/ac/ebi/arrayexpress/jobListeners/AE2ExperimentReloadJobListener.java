package uk.ac.ebi.arrayexpress.jobListeners;

/*
 * Copyright 2009-2012 European Molecular Biology Laboratory
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

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
