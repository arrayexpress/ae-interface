package uk.ac.ebi.microarray.ontology.efo;

/*
 * Copyright 2009-2011 European Molecular Biology Laboratory
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

import java.util.Map;
import java.util.Set;

public interface IEFOOntology
{
    public final static int INCLUDE_SELF = 1;
    public final static int INCLUDE_ALT_TERMS = 2;
    public final static int INCLUDE_CHILD_TERMS = 4;
    public final static int INCLUDE_PART_OF_TERMS = 8;

    public final static int INCLUDE_ALL =
            INCLUDE_SELF
            + INCLUDE_ALT_TERMS
            + INCLUDE_CHILD_TERMS
            + INCLUDE_PART_OF_TERMS;

    public final static int INCLUDE_CHILDREN =
            INCLUDE_ALT_TERMS
            + INCLUDE_CHILD_TERMS
            + INCLUDE_PART_OF_TERMS;

    public String getRootID();
    public Map<String, EFONode> getEfoMap();
    public Map<String, Set<String>> getEfoPartOfIdMap();
    public Set<String> getTerms( String efoId, int includeFlags );
}
