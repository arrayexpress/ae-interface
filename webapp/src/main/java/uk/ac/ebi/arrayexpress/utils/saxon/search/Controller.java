package uk.ac.ebi.arrayexpress.utils.saxon.search;

/*
 * Copyright 2009-2010 Microarray Informatics Group, European Bioinformatics Institute
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

import java.net.URL;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Controller
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private Configuration config;
    private QueryPool queryPool;
    private IQueryExpander queryExpander;
    private IQueryHighlighter queryHighlighter;

    private Map<String, IndexEnvironment> environment = new HashMap<String, IndexEnvironment>();

    public Controller( URL configFile )
    {
        this.config = new Configuration(configFile);
        this.queryPool = new QueryPool();
    }

    public void setQueryExpander( IQueryExpander queryExpander )
    {
        this.queryExpander = queryExpander;
    }

    public void setQueryHighlighter( IQueryHighlighter queryHighlighter )
    {
        this.queryHighlighter = queryHighlighter;
    }

    public IndexEnvironment getEnvironment( String indexId )
    {
        if (!this.environment.containsKey(indexId)) {
            this.environment.put(indexId, new IndexEnvironment(config.getIndexConfig(indexId)));
        }

        return this.environment.get(indexId);
    }

    public void index( String indexId, DocumentInfo document )
    {
        logger.info("Started indexing for index id [{}]", indexId);
        getEnvironment(indexId).putDocumentInfo(
                document.hashCode()
                , new Indexer(getEnvironment(indexId)).index(document)
        );
        logger.info("Indexing for index id [{}] completed", indexId);
    }

    public List<String> getTerms( String indexId, String fieldName )
    {
        return new Querier(getEnvironment(indexId)).getTerms(fieldName);
    }

    public Integer addQuery( String indexId, Map<String, String[]> queryParams )
    {
        return queryPool.addQuery(new QueryConstructor(getEnvironment(indexId)), queryParams, queryExpander);
    }

    public List<NodeInfo> queryIndex( String indexId, Integer queryId )
    {
        return new Querier(getEnvironment(indexId)).query(queryPool.getQueryInfo(queryId).getQuery());
    }

    public String highlightQuery( String indexId, Integer queryId, String fieldName, String text, String openMark, String closeMark )
    {
        if (null == queryHighlighter) {
            // sort of lazy init if we forgot to specify more advanced highlighter
            this.setQueryHighlighter(new QueryHighlighter());
        }
        return queryHighlighter.setEnvironment(getEnvironment(indexId)).highlightQuery(queryPool.getQueryInfo(queryId), fieldName, text, openMark, closeMark);
    }
}
