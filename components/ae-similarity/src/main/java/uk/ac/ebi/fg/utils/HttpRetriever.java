package uk.ac.ebi.fg.utils;

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

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.cookie.CookiePolicy;
import org.apache.commons.httpclient.methods.GetMethod;

import java.io.InputStream;

/**
 * Retrieves http page content
 */
public class HttpRetriever
{
    private HttpMethod method;
    private HttpClient client;

    public HttpRetriever()
    {
        client = new HttpClient();
        client.getParams().setParameter("http.connection.timeout", new Integer(10 * 1000));  // establish connection
        client.getParams().setParameter("http.socket.timeout", new Integer(10 * 1000));      // get data

        setProxySetting();
    }

    public InputStream getPage( String url )
    {
        InputStream responseBody;

        try {
            method = new GetMethod(url);
            method.getParams().setCookiePolicy(CookiePolicy.IGNORE_COOKIES);
            int statusCode = client.executeMethod(method);
            if (statusCode != HttpStatus.SC_OK) {
                throw new RuntimeException(method.getStatusLine().toString());
            }
            // read response body
            responseBody = method.getResponseBodyAsStream();

        } catch (Exception ex) {
            throw new RuntimeException(ex.getMessage());
        }

        return responseBody;
    }

    private void setProxySetting()
    {
        String host = System.getProperty("http.proxyHost");
        if (host != null) {
            int port = (null != System.getProperty("http.proxyPort")) ? Integer.valueOf(System.getProperty("http.proxyPort")) : 80;
            client.getHostConfiguration().setProxy(host, port);
        }
    }

    public void closeConnection()
    {
        method.releaseConnection();
    }
}
