package uk.ac.ebi.arrayexpress.utils.saxon;

import net.sf.saxon.om.DocumentInfo;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;

import java.io.IOException;

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

public class DocumentUpdater implements IDocumentSource
{
    private IDocumentSource source;
    private SaxonEngine saxon;
    private DocumentInfo update;

    public DocumentUpdater( IDocumentSource source, DocumentInfo update )
    {
        this.source = source;
        this.saxon = (SaxonEngine) Application.getAppComponent("SaxonEngine");
        this.update = update;
    }

    // implementation of IDocumentSource.getDocumentURI()
    @Override
    public String getDocumentURI()
    {
        return "update-" + source.getDocumentURI();
    }

    // implementation of IDocumentSource.getDocument()
    @Override
    public synchronized DocumentInfo getDocument() throws IOException
    {
        return this.update;
    }

    // implementation of IDocumentSource.setDocument(DocumentInfo)
    @Override
    public synchronized void setDocument( DocumentInfo doc ) throws IOException
    {
        // nothing
    }

    public void update() throws SaxonException, IOException, InterruptedException
    {
        synchronized(getClass()) {
            saxon.registerDocumentSource(this);
            source.setDocument(saxon.transform(source.getDocument(), getDocumentURI().replace(".xml", "-xml.xsl"), null));
            saxon.unregisterDocumentSource(this);
        }
    }
}

