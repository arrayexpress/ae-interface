package uk.ac.ebi.microarray.ontology.efo;

/**
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

/**
 * @author Anna Zhukova
 */

/**
 * Class providing methods of string normalization and map format conversion.
 *
 */
public final class Utils
{
    /**
     * For null string returns an empty one,
     * for not null strings returns its trimmed copy
     * with leading and trailing white spaces removed.
     *
     * @param str String to trim.
     * @return an empty string if the given one was null,
     *         trimmed copy of the given one
     *         with leading and trailing white spaces removed otherwise.
     */
    public static String safeStringTrim( String str )
    {
        return null == str ? "" : str.trim();
    }


    /**
     * For null string returns an empty one,
     * for not null strings returns its trimmed copy with EFO-specific information removed
     *
     * @param str String to preprocess.
     * @return an empty string if the given one was null,
     *         otherwise preprocessed string.
     */
    public static String preprocessAlternativeTermString( String str )
    {
        if (null == str) {
            return "";
        }
        // removing service
        return str.replaceAll("(\\[accessedResource:[^\\]]+\\])|(\\[accessDate:[^\\]]+\\])", "").trim();
    }

  

}
