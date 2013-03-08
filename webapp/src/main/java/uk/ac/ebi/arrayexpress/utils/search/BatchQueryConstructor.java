package uk.ac.ebi.arrayexpress.utils.search;

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

import org.apache.lucene.index.Term;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.search.*;
import uk.ac.ebi.arrayexpress.utils.StringTools;
import uk.ac.ebi.arrayexpress.utils.saxon.search.IndexEnvironment;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class BatchQueryConstructor extends BackwardsCompatibleQueryConstructor
{
    private final static String FIELD_KEYWORDS = "keywords";
    private final static String FIELD_ACCESSION = "accession";

    private final static String RE_MATCHES_BATCH_OF_ACCESSIONS = "^\\s*(([ae]-\\w{4}-\\d+)[\\s,;]+)+$";
    private final static String RE_SPLIT_BATCH_OF_ACCESSIONS = "[\\s,;]+";

    @Override
    public Query construct( IndexEnvironment env, Map<String, String[]> querySource ) throws ParseException
    {
        Query query = super.construct(env, querySource);

        if (querySource.containsKey(FIELD_KEYWORDS)) {
            String keywords = StringTools.arrayToString(querySource.get(FIELD_KEYWORDS), " ").toLowerCase() + " ";
            if (keywords.matches(RE_MATCHES_BATCH_OF_ACCESSIONS)) {
                String[] accessions = keywords.split(RE_SPLIT_BATCH_OF_ACCESSIONS);

                query = removeTermQueriesForField(query, FIELD_KEYWORDS);

                BooleanQuery accQuery = new BooleanQuery();
                for (String acc : accessions) {
                    accQuery.add(new TermQuery(new Term(FIELD_ACCESSION, acc)), BooleanClause.Occur.SHOULD);
                }

                BooleanQuery topQuery;
                if (query instanceof BooleanQuery) {
                    topQuery = (BooleanQuery)query;
                } else {
                    topQuery = new BooleanQuery();
                    topQuery.add(query, BooleanClause.Occur.MUST);
                }

                topQuery.add(accQuery, BooleanClause.Occur.MUST);
                query = topQuery;
            }
        }
        return query;
    }

    @Override
    public Query construct( IndexEnvironment env, String queryString ) throws ParseException
    {
        return super.construct(env, queryString);
    }

    private Query removeTermQueriesForField( Query query, String fieldName )
    {
        Query q = removeTermQueryForField(query, fieldName);
        if (null == q) {
            q = new BooleanQuery();
        }

        return q;
    }


    private Query removeTermQueryForField( Query query, String fieldName )
    {
        if (query instanceof BooleanQuery) {
            BooleanQuery boolQuery = new BooleanQuery();
            for ( BooleanClause clause : ((BooleanQuery)query).clauses() ) {
                Query q = removeTermQueryForField(clause.getQuery(), fieldName);
                if (null != q) {
                    boolQuery.add(q, clause.getOccur());
                }
                if (0 != boolQuery.clauses().size()) {
                    query = boolQuery;
                } else {
                    query = null;
                }
            }
        } else if (query instanceof TermQuery || query instanceof PhraseQuery) {
            Set<Term> terms = new HashSet<>();
            query.extractTerms(terms);
            for (Term term : terms) {
                if (fieldName.equals(term.field())) {
                    return null;
                }
            }
        }
        return query;
    }
}
