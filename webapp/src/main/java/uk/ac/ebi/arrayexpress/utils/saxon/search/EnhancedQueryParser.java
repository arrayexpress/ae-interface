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

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.NumericRangeQuery;
import org.apache.lucene.search.Query;
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
        if (env.fields.containsKey(this.getField()) && env.fields.get(this.getField()).forcePhraseQuery) {
            queryText = "\"" + queryText + "\"";
        }
        return super.parse(queryText);
    }

    protected Query getFieldQuery( String field, String queryText, int slop ) throws ParseException
    {
        Query query = super.getFieldQuery(field, queryText, slop);
        if (env.fields.containsKey(field) && "integer".equals(env.fields.get(field).type)) {
            return NumericRangeQuery.newLongRange(
                    field,
                    parseLong(queryText),
                    parseLong(queryText),
                    true,
                    true);
        } else {
            return query;
        }
    }

    protected Query getFieldQuery( String field, String queryText ) throws ParseException
    {
        Query query = super.getFieldQuery(field, queryText);
        if (env.fields.containsKey(field) && "integer".equals(env.fields.get(field).type)) {
            return NumericRangeQuery.newLongRange(
                    field,
                    parseLong(queryText),
                    parseLong(queryText),
                    true,
                    true);
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
