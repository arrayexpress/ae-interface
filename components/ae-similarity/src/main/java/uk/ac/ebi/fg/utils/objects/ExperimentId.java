package uk.ac.ebi.fg.utils.objects;

/*
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

import uk.ac.ebi.fg.utils.ReceivingType;

/**
 * Experiment object containing all required fields for PubMed and ontology similarity calculations
 */
public class ExperimentId implements Comparable, Cloneable
{
    private String myAccession;
    private String mySpecies = "";
    private int assayCount = 0;             // hybridisations
    private int myOWLDist = Integer.MAX_VALUE;
    private int myPubMedDist = Integer.MAX_VALUE;
    private int numbOfMatches = 0;
    private int dist0Count = 0;
    private int dist1Count = 0;
    private int dist2Count = 0;
    private int lowPriorityMatchCount = 0;
    private float calculatedDistance = 0;

    public ExperimentId clone()
    {
        try {
            return (ExperimentId) super.clone();
        } catch (CloneNotSupportedException e) {
            System.out.println("Cloning not allowed");      // todo: check error
            return null;
        }
    }

    public ExperimentId( String id, ReceivingType rType, String species, int assayCount )
    {
        this.myAccession = id;
        this.mySpecies = species;
        if (rType.equals(ReceivingType.PUBMED))
            myPubMedDist = Integer.MAX_VALUE - 1;
        else if (rType.equals(ReceivingType.OWL))
            myOWLDist = Integer.MAX_VALUE - 1;
        this.assayCount = assayCount;
    }

    public String getSpecies()
    {
        return mySpecies;
    }

    public ExperimentId( String id, ReceivingType rType, int dist )
    {
        this.myAccession = id;
        if (rType.equals(ReceivingType.PUBMED))
            myPubMedDist = dist;
        else if (rType.equals(ReceivingType.OWL))
            myOWLDist = dist;
    }

    public String getAccession()
    {
        return myAccession;
    }

    public ReceivingType getType()
    {
        if (myOWLDist != Integer.MAX_VALUE) {
            if (myPubMedDist != Integer.MAX_VALUE)
                return ReceivingType.PUBMED_AND_OWL;
            else
                return ReceivingType.OWL;
        } else if (myPubMedDist != Integer.MAX_VALUE)
            return ReceivingType.PUBMED;
        return ReceivingType.NONE;
    }

    public int getPubMedDistance()
    {
        return myPubMedDist;
    }

    public int getOWLDistance()
    {
        return myOWLDist;
    }

    public void setNumbOfMatches( int amount )
    {
        numbOfMatches = amount;
    }

    public void setDist0Count( int count )
    {
        dist0Count = count;
    }

    public void setDist1Count( int count )
    {
        dist1Count = count;
    }

    public void setDist2Count( int count )
    {
        dist2Count = count;
    }

    public void setLowPriorityMatchCount( int count )
    {
        lowPriorityMatchCount = count;
    }

    public void setCalculatedDistance( float distance )
    {
        calculatedDistance = distance;
    }

    public void setAssayCount( int count )
    {
        assayCount = count;
    }

    public int getNumbOfMatches()
    {
        return numbOfMatches;
    }

    public int getDist0Count()
    {
        return dist0Count;
    }

    public int getDist1Count()
    {
        return dist1Count;
    }

    public int getDist2Count()
    {
        return dist2Count;
    }

    public int getLowPriorityMatchCount()
    {
        return lowPriorityMatchCount;
    }

    public float getCalculatedDistance()
    {
        return calculatedDistance;
    }

    public int getAssayCount()
    {
        return assayCount;
    }

    @Override
    public int hashCode()
    {
        return myAccession.hashCode();
    }

    @Override
    public boolean equals( Object other )
    {
        if (this == other) return true;
        if (null == other || getClass() != other.getClass()) return false;
        ExperimentId a = (ExperimentId) other;

        if (myAccession.equals(a.myAccession))
            return true;
        return false;
    }

    public int compareTo( Object other )
    {
        ExperimentId a = (ExperimentId) other;

        return myAccession.compareTo(a.myAccession);
    }

    public String toString()
    {
        return "[" + myAccession + ", " + getType() + "]  ";
    }
}
