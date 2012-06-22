package uk.ac.ebi.fg.jobs;

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

import org.apache.lucene.queryParser.ParseException;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.utils.efo.IEFO;
import uk.ac.ebi.fg.utils.ApplicationJob;
import uk.ac.ebi.fg.utils.lucene.IndexedDocumentController;
import uk.ac.ebi.fg.utils.objects.EFO;
import uk.ac.ebi.fg.utils.objects.StaticIndexedEFODocument;

import java.io.IOException;
import java.util.*;

/**
 * Stores required EFO information in lucene index
 */
public class LuceneEFOIndexJob extends ApplicationJob
{
    private IEFO efo = EFO.getEfo();
    private Map<String, Map<String, Set<String>>> labelToClassMap = new HashMap<String, Map<String, Set<String>>>();   // className, uri, alternative names
    private IndexedDocumentController indexer;
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public LuceneEFOIndexJob()
    {
    }

    /**
     * Creates lucene indexed EFO that is stored in RAM
     *
     * @param jobExecutionContext
     * @throws JobExecutionException
     * @throws ParseException
     * @throws IOException
     */
    public void doExecute( JobExecutionContext jobExecutionContext ) throws JobExecutionException, ParseException, IOException
    {
        init();
        indexEFOLabels();

        EFO.setEfo(null);
    }

    /**
     * Stores extracted EFO information in lucene index
     *
     * @throws IOException
     */
    private void indexEFOLabels() throws IOException
    {
        logger.info("Indexing started");

        long start = System.currentTimeMillis();

        for (Map.Entry<String, Map<String, Set<String>>> entry : labelToClassMap.entrySet()) {
            Map<String, Set<String>> innerMap = entry.getValue();
            Set<String> uris = innerMap.keySet();
            String uri = null;
            for (String u : uris) {
                uri = u;
                if (uris.size() > 1)
                    logger.warn("Class \'" + entry.getKey() + "\' has " + uris.size() + " uris " + uri);    // todo: requires reporting
            }

            Set<String> altTerms = innerMap.get(uri);

            indexer.addFields(entry.getKey(), uri, altTerms);
        }

        indexer.closeWriter();
        logger.info("Indexing finished in " + (System.currentTimeMillis() - start) + "ms");
    }

    /**
     * Fills up map containing class name, URI and alternative terms
     *
     * @throws IOException
     */
    private void init() throws IOException
    {
        indexer = new IndexedDocumentController();
        StaticIndexedEFODocument.setDoc(indexer);

        for (String uri : efo.getMap().keySet()) {
            if (null == efo.getMap().get(uri).getTerm()) {
                logger.warn("URI " + uri + " has no terms");
                continue;
            }

            if (efo.getMap().get(uri).getTerm().toLowerCase().startsWith("obsolete")) {
                logger.warn("Found obsolete class: " + uri + " ; " + efo.getMap().get(uri).getTerm());
                continue;
            }

            String className = getClassName(uri);

            Set<String> altTerms = new TreeSet<String>();
            for (String name : getClassAlternativeNames(uri))
                altTerms.add(name);

            if (!labelToClassMap.containsKey(className))
                labelToClassMap.put(className, new HashMap<String, Set<String>>());

            labelToClassMap.get(className).put(uri, altTerms);
        }
    }

    /**
     * Retrieves class name of specified URI
     *
     * @param uri
     * @return
     */
    private synchronized String getClassName( String uri )
    {
        String term = null;
        for (String className : efo.getTerms(uri, IEFO.INCLUDE_SELF))
            term = className;

        return term;
    }

    /**
     * Retrieves alternative names of specified URI
     *
     * @param uri
     * @return
     */
    private synchronized List<String> getClassAlternativeNames( String uri )
    {
        List<String> results = new ArrayList<String>();
        results.addAll(efo.getTerms(uri, IEFO.INCLUDE_ALT_TERMS));

        return results;
    }
}
