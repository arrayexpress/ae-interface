package uk.ac.ebi.arrayexpress.utils.search;

import org.apache.lucene.search.BooleanClause;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.Query;
import uk.ac.ebi.arrayexpress.utils.saxon.search.QueryInfo;

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

public class EFOExpandableQueryInfo extends QueryInfo
{
    private Query originalQuery;
    private BooleanQuery synonymPartQuery = new BooleanQuery();
    private BooleanQuery efoExpansionPartQuery = new BooleanQuery();

    public Query getOriginalQuery()
    {
        return originalQuery;
    }

    public void setOriginalQuery( Query originalQuery )
    {
        this.originalQuery = originalQuery;
    }

    public Query getSynonymPartQuery()
    {
        return synonymPartQuery;
    }

    public void addToSynonymPartQuery( Query part )
    {
        synonymPartQuery.add(part, BooleanClause.Occur.SHOULD);
    }

    public Query getEfoExpansionPartQuery()
    {
        return efoExpansionPartQuery;
    }

    public void addToEfoExpansionPartQuery( Query part )
    {
        efoExpansionPartQuery.add(part, BooleanClause.Occur.SHOULD);
    }
}
