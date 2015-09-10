package uk.ac.ebi.arrayexpress.servlets;

/*
 * Copyright 2009-2014 European Molecular Biology Laboratory
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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.components.Files;
import uk.ac.ebi.arrayexpress.components.Users;
import uk.ac.ebi.arrayexpress.utils.RegexHelper;
import uk.ac.ebi.arrayexpress.utils.io.ArchivedDownloadFile;
import uk.ac.ebi.arrayexpress.utils.io.IDownloadFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.util.List;

public class ArchivedFileDownloadServlet extends BaseDownloadServlet
{
    private static final long serialVersionUID = 292987974909731234L;

    private transient final Logger logger = LoggerFactory.getLogger(getClass());

    protected IDownloadFile getDownloadFileFromRequest( HttpServletRequest request, HttpServletResponse response, String authUserName )
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

                List<String> userIDs = getUserIds(authUserName);
                if (null == userIDs || (0 != userIDs.size() && !users.isAccessible(accession, userIDs))) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    throw new DownloadServletException(
                            "Data from ["
                                    + accession
                                    + "] is not accessible for the user ["
                                    + authUserName
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
