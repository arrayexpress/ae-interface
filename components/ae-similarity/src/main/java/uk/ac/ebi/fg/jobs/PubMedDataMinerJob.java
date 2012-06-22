package uk.ac.ebi.fg.jobs;

import org.apache.commons.configuration.Configuration;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.fg.utils.ApplicationJob;
import uk.ac.ebi.fg.utils.PubMedRetriever;
import uk.ac.ebi.fg.utils.objects.PubMedId;

import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Adds records to PubMed id relation map. Record contains id and set of ids with distances
 */
public class PubMedDataMinerJob extends ApplicationJob
{
    private final Logger logger = LoggerFactory.getLogger(getClass());
    public PubMedDataMinerJob() {}

    public void doExecute(JobExecutionContext jobExecutionContext) throws JobExecutionException, InterruptedException
    {
        JobDataMap dataMap = jobExecutionContext.getMergedJobDataMap();

        Set<String> pubMedNewIds = (Set<String>)dataMap.get("pubMedNewIds");
        ConcurrentHashMap<String, SortedSet<PubMedId>> pubMedIdRelationMap = (ConcurrentHashMap<String, SortedSet<PubMedId>>)dataMap.get("pubMedIdRelationMap");
        Configuration properties = (Configuration)dataMap.get("properties");
        AtomicInteger pubMedCounter = (AtomicInteger) dataMap.get("pubMedCounter");
        PubMedRetriever pubMedRetriever = (PubMedRetriever) dataMap.get("pubMedRetriever");
        String entry = (String) dataMap.get("entry");

        String pubMedURL = properties.getString("pub_med_url");
        int maxPubMedDist = properties.getInt("max_pubmed_distance");
        SortedSet<PubMedId> similarPublications = new TreeSet<PubMedId>();

        // add publication with distance 0
        similarPublications.add(new PubMedId(entry, 0));

        // get similar publications (distance 1)
        similarPublications.addAll(getPubMedIdSet(pubMedRetriever.getSimilars(pubMedURL, entry), 1));

        // get publications with distance 2
        if ( null != similarPublications && maxPubMedDist == 2 ) {
            SortedSet<PubMedId> iterationSet = new TreeSet<PubMedId>(similarPublications);

            for (PubMedId publication : iterationSet)
                similarPublications.addAll(getPubMedIdSet(pubMedRetriever.getSimilars(pubMedURL, publication.getPublicationId()), 2));
        }

        if ( !similarPublications.isEmpty() )
            pubMedIdRelationMap.putIfAbsent(entry, similarPublications);

         // delay job to run for 1 second
         Thread.currentThread().wait(1000);

        logger.debug("Finished " + pubMedCounter.incrementAndGet() + " of "+ pubMedNewIds.size() + " PubMedDataMinerJobs");
    }

    /**
     * Creates PubMed publications with set distance
     *
     * @param set       publications
     * @param distance  distance
     * @return
     */
    private SortedSet<PubMedId> getPubMedIdSet( SortedSet<String> set, int distance )
    {
        SortedSet<PubMedId> result = new TreeSet<PubMedId>();

        if ( null != set ) {
            for ( String pubMedId : set ) {
                result.add(new PubMedId(pubMedId, distance));
            }
        }

        return result;
    }
}
