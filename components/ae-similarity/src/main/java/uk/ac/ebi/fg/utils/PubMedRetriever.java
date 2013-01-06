package uk.ac.ebi.fg.utils;

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
import net.sf.saxon.om.NodeInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.fg.utils.saxon.IXPathEngine;

import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;

/**
 * Retrieves similar publication ids
 */
public class PubMedRetriever
{
    private IXPathEngine engine;
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public PubMedRetriever( IXPathEngine eng )
    {
        this.engine = eng;
    }

    /**
     * @param sourceURL     base download link
     * @param publicationId publication id
     * @return PubMed ids
     */
    public SortedSet<String> getSimilars( String sourceURL, String publicationId )
    {
        SortedSet<String> result = null;
        HttpRetriever retriever = new HttpRetriever();
        try {
            DocumentInfo similarDoc = engine.buildDocument(retriever.getPage(sourceURL + publicationId));
            List nodes = engine.evaluateXPath(similarDoc, "/eLinkResult/LinkSet/LinkSetDb[LinkName = 'pubmed_pubmed_five']/Link/Id[string()!=\'" + publicationId + "\']");

//            List nodes = engine.evaluateXPath(similarDoc, "//LinkSetDb/Link[../LinkName/text()='pubmed_pubmed_citedin'] |" +
//                    "//LinkSetDb/Link[../LinkName/text()='pubmed_pubmed'] ");
            retriever.closeConnection();

            result = new TreeSet<String>();
            for (Object node : nodes) {
                result.add(((NodeInfo) node).getStringValue());
            }
        } catch (Throwable ex) {
            logger.warn("URL: " + sourceURL + publicationId + " error: " + ex.getMessage());
        } finally {
            return result;
        }
    }
}
