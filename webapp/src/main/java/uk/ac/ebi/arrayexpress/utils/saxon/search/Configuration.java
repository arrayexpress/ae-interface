package uk.ac.ebi.arrayexpress.utils.saxon.search;

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

import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.configuration.HierarchicalConfiguration;
import org.apache.commons.configuration.XMLConfiguration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.URL;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Configuration
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private Map<String, HierarchicalConfiguration> indicesConfig = new HashMap<String, HierarchicalConfiguration>();

    public Configuration( URL configResource )
    {
        try {
            // set list delimiter to bogus value to disable list parsing in configuration values
            XMLConfiguration.setDefaultListDelimiter('\uffff');
            XMLConfiguration xmlConfig = new XMLConfiguration(configResource);
            readConfiguration(xmlConfig);
        } catch (ConfigurationException x) {
            logger.error("There was an exception thrown:", x);
        }
    }

    public Configuration( HierarchicalConfiguration config )
    {
        readConfiguration(config);
    }

    public HierarchicalConfiguration getIndexConfig( String indexId )
    {
        if (indicesConfig.containsKey(indexId)) {
            return indicesConfig.get(indexId);
        }

        return null;
    }

    private void readConfiguration( HierarchicalConfiguration config )
    {
        List indexList = config.configurationsAt("index");

        for (Object conf : indexList) {
            HierarchicalConfiguration indexConfig = (HierarchicalConfiguration)conf;
            String indexId = indexConfig.getString("[@id]");
            this.indicesConfig.put(indexId, indexConfig);
        }
    }
}
