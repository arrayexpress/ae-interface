package uk.ac.ebi.arrayexpress.utils.search;

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

import org.apache.lucene.index.Term;
import org.apache.lucene.search.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.utils.StringTools;
import uk.ac.ebi.arrayexpress.utils.saxon.search.IQueryExpander;
import uk.ac.ebi.arrayexpress.utils.saxon.search.QueryInfo;

import java.util.HashSet;
import java.util.Set;

public final class EFOQueryExpander implements IQueryExpander
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private IEFOExpansionLookup lookup;

    public EFOQueryExpander( IEFOExpansionLookup lookup )
    {
        this.lookup = lookup;
    }

    public QueryInfo newQueryInfo()
    {
        return new EFOExpandableQueryInfo();
    }

    public Query expandQuery( QueryInfo info )
    {
        EFOExpandableQueryInfo queryInfo = null;

        try {
            queryInfo = (EFOExpandableQueryInfo)info;
        } catch (ClassCastException x) {
            // ok, do nothing here
        }

        if (null != queryInfo) {
            queryInfo.setExpandEfoFlag("true".equals(StringTools.arrayToString(info.getParams().get("expandefo"), " ")));
            queryInfo.setOriginalQuery(queryInfo.getQuery());

            return expand(queryInfo, queryInfo.getQuery());
        } else {
            return info.getQuery();
        }
    }

    private Query expand( EFOExpandableQueryInfo queryInfo, Query query )
    {
        Query result;

        if (query instanceof BooleanQuery) {
            result = new BooleanQuery();

            BooleanClause[] clauses = ((BooleanQuery) query).getClauses();
            for (BooleanClause c : clauses) {
                ((BooleanQuery) result).add(
                        expand(queryInfo, c.getQuery())
                        , c.getOccur()
                );
            }
        } else if (query instanceof PrefixQuery || query instanceof WildcardQuery) {
            // we don't expand prefix or wildcard queries yet (because there are side-effects
            // we need to take care of first
            // for example, for prefix query will found multi-worded terms which, well, is wrong
            return query;
        } else {
            result = doExpand(queryInfo, query);
        }
        return result;
    }

    private Query doExpand( EFOExpandableQueryInfo queryInfo, Query query )
    {
        String field = getQueryField(query);
        if (null != field && -1 != " keywords sa efv exptype species ".indexOf(" " + field + " ")) {

            boolean shouldExpandEfo = queryInfo.getExpandEfoFlag() || "exptype".equals(field);   // exptype always expands

            EFOExpansionTerms expansionTerms = lookup.getExpansionTerms(query);
            if ((shouldExpandEfo && (0 != expansionTerms.efo.size())) || 0 != expansionTerms.synonyms.size()) {
                BooleanQuery boolQuery = new BooleanQuery();

                boolQuery.add(query, BooleanClause.Occur.SHOULD);

                for (String term : expansionTerms.synonyms) {
                    Query synonymPart = newQueryFromString(term.trim(), field);
                    if (!queryPartIsRedundant(query, synonymPart)) {
                        boolQuery.add(synonymPart, BooleanClause.Occur.SHOULD);
                        queryInfo.addToSynonymPartQuery(synonymPart);
                    }
                }

                if (shouldExpandEfo) {
                    for (String term : expansionTerms.efo) {
                        Query expansionPart = newQueryFromString(term.trim(), field);
                        boolQuery.add(expansionPart, BooleanClause.Occur.SHOULD);
                        queryInfo.addToEfoExpansionPartQuery(expansionPart);
                    }
                }
                return boolQuery;
            }
        }
        return query;
    }

    private String getQueryField( Query query )
    {
        String field = null;
        try {
            if (query instanceof PrefixQuery) {
                field = ((PrefixQuery) query).getPrefix().field();
            } else if (query instanceof WildcardQuery) {
                field = ((WildcardQuery) query).getTerm().field();
            } else if (query instanceof TermRangeQuery) {
                field = ((TermRangeQuery) query).getField();
            } else if (query instanceof NumericRangeQuery) {
                field = ((NumericRangeQuery) query).getField();
            } else if (query instanceof FuzzyQuery) {
                field = ((FuzzyQuery) query).getTerm().field();
            } else {
                Set<Term> terms = new HashSet<Term>();
                query.extractTerms(terms);
                if (terms.size() > 1 && !(query instanceof PhraseQuery)) {
                    logger.warn("More than one term found for query [{}]", query.toString());
                } else if (0 == terms.size()) {
                    logger.error("No terms found for query [{}]", query.toString());
                    return null;
                }
                field = ((Term) terms.toArray()[0]).field();
            }
        } catch (UnsupportedOperationException x) {
            logger.error("Query of [{}], class [{}] doesn't allow us to get its terms extracted", query.toString(), query.getClass().getCanonicalName());
        }

        return field;
    }

    public Query newQueryFromString( String text, String field )
    {
        if (-1 != text.indexOf(" ")) {
            String[] tokens = text.split("\\s+");
            PhraseQuery q = new PhraseQuery();
            for (String token : tokens) {
                q.add(new Term(field, token));
            }
            return q;
        } else {
            return new TermQuery(new Term(field, text));
        }
    }

    private boolean queryPartIsRedundant( Query query, Query part )
    {
        Term partTerm = getFirstTerm(part);

        if (query instanceof PrefixQuery) {
            Term prefixTerm = ((PrefixQuery)query).getPrefix();
            return prefixTerm.field().equals(partTerm.field()) && (partTerm.text().startsWith(prefixTerm.text()));
        } else if (query instanceof WildcardQuery) {
            Term wildcardTerm = ((WildcardQuery)query).getTerm();
            String wildcard = "^" + wildcardTerm.text().replaceAll("\\?", "\\.").replaceAll("\\*", "\\.*") + "$";
            return wildcardTerm.field().equals(partTerm.field()) && (partTerm.text().matches(wildcard));
        } else {
            return query.toString().equals(part.toString());
        }

    }

    private Term getFirstTerm( Query query )
    {
        if (query instanceof PhraseQuery) {
            Term[] terms = ((PhraseQuery)query).getTerms();
            if (0 != terms.length) {
                return terms[0];
            }
        } else if (query instanceof TermQuery) {
            return ((TermQuery)query).getTerm();
        } else {
            Set<Term> terms = new HashSet<Term>();
            query.extractTerms(terms);
            for (Term t : terms ) {
                return t;
            }
        }
        return new Term("", "");
    }
}
