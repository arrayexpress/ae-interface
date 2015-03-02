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

import net.sf.saxon.om.Item;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.BooleanValue;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.persistence.FilePersistence;
import uk.ac.ebi.arrayexpress.utils.saxon.Document;
import uk.ac.ebi.arrayexpress.utils.saxon.IDocumentSource;
import uk.ac.ebi.arrayexpress.utils.saxon.PersistableDocumentContainer;
import uk.ac.ebi.arrayexpress.utils.saxon.search.IndexerException;

import java.io.File;
import java.io.IOException;
import java.util.List;

public class Files extends ApplicationComponent implements IDocumentSource
{
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final String MAP_FOLDER = "ftp-folder";
    private final String MAP_RAW_FILES = "raw-files";
    private final String MAP_PROCESSED_FILES = "processed-files";
    private final String MAP_FILES_TOTAL = "files-total";

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

    @Override
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
        maps.registerMap(new MapEngine.SimpleValueMap(MAP_FILES_TOTAL));

        updateIndex();
        updateAccelerators();
        this.saxon.registerDocumentSource(this);
    }

    @Override
    public void terminate() throws Exception
    {
    }

    // implementation of IDocumentSource.getDocumentURI()
    @Override
    public String getDocumentURI()
    {
        return "files.xml";
    }

    // implementation of IDocumentSource.getDocument()
    @Override
    public synchronized Document getDocument() throws IOException
    {
        return this.document.getObject().getDocument();
    }

    @Override
    public synchronized void setDocument( Document doc ) throws IOException, InterruptedException
    {
        if (null != doc) {
            this.document.setObject(new PersistableDocumentContainer("files", doc));
            updateIndex();
            updateAccelerators();
        } else {
            this.logger.error("Files NOT updated, NULL document passed");
        }
    }

    public void reload( Document doc, String message ) throws IOException, InterruptedException
    {
        setDocument(doc);
        this.lastReloadMessage = message;
    }

    private void updateIndex() throws IOException, InterruptedException
    {
        Thread.sleep(0);
        try {
            this.search.getController().index(INDEX_ID, this.getDocument());
        } catch (IndexerException x) {
            throw new RuntimeException(x);
        }
    }

    @SuppressWarnings("unchecked")
    private void updateAccelerators() throws IOException
    {
        this.logger.debug("Updating maps for files");

        maps.clearMap(MAP_FOLDER);
        maps.clearMap(MAP_RAW_FILES);
        maps.clearMap(MAP_PROCESSED_FILES);
        maps.clearMap(MAP_FILES_TOTAL);

         try {
            Document doc = getDocument();
            List<Item> documentNodes = saxon.evaluateXPath(doc.getRootNode(), "/files/folder");

            for (Item node : documentNodes) {

                // get all the expressions taken care of
                String accession = saxon.evaluateXPathSingleAsString((NodeInfo) node, "@accession");
                String folderKind = saxon.evaluateXPathSingleAsString((NodeInfo) node, "@kind");
                maps.setMappedValue(MAP_FOLDER, accession, node);
                //todo: remove redundancy here
                if ("experiment".equals(folderKind)) {
                    maps.setMappedValue(MAP_RAW_FILES, accession, saxon.evaluateXPathSingle((NodeInfo)node, "count(file[@kind = 'raw'])"));
                    maps.setMappedValue(MAP_PROCESSED_FILES, accession, saxon.evaluateXPathSingle((NodeInfo)node, "count(file[@kind = 'processed'])"));
                    maps.setMappedValue(MAP_FILES_TOTAL, accession, saxon.evaluateXPathSingle((NodeInfo)node, "sum(file/@size)"));
                }
            }
            this.logger.debug("Maps updated");
         } catch (XPathException x) {
             throw new RuntimeException(x);
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

    private String getFileLocatingXPQuery( String accession, String kind, String name )
    {
        accession = StringEscapeUtils.escapeXml(accession);
        kind = StringEscapeUtils.escapeXml(kind);
        name = StringEscapeUtils.escapeXml(name);
        return "/files/folder" +
                ( StringUtils.isNotBlank(accession) ? "[@accession = '" + accession + "']" : "" ) +
                "/file[@name = '" + name + "'" +
                ( StringUtils.isNotBlank(kind) ? " and @kind = '" + kind + "'" : "" ) +
                "]";
    }

    // returns true is file is registered in the registry
    public boolean doesExist( String accession, String kind, String name ) throws IOException
    {
        boolean result = false;

        if (StringUtils.isNotBlank(name)) {

            try {
                result = ((BooleanValue) this.saxon.evaluateXPathSingle(
                        getDocument().getRootNode()
                        , "exists(" + getFileLocatingXPQuery(accession, kind, name) + ")"
                )).effectiveBooleanValue();
            } catch (XPathException x) {
                logger.error("Caught an exception:", x);
            }
        }
        return result;
    }

    // returns absolute file location (if file exists, null otherwise) in local filesystem
    public String getLocation( String accession, String kind, String name ) throws IOException
    {
        String location = null;

        if (StringUtils.isNotBlank(name)) {
            try {
                String fileXPQuery = getFileLocatingXPQuery(accession, kind, name);
                String xPathQuery = "concat(" + fileXPQuery + "/../@location, '/', " + fileXPQuery + "/@location)";
                location = this.saxon.evaluateXPathSingleAsString(
                        getDocument().getRootNode()
                        , xPathQuery
                );
            } catch ( XPathException x ) {
                logger.error("Caught an exception:", x);
            }
        }

        return location;
    }
}
