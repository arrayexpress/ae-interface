package uk.ac.ebi.arrayexpress.components;

/*
 * Copyright 2009-2011 European Molecular Biology Laboratory
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
import net.sf.saxon.xpath.XPathEvaluator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.RegexHelper;
import uk.ac.ebi.arrayexpress.utils.persistence.FilePersistence;
import uk.ac.ebi.arrayexpress.utils.saxon.ExtFunctions;
import uk.ac.ebi.arrayexpress.utils.saxon.IDocumentSource;
import uk.ac.ebi.arrayexpress.utils.saxon.PersistableDocumentContainer;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import java.io.File;
import java.util.List;

public class Files extends ApplicationComponent implements IDocumentSource
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private String rootFolder;
    private FilePersistence<PersistableDocumentContainer> document;
    private String lastReloadMessage;

    private SaxonEngine saxon;
    private SearchEngine search;
    //private Events events;

    public final String INDEX_ID = "files";

    public Files()
    {
    }

    public void initialize() throws Exception
    {
        this.saxon = (SaxonEngine) getComponent("SaxonEngine");
        this.search = (SearchEngine) getComponent("SearchEngine");
        //this.events = (Events) getComponent("Events");

        this.document = new FilePersistence<PersistableDocumentContainer>(
                new PersistableDocumentContainer("files"),
                new File(getPreferences().getString("ae.files.persistence-location"))
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
        return "files.xml";
    }

    // implementation of IDocumentSource.getDocument()
    public synchronized DocumentInfo getDocument() throws Exception
    {
        return this.document.getObject().getDocument();
    }

    public synchronized void setDocument( DocumentInfo doc ) throws Exception
    {
        if (null != doc) {
            this.document.setObject(new PersistableDocumentContainer("files", doc));
            updateIndex();
            updateAccelerators();
        } else {
            this.logger.error("Files NOT updated, NULL document passed");
        }
    }

    public void reload( DocumentInfo doc, String message ) throws Exception
    {
        setDocument(doc);
        this.lastReloadMessage = message;
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
        this.logger.debug("Updating accelerators for files");

        ExtFunctions.clearAccelerator("ftp-folder");
        ExtFunctions.clearAccelerator("raw-files");
        ExtFunctions.clearAccelerator("fgem-files");

        try {
            XPath xp = new XPathEvaluator(getDocument().getConfiguration());
            XPathExpression xpe = xp.compile("/files/folder");
            List documentNodes = (List) xpe.evaluate(getDocument(), XPathConstants.NODESET);

            XPathExpression accessionXpe = xp.compile("@accession");
            XPathExpression folderKindXpe = xp.compile("@kind");
            XPathExpression rawFilePresentXpe = xp.compile("count(file[@kind = 'raw'])");
            XPathExpression fgemFilePresentXpe = xp.compile("count(file[@kind = 'fgem'])");
            for (Object node : documentNodes) {

                try {
                    // get all the expressions taken care of
                    String accession = accessionXpe.evaluate(node);
                    String folderKind = folderKindXpe.evaluate(node);
                    ExtFunctions.addAcceleratorValue("ftp-folder", accession, node);
                    //todo: remove redundancy here
                    if ("experiment".equals(folderKind)) {
                        ExtFunctions.addAcceleratorValue("raw-files", accession, rawFilePresentXpe.evaluate(node));
                        ExtFunctions.addAcceleratorValue("fgem-files", accession, fgemFilePresentXpe.evaluate(node));
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

    public synchronized void setRootFolder( String folder )
    {
        if (null != folder && 0 < folder.length()) {
            if (folder.endsWith(File.separator)) {
                this.rootFolder = folder;
            } else {
                this.rootFolder = folder + File.separator;
            }
        } else {
            this.logger.error("setRootFolder called with null or empty parameter, expect problems down the road");
        }
    }

    public synchronized String getRootFolder()
    {
        if (null == this.rootFolder) {
            this.rootFolder = getPreferences().getString("ae.files.root.location");
        }
        return this.rootFolder;
    }

    public String getLastReloadMessage()
    {
        return this.lastReloadMessage;
    }

    // returns true is file is registered in the registry
    public boolean doesExist( String accession, String name ) throws Exception
    {
        if (null != accession && accession.length() > 0) {
            return Boolean.parseBoolean(
                    this.saxon.evaluateXPathSingle(
                            getDocument()
                            , "exists(//folder[@accession = \"" + accession.replaceAll("\"", "&quot;") + "\"]/file[@name = \"" + name.replaceAll("\"", "&quot;") + "\"])"
                    )
            );
        } else {
            return Boolean.parseBoolean(
                    this.saxon.evaluateXPathSingle(
                            getDocument()
                            , "exists(//file[@name = \"" + name.replaceAll("\"", "&quot;") + "\"])"
                    )
            );
        }
    }

    // returns absolute file location (if file exists, null otherwise) in local filesystem
    public String getLocation( String accession, String name ) throws Exception
    {
        String folderLocation;

        if (null != accession && accession.length() > 0) {
            folderLocation = this.saxon.evaluateXPathSingle(
                    getDocument()
                    , "//folder[@accession = '" + accession + "' and file/@name = '" + name + "']/@location"
            );
        } else {
            folderLocation = this.saxon.evaluateXPathSingle(
                    getDocument()
                    , "//folder[file/@name = '" + name + "']/@location"
            );
        }

        if (null != folderLocation && folderLocation.length() > 0) {
            return folderLocation + File.separator + name;
        } else {
            return null;
        }
    }

    public String getAccession( String fileLocation ) throws Exception
    {
        String[] nameFolder = new RegexHelper("^(.+)/([^/]+)$", "i")
                .match(fileLocation);
        if (null == nameFolder || 2 != nameFolder.length) {
            this.logger.error("Unable to parse the location [{}]", fileLocation);
            return null;
        }

        return this.saxon.evaluateXPathSingle(
                getDocument()
                , "//folder[file/@name = '" + nameFolder[1] + "' and @location = '" + nameFolder[0] + "']/@accession"
        );
    }
}
