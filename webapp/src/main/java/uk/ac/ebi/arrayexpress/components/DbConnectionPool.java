package uk.ac.ebi.arrayexpress.components;

import com.jolbox.bonecp.BoneCPConfig;
import org.apache.commons.configuration.HierarchicalConfiguration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.db.ConnectionSource;
import uk.ac.ebi.arrayexpress.utils.db.IConnectionSource;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

public class DbConnectionPool extends ApplicationComponent
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private Map<String, BoneCPConfig> configs = new HashMap<String, BoneCPConfig>();

    @Override
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
                cpConf.setConnectionTestStatement(connConf.getString("testStatement"));
                cpConf.setMinConnectionsPerPartition(connConf.getInt("minConnections"));
                cpConf.setMaxConnectionsPerPartition(connConf.getInt("maxConnections"));
                cpConf.setPartitionCount(1);
                this.configs.put(connName, cpConf);
            }
        }
    }

    @Override
    public void terminate() throws Exception
    {
    }

    public IConnectionSource getConnectionSource( String connectionNames )
    {
        if (null != connectionNames) {
            String[] conns = connectionNames.trim().split("\\s*,\\s*");
            for ( String conn : conns ) {
                logger.info("Checking connection [{}]", conn);
                if (!configs.containsKey(conn)) {
                    logger.error("Connection [{}] is not configured", conn);
                } else {
                    try {
                        IConnectionSource source = new ConnectionSource(conn, configs.get(conn));
                        logger.info("Will use available connection [{}]", conn);
                        return source;
                    } catch (SQLException x) {
                        logger.warn("Connection [{}] is unavailable", conn);
                        logger.debug("Exception was:", x);
                    }
                }
            }
        }
        return null;
    }


}