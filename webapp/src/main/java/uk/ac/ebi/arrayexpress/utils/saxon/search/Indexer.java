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

import net.sf.saxon.om.DocumentInfo;
import net.sf.saxon.om.Item;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.BooleanValue;
import net.sf.saxon.value.Int64Value;
import net.sf.saxon.value.NumericValue;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.document.*;
import org.apache.lucene.index.IndexOptions;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.store.Directory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


public class Indexer {
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private IndexEnvironment env;
    private SaxonEngine saxon;

    public Indexer(IndexEnvironment env, SaxonEngine saxon) {
        this.env = env;
        this.saxon = saxon;
    }

    public List<NodeInfo> index(DocumentInfo document) throws IndexerException, InterruptedException {
        try (IndexWriter w = createIndex(this.env.indexDirectory, this.env.indexAnalyzer)) {

            List documentNodes = saxon.evaluateXPath(document, this.env.indexDocumentPath);
            List<NodeInfo> indexedNodes = new ArrayList<>(documentNodes.size());

            for (Object node : documentNodes) {
                Document d = new Document();

                // get all the fields taken care of
                for (IndexEnvironment.FieldInfo field : this.env.fields.values()) {
                    try {
                        List<Item> values = saxon.evaluateXPath((NodeInfo) node, field.path);
                        for (Item v : values) {
                            if ("integer".equals(field.type)) {
                                addIntIndexField(d, field.name, v);
                            } else if ("date".equals(field.type)) {
                                // todo: addDateIndexField(d, field.name, v);
                                logger.error("Date fields are not supported yet, field [{}] will not be created", field.name);
                            } else if ("boolean".equals(field.type)) {
                                addBooleanIndexField(d, field.name, v);
                            } else {
                                addIndexField(d, field.name, v, field.shouldAnalyze, field.shouldStore);
                            }
                            Thread.sleep(0);
                        }
                    } catch (XPathException x) {
                        String expression = ((NodeInfo) node).getStringValue();
                        logger.error("Caught an exception while indexing expression [" + field.path + "] for document [" + expression.substring(0, expression.length() > 20 ? 20 : expression.length()) + "...]", x);
                        throw x;
                    }
                }

                w.addDocument(d);
                // append node to the list
                indexedNodes.add((NodeInfo) node);
            }

            w.commit();

            return indexedNodes;
        } catch (IOException | XPathException x) {
            throw new IndexerException(x);
        }
    }


    private IndexWriter createIndex(Directory indexDirectory, Analyzer analyzer) throws IOException {
        IndexWriterConfig config = new IndexWriterConfig(analyzer);
        config.setOpenMode(IndexWriterConfig.OpenMode.CREATE);

        return new IndexWriter(indexDirectory, config);
    }

    private void addIndexField(Document document, String name, Item value, boolean shouldAnalyze, boolean shouldStore) {
        String stringValue = value.getStringValue();
        FieldType fieldType = new FieldType();
        fieldType.setIndexOptions(IndexOptions.DOCS_AND_FREQS_AND_POSITIONS);
        fieldType.setTokenized(shouldAnalyze);
        fieldType.setStored(shouldStore);
        document.add(new Field(name, stringValue, fieldType));
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

    private void addIntIndexField(Document document, String name, Item value) {
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
}
