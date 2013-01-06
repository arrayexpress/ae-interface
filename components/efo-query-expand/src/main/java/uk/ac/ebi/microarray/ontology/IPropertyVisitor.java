package uk.ac.ebi.microarray.ontology;

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

/**
 * Strategy of nodes relationship induced by the property processing.
 *
 */
public interface IPropertyVisitor<N extends IOntologyNode>
{
    /**
     * What property we are intrested in.
     *
     * @return Property.
     */
    String getPropertyName();

    /**
     * Process relationshid forsed by the property we are interested in between given nodes.
     *
     * @param node   First node.
     * @param friend Second node.
     */
    void inRelationship( N node, N friend );
}
