package uk.ac.ebi.microarray.ontology.efo;

/**
 * Copyright 2009-2010 European Molecular Biology Laboratory
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

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

/**
 * Class providing methods of string normalization and map format conversion.
 *
 */
public final class Utils
{
    /**
     * Checks if the given string should not be added to the list of terms.
     * Current rule is that we filter out null strings or strings shorter than 3 characters
     *
     * @param str String to check.
     * @return true if the given string is a stop word (i.e. should not be added to the index)
     */
    public static boolean isStopTerm( String str )
    {
        return null == str || str.length() < 3;
    }

    /**
     * Checks if the given string should not be added to the list of synonyms.
     * Current rule is that we filter out null strings, strings shorter than 3 characters
     * and strings contain some patterns that we established
     *
     * @param str String to check.
     * @return true if the given string is a stop word (i.e. should not be added to the index)
     */
    public static boolean isStopSynonym( String str )
    {
        return isStopTerm(str) || str.matches(".*(\\s\\(.+\\)|\\s\\[.+\\]|,\\s|\\s-\\s|/|NOS).*");
    }

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

    /**
     * Converts Map&lt;String, String[]&gt; to Map&lt;String[], String[][]&gt;
     * by splitting each value into words aroung whitespaces.
     *
     * @param from Map&lt;String, String[]&gt; to convert.
     * @return converted Map&lt;String[], String[][]&gt;.
     */
    public static Map<String[], String[][]> string2ArrayOfStringMapToArrayOfString2ArrayOfArrayOfStringMap( Map<String, String[]> from )
    {
        Map<String[], String[][]> result = new HashMap<String[], String[][]>();
        for (Map.Entry<String, String[]> entry : from.entrySet()) {
            String[] value = entry.getValue();
            String[][] synonyms = new String[value.length][];
            int i = 0;
            for (String element : value) {
                synonyms[i++] = element.split(" ");
            }
            result.put(entry.getKey().split(" "), synonyms);
        }
        return result;
    }

    /**
     * Converts Map&lt;T, ? extends Collection&lt;S&gt;&gt;
     * to Map&lt;T[], S[]&gt;
     * by converting values from Collection type to Array.
     *
     * @param from              Map&lt;T, ? extends Collection&lt;S&gt;&gt; to convert.
     * @param sampleOfArrayType Parameter used only for deriving proper array type
     *                          of resulting map values.
     * @return converted Map&lt;T[], S[]&gt;.
     */
    public static <T, S> Map<T, S[]> a2CollectionOfBMapToA2ArrayOfBMap( Map<T, ? extends Collection<S>> from, S[] sampleOfArrayType )
    {
        Map<T, S[]> result = new HashMap<T, S[]>();
        for (Map.Entry<T, ? extends Collection<S>> elements : from.entrySet()) {
            S[] value = elements.getValue().toArray(sampleOfArrayType);
            if (value.length > 0) {
                result.put(elements.getKey(), value);
            }
        }
        return result;
    }

}
