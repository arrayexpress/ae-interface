package uk.ac.ebi.arrayexpress.utils;

import java.io.*;

/*
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

public class StringTools
{
    private StringTools()
    {
    }

    public static String arrayToString( String[] a, String separator )
    {
        if (a == null || separator == null) {
            return null;
        }

        StringBuilder result = new StringBuilder();
        if (a.length > 0) {
            result.append(a[0]);
            for (int i = 1; i < a.length; i++) {
                result.append(separator);
                result.append(a[i]);
            }
        }
        return result.toString();
    }

    public static String streamToString( InputStream is ) throws IOException
    {
        if (is != null) {
            StringBuilder sb = new StringBuilder();
            String line;
            try {
                BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"));
                while ((line = reader.readLine()) != null) {
                    sb.append(line).append("\n");
                }
            } finally {
                is.close();
            }
            return sb.toString();
        } else {
            return "";
        }
    }

    public static void stringToFile( String string, File file ) throws IOException
    {
        BufferedWriter w = new BufferedWriter(new FileWriter(file));
        w.write(string);
        w.close();
    }

    public static String unescapeXMLDecimalEntities( String in )
    {
        StringBuilder out = new StringBuilder();

        if (in == null || ("".equals(in))) return "";

        int entityStart;
        int entityEnd;
        int currentIndex = 0;

        while (currentIndex < in.length()) {
            entityStart = in.indexOf("&#", currentIndex);
            if (-1 == entityStart) {
                out.append(in.substring(currentIndex));
                break;
            }
            out.append(in.substring(currentIndex, entityStart));
            entityEnd = in.indexOf(";", entityStart);
            if (-1 != entityEnd && in.substring(entityStart + 2, entityEnd).matches("^\\d+$")) {
                // good stuff, we found decimal entity
                out.append((char)Integer.parseInt(in.substring(entityStart + 2, entityEnd)));
                currentIndex = entityEnd + 1;
            } else {
                out.append("&#");
                currentIndex = entityStart + 2;
            }
        }
        return out.toString();
    }


    /**
     * This method ensures that the output String has only
     * valid XML unicode characters as specified by the
     * XML 1.0 standard. For reference, please see
     * <a href="http://www.w3.org/TR/2000/REC-xml-20001006#NT-Char">the
     * standard</a>. This method will return an empty
     * String if the input is null or empty.
     *
     * @param in The String whose non-valid characters we want to remove.
     * @return The in String, stripped of non-valid characters.
     */
    public static String stripNonValidXMLCharacters( String in )
    {
        StringBuilder out = new StringBuilder(); // Used to hold the output.
        char current; // Used to reference the current character.

        if (in == null || ("".equals(in))) return ""; // vacancy test.
        for (int i = 0; i < in.length(); i++) {
            current = in.charAt(i); // NOTE: No IndexOutOfBoundsException caught here; it should not happen.
            if ((current == 0x9) ||
                    (current == 0xA) ||
                    (current == 0xD) ||
                    ((current >= 0x20) && (current <= 0xD7FF)) ||
                    ((current >= 0xE000) && (current <= 0xFFFD)) ||
                    ((current >= 0x10000) && (current <= 0x10FFFF)))
                out.append(current);
        }
        return out.toString();
    }
}
