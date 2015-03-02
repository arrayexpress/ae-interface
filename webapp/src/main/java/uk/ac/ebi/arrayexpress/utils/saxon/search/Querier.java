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

import net.sf.saxon.om.NodeInfo;
import org.apache.lucene.index.*;
import org.apache.lucene.search.*;
import org.apache.lucene.util.BytesRef;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class Querier {
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private IndexEnvironment env;

    public Querier(IndexEnvironment env) {
        this.env = env;
    }

    public List<String> getTerms(String fieldName, int minFreq) throws IOException {
        List<String> termsList = new ArrayList<>();

        try (IndexReader reader = DirectoryReader.open(this.env.indexDirectory)) {
            Terms terms = MultiFields.getTerms(reader, fieldName);
            if (null != terms) {
                TermsEnum iterator = terms.iterator(null);
                BytesRef byteRef;
                while((byteRef = iterator.next()) != null) {
                    if (iterator.docFreq() >= minFreq) {
                        termsList.add(byteRef.utf8ToString());
                    }
                }
            }
        }
        return termsList;
    }

    public void dumpTerms(String fieldName) throws IOException {
        try (IndexReader reader = DirectoryReader.open(this.env.indexDirectory)) {
            Terms terms = MultiFields.getTerms(reader, fieldName);
            if (null != terms) {
                File f = new File(System.getProperty("java.io.tmpdir"), fieldName + "_terms.txt");
                try (BufferedWriter w = new BufferedWriter(new FileWriter(f))) {
                    StringBuilder sb = new StringBuilder();
                    TermsEnum iterator = terms.iterator(null);
                    BytesRef byteRef;
                    while ((byteRef = iterator.next()) != null) {
                        sb.append(iterator.docFreq()).append('\t').append(byteRef.utf8ToString()).append(StringTools.EOL);
                    }
                    w.write(sb.toString());
                }
            }
        }
    }

    public Integer getDocCount(Query query) throws IOException {
        try (IndexReader reader = DirectoryReader.open(this.env.indexDirectory)) {
            IndexSearcher searcher = new IndexSearcher(reader);

            // +1 is a trick to prevent from having an exception thrown if documentNodes.size() value is 0
            TopDocs hits = searcher.search(query, this.env.documentNodes.size() + 1);


            return hits.totalHits;
        }
    }

    public List<NodeInfo> query(Query query) throws IOException {
        try (IndexReader reader = DirectoryReader.open(this.env.indexDirectory)) {
            LeafReader leafReader = SlowCompositeReaderWrapper.wrap(reader);
            IndexSearcher searcher = new IndexSearcher(reader);
            // empty query returns everything
            if (query instanceof BooleanQuery && ((BooleanQuery) query).clauses().isEmpty()) {
                logger.info("Empty search, returned all [{}] documents", this.env.documentNodes.size());
                return this.env.documentNodes;
            }
            logger.info("Search of index [{}] with query [{}] started", env.indexId, query.toString());
            TopDocs hits = searcher.search(
                    new ConstantScoreQuery(query),
                    this.env.documentNodes.size() + 1
            );
            logger.info("Search reported [{}] matches", hits.totalHits);
            final List<NodeInfo> matchingNodes = new ArrayList<>(hits.totalHits);
            final NumericDocValues ids = leafReader.getNumericDocValues("docId");
            for (ScoreDoc d : hits.scoreDocs) {
                matchingNodes.add(
                        this.env.documentNodes.get(
                                (int)ids.get(d.doc)
                        )
                );
            }
//            searcher.search(query, new Collector() {
//                public LeafCollector getLeafCollector(LeafReaderContext context)
//                        throws IOException {
//                    return new LeafCollector() {
//
//                        // ignore scorer
//                        public void setScorer(Scorer scorer) throws IOException {
//                        }
//
//                        public void collect(int doc) throws IOException {
//                            matchingNodes.add(
//                                    env.documentNodes.get(
//                                            (int)ids.get(doc)
//                                    )
//                            );
//                        }
//                    };
//                }
//            });
            logger.info("Search completed", matchingNodes.size());

            return matchingNodes;
            /*
            // to show _all_ available nodes
            // +1 is a trick to prevent from having an exception thrown if documentNodes.size() value is 0
            TopDocs hits = searcher.search(query, this.env.documentNodes.size() + 1);
            logger.info("Search of index [" + this.env.indexId + "] with query [{}] returned [{}] hits", query.toString(), hits.totalHits);

            result = new ArrayList<>(hits.totalHits);
            for (ScoreDoc d : hits.scoreDocs) {
                Document doc = searcher.doc(d.doc);
                result.add(
                        this.env.documentNodes.get(
                                doc.getField(Indexer.NAME_INDEX)
                                        .numericValue()
                                        .intValue()
                        )
                );
            }
            */
        }
    }

    public List<NodeInfo> query(QueryInfo queryInfo) throws IOException {
        return query(queryInfo.getQuery());
    }
}
