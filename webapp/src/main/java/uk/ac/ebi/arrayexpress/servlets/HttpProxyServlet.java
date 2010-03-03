package uk.ac.ebi.arrayexpress.servlets;

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

import org.apache.commons.httpclient.Header;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.GetMethod;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationServlet;
import uk.ac.ebi.arrayexpress.utils.RegExpHelper;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class HttpProxyServlet extends ApplicationServlet
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    protected boolean canAcceptRequest( HttpServletRequest request, RequestType requestType )
    {
        return (requestType == RequestType.GET);
    }

    // Respond to HTTP requests from browsers.
    protected void doRequest( HttpServletRequest request, HttpServletResponse response, RequestType requestType )
            throws ServletException, IOException
    {
        logRequest(logger, request, requestType);

        String path = new RegExpHelper("servlets/proxy/(.+)", "i")
                .matchFirst(request.getRequestURL().toString());
        String queryString = request.getQueryString();

        if (0 < path.length()) {
            // todo: wtf is this hardcoded?
            String url = new StringBuilder("http://www.ebi.ac.uk/").append(path).append(null != queryString ? "?" + queryString : "").toString();
            logger.debug("Will access [{}]", url);

            HttpClient httpClient = new HttpClient();
            GetMethod getMethod = new GetMethod(url);

            try {
                // establish a connection within 5 seconds
                httpClient.getHttpConnectionManager().getParams().setConnectionTimeout(5000);

                httpClient.executeMethod(getMethod);

                int responseStatus = getMethod.getStatusCode();
                Header contentLength = getMethod.getResponseHeader("Content-Length");

                logger.debug("Response: http status [{}], length [{}]", String.valueOf(responseStatus), null != contentLength ? contentLength.getValue() : "null");

                if (null != contentLength && 0 < Long.parseLong(contentLength.getValue()) && 200 == responseStatus) {

                    Header contentType = getMethod.getResponseHeader("Content-Type");
                    if (null != contentType) {
                        response.setContentType(contentType.getValue());
                    }

                    BufferedReader in = new BufferedReader(
                            new InputStreamReader(getMethod.getResponseBodyAsStream()));

                    ServletOutputStream out = response.getOutputStream();

                    String inputLine;
                    while ( (inputLine = in.readLine()) != null ) {
                        out.println(inputLine);
                    }

                    in.close();
                    out.close();
                } else {
                    String err = "Response from [" + url + "] was invalid: http status [" + String.valueOf(responseStatus) + "], length [" + (null == contentLength ? "null" : contentLength.getValue())  + "]";
                    logger.error(err);
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, err);
                }
            } catch ( Exception x ) {
                logger.error("Caught an exception:", x);
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, x.getMessage());
            } finally {
                getMethod.releaseConnection();
            }
        }
    }
}
