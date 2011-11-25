package uk.ac.ebi.arrayexpress.utils.efo;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.*;

import java.io.InputStream;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
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

public class EFOLoader
{
    private final static IRI IRI_AE_LABEL = IRI.create("http://www.ebi.ac.uk/efo/ArrayExpress_label");
    private final static IRI IRI_EFO_URI = IRI.create("http://www.ebi.ac.uk/efo/ArrayExpress_label");
    private final static IRI IRI_ALT_TERM = IRI.create("http://www.ebi.ac.uk/efo/alternative_term");
    private final static IRI IRI_PART_OF = IRI.create("http://www.obofoundry.org/ro/ro.owl#part_of");


    private Map<String, Set<String>> reverseSubClassOfMap = new HashMap<String, Set<String>>();
    private Map<String, Set<String>> reversePartOfMap = new HashMap<String, Set<String>>();

    public EFOLoader()
    {
    }

    public IEFO load( InputStream ontologyStream )
    {
        OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
        OWLOntology ontology;
        EFOImpl efo = new EFOImpl();
        try {
            ontology = manager.loadOntologyFromOntologyDocument(ontologyStream);

            Set<OWLClass> classes = ontology.getClassesInSignature();
            for (OWLClass cls : classes) {
                loadClass(ontology, cls, efo);
            }

            // now, complete missing bits in parent-children relationships
            for (String id : reverseSubClassOfMap.keySet()) {
                EFONode node = efo.getMap().get(id);
                for (String parentId : reverseSubClassOfMap.get(id)) {
                    EFONode parentNode = efo.getMap().get(parentId);
                    node.getParents().add(parentNode);
                    parentNode.getChildren().add(node);
                }
            }



        } catch (OWLOntologyCreationException e) {
            throw new RuntimeException("Unable to read ontology from a stream", e);
        }

        return efo;
    }

    private void loadClass( OWLOntology ontology, OWLClass cls, EFOImpl efo )
    {
        // initialise the node
        EFONode node = new EFONode(cls.toStringID());

        // iterate over the annotations to get relevant ones
        Set<OWLAnnotation> annotations = cls.getAnnotations(ontology);
        for (OWLAnnotation annotation : annotations) {
            if (annotation.getValue() instanceof OWLLiteral) {
                String value = ((OWLLiteral)annotation.getValue()).getLiteral();
                if (annotation.getProperty().isLabel() || "".equals(node.getTerm())) {
                    node.setTerm(value);
                } else if (IRI_AE_LABEL.equals(annotation.getProperty().getIRI())) {
                    node.setTerm(value);
                } else if (IRI_EFO_URI.equals(annotation.getProperty().getIRI())) {
                    node.setEfoUri(value);
                } else if (IRI_ALT_TERM.equals(annotation.getProperty().getIRI())) {
                    node.getAlternativeTerms().add(value);
                }
            }
        }
        // adding newly created node to the map
        efo.getMap().put(node.getId(), node);

        // getting some info on relationships
        Set<OWLSubClassOfAxiom> subClassOfAxioms = ontology.getSubClassAxiomsForSubClass(cls);
        for (OWLSubClassOfAxiom subClassOf : subClassOfAxioms ) {
            OWLClassExpression superClass = subClassOf.getSuperClass();
            if (superClass instanceof OWLClass ) {
                if (!reverseSubClassOfMap.containsKey(node.getId())) {
                    reverseSubClassOfMap.put(node.getId(), new HashSet<String>());
                }
                reverseSubClassOfMap.get(node.getId()).add(((OWLClass) superClass).toStringID());
            } else if (superClass instanceof OWLQuantifiedObjectRestriction) {
                // may be part-of
                OWLQuantifiedObjectRestriction restriction = (OWLQuantifiedObjectRestriction)superClass;
                if (IRI_PART_OF == restriction.getProperty().getNamedProperty().getIRI()
                        && restriction.getFiller() instanceof OWLClass) {
                    if (!reversePartOfMap.containsKey(node.getId())) {
                        reversePartOfMap.put(node.getId(), new HashSet<String>());
                    }
                    reversePartOfMap.get(node.getId()).add(((OWLClass) restriction.getFiller()).toStringID());
                }
            }
        }
    }
}
