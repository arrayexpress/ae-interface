package uk.ac.ebi.fg.utils.objects;

import java.io.Serializable;

public class PubMedId implements Comparable, Serializable
{
    private String publicationId;
    private int distance;

    public PubMedId( String publicationId, int distance )
    {
        this.publicationId = publicationId;
        this.distance = distance;
    }

    public String getPublicationId()
    {
        return publicationId;
    }

    public int getDistance()
    {
        return distance;
    }

    @Override
    public int hashCode()
    {
        return publicationId.hashCode();
    }

    @Override
    public boolean equals(Object other) {
        if (this == other) return true;
        if (null == other || getClass() != other.getClass()) return false;
        PubMedId a = (PubMedId)other;

        if ( publicationId.equals(a.getPublicationId()) )
            return true;
        return false;
    }

    public int compareTo(Object other) {
        PubMedId a = (PubMedId)other;

        return publicationId.compareTo(a.publicationId);
    }
}
