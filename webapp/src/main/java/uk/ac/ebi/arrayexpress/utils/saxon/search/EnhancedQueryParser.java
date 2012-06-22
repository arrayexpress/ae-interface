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

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.index.Term;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.NumericRangeQuery;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.TermRangeQuery;
import org.apache.lucene.util.Version;

public class EnhancedQueryParser extends QueryParser
{
    private IndexEnvironment env;

    public EnhancedQueryParser( IndexEnvironment env, String f, Analyzer a )
    {
        super(Version.LUCENE_30, f, a);
        this.env = env;
    }

    protected Query getRangeQuery( String field,
                                   String part1,
                                   String part2,
                                   boolean inclusive )
            throws ParseException
    {
        TermRangeQuery query = (TermRangeQuery)
                super.getRangeQuery(field, part1, part2,
                        inclusive);
        if (env.fields.containsKey(field) && "integer".equals(env.fields.get(field).type)) {
            return NumericRangeQuery.newLongRange(
                    field,
                    parseLong(query.getLowerTerm()),
                    parseLong(query.getUpperTerm()),
                    query.includesLower(),
                    query.includesUpper());
        } else {
            return query;
        }
    }

    public Query parse(String queryText) throws ParseException
    {
        return super.parse(queryText);
    }

    protected Query getFieldQuery( String field, String queryText, int slop ) throws ParseException
    {
        return rewriteNumericBooleanFieldQuery(super.getFieldQuery(field, queryText, slop), field, queryText);
    }

    protected Query getFieldQuery( String field, String queryText ) throws ParseException
    {
        return rewriteNumericBooleanFieldQuery(super.getFieldQuery(field, queryText), field, queryText);
    }

    private Query rewriteNumericBooleanFieldQuery( Query query, String field, String queryText ) throws ParseException
    {
        if (env.fields.containsKey(field) && "integer".equals(env.fields.get(field).type)) {
            return NumericRangeQuery.newLongRange(
                    field,
                    parseLong(queryText),
                    parseLong(queryText),
                    true,
                    true);
        } else if (env.fields.containsKey(field) && "boolean".equals(env.fields.get(field).type)) {
            if ("true".equalsIgnoreCase(queryText) || "on".equalsIgnoreCase(queryText) || "1".equalsIgnoreCase(queryText)) {
                return new TermQuery(new Term(field, "true"));
            } else if ("false".equalsIgnoreCase(queryText) || "0".equalsIgnoreCase(queryText)) {
                return new TermQuery(new Term(field, "false"));
            } else {
                return new TermQuery(new Term(field, queryText));   // in this case we get no results, but the query will be properly logged
            }
        } else {
            return query;
        }
    }

    private Long parseLong( String text ) throws ParseException
    {
        Long value;

        try {
            value = Long.parseLong(text);
        } catch (NumberFormatException x) {
            throw new ParseException(x.getMessage());
        }

        return value;
    }
}
