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

public class Protocols extends ApplicationComponent implements XMLDocumentSource
{
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private Document document;
    private SaxonEngine saxon;
    private SearchEngine search;

    public final String INDEX_ID = "protocols";

    public enum ProtocolsSource
    {
        AE1, AE2;

        public String getStylesheetName()
        {
            switch (this) {
                case AE1:   return "preprocess-protocols-ae1-xml.xsl";
                case AE2:   return "preprocess-protocols-ae2-xml.xsl";
            }
            return null;
        }
    }

    public Protocols()
    {
    }

    @Override
    public void initialize() throws Exception
    {
        this.saxon = (SaxonEngine) getComponent("SaxonEngine");
        this.search = (SearchEngine) getComponent("SearchEngine");

        this.document = new StoredDocument(
                new File(getPreferences().getString("ae.protocols.persistence-location")),
                "protocols"
        );

        updateIndex();
        this.saxon.registerDocumentSource(this);
    }

    @Override
    public void terminate() throws Exception
    {
    }

    public String getURI()
    {
        return "protocols.xml";
    }

    public synchronized NodeInfo getRootNode()
    {
        return document.getRootNode();
    }

    public synchronized void setRootNode( NodeInfo rootNode ) throws IOException, SaxonException
    {
        if (null != rootNode) {
            document = new StoredDocument(rootNode,
                    new File(getPreferences().getString("ae.protocols.persistence-location")));
            updateIndex();
        } else {
            this.logger.error("Protocols NOT updated, NULL document passed");
        }
    }

    public void update( String xmlString, ProtocolsSource source ) throws IOException, InterruptedException
    {
        try {
            NodeInfo update = this.saxon.transform(xmlString, source.getStylesheetName(), null);
            if (null != update) {
                new DocumentUpdater(this, update).update();
            }
        } catch (SaxonException x) {
            throw new RuntimeException(x);
        }
    }

    private void updateIndex()
    {
        try {
            Thread.sleep(0);
            this.search.getController().index(INDEX_ID, document);
        } catch (Exception x) {
            throw new RuntimeException(x);
        }
    }
}