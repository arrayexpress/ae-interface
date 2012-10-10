package uk.ac.ebi.arrayexpress.utils.saxon.functions;

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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

public class ExtFunctions
{
    // logging machinery
    private static final Logger logger = LoggerFactory.getLogger(ExtFunctions.class);

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
}
