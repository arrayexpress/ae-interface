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
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.io.File;

public class DocumentPersister
{

    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final static String emptyXml = "<?xml version=\"1.0\"?><empty/>";

    public DocumentInfo loadObject( String fileLocation )
    {
        DocumentInfo document = null;

        try {
            String strDocument = StringTools.fileToString(new File(fileLocation));
            if (null == strDocument) {
                strDocument = emptyXml;
            }
            document = ((SaxonEngine) Application.getAppComponent("SaxonEngine")).buildDocument(strDocument);


        } catch (Exception e) {
            throw new PersistenceException("Problem with loading ", e);
        }

        return document;
    }

    public void saveObject( DocumentInfo document, String fileLocation )
    {

        try {
            String strDocument = ((SaxonEngine) Application.getAppComponent("SaxonEngine")).serializeDocument(document);
            StringTools.stringToFile(strDocument, new File(fileLocation));
        } catch (Exception e) {
            throw new PersistenceException("Problem with persisting document ", e);
        }
    }
}
