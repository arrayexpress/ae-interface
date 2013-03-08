package uk.ac.ebi.arrayexpress.servlets;

/*
 * Copyright 2009-2013 European Molecular Biology Laboratory
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

import de.schlichtherle.util.zip.ZipEntry;
import de.schlichtherle.util.zip.ZipFile;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.components.Files;
import uk.ac.ebi.arrayexpress.components.Users;
import uk.ac.ebi.arrayexpress.utils.RegexHelper;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.util.List;

public class ArchivedFileDownloadServlet extends BaseDownloadServlet
{
    private static final long serialVersionUID = 292987974909731234L;

    private transient final Logger logger = LoggerFactory.getLogger(getClass());

    protected final class ArchivedDownloadFile implements IDownloadFile
    {
        private final File file;
        private final String entryName;
        private final ZipFile zipFile;
        private final ZipEntry zipEntry;

        public ArchivedDownloadFile( File archiveFile, String entryName ) throws IOException
        {
            if ( null == archiveFile || null == entryName ) {
                throw new IllegalArgumentException("Arguments cannot be null");
            }
            this.file = archiveFile;
            this.entryName = entryName;
            this.zipFile = new ZipFile(archiveFile);
            this.zipEntry = this.zipFile.getEntry(this.entryName);
        }

        private File getFile()
        {
            return this.file;
        }
        
        private String getEntryName()
        {
            return this.entryName;
        }

        private ZipEntry getZipEntry()
        {
            return this.zipEntry;
        }

        public String getName()
        {
            return getEntryName();
        }

        public String getPath()
        {
            return getFile().getName() + File.separator + getEntryName();
        }

        public long getLength()
        {
            return (null != getZipEntry() ? getZipEntry().getSize() : 0L);
        }

        public long getLastModified()
        {
            return (null != getZipEntry() ? getZipEntry().getTime() : 0L);
        }

        public boolean canDownload()
        {
            return null != getZipEntry();
        }

        public boolean isRandomAccessSupported()
        {
            return false;
        }

        public RandomAccessFile getRandomAccessFile() throws IOException
        {
            throw new IllegalArgumentException("Method not supported");
        }

        public InputStream getInputStream() throws IOException
        {
            if (null == getZipEntry())
                throw new FileNotFoundException("Archived file not found");
            return this.zipFile.getInputStream(getZipEntry());
        }

        public void close() throws IOException
        {
            if (null != this.zipFile) {
                zipFile.close();
            }
        }
    }

    protected IDownloadFile getDownloadFileFromRequest( HttpServletRequest request, HttpServletResponse response, List<String> userIDs )
            throws DownloadServletException
    {
        RegexHelper PARSE_ARGUMENTS_REGEX = new RegexHelper("/([^/]+)/([^/]+)/([^/]+)$", "i");
        String[] requestArgs = PARSE_ARGUMENTS_REGEX.match(request.getRequestURL().toString());

        if (null == requestArgs || requestArgs.length != 3
                || "".equals(requestArgs[0]) || "".equals(requestArgs[1])
                || "".equals(requestArgs[2])) {
            throw new DownloadServletException(
                    "Bad arguments passed via request URL ["
                            + request.getRequestURL().toString()
                            + "]"
            );
        }

        IDownloadFile file;

        String accession = requestArgs[0];
        String archName = requestArgs[1];
        String fileName = requestArgs[2];

        logger.info("Requested download of [{}] from archive [{}],  accession [" + accession + "]", fileName, archName);
        Files files = (Files) getComponent("Files");
        Users users = (Users) getComponent("Users");

        try {

            if (!files.doesExist(accession, null, archName)) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                throw new DownloadServletException(
                        "Archive with name ["
                                + archName
                                + "], accession ["
                                + accession
                                + "] is not in files.xml");
            } else {
                String archLocation = files.getLocation(accession, null, archName);

                // finally if there is no accession or location determined at the stage - panic
                if ("".equals(archLocation) || "".equals(accession)) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    throw new DownloadServletException(
                            "Either accession ["
                                    + String.valueOf(accession)
                                    + "] or location ["
                                    + String.valueOf(archLocation)
                                    + "] were not determined");
                }

                if (!(null != userIDs && (0 == userIDs.size() || users.isAccessible(accession, userIDs)))) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    throw new DownloadServletException(
                            "Data from ["
                                    + accession
                                    + "] is not accessible for the user with id(s) ["
                                    + StringTools.arrayToString(userIDs.toArray(new String[userIDs.size()]), ", ")
                                    + "]"
                    );
                }

                logger.debug("Will be serving archive [{}]", archLocation);
                file = new ArchivedDownloadFile(new File(files.getRootFolder(), archLocation), fileName);
    
                if (!file.canDownload()) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    throw new DownloadServletException(
                            "File ["
                                    + fileName
                                    + "] was not found or there are multiple files with the name inside archive ["
                                    + String.valueOf(archLocation)
                                    + "]");

                }
            }
        } catch (DownloadServletException x) {
            throw x;
        } catch (Exception x) {
            throw new DownloadServletException(x);
        }
        return file;
    }
}
