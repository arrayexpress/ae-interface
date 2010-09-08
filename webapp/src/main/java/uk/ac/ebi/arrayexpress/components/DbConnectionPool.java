package uk.ac.ebi.arrayexpress.components;

import com.jolbox.bonecp.BoneCP;
import com.jolbox.bonecp.BoneCPConfig;
import org.apache.commons.configuration.HierarchicalConfiguration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;

import java.sql.Connection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/*
 * Copyright 2009-2010 European Molecular Biology Laboratory
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

public class DbConnectionPool extends ApplicationComponent
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private Map<String, BoneCPConfig> connPoolConfigs = new HashMap<String, BoneCPConfig>();
    private Map<String, BoneCP> connPools = new HashMap<String, BoneCP>();

    public void initialize() throws Exception
    {
        HierarchicalConfiguration connsConf = (HierarchicalConfiguration)getPreferences().getConfSubset("ae.db.connections");
        if (null != connsConf) {
            List conns = connsConf.configurationsAt("connection");
            for (Object conn : conns) {
                HierarchicalConfiguration connConf = (HierarchicalConfiguration)conn;
                String connName = connConf.getString("name");
                logger.debug("Configuring pool for connection [{}]", connName);
                try {
                    Class.forName(connConf.getString("driver"));
                } catch (ClassNotFoundException x) {
                    logger.error("Unable to load driver [{}] for connection [{}]", connConf.getString("driver"), connName);
                }

                BoneCPConfig cpConf = new BoneCPConfig();
                cpConf.setJdbcUrl(connConf.getString("url"));
                cpConf.setUsername(connConf.getString("username"));
                cpConf.setPassword(connConf.getString("password"));

                this.connPoolConfigs.put(connName, cpConf);
            }
        }
    }

    public void terminate() throws Exception
    {
        for (BoneCP pool : connPools.values()) {
            pool.shutdown();
        }
    }

    public Connection getConnection( String poolName ) throws Exception
    {
        if (!connPoolConfigs.containsKey(poolName)) {
            logger.error("Connection [{}] is not defined, returning null");
            return null;
        }

        if (!connPools.containsKey(poolName)) {
            BoneCP connectionPool = new BoneCP(connPoolConfigs.get(poolName));
            connPools.put(poolName, connectionPool);
        }

        BoneCP pool = connPools.get(poolName);
        return pool.getConnection();
    }
}