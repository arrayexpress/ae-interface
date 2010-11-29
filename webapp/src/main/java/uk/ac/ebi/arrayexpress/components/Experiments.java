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

    private final RegexHelper ARRAY_ACCESSION_REGEX = new RegexHelper("^[aA]-\\w{4}-\\d+$", "");

    private TextFilePersistence<PersistableDocumentContainer> document;
    private TextFilePersistence<PersistableStringList> experimentsInAtlas;
    private TextFilePersistence<PersistableString> species;
    private TextFilePersistence<PersistableString> arrays;
    private Map<String, String> assaysByMolecule;
    private Map<String, String> assaysByInstrument;

    private SaxonEngine saxon;
    private SearchEngine search;
    private Events events;
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

        public String toString()
        {
            switch (this) {
                case AE1:   return "AE1";
                case AE2:   return "AE2";
            }
            return null;

        }
    }

    public Experiments()
    {
    }

    public void initialize() throws Exception
    {
        this.saxon = (SaxonEngine) getComponent("SaxonEngine");
        this.search = (SearchEngine) getComponent("SearchEngine");
        this.events = (Events) getComponent("Events");
        this.autocompletion = (Autocompletion) getComponent("Autocompletion");

        this.document = new TextFilePersistence<PersistableDocumentContainer>(
                new PersistableDocumentContainer("experiments")
                , new File(getPreferences().getString("ae.experiments.persistence-location"))
        );

        this.experimentsInAtlas = new TextFilePersistence<PersistableStringList>(
                new PersistableStringList()
                , new File(getPreferences().getString("ae.atlasexperiments.persistence-location"))
        );

        this.species = new TextFilePersistence<PersistableString>(
                new PersistableString()
                , new File(getPreferences().getString("ae.species.dropdown-html-location"))

        );

        this.arrays = new TextFilePersistence<PersistableString>(
                new PersistableString()
                , new File(getPreferences().getString("ae.arrays.dropdown-html-location"))
        );

        this.assaysByMolecule = new HashMap<String, String>();
        this.assaysByMolecule.put("", "<option value=\"\">All assays by molecule</option><option value=\"DNA assay\">DNA assay</option><option value=\"metabolomic profiling\">Metabolite assay</option><option value=\"protein assay\">Protein assay</option><option value=\"RNA assay\">RNA assay</option>");
        this.assaysByMolecule.put("array assay", "<option value=\"\">All assays by molecule</option><option value=\"DNA assay\">DNA assay</option><option value=\"RNA assay\">RNA assay</option>");
        this.assaysByMolecule.put("high throughput sequencing assay", "<option value=\"\">All assays by molecule</option><option value=\"DNA assay\">DNA assay</option><option value=\"RNA assay\">RNA assay</option>");
        this.assaysByMolecule.put("proteomic profiling by mass spectrometer", "<option value=\"protein assay\">Protein assay</option>");

        this.assaysByInstrument = new HashMap<String, String>();
        this.assaysByInstrument.put("", "<option value=\"\">All technologies</option><option value=\"array assay\">Array</option><option value=\"high throughput sequencing assay\">High-throughput sequencing</option><option value=\"proteomic profiling by mass spectrometer\">Mass spectrometer</option>");
        this.assaysByInstrument.put("DNA assay", "<option value=\"\">All technologies</option><option value=\"array assay\">Array</option><option value=\"high throughput sequencing assay\">High-throughput sequencing</option>");
        this.assaysByInstrument.put("metabolomic profiling", "<option value=\"\">All technologies</option>");
        this.assaysByInstrument.put("protein assay", "<option value=\"\">All technologies</option><option value=\"proteomic profiling by mass spectrometer\">Mass spectrometer</option>");
        this.assaysByInstrument.put("RNA assay", "<option value=\"\">All technologies</option><option value=\"array assay\">Array</option><option value=\"high throughput sequencing assay\">High-throughput sequencing</option>");

        updateIndex();
        updateAccelerators();
        this.saxon.registerDocumentSource(this);
    }

    public void terminate() throws Exception
    {
    }

    // implementation of IDocumentSource.getDocumentURI()
    public String getDocumentURI()
    {
        return "experiments.xml";
    }

    // implementation of IDocumentSource.getDocument()
    public synchronized DocumentInfo getDocument() throws Exception
    {
        return this.document.getObject().getDocument();
    }

    // implementation of IDocumentSource.setDocument(DocumentInfo)
    public synchronized void setDocument( DocumentInfo doc ) throws Exception
    {
        if (null != doc) {
            this.document.setObject(new PersistableDocumentContainer("experiments", doc));
            buildSpeciesArrays();
            updateIndex();
        } else {
            this.logger.error("Experiments NOT updated, NULL document passed");
        }
    }

    public boolean isAccessible( String accession, String userId ) throws Exception
    {
        return ( "0".equals(userId)                         // superuser
                || ARRAY_ACCESSION_REGEX.test(accession)    // array accession: wtf is this here?!
                || Boolean.parseBoolean(                    // tests document for access
                    saxon.evaluateXPathSingle(              //
                            getDocument()                   //
                            , "exists(//experiment[accession = '" + accession + "' and user = '" + userId + "'])"
                    )
                )
        );
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

    public void update( String xmlString, ExperimentSource source, String sourceDescription ) throws Exception
    {
        boolean success = false;
        try {
            DocumentInfo updateDoc = this.saxon.transform(xmlString, source.getStylesheetName(), null);
            if (null != updateDoc) {
                new DocumentUpdater(this, updateDoc).update();
                success = true;
            }
        } finally {
            events.addEvent(
                    "experiments-update"
                    , source.toString() + " experiments updated from "
                            + ("".equals(sourceDescription) ? "(null)" : sourceDescription)
                    , success
            );
        }
    }

    public void reloadExperimentsInAtlas( String sourceLocation ) throws Exception
    {
        URL source = new URL(sourceLocation);
        String result = this.saxon.transformToString(source, "preprocess-atlas-experiments-txt.xsl", null);
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

    private void updateIndex()
    {
        try {
            this.search.getController().index(INDEX_ID, this.getDocument());
            this.autocompletion.rebuild();
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

    private void buildSpeciesArrays() throws Exception
    {
        // todo: move this to a separate component (autocompletion?)
        String speciesString = saxon.transformToString(this.getDocument(), "build-species-list-html.xsl", null);
        this.species.setObject(new PersistableString(speciesString));

        String arraysString = saxon.transformToString(this.getDocument(), "build-arrays-list-html.xsl", null);
        this.arrays.setObject(new PersistableString(arraysString));
    }
}
