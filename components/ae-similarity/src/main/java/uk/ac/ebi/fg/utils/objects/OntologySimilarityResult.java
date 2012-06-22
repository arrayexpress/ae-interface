package uk.ac.ebi.fg.utils.objects;

import java.io.Serializable;

public class OntologySimilarityResult implements Comparable, Serializable
{
    private String URI;
    private int distance;

    public OntologySimilarityResult(String name, int distance)
    {
        this.distance = distance;
        this.URI = name;
    }

    public String getURI()
    {
        return URI;
    }

    public int getDistance()
    {
        return distance;
    }

    public int compareTo(Object other)
    {
        OntologySimilarityResult a = (OntologySimilarityResult)other;

        if (distance == a.distance)
            return URI.compareTo(a.URI);
        return new Integer(distance).compareTo(a.distance);
    }

    public String toString()
    {
        return URI + " " + distance;
    }
}
