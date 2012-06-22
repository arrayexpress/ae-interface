package uk.ac.ebi.fg.jobs;

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

    public OntologySimilarityJob()
    {}

    public void doExecute(JobExecutionContext jobExecutionContext) throws JobExecutionException, InterruptedException
    {
        JobDataMap dataMap = jobExecutionContext.getJobDetail().getJobDataMap();
        Map<ExperimentId, SortedSet<EfoTerm>> smallMap = (Map<ExperimentId, SortedSet<EfoTerm>>)dataMap.get("smallMap");
        OntologyDistanceCalculator distanceCalculator = (OntologyDistanceCalculator)dataMap.get("distanceCalculator");
        Map<String, SortedSet<ExperimentId>> uriToExpMap = (ConcurrentHashMap<String, SortedSet<ExperimentId>>)dataMap.get("uriToExpMap");
        Map<ExperimentId, SortedSet<EfoTerm>> expToURIMap = (ConcurrentHashMap<ExperimentId, SortedSet<EfoTerm>>) dataMap.get("expToURIMap");
        Map<ExperimentId, SortedSet<ExperimentId>> ontologyResults = (ConcurrentHashMap<ExperimentId, SortedSet<ExperimentId>>)dataMap.get("ontologyResults");
        SortedSet<String> lowPriorityURIs = (SortedSet<String>) dataMap.get("lowPriorityOntologyURIs");
        int counter = (Integer) dataMap.get("counter");
        Configuration properties = (Configuration) dataMap.get("properties");

        final int maxOWLSimilarityCount = properties.getInt("max_displayed_OWL_similarities");
        final int smallExpAssayCountLimit = properties.getInt("small_experiment_assay_count_limit");
        final float minCalculatedOntologyDistance = properties.getFloat("minimal_calculated_ontology_distance");

        logger.info("Started " + (counter - smallMap.size()) + " - " + counter + " ontology similarity jobs");

        for ( Map.Entry<ExperimentId, SortedSet<EfoTerm>> entry : smallMap.entrySet() ) {
            ExperimentId experiment = entry.getKey();
                SortedSet<ExperimentId> resultExpSimilaritySet = new TreeSet<ExperimentId>();

                for( EfoTerm efoTerm : entry.getValue() ) {
                    Set<OntologySimilarityResult> similars = distanceCalculator.getSimilarNodes(efoTerm.getUri());

                    if (null != similars) {
                        for (OntologySimilarityResult ontologySimilarityResult : similars) {
                            int distance = ontologySimilarityResult.getDistance();
                            SortedSet<ExperimentId> similarExperiments = uriToExpMap.get(ontologySimilarityResult.getURI());

                            if ( similarExperiments != null ) {
                                for ( ExperimentId exp : similarExperiments ) {
                                    if ( experiment.getSpecies().equals(exp.getSpecies()) && !experiment.equals(exp) ) {
                                        if ( resultExpSimilaritySet.contains(exp) ) {
                                            ExperimentId expClone = resultExpSimilaritySet.tailSet(exp).first().clone();
                                            resultExpSimilaritySet.remove(exp);
                                            resultExpSimilaritySet.add(setDistance(expClone, ontologySimilarityResult.getURI(), lowPriorityURIs, distance));
                                        } else {
                                            ExperimentId expClone = exp.clone();
                                            resultExpSimilaritySet.add(setDistance(expClone, ontologySimilarityResult.getURI(), lowPriorityURIs, distance));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

            ontologyResults.put(experiment, cleanResults(experiment, resultExpSimilaritySet, smallExpAssayCountLimit,
                       maxOWLSimilarityCount, minCalculatedOntologyDistance, expToURIMap));

            Thread.currentThread().wait(1);
        }

        logger.info("Finished " + (counter - smallMap.size()) + " - " + counter + " ontology similarity jobs");

        smallMap.clear();
    }

    /**
     * Increases distance count for experiment instance
     *
     * @param exp               Experiment holding distances
     * @param URI               URI
     * @param lowPriorityURIs   URIs with lowered priority
     * @param dist              URI distance
     * @return
     */
    private ExperimentId setDistance( ExperimentId exp, String URI, SortedSet<String> lowPriorityURIs, int dist )
    {
        if ( lowPriorityURIs.contains(URI) ) {
            exp.setLowPriorityMatchCount(exp.getLowPriorityMatchCount() + 1);
            exp.setNumbOfMatches(exp.getNumbOfMatches() + 1);
        } else {
            switch (dist) {
                case 0: exp.setDist0Count(exp.getDist0Count() + 1);
                        exp.setNumbOfMatches(exp.getNumbOfMatches() + 1);
                        break;
                case 1: exp.setDist1Count(exp.getDist1Count() + 1);
                        exp.setNumbOfMatches(exp.getNumbOfMatches() + 1);
                        break;
                case 2: exp.setDist2Count(exp.getDist2Count() + 1);
                        exp.setNumbOfMatches(exp.getNumbOfMatches() + 1);
                        break;
                default: logger.warn("URI distance out of bounds for experiment " + exp.getAccession() + ", URI: " + URI);
                        break;
            }
        }

        return exp;
    }

    /**
     * Applies all required restrictions to similar experiment set
     *
     * @param exp                               Main experiment
     * @param similarExperiments                Similar experiment set
     * @param smallExpAssayCountLimit           assay limit
     * @param maxOWLSimilarityCount             maximal number of returned similar experiments
     * @param minCalculatedOntologyDistance     calculated coefficient that similar experiments need to exceed
     * @param expToURIMap                       map containing experiments with all URIs associated with each
     * @return
     */
    private SortedSet<ExperimentId> cleanResults( ExperimentId exp, SortedSet<ExperimentId> similarExperiments,
                                                  int smallExpAssayCountLimit, int maxOWLSimilarityCount,
                                                  float minCalculatedOntologyDistance,
                                                  Map<ExperimentId, SortedSet<EfoTerm>> expToURIMap)
    {
        List<ExperimentId> expList = new LinkedList<ExperimentId>(similarExperiments);

        expList = removeLargeOntologyExperiments(exp, expList, smallExpAssayCountLimit);
        calculateDistances(expList, expToURIMap);
        Collections.sort(expList, new ExperimentComparator());

        // restrict number of experiments written in file
        return limitOntologyExperimentCount(expList, maxOWLSimilarityCount, minCalculatedOntologyDistance);
    }

    /**
     * Applies assay (hybridisation) restrictions. If experiment assay count is under the limit
     * similar experiment list is filtrated to remove similar experiments exceeding the limit
     *
     * @param mainExp                   experiment
     * @param expList                   similar experiment list
     * @param smallExpAssayCountLimit   assay limit
     * @return
     */
    private List<ExperimentId> removeLargeOntologyExperiments ( ExperimentId mainExp, List<ExperimentId> expList, int smallExpAssayCountLimit )
    {
        List<ExperimentId> resultList = new LinkedList<ExperimentId>();
        resultList.addAll(expList);

        if ( mainExp.getAssayCount() <= smallExpAssayCountLimit ) {
            for ( ExperimentId exp : expList ) {
                if ( exp.getAssayCount() > smallExpAssayCountLimit )
                    resultList.remove(exp);
            }
        }

        return resultList;
    }

    /**
     * Calculates distances
     *
     * @param expList       experiments that need distances calculated
     * @param expToURIMap   map containing experiments with all URIs associated with each
     */
    private void calculateDistances( List<ExperimentId> expList, Map<ExperimentId, SortedSet<EfoTerm>> expToURIMap )
    {
        float lowPriorityCoefficient = 0.001f;
        float dist1Coefficient = 0.25f;
        float dist2Coefficient = 0.5f;

        for ( ExperimentId exp : expList ) {
            if ( exp.getNumbOfMatches() != 0 ) {
                float numbOfLinks = exp.getNumbOfMatches();
                float dist0Count = exp.getDist0Count();
                float dist1Count = exp.getDist1Count();
                float dist2Count = exp.getDist2Count();
                float lowPriorityCount = exp.getLowPriorityMatchCount();

                float numbOfTerms = expToURIMap.get(exp).size();

                exp.setCalculatedDistance(
                        numbOfLinks / numbOfTerms + dist0Count
                                - dist1Count / numbOfTerms * dist1Coefficient
                                - dist2Count / numbOfTerms * dist2Coefficient
                                + lowPriorityCount / numbOfTerms * lowPriorityCoefficient
                );
            }
        }
    }

    /**
     * Returns limited set of experiments
     *
     * @param expList                           experiments
     * @param maxOWLSimilarityCount             maximal number of returned similar experiments
     * @param minCalculatedOntologyDistance     calculated coefficient that similar experiments need to exceed
     * @return
     */
    private SortedSet<ExperimentId> limitOntologyExperimentCount( List<ExperimentId> expList, int maxOWLSimilarityCount,
                                                                  float minCalculatedOntologyDistance )
    {
        Iterator<ExperimentId> iterator = expList.iterator();
        SortedSet<ExperimentId> restrictedSet = new TreeSet<ExperimentId>();
        int OWLCounter = 1;

        while ( iterator.hasNext() ) {
            ExperimentId exp = iterator.next();
            if ( exp.getType().equals(ReceivingType.OWL) && (exp.getOWLDistance() != Integer.MAX_VALUE)
                    && (OWLCounter <= maxOWLSimilarityCount) && minCalculatedOntologyDistance <= exp.getCalculatedDistance()) {
                restrictedSet.add(exp);
                ++OWLCounter;
            }
        }

        return restrictedSet;
    }
}
