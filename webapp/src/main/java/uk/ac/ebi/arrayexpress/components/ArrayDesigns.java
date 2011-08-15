package uk.ac.ebi.arrayexpress.components;

import net.sf.saxon.om.DocumentInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.persistence.PersistableDocumentContainer;
import uk.ac.ebi.arrayexpress.utils.persistence.TextFilePersistence;
import uk.ac.ebi.arrayexpress.utils.saxon.DocumentUpdater;
import uk.ac.ebi.arrayexpress.utils.saxon.IDocumentSource;

import java.io.File;

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

public class ArrayDesigns extends ApplicationComponent implements IDocumentSource
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private TextFilePersistence<PersistableDocumentContainer> document;
    private SaxonEngine saxon;
    private SearchEngine search;

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

    public void initialize() throws Exception
    {
        this.saxon = (SaxonEngine) getComponent("SaxonEngine");
        this.search = (SearchEngine) getComponent("SearchEngine");
        
        this.document = new TextFilePersistence<PersistableDocumentContainer>(
                new PersistableDocumentContainer("array_designs")
                , new File(getPreferences().getString("ae.arrays.persistence-location"))
        );

        updateIndex();
        this.saxon.registerDocumentSource(this);
    }

    public void terminate() throws Exception
    {
    }

    // implementation of IDocumentSource.getDocumentURI()
    public String getDocumentURI()
    {
        return "arrays.xml";
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
            this.document.setObject(new PersistableDocumentContainer("array_designs", doc));
            updateIndex();
        } else {
            this.logger.error("Array designs NOT updated, NULL document passed");
        }
    }

    public void update( String xmlString, ArrayDesignSource source ) throws Exception
    {
        DocumentInfo updateDoc = this.saxon.transform(xmlString, source.getStylesheetName(), null);
        if (null != updateDoc) {
            new DocumentUpdater(this, updateDoc).update();
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
}