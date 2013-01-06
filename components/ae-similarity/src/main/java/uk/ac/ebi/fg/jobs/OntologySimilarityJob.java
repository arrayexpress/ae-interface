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
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.fg.utils.ApplicationJob;
import uk.ac.ebi.fg.utils.ExperimentComparator;
import uk.ac.ebi.fg.utils.OntologyDistanceCalculator;
import uk.ac.ebi.fg.utils.ReceivingType;
import uk.ac.ebi.fg.utils.objects.EfoTerm;
import uk.ac.ebi.fg.utils.objects.ExperimentId;
import uk.ac.ebi.fg.utils.objects.OntologySimilarityResult;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Calculates ontology similarity distances between experiments
 */
public class OntologySimilarityJob extends ApplicationJob
{
    private final Logger logger = LoggerFactory.getLogger(getClass());
    private SortedSet<String> lowPriorityURIs;

    public OntologySimilarityJob()
    {
    }

    public void doExecute( JobExecutionContext jobExecutionContext ) throws JobExecutionException, InterruptedException
    {
        JobDataMap dataMap = jobExecutionContext.getJobDetail().getJobDataMap();
        Map<ExperimentId, SortedSet<EfoTerm>> smallMap = (Map<ExperimentId, SortedSet<EfoTerm>>) dataMap.get("smallMap");
        OntologyDistanceCalculator distanceCalculator = (OntologyDistanceCalculator) dataMap.get("distanceCalculator");
        Map<String, SortedSet<ExperimentId>> uriToExpMap = (ConcurrentHashMap<String, SortedSet<ExperimentId>>) dataMap.get("uriToExpMap");
        Map<ExperimentId, SortedSet<EfoTerm>> expToURIMap = (ConcurrentHashMap<ExperimentId, SortedSet<EfoTerm>>) dataMap.get("expToURIMap");
        Map<ExperimentId, SortedSet<ExperimentId>> ontologyResults = (ConcurrentHashMap<ExperimentId, SortedSet<ExperimentId>>) dataMap.get("ontologyResults");
        lowPriorityURIs = (SortedSet<String>) dataMap.get("lowPriorityOntologyURIs");
        int counter = (Integer) dataMap.get("counter");
        Configuration properties = (Configuration) dataMap.get("properties");

        final int maxOWLSimilarityCount = properties.getInt("max_displayed_OWL_similarities");
        final int smallExpAssayCountLimit = properties.getInt("small_experiment_assay_count_limit");
        final float minCalculatedOntologyDistance = properties.getFloat("minimal_calculated_ontology_distance");

        logger.info("Started " + (counter - smallMap.size()) + " - " + counter + " ontology similarity jobs");

        for (Map.Entry<ExperimentId, SortedSet<EfoTerm>> entry : smallMap.entrySet()) {
            ExperimentId experiment = entry.getKey();
            SortedSet<ExperimentId> resultExpSimilaritySet = new TreeSet<ExperimentId>();

            for (EfoTerm efoTerm : entry.getValue()) {
                Set<OntologySimilarityResult> similars = distanceCalculator.getSimilarNodes(efoTerm.getUri());

                if (null != similars) {
                    for (OntologySimilarityResult ontologySimilarityResult : similars) {
                        int distance = ontologySimilarityResult.getDistance();
                        SortedSet<ExperimentId> similarExperiments = uriToExpMap.get(ontologySimilarityResult.getURI());

                        if (similarExperiments != null) {
                            for (ExperimentId exp : similarExperiments) {
                                if (experiment.getSpecies().equals(exp.getSpecies()) && !experiment.equals(exp)) {
                                    if (resultExpSimilaritySet.contains(exp)) {
                                        ExperimentId expClone = resultExpSimilaritySet.tailSet(exp).first().clone();
                                        resultExpSimilaritySet.remove(exp);
                                        resultExpSimilaritySet.add(setDistance(expClone, ontologySimilarityResult.getURI(), distance));
                                    } else {
                                        ExperimentId expClone = exp.clone();
                                        resultExpSimilaritySet.add(setDistance(expClone, ontologySimilarityResult.getURI(), distance));
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // store information for maximal score calculation
            ExperimentId experimentClone = experiment.clone();
            for ( EfoTerm efoTerm : expToURIMap.get(experimentClone) ) {
                if ( lowPriorityURIs.contains(efoTerm.getUri()) )
                    experimentClone.setLowPriorityMatchCount( experimentClone.getLowPriorityMatchCount() + 1 );
                else
                    experimentClone.setDist0Count( experimentClone.getDist0Count() + 1 );

                experimentClone.setNumbOfMatches( experimentClone.getNumbOfMatches() + 1 );
            }

            ontologyResults.put(experimentClone, cleanResults(experimentClone, resultExpSimilaritySet, smallExpAssayCountLimit,
                    maxOWLSimilarityCount, minCalculatedOntologyDistance, expToURIMap));

            Thread.currentThread().wait(1);
        }

        logger.info("Finished " + (counter - smallMap.size()) + " - " + counter + " ontology similarity jobs");

        smallMap.clear();
    }

    /**
     * Increases distance count for experiment instance
     *
     * @param exp             Experiment holding distances
     * @param URI             URI
     * @param dist            URI distance
     * @return
     */
    private ExperimentId setDistance( ExperimentId exp, String URI, int dist )
    {
        if (lowPriorityURIs.contains(URI)) {
            exp.setLowPriorityMatchCount(exp.getLowPriorityMatchCount() + 1);
            exp.setNumbOfMatches(exp.getNumbOfMatches() + 1);
        } else {
            switch (dist) {
                case 0:
                    exp.setDist0Count(exp.getDist0Count() + 1);
                    exp.setNumbOfMatches(exp.getNumbOfMatches() + 1);
                    break;
                case 1:
                    exp.setDist1Count(exp.getDist1Count() + 1);
                    exp.setNumbOfMatches(exp.getNumbOfMatches() + 1);
                    break;
                case 2:
                    exp.setDist2Count(exp.getDist2Count() + 1);
                    exp.setNumbOfMatches(exp.getNumbOfMatches() + 1);
                    break;
                default:
                    logger.warn("URI distance out of bounds for experiment " + exp.getAccession() + ", URI: " + URI);
                    break;
            }
        }

        return exp;
    }

    /**
     * Applies all required restrictions to similar experiment set
     *
     * @param exp                           Main experiment
     * @param similarExperiments            Similar experiment set
     * @param smallExpAssayCountLimit       assay limit
     * @param maxOWLSimilarityCount         maximal number of returned similar experiments
     * @param minCalculatedOntologyDistance calculated coefficient that similar experiments need to exceed
     * @param expToURIMap                   map containing experiments with all URIs associated with each
     * @return
     */
    private SortedSet<ExperimentId> cleanResults( ExperimentId exp, SortedSet<ExperimentId> similarExperiments,
                                                  int smallExpAssayCountLimit, int maxOWLSimilarityCount,
                                                  float minCalculatedOntologyDistance,
                                                  Map<ExperimentId, SortedSet<EfoTerm>> expToURIMap )
    {
        float maxScore = 0;
        List<ExperimentId> expList = new LinkedList<ExperimentId>(similarExperiments);

        expList = removeLargeOntologyExperiments(exp, expList, smallExpAssayCountLimit);
        calculateDistances(exp, expList, expToURIMap, maxScore);
        Collections.sort(expList, new ExperimentComparator());    // must sort by scores in descending order

        // restrict number of experiments written in file
        return limitOntologyExperimentCount(expList, maxOWLSimilarityCount, minCalculatedOntologyDistance, maxScore );
    }

    /**
     * Applies assay (hybridisation) restrictions. If experiment assay count is under the limit
     * similar experiment list is filtrated to remove similar experiments exceeding the limit
     *
     * @param mainExp                 experiment
     * @param expList                 similar experiment list
     * @param smallExpAssayCountLimit assay limit
     * @return
     */
    private List<ExperimentId> removeLargeOntologyExperiments( ExperimentId mainExp, List<ExperimentId> expList, int smallExpAssayCountLimit )
    {
        List<ExperimentId> resultList = new LinkedList<ExperimentId>();
        resultList.addAll(expList);

        if (mainExp.getAssayCount() <= smallExpAssayCountLimit) {
            for (ExperimentId exp : expList) {
                if (exp.getAssayCount() > smallExpAssayCountLimit)
                    resultList.remove(exp);
            }
        }

        return resultList;
    }

    /**
     * Calculates distances
     *
     * @param expList     experiments that need distances calculated
     * @param expToURIMap map containing experiments with all URIs associated with each
     */
    private void calculateDistances( ExperimentId mainExp, List<ExperimentId> expList, Map<ExperimentId,
            SortedSet<EfoTerm>> expToURIMap, float maxScore )
    {
        float lowPriorityCoefficient = 0.001f;
        float dist1Coefficient = 0.25f;
        float dist2Coefficient = 0.5f;

        // calculate max score
        maxScore = (1 + mainExp.getDist0Count()
                        + mainExp.getLowPriorityMatchCount() / expToURIMap.get(mainExp).size() * lowPriorityCoefficient) / 9 * 10;

        for (ExperimentId exp : expList) {
            if (exp.getNumbOfMatches() != 0) {
                float numbOfLinks = exp.getNumbOfMatches();
                float dist0Count = exp.getDist0Count();
                float dist1Count = exp.getDist1Count();
                float dist2Count = exp.getDist2Count();
                float lowPriorityCount = exp.getLowPriorityMatchCount();

                float numbOfTerms = expToURIMap.get(exp).size();

                int totalLowPriorityURIs = 0;
                for ( EfoTerm term : expToURIMap.get(exp) ) {
                    if ( lowPriorityURIs.contains(term.getUri()) )
                        totalLowPriorityURIs++;
                }

                // low priority terms that main exp doesn't have
                float difference = ( totalLowPriorityURIs - lowPriorityCount ) - mainExp.getLowPriorityMatchCount();
                if ( difference > 0 ) {          // calculate score taking into account low priority links that mainExp doesn't have
                    exp.setCalculatedDistance(
                            (numbOfLinks / (numbOfTerms - difference) > 1) ? 0 : numbOfLinks / (numbOfTerms - difference)
                            + dist0Count
                            - dist1Count / numbOfTerms * dist1Coefficient
                            - dist2Count / numbOfTerms * dist2Coefficient
                            - difference / (numbOfTerms - difference) * lowPriorityCoefficient
                    );
                } else {
                    exp.setCalculatedDistance(
                            numbOfLinks / numbOfTerms
                            + dist0Count
                            - dist1Count / numbOfTerms * dist1Coefficient
                            - dist2Count / numbOfTerms * dist2Coefficient
                            + lowPriorityCount / numbOfTerms * lowPriorityCoefficient
                    );
                }
            }
        }
    }

    /**
     * Returns limited set of experiments
     *
     * @param expList                       experiments
     * @param maxOWLSimilarityCount         maximal number of returned similar experiments
     * @param minCalculatedOntologyDistance calculated coefficient that similar experiments need to exceed
     * @return
     */
    private SortedSet<ExperimentId> limitOntologyExperimentCount( List<ExperimentId> expList, int maxOWLSimilarityCount,
                                                                  float minCalculatedOntologyDistance, float maxScore )
    {
        Iterator<ExperimentId> iterator = expList.iterator();
        SortedSet<ExperimentId> restrictedSet = new TreeSet<ExperimentId>();
        int OWLCounter = 1;

        while (iterator.hasNext()) {
            ExperimentId exp = iterator.next();

            // deal with large scores - experiment with large number of links can exceed maxScore
            if ( exp.getCalculatedDistance() > maxScore )
                maxScore = exp.getCalculatedDistance() / 9 * 10;    // best score becomes 90% of maxScore

            if (exp.getType().equals(ReceivingType.OWL) && (exp.getOWLDistance() != Integer.MAX_VALUE)
                    && (OWLCounter <= maxOWLSimilarityCount) && minCalculatedOntologyDistance <= exp.getCalculatedDistance()) {
                exp.setCalculatedDistance( exp.getCalculatedDistance() / maxScore * 100 );   // change score into percentage
                restrictedSet.add(exp);
                ++OWLCounter;
            }
        }

        return restrictedSet;
    }
}
