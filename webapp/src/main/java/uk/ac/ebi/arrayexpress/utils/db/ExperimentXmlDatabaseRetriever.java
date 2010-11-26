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

import java.io.IOException;
import java.sql.Clob;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class ExperimentXmlDatabaseRetriever extends SqlStatementExecutor
{
    // logging facility
    private final Logger logger = LoggerFactory.getLogger(getClass());
    // sql code
    private final static String getExperimentXmlSql = "select" +
            " XmlElement( \"experiment\"" +
            " , XmlElement( \"id\", e.id )" +
            " , ( select XmlAgg( XmlElement( \"accession\", identifier ) ) from tt_identifiable i where i.id = e.id )" +
            " , ( select XmlAgg( XmlElement( \"name\", value ) ) from tt_namevaluetype sa where sa.t_extendable_id = e.id and sa.name = 'AEExperimentDisplayName' )" +
            " , ( select XmlAgg( XmlElement( \"loaddate\", value ) ) from tt_namevaluetype sa where sa.t_extendable_id = e.id and sa.name = 'ArrayExpressLoadDate' )" +
            " , ( select XmlAgg( XmlElement( \"releasedate\", value ) ) from tt_namevaluetype sa where sa.t_extendable_id = e.id and sa.name = 'ArrayExpressReleaseDate' )" +
            " , ( select XmlAgg( XmlElement( \"user\", XmlAttributes( v.user_id as \"id\" ) ) ) from tt_extendable ext left outer join pl_visibility v on v.label_id = ext.label_id where ext.id = e.id )" +
            " , ( select XmlAgg( XmlElement( \"secondaryaccession\", value ) ) from tt_namevaluetype sa where sa.t_extendable_id = e.id and sa.name = 'SecondaryAccession' )" +
            " , ( select XmlAgg( XmlElement( \"seqdatauri\", value ) ) from tt_namevaluetype sa where sa.t_extendable_id = e.id and sa.name = 'SequenceDataURI' )" +
            " , ( select XmlAgg( XmlElement( \"miamegold\", value ) ) from tt_namevaluetype sa where sa.t_extendable_id = e.id and sa.name = 'AEMIAMEGOLD' )" +
            " , ( select XmlAgg( XmlElement( \"sampleattribute\", XmlAttributes( i4samattr.category as \"category\", i4samattr.value as \"value\") ) ) from ( select  /*+ LEADING(b) INDEX(o) INDEX(c) INDEX(b)*/ distinct b.experiments_id as id, o.category as category, ( case when (o.category = o.value and o.readablevalue is not null ) then o.readablevalue else nvl(o.value, ' ') end ) as value from tt_ontologyentry o, tt_characteris_t_biomateri c, tt_biomaterials_experiments b where b.biomaterials_id = c.t_biomaterial_id and c.characteristics_id = o.id ) i4samattr where i4samattr.id = e.id group by i4samattr.id )" +
            " , ( select XmlAgg( XmlElement( \"experimentalfactor\", XmlAttributes( i4efvs.name as \"name\", i4efvs.value as \"value\") ) ) from (select /*+ leading(d) index(d) index(doe) index(tl) index(f) index(fi) index(fv) index(voe) index(m) */ distinct d.t_experiment_id as id, ( case when voe.category is not null then voe.category else fi.name end ) as name, nvl( case when voe.value is not null then voe.value else m.value end, ' ' ) as value from tt_experimentdesign d, tt_ontologyentry doe, tt_types_t_experimentdesign tl, tt_experimentalfactor f, tt_identifiable fi, tt_factorvalue fv, tt_ontologyentry voe, tt_measurement m where doe.id = tl.types_id and tl.t_experimentdesign_id = d.id and f.t_experimentdesign_id (+) = d.id and fv.experimentalfactor_id (+) = f.id and voe.id (+) = fv.value_id and fi.id (+) = f.id and m.id (+) = fv.measurement_id) i4efvs where i4efvs.id = e.id group by i4efvs.id )" +
            " , ( select XmlAgg( XmlElement( \"miamescore\", XmlAttributes( nvt_miamescores.name as \"name\", nvt_miamescores.value as \"value\" ) ) ) from tt_namevaluetype nvt_miamescores, tt_namevaluetype nvt_miame where nvt_miame.id = nvt_miamescores.t_namevaluetype_id and nvt_miame.t_extendable_id = e.id and nvt_miame.name = 'AEMIAMESCORE' group by nvt_miame.value )" +
            " , ( select /*+ index(pba) */ XmlAgg( XmlElement( \"arraydesign\", XmlAttributes( a.arraydesign_id as \"id\", i4array.identifier as \"accession\", nvt_array.value as \"name\" , count(a.arraydesign_id) as \"count\" ) ) ) from tt_bioassays_t_experiment ea inner join tt_physicalbioassay pba on pba.id = ea.bioassays_id inner join tt_bioassaycreation h on h.id = pba.bioassaycreation_id inner join tt_array a on a.id = h.array_id inner join tt_identifiable i4array on i4array.id = a.arraydesign_id inner join tt_namevaluetype nvt_array on nvt_array.t_extendable_id = a.arraydesign_id and nvt_array.name = 'AEArrayDisplayName' where ea.t_experiment_id = e.id group by a.arraydesign_id, i4array.identifier, nvt_array.value )" +
            " , ( select /*+ leading(i7) index(bad)*/ XmlAgg( XmlElement( \"bioassaydatagroup\", XmlAttributes( badg.id as \"id\", i8.identifier as \"name\", count(badg.id) as \"bioassaydatacubes\", ( select substr( i10.identifier, 3, 4 ) from tt_arraydesign_bioassaydat abad, tt_identifiable i10 where abad.bioassaydatagroups_id = badg.id and i10.id = abad.arraydesigns_id and rownum = 1 ) as \"arraydesignprovider\", ( select d.dataformat from tt_bioassays_t_bioassayd b, tt_bioassaydata c, tt_biodatacube d, tt_bioassaydat_bioassaydat badbad where b.t_bioassaydimension_id = c.bioassaydimension_id and c.biodatavalues_id = d.id and badbad.bioassaydatas_id = c.id and badbad.bioassaydatagroups_id = badg.id and rownum = 1) as \"dataformat\", ( select count(bbb.bioassays_id) from tt_bioassays_bioassaydat bbb where bbb.bioassaydatagroups_id = badg.id ) as \"bioassays\", ( select count(badg.id) from tt_derivedbioassaydata dbad, tt_bioassaydat_bioassaydat bb where bb.bioassaydatagroups_id = badg.id and dbad.id = bb.bioassaydatas_id and rownum = 1 ) as \"isderived\" ) ) ) from  tt_bioassaydatagroup badg, tt_bioassaydat_bioassaydat bb, tt_bioassaydata bad, tt_identifiable i8 where badg.experiment_id = e.id and bb.bioassaydatagroups_id = badg.id and bad.id = bb.bioassaydatas_id and i8.id = bad.designelementdimension_id group by i8.identifier, badg.id )" +
            " , ( select XmlAgg( XmlElement( \"bibliography\", XmlAttributes( trim(db.accession) as \"accession\", trim(b.publication) AS \"publication\", trim(b.authors) AS \"authors\", trim(b.title) as \"title\", trim(b.year) as \"year\", trim(b.volume) as \"volume\", trim(b.issue) as \"issue\", trim(b.pages) as \"pages\", trim(b.uri) as \"uri\" ) ) ) from tt_bibliographicreference b, tt_description dd, tt_accessions_t_bibliogra ab, tt_databaseentry db where b.t_description_id = dd.id and dd.t_describable_id = e.id and ab.t_bibliographicreference_id(+) = b.id and db.id (+)= ab.accessions_id )" +
            " , ( select XmlAgg( XmlElement( \"provider\", XmlAttributes( pp.firstname || ' ' || pp.lastname AS \"contact\", c.email AS \"email\", value AS \"role\" ) ) ) from tt_identifiable ii, tt_ontologyentry o, tt_providers_t_experiment p, tt_roles_t_contact r, tt_person pp, tt_contact c where c.id = r.t_contact_id and ii.id = r.t_contact_id and r.roles_id = o.id and pp.id = ii.id and ii.id = p.providers_id and p.t_experiment_id = e.id )" +
            " , ( select XmlAgg( XmlElement( \"experimentdesign\", expdesign ) ) from ( select  /*+ index(ed) */ distinct ed.t_experiment_id as id, translate(replace(oe.value,'_design',''),'_',' ') as expdesign from tt_experimentdesign ed, tt_types_t_experimentdesign tte, tt_ontologyentry oe where tte.t_experimentdesign_id = ed.id and oe.id = tte.types_id and oe.category = 'ExperimentDesignType' ) t where t.id = e.id )" +
            " , ( select XmlAgg( XmlElement( \"experimenttype\", exptype ) ) from ( select distinct don.t_describable_id as id, oe.value as exptype from tt_ontologyentry oe, tt_annotations_t_descriptio ano, tt_description don where don.id =+ ano.t_description_id and ano.annotations_id =+ oe.id and oe.category = 'AEExperimentType' ) t where t.id = e.id )" +
            " , ( select XmlAgg( XmlElement( \"description\", XmlAttributes( id as \"id\" ), text ) ) from tt_description d where d.t_describable_id = e.id )" +
            " ).getClobVal() as xml" +
            " from" +
            "  tt_experiment e" +
            " where" +
            "  e.id = ?" +
            " group by" +
            "  e.id";

    // experiment list
    private List experimentList;
    // experiment xml builder
    private StringBuilder experimentXml;
    // current experiment id (being executed)
    private Long experimentId;

    public ExperimentXmlDatabaseRetriever( IConnectionSource connSource, List expList )
    {
        super(connSource, getExperimentXmlSql);
        experimentList = expList;
        experimentXml = new StringBuilder(4000 * expList.size());
    }

    public String getExperimentXml() throws InterruptedException
    {
        logger.debug("Retrieving experiment data for [{}] experiments", experimentList.size());
        try {
            for (Object exp : experimentList) {
                experimentId = (Long) exp;
                if (!execute(true)) {
                    experimentXml = new StringBuilder();
                    break;
                }
                Thread.sleep(1);
            }
            logger.debug("Retrieval completed");
        } catch (InterruptedException x) {
            logger.debug("Retrieval aborted");
        } finally {
            try {
                closeConnection();
            } catch (SQLException x) {
                logger.error("Caught an exception:", x);
            }
        }
        return experimentXml.toString();
    }

    protected void setParameters( PreparedStatement stmt ) throws SQLException
    {
        stmt.setLong(1, experimentId);
    }

    protected void processResultSet( ResultSet resultSet ) throws IOException, SQLException
    {
        if (resultSet.next()) {
            Clob xmlClob = resultSet.getClob(1);
            if (null != xmlClob) {
                experimentXml.append(ClobToString(xmlClob));
            }
        }
    }
}
