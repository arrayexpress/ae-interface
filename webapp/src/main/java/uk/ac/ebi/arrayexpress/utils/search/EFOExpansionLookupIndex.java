package uk.ac.ebi.arrayexpress.utils.search;

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
import uk.ac.ebi.arrayexpress.utils.efo.EFONode;
import uk.ac.ebi.arrayexpress.utils.efo.IEFO;

import java.io.File;
import java.io.IOException;
import java.util.*;

public class EFOExpansionLookupIndex implements IEFOExpansionLookup
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private FSDirectory indexDirectory;

    private IEFO efo;
    private Set<String> stopWords;
    private Map<String, Set<String>> customSynonyms;

    // maximum number of index documents to be processed; in reality shouldn't be more than 2
    private static final int MAX_INDEX_HITS = 16;

    public EFOExpansionLookupIndex( String indexLocation, Set<String> stopWords ) throws IOException
    {
        this.stopWords = stopWords;
        this.indexDirectory = FSDirectory.open(new File(indexLocation));
    }

    private IEFO getEfo()
    {
        return this.efo;
    }

    public void setEfo( IEFO efo )
    {
        this.efo = efo;
    }

    public void setCustomSynonyms( Map<String, Set<String>> synonyms )
    {
        this.customSynonyms = synonyms;
    }

    public void buildIndex() throws InterruptedException
    {
        try {
            IndexWriter w = createIndex(this.indexDirectory, new LowercaseAnalyzer());

            this.logger.debug("Building expansion lookup index");
            addNodeAndChildren(this.efo.getMap().get(IEFO.ROOT_ID), w);
            addCustomSynonyms(w);
            commitIndex(w);
            this.logger.debug("Building completed");
        } catch (InterruptedException x) {
            throw x;
        } catch (Exception x) {
            this.logger.error("Caught an exception:", x);
        }

    }

    private void addCustomSynonyms( IndexWriter w ) throws InterruptedException
    {
        // here we add all custom synonyms so those that weren't added during EFO processing
        //  get a chance to be included, too. don't worry about duplication, dupes will be removed during retrieval
        if (null != this.customSynonyms) {
            Set<String> addedTerms = new TreeSet<String>(String.CASE_INSENSITIVE_ORDER);
            for (String term : this.customSynonyms.keySet()) {
                if (!addedTerms.contains(term)) {
                    Document d = new Document();

                    Set<String> syns = this.customSynonyms.get(term);
                    for (String syn : syns) {
                        addIndexField(d, "term", syn, true, true);

                    }
                    addIndexDocument(w, d);
                    addedTerms.addAll(syns);
                }
            }
        }
    }

    private void addNodeAndChildren( EFONode node, IndexWriter w ) throws InterruptedException
    {
        Thread.sleep(1);
        if (null != node) {
            addNodeToIndex(node, w);
            for (EFONode child : node.getChildren()) {
                addNodeAndChildren(child, w);
            }
        }
    }

    private void addNodeToIndex( EFONode node, IndexWriter w ) throws InterruptedException
    {
        String term = node.getTerm();

        if (null != term && !isStopTerm(term)) {
            Set<String> synonyms = node.getAlternativeTerms();

            // if the node represents organizational class, just include its synonyms, but not children
            Set<String> childTerms =
                    node.isOrganizationalClass()
                    ? new HashSet<String>()
                    : getEfo().getTerms(node.getId(), IEFO.INCLUDE_CHILDREN);

            // here we add custom synonyms to EFO synonyms/child terms and their synonyms
            if (null != this.customSynonyms) {
                for (String syn : new HashSet<String>(synonyms)) {
                    if (null != syn && this.customSynonyms.containsKey(syn)) {
                        synonyms.addAll(this.customSynonyms.get(syn));
                    }
                }

                if (this.customSynonyms.containsKey(term)) {
                    synonyms.addAll(this.customSynonyms.get(term));
                }

                for (String child : new HashSet<String>(childTerms)) {
                    if (null != child && this.customSynonyms.containsKey(child)) {
                        childTerms.addAll(this.customSynonyms.get(child));
                    }
                }
            }
            if (synonyms.contains(term)) {
                synonyms.remove(term);
            }

            if (synonyms.size() > 0 || childTerms.size() > 0) {

                Document d = new Document();

                for (String syn : synonyms) {
                    if (childTerms.contains(syn)) {
                        // this.logger.debug("Synonym [{}] for term [{}] is present as a child term itelf, skipping", syn, term);
                    } else if (isStopExpansionTerm(syn)) {
                        // this.logger.debug("Synonym [{}] for term [{}] is a stop-word, skipping", syn, term);
                    } else {
                        addIndexField(d, "term", syn, true, true);
                    }
                }

                for (String efoTerm : childTerms) {
                    if (isStopExpansionTerm(efoTerm)) {
                        // this.logger.debug("Child EFO term [{}] for term [{}] is a stop-word, skipping", efoTerm, term);
                    } else {
                        addIndexField(d, "efo", efoTerm, false, true);
                    }
                }

                addIndexField(d, "term", term, true, true);
                addIndexDocument(w, d);
            }
        }
    }

    public EFOExpansionTerms getExpansionTerms( Query origQuery ) throws IOException
    {
        EFOExpansionTerms expansion = new EFOExpansionTerms();

        if (this.indexDirectory.getFile().exists()) {
            IndexReader reader = null;
            IndexSearcher searcher = null;
            try {
                reader = IndexReader.open(this.indexDirectory, true);

                // to show _all_ available nodes
                searcher = new IndexSearcher(reader);
                Query q = overrideQueryField(origQuery, "term");

                TopDocs hits = searcher.search(q, MAX_INDEX_HITS);
                this.logger.debug("Expansion lookup for query [{}] returned [{}] hits", q.toString(), hits.totalHits);

                for (ScoreDoc d : hits.scoreDocs) {
                    Document doc = searcher.doc(d.doc);
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
            } finally {
                if (null != searcher) {
                    searcher.close();
                }

                if (null != reader) {
                    reader.close();
                }
            }
        }

        return expansion;
    }

    private IndexWriter createIndex( Directory indexDirectory, Analyzer analyzer ) throws InterruptedException
    {
        IndexWriter iwriter = null;
        try {
            Thread.sleep(1);
            iwriter = new IndexWriter(indexDirectory, analyzer, true, IndexWriter.MaxFieldLength.UNLIMITED);
        } catch (InterruptedException x) {
            throw x;
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

    private void addIndexDocument( IndexWriter iwriter, Document document ) throws InterruptedException
    {
        try {
            Thread.sleep(1);
            iwriter.addDocument(document);
        } catch (InterruptedException x) {
            throw x;
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
