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

import net.sf.saxon.om.NodeInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.components.Experiments;
import uk.ac.ebi.arrayexpress.utils.RegexHelper;

import java.text.SimpleDateFormat;
import java.util.Date;

public class ExtFunctions
{
    // logging machinery
    private static final Logger logger = LoggerFactory.getLogger(ExtFunctions.class);

    public static String fileSizeToString( long size )
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

    private static boolean testCheckbox( String check )
    {
        return (null != check && (check.toLowerCase().equals("true") || check.toLowerCase().equals("on")));
    }
    
    public static String describeQuery( String queryId )
    {
        StringBuilder desc = new StringBuilder();
        /**
        if (!keywords.trim().equals("")) {
            desc.append("'").append(keywords).append("'");
        }
        if (!species.trim().equals("")) {
            if (0 != desc.length()) {
                desc.append(" and ");
            }
            desc.append("species '").append(species).append("'");
        }
        if (!array.trim().equals("")) {
            if (0 != desc.length()) {
                desc.append(" and ");
            }
            desc.append("array '").append(array).append("'");
        }
        if (!experimentType.trim().equals("")) {
            if (0 != desc.length()) {
                desc.append(" and ");
            }
            desc.append("experiment type '").append(experimentType).append("'");
        }

        if (0 != desc.length()) {
            desc.insert(0, "matching ");
        }

        if (testCheckbox(inAtlas)) {
            if (0 != desc.length()) {
                desc.append(" and ");
            }
            desc.append("present in ArrayExpress Atlas");
        }
        **/
        return desc.toString();
    }

    public static String trimTrailingDot( String str )
    {
        if (str.endsWith(".")) {
            return str.substring(0, str.length() - 1);
        } else
            return str;
    }

    public static String dateToRfc822()
    {
        return new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z").format(new Date());
    }

    public static String dateToRfc822( String dateString )
    {
        if (null != dateString && 0 < dateString.length()) {
            try {
                Date date = new SimpleDateFormat("yyyy-MM-dd").parse(dateString);
                dateString = new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z").format(date);
            } catch (Exception x) {
                logger.debug("Caught an exception:", x);
            }
        } else {
            dateString = "";
        }

        return dateString;
    }

    /* ***************************************************** */
    public static boolean isExperimentInAtlas( String accession )
    {
        return ((Experiments)Application.getAppComponent("Experiments"))
                .isInAtlas(accession);
    }

    public static boolean isExperimentAccessible( String accession, String userId )
    {
        return ((Experiments)Application.getAppComponent("Experiments"))
                .isAccessible(accession, userId);
    }

    public static NodeInfo getFilesForAccession( String accession ) throws InterruptedException
    {
        /**
        try {
            List<FtpFileEntry> files = ((Files)Application.getAppComponent("Files"))
                    .getFilesMap()
                    .getEntriesByAccession(accession);
            if (null != files) {
                StringBuilder sb = new StringBuilder("<files>");
                for (FtpFileEntry file : files) {
                    sb.append("<file kind=\"")
                            .append(FtpFileEntry.getKind(file))
                            .append("\" extension=\"")
                            .append(FtpFileEntry.getExtension(file))
                            .append("\" name=\"")
                            .append(FtpFileEntry.getName(file))
                            .append("\" size=\"")
                            .append(String.valueOf(file.getSize()))
                            .append("\" lastmodified=\"")
                            .append(new SimpleDateFormat("d MMMMM yyyy, HH:mm").format(new Date(file.getLastModified())))
                            .append("\"/>");
                    Thread.sleep(1);
                }
                sb.append("</files>");
                return ((SaxonEngine)Application.getAppComponent("SaxonEngine")).buildDocument(sb.toString());
            }
        } catch (InterruptedException x) {
            logger.warn("Method interrupted");
            throw x;
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }
        **/
        return null;
    }

    public static boolean testRegexp( String input, String pattern, String flags )
    {
        boolean result = false;

        try {
            return new RegexHelper(pattern, flags).test(input);
        } catch (Exception t) {
            logger.debug("Caught an exception:", t);
        }

        return result;
    }
}
