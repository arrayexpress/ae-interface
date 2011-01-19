package uk.ac.ebi.arrayexpress.utils.db;

/*
 * Copyright 2009-2011 European Molecular Biology Laboratory
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

import java.io.IOException;
import java.io.InputStream;
import java.sql.*;

public abstract class SqlStatementExecutor
{
    // logging facility
    private final Logger logger = LoggerFactory.getLogger(getClass());

    // statement
    private PreparedStatement statement;

    public SqlStatementExecutor( IConnectionSource source, String sql )
    {
        if (null != sql && null != source) {
            try {
                Connection conn = source.getConnection();
                statement = prepareStatement(conn, sql);
            } catch (SQLException x) {
                logger.error("Caught an exception:", x);
            }
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
            } catch (SQLException x) {
                logger.error("Caught an exception:", x);
            } catch (IOException x) {
                logger.error("Caught an exception:", x);
            } finally {
                if (null != rs) {
                    try {
                        rs.close();
                    } catch (SQLException x) {
                        logger.error("Caught an exception:", x);
                    }
                }

                if (!shouldRetainConnection) {
                    try {
                        closeConnection();
                    } catch (SQLException x) {
                        logger.error("Caught an exception:", x);
                    }
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
    protected abstract void processResultSet( ResultSet resultSet ) throws IOException, SQLException;

    private PreparedStatement prepareStatement( Connection conn, String sql ) throws SQLException
    {
        PreparedStatement stmt = null;
        if (null != conn) {
            stmt = conn.prepareStatement(sql);
        }

        return stmt;
    }

    protected void closeConnection() throws SQLException
    {
        if (null != statement) {
            statement.getConnection().close();
            statement = null;
        }
    }

    protected String clobToString( Clob cl ) throws IOException, SQLException
    {
        if (cl == null)
            return null;

        StringBuilder sb = new StringBuilder((int) cl.length());
        InputStream in = cl.getAsciiStream();
        int ch;
        try {
            while (true) {
                ch = in.read();
                if (-1 == ch) {
                    break;
                }
                sb.append((char) ch);
            }
        } finally {
            in.close();
        }

        return sb.toString();
    }

}
