package uk.ac.ebi.fg.utils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.utils.efo.EFONode;
import uk.ac.ebi.arrayexpress.utils.efo.IEFO;
import uk.ac.ebi.fg.utils.objects.OntologySimilarityResult;

import java.io.Serializable;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Calculates ontology term distances based on EFO
 */
public class OntologyDistanceCalculator implements Serializable
{
    private static final long serialVersionUID = 4L;
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final int myMaxDistance;

    // Map contains result of calculation
    private Map<String, SortedSet<OntologySimilarityResult>> myQueryMap =
                    new ConcurrentHashMap<String, SortedSet<OntologySimilarityResult>>();


    public OntologyDistanceCalculator( IEFO efo, int maxDistance) throws InterruptedException
    {
        this.myMaxDistance = maxDistance;
        calculateDistances(efo);
    }

    /**
     * Calculates distances between nodes in ontology using Floyd-Warshall algorithm
     *
     * @param efo
     * @throws InterruptedException
     */
    public void calculateDistances(IEFO efo) throws InterruptedException
    {

        Map<String, EFONode> efoMap = efo.getMap();
        Map<String, Set<String>> partOfIdMap = efo.getPartOfIdMap();

        logger.info("Calculating distances");

        final ArrayList<String> completeURIList = new ArrayList<String>(efoMap.keySet());

        //create and initialize distance Matrix for OWLClasses
        int arrSize = completeURIList.size();
        int [][] distanceMatrix = new int[arrSize][arrSize];
        for (int i = 0; i != arrSize; ++i) {
            for (int j = 0; j != arrSize; ++j) {
                distanceMatrix[i][j] = Integer.MAX_VALUE;
            }
            distanceMatrix[i][i] = 0; // set distance to itself 0
        }

        // initialize parent-child distanceMatrix relationship; distance value 1
        initializeMatrix(distanceMatrix, completeURIList, efoMap, partOfIdMap);

        // Floyd-Warshall algorithm
        for (int k = 0; k != arrSize; ++k) {
            for (int i = 0; i != arrSize; ++i) {
                for (int j = 0; j != arrSize; ++j) {
                    if ( distanceMatrix[i][k] >= myMaxDistance || distanceMatrix[k][j] >= myMaxDistance )
                        continue;

                    distanceMatrix[i][j] =
                            Math.min(distanceMatrix[i][j],
                                    distanceMatrix[i][k] + distanceMatrix[k][j]);
                }
            }
            Thread.currentThread().wait(1);
        }

        // translate distances to query map
        for (int i = 0; i != arrSize; ++i) {
            SortedSet<OntologySimilarityResult> set =
                    Collections.synchronizedSortedSet(new TreeSet<OntologySimilarityResult>());
            myQueryMap.put( completeURIList.get(i), set);
            for (int j = 0; j != arrSize; ++j) {
                if (distanceMatrix[i][j] <= myMaxDistance)
                    set.add( new OntologySimilarityResult(completeURIList.get(j),
                                                            distanceMatrix[i][j]));
            }
        }

        logger.info("Distances have been calculated.");
    }

    /**
     * Sets parent-child and same level child node relationship distances to 1
     *
     * @param distanceMatrix
     * @param allURIs
     * @param efoMap
     * @param partOfIdMap
     */
    private void initializeMatrix(int[][] distanceMatrix, ArrayList<String> allURIs,
                                  Map<String, EFONode> efoMap, Map<String, Set<String>> partOfIdMap)
    {
        // initialize distanceMatrix
        for (Map.Entry<String, EFONode> e : efoMap.entrySet()) {
            int clIndex = allURIs.indexOf(e.getKey());
            if (e.getValue().hasChildren()) {
                for (EFONode childNode : e.getValue().getChildren()) {
                    int childNodeIndex = allURIs.indexOf(childNode.getId());

                    distanceMatrix[childNodeIndex][clIndex] = 1;
                    distanceMatrix[clIndex][childNodeIndex] = 1;

                    // set same level child distance to 1
                    for ( EFONode childNode2 : e.getValue().getChildren() ) {
                        if ( !childNode.equals(childNode2) ) {
                            int childNode2Index = allURIs.indexOf(childNode2.getId());

                            distanceMatrix[childNodeIndex][childNode2Index] = 1;
                            distanceMatrix[childNode2Index][childNodeIndex] = 1;
                        }
                    }
                }
            }
        }

        for (Map.Entry<String, Set<String>> e : partOfIdMap.entrySet()) {
            int clIndex = allURIs.indexOf(e.getKey());

            for (String eChild : e.getValue()) {
                int childIndex = allURIs.indexOf(eChild);

                distanceMatrix[childIndex][clIndex] = 1;
                distanceMatrix[clIndex][childIndex] = 1;

                // set same level child distance to 1
                for ( String eChild2 : e.getValue() ) {
                    if ( !eChild.equals(eChild2) ) {
                        int child2Index = allURIs.indexOf(eChild2);

                        distanceMatrix[childIndex][child2Index] = 1;
                        distanceMatrix[child2Index][childIndex] = 1;
                    }
                }
            }
        }
    }

    /**
     * Returns EFO URIs that are within distance limit
     *
     * @param   cl the node name in ontology like "http://www.ebi.ac.uk/efo/$NAME$"
     * @return  set of nodes that connected to cl
     */
    public Set<OntologySimilarityResult> getSimilarNodes(String cl)
    {
        return myQueryMap.get(cl);
    }

    public void clear()
    {
        myQueryMap.clear();
    }
}
