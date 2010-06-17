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
    public final static String EOL = System.getProperty("line.separator");

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

    public static String fileToString( File persistenceFile ) throws IOException
    {
        StringBuilder result = new StringBuilder();
        if (persistenceFile.exists()) {
            BufferedReader r = new BufferedReader(new InputStreamReader(new FileInputStream(persistenceFile)));
            while (r.ready()) {
                String str = r.readLine();
                // null means stream has reached the end
                if (null != str) {
                    result.append(str).append(EOL);
                } else {
                    break;
                }
            }
        } else {
            return null;
        }

        return result.toString();
    }

}
