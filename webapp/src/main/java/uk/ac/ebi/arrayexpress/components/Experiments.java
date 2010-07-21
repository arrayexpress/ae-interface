package uk.ac.ebi.arrayexpress.components;

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

import net.sf.saxon.om.DocumentInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.utils.DocumentTypes;
import uk.ac.ebi.arrayexpress.utils.RegexHelper;
import uk.ac.ebi.arrayexpress.utils.StringTools;
import uk.ac.ebi.arrayexpress.utils.persistence.PersistableString;
import uk.ac.ebi.arrayexpress.utils.persistence.PersistableStringList;
import uk.ac.ebi.arrayexpress.utils.persistence.TextFilePersistence;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Experiments extends XMLDocumentComponent
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final RegexHelper arrayAccessionRegex = new RegexHelper("^[aA]-\\w{4}-\\d+$", "");

    private String dataSource;

    private TextFilePersistence<PersistableStringList> experimentsInAtlas;
    private TextFilePersistence<PersistableString> species;
    private TextFilePersistence<PersistableString> arrays;
    private Map<String, String> assaysByMolecule;
    private Map<String, String> assaysByInstrument;

    private SearchEngine search;
    private Autocompletion autocompletion;

    public Experiments()
    {
        super("Experiments");
    }

    public void initialize() throws Exception
    {
        super.initialize();
        search = (SearchEngine) getComponent("SearchEngine");
        autocompletion = (Autocompletion) getComponent("Autocompletion");

        // TODO
        // this.experiments = new TextFilePersistence<PersistableDocument>(
        //        new PersistableDocument()
        //        , new File(getPreferences().getString("ae.experiments.file.location"))
        //);

        this.experimentsInAtlas = new TextFilePersistence<PersistableStringList>(
                new PersistableStringList()
                , new File(getPreferences().getString("ae.atlasexperiments.file.location"))
        );

        this.species = new TextFilePersistence<PersistableString>(
                new PersistableString()
                , new File(getPreferences().getString("ae.species.file.location"))

        );

        this.arrays = new TextFilePersistence<PersistableString>(
                new PersistableString()
                , new File(getPreferences().getString("ae.arraylist.file.location"))
        );

        this.assaysByMolecule = new HashMap<String, String>();
        assaysByMolecule.put("", "<option value=\"\">All assays by molecule</option><option value=\"DNA assay\">DNA assay</option><option value=\"metabolomic profiling\">Metabolite assay</option><option value=\"protein assay\">Protein assay</option><option value=\"RNA assay\">RNA assay</option>");
        assaysByMolecule.put("array assay", "<option value=\"\">All assays by molecule</option><option value=\"DNA assay\">DNA assay</option><option value=\"RNA assay\">RNA assay</option>");
        assaysByMolecule.put("high throughput sequencing assay", "<option value=\"\">All assays by molecule</option><option value=\"DNA assay\">DNA assay</option><option value=\"RNA assay\">RNA assay</option>");
        assaysByMolecule.put("proteomic profiling by mass spectrometer", "<option value=\"protein assay\">Protein assay</option>");

        this.assaysByInstrument = new HashMap<String, String>();
        assaysByInstrument.put("", "<option value=\"\">All technologies</option><option value=\"array assay\">Array</option><option value=\"high throughput sequencing assay\">High-throughput sequencing</option><option value=\"proteomic profiling by mass spectrometer\">Mass spectrometer</option>");
        assaysByInstrument.put("DNA assay", "<option value=\"\">All technologies</option><option value=\"array assay\">Array</option><option value=\"high throughput sequencing assay\">High-throughput sequencing</option>");
        assaysByInstrument.put("metabolomic profiling", "<option value=\"\">All technologies</option>");
        assaysByInstrument.put("protein assay", "<option value=\"\">All technologies</option><option value=\"proteomic profiling by mass spectrometer\">Mass spectrometer</option>");
        assaysByInstrument.put("RNA assay", "<option value=\"\">All technologies</option><option value=\"array assay\">Array</option><option value=\"high throughput sequencing assay\">High-throughput sequencing</option>");
    }

    public void terminate() throws Exception
    {
        saxon = null;
    }

    public boolean isAccessible( String accession, String userId ) throws Exception
    {
        if ("0".equals(userId)) {
            return true;
        } else if (arrayAccessionRegex.test(accession)) {
            return true; // we allow array queries
        } else {
            return Boolean.parseBoolean(
                    saxon.evaluateXPathSingle(
                            documentContainer.getDocument(DocumentTypes.EXPERIMENTS)
                            , "exists(//experiment[accession = '" + accession + "' and user = '" + userId + "'])"
                    )
            );
        }
    }

    public boolean isInAtlas( String accession ) throws Exception
    {
        return this.experimentsInAtlas.getObject().contains(accession);
    }

    public String getSpecies() throws Exception
    {
        return this.species.getObject().get();
    }

    public String getArrays() throws Exception
    {
        return this.arrays.getObject().get();
    }

    public String getAssaysByMolecule( String key )
    {
        return this.assaysByMolecule.get(key);
    }

    public String getAssaysByInstrument( String key )
    {
        return this.assaysByInstrument.get(key);
    }

    public String getDataSource()
    {
        if (null == this.dataSource) {
            this.dataSource = StringTools.arrayToString(
                    getPreferences().getStringArray("ae.experiments.db.datasources")
                    , ","
            );
        }

        return this.dataSource;
    }

    public void setDataSource( String dataSource )
    {
        this.dataSource = dataSource;
    }

    public void reload( String xmlString ) throws Exception
    {
        DocumentInfo doc = loadXMLString(DocumentTypes.EXPERIMENTS, xmlString);
        if (null != doc) {
            buildSpeciesArraysExpTypes(doc);
        }
    }

    public void setExperimentsInAtlas( List<String> expList ) throws Exception
    {
        this.experimentsInAtlas.setObject(new PersistableStringList(expList));
    }

    private void buildSpeciesArraysExpTypes( DocumentInfo doc ) throws Exception
    {
        String speciesString = saxon.transformToString(doc, "build-species-list-html.xsl", null);
        this.species.setObject(new PersistableString(speciesString));

        String arraysString = saxon.transformToString(doc, "build-arrays-list-html.xsl", null);
        this.arrays.setObject(new PersistableString(arraysString));
    }
}
