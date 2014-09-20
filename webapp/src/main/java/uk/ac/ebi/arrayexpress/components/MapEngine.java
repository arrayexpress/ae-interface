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

import au.com.bytecode.opencsv.CSVReader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class MapEngine extends ApplicationComponent
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private Map<String, IValueMap> mapRegistry;

    @Override
    public void initialize() throws Exception
    {
        mapRegistry = new HashMap<>();
    }

    @Override
    public void terminate() throws Exception
    {
    }

    public void registerMap( IValueMap map )
    {
        if (mapRegistry.containsKey(map.getName())) {
            logger.error("Unable to register map [{}] - already registered", map.getName());
        } else {
            mapRegistry.put(map.getName(), map);
        }
    }

    public synchronized void clearMap( String mapName )
    {
        if (mapRegistry.containsKey(mapName)) {
            mapRegistry.get(mapName).clearValues();
        } else {
            logger.error("Map [{}] is not registered", mapName);
        }
    }

    public synchronized void loadMap( String mapName, File tsvFile ) throws IOException
    {
        if (mapRegistry.containsKey(mapName)) {
            clearMap(mapName);
            CSVReader tsvReader = new CSVReader(
                    new BufferedReader(
                            new FileReader(tsvFile)
                    )
                    , '\t'
            );

            for (String[] keyValue : tsvReader.readAll()) {
                if (null != keyValue && 2 == keyValue.length) {
                    setMappedValue(mapName, keyValue[0], keyValue[1]);
                } else {
                    throw new IOException("File [" + tsvFile.getPath() + "] contains invalid entry [" + StringTools.arrayToString(keyValue, "|") + "]");
                }
            }
        } else {
            logger.error("Map [{}] is not registered", mapName);
        }
    }

    public synchronized Object getMappedValue( String mapName, String mapKey )
    {
        if (mapRegistry.containsKey(mapName)) {
            IValueMap map = mapRegistry.get(mapName);
            if (null != map && map.containsKey(mapKey)) {
                return map.getValue(mapKey);
            } else {
                //logger.debug("Map [{}] has no value for key [{}]", mapName, mapKey);
            }
        } else {
            logger.error("Accessed map [{}] which was not registered", mapName);
        }

        return null;
    }

    public synchronized void setMappedValue( String mapName, String mapKey, Object mapValue )
    {
        if (mapRegistry.containsKey(mapName)) {
            IValueMap map = mapRegistry.get(mapName);
            if (null != map) {
                if (map.containsKey(mapKey)) {
                    logger.debug("Map [{}] has already value for key [{}], will be overwritten", mapName, mapKey);
                } else {
                    map.setValue(mapKey, mapValue);
                }
            }
        } else {
            logger.error("Accessed map [{}] which was not registered", mapName);
        }
    }

    public synchronized void addMappedValue( String mapName, String mapKey, Object mapValue )
    {
        if (mapRegistry.containsKey(mapName)) {
            IValueMap map = mapRegistry.get(mapName);
            if (null != map) {
                if (map.containsKey(mapKey)) {
                    Object oldValue = map.getValue(mapKey);
                    MapList mapList = new MapList();
                    if (oldValue instanceof MapList) {
                        mapList = (MapList)oldValue;
                    } else {
                        mapList.add(oldValue);
                    }
                    mapList.add(mapValue);
                    map.setValue(mapKey, mapList);
                } else {
                    map.setValue(mapKey, mapValue);
                }
            }
        } else {
            logger.error("Accessed map [{}] which was not registered", mapName);
        }
    }

    private class MapList extends ArrayList<Object>
    {
    }

    public interface IValueMap
    {
        public String getName();

        public boolean containsKey( String key );

        public Object getValue( String key );

        public void clearValues();

        public void setValue( String key, Object value );
    }

    public static class SimpleValueMap implements IValueMap
    {
        private String name;
        private Map<String, Object> map;

        public SimpleValueMap( String name )
        {
            this(name, new HashMap<String, Object>());
        }

        public SimpleValueMap( String name, HashMap<String, Object> map )
        {
            if (null == name || null == map) {
                throw new IllegalArgumentException("Null map and/or name not allowed");
            }
            this.name = name;
            this.map = map;
        }

        @Override
        public String getName()
        {
            return name;
        }

        @Override
        public boolean containsKey( String key )
        {
            return map.containsKey(key);
        }

        @Override
        public Object getValue( String key )
        {
            return containsKey(key) ? map.get(key) : null;
        }

        @Override
        public void clearValues()
        {
            map.clear();
        }

        @Override
        public void setValue( String key, Object value )
        {
            map.put(key, value);
        }
    }

    public static class JointValueMap implements IValueMap
    {
        private String name;
        private Map<String, IValueMap> maps;

        public JointValueMap( String name )
        {
            this.name = name;
            this.maps = new HashMap<>();
        }

        @Override
        public String getName()
        {
            return name;
        }

        @Override
        public boolean containsKey( String key )
        {
            for ( IValueMap map : maps.values() ) {
                if (map.containsKey(key)) {
                    return true;
                }
            }
            return false;
        }

        @Override
        public Object getValue( String key )
        {
            for ( IValueMap map : maps.values() ) {
                if (map.containsKey(key)) {
                    return map.getValue(key);
                }
            }
            return null;
        }

        @Override
        public void clearValues()
        {
            throw new IllegalArgumentException("Method not supported");
        }

        @Override
        public void setValue( String key, Object value )
        {
            throw new IllegalArgumentException("Method not supported");
        }

        public void addMap( IValueMap map )
        {
            if (maps.containsKey(map.getName())) {
                throw new IllegalArgumentException("Map [" + map.getName() + "] already added");
            } else {
                maps.put(map.getName(), map);
            }
        }

        public IValueMap getMap( String name )
        {
            if (maps.containsKey(name)) {
                return maps.get(name);
            } else {
                throw new IllegalArgumentException("Map [" + name + "] not found");
            }
        }
    }
}
