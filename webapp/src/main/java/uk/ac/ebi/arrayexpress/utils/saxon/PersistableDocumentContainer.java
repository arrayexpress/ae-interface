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

import net.sf.saxon.om.Item;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.NumericValue;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;
import uk.ac.ebi.arrayexpress.utils.persistence.Persistable;

public class PersistableDocumentContainer extends DocumentContainer implements Persistable {
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final String rootElement;

    public PersistableDocumentContainer(String rootElement) {
        this.rootElement = rootElement;
        createDocument();
    }

    public PersistableDocumentContainer(String rootElement, Document doc) {
        this.rootElement = rootElement;
        if (null == doc) {
            createDocument();
        } else {
            setDocument(doc);
        }
    }

    public String toPersistence() {
        try {
            return ((SaxonEngine)Application.getAppComponent("SaxonEngine")).serializeDocument(
                    getDocument().getRootNode()
            );
        } catch (Exception x)
        {
            logger.debug( "Caught an exception:", x );
        }
        return null;
    }

    public void fromPersistence(String str) {
        try {
            setDocument(build(str));
        } catch (Exception x) {
            setDocument(null);
        }

        if (null == getDocument()) {
            createDocument();
        }
    }

    public boolean isEmpty()
    {
        if (null == getDocument()) {
            return true;
        }

        Long total = null;
        try {
            SaxonEngine saxon = (SaxonEngine)Application.getAppComponent("SaxonEngine");
            Item item = saxon.evaluateXPathSingle(getDocument().getRootNode(), "count(/" + this.rootElement + "/*)");
            total = ((NumericValue) item).longValue();
        } catch (XPathException x) {
            logger.debug("Caught an exception:", x);
        }

        return (null == total || 0 == total);
    }

    private void createDocument()
    {
        try {
            setDocument(build("<?xml version=\"1.0\"?><" + this.rootElement + "/>"));
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }

        if (null == getDocument()) {
            logger.error("The document WAS NOT created, expect problems down the road");
        }

    }

    private Document build(String str) throws XPathException {
        return ((SaxonEngine)Application.getAppComponent("SaxonEngine")).buildDocument(str);
    }
}
