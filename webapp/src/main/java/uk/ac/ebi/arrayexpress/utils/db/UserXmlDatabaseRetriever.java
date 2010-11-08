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

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserXmlDatabaseRetriever extends SqlStatementExecutor
{
    // logging facility
    private final Logger logger = LoggerFactory.getLogger(getClass());
    // sql to get a list of experiments from the database
    // (the parameter is either 0 for all experiments and 1 for public only)
    private final static String getUserListSql = "select distinct id, name, password, email, priviledge" +
            " from" +
            "  pl_user" +
            " order by" +
            "  id asc";

    private String userXML;

    public UserXmlDatabaseRetriever( IConnectionSource connSource )
    {
        super(connSource, getUserListSql);
    }

    public String getUserXML()
    {
        if (!execute(false)) {
            logger.error("There was a problem retrieving the list of experiments, check log for errors or exceptions");
        }
        return userXML;
    }

    protected void setParameters( PreparedStatement stmt ) throws SQLException
    {
        // nothing to do here
    }

    protected void processResultSet( ResultSet resultSet ) throws SQLException
    {
        StringBuilder sb = new StringBuilder(4000000);
        sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
                .append("<users>")
                ;

        while ( resultSet.next() ) {
            sb.append("<user><id>")
                    .append(resultSet.getLong(1))
                    .append("</id><name>")
                    .append(resultSet.getString(2))
                    .append("</name><password>")
                    .append(resultSet.getString(3))
                    .append("</password><email>")
                    .append(resultSet.getString(4))
                    .append("</email><is_privileged>")
                    .append(resultSet.getBoolean(5))
                    .append("</is_privileged></user>");
        }
        sb.append("</users>");
        userXML = sb.toString();
    }
}

