package uk.ac.ebi.microarray.ontology;

/**
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

/**
 * @author Anna Zhukova
 */

import org.semanticweb.owl.model.OWLAnnotationVisitor;

import java.util.Collection;

/**
 * Visits annotations of the ontology class, stores useful information and then is able to create appropriate node.
 *
 */
public interface IClassAnnotationVisitor<N extends IOntologyNode> extends OWLAnnotationVisitor
{
    /**
     * Given the id of the ontology class constructs IOntologyNode.
     *
     * @param id Id of the ontology class given.
     * @return IOntologyNode constructed.
     */
    N getOntologyNode( String id );

    /**
     * Given the node corresponding to the ontology class and nodes corresponding to its children
     * and information if this class is organisational updates this ontology node in appropriate way.
     *
     * @param node                 IOntologyNode given.
     * @param children             Child nodes.
     */
    void updateOntologyNode( N node, Collection<N> children );


    /**
     * This needs to be called every time visitor is about to visit a new node.
     */
    void newNode();
}
