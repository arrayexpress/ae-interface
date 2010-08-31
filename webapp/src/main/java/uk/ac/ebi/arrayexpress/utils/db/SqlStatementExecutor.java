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

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public abstract class SqlStatementExecutor
{
    // logging facility
    private final Logger logger = LoggerFactory.getLogger(getClass());

    // statement
    private PreparedStatement statement;

    public SqlStatementExecutor( DataSource ds, String sql )
    {
        if (null != sql && null != ds) {
            statement = prepareStatement(ds, sql);
        }
    }

    protected boolean execute( boolean shouldRetainConnection )
    {
        boolean result = false;
        if (null != statement) {
            ResultSet rs = null;
            try {
                setParameters(statement);
                rs = statement.executeQuery();
                processResultSet(rs);
                result = true;
            } catch ( Exception x ) {
                logger.error("Caught an exception:", x);
            } finally {
                if (null != rs) {
                    try {
                        rs.close();
                    } catch ( SQLException x ) {
                        logger.error("Caught an exception:", x);
                    }
                }

                if (!shouldRetainConnection) {
                    closeConnection();
                }
            }
        } else {
            logger.error("Statement is null, please check the log for possible exceptions");
        }
        return result;
    }

    // overridable method that would allow user to set additional parameters (if any)
    protected abstract void setParameters( PreparedStatement stmt ) throws SQLException;

    // overridable method that would allow user to parse the result set upon successful execution
    protected abstract void processResultSet( ResultSet resultSet ) throws SQLException;

    private PreparedStatement prepareStatement( DataSource ds, String sql )
    {
        PreparedStatement stmt = null;
        if (null != ds) {
            try {
                Connection conn = ds.getConnection();
                stmt = conn.prepareStatement(sql);
            } catch ( SQLException x ) {
                logger.error("Caught an exception:", x);
            }
        }

        return stmt;
    }

    protected void closeConnection()
    {
        if (null != statement) {
            try {
                statement.getConnection().close();
            } catch ( SQLException x ) {
                logger.error("Caught an exception:", x);
            }
            statement = null;
        }
    }

}
