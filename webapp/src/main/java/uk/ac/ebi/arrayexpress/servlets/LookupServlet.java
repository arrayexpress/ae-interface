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
import uk.ac.ebi.arrayexpress.app.ApplicationServlet;
import uk.ac.ebi.arrayexpress.components.Autocompletion;
import uk.ac.ebi.arrayexpress.components.Experiments;
import uk.ac.ebi.arrayexpress.components.Ontologies;
import uk.ac.ebi.arrayexpress.utils.RegexHelper;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

public class LookupServlet extends ApplicationServlet
{
    private static final long serialVersionUID = -5043275356216186598L;

    private transient final Logger logger = LoggerFactory.getLogger(getClass());

    protected boolean canAcceptRequest( HttpServletRequest request, RequestType requestType )
    {
        return (requestType == RequestType.GET || requestType == RequestType.POST);
    }

    // Respond to HTTP requests from browsers.
    protected void doRequest( HttpServletRequest request, HttpServletResponse response, RequestType requestType )
            throws ServletException, IOException
    {
        logRequest(logger, request, requestType);

        String[] requestArgs = new RegexHelper("/([^/]+)$", "i")
                .match(request.getPathInfo());

        String type = "";
        String query = null != request.getParameter("q") ? request.getParameter("q") : "";
        Integer limit = null != request.getParameter("limit") ? Integer.parseInt(request.getParameter("limit")) : null;

        String efoId = null != request.getParameter("efoid") ? request.getParameter("efoid") : "";
        // todo: remove this hack at all
        efoId = efoId.replaceFirst("^http\\://wwwdev\\.ebi\\.ac\\.uk/", "http://www.ebi.ac.uk/");

        if (null != requestArgs) {
            if (!requestArgs[0].equals("")) {
                type = requestArgs[0];
            }
        }

        if (type.contains("json")) {
            response.setContentType("application/json; charset=UTF-8");
        } else {
            response.setContentType("text/plain; charset=UTF-8");
        }
        // Disable cache no matter what (or we're fucked on IE side)
        response.addHeader("Pragma", "no-cache");
        response.addHeader("Cache-Control", "no-cache");
        response.addHeader("Cache-Control", "must-revalidate");
        response.addHeader("Expires", "Fri, 16 May 2008 10:00:00 GMT"); // some date in the past

        // Output goes to the response PrintWriter.
        try (PrintWriter out = response.getWriter()) {
            Experiments experiments = (Experiments)getComponent("Experiments");
            Autocompletion autocompletion = (Autocompletion)getComponent("Autocompletion");
            Ontologies ontologies = (Ontologies)getComponent("Ontologies");
            if ("arrays".equals(type) && null != experiments) {
                out.print(experiments.getArrays());
            } else if ("species".equals(type) && null != experiments) {
                out.print(experiments.getSpecies());
            } else if ("expdesign".equals(type) && null != ontologies) {
                out.print(ontologies.getAssayByMoleculeOptions());
            } else if ("exptech".equals(type) && null != ontologies) {
                out.print(ontologies.getAssayByInstrumentOptions());
            } else if ("keywords".equals(type) && null != autocompletion) {
                String field = (null != request.getParameter("field") ? request.getParameter("field") : "");
                out.print(autocompletion.getKeywords(query, field, limit));
            } else if ("efowords".equals(type) && null != autocompletion) {
                out.print(autocompletion.getEfoWords(query, limit));
            } else if ("efotree".equals(type) && null != autocompletion) {
                out.print(autocompletion.getEfoChildren(efoId));
            } else {
                logger.error("Action [{}] is not supported", type);
            }
        } catch (Exception x) {
            throw new RuntimeException(x);
        }
    }
}

