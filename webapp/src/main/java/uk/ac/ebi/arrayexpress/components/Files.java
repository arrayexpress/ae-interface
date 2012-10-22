package uk.ac.ebi.arrayexpress.components;

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

import net.sf.saxon.om.DocumentInfo;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.trans.XPathException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.RegexHelper;
import uk.ac.ebi.arrayexpress.utils.persistence.FilePersistence;
import uk.ac.ebi.arrayexpress.utils.saxon.IDocumentSource;
import uk.ac.ebi.arrayexpress.utils.saxon.PersistableDocumentContainer;

import java.io.File;
import java.io.IOException;
import java.util.List;

public class Files extends ApplicationComponent implements IDocumentSource
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final String MAP_FOLDER = "ftp-folder";
    private final String MAP_RAW_FILES = "raw-files";
    private final String MAP_PROCESSED_FILES = "fgem-files";

    private String rootFolder;
    private FilePersistence<PersistableDocumentContainer> document;
    private String lastReloadMessage = "";

    private MapEngine maps;
    private SaxonEngine saxon;
    private SearchEngine search;

    public final String INDEX_ID = "files";

    public Files()
    {
    }

    public void initialize() throws Exception
    {
        this.maps = (MapEngine) getComponent("MapEngine");
        this.saxon = (SaxonEngine) getComponent("SaxonEngine");
        this.search = (SearchEngine) getComponent("SearchEngine");

        this.document = new FilePersistence<>(
                new PersistableDocumentContainer("files"),
                new File(getPreferences().getString("ae.files.persistence-location"))
        );

        maps.registerMap(new MapEngine.SimpleValueMap(MAP_FOLDER));
        maps.registerMap(new MapEngine.SimpleValueMap(MAP_RAW_FILES));
        maps.registerMap(new MapEngine.SimpleValueMap(MAP_PROCESSED_FILES));

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
    public synchronized DocumentInfo getDocument() throws IOException
    {
        return this.document.getObject().getDocument();
    }

    public synchronized void setDocument( DocumentInfo doc ) throws IOException
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
        this.logger.debug("Updating maps for files");

        maps.clearMap(MAP_FOLDER);
        maps.clearMap(MAP_RAW_FILES);
        maps.clearMap(MAP_PROCESSED_FILES);

        try {
            DocumentInfo doc = getDocument();
            List<Object> documentNodes = saxon.evaluateXPath(doc, "/files/folder");

            for (Object node : documentNodes) {

                try {
                    // get all the expressions taken care of
                    String accession = saxon.evaluateXPathSingleAsString((NodeInfo) node, "@accession");
                    String folderKind = saxon.evaluateXPathSingleAsString((NodeInfo) node, "@kind");
                    maps.setMappedValue(MAP_FOLDER, accession, node);
                    //todo: remove redundancy here
                    if ("experiment".equals(folderKind)) {
                        maps.setMappedValue(MAP_RAW_FILES, accession, saxon.evaluateXPathSingle((NodeInfo)node, "count(file[@kind = 'raw'])"));
                        maps.setMappedValue(MAP_PROCESSED_FILES, accession, saxon.evaluateXPathSingle((NodeInfo)node, "count(file[@kind = 'fgem'])"));
                    }
                } catch (XPathException x) {
                    this.logger.error("Caught an exception:", x);
                }
            }
            this.logger.debug("Maps updated");
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
    public boolean doesExist( String accession, String name ) throws IOException
    {
        boolean result = false;

        try {
            if (null != accession && accession.length() > 0) {
                result = (Boolean)this.saxon.evaluateXPathSingle(
                        getDocument()
                        , "exists(//folder[@accession = \"" + accession.replaceAll("\"", "&quot;") + "\"]/file[@name = \"" + name.replaceAll("\"", "&quot;") + "\"])"
                );
            } else {
                result = (Boolean)this.saxon.evaluateXPathSingle(
                        getDocument()
                        , "exists(//file[@name = \"" + name.replaceAll("\"", "&quot;") + "\"])"
                );
            }
        } catch ( XPathException x ) {
            logger.error("Caught an exception:", x);
        }

        return result;
    }

    // returns absolute file location (if file exists, null otherwise) in local filesystem
    public String getLocation( String accession, String name ) throws IOException
    {
        String folderLocation = null;

        try {
            if (null != accession && accession.length() > 0) {
                folderLocation = this.saxon.evaluateXPathSingleAsString(
                        getDocument()
                        , "//folder[@accession = '" + accession + "' and file/@name = '" + name + "']/@location"
                );
            } else {
                folderLocation = this.saxon.evaluateXPathSingleAsString(
                        getDocument()
                        , "//folder[file/@name = '" + name + "']/@location"
                );
            }
        } catch ( XPathException x ) {
            logger.error("Caught an exception:", x);
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

        return this.saxon.evaluateXPathSingleAsString(
                getDocument()
                , "//folder[file/@name = '" + nameFolder[1] + "' and @location = '" + nameFolder[0] + "']/@accession"
        );
    }
}
