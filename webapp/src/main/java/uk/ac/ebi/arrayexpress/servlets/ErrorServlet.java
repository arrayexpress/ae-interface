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

import net.sf.saxon.om.DocumentInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;
import uk.ac.ebi.arrayexpress.utils.HttpServletRequestParameterMap;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

public class ErrorServlet extends AuthAwareApplicationServlet {

    private transient final Logger logger = LoggerFactory.getLogger(getClass());

    protected boolean canAcceptRequest( HttpServletRequest request, RequestType requestType )
    {
        return true;
    }

    protected void doAuthenticatedRequest(
            HttpServletRequest request
            , HttpServletResponse response
            , RequestType requestType
            , String authUserName
    ) throws ServletException, IOException
    {
        logRequest(logger, request, requestType);

        response.setContentType("text/html; charset=UTF-8");
        // Output goes to the response PrintWriter.

        try (PrintWriter out = response.getWriter()) {
            String stylesheetName = "error-html.xsl";

            HttpServletRequestParameterMap params = new HttpServletRequestParameterMap(request);
            params.put("original-request-uri", (String)request.getAttribute("javax.servlet.error.request_uri"));
            params.put("userid", StringTools.listToString(getUserIds(authUserName), " OR "));
            params.put("username", authUserName);

            SaxonEngine saxonEngine = (SaxonEngine) getComponent("SaxonEngine");
            DocumentInfo source = saxonEngine.getAppDocument();

            if (!saxonEngine.transformToWriter(
                    source
                    , stylesheetName
                    , params
                    , out
            )) {                     // where to dump resulting text
                throw new Exception("Transformation returned an error");
            }
        } catch (Exception x) {
            throw new RuntimeException(x);
        }
    }}
