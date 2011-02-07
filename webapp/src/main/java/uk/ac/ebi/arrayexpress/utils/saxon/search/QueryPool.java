package uk.ac.ebi.arrayexpress.utils.saxon.search;

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

import org.apache.lucene.queryParser.ParseException;
import uk.ac.ebi.arrayexpress.utils.LRUMap;

import java.io.IOException;
import java.util.Collections;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public class QueryPool
{
    // logging machinery
    //private final Logger logger = LoggerFactory.getLogger(getClass());

    private AtomicInteger queryId;

    private Map<Integer, QueryInfo> queries = Collections.synchronizedMap(new LRUMap<Integer, QueryInfo>(50));

    public QueryPool()
    {
        this.queryId = new AtomicInteger(0);
    }

    public Integer addQuery(
            IndexEnvironment env
            , IQueryConstructor queryConstructor
            , Map<String, String[]> queryParams
            , String queryString
            , IQueryExpander queryExpander )
            throws ParseException, IOException
    {
        QueryInfo info;

        if (null != queryExpander) {
            info = queryExpander.newQueryInfo();
        } else {
            info = new QueryInfo();
        }

        info.setIndexId(env.indexId);
        info.setQueryString(queryString);
        info.setParams(queryParams);
        info.setQuery(queryConstructor.construct(env, queryParams));
        if (null != queryExpander) {
            info.setQuery(queryExpander.expandQuery(info));
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
