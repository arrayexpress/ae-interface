package uk.ac.ebi.arrayexpress.app;

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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public abstract class ApplicationServlet extends HttpServlet
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public Application getApplication()
    {
        return Application.getInstance();
    }

    public ApplicationComponent getComponent( String name )
    {
        return getApplication().getComponent(name);
    }

    public ApplicationPreferences getPreferences()
    {
        return getApplication().getPreferences();
    }

    protected enum RequestType
    {
        HEAD, GET, POST;

        public String toString()
        {
            switch (this) {
                case HEAD:
                    return "HEAD";
                case GET:
                    return "GET";
                case POST:
                    return "POST";
            }
            throw new AssertionError("Unknown type: " + this);
        }
    }

    @Override
    public void doGet( HttpServletRequest request, HttpServletResponse response ) throws ServletException, IOException
    {
        processRequest(request, response, RequestType.GET);
    }

    @Override
    public void doPost( HttpServletRequest request, HttpServletResponse response ) throws ServletException, IOException
    {
        processRequest(request, response, RequestType.POST);
    }

    @Override
    public void doHead( HttpServletRequest request, HttpServletResponse response ) throws ServletException, IOException
    {
        processRequest(request, response, RequestType.HEAD);
    }

    private void processRequest( HttpServletRequest request, HttpServletResponse response, RequestType requestType )
            throws ServletException, IOException
    {
        try {
            if (canAcceptRequest(request, requestType)) {
                doRequest(request, response, requestType);
            } else {
                logger.error("Request of type [{}] is unsupported", requestType.toString());
                response.sendError(HttpServletResponse.SC_BAD_REQUEST
                        , "The request of type " + requestType.toString() + " is not allowed here");
            }
        } catch (Throwable x) {
            logger.error("[SEVERE] Runtime error while processing request:", x);
            getApplication().sendExceptionReport(
                    "[SEVERE] Runtime error while processing " + requestToString(request, requestType)
                    , x
            );
            if (!response.isCommitted()) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }

        }
    }

    protected abstract boolean canAcceptRequest( HttpServletRequest request, RequestType requestType );

    protected abstract void doRequest( HttpServletRequest request, HttpServletResponse response, RequestType requestType )
            throws ServletException, IOException;

    protected void logRequest( Logger logger, HttpServletRequest request, RequestType requestType )
    {
        logger.info("Processing {}", requestToString(request, requestType));
    }

    protected String requestToString( HttpServletRequest request, RequestType requestType )
    {
        return "["
                + requestType.toString()
                + "] request ["
                + request.getRequestURL().append(
                    null != request.getQueryString() ? "?" + request.getQueryString() : ""
                )
                + "]";
    }

}
