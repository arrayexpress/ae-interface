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
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserXmlDatabaseRetriever extends SqlStatementExecutor
{
    // logging facility
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final static String getUserListSql =
            "select distinct id, name, password, email, priviledge" +
            " from" +
            "  pl_user" +
            " order by" +
            "  id asc";

    private String userXml;

    public UserXmlDatabaseRetriever( IConnectionSource connSource )
    {
        super(connSource, getUserListSql);
    }

    public String getXml()
    {
        if (!execute(false)) {
            logger.error("There was a problem retrieving user information, check log for errors or exceptions");
        }
        return userXml;
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
                    .append(StringTools.safeToString(resultSet.getLong(1), ""))
                    .append("</id><name>")
                    .append(StringTools.safeToString(resultSet.getString(2), ""))
                    .append("</name><password>")
                    .append(StringTools.safeToString(resultSet.getString(3), ""))
                    .append("</password><email>")
                    .append(StringTools.safeToString(resultSet.getString(4), ""))
                    .append("</email><is_privileged>")
                    .append(StringTools.safeToString(resultSet.getBoolean(5), "false"))
                    .append("</is_privileged></user>");
        }
        sb.append("</users>");
        userXml = sb.toString();
    }
}

