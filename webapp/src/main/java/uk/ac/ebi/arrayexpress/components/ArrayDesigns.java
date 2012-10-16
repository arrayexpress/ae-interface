package uk.ac.ebi.arrayexpress.components;

import net.sf.saxon.om.DocumentInfo;
import net.sf.saxon.xpath.XPathEvaluator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.persistence.FilePersistence;
import uk.ac.ebi.arrayexpress.utils.saxon.DocumentUpdater;
import uk.ac.ebi.arrayexpress.utils.saxon.IDocumentSource;
import uk.ac.ebi.arrayexpress.utils.saxon.PersistableDocumentContainer;
import uk.ac.ebi.arrayexpress.utils.saxon.functions.ExtFunctions;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import java.io.File;
import java.io.IOException;
import java.util.List;

/*
 * Copyright 2009-2012 European Molecular Biology Laboratory
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

    private FilePersistence<PersistableDocumentContainer> document;
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
        
        this.document = new FilePersistence<PersistableDocumentContainer>(
                new PersistableDocumentContainer("array_designs")
                , new File(getPreferences().getString("ae.arrays.persistence-location"))
        );

        updateIndex();
        updateAccelerators();
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
    public synchronized DocumentInfo getDocument() throws IOException
    {
        return this.document.getObject().getDocument();
    }

    // implementation of IDocumentSource.setDocument(DocumentInfo)
    public synchronized void setDocument( DocumentInfo doc ) throws IOException
    {
        if (null != doc) {
            this.document.setObject(new PersistableDocumentContainer("array_designs", doc));
            updateIndex();
            updateAccelerators();
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

    private void updateAccelerators()
    {
        this.logger.debug("Updating accelerators for arrays");

        ExtFunctions.clearAccelerator("legacy-array-ids");
        try {
            XPath xp = new XPathEvaluator(getDocument().getConfiguration());
            XPathExpression xpe = xp.compile("/array_designs/array_design[@visible = 'true']");
            List documentNodes = (List) xpe.evaluate(getDocument(), XPathConstants.NODESET);

            XPathExpression accessionXpe = xp.compile("accession");
            XPathExpression legacyIdsXpe = xp.compile("legacy_id");
            for (Object node : documentNodes) {

                try {
                    // get all the expressions taken care of
                    String accession = accessionXpe.evaluate(node);
                    List legacyIds = (List)legacyIdsXpe.evaluate(node, XPathConstants.NODESET);
                    if (null != legacyIds) {
                        ExtFunctions.addAcceleratorValue("legacy-array-ids", accession, legacyIds);
                    }
                } catch (XPathExpressionException x) {
                    this.logger.error("Caught an exception:", x);
                }
            }

            this.logger.debug("Accelerators updated");
        } catch (Exception x) {
            this.logger.error("Caught an exception:", x);
        }
    }
}