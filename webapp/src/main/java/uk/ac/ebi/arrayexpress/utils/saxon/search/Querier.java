package uk.ac.ebi.arrayexpress.utils.saxon.search;

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

import net.sf.saxon.om.NodeInfo;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.Term;
import org.apache.lucene.index.TermEnum;
import org.apache.lucene.search.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class Querier
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private IndexEnvironment env;

    public Querier( IndexEnvironment env )
    {
        this.env = env;
    }

    public List<String> getTerms( String fieldName, int minFreq ) throws IOException
    {
        List<String> termsList = new ArrayList<>();

        try (IndexReader reader = IndexReader.open(this.env.indexDirectory); TermEnum terms = reader.terms(new Term(fieldName, ""))) {
            if (null != terms) {
                while (null != terms.term() && fieldName.equals(terms.term().field())) {
                    if (terms.docFreq() >= minFreq) {
                        termsList.add(terms.term().text());
                    }
                    if (!terms.next())
                        break;
                }
                terms.close();
            }
        }

        return termsList;
    }

    public void dumpTerms( String fieldName ) throws IOException
    {
        try (IndexReader reader = IndexReader.open(this.env.indexDirectory); TermEnum terms = reader.terms(new Term(fieldName, ""))) {

            File f = new File(System.getProperty("java.io.tmpdir"), fieldName + "_terms.txt");
            try (BufferedWriter w = new BufferedWriter(new FileWriter(f))) {
                StringBuilder sb = new StringBuilder();
                while (fieldName.equals(terms.term().field())) {
                    sb.append(terms.docFreq()).append('\t').append(terms.term().text()).append(StringTools.EOL);
                    if (!terms.next())
                        break;
                }
                w.write(sb.toString());
            }
        }
    }

    public Integer getDocCount( Query query ) throws IOException
    {
        try (IndexReader reader =  IndexReader.open(this.env.indexDirectory); IndexSearcher searcher = new IndexSearcher(reader)) {

            // +1 is a trick to prevent from having an exception thrown if documentNodes.size() value is 0
            TopDocs hits = searcher.search(query, this.env.documentNodes.size() + 1);


            return hits.totalHits;
        }
    }

    public List<NodeInfo> query( Query query ) throws IOException
    {
        List<NodeInfo> result;

        try (IndexReader reader =  IndexReader.open(this.env.indexDirectory); IndexSearcher searcher = new IndexSearcher(reader)) {

            // empty query returns everything
            if (query instanceof BooleanQuery && ((BooleanQuery)query).clauses().isEmpty()) {
                logger.info("Empty search, returned all [{}] documents", this.env.documentNodes.size());
                return this.env.documentNodes;
            }

            // to show _all_ available nodes
            // +1 is a trick to prevent from having an exception thrown if documentNodes.size() value is 0
            TopDocs hits = searcher.search(query, this.env.documentNodes.size() + 1);
            logger.info("Search of index [" + this.env.indexId + "] with query [{}] returned [{}] hits", query.toString(), hits.totalHits);

            result = new ArrayList<>(hits.totalHits);
            for (ScoreDoc d : hits.scoreDocs) {
                result.add(this.env.documentNodes.get(d.doc));
            }
        }

        return result;
    }

    public List<NodeInfo> query( QueryInfo queryInfo ) throws IOException
    {
        List<NodeInfo> result;

        try (IndexReader reader =  IndexReader.open(this.env.indexDirectory); IndexSearcher searcher = new IndexSearcher(reader)) {

            // empty query returns everything
            if (queryInfo.getQuery() instanceof BooleanQuery && ((BooleanQuery)queryInfo.getQuery()).clauses().isEmpty()) {
                logger.info("Empty search, returned all [{}] documents", this.env.documentNodes.size());
                return this.env.documentNodes;
            }

            // to show _all_ available nodes
            // +1 is a trick to prevent from having an exception thrown if documentNodes.size() value is 0
            TopDocs hits = searcher.search(queryInfo.getQuery(), this.env.documentNodes.size() + 1);
            logger.info("Search of index [" + this.env.indexId + "] with query [{}] returned [{}] hits", queryInfo.getQuery().toString(), hits.totalHits);

            result = new ArrayList<>(hits.totalHits);
            for (ScoreDoc d : hits.scoreDocs) {                       // are in descending order
                result.add(this.env.documentNodes.get(d.doc));
                //queryInfo.putScore(this.env.documentNodes.get(d.doc), d.score);  lucene score is not needed
            }
        }

        return result;
    }
}
