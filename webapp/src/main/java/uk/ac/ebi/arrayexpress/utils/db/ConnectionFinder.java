package uk.ac.ebi.arrayexpress.utils.db;

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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.components.DbConnectionPool;

import java.sql.Connection;

public class ConnectionFinder
{
    // logging facility
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public String findAvailableConnection( String connNames )
    {
        if (null != connNames) {
            String[] dsList = connNames.trim().split("\\s*,\\s*");
            for ( String connName : dsList ) {
                logger.info("Checking connection [{}]", connName);
                if (isConnectionAvailable(connName)) {
                    logger.info("Will use available connection [{}]", connName);
                    return connName;
                } else {
                    logger.warn("Connection [{}] is unavailable", connName);
                }
            }
        }
        return null;
    }

    private boolean isConnectionAvailable( String connName )
    {
        boolean result = false;
        Connection conn = null;
        if (null != connName) {
            try {
                conn = ((DbConnectionPool)Application.getInstance().getComponent("DbConnectionPool")).getConnection(connName);
                conn.close();
                conn = null;
                result = true;
            } catch ( Exception x ) {
                logger.debug("Caught an exception [{}]", x.getMessage());
            } finally {
                if (null != conn) {
                    try {
                        conn.close();
                    } catch ( Exception x ) {
                        logger.error("Caught an exception:", x);
                    }
                }
            }
        }
        return result;
    }
}
