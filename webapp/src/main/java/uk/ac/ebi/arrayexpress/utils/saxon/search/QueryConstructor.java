package uk.ac.ebi.arrayexpress.utils.saxon.search;

/*
 * Copyright 2009-2010 Functional Genomics Group, European Bioinformatics Institute
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
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.BooleanClause;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.Query;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

public class QueryConstructor implements IQueryConstructor
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private IndexEnvironment env;

    public IQueryConstructor setEnvironment( IndexEnvironment env )
    {
        this.env = env;
        return this;
    }

    public Query construct( Map<String, String[]> querySource ) throws ParseException
    {
        BooleanQuery result = new BooleanQuery();
        for (Map.Entry<String, String[]> queryItem : querySource.entrySet()) {
            if (this.env.fields.containsKey(queryItem.getKey()) && queryItem.getValue().length > 0) {
                QueryParser parser = new EnhancedQueryParser(this.env, queryItem.getKey(), this.env.indexAnalyzer);
                parser.setDefaultOperator(QueryParser.Operator.AND);
                for ( String value : queryItem.getValue() ) {
                    if (!"".equals(value)) {
                        Query q = parser.parse(value);
                        result.add(q, BooleanClause.Occur.MUST);
                    }
                }
            }
        }
        return result;
    }
}
