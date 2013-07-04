package uk.ac.ebi.arrayexpress.components;

/*
 * Copyright 2009-2013 European Molecular Biology Laboratory
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
import net.sf.saxon.trans.XPathException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.persistence.FilePersistence;
import uk.ac.ebi.arrayexpress.utils.saxon.DocumentUpdater;
import uk.ac.ebi.arrayexpress.utils.saxon.IDocumentSource;
import uk.ac.ebi.arrayexpress.utils.saxon.PersistableDocumentContainer;
import uk.ac.ebi.arrayexpress.utils.saxon.SaxonException;

import java.io.File;
import java.io.IOException;

public class News extends ApplicationComponent implements IDocumentSource
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private FilePersistence<PersistableDocumentContainer> document;
    private SaxonEngine saxon;

    public final String DOCUMENT_ID = "news";

    public News()
    {
    }

    @Override
    public void initialize() throws Exception
    {
        this.saxon = (SaxonEngine) getComponent("SaxonEngine");

        this.document = new FilePersistence<>(
                new PersistableDocumentContainer(DOCUMENT_ID)
                , new File(getPreferences().getString("ae.news.persistence-location"))
        );

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
        return DOCUMENT_ID + ".xml";
    }

    // implementation of IDocumentSource.getDocument()
    @Override
    public synchronized DocumentInfo getDocument() throws IOException
    {
        return this.document.getObject().getDocument();
    }

    // implementation of IDocumentSource.setDocument(DocumentInfo)
    @Override
    public synchronized void setDocument( DocumentInfo doc ) throws IOException, InterruptedException
    {
        if (null != doc) {
            this.document.setObject(new PersistableDocumentContainer(DOCUMENT_ID, doc));
        } else {
            this.logger.error("News NOT updated, NULL document passed");
        }
    }

    public void update( String xmlString) throws IOException, InterruptedException
    {
        try {
            DocumentInfo updateDoc = this.saxon.buildDocument(xmlString);
            if (null != updateDoc) {
                new DocumentUpdater(this, updateDoc).update();
            }
        } catch (XPathException | SaxonException x) {
            throw new RuntimeException(x);
        }
    }
}