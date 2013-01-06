package uk.ac.ebi.microarray.ontology.efo;

/**
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

/**
 * @author Anna Zhukova
 */

import org.semanticweb.owl.model.OWLConstant;
import org.semanticweb.owl.model.OWLConstantAnnotation;
import org.semanticweb.owl.model.OWLObjectAnnotation;
import uk.ac.ebi.microarray.ontology.IClassAnnotationVisitor;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

/**
 * Visits annotations of the EFO ontology class,
 * stores useful information and then is able to create appropriate node.
 *
 */
public class EFOClassAnnotationVisitor implements IClassAnnotationVisitor<EFONode>
{

    private String term;
    private String efoUri;
    private boolean isBranchRoot;
    private boolean isOrganizational;
    private Set<String> alternatives;

     /**
     * Clears internal state before visiting a new node
     *
     */
    public void newNode()
    {
        this.term = null;
        this.efoUri = null;
        this.isBranchRoot = false;
        this.isOrganizational = false;
        this.alternatives = new HashSet<String>();
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
        } else if (annotation.getAnnotationURI().toString().contains("EFO_URI")) {
            this.efoUri = annotation.getAnnotationValue().getLiteral();
        } else if (annotation.getAnnotationURI().toString().contains("alternative_term")) {
            String alternativeTerm = annotation.getAnnotationValue().getLiteral();
            this.alternatives.add(Utils.preprocessAlternativeTermString(alternativeTerm));
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
     * Given a class if creates a EFONode.
     *
     * @param id Id of the ontology class given.
     * @return EFONode created.
     */
    public EFONode getOntologyNode( String id )
    {
        return new EFONode(
                id
                , null != getEfoUri() ? getEfoUri() : id
                , getTerm()
                , getAlternatives()
                , isBranchRoot()
                , isOrganizational()
        );
    }

    /**
     * Given the node corresponding to the ontology class and nodes corresponding to its children
     * and information if this class is organisational updates this ontology node children set
     * and their parents sets (if the given node is not organizational).
     *
     * @param node                 IOntologyNode given.
     * @param children             Child nodes.
     */
    public void updateOntologyNode( EFONode node, Collection<EFONode> children )
    {
        for (EFONode child : children) {
            node.getChildren().add(child);
            child.getParents().add(node);
        }
    }

    /**
     * Returns the value of "ArrayExpress_label" annotation property.
     *
     * @return Value of "ArrayExpress_label" annotation property.
     */
    public String getTerm()
    {
        return this.term;
    }

    /**
     * Returns EFO URI if specified.
     *
     * @return EFO URI
     */
    public String getEfoUri()
    {
        return this.efoUri;
    }

    /**
     * Returns the value of "branch_class" annotation property.
     *
     * @return Value of "branch_class" annotation property.
     */
    public boolean isBranchRoot()
    {
        return this.isBranchRoot;
    }

    /**
     * Returns the value of "organizational_class" annotation property.
     *
     * @return Value of "organization_class" annotation property.
     */
    public boolean isOrganizational()
    {
        return this.isOrganizational;
    }

    /**
     * Returns set of "alternative_term" annotation properties.
     *
     * @return Set of "alternative_term" annotation properties.
     */
    public Set<String> getAlternatives()
    {
        return this.alternatives;
    }
}
