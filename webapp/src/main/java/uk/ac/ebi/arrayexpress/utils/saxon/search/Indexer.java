package uk.ac.ebi.arrayexpress.utils.saxon.search;

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
import net.sf.saxon.om.Item;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.BooleanValue;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.NumericField;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.store.Directory;
import org.apache.lucene.util.Version;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.io.IOException;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;


public class Indexer
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private IndexEnvironment env;
    private SaxonEngine saxon;

    public Indexer( IndexEnvironment env, SaxonEngine saxon )
    {
        this.env = env;
        this.saxon = saxon;
    }

    public List<NodeInfo> index( DocumentInfo document ) throws IndexerException, InterruptedException
    {
        try (IndexWriter w = createIndex(this.env.indexDirectory, this.env.indexAnalyzer)) {

            List documentNodes = saxon.evaluateXPath(document, this.env.indexDocumentPath);
            List<NodeInfo> indexedNodes = new ArrayList<>(documentNodes.size());

            for (Object node : documentNodes) {
                Document d = new Document();

                // get all the fields taken care of
                for (IndexEnvironment.FieldInfo field : this.env.fields.values()) {
                    try {
                        List<Object> values = saxon.evaluateXPath((NodeInfo)node, field.path);
                        for (Object v : values) {
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
                        logger.error("Caught an exception while indexing expression [" + field.path + "] for document [" + ((NodeInfo)node).getStringValue().substring(0, 20) + "...]", x);
                        throw x;
                    }
                }

                w.addDocument(d);
                // append node to the list
                indexedNodes.add((NodeInfo)node);
            }

            w.commit();

            return indexedNodes;
        } catch (IOException|XPathException x) {
            throw new IndexerException(x);
        }
    }


    private IndexWriter createIndex( Directory indexDirectory, Analyzer analyzer ) throws IOException
    {
        IndexWriterConfig config = new IndexWriterConfig(Version.LUCENE_31, analyzer);
        config.setOpenMode(IndexWriterConfig.OpenMode.CREATE);

        return new IndexWriter(indexDirectory, config);
    }

    private void addIndexField( Document document, String name, Object value, boolean shouldAnalyze, boolean shouldStore )
    {
        String stringValue;
        if (value instanceof String) {
            stringValue = (String)value;
        } else if (value instanceof NodeInfo) {
            stringValue = ((NodeInfo)value).getStringValue();
        } else {
            stringValue = value.toString();
            logger.warn("Not sure if I handle string value of [{}] for the field [{}] correctly, relying on Object.toString()", value.getClass().getName(), name);
        }

        document.add(new Field(name, stringValue, shouldStore ? Field.Store.YES : Field.Store.NO, shouldAnalyze ? Field.Index.ANALYZED : Field.Index.NOT_ANALYZED));
    }

    private void addBooleanIndexField( Document document, String name, Object value )
    {
        Boolean boolValue = null;
        if (value instanceof Boolean) {
            boolValue = (Boolean)value;
        } else if (value instanceof BooleanValue) {
            boolValue = ((BooleanValue)value).getBooleanValue();
        } else if (value instanceof Item) {
            String stringValue = ((Item)value).getStringValue();
            boolValue = StringTools.stringToBoolean(stringValue);
        } else {
            logger.error("Cannot convert value of type [{}] for the field [{}] to boolean", value.getClass(), name);
        }

        document.add(new Field(name, null == boolValue ? "" : boolValue.toString(), Field.Store.NO, Field.Index.NOT_ANALYZED));
    }

    private void addIntIndexField( Document document, String name, Object value )
    {
        Long longValue;
        if (value instanceof BigInteger) {
            longValue = ((BigInteger)value).longValue();
        } else if (value instanceof NodeInfo) {
            longValue = Long.parseLong(((NodeInfo)value).getStringValue());
        } else {
            longValue = Long.parseLong(value.toString());
            logger.warn("Not sure if I handle long value of [{}] for the field [{}] correctly, relying on Object.toString()", value.getClass().getName(), name);
        }
        if (null != longValue) {
            document.add(new NumericField(name).setLongValue(longValue));
        } else {
            logger.warn("Long value of the field [{}] was null", name);
        }
    }
}
