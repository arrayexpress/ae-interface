package uk.ac.ebi.arrayexpress.servlets;

/*
 * Copyright 2009-2012 European Molecular Biology Laboratory
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
import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.MultiThreadedHttpConnectionManager;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.cookie.CookiePolicy;
import org.apache.commons.httpclient.methods.FileRequestEntity;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PutMethod;
import org.apache.commons.httpclient.methods.RequestEntity;
import org.apache.commons.lang.text.StrSubstitutor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationServlet;
import uk.ac.ebi.arrayexpress.components.Files;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GenomeSpaceUploadServlet extends ApplicationServlet
{
    private static final long serialVersionUID = 4447436099042802322L;

    private transient final Logger logger = LoggerFactory.getLogger(getClass());

    private HttpClient httpClient;

    @Override
    public void init( ServletConfig config ) throws ServletException
    {
        super.init(config);

        httpClient = new HttpClient(new MultiThreadedHttpConnectionManager());
        String proxyHost = System.getProperty("http.proxyHost");
        String proxyPort = System.getProperty("http.proxyPort");
        logger.info("Checking system properties for proxy configuration: [{}:{}]", proxyHost, proxyPort);
        if (null != proxyHost && null != proxyPort) {
            httpClient.getHostConfiguration().setProxy(proxyHost, Integer.parseInt(proxyPort));
        }
    }

    @Override
    protected boolean canAcceptRequest( HttpServletRequest request, RequestType requestType )
    {
        return (requestType == RequestType.GET || requestType == RequestType.POST);
    }

    @Override
    protected void doRequest( HttpServletRequest request, HttpServletResponse response, RequestType requestType )
            throws ServletException, IOException
    {
        logRequest(logger, request, requestType);

        Files files = (Files) getComponent("Files");

        String fileName = request.getParameter("filename");
        String accession = request.getParameter("accession");
        String targetLocation = request.getParameter("target");
        String gsToken = request.getParameter("token");

        if (null == fileName || null == accession || null == gsToken || null == targetLocation) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST
                    , "Expected parameters [filename], [accession], [target], [token] not found in the request"
            );
        } else {
            String fileLocation = files.getLocation(accession, fileName);
            File file = null != fileLocation ? new File(files.getRootFolder(), fileLocation) : null;

            if (null == file || !file.exists()) {
                logger.error("Requested file upload of [{}/{}] which is not found", accession, fileName);
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            } else {
                UploadFileInfo fileInfo = new UploadFileInfo(file);
                Integer statusCode = getFileUploadURL(fileInfo, "/Home/kolais/", gsToken);
                if (HttpServletResponse.SC_OK != statusCode) {
                    response.sendError(statusCode);
                    return;
                }

                statusCode = putFile(fileInfo);
                if (HttpServletResponse.SC_OK != statusCode) {
                    response.sendError(statusCode);
                    return;
                }
                response.setContentType("text/plain; charset=US-ASCII");
                try (PrintWriter out = response.getWriter()) {
                    out.print("Done");
                }
                logger.info("Successfully sent [{}] to [GenomeSpace:{}]", fileLocation, targetLocation);
            }
        }
    }



    private Integer getFileUploadURL( UploadFileInfo fileInfo, String target, String gsToken ) throws IOException
    {
        GetMethod get = new GetMethod(
                "https://dm.genomespace.org/datamanager/v1.0/uploadurl"
                        + target.replaceAll("^/?(.+[^/])/?$", "/$1/")
                        + fileInfo.getFile().getName()
        );
        get.getParams().setCookiePolicy(CookiePolicy.IGNORE_COOKIES);
        get.setQueryString(
                new NameValuePair[] {
                        new NameValuePair("Content-Length", fileInfo.getContentLength())
                        , new NameValuePair("Content-Type", fileInfo.GetContentType())
                        , new NameValuePair("Content-MD5", fileInfo.getContentMD5())
                }
        );
        get.setRequestHeader("Cookie","gs-token=" + gsToken);

        Integer statusCode = null;
        try {
            statusCode = httpClient.executeMethod(get);
            if (HttpServletResponse.SC_OK == statusCode) {
                fileInfo.setUploadURL(StringTools.streamToString(get.getResponseBodyAsStream(), "US-ASCII"));
            } else {
                logger.error("Unable to obtain upload URL, status code [{}]", statusCode);
            }
        } catch ( HttpException x ) {
            logger.error("Caught an exception:", x);
        } finally {
            get.releaseConnection();
        }

        return statusCode;
    }

    private Integer putFile( UploadFileInfo fileInfo ) throws IOException
    {
        PutMethod put = new PutMethod(fileInfo.getUploadURL());
        RequestEntity entity = new FileRequestEntity(fileInfo.getFile(), fileInfo.GetContentType());
        put.setRequestEntity(entity);
        put.setRequestHeader("Content-MD5", fileInfo.getContentMD5());

        Integer statusCode = null;
        try {
            statusCode = httpClient.executeMethod(put);
        } catch ( HttpException x ) {
            logger.error("Caught an exception:", x);
        } finally {
            put.releaseConnection();
        }
        return statusCode;
    }

    private class UploadFileInfo
    {
        private File file = null;
        private String md5 = null;
        private String uploadURL = null;

        public UploadFileInfo( File file )
        {
            this.file = file;

        }

        public File getFile()
        {
            return this.file;
        }

        public String getContentLength()
        {
            if (null != getFile()) {
                return String.valueOf(getFile().length());
            }
            return null;
        }

        public String getContentMD5() throws IOException
        {
            if (null != getFile() && null == this.md5) {
                String md5Command = getPreferences().getString("ae.files.get-md5-base64-encoded-command");

                // put fileLocation in place of ${file} in command line
                Map<String, String> params = new HashMap<>();
                params.put("arg.file", getFile().getPath());
                StrSubstitutor sub = new StrSubstitutor(params);
                md5Command = sub.replace(md5Command);

                // execute command
                List<String> commandParams = new ArrayList<>();
                commandParams.add("/bin/sh");
                commandParams.add("-c");
                commandParams.add(md5Command);
                logger.debug("Executing [{}]", md5Command);
                ProcessBuilder pb = new ProcessBuilder(commandParams);
                Process process = pb.start();

                try (InputStream stdOut = process.getInputStream()) {

                    this.md5 = StringTools.streamToString(stdOut, "US-ASCII").replaceAll("\\s", "");
                    if (0 != process.waitFor()) {
                        this.md5 = null;
                    }
                } catch (InterruptedException x) {
                    logger.error("Process was interrupted: ", x);
                }
            }
            return this.md5;
        }

        public String GetContentType()
        {
            if (null != getFile()) {
                return getServletContext().getMimeType(getFile().getName());
            }
            return null;
        }

        public String getUploadURL()
        {
            return this.uploadURL;
        }

        public void setUploadURL( String url )
        {
            this.uploadURL = url;
        }
    }
}
