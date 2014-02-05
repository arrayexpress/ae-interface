package uk.ac.ebi.microarray.ontology.efo;


/**
 * Copyright 2009-2014 European Molecular Biology Laboratory
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

import uk.ac.ebi.microarray.ontology.IPropertyVisitor;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * Visits nodes that are in part_of relationships and builds
 * map node name -> set of its part names
 * and map node id -> set of its part ids.
 *
 */

public class EFOPartOfPropertyVisitor implements IPropertyVisitor<EFONode>
{
    /**
     * Part_of property name.
     */
    public static final String PART_OF = "part_of";

    private Map<String, Set<String>> partOfIdMap;

    public EFOPartOfPropertyVisitor( Map<String, Set<String>> partOfIdMap )
    {
        this.partOfIdMap = partOfIdMap;
    }

    /**
     * Process relationship forced by the part_of property.
     *
     * @param node   First node.
     * @param friend Second node.
     */
    public void inRelationship( EFONode node, EFONode friend )
    {
        if (null == node || null == friend || friend.getId().equals(node.getId())) {
            return;
        }
        Set<String> parentPartIds = this.partOfIdMap.get(friend.getId());
        if (null == parentPartIds) {
            parentPartIds = new HashSet<String>();
            this.partOfIdMap.put(friend.getId(), parentPartIds);
        }
        parentPartIds.add(node.getId());
    }

    /**
     * Returns part_of property name.
     *
     * @return Part_of property name.
     */
    public String getPropertyName()
    {
        return PART_OF;
    }
}
