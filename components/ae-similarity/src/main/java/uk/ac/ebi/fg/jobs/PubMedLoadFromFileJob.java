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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.fg.utils.ApplicationJob;
import uk.ac.ebi.fg.utils.objects.PubMedId;

import java.io.File;
import java.io.FileInputStream;
import java.io.ObjectInputStream;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Retrieves PubMed ids from file and separates ids that are missing
 */
public class PubMedLoadFromFileJob extends ApplicationJob
{
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public PubMedLoadFromFileJob()
    {
    }

    public void doExecute( JobExecutionContext jobExecutionContext ) throws Exception
    {
        JobDataMap dataMap = jobExecutionContext.getMergedJobDataMap();
        Map<String, SortedSet<PubMedId>> pubMedIdRelationMap = (Map<String, SortedSet<PubMedId>>) dataMap.get("pubMedIdRelationMap");
        Map<String, String> expToPubMedIdMap = (ConcurrentHashMap<String, String>) dataMap.get("expToPubMedIdMap");
        Set<String> pubMedNewIds = (Set<String>) dataMap.get("pubMedNewIds");
        Configuration properties = (Configuration) dataMap.get("properties");

        String fileLocation = properties.getString("persistence-location-pubMed");
        File pubMedFile = new File(fileLocation);

        if (pubMedFile.exists()) {
            FileInputStream fis = new FileInputStream(pubMedFile);
            ObjectInputStream ois = new ObjectInputStream(fis);

            logger.info("Reading object from file " + pubMedFile.getName());
            pubMedIdRelationMap.putAll((ConcurrentHashMap<String, SortedSet<PubMedId>>) ois.readObject());
            logger.info(pubMedFile.getName() + " retrieved from file");
            ois.close();

            // get missing ids
            pubMedNewIds.addAll(getMissingData(pubMedIdRelationMap, new TreeSet<String>(expToPubMedIdMap.values())));
        } else {
            logger.info(pubMedFile.getName() + " file not found");

            // get all ids
            pubMedNewIds.addAll(new TreeSet<String>(expToPubMedIdMap.values()));
        }
    }

    /**
     * Returns PubMed ids that need to be downloaded
     *
     * @param pubMedIdRelationMap currently available PubMed ids with similar ids
     * @param allIds              all experiment PubMed ids
     * @return PubMed ids that do not have similar ids
     */
    private Set<String> getMissingData( Map<String, SortedSet<PubMedId>> pubMedIdRelationMap, Set<String> allIds )
    {
        if (!pubMedIdRelationMap.keySet().equals(allIds)) {
            allIds.removeAll(pubMedIdRelationMap.keySet());
        } else {
            logger.info("No new PubMed IDs found");
            allIds.clear();
        }

        return allIds;
    }
}
