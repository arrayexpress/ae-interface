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

import uk.ac.ebi.microarray.ontology.OntologyLoader;

import java.io.InputStream;
import java.util.*;

import static uk.ac.ebi.microarray.ontology.efo.Utils.isStopWord;
import static uk.ac.ebi.microarray.ontology.efo.Utils.trimLowercaseString;

public class EFOOntologyHelper
{

    private Map<String, EFONode> efoMap = new HashMap<String, EFONode>();
    private Map<String, Set<String>> nameToPartsMap = new HashMap<String, Set<String>>();
    private Map<String, Set<String>> idToPartIdsMap = new HashMap<String, Set<String>>();
    private SortedSet<EFONode> roots = new TreeSet<EFONode>(EFONode.TERM_COMPARATOR);
    private Map<String, Set<String>> nameToAlternativesMap = new HashMap<String, Set<String>>();

    /**
     * Returns Map ontology term name -> set of
     * names of all its parts (part_of relationship)
     * and parts of their parts recursively
     * and also subclasses (is_a) and subclasses of subclasses recursively.
     *
     * @return Map to fully expand every ontology term
     */
    public Map<String, Set<String>> getFullOntologyExpansionMap()
    {
        Map<String, Set<String>> result = new HashMap<String, Set<String>>();
        for (String id : efoMap.keySet()) {
            String name = trimLowercaseString(getTermNameById(id));
            if (!isStopWord(name)) {
                Set<String> expansionSet = new LinkedHashSet<String>();
                addPartsRecursively(expansionSet, nameToPartsMap.get(name));
                addChildrenRecursively(expansionSet, id);
                if (!expansionSet.isEmpty()) {
                    result.put(name, expansionSet);
                }
            }
        }
        return result;
    }

    /**
     * Returns Map ontology term id -> name.
     *
     * @return Map ontology term id -> name.
     */
    public Map<String, String> getTermByIdMap()
    {
        Map<String, String> result = new HashMap<String, String>();
        for (String id : efoMap.keySet()) {
            String name = trimLowercaseString(getTermNameById(id));
            if (!isStopWord(name)) {
                result.put(id, name);
            }
        }
        return result;
    }

    /**
     * Returns Map ontology term id -> set of
     * ids of all its parts (part_of relationship) and subclasses (is_a).
     *
     * @return Map to expand ontology term
     */
    public Map<String, Set<String>> getOntologyIdExpansionMap()
    {
        Map<String, Set<String>> result = new HashMap<String, Set<String>>();
        for (String id : efoMap.keySet()) {
            String name = trimLowercaseString(getTermNameById(id));
            if (!isStopWord(name)) {
                Set<String> expansionSet = new LinkedHashSet<String>();
                addParts(expansionSet, getIdToPartIdsMap().get(id));
                addChildren(expansionSet, id);
                if (!expansionSet.isEmpty()) {
                    result.put(id, expansionSet);
                }
            }
        }
        return result;
    }

    private void addChildrenRecursively( Set<String> expansionSet, String id )
    {
        expansionSet.addAll(getAllChildrenNames(id));
    }

    private void addChildren( Set<String> expansionSet, String id )
    {
        expansionSet.addAll(getChildrenIds(id));
    }

    private void addPartsRecursively( Set<String> expansionSet, Set<String> parts )
    {
        if (null != parts && parts.size() > 0) {
            expansionSet.addAll(parts);
            for (String part : parts) {
                addPartsRecursively(expansionSet, nameToPartsMap.get(part));
            }
        }
    }

    private void addParts( Set<String> expansionSet, Set<String> parts )
    {
        if (null != parts && parts.size() > 0) {
            expansionSet.addAll(parts);
        }
    }


    public Map<String, Set<String>> getSynonymMap()
    {
        return nameToAlternativesMap;
    }

    public Map<String, Set<String>> getPartOfExpansionMap()
    {
        return nameToPartsMap;
    }


    /*
     * Helper factory method to make term classes
     *
     * @param node internal node to make it from
     * @return external term object
     */
    private EFOTerm newTerm( EFONode node )
    {
        return new EFOTerm(node, roots.contains(node));
    }

    /*
     * Helper factory method to make term classes
     *
     * @param node  internal node to make it from
     * @param depth required depth
     * @return external term object
     */
    private EFOTerm newTerm( EFONode node, int depth )
    {
        return new EFOTerm(node, depth, roots.contains(node));
    }

    /**
     * Constructor loading ontology data.
     *
     * @param ontologyStream InputStream with ontology.
     */
    public EFOOntologyHelper( InputStream ontologyStream )
    {
        OntologyLoader<EFONode> loader = new OntologyLoader<EFONode>(ontologyStream);
        this.efoMap = loader.load(
                new EFOClassAnnotationVisitor(this.nameToAlternativesMap)
                , new EFOPartOfPropertyVisitor(this.nameToPartsMap, this.idToPartIdsMap)
        );

        for (EFONode n : efoMap.values()) {
            if (n.getParents().isEmpty()) {
                roots.add(n);
            }
        }
    }

    /**
     * Fetch term string by id
     *
     * @param id term id
     * @return term string
     */
    public String getTermNameById( String id )
    {
        EFONode node = efoMap.get(id);
        return null == node ? null : node.getTerm();
    }

    /**
     * Check if term is here
     *
     * @param id term id
     * @return true if yes
     */
    public boolean hasTerm( String id )
    {
        EFONode node = efoMap.get(id);
        return null != node;
    }

    /**
     * Fetch term by id
     *
     * @param id term id
     * @return external term representation if found in ontology, null otherwise
     */
    public EFOTerm getTermById( String id )
    {
        EFONode node = efoMap.get(id);
        return null == node ? null : newTerm(node);
    }

    private void collectChildren( Collection<String> result, EFONode node )
    {
        for (EFONode n : node.getChildren()) {
            result.add(n.getId());
            collectChildren(result, n);
        }
    }

    private void collectChildrenNames( Collection<String> result, EFONode node )
    {
        for (EFONode n : node.getChildren()) {
            String name = trimLowercaseString(n.getTerm());
            if (!isStopWord(name)) {
                result.add(name);
            }
            collectChildrenNames(result, n);
        }
    }

    /**
     * Returns collection of IDs of node itself and all its children recursively
     *
     * @param id term id
     * @return collection of IDs, empty if term is not found
     */
    public Collection<String> getTermAndAllChildrenIds( String id )
    {
        EFONode node = efoMap.get(id);
        List<String> ids = new ArrayList<String>(null == node ? 0 : node.getChildren().size());
        if (null != node) {
            collectChildren(ids, node);
            ids.add(node.getId());
        }
        return ids;
    }

    /**
     * Returns collection of names of node itself and all its children recursively
     *
     * @param id term id
     * @return collection of names, empty if term is not found
     */
    public Collection<String> getTermAndAllChildrenNames( String id )
    {
        EFONode node = efoMap.get(id);
        Set<String> names = new HashSet<String>(null == node ? 0 : node.getChildren().size());
        if (null != node) {
            collectChildrenNames(names, node);
            String name = trimLowercaseString(node.getTerm());
            if (!isStopWord(name)) {
                names.add(name);
            }
        }
        return names;
    }

    public Collection<String> getAllChildrenNames( String id )
    {
        EFONode node = efoMap.get(id);
        Set<String> ids = new HashSet<String>(null == node ? 0 : node.getChildren().size());
        Set<String> names = new HashSet<String>(null == node ? 0 : node.getChildren().size());
        if (null != node) {
            collectChildren(ids, node);
            for (String childId : ids) {
                names.addAll(getTermAndAllChildrenNames(childId));
            }
        }
        return names;
    }

    /**
     * Returns collection of term's direct children
     *
     * @param id term id
     * @return collection of terms, null if term is not found
     */
    public Collection<EFOTerm> getTermChildren( String id )
    {
        EFONode node = efoMap.get(id);
        if (null == node)
            return null;

        List<EFOTerm> result = new ArrayList<EFOTerm>(node.getChildren().size());
        for (EFONode n : node.getChildren())
            result.add(newTerm(n));

        return result;
    }

    /**
     * Returns collection of term's direct children names
     *
     * @param id term id
     * @return collection of names, null if term is not found
     */
    public Collection<String> getChildrenNames( String id )
    {
        EFONode node = efoMap.get(id);
        if (null == node)
            return null;

        List<String> result = new ArrayList<String>(node.getChildren().size());
        for (EFONode n : node.getChildren())
            result.add(n.getTerm());

        return result;
    }

    /**
     * Returns collection of term's direct children ids
     *
     * @param id term id
     * @return collection of ids, null if term is not found
     */
    public Collection<String> getChildrenIds( String id )
    {
        EFONode node = efoMap.get(id);
        if (null == node)
            return null;

        List<String> result = new ArrayList<String>(node.getChildren().size());
        for (EFONode n : node.getChildren())
            result.add(n.getId());

        return result;
    }


    /**
     * Returns collection of all terms (depth=0)
     *
     * @return collection of all terms
     */
    public Collection<EFOTerm> getAllTerms()
    {
        List<EFOTerm> result = new ArrayList<EFOTerm>(efoMap.size());
        for (EFONode n : efoMap.values())
            result.add(newTerm(n));
        return result;
    }

    /**
     * Returns collection of all term IDs
     *
     * @return set of all term IDs
     */
    public Set<String> getAllTermIds()
    {
        return new HashSet<String>(efoMap.keySet());
    }

    /**
     * Searches for prefix in ontology
     *
     * @param prefix prefix to search
     * @return set of string IDs
     */
    public Set<String> searchTermPrefix( String prefix )
    {
        String lprefix = prefix.toLowerCase();
        Set<String> result = new HashSet<String>();
        for (EFONode n : efoMap.values())
            if (n.getTerm().toLowerCase().startsWith(lprefix) || n.getId().toLowerCase().startsWith(lprefix)) {
                result.add(n.getId());
            }
        return result;
    }

    /**
     * Searches for text in ontology
     *
     * @param text words to search
     * @return collection of terms
     */
    public Collection<EFOTerm> searchTerm( String text )
    {
        final String ltext = text.trim().toLowerCase();
        String regex = ".*\\b\\Q" + ltext.replace("\\E", "").replaceAll("\\s+", "\\\\E\\\\b\\\\s+\\\\b\\\\Q") + "\\E\\b.*";
        List<EFOTerm> result = new ArrayList<EFOTerm>(efoMap.size());
        for (EFONode n : efoMap.values()) {
            if (n.getId().toLowerCase().equals(ltext) || n.getTerm().toLowerCase().equals(ltext))
                result.add(0, newTerm(n)); // exact matches go first
            else if (n.getTerm().toLowerCase().matches(regex))
                result.add(newTerm(n));
        }
        return result;
    }

    private void collectPaths( EFONode node, Collection<List<EFOTerm>> result, List<EFOTerm> current, boolean stopOnBranchRoot )
    {
        for (EFONode p : node.getParents()) {
            List<EFOTerm> next = new ArrayList<EFOTerm>(current);
            next.add(newTerm(p));
            if (stopOnBranchRoot && p.isBranchRoot())
                result.add(next);
            else
                collectPaths(p, result, next, stopOnBranchRoot);
        }
        if (node.getParents().isEmpty())
            result.add(current);
    }

    /**
     * Returns list of term parent paths (represented as list string from node ending at root)
     *
     * @param id               term id to search
     * @param stopOnBranchRoot if true, stops on branch root, not going to real root
     * @return list of lists of EFOTerm's
     */
    public List<List<EFOTerm>> getTermParentPaths( String id, boolean stopOnBranchRoot )
    {
        EFONode node = efoMap.get(id);
        if (null == node)
            return null;

        List<List<EFOTerm>> result = new ArrayList<List<EFOTerm>>();
        collectPaths(node, result, new ArrayList<EFOTerm>(), stopOnBranchRoot);
        return result;
    }

    /**
     * Returns list of term parent paths (represented as list string from node ending at root)
     *
     * @param term             term to search
     * @param stopOnBranchRoot if true, stops on branch root, not going to real root
     * @return list of lists of EFOTerm's
     */
    public List<List<EFOTerm>> getTermParentPaths( EFOTerm term, boolean stopOnBranchRoot )
    {
        return getTermParentPaths(term.getId(), stopOnBranchRoot);
    }

    /**
     * Returns set of term's direct parent IDs
     *
     * @param id term id
     * @return set of string IDs
     */
    public Set<String> getTermFirstParents( String id )
    {
        EFONode node = efoMap.get(id);
        if (null == node)
            return null;
        Set<String> parents = new HashSet<String>();
        for (EFONode p : node.getParents())
            parents.add(p.getId());
        return parents;
    }

    /**
     * Returns set of term's parent IDs
     *
     * @param id               term id
     * @param stopOnBranchRoot if true, stops on branch root, not going to real root
     * @return set of string IDs
     */
    public Set<String> getTermParents( String id, boolean stopOnBranchRoot )
    {
        EFONode node = efoMap.get(id);
        if (null == node)
            return null;
        Set<String> parents = new HashSet<String>();
        collectParents(node, parents, stopOnBranchRoot);
        return parents;
    }

    private void collectParents( EFONode node, Set<String> parents, boolean stopOnBranchRoot )
    {
        for (EFONode p : node.getParents()) {
            parents.add(p.getId());
            if (!stopOnBranchRoot || !p.isBranchRoot())
                collectParents(p, parents, stopOnBranchRoot);
        }
    }

    private void collectSubTree( EFONode currentNode, List<EFOTerm> result, Set<String> allNodes, Set<String> visited, int depth, boolean printing )
    {
        if (printing && !allNodes.contains(currentNode.getId()))
            return;

        if (!printing && allNodes.contains(currentNode.getId()) && !visited.contains(currentNode.getId()))
            printing = true;

        if (printing) {
            result.add(newTerm(currentNode, depth));
            visited.add(currentNode.getId());
            for (EFONode child : currentNode.getChildren())
                collectSubTree(child, result, allNodes, visited, depth + 1, true);
        } else {
            for (EFONode child : currentNode.getChildren())
                collectSubTree(child, result, allNodes, visited, 0, false);
        }
    }

    /**
     * Creates flat subtree representation ordered in natural print order,
     * each self-contained sub-tree starts from depth=0
     *
     * @param ids marked IDs
     * @return list of EFOTerm's
     */
    public List<EFOTerm> getSubTree( Set<String> ids )
    {
        List<EFOTerm> result = new ArrayList<EFOTerm>();

        Set<String> visited = new HashSet<String>();
        for (EFONode root : roots) {
            collectSubTree(root, result, ids, visited, 0, false);
        }
        return result;
    }

    private void collectTreeDownTo( Iterable<EFONode> nodes, Stack<EFONode> path, List<EFOTerm> result, int depth )
    {
        EFONode next = path.pop();
        for (EFONode n : nodes) {
            result.add(newTerm(n, depth));
            if (n.equals(next) && !path.empty())
                collectTreeDownTo(n.getChildren(), path, result, depth + 1);
        }
    }

    /**
     * Creates flat subtree representation of tree "opened" down to specified node,
     * hence displaying all its parents first and then a tree level, containing specified node
     *
     * @param id term id
     * @return list of EFOTerm's
     */
    public List<EFOTerm> getTreeDownTo( String id )
    {
        List<EFOTerm> result = new ArrayList<EFOTerm>();

        Stack<EFONode> path = new Stack<EFONode>();
        EFONode node = efoMap.get(id);
        while (true) {
            path.push(node);
            if (node.getParents().isEmpty())
                break;
            node = node.getParents().first();
        }

        collectTreeDownTo(roots, path, result, 0);
        return result;
    }

    /**
     * Returns set of root node IDs
     *
     * @return set of root node IDs
     */
    public Set<String> getRootIds()
    {
        Set<String> result = new HashSet<String>();
        for (EFONode n : roots) {
            result.add(n.getId());
        }
        return result;
    }

    /**
     * Returns list of root terms
     *
     * @return list of terms
     */
    public List<EFOTerm> getRoots()
    {
        List<EFOTerm> result = new ArrayList<EFOTerm>(roots.size());
        for (EFONode n : roots)
            result.add(newTerm(n));

        return result;
    }


    /**
     * Returns set of branch root IDs
     *
     * @return set of branch root IDs
     */
    public Set<String> getBranchRootIds()
    {
        Set<String> result = new HashSet<String>();
        for (EFONode n : efoMap.values())
            if (n.isBranchRoot())
                result.add(n.getId());
        return result;
    }

    /**
     * Getter for map id -> set of parts ids map.
     *
     * @return Map id -> set of parts ids map.
     */
    public Map<String, Set<String>> getIdToPartIdsMap()
    {
        return Collections.unmodifiableMap(idToPartIdsMap);
    }
}
