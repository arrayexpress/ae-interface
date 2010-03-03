package uk.ac.ebi.microarray.lucene.query;

/**
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

/**
 * @author Anna Zhukova
 */

import org.apache.lucene.index.Term;
import org.apache.lucene.search.BooleanClause;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.PhraseQuery;
import org.apache.lucene.search.Query;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class QueryTokenizer {
    /**
     * Returns set of string synonyms found in all provided maps.
     * For each map inserts synonyms found in it partitioned by "OR"
     * into corresponding query from partQueries.
     *
     * @param str        Strings which synonyms are searched
     * @param field       Field name, used to create terms for synonym strings in partQueries
     * @param synonymMaps Maps where synonyms are searched
     * @param partQueries array of queries to place found synonyms where
     *                    partQueries[i + 2], where i is map number in synonymMap list,
     *                    will contain all the synonyms we found in i-th map for the string.
     *                    and its synonyms found in previous maps partitioned by "OR".
     *                    partQueries[0] and partQueries[1] are not used.
     * @return Set of synonyms from all the maps
     */
    public static Set<String> getSynonyms(
            String str, String field,
            List<Map<String, Set<String>>> synonymMaps, Query[] partQueries) {
        int i = 2;
        Set<String> result = new HashSet<String>();
        for (Map<String, Set<String>> map : synonymMaps) {
            Set<String> newIn = new HashSet<String>();
            for (String alreadyIn : result) {
                Set<String> synonyms2AlreadyIn = map.get(alreadyIn);
                if (synonyms2AlreadyIn != null) {
                    newIn.addAll(synonyms2AlreadyIn);
                }
            }
            Set<String> synonyms2String = map.get(str);
            if (synonyms2String != null) {
                newIn.addAll(synonyms2String);
            }
            for (String synonym : newIn) {
                if (partQueries[i] == null) {
                    partQueries[i] = new BooleanQuery();
                }
                ((BooleanQuery) partQueries[i]).add(
                        buildSynonymPhraseQuery(field, synonym),
                        BooleanClause.Occur.SHOULD);
            }
            i++;
            result.addAll(newIn);
        }
        return result;

    }

    /**
     * Expands given query using synonym maps.
     *
     * @param queries     Array of queries, where queries[0] is query to be expanded.
     *                    query[1] will contain the resulting expanded query when the method returns.
     *                    For i != 0 and i != 1 queries[i] will contain Query with synonyms
     *                    found in synonymMap[i - 2]
     *                    (see QueryTokenizer.getSynonyms(String str, String field,
     *                    List&lt;Map&lt;String, Set&lt;String&gt;&gt;&gt; synonymMaps,
     *                    Query[] partQueries)
     *                    when the method returns.
     *                    queries.length should be equal to synonymMap.size() + 2.
     * @param synonymMaps Maps used to expand query
     * @return Expanded query.
     */


    public static Query rewriteQuery(
            Query[] queries,
            List<Map<String, Set<String>>> synonymMaps) {
        if (queries[0] instanceof BooleanQuery) {
            return queries[1] = rewriteBooleanQuery((BooleanQuery) queries[0],
                    synonymMaps, queries);
        } else {
            return queries[1] = rewriteNotBooleanQuery(queries[0],
                    synonymMaps, queries);
        }
    }


    /**
     * Rewrites Boolean query query expanding all its clauses using synonymMaps.
     *
     * @param query       Query to be expanded.
     * @param synonymMaps Maps where synonyms are looked for
     * @param partQueries Array of queries to place found synonyms into
     *                    where partQueries[i + 2], where i is map number in synonymMap list,
     *                    will contain all the synonyms we found in i-th map for the string
     *                    and its synonyms found in previous maps partitioned by "OR".
     *                    partQueries[0] and partQueries[1] are not used.
     * @return Expanded query.
     */
    public static BooleanQuery rewriteBooleanQuery(
            BooleanQuery query,
            List<Map<String, Set<String>>> synonymMaps, Query[] partQueries) {
        BooleanQuery result = new BooleanQuery();
        for (BooleanClause clause : query.getClauses()) {
            BooleanClause.Occur suboccur = clause.getOccur();
            Query subquery = clause.getQuery();
            if (subquery instanceof BooleanQuery) {
                result.add(
                        rewriteBooleanQuery(
                                (BooleanQuery) subquery,
                                synonymMaps, partQueries
                        ),
                        suboccur);
            } else {
                result.add(
                        rewriteNotBooleanQuery(subquery, synonymMaps, partQueries),
                        suboccur);
            }
        }
        return result;
    }

    /**
     * Expands query which is not instanceOf(BooleanQuery) into BooleanQuery.
     * For every term or phrase >t< in query it will be replaced by
     * (>t< OR >synonym1< OR >synonym2< OR ...), where synonyms are found in
     * synonym maps
     * (see QueryTokenizer.getSynonyms(String str, String field,
     * List&lt;Map&lt;String, Set&lt;String&gt;&gt;&gt; synonymMaps,
     * Query[] partQueries)
     *
     * @param query       Query to be expanded
     * @param synonymMaps Maps where synonyms are looked for
     * @param partQueries Array of queries to place found synonyms into
     *                    where partQueries[i + 2], where i is map number in synonymMap list,
     *                    will contain all the synonyms we found in i-th map for the string
     *                    and its synonyms found in previous maps partitioned by "OR".
     *                    partQueries[0] and partQueries[1] are not used.
     * @return Expanded query
     */
    public static BooleanQuery rewriteNotBooleanQuery(
            Query query,
            List<Map<String, Set<String>>> synonymMaps, Query[] partQueries) {
        BooleanQuery newQuery = new BooleanQuery();
        newQuery.add(query, BooleanClause.Occur.SHOULD);
        if (query instanceof PhraseQuery) {
            PhraseQuery phraseQuery = (PhraseQuery) query;
            StringBuilder phrase = new StringBuilder();
            String field = null;
            for (Term t : phraseQuery.getTerms()) {
                if (field == null) {
                    field = t.field();
                }
                phrase.append(t.text()).append(" ");
            }
            appendSynonyms(synonymMaps, partQueries, newQuery,
                    phrase.toString().trim(), field);
        } else {
            Set<Term> terms = new HashSet<Term>();
            query.extractTerms(terms);
            for (Term term : terms) {
                appendSynonyms(synonymMaps, partQueries, newQuery,
                        term.text(), term.field());
            }
        }
        return newQuery;
    }


    /**
     * Adds PhraseQuery containing given phrase to the given BoolenQuery query
     *
     * @param synonymMaps Maps where synonyms are looked for
     * @param partQueries partQueries Array of queries to place found synonyms into
     *                    where partQueries[i + 2], where i is map number in synonymMap list,
     *                    will contain all the synonyms we found in i-th map for the string
     *                    and its synonyms found in previous maps partitioned by "OR".
     *                    partQueries[0] and partQueries[1] are not used.
     * @param query       Query resulting PhraseQuery to be added to
     * @param phrase      Phrase for PhraseQuery
     * @param field       Filed name for PhraseQuery terms
     */
    public static void appendSynonyms(List<Map<String, Set<String>>> synonymMaps,
                                       Query[] partQueries, BooleanQuery query,
                                       String phrase, String field) {
        if (field != null) {
            Set<String> synonyms = getSynonyms(phrase, field, synonymMaps,
                    partQueries);
            for (String synonym : synonyms) {
                query.add(buildSynonymPhraseQuery(field, synonym),
                        BooleanClause.Occur.SHOULD);
            }
        }
    }


    /**
     * Splits given synonym phrase into words and puts them into PhraseQuery
     *
     * @param field   Field name for the term
     * @param synonym Synonym phrase
     * @return PhraseQuery containing given synonym phrase
     */
    public static PhraseQuery buildSynonymPhraseQuery(String field,
                                                       String synonym) {
        PhraseQuery synonymQuery = new PhraseQuery();
        String[] synonymParts = synonym.split(" ");
        for (String part : synonymParts) {
            synonymQuery.add(new Term(field, part));
        }
        return synonymQuery;
    }
}

