package uk.ac.ebi.fg.jobs;

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

import org.apache.commons.configuration.Configuration;
import org.quartz.JobDataMap;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.SchedulerException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.utils.controller.IJobsController;
import uk.ac.ebi.fg.utils.ApplicationJob;
import uk.ac.ebi.fg.utils.objects.EfoTerm;
import uk.ac.ebi.fg.utils.objects.ExperimentId;

import javax.xml.xpath.XPath;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.SortedSet;
import java.util.concurrent.ConcurrentHashMap;

import static org.quartz.JobBuilder.newJob;

/**
 * Separates experiment list into smaller lists and creates concurrent jobs for data extraction
 */
public class TermToURIMappingWrapperJob extends ApplicationJob
{
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public TermToURIMappingWrapperJob()
    {
    }

    public void doExecute( JobExecutionContext jobExecutionContext ) throws InterruptedException, SchedulerException
    {
        JobDataMap dataMap = jobExecutionContext.getJobDetail().getJobDataMap();

        IJobsController jobsController = (IJobsController) dataMap.get("jobsController");
        Map<ExperimentId, SortedSet<EfoTerm>> expToURIMap = (ConcurrentHashMap<ExperimentId, SortedSet<EfoTerm>>) dataMap.get("expToURIMap");
        Map<String, String> expToPubMedIdMap = (ConcurrentHashMap<String, String>) dataMap.get("expToPubMedIdMap");
        List experiments = (List) dataMap.get("experiments");
        XPath xp = (XPath) dataMap.get("experimentXPath");
        Configuration properties = (Configuration) dataMap.get("properties");
        String jobGroup = properties.getString("quartz_job_group_name");
        int threadLimit = (properties.getInt("concurrent_job_limit") > 1) ? properties.getInt("concurrent_job_limit") : 1;

        List smallExperimentList = new LinkedList();
        int counter = 0;
        int separateAt = experiments.size() / threadLimit + experiments.size() % threadLimit;

        logger.info("Term to URI mapping jobs started");
        for (Object node : experiments) {
            smallExperimentList.add(node);
            ++counter;

            if (counter % separateAt == 0 || counter == experiments.size()) {
                JobDetail termToURIMappingJobDetail = newJob(TermToURIMappingJob.class)
                        .withIdentity("termToURIMappingJob" + counter, jobGroup)
                        .storeDurably(false)
                        .requestRecovery(false)
                        .build();

                termToURIMappingJobDetail.getJobDataMap().put("experiments", new LinkedList(smallExperimentList));
                termToURIMappingJobDetail.getJobDataMap().put("expToURIMap", expToURIMap);
                termToURIMappingJobDetail.getJobDataMap().put("expToPubMedIdMap", expToPubMedIdMap);
                termToURIMappingJobDetail.getJobDataMap().put("experimentXPath", xp);
                termToURIMappingJobDetail.getJobDataMap().put("counter", new Integer(counter));
                termToURIMappingJobDetail.getJobDataMap().put("separateAt", separateAt);   // for jobListener use

                jobsController.addJob("termToURIMappingJob" + counter, TermToURIMappingJob.class, termToURIMappingJobDetail);
                jobsController.executeJob("termToURIMappingJob" + counter, jobGroup);

                // clear list
                smallExperimentList.clear();
                Thread.currentThread().wait(1);
            }
        }
    }
}
