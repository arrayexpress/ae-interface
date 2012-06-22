package uk.ac.ebi.fg.utils.objects;

/*
 * Copyright 2009-2012 European Molecular Biology Laboratory
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
    public boolean equals( Object other )
    {
        if (this == other) return true;
        if (null == other || getClass() != other.getClass()) return false;
        PubMedId a = (PubMedId) other;

        if (publicationId.equals(a.getPublicationId()))
            return true;
        return false;
    }

    public int compareTo( Object other )
    {
        PubMedId a = (PubMedId) other;

        return publicationId.compareTo(a.publicationId);
    }
}
