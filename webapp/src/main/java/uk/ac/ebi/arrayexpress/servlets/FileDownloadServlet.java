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
import uk.ac.ebi.arrayexpress.components.Experiments;
import uk.ac.ebi.arrayexpress.components.Files;
import uk.ac.ebi.arrayexpress.components.MapEngine;
import uk.ac.ebi.arrayexpress.components.Users;
import uk.ac.ebi.arrayexpress.utils.io.IDownloadFile;
import uk.ac.ebi.arrayexpress.utils.io.RegularDownloadFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.util.List;

public class FileDownloadServlet extends BaseDownloadServlet
{
    private static final long serialVersionUID = 292987974909737571L;

    private transient final Logger logger = LoggerFactory.getLogger(getClass());

    protected IDownloadFile getDownloadFileFromRequest(
            HttpServletRequest request
            , HttpServletResponse response
            , String authUserName
    ) throws DownloadServletException
    {
        String accession = "";
        String kind = "";
        String name = "";
        IDownloadFile file;

        try {
            String[] requestArgs = request.getPathInfo().replaceFirst("^/", "").split("/");
            if (null != requestArgs) {
                if (1 == requestArgs.length) { // name only passed
                    name = requestArgs[0];
                } else if (2 == requestArgs.length) { // accession/name passed
                    accession = requestArgs[0];
                    name = requestArgs[1];
                } else { // all params passed: accession/kind/name
                    accession = requestArgs[0];
                    kind = requestArgs[1];
                    name = requestArgs[2];
                }
            }
            logger.info("Requested download of [" + name + "], kind [" + kind + "], accession [" + accession + "]");
            MapEngine maps = (MapEngine) getComponent("MapEngine");
            Files files = (Files) getComponent("Files");
            Users users = (Users) getComponent("Users");



            if (!files.doesExist(accession, kind, name)) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                throw new DownloadServletException(
                        "File [" + name + "], kind [" + kind + "], accession [" + accession + "] is not in files.xml");
            } else {
                String location = files.getLocation(accession, kind, name);

                if (!"".equals(location) && "".equals(accession)) {
                    // attempt to resolve accession for file by its location
                    accession = location.replaceFirst("^.+/([AE]-\\w{4}-\\d+)/.+$", "$1");
                }

                // finally if there is no accession or location determined at the stage - panic
                if ("".equals(location) || "".equals(accession)) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    throw new DownloadServletException(
                            "Either accession ["
                                    + String.valueOf(accession)
                                    + "] or location ["
                                    + String.valueOf(location)
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

                logger.debug("Will be serving file [{}]", location);

                if (users.isReviewerByName(authUserName) && (Boolean)maps.getMappedValue(Experiments.MAP_ANONYMOUS_REVIEW_EXPERIMENTS, accession)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    throw new DownloadServletException(
                            "Data from ["
                                    + accession
                                    + "] is not accessible for the reviewer ["
                                    + authUserName
                                    + "] to protect identity of the submitter"
                    );
                    //file = new FilteredMageTabDownloadFile(new File(files.getRootFolder(), location));
                } else {
                    file = new RegularDownloadFile(new File(files.getRootFolder(), location));
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
