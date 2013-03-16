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

import net.sf.uadetector.UserAgent;
import net.sf.uadetector.UserAgentStringParser;
import net.sf.uadetector.service.UADetectorServiceFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationServlet;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

public class FeedbackServlet extends ApplicationServlet
{
    private static final long serialVersionUID = -4509580274404536345L;

    private transient final Logger logger = LoggerFactory.getLogger(getClass());

    @Override
    protected boolean canAcceptRequest( HttpServletRequest request, RequestType requestType )
    {
        return (requestType == RequestType.GET || requestType == RequestType.POST);
    }

    // Respond to HTTP requests from browsers.
    @Override
    protected void doRequest( HttpServletRequest request, HttpServletResponse response, RequestType requestType ) throws ServletException, IOException
    {
        logRequest(logger, request, requestType);

        String message = request.getParameter("m");
        String email = request.getParameter("e");
        String page = request.getParameter("p");
        String ref = request.getParameter("r");

        UserAgentStringParser parser = UADetectorServiceFactory.getResourceModuleParser();
        UserAgent agent = parser.parse(request.getHeader("User-Agent"));

        String originator = getPreferences().getString("app.reports.originator");
        if (null != email && email.matches("^[^\\s]*@[A-Za-z0-9-]+[.][A-Za-z0-9.-]+$")) {
            originator = email;
        }
        if (!"".equals(message)) {
            getApplication().sendEmail(
                    originator
                    , getPreferences().getStringArray("ae.feedback.recipients")
                    , getPreferences().getString("ae.feedback.subject")
                    , (!originator.equals(email) ? ("From: " + ("".equals(email) ? "unknown sender" : email) + StringTools.EOL) : "")
                    + StringTools.EOL
                    + message + StringTools.EOL
                    + StringTools.EOL
                    + "---" + StringTools.EOL
                    + "Page " + page + StringTools.EOL
                    + (!"".equals(ref) ? "Referrer " + ref + StringTools.EOL : "")
                    + "Using " + agent.getName() + " " + agent.getVersionNumber().toVersionString()
                    + " on " + agent.getOperatingSystem().getName() + StringTools.EOL
                    + StringTools.EOL
                    + "Sent by ${variable.appname} running on ${variable.hostname}" + StringTools.EOL
                    + StringTools.EOL
            );
        }

        response.setContentType("text/plain; charset=UTF-8");
        // Disable cache no matter what (or we're fucked on IE side)
        response.addHeader("Pragma", "no-cache");
        response.addHeader("Cache-Control", "no-cache");
        response.addHeader("Cache-Control", "must-revalidate");
        response.addHeader("Expires", "Fri, 16 May 2008 10:00:00 GMT"); // some date in the past

        // Output goes to the response PrintWriter.
        PrintWriter out = response.getWriter();
        try {
            out.print("Thanks!");
        } catch (Exception x) {
            throw new RuntimeException(x);
        }
        out.close();
    }
}
