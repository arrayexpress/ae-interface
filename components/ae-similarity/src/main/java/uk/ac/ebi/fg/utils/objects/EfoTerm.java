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

public class EfoTerm implements Comparable
{
    private String uri;
    private String textValue;

    public EfoTerm( String uri, String textValue )
    {
        this.uri = uri;
        this.textValue = textValue;
    }

    public String getUri()
    {
        return uri;
    }

    public String getTextValue()
    {
        return textValue;
    }

    public int compareTo( Object object )
    {
        EfoTerm term = (EfoTerm) object;
        return uri.compareTo(term.getUri());
    }

    @Override
    public boolean equals( Object object )
    {
        if (this == object) return true;
        if (null == object || getClass() != object.getClass()) return false;
        EfoTerm efoTerm = (EfoTerm) object;

        if (uri.equals(efoTerm.getUri()))
            return true;
        return false;
    }

    @Override
    public int hashCode()
    {
        return uri.hashCode();
    }
}
