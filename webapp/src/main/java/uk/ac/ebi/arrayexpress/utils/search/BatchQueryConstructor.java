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

import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.search.Query;
import uk.ac.ebi.arrayexpress.utils.StringTools;
import uk.ac.ebi.arrayexpress.utils.saxon.search.IndexEnvironment;

import java.util.Map;

public class BatchQueryConstructor extends BackwardsCompatibleQueryConstructor
{
    private final static String FIELD_KEYWORDS = "keywords";

    private final static String RE_MATCHES_BATCH_OF_ACCESSIONS = "^\\s*(([aAeE]-\\w{4}-\\d+)[\\s,;]+)+$";
    private final static String RE_REPLACE_BATCH_OF_ACCESSIONS = "\\s*([aAeE]-\\w{4}-\\d+)[\\s,;]+";

    @Override
    public Query construct( IndexEnvironment env, Map<String, String[]> querySource ) throws ParseException
    {
        if (querySource.containsKey(FIELD_KEYWORDS)) {
            String keywords = StringTools.arrayToString(querySource.get(FIELD_KEYWORDS), " ") + " ";
            if (keywords.matches(RE_MATCHES_BATCH_OF_ACCESSIONS)) {
                keywords = keywords.replaceAll(RE_REPLACE_BATCH_OF_ACCESSIONS, " OR accession:$1").replaceFirst("^ OR", "");
                querySource.put(FIELD_KEYWORDS, new String[]{keywords});
            }
        }
        return super.construct(env, querySource);
    }

    @Override
    public Query construct( IndexEnvironment env, String queryString ) throws ParseException
    {
        return super.construct(env, queryString);
    }
}
