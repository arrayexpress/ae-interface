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

import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.BooleanClause;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.Query;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

public class QueryConstructor
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private IndexEnvironment env;

    public QueryConstructor( IndexEnvironment env )
    {
        this.env = env;
    }

    public Query construct( Map<String, String> querySource )
    {
        BooleanQuery result = new BooleanQuery();
        try {
            for (Map.Entry<String, String> queryItem : querySource.entrySet()) {
                if (env.fields.containsKey(queryItem.getKey()) && queryItem.getValue().trim().length() > 0) {
                    QueryParser parser = new NumericRangeQueryParser(env, queryItem.getKey(), this.env.indexAnalyzer);
                    parser.setDefaultOperator(QueryParser.Operator.AND);
                    try {
                        Query q = parser.parse(queryItem.getValue());
                        result.add(q, BooleanClause.Occur.MUST);
                    } catch (ParseException x) {
                        logger.error(x.getMessage()); //todo: this should be communicated to the user, will deal with this at a later stage
                    }
                }
            }
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }
        return result;
    }
}
