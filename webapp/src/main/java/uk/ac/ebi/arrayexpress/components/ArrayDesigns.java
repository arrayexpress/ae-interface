package uk.ac.ebi.arrayexpress.components;

import net.sf.saxon.om.Item;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.trans.XPathException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.persistence.FilePersistence;
import uk.ac.ebi.arrayexpress.utils.saxon.*;

import java.io.File;
import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

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

public class ArrayDesigns extends ApplicationComponent implements IDocumentSource
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final String MAP_ARRAY_LEGACY_ID = "array-legacy-ids";

    private FilePersistence<PersistableDocumentContainer> document;

    private MapEngine maps;
    private SaxonEngine saxon;
    private SearchEngine search;
    private Users users;

    public final String INDEX_ID = "arrays";
    
    public enum ArrayDesignSource
    {
        AE1, AE2;

        public String getStylesheetName()
        {
            switch (this) {
                case AE1:   return "preprocess-arrays-ae1-xml.xsl";
                case AE2:   return "preprocess-arrays-ae2-xml.xsl";
            }
            return null;
        }
    }

    public ArrayDesigns()
    {
    }

    @Override
    public void initialize() throws Exception
    {
        this.maps = (MapEngine) getComponent("MapEngine");
        this.saxon = (SaxonEngine) getComponent("SaxonEngine");
        this.search = (SearchEngine) getComponent("SearchEngine");
        this.users = (Users) getComponent("Users");
        
        this.document = new FilePersistence<>(
                new PersistableDocumentContainer("array_designs")
                , new File(getPreferences().getString("ae.arrays.persistence-location"))
        );

        maps.registerMap(new MapEngine.SimpleValueMap(MAP_ARRAY_LEGACY_ID));
        users.registerUserMap(new MapEngine.SimpleValueMap(INDEX_ID));

        updateIndex();
        updateMaps();
        this.saxon.registerDocumentSource(this);
    }

    @Override
    public void terminate() throws Exception
    {
    }

    // implementation of IDocumentSource.getDocumentURI()
    public String getDocumentURI()
    {
        return "arrays.xml";
    }

    // implementation of IDocumentSource.getDocument()
    public synchronized Document getDocument() throws IOException
    {
        return this.document.getObject().getDocument();
    }

    // implementation of IDocumentSource.setDocument(Document)
    public synchronized void setDocument( Document doc ) throws IOException
    {
        if (null != doc) {
            this.document.setObject(new PersistableDocumentContainer("array_designs", doc));
            updateIndex();
            updateMaps();
        } else {
            this.logger.error("Array designs NOT updated, NULL document passed");
        }
    }

    public void update( String xmlString, ArrayDesignSource source ) throws IOException, InterruptedException
    {
        try {
            Document updateDoc = this.saxon.transform(xmlString, source.getStylesheetName(), null);
            if (null != updateDoc) {
                new DocumentUpdater(this, updateDoc).update();
            }
        } catch (SaxonException x) {
            throw new RuntimeException(x);
        }
    }

    private void updateIndex()
    {
        try {
            this.search.getController().index(INDEX_ID, this.getDocument());
        } catch (Exception x) {
            this.logger.error("Caught an exception:", x);
        }
    }

    private void updateMaps()
    {
        this.logger.debug("Updating maps for arrays");

        maps.clearMap(MAP_ARRAY_LEGACY_ID);
        users.clearUserMap(INDEX_ID);

        try {
            List<Item> documentNodes = saxon.evaluateXPath(getDocument().getRootNode(),
                    "/array_designs/array_design[@visible = 'true']");
            for (Item node : documentNodes) {

                try {
                    NodeInfo array = (NodeInfo)node;

                    String accession = saxon.evaluateXPathSingleAsString(array, "accession");
                    String legacyId = saxon.evaluateXPathSingleAsString(array, "legacy_id");

                    if (null != legacyId) {
                        maps.setMappedValue(MAP_ARRAY_LEGACY_ID, accession, legacyId);
                    }
                    List<Item> userIds = saxon.evaluateXPath(array, "user/@id");
                    if (null != userIds && userIds.size() > 0) {
                        Set<String> stringSet = new HashSet<>(userIds.size());
                        for (Object userId : userIds) {
                            stringSet.add(((Item)userId).getStringValue());
                        }
                        users.setUserMapping(INDEX_ID, accession, stringSet);
                    }
                } catch (XPathException x) {
                    this.logger.error("Caught an exception:", x);
                }
            }

            this.logger.debug("Maps updated");
        } catch (Exception x) {
            this.logger.error("Caught an exception:", x);
        }
    }
}