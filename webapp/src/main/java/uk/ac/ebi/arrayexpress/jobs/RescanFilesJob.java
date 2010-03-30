package uk.ac.ebi.arrayexpress.jobs;

/*
 * Copyright 2009-2010 Functional Genomics Group, European Bioinformatics Institute
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

import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.app.ApplicationJob;
import uk.ac.ebi.arrayexpress.components.Files;
import uk.ac.ebi.arrayexpress.utils.RegexHelper;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;

public class RescanFilesJob extends ApplicationJob
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public void doExecute( JobExecutionContext jec ) throws InterruptedException
    {
        StringBuilder xmlString = new StringBuilder(20000000);
        Application app = Application.getInstance();

        String rootFolder = ((Files)app.getComponent("Files")).getRootFolder();
        this.logger.info("Rescan of downloadable files from [{}] requested", rootFolder);
        if (null != rootFolder) {
            File root = new File(rootFolder);
            if (!root.exists()) {
                this.logger.error("Rescan problem: root folder [{}] is inaccessible", rootFolder);
            } else if (!root.isDirectory()) {
                this.logger.error("Rescan problem: root folder [{}] is not a directory", rootFolder);
            } else {
                try {
                    xmlString.append("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>")
                            .append("<files root=\"").append(root.getAbsolutePath()).append("\">");
                    rescanFolder(root, xmlString);
                    xmlString.append("</files>");
                    ((Files)app.getComponent("Files")).reload(xmlString.toString());
                    this.logger.info("Rescan of downloadable files completed");
                } catch ( InterruptedException x ) {
                    throw x;
                } catch ( Exception x ) {
                    this.logger.error("Caught an exception:", x);
                }
            }
        } else {
            this.logger.error("Rescan problem: root folder has not been set");
        }
    }

    private void rescanFolder( File folder, StringBuilder xmlString ) throws InterruptedException
    {
        if (folder.canRead()) {
            File[] files = folder.listFiles();
            Thread.sleep(1);
            // process files first, then go over sub-folders
            for ( File f : files ) {
                Thread.sleep(1);
                if (f.isFile()) {
                    if (!f.canRead()) {
                        logger.warn("Rescan found non-readable file [{}]", f.getAbsolutePath());
                    } else if (!f.getName().startsWith(".")) {
                        buildFileXmlString(f, xmlString);
                    }
                }
            }

            // go over sub-folders
            for ( File f : files ) {
                Thread.sleep(1);
                if (f.isDirectory() && !f.getName().startsWith(".")) {
                    xmlString.append("<folder location=\"").append(f.getAbsolutePath()).append("\">");
                    rescanFolder(f, xmlString);
                    xmlString.append("</folder>");
                }
            }
        } else {
            logger.warn("Rescan found non-readable folder [{}{}]", folder.getAbsolutePath(), File.separator);
        }
    }

    private void buildFileXmlString( File f, StringBuilder builder )
    {
        String name = f.getName();
        builder.append("<file kind=\"")
            .append(getFileKind(name))
            .append("\" extension=\"")
            .append(getFileExtension(name))
            .append("\" name=\"")
            .append(name)
            .append("\" size=\"")
            .append(String.valueOf(f.length()))
            .append("\" lastmodified=\"")
            .append(new SimpleDateFormat("d MMMMM yyyy, HH:mm").format(new Date(f.lastModified())))
            .append("\"/>");
    }

   private String getFileKind( String name )
    {
        if (null != name && !name.equals("")) {
            if (FGEM_ARCHIVE_REGEX.test(name)) {
                return "fgem";
            }
            if (RAW_ARCHIVE_REGEX.test(name)) {
                return "raw";
            }
            if (CEL_ARCHIVE_REGEX.test(name)) {
                return "cel";
            }
            if (MAGEML_ARCHIVE_REGEX.test(name)) {
                return "mageml";
            }
            if (ADF_FILE_REGEX.test(name)) {
                return "adf";
            }
            if (IDF_FILE_REGEX.test(name)) {
                return "idf";
            }
            if (SDRF_FILE_REGEX.test(name)) {
                return "sdrf";
            }
            if (TWO_COLS_FILE_REGEX.test(name)) {
                return "twocolumns";
            }
            if (BIOSAMPLES_FILE_REGEX.test(name)) {
                return "biosamples";
            }

        }
        return "";
    }

    private String getFileExtension( String name )
    {
        if (null != name && !name.equals("")) {
            return EXTENSION_REGEX.matchFirst(name);
        }
        return "";
    }

//    private static final RegexHelper accessionRegExp
//            = new RegexHelper("/([AE]-\\w{4}-\\d+)/", "i");
//
//    private static final RegexHelper nameRegExp
//            = new RegexHelper("/([^/]+)$");

    private static final RegexHelper EXTENSION_REGEX
            = new RegexHelper("\\.([^.]+|tar\\.gz)$", "i");

    private static final RegexHelper FGEM_ARCHIVE_REGEX
            = new RegexHelper("\\.processed\\.(\\d+\\.)?(zip|tgz|tar\\.gz)$", "i");

    private static final RegexHelper RAW_ARCHIVE_REGEX
            = new RegexHelper("\\.raw\\.(\\d+\\.)?(zip|tgz|tar\\.gz)$", "i");

    private static final RegexHelper CEL_ARCHIVE_REGEX
            = new RegexHelper("\\.cel\\.(\\d+\\.)?(zip|tgz|tar\\.gz)$", "i");

    private static final RegexHelper ADF_FILE_REGEX
            = new RegexHelper("\\.adf\\.txt|\\.adf\\.xls", "i");

    private static final RegexHelper IDF_FILE_REGEX
            = new RegexHelper("\\.idf\\.txt|\\.idf\\.xls", "i");

    private static final RegexHelper SDRF_FILE_REGEX
            = new RegexHelper("\\.sdrf\\.txt|\\.sdrf\\.xls", "i");

    private static final RegexHelper TWO_COLS_FILE_REGEX
            = new RegexHelper("\\.2columns\\.txt|\\.2columns\\.xls", "i");

    private static final RegexHelper BIOSAMPLES_FILE_REGEX
            = new RegexHelper("\\.biosamples\\.map|\\.biosamples\\.png|\\.biosamples\\.svg", "i");

    private static final RegexHelper MAGEML_ARCHIVE_REGEX
            = new RegexHelper("\\.mageml\\.zip|\\.mageml\\.tgz|\\.mageml\\.tar\\.gz", "i");
}
