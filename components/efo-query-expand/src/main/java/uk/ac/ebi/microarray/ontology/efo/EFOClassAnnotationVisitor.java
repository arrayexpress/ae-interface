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

import org.semanticweb.owl.model.OWLConstant;
import org.semanticweb.owl.model.OWLConstantAnnotation;
import org.semanticweb.owl.model.OWLObjectAnnotation;
import uk.ac.ebi.microarray.ontology.IClassAnnotationVisitor;

import java.util.*;

import static uk.ac.ebi.microarray.ontology.efo.Utils.*;

/**
 * Visits annotations of the EFO ontology class,
 * stores useful information and then is able to create appropriate node.
 *
 */
public class EFOClassAnnotationVisitor implements IClassAnnotationVisitor<EFONode>
{

    private Map<String, Set<String>> nameToAlternativesMap;

    private String term;
    private boolean isBranchRoot;
    private boolean isOrganizational;
    private Set<String> alternatives = new HashSet<String>();

    public EFOClassAnnotationVisitor()
    {
        this(new HashMap<String, Set<String>>());
    }

    public EFOClassAnnotationVisitor( Map<String, Set<String>> nameToAlternativesMap )
    {
        this.nameToAlternativesMap = nameToAlternativesMap;
    }

     /**
     * Clears internal state before visiting a new node
     *
     */
    public void newNode()
    {
        this.term = null;
        this.isBranchRoot = false;
        this.isOrganizational = false;
        this.alternatives.clear();
    }

    /**
     * Visits the given annotation. If it is label, "branch_class", "organizational_class",
     * "ArrayExpress_label" or "alternative_term" one, stores corresponding information.
     *
     * @param annotation Annotation to visit.
     */
    public void visit( OWLConstantAnnotation annotation )
    {
        if (annotation.isLabel()) {
            OWLConstant c = annotation.getAnnotationValue();
            if (null == this.term)
                this.term = c.getLiteral();
        } else if (annotation.getAnnotationURI().toString().contains("branch_class")) {
            this.isBranchRoot = Boolean.valueOf(annotation.getAnnotationValue().getLiteral());
        } else if (annotation.getAnnotationURI().toString().contains("organizational_class")) {
            this.isOrganizational = Boolean.valueOf(annotation.getAnnotationValue().getLiteral());
        } else if (annotation.getAnnotationURI().toString().contains("ArrayExpress_label")) {
            this.term = annotation.getAnnotationValue().getLiteral();
        } else if (annotation.getAnnotationURI().toString().contains("alternative_term")) {
            String alternativeTerm = annotation.getAnnotationValue().getLiteral();
            if (-1 != alternativeTerm.indexOf("[accessedResource: CHEBI:")) {
                alternativeTerm = preprocessChebiString(alternativeTerm);
            } else {
                alternativeTerm = preprocessAlternativeTermString(alternativeTerm);
            }
            this.alternatives.add(alternativeTerm);
        }
    }

    /**
     * Ignores.
     *
     * @param annotation Annotation to ignore.
     */
    public void visit( OWLObjectAnnotation annotation )
    {
    }

    /**
     * Returns label of just visited class.
     *
     * @return Label of just visited class.
     */
    public String getTerm()
    {
        return this.term;
    }

    /**
     * Returns if just visited class is annotated as a banch root.
     *
     * @return If just visited class is annotated as a banch root.
     */
    public boolean isBranchRoot()
    {
        return this.isBranchRoot;
    }

    /**
     * Returns if just visited class is annotated as an organizational one.
     *
     * @return If just visited class is annotated as an organizational one.
     */
    public boolean isOrganizational()
    {
        return this.isOrganizational;
    }

    /**
     * Returns set of "alternative_term" annotations for just visited class.
     *
     * @return Set of "alternative_term" annotations for just visited class.
     */
    public Set<String> getAlternatives()
    {
        return this.alternatives;
    }

    /**
     * Given a class if creates a EFONode.
     *
     * @param id Id of the ontology class given.
     * @return EFONode created.
     */
    public EFONode getOntologyNode( String id )
    {
        EFONode node = new EFONode(id, getTerm(), isBranchRoot());
        if (!isOrganizational()) {
            addAlternativesToMap(getTerm());
        }
        return node;
    }

    /**
     * Given the node corresponding to the ontology class and nodes corresponding to its children
     * and information if this class is organisational updates this ontology node children set
     * and their parents sets (if the given node is not organizational).
     *
     * @param node                 IOntologyNode given.
     * @param children             Child nodes.
     * @param isNodeOrganizational If the given node is organizational.
     */
    public void updateOntologyNode( EFONode node, Collection<EFONode> children, boolean isNodeOrganizational )
    {
        for (EFONode child : children) {
            node.getChildren().add(child);
            if (!isNodeOrganizational) {
                child.getParents().add(node);
            }
        }
    }

    /**
     * Given a term updates alternative map.
     *
     * @param term Given term.
     */
    private void addAlternativesToMap( String term )
    {
        String lowerCaseTerm = trimLowercaseString(term);
        if (!isStopWord(lowerCaseTerm)) {
            Set<String> alternatives = getAlternatives();
            if (!alternatives.isEmpty()) {
                Set<String> existingAlternatives = getNameToAlternativesMap().get(lowerCaseTerm);
                if (null == existingAlternatives) {
                    existingAlternatives = new HashSet<String>();
                    this.nameToAlternativesMap.put(lowerCaseTerm, existingAlternatives);
                }
                for (String alternativeTerm : alternatives) {
                    if (isStopWord(alternativeTerm)) {
                        continue;
                    }
                    if (lowerCaseTerm.equals(alternativeTerm)) {
                        continue;
                    }
                    existingAlternatives.add(alternativeTerm);
                }
            }
        }
    }

    /**
     * Returns map node name (term) -> set of alternative names.
     *
     * @return Unmodifiable map node name (term) -> set of alternative names.
     */
    public Map<String, Set<String>> getNameToAlternativesMap()
    {
        return Collections.unmodifiableMap(nameToAlternativesMap);
    }
}
