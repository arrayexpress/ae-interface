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
import java.sql.Clob;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ProtocolXMLDatabaseRetriever extends SqlStatementExecutor
{
    // logging facility
    private final Logger logger = LoggerFactory.getLogger(getClass());
    // sql to get a list of experiments from the database
    // (the parameter is either 0 for all experiments and 1 for public only)
    private final static String getProtocolXMLSql = "select XmlElement(\"protocol\", XmlElement(\"id\", protocol.id), XmlElement(\"accession\", protocol_id.identifier), XmlElement(\"name\", protocol_id.name)\n" +
            ", XmlElement(\"title\", protocol.title)\n" +
            ", XmlElement(\"text\", protocol.text)\n" +
            ", XmlElement(\"type\", protocol_type.value)\n" +
            ").getClobVal() as xml\n" +
            "from\n" +
            "tt_identifiable protocol_id\n" +
            "inner join tt_protocol protocol on protocol.id = protocol_id.id\n" +
            "left outer join tt_ontologyentry protocol_type on protocol.type_id = protocol_type.id "
//            + "where \n" +
//            "rownum<100"
            ;

    private String xmlProtocolString;

    public ProtocolXMLDatabaseRetriever( DataSource ds )
    {
        super(ds, getProtocolXMLSql);
    }

    public String getProtocolXml()
    {

        boolean b = execute(false);
        if (!b) {
            logger.error("There was a problem retrieving the list of Protocols, check log for errors or exceptions");
        }
        return xmlProtocolString;
    }

    protected void setParameters( PreparedStatement stmt ) throws SQLException
    {
        // nothing to do here
    }

    protected void processResultSet( ResultSet resultSet ) throws SQLException
    {
        StringBuffer xmlBuffer = new StringBuffer(20000);
        xmlBuffer.append("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><protocols>");

        int i = 0;
        while (resultSet.next()) {
            Clob xmlClob = resultSet.getClob(1);
            String s = clobToString(xmlClob);
            xmlBuffer.append(s);

        }

        xmlBuffer.append("</protocols>");

        xmlProtocolString = xmlBuffer.toString();
        System.out.println("xmlProtocolString = " + xmlProtocolString);
    }


}