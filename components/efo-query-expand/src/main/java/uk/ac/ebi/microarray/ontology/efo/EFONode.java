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

import uk.ac.ebi.microarray.ontology.IOntologyNode;

import java.util.Comparator;
import java.util.SortedSet;
import java.util.TreeSet;

/**
 * Internal EFO class representation structure.
 *
 */
public class EFONode implements IOntologyNode
{
    private String id;
    private String efoUri;
    private String term;
    private boolean isBranchRoot;

    /**
     * Comparator comparing 2 nodes by comparing their terms lexicographically.
     */
    protected static final Comparator<EFONode> TERM_COMPARATOR = new Comparator<EFONode>()
    {
        public int compare( EFONode o1, EFONode o2 )
        {
            return o1.getTerm().compareTo(o2.getTerm());
        }
    };

    private SortedSet<EFONode> children = new TreeSet<EFONode>(TERM_COMPARATOR);
    private SortedSet<EFONode> parents = new TreeSet<EFONode>(TERM_COMPARATOR);

    protected EFONode( String id, String efoUri, String term, boolean isBranchRoot )
    {
        this.setId(id);
        this.setEfoUri(efoUri);
        this.setTerm(term);
        this.setIsBranchRoot(isBranchRoot);
    }

    @Override
    public boolean equals( Object o )
    {
        if (this == o) return true;
        if (null == o || getClass() != o.getClass()) return false;
        EFONode node = (EFONode)o;
        return !(getId() != null ? !getId().equals(node.getId()) : node.getId() != null);
    }

    @Override
    public int hashCode()
    {
        int result = getId() != null ? getId().hashCode() : 0;
        result = 31 * result + (getTerm() != null ? getTerm().hashCode() : 0);
        result = 31 * result + (getChildren() != null ? getChildren().hashCode() : 0);
        return result;
    }

    @Override
    public String toString()
    {
        return getId() + "(" + getTerm() + ")" + (getChildren().isEmpty() ? "" : "+");
    }

    public String getId()
    {
        return id;
    }

    public void setId( String id )
    {
        this.id = id;
    }

   public String getEfoUri()
    {
        return efoUri;
    }

    public void setEfoUri( String efoUri )
    {
        this.efoUri = efoUri;
    }

    public String getTerm()
    {
        return term;
    }

    public void setTerm( String term )
    {
        this.term = term;
    }

    public boolean isBranchRoot()
    {
        return isBranchRoot;
    }

    public void setIsBranchRoot( boolean isBranchRoot )
    {
        this.isBranchRoot = isBranchRoot;
    }

    @SuppressWarnings("unchecked")
    public SortedSet<EFONode> getChildren()
    {
        return children;
    }

    public SortedSet<EFONode> getParents()
    {
        return parents;
    }
}
