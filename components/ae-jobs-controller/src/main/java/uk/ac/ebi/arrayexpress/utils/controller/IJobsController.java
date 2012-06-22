package uk.ac.ebi.arrayexpress.utils.controller;

import org.quartz.Job;
import org.quartz.JobDetail;
import org.quartz.JobListener;
import org.quartz.SchedulerException;

import java.util.Map;

public interface IJobsController
{
    public void addJob( String name, Class<? extends Job> c, Map<String, Object> dataMap, String group ) throws SchedulerException;
    public void addJob( String name, Class<? extends Job> c, JobDetail jobDetail ) throws SchedulerException;
    public void executeJob( String name, String group ) throws SchedulerException;
    public void addJobListener( JobListener jl ) throws SchedulerException;
}
