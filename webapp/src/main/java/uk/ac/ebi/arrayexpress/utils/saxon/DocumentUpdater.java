/*
 * Copyright 2009-2015 European Molecular Biology Laboratory
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

package uk.ac.ebi.arrayexpress.utils.saxon;

import net.sf.saxon.om.NodeInfo;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;

import java.io.IOException;

public class DocumentUpdater implements XMLDocumentSource {
    private final XMLDocumentSource source;
    private final SaxonEngine saxon;
    private final NodeInfo update;

    public DocumentUpdater(XMLDocumentSource source, NodeInfo update) {
        this.source = source;
        this.saxon = (SaxonEngine)Application.getAppComponent("SaxonEngine");
        this.update = update;
    }

    @Override
    public String getURI() {
        return "update-" + source.getURI();
    }

    @Override
    public synchronized NodeInfo getRootNode() throws IOException {
        return this.update;
    }

    @Override
    public synchronized void setRootNode(NodeInfo rootNode) throws IOException {
        // nothing
    }

    public void update() throws SaxonException, IOException, InterruptedException {
        synchronized (getClass()) {
            saxon.registerDocumentSource(this);
            source.setRootNode(
                    saxon.transform(source.getRootNode(), getURI().replace(".xml", "-xml.xsl"), null)
            );
            saxon.unregisterDocumentSource(this);
        }
    }
}

