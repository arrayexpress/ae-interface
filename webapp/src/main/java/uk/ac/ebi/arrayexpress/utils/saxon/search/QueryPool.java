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

import org.apache.lucene.search.Query;
import uk.ac.ebi.arrayexpress.utils.LRUMap;

import java.util.Collections;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public class QueryPool
{
    // logging machinery
    //private final Logger logger = LoggerFactory.getLogger(getClass());

    private AtomicInteger queryId;

    public class QueryInfo
    {
        public Map<String, String[]> queryParams;
        public Query parsedQuery;

        public QueryInfo( Map<String, String[]> queryParams )
        {
            this.queryParams = queryParams;
        }
    }

    private Map<Integer, QueryInfo> queries = Collections.synchronizedMap(new LRUMap<Integer, QueryInfo>(50));

    public QueryPool()
    {
        this.queryId = new AtomicInteger(0);
    }

    public Integer addQuery( QueryConstructor queryConstructor, Map<String, String[]> queryParams, IQueryExpander queryExpander )
    {
        QueryInfo info = new QueryInfo(queryParams);
        info.parsedQuery = queryConstructor.construct(queryParams);
        if (null != queryExpander) {
            info.parsedQuery = queryExpander.expandQuery(info.parsedQuery, queryParams);
        }
        this.queries.put(this.queryId.addAndGet(1), info);

        return this.queryId.get();
    }

    public QueryInfo getQueryInfo( Integer queryId )
    {
        QueryInfo info = null;

        if (queries.containsKey(queryId)) {
            info = queries.get(queryId);
        }

        return info;
    }
}
