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
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.RegexHelper;
import uk.ac.ebi.arrayexpress.utils.persistence.PersistableDocumentContainer;
import uk.ac.ebi.arrayexpress.utils.persistence.PersistableString;
import uk.ac.ebi.arrayexpress.utils.persistence.PersistableStringList;
import uk.ac.ebi.arrayexpress.utils.persistence.TextFilePersistence;
import uk.ac.ebi.arrayexpress.utils.saxon.DocumentUpdater;
import uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions;
import uk.ac.ebi.arrayexpress.utils.saxon.IDocumentSource;

import java.io.File;
import java.net.URL;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class Experiments extends ApplicationComponent implements IDocumentSource
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final RegexHelper arrayAccessionRegex = new RegexHelper("^[aA]-\\w{4}-\\d+$", "");

    private String connName;
    private TextFilePersistence<PersistableDocumentContainer> experiments;
    private TextFilePersistence<PersistableStringList> experimentsInAtlas;
    private TextFilePersistence<PersistableString> species;
    private TextFilePersistence<PersistableString> arrays;
    private Map<String, String> assaysByMolecule;
    private Map<String, String> assaysByInstrument;

    private SaxonEngine saxon;
    private SearchEngine search;
    private Autocompletion autocompletion;

    public final String INDEX_ID = "experiments";

    public enum ExperimentSource
    {
        AE1, AE2;

        public String getStylesheetName()
        {
            switch (this) {
                case AE1:   return "preprocess-experiments-ae1-xml.xsl";
                case AE2:   return "preprocess-experiments-ae2-xml.xsl";
            }
            return null;
        }
    }

    public Experiments()
    {
    }

    public void initialize() throws Exception
    {
        saxon = (SaxonEngine) getComponent("SaxonEngine");
        search = (SearchEngine) getComponent("SearchEngine");
        autocompletion = (Autocompletion) getComponent("Autocompletion");

        this.experiments = new TextFilePersistence<PersistableDocumentContainer>(
                new PersistableDocumentContainer("experiments")
                , new File(getPreferences().getString("ae.experiments.file.location"))
        );

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
                , new File(getPreferences().getString("ae.arrays.file.location"))
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

        indexExperiments();
        updateAccelerators();
        saxon.registerDocumentSource(this);
    }

    public void terminate() throws Exception
    {
        saxon = null;
    }

    // implementation of IDocumentSource.getDocumentURI()
    public String getDocumentURI()
    {
        return "experiments.xml";
    }

    // implementation of IDocumentSource.getDocument()
    public synchronized DocumentInfo getDocument() throws Exception
    {
        return this.experiments.getObject().getDocument();
    }

    // implementation of IDocumentSource.setDocument(DocumentInfo)
    public synchronized void setDocument( DocumentInfo doc ) throws Exception
    {
        if (null != doc) {
            this.experiments.setObject(new PersistableDocumentContainer("experiments", doc));
            buildSpeciesArraysExpTypes();
            indexExperiments();
        } else {
            this.logger.error("Experiments NOT updated, NULL document passed");
        }
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
                            getDocument()
                            , "exists(//experiment[accession = '" + accession + "' and user = '" + userId + "'])"
                    )
            );
        }
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

    public void update( String xmlString, ExperimentSource source ) throws Exception
    {
        DocumentInfo updateDoc = saxon.transform(xmlString, source.getStylesheetName(), null);
        if (null != updateDoc) {
            new DocumentUpdater(this, updateDoc).update();
        }
    }

    public void reloadExperimentsInAtlas( String sourceLocation ) throws Exception
    {
        URL source = new URL(sourceLocation);
        String result = saxon.transformToString(source, "preprocess-atlas-experiments-txt.xsl", null);
        if (null != result) {
            String[] exps = result.split("\n");
            if (exps.length > 0) {
                this.experimentsInAtlas.setObject(new PersistableStringList(Arrays.asList(exps)));
                updateAccelerators();
                this.logger.info("Stored GXA info, [{}] experiments listed", exps.length);
            } else {
                this.logger.warn("Atlas returned [0] experiments listed, will NOT update our info");
            }
        }
    }

    private void indexExperiments()
    {
        try {
            search.getController().index(INDEX_ID, this.getDocument());
            autocompletion.rebuild();
        } catch (Exception x) {
            this.logger.error("Caught an exception:", x);
        }
    }

    private void updateAccelerators()
    {
        this.logger.debug("Updating accelerators for experiments");

        ExtFunctions.clearAccelerator("is-in-atlas");
        try {
            for (String accession : this.experimentsInAtlas.getObject()) {
                ExtFunctions.addAcceleratorValue("is-in-atlas", accession, "1");
            }
            this.logger.debug("Accelerators updated");
        } catch (Exception x) {
            this.logger.error("Caught an exception:", x);
        }
    }

    private void buildSpeciesArraysExpTypes() throws Exception
    {
        String speciesString = saxon.transformToString(this.getDocument(), "build-species-list-html.xsl", null);
        this.species.setObject(new PersistableString(speciesString));

        String arraysString = saxon.transformToString(this.getDocument(), "build-arrays-list-html.xsl", null);
        this.arrays.setObject(new PersistableString(arraysString));
    }
}
