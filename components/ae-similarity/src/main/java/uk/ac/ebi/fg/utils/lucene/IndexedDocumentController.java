package uk.ac.ebi.fg.utils.lucene;

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

import org.apache.lucene.analysis.KeywordAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.RAMDirectory;
import org.apache.lucene.util.Version;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.utils.efo.EFONode;
import uk.ac.ebi.arrayexpress.utils.efo.IEFO;
import uk.ac.ebi.fg.utils.objects.EFO;
import uk.ac.ebi.fg.utils.objects.EfoTerm;

import java.io.IOException;
import java.util.*;

/**
 * Facilitates lucene document management
 */
public class IndexedDocumentController
{
    private Directory ramDirectory;
    private Document doc;
    private IndexWriter writer;
    private String className = "name";
    private String classNameAlternatives = "nameAlternative";
    private String URI = "URI";
    private final Logger logger = LoggerFactory.getLogger(getClass());
    private IEFO efo;

    // todo: remove temporary data structures after testing
    private Map<String, Set<String>> loggedURIsAndTerms = new HashMap<String, Set<String>>();

    public IndexedDocumentController() throws IOException
    {
        ramDirectory = new RAMDirectory(); // store documents in RAM
        efo = EFO.getEfo();
        writer = getWriter();
    }

    /**
     * Closes writer after documents have been added to lucene index
     *
     * @throws IOException
     */
    public void closeWriter() throws IOException
    {
        writer.close();
    }

    /**
     * Creates a document with fields and adds to document writer.
     * After adding all required fields closewriter() needs to be called
     *
     * @param term     Class name
     * @param uri      URI
     * @param altTerms Alternative class names
     * @throws IOException
     */
    public synchronized void addFields( String term, String uri, Set<String> altTerms ) throws IOException
    {
        String cleanTerm = normalizeTerm(term);

        if (cleanTerm != null) {
            doc = new Document();

            doc.add(new Field(className, cleanTerm, Field.Store.YES, Field.Index.ANALYZED));
            for (String altTerm : altTerms) {
                String cleanAlt = normalizeTerm(altTerm);
                if (cleanAlt != null && !cleanAlt.equals(cleanTerm))
                    doc.add(new Field(classNameAlternatives, cleanAlt, Field.Store.YES, Field.Index.ANALYZED));
            }

            doc.add(new Field(URI, uri, Field.Store.YES, Field.Index.NOT_ANALYZED));

            writer.addDocument(doc);
        }
    }

    /**
     * Creates a new writer
     *
     * @return
     * @throws IOException
     */
    private IndexWriter getWriter() throws IOException
    {
        return new IndexWriter(ramDirectory,
                new IndexWriterConfig(Version.LUCENE_35, new KeywordAnalyzer())
        );
    }

    /**
     * Tries to find term in lucene index
     *
     * @param term Class name
     * @return URI or null if nothing was found
     * @throws IOException
     * @throws ParseException
     */
    public String findTerm( String term ) throws IOException, ParseException
    {
        return findTerm(term, Integer.MAX_VALUE);
    }

    /**
     * Tries to find term in lucene index with limited number of matches
     *
     * @param term  Class name
     * @param limit Number of allowed matches
     * @return URI or null if nothing was found or exceeds limit
     * @throws IOException
     * @throws ParseException
     */
    public String findTerm( String term, int limit ) throws IOException, ParseException
    {
        limit = (limit >= 1) ? limit : Integer.MAX_VALUE;
        TopDocs topDocs = getMatchingDocuments(term);
        String uri = null;

        if (topDocs != null) {
            // try to decide which term is the best match
            if (topDocs.totalHits > 1) {
                uri = findBestMatch(topDocs, term);
            }

            if (topDocs.totalHits > 0 && topDocs.totalHits <= limit && uri == null) {
                // logging todo: remove
                if (topDocs.totalHits > 1 && !loggedURIsAndTerms.containsKey(term)) {  // todo: remove logging structure
                    Set<String> uriSet = new TreeSet<String>();

                    for (ScoreDoc doc : topDocs.scoreDocs) {
                        Document document = getDoc(doc.doc);
                        uriSet.add(document.get(URI));
                    }

                    loggedURIsAndTerms.put(term, uriSet);
                }

                for (ScoreDoc doc : topDocs.scoreDocs) {
                    Document document = getDoc(doc.doc);

                    uri = document.get(URI);
                    break;     // uses the first match when there are several options
                }

            }
        }

        return uri;
    }

    /**
     * Finds documents that contain term. First looks for class names afterwards for alternative terms.
     *
     * @param term search term
     * @return object with all documents containing the term
     * @throws IOException
     * @throws ParseException
     */
    private TopDocs getMatchingDocuments( String term ) throws IOException, ParseException
    {
        String cleanTerm = normalizeTerm(term);
        TopDocs topDocs = null;

        if (cleanTerm != null) {
            IndexReader reader = IndexReader.open(ramDirectory);
            IndexSearcher searcher = new IndexSearcher(reader);
            QueryParser parser = new QueryParser(Version.LUCENE_35, className, new KeywordAnalyzer());
            Query query = parser.parse(cleanTerm);
            topDocs = searcher.search(query, 10);

            // search alternative terms
            if (topDocs.totalHits == 0) {
                // logger.debug("0 matches for: " + term);

                parser = new QueryParser(Version.LUCENE_35, classNameAlternatives, new KeywordAnalyzer());
                query = parser.parse(cleanTerm);
                topDocs = searcher.search(query, 10);
                // logger.debug("Number of alternative term matches: " + topDocs.totalHits);
            }
            searcher.close();
            reader.close();
        }

        return topDocs;
    }

    /**
     * Retrieves document from lucene index with document index
     *
     * @param index document index
     * @return document
     * @throws IOException
     */
    public Document getDoc( int index ) throws IOException
    {
        IndexReader reader = IndexReader.open(ramDirectory);
        IndexSearcher searcher = new IndexSearcher(reader);

        Document doc = searcher.doc(index);

        searcher.close();

        return doc;
    }

    /**
     * Removes unwanted characters
     *
     * @param term
     * @return
     */
    private String normalizeTerm( String term )
    {
        String normalizedTerm = term.replaceAll("[^A-Za-z0-9]", "").toLowerCase();

        if (normalizedTerm.length() <= 2 || normalizedTerm.equals(""))    // todo: skip integers??
            return null;

        return normalizedTerm;
    }

    /**
     * Finds EFO URIs for categories and terms that can be found in EFO
     *
     * @param categoriesWithTerms categories with set of terms
     * @return URIs with search Strings
     */
    public SortedSet<EfoTerm> getURIs( Map<String, List<String>> categoriesWithTerms )
    {
        SortedSet<EfoTerm> urisWithTerms = new TreeSet<EfoTerm>();

        try {
            for (Map.Entry<String, List<String>> categoryWithTerms : categoriesWithTerms.entrySet()) {
                String category = categoryWithTerms.getKey();
                String categoryURI = findTerm(category);
                List<String> values = categoryWithTerms.getValue();

                // get all unique matches
                for (String value : values) {
                    String uri = findTerm(value, 1);  // 1 unique match only
                    if (uri != null) {
                        urisWithTerms.add(new EfoTerm(uri, value));
                    }
                }

                // category + value matches
                if (categoryURI != null) {
                    EFONode node = efo.getMap().get(categoryURI);
                    Set<String> childrenURIs = getAllChildURIs(node);

                    for (String value : categoryWithTerms.getValue()) {
                        String uri = findTerm(value);
                        if (uri != null) {
                            if (childrenURIs.contains(uri))  // 100% match (found value as child node of category in efo)
                                urisWithTerms.add(new EfoTerm(uri, value));
                        }
                    }
                }
            }

        } catch (Exception ex) {
            logger.error(ex.getMessage());
            ex.printStackTrace();
        }

        return urisWithTerms;
    }

    /**
     * Goes through EFO map recursively retrieving all child URIs
     *
     * @param parent
     * @return child URIs
     */
    private Set<String> getAllChildURIs( EFONode parent )
    {
        Set<String> allChildURIs = new TreeSet<String>();

        if (parent.getChildren().size() != 0) {
            for (EFONode childNode : parent.getChildren()) {
                allChildURIs.add(childNode.getId());
                allChildURIs.addAll(getAllChildURIs(childNode));
            }
        }

        return allChildURIs;
    }

    /**
     * Returns all terms that have more than 1 URI
     *
     * @return map with terms and URIs
     */
    public Map<String, Set<String>> getLoggedURIsAndTerms()
    {
        return loggedURIsAndTerms;
    }

    /**
     * Tries to resolve multiple matches by looking for parent-child relationship between found URIs in EFO and
     * returning parent URI
     *
     * @param topDocs documents that contain the term
     * @param term    search term
     * @return URI or null if relationship was not found
     * @throws IOException
     */
    private String findBestMatch( TopDocs topDocs, String term ) throws IOException  // todo: term used only for better logging
    {
        String bestMatch = null;

        String tempURI = null;
        Set<String> tempChildURIs = new TreeSet<String>();

        for (ScoreDoc doc : topDocs.scoreDocs) {
            Document document = getDoc(doc.doc);

            if (!tempChildURIs.isEmpty()) {
                if (tempChildURIs.contains(document.get(URI))) {
                    logger.info("Chose " + tempURI + " over " + document.get(URI) + " for term " + term);
                    bestMatch = tempURI;
                    continue;
                } else if (getAllChildURIs(efo.getMap().get(document.get(URI))).contains(tempURI)) {
                    logger.info("Chose " + document.get(URI) + " over " + tempURI + " for term " + term);
                    bestMatch = tempURI = document.get(URI);
                    tempChildURIs = getAllChildURIs(efo.getMap().get(document.get(URI)));
                }
            }

            tempURI = document.get(URI);
            tempChildURIs = getAllChildURIs(efo.getMap().get(tempURI));
        }

        return bestMatch;
    }
}
