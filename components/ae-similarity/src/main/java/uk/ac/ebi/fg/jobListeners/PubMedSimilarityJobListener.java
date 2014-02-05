package uk.ac.ebi.fg.jobListeners;

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
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import uk.ac.ebi.arrayexpress.utils.controller.IJobsController;
import uk.ac.ebi.fg.jobs.PubMedUpdateFileJob;
import uk.ac.ebi.fg.utils.ApplicationJobListener;
import uk.ac.ebi.fg.utils.objects.StaticJobController;

/**
 * After PubMed file has been updated starts PubMed similarity job
 */
public class PubMedSimilarityJobListener extends ApplicationJobListener
{
    public PubMedSimilarityJobListener( String name )
    {
        super(name);
    }

    public void jobExecuted( JobExecutionContext jobExecutionContext ) throws Exception
    {
        JobDetail jobDetail = jobExecutionContext.getJobDetail();

        if (jobDetail.getJobClass().equals(PubMedUpdateFileJob.class)) {
            IJobsController jobsController = StaticJobController.getJobController();

            jobsController.executeJob("PubMedSimilarityJob", ((Configuration) jobDetail.getJobDataMap().get("properties")).getString("quartz_job_group_name"));
        }
    }
}
