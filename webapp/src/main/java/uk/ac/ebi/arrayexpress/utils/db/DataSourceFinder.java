package uk.ac.ebi.arrayexpress.utils.db;

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

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NameNotFoundException;
import javax.sql.DataSource;
import java.sql.Connection;

public class DataSourceFinder
{
    // logging facility
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public DataSource findDataSource( String dsNames )
    {
        DataSource result = null;
        if (null != dsNames) {
            String[] dsList = dsNames.trim().split("\\s*,\\s*");
            for ( String dsName : dsList ) {
                logger.info("Checking data source [{}]", dsName);
                result = getDataSource(dsName);
                if (isDataSourceAvailable(result)) {
                    logger.info("Will use available data source [{}]", dsName);
                    break;
                } else {
                    logger.warn("Data source [{}] is unavailable", dsName);
                    result = null;
                }
            }
        }
        return result;
    }

    private DataSource getDataSource( String dsName )
    {
        DataSource ds = null;
        logger.info("Looking up data source [{}]", dsName);
        try {
            Context initContext = new InitialContext();
            Context envContext = (Context) initContext.lookup("java:/comp/env");

            ds = (DataSource) envContext.lookup("jdbc/" + dsName.toLowerCase());
        } catch ( NameNotFoundException x ) {
            logger.error("Data source [{}] is not regsitered with application, check your context.xml", dsName);
        } catch ( Exception x ) {
            logger.error("Caught an exception:", x);
        }

        return ds;
    }

    private boolean isDataSourceAvailable( DataSource ds )
    {
        boolean result = false;
        Connection conn = null;
        if (null != ds) {
            try {
                conn = ds.getConnection();
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
