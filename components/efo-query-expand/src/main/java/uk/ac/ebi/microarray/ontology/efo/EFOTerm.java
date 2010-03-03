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

/**
 * External view for EFO node class.
 *
 */
public class EFOTerm
{
    private String id;
    private String term;
    private boolean isExpandable;
    private boolean isBranchRoot;
    private boolean isRoot;
    private int depth;

    protected EFOTerm( EFONode node, boolean isRoot )
    {
        this(node, 0, isRoot);
    }

    /**
     * Constructor to create a term from another one and custom depth
     *
     * @param other original node to clone
     * @param depth depth to set (we can have depth relative to something, not from real root all the time)
     */
    public EFOTerm( EFOTerm other, int depth )
    {
        this.id = other.getId();
        this.term = other.getTerm();
        this.isExpandable = other.isExpandable();
        this.isBranchRoot = other.isBranchRoot();
        this.depth = depth;
        this.isRoot = other.isRoot();
    }

    /**
     * Constructor to create term from internal node
     *
     * @param node   original node
     * @param depth  required depth
     * @param isRoot true if this node is root
     */
    protected EFOTerm( EFONode node, int depth, boolean isRoot )
    {
        this.id = node.getId();
        this.term = node.getTerm();
        this.isExpandable = !node.getChildren().isEmpty();
        this.isBranchRoot = node.isBranchRoot();
        this.depth = depth;
        this.isRoot = isRoot;
    }

    /**
     * Return id of the term
     *
     * @return id of the term
     */
    public String getId()
    {
        return id;
    }

    /**
     * Returns term description string of the term
     *
     * @return term description string of the term
     */
    public String getTerm()
    {
        return term;
    }

    /**
     * Returns if node is expandable (contains children)
     *
     * @return if node is expandable (contains children)
     */
    public boolean isExpandable()
    {
        return isExpandable;
    }

    /**
     * Returns if node is branch root node
     *
     * @return if node is branch root node
     */
    public boolean isBranchRoot()
    {
        return isBranchRoot;
    }

    /**
     * Returns if node is root node
     *
     * @return if node is root node
     */
    public boolean isRoot()
    {
        return isRoot;
    }

    /**
     * Returns node depth
     *
     * @return node depth
     */
    public int getDepth()
    {
        return depth;
    }

    /**
     * Equality check method
     *
     * @param o other term
     * @return true if equal
     */
    @Override
    public boolean equals( Object o )
    {
        if (this == o) return true;
        if (null == o || getClass() != o.getClass()) return false;
        EFOTerm term = (EFOTerm)o;
        return !(null != id ? !id.equals(term.id) : null != term.id);
    }

    /**
     * Returns hash code
     *
     * @return hash code
     */
    @Override
    public int hashCode()
    {
        return null != id ? id.hashCode() : 0;
    }

    /**
     * Returns nice string representation
     *
     * @return printable string
     */
    @Override
    public String toString()
    {
        return id + "(" + term + ")";
    }
}

