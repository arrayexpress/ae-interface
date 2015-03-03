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

import net.sf.saxon.om.NodeInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.saxon.*;

import java.io.File;
import java.io.IOException;

public class News extends ApplicationComponent implements XMLDocumentSource
{
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private Document document;
    private SaxonEngine saxon;

    public final String DOCUMENT_ID = "news";

    public News()
    {
    }

    @Override
    public void initialize() throws Exception
    {
        this.saxon = (SaxonEngine) getComponent("SaxonEngine");

        this.document = new StoredDocument(
                new File(getPreferences().getString("ae.news.persistence-location")),
                "news"
        );

        this.saxon.registerDocumentSource(this);
    }

    @Override
    public void terminate() throws Exception
    {
    }

    @Override
    public String getURI()
    {
        return DOCUMENT_ID + ".xml";
    }

    @Override
    public synchronized NodeInfo getRootNode()
    {
        return document.getRootNode();
    }

    @Override
    public synchronized void setRootNode( NodeInfo rootNode ) throws IOException, SaxonException
    {
        if (null != rootNode) {
            document = new StoredDocument(rootNode,
                    new File(getPreferences().getString("ae.news.persistence-location")));
        } else {
            this.logger.error("News NOT updated, NULL document passed");
        }
    }

    public void update( String xmlString ) throws IOException
    {
        try {
            NodeInfo update = this.saxon.buildDocument(xmlString);
            if (null != update) {
                new DocumentUpdater(this, update).update();
            }
        } catch (Exception x) {
            throw new RuntimeException(x);
        }
    }
}