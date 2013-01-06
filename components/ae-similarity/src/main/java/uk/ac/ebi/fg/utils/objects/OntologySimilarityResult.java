package uk.ac.ebi.fg.utils.objects;

/*
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

import java.io.Serializable;

public class OntologySimilarityResult implements Comparable, Serializable
{
    private String URI;
    private int distance;

    public OntologySimilarityResult( String name, int distance )
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

    public int compareTo( Object other )
    {
        OntologySimilarityResult a = (OntologySimilarityResult) other;

        if (distance == a.distance)
            return URI.compareTo(a.URI);
        return new Integer(distance).compareTo(a.distance);
    }

    public String toString()
    {
        return URI + " " + distance;
    }
}
