package uk.ac.ebi.fg.jobs;

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

import org.apache.commons.configuration.Configuration;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.fg.utils.ApplicationJob;
import uk.ac.ebi.fg.utils.ReceivingType;
import uk.ac.ebi.fg.utils.objects.ExperimentId;
import uk.ac.ebi.fg.utils.objects.PubMedId;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Converts all gathered id relations into experiment distances
 */
public class PubMedSimilarityJob extends ApplicationJob
{
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public PubMedSimilarityJob()
    {
    }

    public void doExecute( JobExecutionContext jobExecutionContext ) throws JobExecutionException, InterruptedException
    {
        JobDataMap dataMap = jobExecutionContext.getMergedJobDataMap();

        Map<String, String> expToPubMedIdMap = (ConcurrentHashMap<String, String>) dataMap.get("expToPubMedIdMap");
        Map<String, SortedSet<PubMedId>> pubMedIdRelationMap = (Map<String, SortedSet<PubMedId>>) dataMap.get("pubMedIdRelationMap");
        ConcurrentHashMap<String, SortedSet<ExperimentId>> pubMedResults = (ConcurrentHashMap<String, SortedSet<ExperimentId>>) dataMap.get("pubMedResults");
        Configuration properties = (Configuration) dataMap.get("properties");

        final int maxPubMedSimilarityCount = properties.getInt("max_displayed_PubMed_similarities");
        Map<String, SortedSet<String>> pubMedIdToExpAccessionMap = reverseMap(expToPubMedIdMap);
        expToPubMedIdMap.clear();

        logger.info("PubMedSimilarityJob started");

        for (Map.Entry<String, SortedSet<String>> pubMedIdToExpAccession : pubMedIdToExpAccessionMap.entrySet()) {
            SortedSet<ExperimentId> result = new TreeSet<ExperimentId>();

            if (pubMedIdRelationMap.containsKey(pubMedIdToExpAccession.getKey())) {     // false - failed to get similar PubMed ids
                for (PubMedId publication : pubMedIdRelationMap.get(pubMedIdToExpAccession.getKey())) {
                    result.addAll(getExperiments(pubMedIdToExpAccessionMap, publication));
                }

                for (String expAccession : pubMedIdToExpAccession.getValue()) {
                    pubMedResults.putIfAbsent(expAccession, limitPubMedExperimentCount(result, maxPubMedSimilarityCount, expAccession));
                }
            }

            Thread.currentThread().wait(1);
        }

        pubMedIdToExpAccessionMap.clear();
        pubMedIdRelationMap.clear();
        logger.info("PubMedSimilarityJob finished");
    }

    /**
     * Creates experiment set with distances for particular PubMed id
     *
     * @param pubMedIdToExpAccessionMap all PubMed ids with experiments
     * @param publication               PubMed id
     * @return
     */
    private SortedSet<ExperimentId> getExperiments( Map<String, SortedSet<String>> pubMedIdToExpAccessionMap,
                                                    PubMedId publication )
    {
        SortedSet<ExperimentId> result = new TreeSet<ExperimentId>();

        if (pubMedIdToExpAccessionMap.containsKey(publication.getPublicationId())) {
            for (String expAccession : pubMedIdToExpAccessionMap.get(publication.getPublicationId()))
                result.add(new ExperimentId(expAccession, ReceivingType.PUBMED, scoreInPercentage(publication.getDistance())));
        }

        return result;
    }

    /**
     * Reverses map containing experiments with PubMed ids
     *
     * @param expToPubMedIdMap
     * @return map containing PubMed ids with a set of experiment accessions
     */
    private Map<String, SortedSet<String>> reverseMap( Map<String, String> expToPubMedIdMap )
    {
        Map<String, SortedSet<String>> reverseMap = new HashMap<String, SortedSet<String>>();  // publication id, experiment accessions

        for (Map.Entry<String, String> entry : expToPubMedIdMap.entrySet()) {  // exp, pubmed id
            String expAccession = entry.getKey();
            String pubMedId = entry.getValue();

            if (reverseMap.containsKey(pubMedId))
                reverseMap.get(pubMedId).add(expAccession);
            else {
                SortedSet<String> set = new TreeSet<String>();
                set.add(expAccession);
                reverseMap.put(pubMedId, set);
            }
        }

        return reverseMap;
    }

    /**
     * Returns limited set of experiments
     *
     * @param expSet                   experiment set
     * @param maxPubMedSimilarityCount maximal distance between experiments
     * @param expAccession             experiment accession that will be excluded from return set
     * @return
     */
    private SortedSet<ExperimentId> limitPubMedExperimentCount( Set<ExperimentId> expSet, int maxPubMedSimilarityCount, String expAccession )
    {
        Iterator<ExperimentId> iterator = expSet.iterator();
        SortedSet<ExperimentId> restrictedSet = new TreeSet<ExperimentId>();
        int PubMedCounter = 1;

        while (iterator.hasNext()) {
            ExperimentId exp = iterator.next();
            if (exp.getType().equals(ReceivingType.PUBMED) && (exp.getPubMedDistance() != Integer.MAX_VALUE)
                    && (PubMedCounter <= maxPubMedSimilarityCount) && !exp.getAccession().equals(expAccession)) {
                restrictedSet.add(exp);
                ++PubMedCounter;
            }
        }

        return restrictedSet;
    }

    /**
     * Transform distance into percentage
     *
     * @param score     publication distance
     * @return          percentage
     */
    private int scoreInPercentage ( int score )
    {
        switch ( score ) {
            case 0:
                return 90;         // todo: adjust scoring
            case 1:
                return 70;
            default:
                return score;
        }
    }
}
