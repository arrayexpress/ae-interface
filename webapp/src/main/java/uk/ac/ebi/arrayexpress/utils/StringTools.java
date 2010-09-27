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
            if (-1 != entityEnd && in.substring(entityStart + 2, entityEnd).matches("^\\d{4,}$")) {
                // good stuff, we found decimal entity
                out.append((char) Integer.parseInt(in.substring(entityStart + 2, entityEnd)));
                currentIndex = entityEnd + 1;
            } else {
                out.append("&#");
                currentIndex = entityStart + 2;
            }
        }
        return out.toString();
    }

    private static char ILLEGAL_CHAR_REPRESENATION = 0xfffd;
    private static char C1_CONTROL_TRANSCODE_MAP[] = {
            8364, ILLEGAL_CHAR_REPRESENATION, 8218, 402, 8222, 8230, 8224, 8225,
            710, 8240, 352, 8249, 338, ILLEGAL_CHAR_REPRESENATION, 381, ILLEGAL_CHAR_REPRESENATION,
            ILLEGAL_CHAR_REPRESENATION, 8216, 8217, 8220, 8221, 8226, 8211, 8212,
            732, 8482, 353, 8250, 339, ILLEGAL_CHAR_REPRESENATION, 382, 376
    };

    public static String escapeChar( char in )
    {
        return "&#" + String.valueOf((int) in) + ";";
    }

    public static String replaceIllegalHTMLCharacters( String in )
    {
        if (null == in)
            return null;

        StringBuilder out = new StringBuilder(in.length() * 2);
        char current;

        for (int i = 0; i < in.length(); i++) {
            current = in.charAt(i);
            if (0x09 == current || 0x0a == current || 0x0d == current || (current >= 0x20 && current <= 0x7e)) {
                out.append(current);
            } else if (current >= 0x80 && current <= 0x9f) {
                out.append(escapeChar(C1_CONTROL_TRANSCODE_MAP[current - 0x80]));
            } else if ((current >= 0xa0 && current <= 0xd7ff) || (current >= 0xe000 && current <= 0xfffd) || (current >= 0x10000 && current <= 0x10ffff)) {
                out.append(escapeChar(current));
            } else {
                out.append(escapeChar(ILLEGAL_CHAR_REPRESENATION));
            }
        }
        return out.toString();
    }

    public static String detectDecodeUTF8Sequences( String in )
    {
        if (null == in)
            return null;

        StringBuilder sb = new StringBuilder(in.length() * 2);

        char ch, decoded;
        for (int ix = 0; ix < in.length(); ++ix) {
            ch = in.charAt(ix);

            if (ch <= 0x7f) {
                // there are no problems with ascii
                sb.append(ch);
            } else if (ch >= 0xc2 && ch <= 0xdf && (ix + 1) < in.length()) {
                // this is possibly a start of two-byte utf-8 sequence
                // let's try to decode it and if it's any good, use it
                // or just copy the original sequence
                decoded = StringTools.decodeUTF8((byte) ch, (byte) in.charAt(ix + 1));
                if (ILLEGAL_CHAR_REPRESENATION == decoded) {
                    sb.append(ch);
                } else {
                    sb.append(decoded);
                    ix++;
                }
            } else if (ch >= 0xe0 && ch <= 0xef && (ix + 2) < in.length()) {
                // this is possibly a start of three-byte utf-8 sequence
                // let's try to decode it and if it's any good, use it
                // or just copy the original sequence
                decoded = StringTools.decodeUTF8((byte) ch, (byte) in.charAt(ix + 1), (byte) in.charAt(ix + 2));
                if (-1 == decoded) {
                    sb.append(ch);
                } else {
                    sb.append(decoded);
                    ix = +2;
                }
            } else {
                // the rest is interpreted as pure unicode (we don't decode four-byte utf-8's)
                sb.append(ch);
            }
        }
        return sb.toString();
    }

    public static char decodeUTF8( byte b0, byte b1 )
    {
        if ((0xc0 == (b0 & 0xe0)) && (0x80 == (b1 & 0xc0))) {
            return (char) (((b0 & 0x1f) << 6) + (b1 & 0x3f));
        } else {
            return ILLEGAL_CHAR_REPRESENATION;
        }
    }

    public static char decodeUTF8( byte b0, byte b1, byte b2 )
    {
        if ((0xe0 == (b0 & 0xf0)) && (0x80 == (b1 & 0xc0)) && (0x80 == (b2 & 0xc0))) {
            return (char) (((b0 & 0x0f) << 12) + ((b1 & 0x3f) << 6) + (b2 & 0x3f));
        } else {
            return ILLEGAL_CHAR_REPRESENATION;
        }
    }

}
