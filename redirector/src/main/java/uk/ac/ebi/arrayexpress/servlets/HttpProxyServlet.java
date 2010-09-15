package uk.ac.ebi.arrayexpress.servlets;

import org.apache.commons.httpclient.Header;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.GetMethod;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.utils.RegexHelper;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.nio.CharBuffer;
import java.util.Enumeration;

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

public class HttpProxyServlet extends HttpServlet
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final RegexHelper paramRegex = new RegexHelper("servlets/proxy/+(.+)", "i");
    private final RegexHelper hostUrlRegex = new RegexHelper("^http\\:\\/\\/([^/]+)\\/", "i");

    private final int PROXY_BUFFER_SIZE = 64000;

    // Respond to HTTP GET requests
    protected void doGet( HttpServletRequest request, HttpServletResponse response )
            throws ServletException, IOException
    {
        logRequest(logger, request, "GET");

        String url = paramRegex.matchFirst(request.getRequestURL().toString());
        String queryString = request.getQueryString();

        if (0 < url.length()) {
            if (!hostUrlRegex.test(url)) { // no host here, will self
                url = "http://localhost:" + String.valueOf(request.getServerPort()) + "/" + url;
            }
            url = new StringBuilder(url).append(null != queryString ? "?" + queryString : "").toString();
            logger.debug("Will access [{}]", url);

            HttpClient httpClient = new HttpClient();
            GetMethod getMethod = new GetMethod(url);

            Enumeration requestHeaders = request.getHeaderNames();
            while (requestHeaders.hasMoreElements()) {
                String name = (String) requestHeaders.nextElement();
                String value = request.getHeader(name);
                if (null != value) {
                    getMethod.setRequestHeader(name, value);
                }
            }

            try {
                // establish a connection within 5 seconds
                httpClient.getHttpConnectionManager().getParams().setConnectionTimeout(5000);

                httpClient.executeMethod(getMethod);

                int statusCode = getMethod.getStatusCode();
                long contentLength = getMethod.getResponseContentLength();
                logger.debug("Got response [{}], length [{}]", statusCode, contentLength);

                Header[] responseHeaders = getMethod.getResponseHeaders();
                for (Header responseHeader : responseHeaders) {
                    String name = responseHeader.getName();
                    String value = responseHeader.getValue();
                    if ( null != name
                            && null != value
                            && !(name.equals("Server") || name.equals("Date") || name.equals("Transfer-Encoding"))
                            ) {
                        response.setHeader(responseHeader.getName(), responseHeader.getValue());
                    }
                }

                if (200 != statusCode) {
                    response.setStatus(statusCode);
                }

                InputStream inStream = getMethod.getResponseBodyAsStream();
                if (null != inStream) {
                    BufferedReader in = new BufferedReader(
                            new InputStreamReader(inStream));

                    BufferedWriter out = new BufferedWriter(new OutputStreamWriter(response.getOutputStream()));

                    CharBuffer buffer = CharBuffer.allocate(PROXY_BUFFER_SIZE);
                    while ( in.read(buffer) >= 0 ) {
                        buffer.flip();
                        out.append(buffer);
                        buffer.clear();
                    }

                    in.close();
                    out.close();
                }
            } catch ( Exception x ) {
                logger.error("Caught an exception:", x);
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, x.getMessage());
            } finally {
                getMethod.releaseConnection();
            }
        }
    }

    private void logRequest( Logger logger, HttpServletRequest request, String requestType )
    {
        logger.info("Processing {}", requestToString(request, requestType));
    }

    protected String requestToString( HttpServletRequest request, String requestType )
    {
        return "["
                + requestType
                + "] request ["
                + request.getRequestURL().append(
                    null != request.getQueryString() ? "?" + request.getQueryString() : ""
                )
                + "]";
    }

}

