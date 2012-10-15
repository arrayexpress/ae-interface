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

import org.apache.commons.lang.text.StrSubstitutor;
import org.openid4java.OpenIDException;
import org.openid4java.association.AssociationSessionType;
import org.openid4java.consumer.ConsumerManager;
import org.openid4java.consumer.InMemoryConsumerAssociationStore;
import org.openid4java.consumer.InMemoryNonceVerifier;
import org.openid4java.consumer.VerificationResult;
import org.openid4java.discovery.DiscoveryInformation;
import org.openid4java.message.*;
import org.openid4java.message.ax.AxMessage;
import org.openid4java.message.ax.FetchRequest;
import org.openid4java.message.ax.FetchResponse;
import org.openid4java.message.sreg.SRegMessage;
import org.openid4java.message.sreg.SRegRequest;
import org.openid4java.message.sreg.SRegResponse;
import org.openid4java.util.HttpClientFactory;
import org.openid4java.util.ProxyProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.app.ApplicationServlet;
import uk.ac.ebi.arrayexpress.components.GenomeSpace;
import uk.ac.ebi.arrayexpress.utils.CookieMap;
import uk.ac.ebi.arrayexpress.utils.StringTools;
import uk.ac.ebi.arrayexpress.utils.genomespace.GenomeSpaceMessageExtension;
import uk.ac.ebi.arrayexpress.utils.genomespace.GenomeSpaceMessageExtensionFactory;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URI;
import java.net.URL;
import java.util.*;

/*
 *  This servlet supports openId authentication to GenomeSpace
 *  and experiment upload functionality
 */
public class GenomeSpaceAuthServlet extends ApplicationServlet
{
    private static final long serialVersionUID = -3446967645131419250L;

    private transient final Logger logger = LoggerFactory.getLogger(getClass());

    // These flags control which extension type to use.  If neither is set the
    // the GenomeSpace Provider will create a custom extension and pass the
    // token, username, and email.
    private static final String USE_SREG = null;  // can be "1.0" or "1.1"
    private static final boolean USE_AX = false;

    private ConsumerManager manager;

    private static final String GS_TOKEN_COOKIE = "gs-token";
    private static final String GS_USERNAME_COOKIE = "gs-username";
    private static final String GS_AUTH_MESSAGE_COOKIE = "gs-auth-message";
    private static final String GS_RETURN_URL_COOKIE = "gs-auth-return-url";

//    private static final String GS_XRD_URL = "https://identity.genomespace.org/identityServer/xrd.jsp";
//    private static final String LOGOUT_RETURN_TO = "logout_return_to";

    private static final String REFERER_HEADER = "Referer";


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

        GenomeSpace gs = (GenomeSpace)getComponent("GenomeSpace");

        if ("true".equals(request.getParameter("is_cancel"))) {
            // User clicked "cancel" on the openID login page.
            displayResult(response, getCookie(request, GS_RETURN_URL_COOKIE), null, null, "User has cancelled login");

        } else if ("true".equals(request.getParameter("is_return"))) {
            // Handles the auth response callback from OpenID provider
            // OpenID protocol requires the response be verified, but that's ignored
            // since GenomeSpace actually uses a 2nd layer of authentication, beyond OpenID
            // server claiming that the user is authenticated. The token is all we care about
            String token = null;
            String username = null;
            String returnURL = getCookie(request, GS_RETURN_URL_COOKIE);

            boolean isTempPasswordLogin = false;  // indicates login using temporary password

            // First we look for token in the queryParameters
            for (String pair : request.getQueryString().split("&")) {
                String[] parts = pair.split("=");
                if (parts[0].endsWith(GenomeSpaceMessageExtension.TOKEN_ALIAS) && parts.length == 2) {
                    token = parts[1];
                } else if (parts[0].endsWith(GenomeSpaceMessageExtension.USERNAME_ALIAS) && parts.length == 2) {
                    username = parts[1];
                } else if (parts[0].endsWith(GenomeSpaceMessageExtension.TEMP_LOGIN_ALIAS) && parts.length == 2) {
                    isTempPasswordLogin = Boolean.valueOf(parts[1]);
                }
            }

            // If not found we look for token in the OpenId message extension.
            // Should only ever get here if bad login is given.
            if (token == null || token.length() == 0 || username == null || username.length() == 0) {
                // Does the OpenID verification
                try {
                    ParameterList paramList = verifyResponse(request, response);
                    if (paramList != null) {
                        if (paramList.hasParameter(GenomeSpaceMessageExtension.TOKEN_ALIAS)
                                && paramList.hasParameter(GenomeSpaceMessageExtension.USERNAME_ALIAS)
                                && paramList.hasParameter(GenomeSpaceMessageExtension.EMAIL_ALIAS)
                                && paramList.hasParameter(GenomeSpaceMessageExtension.TEMP_LOGIN_ALIAS)) {
                            token = paramList.getParameterValue(GenomeSpaceMessageExtension.TOKEN_ALIAS);
                            username = paramList.getParameterValue(GenomeSpaceMessageExtension.USERNAME_ALIAS);
                            isTempPasswordLogin = Boolean.valueOf(paramList.getParameterValue(GenomeSpaceMessageExtension.TEMP_LOGIN_ALIAS));
                        }
                    }
                } catch (Exception e) {
                    logger.error("Error while doing openID verification: ", e);
                }
            }

            if (token == null || token.length() == 0 || username == null || username.length() == 0) {
                logger.info("OpenID login failed");
                displayResult(response, returnURL, null, null, "OpenID login failed");
            } else {
                logger.info("OpenID login succeeded" + (isTempPasswordLogin ? ", used temp password" : ""));
                displayResult(response, returnURL, username, token, null);
            }

        } else {
            String returnURL = request.getHeader(REFERER_HEADER);
            if (null != returnURL) {
                setCookie(response, GS_RETURN_URL_COOKIE, returnURL);
            }

            authRequest(gs.getPropertyValue("prod.openIdUrl"), returnURL, request, response);
        }
    }

    private void displayResult( HttpServletResponse response,
                                String returnURL, String username, String token, String message )
            throws ServletException, IOException
    {
        setCookie(response, GS_TOKEN_COOKIE, token);
        setCookie(response, GS_USERNAME_COOKIE, username);
        setCookie(response, GS_AUTH_MESSAGE_COOKIE, message);
        setCookie(response, GS_RETURN_URL_COOKIE, null);

        if (null != returnURL) {
            response.sendRedirect(returnURL);
        } else {
            try (PrintWriter out = response.getWriter()) {
                URL resource = Application.getInstance().getResource("/WEB-INF/server-assets/templates/gs-auth-result.txt");
                String template = StringTools.streamToString(resource.openStream(), "ISO-8859-1");
                Map<String, String> params = new HashMap<String, String>();
                params.put("gs.token", null != token ? token : "<null>");
                params.put("gs.username", null != username ? username : "<null>");
                params.put("gs.message", null != message ? message : "<null>");
                StrSubstitutor sub = new StrSubstitutor(params);
                out.print(sub.replace(template));
            } catch (Exception x) {
                logger.error("Caught an exception:", x);
            }
        }
    }

    //@SuppressWarnings("rawtypes")
    private void authRequest( String claimedID, String returnURL, HttpServletRequest httpRequest, HttpServletResponse httpResponse )
            throws IOException, ServletException
    {
        try {
            // "return_to URL" needs to come back to this servlet
            // in order to verify the OP response.
            String returnToUrl = httpRequest.getRequestURL().toString() + "?is_return=true";

            // Performs openId discovery, puts association into in-memory
            // store, and creates the auth request.
            List discoveries = manager.discover(claimedID);
            DiscoveryInformation discovered = manager.associate(discoveries);
            httpRequest.getSession().setAttribute("openid-disc", discovered);
            AuthRequest authReq = manager.authenticate(discovered, returnToUrl);

            // This block of code is needed only when you choose OpenId Attribute Exchange
            // to get the gs-token, gs-username, and email.  It is included here to illustrate
            // AX usage, and also to test the GenomeSpace OpenId Provider.
            if (USE_AX) {
                // Add Attribute Exchange request for gs token and username
                FetchRequest fetch = FetchRequest.createFetchRequest();
                fetch.addAttribute(GenomeSpaceMessageExtension.TOKEN_ALIAS,
                        GenomeSpaceMessageExtension.URI + GenomeSpaceMessageExtension.TOKEN_ALIAS, true);
                fetch.addAttribute(GenomeSpaceMessageExtension.USERNAME_ALIAS,
                        GenomeSpaceMessageExtension.URI + GenomeSpaceMessageExtension.USERNAME_ALIAS, true);
                fetch.addAttribute(GenomeSpaceMessageExtension.EMAIL_ALIAS,
                        GenomeSpaceMessageExtension.URI + GenomeSpaceMessageExtension.EMAIL_ALIAS, true);
                authReq.addExtension(fetch);
            }

            // This block of code is needed only when you choose OpenId Simple Registration
            // to get the gs-token, gs-username, and email.  It is included here to illustrate
            // SReg usage, and also to test the GenomeSpace OpenId Provider.
            if (USE_SREG != null) {
                // Add Simple Registration request for gs token and username.  SReg implementation
                // disallows these names, so fudge it by using "gender" and "nickname" in place of
                // "gs-token" and "gs-username" respectively.  GenomeSpace OpenId provider will
                // play along with this little fiction and return the expected values.
                SRegRequest sregReq = SRegRequest.createFetchRequest();
                sregReq.addAttribute("gender", true);
                sregReq.addAttribute("nickname", true);
                sregReq.addAttribute("email", true);
                if (USE_SREG.equals("1.1")) {
                    sregReq.setTypeUri(SRegMessage.OPENID_NS_SREG11);
                }
                authReq.addExtension(sregReq);
            }

            httpResponse.sendRedirect(authReq.getDestinationUrl(true));

        } catch (org.openid4java.discovery.yadis.YadisException e) {
            logger.error("Error requesting OpenID authentication.", e);
            displayResult(httpResponse, returnURL, null, null, "OpenID Provider XRD " +
                    claimedID + " is unavailable.<BR/>The internal error is <CODE>" +
                    e.getMessage() + "</CODE><P/>");
        } catch (OpenIDException e) {
            logger.error("Error requesting OpenId authentication.", e);
            displayResult(httpResponse, returnURL, null, null,
                    "Error requesting OpenId authentication.<BR/>The internal error is <CODE>" +
                            e.getMessage() + "</CODE><P/>");
        }
    }


    /**
     * If OP's response verifies OK, returns the ParameterList containing the
     * GenomeSpace token and username, if they are found in the response, and an
     * empty ParameterList if not found. If the verify fails, returns null
     */
    private ParameterList verifyResponse( HttpServletRequest httpRequest, HttpServletResponse httpResp )
            throws ServletException
    {
        try {
            // extract the parameters from the authentication response
            // (which comes in as a HTTP request from the OpenID provider)
            ParameterList response = new ParameterList(httpRequest.getParameterMap());

            // retrieve the previously stored discovery information
            DiscoveryInformation discovered =
                    (DiscoveryInformation)httpRequest.getSession().getAttribute("openid-disc");

            // extract the receiving URL from the HTTP request
            StringBuffer receivingURL = httpRequest.getRequestURL();
            String queryString = httpRequest.getQueryString();
            if (queryString != null && queryString.length() > 0) {
                receivingURL.append("?").append(queryString);
            }
            // Response must match what was used to place the authentication request.
            VerificationResult verification = manager.verify(
                    receivingURL.toString()
                    , response
                    , discovered
            );

            AuthSuccess authSuccess = null;
            if (verification.getVerifiedId() == null) {
                // Client verification can fail despite the server doing a
                // successful login (possibly related to http->https redirect?)
                // This means the server will have set token and username
                // cookies in genomespace.org domain, which means GenomeSpace
                // will allow access.  Ideally the client here should redirect
                // to the openId logout page to remove those cookies.
                logger.info("OpenID Client side verification failed");

                // Only allow this on localhost for GS developer's convenience.
                boolean onLocalhost = false;
                try {
                    URI uri = new URI(receivingURL.toString());
                    if (uri != null && "localhost".equals(uri.getHost())) {
                        onLocalhost = true;
                    }
                } catch (Exception e) {
                    logger.debug("Cannot parse receiving URL:", e);
                }
                if (onLocalhost) {
                    String msg = "GenomeSpace login is permitted despite OpenID verification fail. This would be rejected if not on localhost.";
                    logger.info(msg);
                } else {
                    return null;
                }
            } else {
                logger.info("OpenID Client side verification succeeded");
            }
            authSuccess = (AuthSuccess) verification.getAuthResponse();
            return extractGenomeSpaceToken(authSuccess);

        } catch (OpenIDException e) {
            // present error to the user
            throw new ServletException(e);
        }
    }

    /** Extracts the GenomeSpace token from the OpenId message. */
    @SuppressWarnings("rawtypes")
    private ParameterList extractGenomeSpaceToken( AuthSuccess authSuccess )
            throws MessageException
    {
        if (authSuccess == null) {
            return null;
        }
        ParameterList returnList = new ParameterList();

        // Only one of these three blocks of code is necessary -- pick one that works
        // and remove the others.  All are included here for illustrative purposes,
        // and also to test the GenomeSpace OpenId Provider.

        @SuppressWarnings("unchecked")
        Set<String> extAliases = authSuccess.getExtensions();
        for (String extAlias : extAliases) {
            logger.debug("Found extension " + extAlias);
            if (extAlias.equals(SRegMessage.OPENID_NS_SREG) || extAlias.equals(SRegMessage.OPENID_NS_SREG11)) {
                MessageExtension ext = authSuccess.getExtension(extAlias);
                if (!(ext instanceof SRegResponse)) {
                    logger.error("Cannot process extension " + extAlias);
                    continue;
                }
                SRegResponse sregResp = (SRegResponse) ext;
                for (Iterator iter = sregResp.getAttributeNames().iterator(); iter.hasNext();) {
                    String name = (String) iter.next();
                    String value = sregResp.getParameterValue(name);
                    logger.info("Found SReg attribute " + name + ":" + value);
                    // Maps SReg nickname -> GenomeSpace username
                    if (name.equals("nickname")) {
                        returnList.addParams(ParameterList.createFromKeyValueForm(
                                GenomeSpaceMessageExtension.USERNAME_ALIAS + ":" + value));
                    }
                    // Maps SReg gender -> GenomeSpace token
                    if (name.equals("gender")) {
                        returnList.addParams(ParameterList.createFromKeyValueForm(
                                GenomeSpaceMessageExtension.TOKEN_ALIAS + ":" + value));
                    }
                    if (name.equals("email")) {
                        returnList.addParams(ParameterList.createFromKeyValueForm(
                                GenomeSpaceMessageExtension.EMAIL_ALIAS + ":" + value));
                    }
                }
            } else if (extAlias.equals(AxMessage.OPENID_NS_AX)) {
                FetchResponse fetchResp = (FetchResponse) authSuccess.getExtension(extAlias);
                List aliases = fetchResp.getAttributeAliases();
                for (Iterator iter = aliases.iterator(); iter.hasNext();) {
                    String name = (String) iter.next();
                    List values = fetchResp.getAttributeValues(name);
                    if (values.size() > 0) {
                        String keyValue = name + ":" + values.get(0);
                        logger.info("Found AX attribute " + keyValue);
                        returnList.addParams(ParameterList.createFromKeyValueForm(keyValue));
                    }
                }
            } else if (extAlias.equals(GenomeSpaceMessageExtension.URI)) {
                MessageExtension msgExt = authSuccess.getExtension(extAlias);
                returnList.addParams(msgExt.getParameters());
            } else {
                logger.warn("No support for extension " + extAlias);
            }
        }

        return returnList;
    }

    @Override
    public void init( ServletConfig config ) throws ServletException
    {
        super.init(config);

        // --- Forward proxy setup (only if needed) ---
        ProxyProperties proxyProps = getProxyProperties(config);
        if (proxyProps != null) {
            logger.debug("ProxyProperties: [{}]", proxyProps);
            HttpClientFactory.setProxyProperties(proxyProps);
        }

        try {
            Message.addExtensionFactory(GenomeSpaceMessageExtensionFactory.class);
        } catch (MessageException e) {
            throw new ServletException("Unable to register GenomeSpaceMessageExtensionFactory", e);
        }

        try {
            manager = new ConsumerManager();
        } catch (Throwable e) {
            throw new ServletException(e);
        }
        manager.setAssociations(new InMemoryConsumerAssociationStore());
        manager.setNonceVerifier(new InMemoryNonceVerifier(5000));
        manager.setMinAssocSessEnc(AssociationSessionType.DH_SHA256);
    }

    private ProxyProperties getProxyProperties( ServletConfig config )
    {
        ProxyProperties proxyProps;
        String host = config.getInitParameter("proxy.host");
        logger.debug("proxy.host: [{}]", host);
        if (host == null) {
            proxyProps = null;
        } else {
            proxyProps = new ProxyProperties();
            String port = config.getInitParameter("proxy.port");
            String username = config.getInitParameter("proxy.username");
            String password = config.getInitParameter("proxy.password");
            String domain = config.getInitParameter("proxy.domain");
            proxyProps.setProxyHostName(host);
            proxyProps.setProxyPort(Integer.parseInt(port));
            proxyProps.setUserName(username);
            proxyProps.setPassword(password);
            proxyProps.setDomain(domain);
        }
        return proxyProps;
    }

    private String getCookie( HttpServletRequest request, String name )
    {
        CookieMap cookies = new CookieMap(request.getCookies());
        return cookies.containsKey(name) ? cookies.get(name).getValue() : null;
    }

    private void setCookie( HttpServletResponse response, String name, String value )
    {
        Cookie cookie = new Cookie(name, null != value ? value : "");
        // if the value is null - delete cookie by expiring it
        if (null == value) {
            cookie.setMaxAge(0);
        }
        response.addCookie(cookie);
    }

}
