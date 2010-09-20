package uk.ac.ebi.arrayexpress.utils.search;

/*
 * Copyright 2009-2010 European Molecular Biology Laboratory
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

import org.apache.commons.lang.StringUtils;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.Term;
import org.apache.lucene.search.*;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.microarray.ontology.efo.EFONode;
import uk.ac.ebi.microarray.ontology.efo.EFOOntologyHelper;

import java.io.File;
import java.util.Arrays;
import java.util.Map;
import java.util.Set;

public class EFOExpansionLookupIndex implements IEFOExpansionLookup
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private String indexLocation;
    private Directory indexDirectory;

    private EFOOntologyHelper ontology;
    private Set<String> stopWords;
    private Map<String, Set<String>> customSynonyms;

    public EFOExpansionLookupIndex( String indexLocation, Set<String> stopWords )
    {
        this.indexLocation = indexLocation;
        this.stopWords = stopWords;
    }

    public void setOntology( EFOOntologyHelper ontology )
    {
        this.ontology = ontology;
    }

    public void setCustomSynonyms( Map<String, Set<String>> synonyms )
    {
        this.customSynonyms = synonyms;
    }

    public void buildIndex()
    {
        try {
            this.indexDirectory = FSDirectory.open(new File(this.indexLocation));
            IndexWriter w = createIndex(this.indexDirectory, new LowercaseAnalyzer());

            this.logger.debug("Building expansion lookup index");
            addNodeAndChildren(this.ontology.getEfoMap().get(EFOOntologyHelper.EFO_ROOT_ID), this.ontology, w);
            commitIndex(w);
            this.logger.debug("Building completed");
        } catch (Exception x) {
            this.logger.error("Caught an exception:", x);
        }

    }

    private void addNodeAndChildren( EFONode node, EFOOntologyHelper ontology, IndexWriter w )
    {
        if (null != node) {
            addNodeToIndex(node, ontology, w);
            for (EFONode child : node.getChildren()) {
                addNodeAndChildren(child, ontology, w);
            }
        }
    }

    private void addNodeToIndex( EFONode node, EFOOntologyHelper ontology, IndexWriter w )
    {
        String term = node.getTerm();
        Set<String> synonyms = node.getAlternativeTerms();
        Set<String> childTerms = ontology.getTerms(node.getId(), EFOOntologyHelper.INCLUDE_CHILDREN);

        if (null != this.customSynonyms) {
            for (String syn : synonyms) {
                if (null != syn && customSynonyms.containsKey(syn.toLowerCase())) {
                    synonyms.addAll(customSynonyms.get(syn.toLowerCase()));
                }
            }

            for (String child : childTerms) {
                if (null != child && customSynonyms.containsKey(child.toLowerCase())) {
                    childTerms.addAll(customSynonyms.get(child.toLowerCase()));
                }
            }
        }
        if (isStopTerm(term)) {
            this.logger.debug("Term [{}] is a stop-word, skipping", term);
        } else {

            if (synonyms.size() > 0 || childTerms.size() > 0) {

                Document d = new Document();

                for (String syn : synonyms) {
                    if (childTerms.contains(syn)) {
                        this.logger.debug("Synonym [{}] for term [{}] is present as a child term itelf, skipping", syn, term);
                    } else if (isStopExpansionTerm(syn)) {
                        this.logger.debug("Synonym [{}] for term [{}] is a stop-word, skipping", syn, term);
                    } else {
                        addIndexField(d, "term", syn, true, true);
                    }
                }

                for (String efoTerm : childTerms) {
                    if (isStopExpansionTerm(efoTerm)) {
                        this.logger.debug("Child EFO term [{}] for term [{}] is a stop-word, skipping", efoTerm, term);
                    } else {
                        addIndexField(d, "efo", efoTerm, false, true);
                    }
                }

                addIndexField(d, "term", term, true, true);
                addIndexDocument(w, d);
            }
        }
    }

    public EFOExpansionTerms getExpansionTerms( Query origQuery )
    {
        EFOExpansionTerms expansion = new EFOExpansionTerms();

        try {
            IndexReader ir = IndexReader.open(this.indexDirectory, true);

            // to show _all_ available nodes
            IndexSearcher isearcher = new IndexSearcher(ir);
            Query q = overrideQueryField(origQuery, "term");
            this.logger.debug("Looking up synonyms for query [{}]", q.toString());

            TopDocs hits = isearcher.search(q, 128); // todo: wtf is this hardcoded?
            this.logger.debug("Query returned [{}] hits", hits.totalHits);

            for (ScoreDoc d : hits.scoreDocs) {
                Document doc = isearcher.doc(d.doc);
                String[] terms = doc.getValues("term");
                String[] efo = doc.getValues("efo");
                this.logger.debug("Synonyms [{}], EFO Terms [{}]", StringUtils.join(terms, ", "), StringUtils.join(efo, ", "));
                if (0 != terms.length) {
                    expansion.synonyms.addAll(Arrays.asList(terms));
                }

                if (0 != efo.length) {
                    expansion.efo.addAll(Arrays.asList(efo));
                }
            }

            isearcher.close();
            ir.close();
        } catch (Exception x) {
            this.logger.error("Caught an exception:", x);
        }

        return expansion;
    }



    private IndexWriter createIndex( Directory indexDirectory, Analyzer analyzer )
    {
        IndexWriter iwriter = null;
        try {
            iwriter = new IndexWriter(indexDirectory, analyzer, true, IndexWriter.MaxFieldLength.UNLIMITED);
        } catch (Exception x) {
            this.logger.error("Caught an exception:", x);
        }

        return iwriter;
    }

    private void addIndexField( Document document, String name, String value, boolean shouldAnalyze, boolean shouldStore )
    {
        value = value.replaceAll("[^\\d\\w-]", " ").toLowerCase();
        document.add(
                new Field(
                        name
                        , value
                        , shouldStore ? Field.Store.YES : Field.Store.NO
                        , shouldAnalyze ? Field.Index.ANALYZED : Field.Index.NOT_ANALYZED
                        , Field.TermVector.NO
                )
        );
    }

    private void addIndexDocument( IndexWriter iwriter, Document document )
    {
        try {
            iwriter.addDocument(document);
        } catch (Exception x) {
            this.logger.error("Caught an exception:", x);
        }
    }

    private void commitIndex( IndexWriter iwriter )
    {
        try {
            iwriter.optimize();
            iwriter.commit();
            iwriter.close();
        } catch (Exception x) {
            this.logger.error("Caught an exception:", x);
        }
    }

    private Query overrideQueryField( Query origQuery, String fieldName )
    {
        Query query = new TermQuery(new Term(""));

        try {
            if (origQuery instanceof PrefixQuery) {
                Term term = ((PrefixQuery)origQuery).getPrefix();
                query = new PrefixQuery(new Term(fieldName, term.text()));
            } else if (origQuery instanceof WildcardQuery) {
                Term term = ((WildcardQuery)origQuery).getTerm();
                query = new WildcardQuery(new Term(fieldName, term.text()));
            } else if (origQuery instanceof TermRangeQuery) {
                TermRangeQuery trq = (TermRangeQuery)origQuery;
                query = new TermRangeQuery(fieldName, trq.getLowerTerm(), trq.getUpperTerm(), trq.includesLower(), trq.includesUpper());
            } else if (origQuery instanceof FuzzyQuery) {
                Term term = ((FuzzyQuery)origQuery).getTerm();
                query = new FuzzyQuery(new Term(fieldName, term.text()));
            } else if (origQuery instanceof TermQuery) {
                Term term = ((TermQuery)origQuery).getTerm();
                query = new TermQuery(new Term(fieldName, term.text()));
            } else if (origQuery instanceof PhraseQuery) {
                Term[] terms = ((PhraseQuery)origQuery).getTerms();
                StringBuilder text = new StringBuilder();
                for (Term t : terms) {
                    text.append(t.text()).append(' ');
                }
                query = new TermQuery(new Term(fieldName, text.toString().trim()));
            } else {
                this.logger.error("Unsupported query type [{}]", origQuery.getClass().getCanonicalName());
            }
        } catch (Exception x) {
            this.logger.error("Caught an exception:", x);
        }


        return query;
    }

    private boolean isStopTerm( String str )
    {
        return null == str || str.length() < 3 || stopWords.contains(str.toLowerCase());
    }

    private boolean isStopExpansionTerm( String str )
    {
        return isStopTerm(str) || str.matches(".*(\\s\\(.+\\)|\\s\\[.+\\]|,\\s|\\s-\\s|/|NOS).*");
    }


}
