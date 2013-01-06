package uk.ac.ebi.fg.jobs;

/*
 * Copyright 2009-2013 European Molecular Biology Laboratory
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
import uk.ac.ebi.fg.utils.OntologyDistanceCalculator;
import uk.ac.ebi.fg.utils.objects.EfoTerm;
import uk.ac.ebi.fg.utils.objects.ExperimentId;

import java.util.HashMap;
import java.util.Map;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.concurrent.ConcurrentHashMap;

import static org.quartz.JobBuilder.newJob;

/**
 * Separates experiment list into smaller lists and creates concurrent jobs for similarity calculations
 */
public class OntologySimilarityWrapperJob extends ApplicationJob
{
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public OntologySimilarityWrapperJob()
    {
    }

    public void doExecute( JobExecutionContext jobExecutionContext ) throws InterruptedException, SchedulerException
    {
        // get data from context
        JobDataMap dataMap = jobExecutionContext.getJobDetail().getJobDataMap();
        IJobsController jobsController = (IJobsController) dataMap.get("jobsController");
        OntologyDistanceCalculator distanceCalculator = (OntologyDistanceCalculator) dataMap.get("distanceCalculator");
        Map<ExperimentId, SortedSet<ExperimentId>> ontologyResults = (ConcurrentHashMap<ExperimentId, SortedSet<ExperimentId>>) dataMap.get("ontologyResults");
        Map<ExperimentId, SortedSet<EfoTerm>> expToURIMap = (ConcurrentHashMap<ExperimentId, SortedSet<EfoTerm>>) dataMap.get("expToURIMap");
        SortedSet<String> lowPriorityURIs = (SortedSet<String>) dataMap.get("lowPriorityOntologyURIs");
        Configuration properties = (Configuration) dataMap.get("properties");
        String jobGroup = properties.getString("quartz_job_group_name");
        int threadLimit = (properties.getInt("concurrent_job_limit") > 1) ? properties.getInt("concurrent_job_limit") - 1 : 1; // leave 1 thread for pubmed calculations

        Map<ExperimentId, SortedSet<EfoTerm>> smallMap = new HashMap<ExperimentId, SortedSet<EfoTerm>>();
        int counter = 0;
        int separateAt = expToURIMap.size() / threadLimit + expToURIMap.size() % threadLimit;

        Map<String, SortedSet<ExperimentId>> uriToExpMap = reverseMap(expToURIMap);

        logger.info("Ontology jobs started");
        for (Map.Entry<ExperimentId, SortedSet<EfoTerm>> entry : expToURIMap.entrySet()) {
            smallMap.put(entry.getKey(), entry.getValue());
            ++counter;

            if (counter % separateAt == 0 || counter == expToURIMap.size()) {
                JobDetail ontologyJobDetail = newJob(OntologySimilarityJob.class)
                        .withIdentity("ontologySimilarityJob" + counter, jobGroup)
                        .storeDurably(false)
                        .requestRecovery(false)
                        .build();

                ontologyJobDetail.getJobDataMap().put("smallMap", new HashMap<ExperimentId, SortedSet<EfoTerm>>(smallMap));
                ontologyJobDetail.getJobDataMap().put("distanceCalculator", distanceCalculator);
                ontologyJobDetail.getJobDataMap().put("uriToExpMap", uriToExpMap);
                ontologyJobDetail.getJobDataMap().put("expToURIMap", expToURIMap);
                ontologyJobDetail.getJobDataMap().put("ontologyResults", ontologyResults);
                ontologyJobDetail.getJobDataMap().put("lowPriorityOntologyURIs", lowPriorityURIs);
                ontologyJobDetail.getJobDataMap().put("counter", new Integer(counter));
                ontologyJobDetail.getJobDataMap().put("properties", properties);

                jobsController.addJob("ontologySimilarityJob" + counter, OntologySimilarityJob.class, ontologyJobDetail);
                jobsController.executeJob("ontologySimilarityJob" + counter, jobGroup);

                // clear map
                smallMap.clear();
                separateAt = expToURIMap.size() / threadLimit;
            }
        }
    }

    /**
     * Reverses map containing experiments with URIs.
     *
     * @param map
     * @return URI with experiment set
     */
    private Map<String, SortedSet<ExperimentId>> reverseMap( Map<ExperimentId, SortedSet<EfoTerm>> map )
    {
        Map<String, SortedSet<ExperimentId>> reverseMap = new ConcurrentHashMap<String, SortedSet<ExperimentId>>();  // URI, experiments

        for (Map.Entry<ExperimentId, SortedSet<EfoTerm>> entry : map.entrySet()) {
            for (EfoTerm term : entry.getValue()) {
                if (reverseMap.containsKey(term.getUri()))
                    reverseMap.get(term.getUri()).add(entry.getKey());
                else {
                    SortedSet<ExperimentId> set = new TreeSet<ExperimentId>();
                    set.add(entry.getKey());
                    reverseMap.put(term.getUri(), set);
                }
            }
        }

        return reverseMap;
    }
}

