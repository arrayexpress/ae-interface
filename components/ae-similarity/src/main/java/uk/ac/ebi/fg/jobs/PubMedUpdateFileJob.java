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
import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.fg.utils.ApplicationJob;
import uk.ac.ebi.fg.utils.objects.PubMedId;

import java.io.File;
import java.io.FileOutputStream;
import java.io.ObjectOutputStream;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;

/**
 * Updates PubMed serialized object file
 */
public class PubMedUpdateFileJob extends ApplicationJob
{
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public PubMedUpdateFileJob()
    {
    }

    public void doExecute( JobExecutionContext jobExecutionContext ) throws Exception
    {
        JobDataMap dataMap = jobExecutionContext.getMergedJobDataMap();
        Map<String, SortedSet<PubMedId>> pubMedIdRelationMap = (Map<String, SortedSet<PubMedId>>) dataMap.get("pubMedIdRelationMap");
        Set<String> pubMedNewIds = (Set<String>) dataMap.get("pubMedNewIds");
        Configuration properties = (Configuration) dataMap.get("properties");

        String fileLocation = properties.getString("persistence-location-pubMed");
        File pubMedFile = new File(fileLocation);

        if (!pubMedNewIds.isEmpty()) {
            FileOutputStream fos = new FileOutputStream(pubMedFile);
            ObjectOutputStream oos = new ObjectOutputStream(fos);

            if (!pubMedIdRelationMap.isEmpty() && pubMedIdRelationMap != null) {
                logger.info("Writing updated pubMedIdRelationMap to file");
                oos.writeObject(pubMedIdRelationMap);
                logger.info("File " + pubMedFile.getName() + " created");
            }

            oos.close();
            pubMedNewIds.clear();
        }
    }
}
