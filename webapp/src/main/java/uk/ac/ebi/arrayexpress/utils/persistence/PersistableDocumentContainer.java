package uk.ac.ebi.arrayexpress.utils.persistence;

/*
 * Copyright 2009-2010 European Molecular Biology Laboratory
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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;
import uk.ac.ebi.arrayexpress.utils.saxon.DocumentContainer;

// TODO - check XML version on persistence events

public class PersistableDocumentContainer extends DocumentContainer implements Persistable
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public PersistableDocumentContainer()
    {
        createDocument();
    }

    public PersistableDocumentContainer( DocumentInfo doc )
    {
        if (null == doc) {
            createDocument();
        } else {
            setDocument(doc);
        }
    }

    public String toPersistence() throws Exception
    {
        return ((SaxonEngine)Application.getAppComponent("SaxonEngine")).serializeDocument(getDocument());
    }

    public void fromPersistence( String str ) throws Exception
    {
        setDocument(((SaxonEngine)Application.getAppComponent("SaxonEngine")).buildDocument(str));
        
        if (null == getDocument()) {
            createDocument();
        }
    }

    public boolean isEmpty() throws Exception
    {
        if (null == getDocument())
            return true;

        String total = ((SaxonEngine)Application.getAppComponent("SaxonEngine")).evaluateXPathSingle(getDocument(), "/experiments/@total");

        return (null == total || total.equals("0"));
    }

    private void createDocument()
    {
        try {
            setDocument(((SaxonEngine)Application.getAppComponent("SaxonEngine")).buildDocument("<?xml version=\"1.0\"?><experiments total=\"0\"></experiments>"));
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }

        if (null == getDocument()) {
            logger.error("The document WAS NOT created, expect problems down the road");
        }

    }
}
