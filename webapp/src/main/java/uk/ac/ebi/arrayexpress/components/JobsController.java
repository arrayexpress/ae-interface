package uk.ac.ebi.arrayexpress.components;

/*
 * Copyright 2009-2014 European Molecular Biology Laboratory
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
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.jobs.*;
import uk.ac.ebi.arrayexpress.utils.controller.IJobsController;

import java.text.ParseException;
import java.util.List;
import java.util.Map;

import static org.quartz.DateBuilder.futureDate;
import static org.quartz.JobBuilder.newJob;
import static org.quartz.SimpleScheduleBuilder.simpleSchedule;
import static org.quartz.TriggerBuilder.newTrigger;
import static org.quartz.impl.matchers.EverythingMatcher.allJobs;


public class JobsController extends ApplicationComponent implements IJobsController
{
    // jobs group
    private static final String AE_JOBS_GROUP = "ae-jobs";

    // quartz scheduler
    private Scheduler scheduler;

    @Override
    public void initialize() throws Exception
    {
        // create scheduler
        this.scheduler = new StdSchedulerFactory().getScheduler();

        // add jobs
        addJob("rescan-files", RescanFilesJob.class);
        addJob("check-files", CheckFilesJob.class);
        addJob("check-experiments", CheckExperimentsJob.class);
        addJob("reload-ae1-xml", ReloadExperimentsFromAE1Job.class);
        addJob("reload-ae2-xml", ReloadExperimentsFromAE2Job.class);
        addJob("retrieve-xml", RetrieveExperimentsXmlJob.class);
        addJob("reload-efo", ReloadOntologyJob.class);
        addJob("update-efo", UpdateOntologyJob.class);

        // schedule jobs
        scheduleJob("rescan-files", "ae.files.rescan");
        scheduleJob("check-files", "ae.files.check");
        scheduleJob("reload-ae1-xml", "ae.experiments.ae1.reload");
        scheduleJob("reload-ae2-xml", "ae.experiments.ae2.reload");
        scheduleJob("update-efo", "ae.efo.update");

        startScheduler();
    }

    @Override
    public void terminate() throws Exception
    {
        terminateJobs();
    }

    public void executeJob( String name ) throws SchedulerException
    {
        getScheduler().triggerJob(new JobKey(name, AE_JOBS_GROUP));
    }

    @Override
    public void executeJob( String name, String group ) throws SchedulerException
    {
        getScheduler().triggerJob(new JobKey(name, group));
    }

    public void executeJobWithParam( String name, String paramName, String paramValue ) throws SchedulerException
    {
        JobDataMap map = new JobDataMap();
        map.put(paramName, paramValue);
        getScheduler().triggerJob(new JobKey(name, AE_JOBS_GROUP), map);
    }

    @Override
    public void addJobListener( JobListener jl ) throws SchedulerException
    {
        if (null != jl) {
            getScheduler().getListenerManager().addJobListener(jl, allJobs());
        }
    }

    public void removeJobListener( JobListener jl ) throws SchedulerException
    {
        if (null != jl) {
            getScheduler().getListenerManager().removeJobListener(jl.getName());
        }
    }

    public void scheduleJobNow( String name ) throws SchedulerException
    {
        Trigger nowTrigger = newTrigger()
                .withIdentity(name + "_at_start_trigger", AE_JOBS_GROUP)
                .forJob(name, AE_JOBS_GROUP)
                .startNow()
                .build();
        getScheduler().scheduleJob(nowTrigger);
    }

    public void scheduleJobInFuture( String name, Integer intervalInMinutes ) throws SchedulerException
    {
        TriggerKey triggerId = new TriggerKey(name + "_in_" + String.valueOf(intervalInMinutes) + "_mins_trigger", AE_JOBS_GROUP);
        if (getScheduler().checkExists(triggerId)) {
            getScheduler().unscheduleJob(triggerId);
        }
        Trigger inFutureTrigger = newTrigger()
                .withIdentity(triggerId)
                .forJob(name, AE_JOBS_GROUP)
                .startAt(futureDate(intervalInMinutes, DateBuilder.IntervalUnit.MINUTE))
                .build();
        getScheduler().scheduleJob(inFutureTrigger);
    }

    public void scheduleIntervalJob( String name, Integer interval ) throws SchedulerException
    {
        Trigger intervalTrigger = newTrigger()
                .withIdentity(name + "_interval_trigger", AE_JOBS_GROUP)
                .forJob(name, AE_JOBS_GROUP)
                .withSchedule(
                        simpleSchedule()
                                .withIntervalInMinutes(interval)
                                .repeatForever()
                )
                .startAt(futureDate(interval, DateBuilder.IntervalUnit.MINUTE))
                .build();

        getScheduler().scheduleJob(intervalTrigger);
    }

    private void startScheduler() throws SchedulerException
    {
        getScheduler().start();
    }

    private Scheduler getScheduler()
    {
        return scheduler;
    }

    public void addJob( String name, Class<? extends Job> c ) throws SchedulerException
    {
        JobDetail j = newJob(c)
                .withIdentity(name, AE_JOBS_GROUP)
                .storeDurably(true)
                .requestRecovery(false)
                .build();
        getScheduler().addJob(j, false);
    }

    public void addJob( String name, Class<? extends Job> c, Map<String, Object> dataMap, String group ) throws SchedulerException
    {
        JobDetail j = newJob(c)
                .withIdentity(name, group)
                .storeDurably(true)
                .requestRecovery(false)
                .build();

        j.getJobDataMap().putAll(dataMap);
        getScheduler().addJob(j, true);
    }

    public void addJob( String name, Class<? extends Job> c, JobDetail jobDetail ) throws SchedulerException
    {
        getScheduler().addJob(jobDetail, true);
    }

    private void scheduleJob( String name, String preferencePrefix ) throws ParseException, SchedulerException
    {
        String schedule = getPreferences().getString(preferencePrefix + ".schedule");
        Integer interval = getPreferences().getInteger(preferencePrefix + ".interval");
        Boolean atStart = getPreferences().getBoolean(preferencePrefix + ".atstart");

        if (null != schedule && 0 < schedule.length()) {
            CronExpression cexp = new CronExpression(schedule);
            Trigger cronTrigger = newTrigger()
                    .withIdentity(name + "_schedule_trigger", AE_JOBS_GROUP)
                    .withSchedule(CronScheduleBuilder.cronSchedule(cexp))
                    .forJob(name, AE_JOBS_GROUP)
                    .build();

            // schedule a job with JobDetail and Trigger
            getScheduler().scheduleJob(cronTrigger);
        }

        boolean hasScheduledInterval = false;

        if (null != interval) {
            scheduleIntervalJob(name, interval);
            hasScheduledInterval = true;
        }

        if ((null != atStart && atStart) && !hasScheduledInterval) {
            scheduleJobNow(name);
        }
    }

    private void terminateJobs() throws SchedulerException
    {
        if (null != getScheduler()) {
            getScheduler().pauseAll();

            List runningJobs = getScheduler().getCurrentlyExecutingJobs();
            for (Object jec : runningJobs) {
                JobDetail j = ((JobExecutionContext) jec).getJobDetail();
                getScheduler().interrupt(j.getKey());
            }

            getScheduler().shutdown(true);
        }
    }
}
