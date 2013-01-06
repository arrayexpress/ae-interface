package uk.ac.ebi.arrayexpress.utils.saxon;

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
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;
import uk.ac.ebi.arrayexpress.utils.persistence.Persistable;

// TODO - check XML version on persistence events

public class PersistableDocumentContainer extends DocumentContainer implements Persistable
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private String rootElement;

    public PersistableDocumentContainer( String rootElement )
    {
        this.rootElement = rootElement;
        createDocument();
    }

    public PersistableDocumentContainer( String rootElement, DocumentInfo doc )
    {
        this.rootElement = rootElement;
        if (null == doc) {
            createDocument();
        } else {
            setDocument(doc);
        }
    }

    public String toPersistence()
    {
        try {
            return ((SaxonEngine)Application.getAppComponent("SaxonEngine")).serializeDocument(getDocument());
        } catch (Exception x)
        {
            logger.debug( "Caught an exception:", x );
        }
        return null;
    }

    public void fromPersistence( String str )
    {
        try {
            setDocument(((SaxonEngine)Application.getAppComponent("SaxonEngine")).buildDocument(str));
        } catch (Exception x)
        {
            setDocument(null);
        }

        if (null == getDocument()) {
            createDocument();
        }
    }

    public boolean isEmpty()
    {
        if (null == getDocument())
            return true;

        Long total = null;
        try {
            SaxonEngine saxon = (SaxonEngine)Application.getAppComponent("SaxonEngine");
            total = (Long)saxon.evaluateXPathSingle(getDocument(), "count(/" + this.rootElement + "/*)");
        } catch (XPathException x)
        {
            logger.debug("Caught an exception:", x);
        }

        return (null == total || 0 == total);
    }

    private void createDocument()
    {
        try {
            setDocument(((SaxonEngine)Application.getAppComponent("SaxonEngine")).buildDocument("<?xml version=\"1.0\"?><" + this.rootElement + "/>"));
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }

        if (null == getDocument()) {
            logger.error("The document WAS NOT created, expect problems down the road");
        }

    }
}
