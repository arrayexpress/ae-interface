package uk.ac.ebi.arrayexpress.utils.saxon.search;

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
import net.sf.saxon.sxpath.XPathExpression;
import net.sf.saxon.trans.XPathException;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.NumericField;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.store.Directory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class Indexer
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private IndexEnvironment env;
    private SaxonEngine saxon;

    private Map<String, XPathExpression> fieldXpe = new HashMap<>();

    public Indexer( IndexEnvironment env, SaxonEngine saxon )
    {
        this.env = env;
        this.saxon = saxon;
    }

    public List<NodeInfo> index( DocumentInfo document )
    {
        List<NodeInfo> indexedNodes = null;

        try {
            List documentNodes = saxon.evaluateXPath(document, this.env.indexDocumentPath);
            indexedNodes = new ArrayList<>(documentNodes.size());

            for (IndexEnvironment.FieldInfo field : this.env.fields.values()) {
                fieldXpe.put(field.name, saxon.getXPathExpression(field.path));
            }

            IndexWriter w = createIndex(this.env.indexDirectory, this.env.indexAnalyzer);

            for (Object node : documentNodes) {
                Document d = new Document();

                // get all the fields taken care of
                for (IndexEnvironment.FieldInfo field : this.env.fields.values()) {
                    try {
                        List<Object> values = fieldXpe.get(field.name).evaluate((NodeInfo)node);
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
                        }
                    } catch (XPathException x) {
                        logger.error("Caught an exception while indexing expression [" + field.path + "] for document [" + ((NodeInfo)node).getStringValue().substring(0, 20) + "...]", x);
                    }
                }

                addIndexDocument(w, d);
                // append node to the list
                indexedNodes.add((NodeInfo)node);
            }
            commitIndex(w);

        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }

        return indexedNodes;
    }


    private IndexWriter createIndex( Directory indexDirectory, Analyzer analyzer )
    {
        IndexWriter iwriter = null;
        try {
            iwriter = new IndexWriter(indexDirectory, analyzer, true, IndexWriter.MaxFieldLength.UNLIMITED);
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }

        return iwriter;
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
        } else if (null != value ) {
            String stringValue = value.toString();
            boolValue = StringTools.stringToBoolean(stringValue);
            logger.warn("Not sure if I handle string value [{}] for the field [{}] correctly, relying on Object.toString()", stringValue, name);
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

    private void addIndexDocument( IndexWriter iwriter, Document document )
    {
        try {
            iwriter.addDocument(document);
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }
    }

    private void commitIndex( IndexWriter iwriter )
    {
        try {
            iwriter.optimize();
            iwriter.commit();
            iwriter.close();
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }
    }
}
