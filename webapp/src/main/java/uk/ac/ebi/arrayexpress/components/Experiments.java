package uk.ac.ebi.arrayexpress.components;

/*
 * Copyright 2009-2014 European Molecular Biology Laboratory
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

import net.sf.saxon.om.Item;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.trans.XPathException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.components.Events.IEventInformation;
import uk.ac.ebi.arrayexpress.utils.StringTools;
import uk.ac.ebi.arrayexpress.utils.persistence.FilePersistence;
import uk.ac.ebi.arrayexpress.utils.persistence.PersistableString;
import uk.ac.ebi.arrayexpress.utils.saxon.*;
import uk.ac.ebi.arrayexpress.utils.saxon.search.IndexerException;

import java.io.File;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class Experiments extends ApplicationComponent implements IDocumentSource
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public final static String MAP_EXPERIMENTS_VIEWS = "experiments-views";
    public final static String MAP_EXPERIMENTS_DOWNLOADS = "experiments-downloads";
    public final static String MAP_EXPERIMENTS_COMPLETE_DOWNLOADS = "experiments-complete-downloads";
    public final static String MAP_EXPERIMENTS_IN_ATLAS = "experiments-in-atlas";
    public final static String MAP_VISIBLE_EXPERIMENTS = "visible-experiments";
    public final static String MAP_EXPERIMENTS_FOR_PROTOCOL = "experiments-for-protocol";
    public final static String MAP_EXPERIMENTS_FOR_ARRAY = "experiments-for-array";
    public final static String MAP_EXPERIMENTS_FOR_USER = "experiments-for-user";

    // todo: move this to similarity component
    // private final String MAP_EXPERIMENTS_WITH_SIMILARITY = "experiments-with-similarity";

    private FilePersistence<PersistableDocumentContainer> document;
    private FilePersistence<PersistableString> species;
    private FilePersistence<PersistableString> arrays;

    private MapEngine maps;
    private SaxonEngine saxon;
    private SearchEngine search;
    private Users users;
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

    public static class UpdateSourceInformation implements IEventInformation
    {
        private ExperimentSource source;
        private String location = null;
        private Long lastModified = null;
        private boolean outcome;

        public UpdateSourceInformation( ExperimentSource source, File sourceFile )
        {
            this.source = source;
            if (null != sourceFile && sourceFile.exists()) {
                this.location = sourceFile.getAbsolutePath();
                this.lastModified = sourceFile.lastModified();
            }
        }

        public UpdateSourceInformation( ExperimentSource source, String location, Long lastModified )
        {
            this.source = source;
            this.location = location;
            this.lastModified = lastModified;
        }

        public void setOutcome( boolean outcome )
        {
            this.outcome = outcome;
        }

        public ExperimentSource getSource()
        {
            return this.source;
        }

        @Override
        public Document getEventXML()
        {
            String xml = "<?xml version=\"1.0\"?><event><category>experiments-update-"
                            + this.source.toString().toLowerCase()
                            + "</category><location>"
                            + this.location + "</location><lastmodified>"
                            + StringTools.longDateTimeToXSDDateTime(lastModified)
                            + "</lastmodified><successful>"
                            + (this.outcome ? "true" : "false")
                            + "</successful></event>";
            try {
                return ((SaxonEngine) Application.getAppComponent("SaxonEngine")).buildDocument(xml);
            } catch (XPathException x) {
                throw new RuntimeException(x);
            }
        }
    }

    public Experiments()
    {
    }

    @Override
    public void initialize() throws Exception
    {
        this.maps = (MapEngine) getComponent("MapEngine");
        this.saxon = (SaxonEngine) getComponent("SaxonEngine");
        this.search = (SearchEngine) getComponent("SearchEngine");
        this.users = (Users) getComponent("Users");
        this.events = (Events) getComponent("Events");
        this.autocompletion = (Autocompletion) getComponent("Autocompletion");

        this.document = new FilePersistence<>(
                new PersistableDocumentContainer("experiments")
                , new File(getPreferences().getString("ae.experiments.persistence-location"))
        );

        this.species = new FilePersistence<>(
                new PersistableString()
                , new File(getPreferences().getString("ae.species.dropdown-html-location"))

        );

        this.arrays = new FilePersistence<>(
                new PersistableString()
                , new File(getPreferences().getString("ae.arrays.dropdown-html-location"))
        );

        maps.registerMap(new MapEngine.SimpleValueMap(MAP_EXPERIMENTS_IN_ATLAS));
        maps.registerMap(new MapEngine.SimpleValueMap(MAP_EXPERIMENTS_VIEWS));
        maps.registerMap(new MapEngine.SimpleValueMap(MAP_EXPERIMENTS_DOWNLOADS));
        maps.registerMap(new MapEngine.SimpleValueMap(MAP_EXPERIMENTS_COMPLETE_DOWNLOADS));
        maps.registerMap(new MapEngine.SimpleValueMap(MAP_VISIBLE_EXPERIMENTS));
        maps.registerMap(new MapEngine.SimpleValueMap(MAP_EXPERIMENTS_FOR_PROTOCOL));
        maps.registerMap(new MapEngine.SimpleValueMap(MAP_EXPERIMENTS_FOR_ARRAY));
        maps.registerMap(new MapEngine.SimpleValueMap(MAP_EXPERIMENTS_FOR_USER));
        users.registerUserMap(new MapEngine.SimpleValueMap(INDEX_ID));

        // todo: move this to similarity component
        // maps.registerMap(new SimpleValueMap(MAP_EXPERIMENTS_WITH_SIMILARITY));

        updateIndex();
        updateMaps();
        this.saxon.registerDocumentSource(this);
    }

    @Override
    public void terminate() throws Exception
    {
    }

    // implementation of IDocumentSource.getDocumentURI()
    @Override
    public String getDocumentURI()
    {
        return "experiments.xml";
    }

    // implementation of IDocumentSource.getDocument()
    @Override
    public synchronized Document getDocument() throws IOException
    {
        return this.document.getObject().getDocument();
    }

    // implementation of IDocumentSource.setDocument(Document)
    @Override
    public synchronized void setDocument( Document doc ) throws IOException, InterruptedException
    {
        if (null != doc) {
            this.document.setObject(new PersistableDocumentContainer("experiments", doc));
            updateIndex();
            updateMaps();
        } else {
            this.logger.error("Experiments NOT updated, NULL document passed");
        }
    }

    public String getSpecies() throws IOException
    {
        return this.species.getObject().get();
    }

    public String getArrays() throws IOException
    {
        return this.arrays.getObject().get();
    }

    public void update( String xmlString, UpdateSourceInformation sourceInformation ) throws IOException, InterruptedException
    {
        boolean success = false;
        try {
            Document updateDoc = this.saxon.transform(
                    xmlString
                    , sourceInformation.getSource().getStylesheetName()
                    , null
            );
            if (null != updateDoc) {
                new DocumentUpdater(this, updateDoc).update();
                buildSpeciesArrays();
                success = true;
            }
        } catch (SaxonException x) {
            throw new RuntimeException(x);
        } finally {
            sourceInformation.setOutcome(success);
            events.addEvent(sourceInformation);
        }
    }

    private void updateIndex() throws IOException, InterruptedException
    {
        Thread.sleep(0);
        try {
            this.search.getController().index(INDEX_ID, this.getDocument());
            this.autocompletion.rebuild();
        } catch (IndexerException x) {
            throw new RuntimeException(x);
        }
    }

    private void updateMaps() throws IOException
    {
        this.logger.debug("Updating maps for experiments");

        maps.clearMap(MAP_VISIBLE_EXPERIMENTS);
        maps.clearMap(MAP_EXPERIMENTS_FOR_PROTOCOL);
        maps.clearMap(MAP_EXPERIMENTS_FOR_ARRAY);
        users.clearUserMap(INDEX_ID);

        // todo: move this to similarity component
        // maps.clearMap(MAP_EXPERIMENTS_WITH_SIMILARITY);
        try {
            List<Item> documentNodes = saxon.evaluateXPath(getDocument().getRootNode(), "/experiments/experiment[source/@visible = 'true']");

            // todo: move this to similarity component
            // XPathExpression similarXpe = saxon.getXPathExpression("similarto");
            // XPathExpression simAccessionXpe = saxon.getXPathExpression("@accession cast as xs:string");

            for (Item node : documentNodes) {
                try {
                    NodeInfo exp = (NodeInfo)node;

                    String accession = saxon.evaluateXPathSingleAsString(exp, "accession");
                    maps.setMappedValue(MAP_VISIBLE_EXPERIMENTS, accession, exp);
                    List<Item> userIds = saxon.evaluateXPath(exp, "user/@id");
                    if (null != userIds && userIds.size() > 0) {
                        Set<String> usersForExperiment = new HashSet<>(userIds.size());
                        for (Object userId : userIds) {
                            String id = ((Item)userId).getStringValue();

                            @SuppressWarnings("unchecked")
                            Set<String> experimentsForUser = (Set<String>)maps.getMappedValue(MAP_EXPERIMENTS_FOR_USER, id);
                            if (null == experimentsForUser) {
                                experimentsForUser = new HashSet<>();
                                maps.setMappedValue(MAP_EXPERIMENTS_FOR_USER, id, experimentsForUser);
                            }
                            experimentsForUser.add(accession);
                            usersForExperiment.add(id);
                        }
                        users.setUserMapping(INDEX_ID, accession, usersForExperiment);
                    }

                    List<Item> protocolIds = saxon.evaluateXPath(exp, "protocol/id");
                    if (null != protocolIds) {
                        for (Object protocolId : protocolIds) {
                            String id = ((Item)protocolId).getStringValue();
                            @SuppressWarnings("unchecked")
                            Set<String> experimentsForProtocol = (Set<String>)maps.getMappedValue(MAP_EXPERIMENTS_FOR_PROTOCOL, id);
                            if (null == experimentsForProtocol) {
                                experimentsForProtocol = new HashSet<>();
                                maps.setMappedValue(MAP_EXPERIMENTS_FOR_PROTOCOL, id, experimentsForProtocol);
                            }
                            experimentsForProtocol.add(accession);
                        }
                    }
                    List<Item> arrayAccessions = saxon.evaluateXPath(exp, "arraydesign/accession");
                    if (null != arrayAccessions) {
                        for (Object arrayAccession : arrayAccessions) {
                            String arrayAcc = ((Item)arrayAccession).getStringValue();
                            @SuppressWarnings("unchecked")
                            Set<String> experimentsForArray = (Set<String>)maps.getMappedValue(MAP_EXPERIMENTS_FOR_ARRAY, arrayAcc);
                            if (null == experimentsForArray) {
                                experimentsForArray = new HashSet<>();
                                maps.setMappedValue(MAP_EXPERIMENTS_FOR_ARRAY, arrayAcc, experimentsForArray);
                            }
                            experimentsForArray.add(accession);
                        }
                    }
                    /* todo: move this to similarity component
                    List<Object> similarToElements = similarXpe.evaluate(exp);
                    if (null != similarToElements) {
                        for ( Object similarTo : similarToElements ) {
                            String simAccession = (String)simAccessionXpe.evaluateSingle((NodeInfo)similarTo);
                            Set<Object> experimentsWithSimilarity = (Set<Object>)maps.getMappedValue(MAP_EXPERIMENTS_WITH_SIMILARITY, simAccession);
                            if (null == experimentsWithSimilarity) {
                                experimentsWithSimilarity = new HashSet<>();
                                maps.setMappedValue(MAP_EXPERIMENTS_WITH_SIMILARITY, simAccession, experimentsWithSimilarity);
                            }
                            experimentsWithSimilarity.add(node);
                        }
                    }
                    */
                } catch (XPathException x) {
                    this.logger.error("Caught an exception:", x);
                }
            }

            this.logger.debug("Maps updated");
        } catch (Exception x) {
            this.logger.error("Caught an exception:", x);
        }
    }

    private void buildSpeciesArrays() throws IOException
    {
        // todo: move this to a separate component (autocompletion?)
        try {
            String speciesString = saxon.transformToString(this.getDocument(), "build-species-list-html.xsl", null);
            this.species.setObject(new PersistableString(speciesString));

            String arraysString = saxon.transformToString(this.getDocument(), "build-arrays-list-html.xsl", null);
            this.arrays.setObject(new PersistableString(arraysString));
        } catch (SaxonException x) {
            throw new RuntimeException(x);
        }

    }
}
