package uk.ac.ebi.arrayexpress.servlets;

import org.apache.commons.lang.text.StrSubstitutor;
import org.apache.lucene.queryParser.ParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.app.ApplicationServlet;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;
import uk.ac.ebi.arrayexpress.components.SearchEngine;
import uk.ac.ebi.arrayexpress.components.Users;
import uk.ac.ebi.arrayexpress.utils.CookieMap;
import uk.ac.ebi.arrayexpress.utils.HttpServletRequestParameterMap;
import uk.ac.ebi.arrayexpress.utils.RegexHelper;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URL;
import java.net.URLDecoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

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

public class QueryServlet extends ApplicationServlet
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    protected boolean canAcceptRequest( HttpServletRequest request, RequestType requestType )
    {
        return (requestType == RequestType.GET || requestType == RequestType.POST);
    }

    // Respond to HTTP requests from browsers.
    protected void doRequest( HttpServletRequest request, HttpServletResponse response, RequestType requestType ) throws ServletException, IOException
    {
        RegexHelper PARSE_ARGUMENTS_REGEX = new RegexHelper("/([^/]+)/([^/]+)/([^/]+)$", "i");

        logRequest(logger, request, requestType);

        String[] requestArgs = PARSE_ARGUMENTS_REGEX.match(request.getRequestURL().toString());

        if (null == requestArgs || requestArgs.length != 3
                || "".equals(requestArgs[0]) || "".equals(requestArgs[1]) || "".equals(requestArgs[2])) {
            throw new ServletException("Bad arguments passed via request URL [" + request.getRequestURL().toString() + "]");
        }

        String index = requestArgs[0];
        String stylesheet = requestArgs[1];
        String outputType = requestArgs[2];


        if (outputType.equals("xls")) {
            // special case for Excel docs
            // we actually send tab-delimited file but mimick it as XLS doc
            String timestamp = new SimpleDateFormat("yyMMdd-HHmmss").format(new Date());
            response.setContentType("application/vnd.ms-excel; charset=ISO-8859-1");
            response.setHeader("Content-disposition", "attachment; filename=\"ArrayExpress-Experiments-" + timestamp + ".xls\"");
            outputType = "tab";
        } else if (outputType.equals("tab")) {
            // special case for tab-delimited files
            // we send tab-delimited file as an attachment
            String timestamp = new SimpleDateFormat("yyMMdd-HHmmss").format(new Date());
            response.setContentType("text/plain; charset=ISO-8859-1");
            response.setHeader("Content-disposition", "attachment; filename=\"ArrayExpress-Experiments-" + timestamp + ".txt\"");
            outputType = "tab";
        } else if (outputType.equals("json")) {
            response.setContentType("application/json; charset=UTF-8");
        } else if (outputType.equals("html")) {
            response.setContentType("text/html; charset=ISO-8859-1");
        } else {
            response.setContentType("text/" + outputType + "; charset=UTF-8");
        }

        // tell client to not cache the page unless we want to
        if (!"true".equalsIgnoreCase(request.getParameter("cache"))) {
            response.addHeader("Pragma", "no-cache");
            response.addHeader("Cache-Control", "no-cache");
            response.addHeader("Cache-Control", "must-revalidate");
            response.addHeader("Expires", "Fri, 16 May 2008 10:00:00 GMT"); // some date in the past
        }

        // Output goes to the response PrintWriter.
        PrintWriter out = response.getWriter();
        try {
            //Experiments experiments = (Experiments) getComponent("Experiments");

            String stylesheetName = new StringBuilder(stylesheet).append('-').append(outputType).append(".xsl").toString();

            HttpServletRequestParameterMap params = new HttpServletRequestParameterMap(request);
            // to make sure nobody sneaks in the other value w/o proper authentication
            params.put("userid", "1");

            // adding "host" request header so we can dynamically create FQDN URLs
            params.put("host", request.getHeader("host"));
            params.put("basepath", request.getContextPath());

            CookieMap cookies = new CookieMap(request.getCookies());
            if (cookies.containsKey("AeLoggedUser") && cookies.containsKey("AeLoginToken")) {
                Users users = (Users) getComponent("Users");
                String user = URLDecoder.decode(cookies.get("AeLoggedUser").getValue(), "UTF-8");
                String passwordHash = cookies.get("AeLoginToken").getValue();
                if (users.verifyLogin(user, passwordHash, request.getRemoteAddr().concat(request.getHeader("User-Agent")))) {
                    if ((users.isPrivileged(user))) { // superuser logged in -> remove user restriction
                            params.remove("userid");
                        } else {
                            params.put("userid", StringTools.listToString(users.getUserIDs(user), " OR "));
                        }
                } else {
                    logger.warn("Removing invalid session cookie for user [{}]", user);
                    // resetting cookies
                    Cookie userCookie = new Cookie("AeLoggedUser", "");
                    userCookie.setPath("/");
                    userCookie.setMaxAge(0);

                    response.addCookie(userCookie);
                }
            }

            // setting "preferred" parameter to true allows only preferred experiments to be displayed, but if
            // any of source control parameters are present in the query, it will not be added
            String[] keywords = params.get("keywords");

            if (!(params.containsKey("migrated")
                || params.containsKey("source")
                || params.containsKey("visible")
                || ( null != keywords && keywords[0].matches(".*\\bmigrated:.*"))
                || ( null != keywords && keywords[0].matches(".*\\bsource:.*"))
                || ( null != keywords && keywords[0].matches(".*\\bvisible:.*"))
                )) {

                params.put("visible", "true");
            }

            try {
                SearchEngine search = ((SearchEngine) getComponent("SearchEngine"));
                if (search.getController().hasIndexDefined(index)) { // only do query if index id is defined
                    Integer queryId = search.getController().addQuery(index, params, request.getQueryString());
                    params.put("queryid", String.valueOf(queryId));
                }

                SaxonEngine saxonEngine = (SaxonEngine) getComponent("SaxonEngine");
                if (!saxonEngine.transformToWriter(
                        saxonEngine.getAppDocument()
                        , stylesheetName
                        , params
                        , out
                    )) {                     // where to dump resulting text
                    throw new Exception("Transformation returned an error");
                }
            } catch (ParseException x) {
                logger.error("Caught lucene parse exception:", x);
                reportQueryError(out, "query-syntax-error.txt", request.getParameter("keywords"));
            }
        } catch (Exception x) {
            throw new RuntimeException(x);
        }
        out.close();
    }

    private void reportQueryError( PrintWriter out, String templateName, String query )
    {
        try {
            URL resource = Application.getInstance().getResource("/WEB-INF/server-assets/templates/" + templateName);
            String template = StringTools.streamToString(resource.openStream(), "ISO-8859-1");
            Map<String, String> params = new HashMap<String, String>();
            params.put("variable.query", query);
            StrSubstitutor sub = new StrSubstitutor(params);
            out.print(sub.replace(template));
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }
    }
}