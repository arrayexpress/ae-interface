package uk.ac.ebi.arrayexpress.utils.saxon;

/*
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

import uk.ac.ebi.arrayexpress.utils.RegExpHelper;

import java.text.SimpleDateFormat;
import java.util.Date;

public class ExtFunctions
{
    public static String capitalize(String str)
    {
        return str.substring(0, 1).toUpperCase() + str.substring(1).toLowerCase();
    }

    public static String fileSizeToString(long size)
    {
        StringBuilder str = new StringBuilder();
        if (922L > size) {
            str.append(size).append(" B");
        } else if (944128L > size) {
            str.append(String.format("%.0f KB", (Long.valueOf(size).doubleValue() / 1024.0)));
        } else if (1073741824L > size) {
            str.append(String.format("%.1f MB", (Long.valueOf(size).doubleValue() / 1048576.0)));
        } else if (1099511627776L > size) {
            str.append(String.format("%.2f GB", (Long.valueOf(size).doubleValue() / 1073741824.0)));
        }
        return str.toString();
    }

    private static boolean testCheckbox(String check)
    {
        return (null != check && (check.toLowerCase().equals("true") || check.toLowerCase().equals("on")));
    }

    public static String describeQuery( String queryId )
    {
        return "Query Description is here :)";
    }

    public static String normalizeSpecies(String species)
    {
        // if more than one word: "First second", otherwise "First"
        String[] spArray = species.trim().split("\\s");
        if (0 == spArray.length) {
            return "";
        } else if (1 == spArray.length) {
            return capitalize(spArray[0]);
        } else {
            return capitalize(spArray[0] + ' ' + spArray[1]);
        }
    }

    public static String[] normalizeAuthors(String authors)
    {
        String[] authorsArray = authors.trim().split("([,;] and )|( and )|([,;]and )|[,;]");
        String[] resultsArray = new String[authorsArray.length];
        int counter = 0;
        for (String author : authorsArray) {
            StringBuilder authorString = new StringBuilder();
            String[] nameArray = author.trim().split("\\s");
            for (String name : nameArray) {
                if (name.length() > 0) {
                    authorString.append(capitalize(name)).append(" ");
                }
            }
            resultsArray[counter++] = authorString.toString();
        }
        return resultsArray;
    }


    public static String trimTrailingDot(String str)
    {
        if (str.endsWith(".")) {
            return str.substring(0, str.length() - 2);
        } else
            return str;
    }

    public static String dateToRfc822()
    {
        return new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z").format(new Date());
    }

    public static String dateToRfc822(String dateString)
    {
        if (null != dateString && 0 < dateString.length()) {
            try {
                Date date = new SimpleDateFormat("yyyy-MM-dd").parse(dateString);
                dateString = new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z").format(date);
            } catch (Exception x) {
                //logger.debug("Caught an exception:", x);
            }
        } else {
            dateString = "";
        }

        return dateString;
    }


    /* ***************************************************** */
    public static boolean isExperimentInAtlas(String accession)
    {
        return true;
    }

    public static boolean isExperimentAccessible(String accession, String userId)
    {
        return true;
    }

    public static boolean testRegexp(String input, String pattern, String flags)
    {
        boolean result = false;

        try {
            return new RegExpHelper(pattern, flags).test(input);
        } catch (Exception t) {
            //logger.debug("Caught an exception:", t);
        }

        return result;

    }
}