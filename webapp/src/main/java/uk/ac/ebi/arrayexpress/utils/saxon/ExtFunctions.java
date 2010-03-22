package uk.ac.ebi.arrayexpress.utils.saxon;

/*
 * Copyright 2009-2010 Microarray Informatics Group, European Bioinformatics Institute
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
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.components.Experiments;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class ExtFunctions
{
    // logging machinery
    private static final Logger logger = LoggerFactory.getLogger(ExtFunctions.class);

    public static String formatFileSize( long size )
    {
        StringBuilder str = new StringBuilder();
        if (922L > size) {
            str.append(size).append(" B");
        } else if (944128L > size) {
            str.append(String.format("%.0f KB", (Long.valueOf(size).doubleValue() / 1024.0)));
        } else if (1073741824L > size) {
            str.append(String.format("%.1f MB", (Long.valueOf(size).doubleValue() / 1048576.0)));
        } else if (1099511627776L > size) {
            str.append(String.format("%.2f GB", (Long.valueOf(size).doubleValue() / 1073741824.0)));
        }
        return str.toString();
    }


    public static String trimTrailingDot( String str )
    {
        if (str.endsWith(".")) {
            return str.substring(0, str.length() - 1);
        } else
            return str;
    }

    public static String dateToRfc822()
    {
        return new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z").format(new Date());
    }

    public static String dateToRfc822( String dateString )
    {
        if (null != dateString && 0 < dateString.length()) {
            try {
                Date date = new SimpleDateFormat("yyyy-MM-dd").parse(dateString);
                dateString = new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z").format(date);
            } catch (Exception x) {
                logger.debug("Caught an exception:", x);
            }
        } else {
            dateString = "";
        }

        return dateString;
    }

    public static boolean isExperimentInAtlas( String accession )
    {
        return ((Experiments)Application.getAppComponent("Experiments"))
                .isInAtlas(accession);
    }

    // todo: this is experimental feature, that should get moved somewhere

    private static Map<String, Map<String, String>> acceleratorMapRegistry = null;

    public synchronized static void clearAccelerator( String acceleratorName )
    {
        if (null != acceleratorMapRegistry && acceleratorMapRegistry.containsKey(acceleratorName)) {
            acceleratorMapRegistry.get(acceleratorName).clear();
        }
    }

    public synchronized static void addAcceleratorValue( String acceleratorName, String key, String value )
    {
        if (null == acceleratorMapRegistry) {
            acceleratorMapRegistry = new HashMap<String, Map<String, String>>();
        }

        if (!acceleratorMapRegistry.containsKey(acceleratorName)) {
            acceleratorMapRegistry.put(acceleratorName, new HashMap<String, String>());
        }

        Map<String, String> acceleratorMap = acceleratorMapRegistry.get(acceleratorName);
        if (acceleratorMap.containsKey(key)) {
            logger.warn("Accelerator [{}] already contains value for key [{}], overriding", acceleratorName, key);
        }

        acceleratorMap.put(key, value);
    }

    public synchronized static String getAcceleratorValue( String acceleratorName, String key )
    {
        if (null != acceleratorMapRegistry && acceleratorMapRegistry.containsKey(acceleratorName)) {
            return acceleratorMapRegistry.get(acceleratorName).get(key);
        } else {
            return null;
        }
    }
}
