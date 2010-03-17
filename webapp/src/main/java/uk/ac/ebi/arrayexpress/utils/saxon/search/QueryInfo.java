package uk.ac.ebi.arrayexpress.utils.saxon.search;

import org.apache.lucene.search.Query;

import java.util.Map;

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

public class QueryInfo
{
    private String queryString;
    private Map<String, String[]> params;
    private Query query;

    public void setQueryString( String queryString )
    {
        this.queryString = queryString;
    }

    public String getQueryString()
    {
        return queryString;
    }
    public void setParams( Map<String, String[]> params )
    {
        this.params = params;
    }

    public Map<String, String[]> getParams()
    {
        return params;
    }

    public void setQuery( Query query )
    {
        this.query = query;
    }

    public Query getQuery()
    {
        return query;
    }
}
