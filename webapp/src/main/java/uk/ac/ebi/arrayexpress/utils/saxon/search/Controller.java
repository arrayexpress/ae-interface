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
import org.apache.commons.configuration.HierarchicalConfiguration;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.Query;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;

import java.io.IOException;
import java.net.URL;
import java.util.*;

public class Controller
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private Configuration config;
    private QueryPool queryPool;
    private IQueryConstructor queryConstructor;
    private IQueryExpander queryExpander;
    private IQueryHighlighter queryHighlighter;
    private SaxonEngine saxon;

    private Map<String, IndexEnvironment> environment = new HashMap<>();

    public Controller( URL configFile )
    {
        this.config = new Configuration(configFile);
        this.queryPool = new QueryPool();
        BooleanQuery.setMaxClauseCount(Integer.MAX_VALUE);
    }

    public Controller( HierarchicalConfiguration config )
    {
        this.config = new Configuration(config);
        this.queryPool = new QueryPool();
        BooleanQuery.setMaxClauseCount(Integer.MAX_VALUE);
    }

    public void setQueryConstructor( IQueryConstructor queryConstructor )
    {
        this.queryConstructor = queryConstructor;
    }

    public void setQueryExpander( IQueryExpander queryExpander )
    {
        this.queryExpander = queryExpander;
    }

    public void setQueryHighlighter( IQueryHighlighter queryHighlighter )
    {
        this.queryHighlighter = queryHighlighter;
    }

    public void setXPathEngine( SaxonEngine saxon )
    {
        this.saxon = saxon;
    }

    public boolean hasIndexDefined( String indexId )
    {
        return this.environment.containsKey(indexId);
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
        this.logger.info("Started indexing for index id [{}]", indexId);
        getEnvironment(indexId).putDocumentInfo(
                document.hashCode()
                , new Indexer(getEnvironment(indexId), saxon).index(document)
        );
        this.logger.info("Indexing for index id [{}] completed", indexId);
    }

    public List<String> getTerms( String indexId, String fieldName, int minFreq ) throws IOException
    {
        IndexEnvironment env = getEnvironment(indexId);
        if (!env.doesFieldExist(fieldName)) {
            this.logger.error("Field [{}] for index id [{}] does not exist, returning empty list");
            return new ArrayList<>();
        } else {
            return new Querier(env).getTerms(fieldName, minFreq);
        }
    }

    public Integer getDocCount( String indexId, Map<String, String[]> queryParams ) throws IOException, ParseException
    {
        IndexEnvironment env = getEnvironment(indexId);

        Query query = queryConstructor.construct(env, queryParams);
        return new Querier(env).getDocCount(query);

    }

    public void dumpTerms( String indexId, String fieldName )
    {
        IndexEnvironment env = getEnvironment(indexId);
        if (env.doesFieldExist(fieldName)) {
            new Querier(env).dumpTerms(fieldName);
        }
    }

    public Set<String> getFieldNames( String indexId )
    {
        IndexEnvironment env = getEnvironment(indexId);
        return (null != env ? env.fields.keySet() : null);
    }

    public String getFieldTitle( String indexId, String fieldName )
    {
        IndexEnvironment env = getEnvironment(indexId);
        return (null != env && env.doesFieldExist(fieldName) ? env.fields.get(fieldName).title : null);        
    }

    public String getFieldType( String indexId, String fieldName )
    {
        IndexEnvironment env = getEnvironment(indexId);
        return (null != env && env.doesFieldExist(fieldName) ? env.fields.get(fieldName).type : null);        
    }

    public Integer addQuery( String indexId, Map<String, String[]> queryParams )
            throws ParseException, IOException
    {
        if (null == this.queryConstructor) {
            // sort of lazy init if we forgot to specify more advanced highlighter
            this.setQueryConstructor(new QueryConstructor());
        }

        return this.queryPool.addQuery(
                getEnvironment(indexId)
                , this.queryConstructor
                , queryParams
                , this.queryExpander
        );
    }

    public List<NodeInfo> queryIndex( Integer queryId ) throws IOException
    {
        QueryInfo queryInfo = this.queryPool.getQueryInfo(queryId);
        return new Querier(getEnvironment(queryInfo.getIndexId())).query(queryInfo);
    }

    public List<NodeInfo> queryIndex( String indexId, String queryString ) throws ParseException, IOException
    {
        return new Querier(getEnvironment(indexId)).query(this.queryConstructor.construct(getEnvironment(indexId), queryString));  // should use "queryIndex( Integer queryId )" instead
    }

    public String highlightQuery( Integer queryId, String fieldName, String text )
    {
        if (null == this.queryHighlighter) {
            // sort of lazy init if we forgot to specify more advanced highlighter
            this.setQueryHighlighter(new QueryHighlighter());
        }
        QueryInfo queryInfo = this.queryPool.getQueryInfo(queryId);
        if (null != queryInfo) {
            return queryHighlighter.setEnvironment(getEnvironment(queryInfo.getIndexId()))
                    .highlightQuery(queryInfo, fieldName, text);
        } else {
            this.logger.error("Unable to find query info for query with id [{}]", queryId);
            return text;
        }
    }
}
