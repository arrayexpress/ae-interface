package uk.ac.ebi.arrayexpress.components;

/*
 * Copyright 2009-2010 European Molecular Biology Laboratory
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

import org.quartz.*;
import org.quartz.impl.StdSchedulerFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.jobs.*;

import java.util.List;


public class JobsController extends ApplicationComponent
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    // jobs group
    private final String AE_JOBS_GROUP = "ae-jobs";

    // quartz scheduler
    private Scheduler scheduler;

    public JobsController()
    {
    }

    public void initialize() throws Exception
    {
        // here we add jobs
        addJob("rescan-files", RescanFilesJob.class);
        addJob("reload-ae1-xml", ReloadExperimentsFromAE1Job.class);
        addJob("reload-ae2-xml", ReloadExperimentsFromAE2Job.class);
        addJob("retrieve-xml", RetrieveExperimentsXmlJob.class);
        addJob("reload-atlas-info", RetrieveExperimentsListFromAtlasJob.class);
        addJob("reload-ontology", ReloadOntologyJob.class);

        scheduleJob("rescan-files", "ae.files.rescan");
        scheduleJob("reload-ae1-xml", "ae.experiments.ae1.reload");
        scheduleJob("reload-ae2-xml", "ae.experiments.ae2.reload");
        // doesn't have an additional schedule for now, sync'd with the reload of experiments
        // scheduleJob("reload-atlas-info", "ae.atlasexperiments.reload");

        startScheduler();
    }

    public void terminate() throws Exception
    {
        terminateJobs();
    }

    public void executeJob( String name )
    {
        try {
            getScheduler().triggerJob(name, AE_JOBS_GROUP);
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }
    }

    public void executeJobWithParam( String name, String paramName, String paramValue )
    {
        try {
            JobDataMap map = new JobDataMap();
            map.put(paramName, paramValue);
            getScheduler().triggerJob(name, AE_JOBS_GROUP, map);
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }
    }

    public void setJobListener( JobListener jl )
    {
        try {
            if (null != jl) {
                getScheduler().addGlobalJobListener(jl);
            } else {
                getScheduler().removeGlobalJobListener("job-listener");
            }
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }
    }

    private void startScheduler()
    {
        try {
            getScheduler().start();
        } catch (SchedulerException x) {
            logger.error("Caught an exception:", x);
        }
    }

    private Scheduler getScheduler()
    {
        if (null == scheduler) {
            try {
                // Retrieve a scheduler from schedule factory
                scheduler = new StdSchedulerFactory().getScheduler();
            } catch (Exception x) {
                logger.error("Caught an exception:", x);
            }
        }
        return scheduler;
    }

    private void addJob( String name, Class c )
    {
        JobDetail j = new JobDetail(
                name
                , AE_JOBS_GROUP
                , c
                , true      // volatilily
                , true      // durability
                , false     // recover
        );

        try {
            getScheduler().addJob(j, false);
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }
    }

    private void scheduleJob( String name, String preferencePrefix )
    {
        String schedule = getPreferences().getString(preferencePrefix + ".schedule");
        Long interval = getPreferences().getLong(preferencePrefix + ".interval");
        Boolean atStart = getPreferences().getBoolean(preferencePrefix + ".atstart");

        if (null != schedule && 0 < schedule.length()) {
            CronTrigger cronTrigger = new CronTrigger(name + "_schedule_trigger", null);
            try {
                // setup CronExpression
                CronExpression cexp = new CronExpression(schedule);
                // Assign the CronExpression to CronTrigger
                cronTrigger.setCronExpression(cexp);
                cronTrigger.setJobName(name);
                cronTrigger.setJobGroup(AE_JOBS_GROUP);
                // schedule a job with JobDetail and Trigger
                getScheduler().scheduleJob(cronTrigger);
            } catch (Exception x) {
                logger.error("Caught an exception:", x);
            }
        }

        boolean hasScheduledInterval = false;

        if (null != interval) {
            scheduleIntervalJob(name, interval);
            hasScheduledInterval = true;
        }

        if ((null != atStart && atStart) && !hasScheduledInterval) {
            SimpleTrigger intervalTrigger = new SimpleTrigger(name + "_at_start_trigger", AE_JOBS_GROUP);

            intervalTrigger.setJobName(name);
            intervalTrigger.setJobGroup(AE_JOBS_GROUP);

            try {
                getScheduler().scheduleJob(intervalTrigger);
            } catch (Exception x) {
                logger.error("Caught an exception:", x);
            }
        }
    }

    private void scheduleIntervalJob( String name, Long interval )
    {
        SimpleTrigger intervalTrigger = new SimpleTrigger(
                name + "_interval_trigger"
                , AE_JOBS_GROUP
                , SimpleTrigger.REPEAT_INDEFINITELY, interval
        );

        intervalTrigger.setJobName(name);
        intervalTrigger.setJobGroup(AE_JOBS_GROUP);

        try {
            getScheduler().scheduleJob(intervalTrigger);
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }
    }

    private void terminateJobs()
    {
        try {
            // stop all jobs from being triggered
            getScheduler().pauseAll();

            List runningJobs = getScheduler().getCurrentlyExecutingJobs();
            for (Object jec : runningJobs) {
                JobDetail j = ((JobExecutionContext) jec).getJobDetail();
                getScheduler().interrupt(j.getName(), j.getGroup());
            }

            getScheduler().shutdown(true);

        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }
    }
}
