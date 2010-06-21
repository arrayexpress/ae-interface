package uk.ac.ebi.microarray.lucene.queryexpansion;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;


/*
 * Copyright 2009-2010 European Molecular Biology Laboratory
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

public class OntologyExpansionTerms
{
    private String           term;
    private Set<String>      synonyms;
    private Set<String>      children;

    public OntologyExpansionTerms()
    {
        term = "";
        synonyms = new HashSet<String>();
        children = new HashSet<String>();
    }

    public void setTerm( String term )
    {
        this.term = term;
    }

    public void addSynonyms( Collection<String> synonyms )
    {
        this.synonyms.addAll(synonyms);
    }

    public void addChildren( Collection<String> children )
    {
        this.children.addAll(children);
    }

    public Collection<String> getSynonyms()
    {
        return this.synonyms;
    }

    public Collection<String> getChildren()
    {
        return this.children;
    }
}
