package uk.ac.ebi.arrayexpress.components;


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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.Properties;

/*
 * GenomeSpace CDK and OpenID wrapper
 */

public class GenomeSpace extends ApplicationComponent
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    // GenomeSpace URLs properties file
    private final static String GS_PROPERTIES_URL = "http://www.genomespace.org/sites/genomespacefiles/config/serverurl.properties";

    //
    private Properties gsProperties = null;

    @Override
    public void initialize() throws Exception
    {
    }

    @Override
    public void terminate() throws Exception
    {
    }

    public String getPropertyValue( String key )
    {
        if (null == gsProperties) {
            loadProperties();
        }
        return (null != gsProperties) ? gsProperties.getProperty(key) : null;
    }

    private void loadProperties()
    {
        try (InputStream is = new URL(GS_PROPERTIES_URL).openStream()) {
            gsProperties = new Properties();
            gsProperties.load(is);
        } catch (IOException x) {
            logger.error("Unable to load properties:", x);
        }
    }
}
