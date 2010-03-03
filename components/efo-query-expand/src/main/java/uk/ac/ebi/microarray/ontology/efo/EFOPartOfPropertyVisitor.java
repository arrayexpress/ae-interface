package uk.ac.ebi.microarray.ontology.efo;


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

import uk.ac.ebi.microarray.ontology.IPropertyVisitor;

import java.util.*;

import static uk.ac.ebi.microarray.ontology.efo.Utils.isStopWord;
import static uk.ac.ebi.microarray.ontology.efo.Utils.trimLowercaseString;

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

    private Map<String, Set<String>> nameToPartsMap;
    private Map<String, Set<String>> idToPartIdsMap;

    public EFOPartOfPropertyVisitor()
    {
        this(new HashMap<String, Set<String>>(), new HashMap<String, Set<String>>());
    }

    public EFOPartOfPropertyVisitor( Map<String, Set<String>> nameToPartsMap, Map<String, Set<String>> idToPartIdsMap )
    {
        this.nameToPartsMap = nameToPartsMap;
        this.idToPartIdsMap = idToPartIdsMap;
    }

    /**
     * We want to look for property relationships of this node
     * only if it's not null and we are interesed in its name.
     *
     * @param node Node.
     * @return true if we the specified node is not null and we are interesed in its name.
     */
    public boolean isInterestedInNode( EFONode node )
    {
        return null != node && isInterestedInNode(getName(node));
    }

    /**
     * We want to look for property relationships of the node with the specified name
     * only if the name is not a stop word.
     *
     * @param nodeName Name of the node.
     * @return true if we the specified name is not a stop word.
     */
    public boolean isInterestedInNode( String nodeName )
    {
        return !isStopWord(nodeName);
    }

    /**
     * Process relationship forced by the part_of property.
     * If we are interested in both nodes given updating nameToPartsMap and idToPartIdsMap.
     *
     * @param node   First node.
     * @param friend Second node.
     */
    public void inRelationship( EFONode node, EFONode friend )
    {
        String nodeName = getName(node);
        String parentName = getName(friend);
        if (null == friend || !isInterestedInNode(parentName) || parentName.equals(nodeName)) {
            return;
        }
        Set<String> parentParts = this.nameToPartsMap.get(parentName);
        Set<String> parentPartIds = this.idToPartIdsMap.get(friend.getId());
        if (null == parentParts) {
            parentParts = new HashSet<String>();
            parentPartIds = new HashSet<String>();
            this.nameToPartsMap.put(parentName, parentParts);
            this.idToPartIdsMap.put(friend.getId(), parentPartIds);
        }
        parentParts.add(nodeName);
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

    /**
     * Returns name of the node given.
     *
     * @param node Node which name we are interested in.
     * @return Name of the given node.
     */
    public String getName( EFONode node )
    {
        return trimLowercaseString(node.getTerm());
    }

    /**
     * Getter for map node name -> set of part names.
     *
     * @return Unmodifiable map node name -> set of part names.
     */
    public Map<String, Set<String>> getNameToPartsMap()
    {
        return Collections.unmodifiableMap(nameToPartsMap);
    }

    /**
     * Getter for map node id -> set of part ids.
     *
     * @return Unmodifiable map node id -> set of part ids.
     */
    public Map<String, Set<String>> getIdToPartIdsMap()
    {
        return Collections.unmodifiableMap(idToPartIdsMap);
    }
}
