package uk.ac.ebi.arrayexpress.utils.saxon;

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

import net.sf.saxon.om.NodeInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collection;
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

    // todo: this is experimental feature, that should get moved somewhere

    private static Map<String, Map<String, Object>> acceleratorMapRegistry = null;

    public synchronized static void clearAccelerator( String acceleratorName )
    {
        if (null != acceleratorMapRegistry && acceleratorMapRegistry.containsKey(acceleratorName.toLowerCase())) {
            acceleratorMapRegistry.get(acceleratorName).clear();
        }
    }

    public synchronized static void addAcceleratorValue( String acceleratorName, String key, Object value )
    {
        if (null == acceleratorMapRegistry) {
            acceleratorMapRegistry = new HashMap<String, Map<String, Object>>();
        }

        if (!acceleratorMapRegistry.containsKey(acceleratorName.toLowerCase())) {
            acceleratorMapRegistry.put(acceleratorName.toLowerCase(), new HashMap<String, Object>());
        }

        Map<String, Object> acceleratorMap = acceleratorMapRegistry.get(acceleratorName.toLowerCase());
        if (acceleratorMap.containsKey(key.toLowerCase())) {
            logger.warn("Accelerator [{}] already contains value for key [{}], overriding", acceleratorName, key);
        }

        acceleratorMap.put(key.toLowerCase(), value);
    }

    public synchronized static Object getAcceleratorValue( String acceleratorName, String key )
    {
        if (null != acceleratorMapRegistry
                && acceleratorMapRegistry.containsKey(acceleratorName.toLowerCase())) {
            return acceleratorMapRegistry.get(acceleratorName.toLowerCase()).get(key.toLowerCase());
        } else {
            return null;
        }
    }

    public synchronized static String getAcceleratorValueAsString( String acceleratorName, String key )
    {
        if (null != acceleratorMapRegistry
                && acceleratorMapRegistry.containsKey(acceleratorName.toLowerCase())) {
            Object value = acceleratorMapRegistry.get(acceleratorName.toLowerCase()).get(key.toLowerCase());
            return value instanceof String ? (String)value : null;
        } else {
            return null;
        }
    }

    public synchronized static Collection getAcceleratorValueAsCollection( String acceleratorName, String key )
    {
        if (null != acceleratorMapRegistry
                && acceleratorMapRegistry.containsKey(acceleratorName.toLowerCase())) {
            Object value = acceleratorMapRegistry.get(acceleratorName.toLowerCase()).get(key.toLowerCase());
            return value instanceof Collection ? (Collection)value : null;
        } else {
            return null;
        }
    }

    public synchronized static NodeInfo getAcceleratorValueAsSequence( String acceleratorName, String key )
    {
        if (null != acceleratorMapRegistry
                && acceleratorMapRegistry.containsKey(acceleratorName.toLowerCase())) {
            Object value = acceleratorMapRegistry.get(acceleratorName.toLowerCase()).get(key.toLowerCase());
            return value instanceof NodeInfo ? (NodeInfo)value : null;
        } else {
            return null;
        }
    }

}
