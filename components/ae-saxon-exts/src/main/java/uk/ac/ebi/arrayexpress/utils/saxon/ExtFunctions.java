package uk.ac.ebi.arrayexpress.utils.saxon;

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

public class ExtFunctions
{
    public static String formatFileSize( long size )
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

    public static String trimTrailingDot( String str )
    {
        if (str.endsWith(".")) {
            return str.substring(0, str.length() - 2);
        } else
            return str;
    }

    public synchronized static void clearAccelerator( String acceleratorName )
    {
    }

    public synchronized static void addAcceleratorValue( String acceleratorName, String key, String value )
    {
    }

    public synchronized static String getAcceleratorValue( String acceleratorName, String key )
    {
        return "1";
    }
}