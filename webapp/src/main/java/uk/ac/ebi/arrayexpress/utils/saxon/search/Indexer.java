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

package uk.ac.ebi.arrayexpress.utils.saxon.search;

import net.sf.saxon.om.Item;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.BooleanValue;
import net.sf.saxon.value.Int64Value;
import net.sf.saxon.value.NumericValue;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.document.*;
import org.apache.lucene.facet.FacetField;
import org.apache.lucene.facet.FacetsConfig;
import org.apache.lucene.facet.taxonomy.TaxonomyWriter;
import org.apache.lucene.facet.taxonomy.directory.DirectoryTaxonomyWriter;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexOptions;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.IndexOutput;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


public class Indexer {
    protected final static String DOCID_FIELD = "docId";

    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final IndexEnvironment env;
    private final SaxonEngine saxon;

    public Indexer(IndexEnvironment env, SaxonEngine saxon) {
        this.env = env;
        this.saxon = saxon;
    }

    public List<NodeInfo> index(uk.ac.ebi.arrayexpress.utils.saxon.Document document) throws IndexerException, InterruptedException {
        try {
            if (getDocumentHash().equals(document.getHash())) {
                logger.debug("Existing index found, no need to refresh");
                List documentNodes = saxon.evaluateXPath(document.getRootNode(), this.env.indexDocumentPath);
                List<NodeInfo> indexedNodes = new ArrayList<>(documentNodes.size());

                for (Object node : documentNodes) {
                    indexedNodes.add((NodeInfo) node);
                }
                return indexedNodes;
            }
            try (IndexWriter w = createIndex(env.indexDirectory, env.indexAnalyzer);
                 TaxonomyWriter tw = createFacets(env.facetDirectory)) {
                
                FacetsConfig config = new FacetsConfig();
                for (IndexEnvironment.FieldInfo field : this.env.fields.values()) {
                    if (null != tw && null != field.facet && !field.facet.isEmpty()) {
                        config.setHierarchical(field.facet, false);
                        config.setMultiValued(field.facet, true);
                        config.setIndexFieldName(field.facet, field.name);
                        config.setRequireDimCount(field.facet, false);
                    }
                }
                
                setDocumentHash(document.getHash());

                List documentNodes = saxon.evaluateXPath(document.getRootNode(), this.env.indexDocumentPath);
                List<NodeInfo> indexedNodes = new ArrayList<>(documentNodes.size());

                for (Object node : documentNodes) {
                    Document d = new Document();

                    // get all the fields taken care of
                    for (IndexEnvironment.FieldInfo field : this.env.fields.values()) {
                        try {
                            List<Item> values = saxon.evaluateXPath((NodeInfo) node, field.path);
                            for (Item v : values) {
                                if ("integer".equals(field.type)) {
                                    addLongField(d, field.name, v);
                                } else if ("date".equals(field.type)) {
                                    // todo: addDateIndexField(d, field.name, v);
                                    logger.error("Date fields are not supported yet, field [{}] will not be created", field.name);
                                } else if ("boolean".equals(field.type)) {
                                    addBooleanIndexField(d, field.name, v);
                                } else {
                                    addStringField(d, field.name, v, field.shouldAnalyze, field.shouldStore);
                                }
                                if (null != tw && null != field.facet && !field.facet.isEmpty()) {
                                    addFacetField(d, field.facet, v);
                                }
                                Thread.sleep(0);
                            }
                        } catch (XPathException x) {
                            String expression = ((NodeInfo) node).getStringValue();
                            logger.error("Caught an exception while indexing expression [" + field.path + "] for document [" + expression.substring(0, expression.length() > 20 ? 20 : expression.length()) + "...]", x);
                            throw x;
                        }
                    }
                    addDocIdField(d, indexedNodes.size());
                    if (null != tw) {
                        w.addDocument(config.build(tw, d));
                    } else {
                        w.addDocument(d);
                    }
                    // append node to the list
                    indexedNodes.add((NodeInfo) node);
                }
                w.commit();
                if (null != tw) {
                    tw.commit();
                }
                
                return indexedNodes;
            }
        } catch (IOException | XPathException x) {
            throw new IndexerException(x);
        }
    }


    private IndexWriter createIndex(Directory indexDirectory, Analyzer analyzer) throws IOException {
        IndexWriterConfig config = new IndexWriterConfig(analyzer);
        config.setOpenMode(IndexWriterConfig.OpenMode.CREATE);

        return new IndexWriter(indexDirectory, config);
    }

    private TaxonomyWriter createFacets(Directory facetsDirectory) throws IOException {
        if (null != facetsDirectory) {
            return new DirectoryTaxonomyWriter(facetsDirectory, IndexWriterConfig.OpenMode.CREATE);
        } else {
            return null;
        }
    }

    private void addStringField(Document document, String name, Item value, boolean shouldAnalyze, boolean shouldStore) {
        String stringValue = value.getStringValue();
        FieldType fieldType = new FieldType();
        fieldType.setIndexOptions(IndexOptions.DOCS_AND_FREQS_AND_POSITIONS);
        fieldType.setTokenized(shouldAnalyze);
        fieldType.setStored(shouldStore);
        document.add(new Field(name, stringValue, fieldType));
    }

    private void addFacetField(Document document, String name, Item value) {
        String stringValue = value.getStringValue();
        document.add(new FacetField(name, stringValue));
    }
    
    private void addBooleanIndexField(Document document, String name, Item value) {
        Boolean boolValue;
        if (value instanceof BooleanValue) {
            boolValue = ((BooleanValue) value).getBooleanValue();
        } else {
            String stringValue = value.getStringValue();
            boolValue = StringTools.stringToBoolean(stringValue);
        }

        document.add(new StringField(name, null == boolValue ? "" : boolValue.toString(), Field.Store.NO));
    }

    private void addLongField(Document document, String name, Item value) {
        Long longValue;
        try {
            if (value instanceof Int64Value) {
                longValue = ((Int64Value) value).asBigInteger().longValue();
            } else if (value instanceof NumericValue) {
                longValue = ((NumericValue) value).longValue();
            } else {
                longValue = Long.parseLong(value.getStringValue());
            }
            document.add(new LongField(name, longValue, Field.Store.NO));
        } catch (XPathException x) {
            logger.error("Unable to convert value [" + value.getStringValue() + "]", x);
        }
    }

    private void addDocIdField(Document document, int docId) {
        document.add(new NumericDocValuesField(DOCID_FIELD, docId));
    }

    private void setDocumentHash(String hash) throws IOException {
        Directory dir = this.env.indexDirectory;
        for (String f : dir.listAll()) {
            if (f.endsWith(".hash")) {
                dir.deleteFile(f);
            }
        }
        try (IndexOutput o = dir.createOutput(hash + ".hash", null)) {
            o.close();
        }
    }

    private String getDocumentHash() throws IOException {
        Directory dir = this.env.indexDirectory;
        if (DirectoryReader.indexExists(dir)) {
            for (String f : dir.listAll()) {
                if (f.endsWith(".hash")) {
                    return f.substring(0, f.indexOf(".hash"));
                }
            }
        }
        return "";
    }
}
