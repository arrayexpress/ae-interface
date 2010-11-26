package uk.ac.ebi.arrayexpress.utils.db;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.sql.Clob;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

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

public class ArrayXmlDatabaseRetriever extends SqlStatementExecutor
{
    // logging facility
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final static String getArrayDesignSql = "select" +
            " XmlElement(\"array_design\"" +
            "  , XmlElement(\"id\", t_phad.id)" +
            "  , ( select XmlElement(\"accession\", t_ad_id.identifier) from tt_identifiable t_ad_id where t_ad_id.id = t_phad.id )" +
            "  , ( select XmlElement(\"name\", t_ad_name.value) from tt_namevaluetype t_ad_name where t_ad_name.t_extendable_id = t_phad.id and t_ad_name.name = 'AEArrayDisplayName' )" +
            "  , ( select XmlAgg(XmlElement(\"species\", t_species.value))" +
            "        from" +
            "        ( select distinct" +
            "            t_o_species.value as value" +
            "            , t_ad_species.t_arraydesign_id as t_arraydesign_id" +
            "          from" +
            "          ( select" +
            "              t_groups.t_arraydesign_id," +
            "              t_de_gr.species_id" +
            "            from" +
            "            ( select" +
            "                t_comp_gr.compositegroups_id as group_id," +
            "                t_comp_gr.t_arraydesign_id" +
            "              from" +
            "                tt_compositegr_t_arraydesi t_comp_gr" +
            "              union select" +
            "                t_rep_gr.reportergroups_id as group_id," +
            "                t_rep_gr.t_arraydesign_id" +
            "              from" +
            "                tt_reportergro_t_arraydesi t_rep_gr" +
            "              union select" +
            "                t_feat_gr.id as group_id," +
            "                t_feat_gr.t_arraydesign_id" +
            "              from" +
            "                tt_featuregroup t_feat_gr" +
            "            ) t_groups" +
            "              left outer join" +
            "                tt_designelementgroup t_de_gr" +
            "              on" +
            "                t_de_gr.id = t_groups.group_id" +
            "              where" +
            "                t_de_gr.species_id is not null" +
            "           ) t_ad_species" +
            "            left outer join" +
            "              tt_ontologyentry t_o_species" +
            "              on t_o_species.id = t_ad_species.species_id" +
            "        ) t_species" +
            "        where" +
            "          t_species.t_arraydesign_id = t_phad.id" +
            "      )" +
            "   ).getClobVal()" +
            " from" +
            "  tt_physicalarraydesign t_phad" +
            "   inner join" +
            "    tt_arraydesign t_ad" +
            "   on" +
            "    t_ad.id = t_phad.id" +
            " group by" +
            "  t_phad.id" +
            " order by" +
            "  t_phad.id asc";

    private StringBuilder arrayDesignXml;

    public ArrayXmlDatabaseRetriever( IConnectionSource connSource )
    {
        super(connSource, getArrayDesignSql);
        arrayDesignXml = new StringBuilder(40000000);
    }

    public String getXml()
    {
        if (!execute(false)) {
            logger.error("There was a problem retrieving array design information, check log for errors or exceptions");
            return null;
        }
        return arrayDesignXml.toString();
    }

    protected void setParameters( PreparedStatement stmt ) throws SQLException
    {
        // nothing to do here
    }

    protected void processResultSet( ResultSet resultSet ) throws IOException, SQLException
    {
        arrayDesignXml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?><array_designs>");
        while ( resultSet.next() ) {
            Clob xmlClob = resultSet.getClob(1);
            if (null != xmlClob) {
                arrayDesignXml.append(ClobToString(xmlClob));
            }
        }
        arrayDesignXml.append("</array_designs>");
    }
}
