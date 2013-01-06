package uk.ac.ebi.arrayexpress.app;

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

import org.apache.commons.lang.text.StrSubstitutor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.utils.EmailSender;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.net.InetAddress;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

public abstract class Application
{
    // logging machinery
    private static final Logger logger = LoggerFactory.getLogger(Application.class);

    private ApplicationPreferences prefs;
    private Map<String, ApplicationComponent> components;
    private EmailSender emailer;

    private static Application appInstance = null;

    public Application( String prefsName )
    {
        prefs = new ApplicationPreferences(prefsName);
        components = new LinkedHashMap<String, ApplicationComponent>();
        // setting application instance available to whoever wants it
        if (null == appInstance) {
            appInstance = this;
        }
    }

    public abstract String getName();

    public abstract URL getResource( String path ) throws MalformedURLException;

    public void addComponent( ApplicationComponent component )
    {
        if (components.containsKey(component.getName())) {
            logger.error("The component [{}] has already been added to the application", component.getName());
        } else {
            components.put(component.getName(), component);
        }
    }

    public ApplicationComponent getComponent( String name )
    {
        if (components.containsKey(name))
            return components.get(name);
        else
            return null;
    }

    public ApplicationPreferences getPreferences()
    {
        return prefs;
    }

    public void initialize()
    {
        logger.debug("Initializing the application...");
        prefs.initialize();
        emailer = new EmailSender(
                getPreferences().getString("app.reports.smtp.host")
                , getPreferences().getInteger("app.reports.smtp.port")
        );

        for (ApplicationComponent c : components.values()) {
            logger.info("Initializing component [{}]", c.getName());
            try {
                c.initialize();
            } catch (RuntimeException x) {
                logger.error("[SEVERE] Caught a runtime exception while initializing [" + c.getName() + "]:", x);
                sendExceptionReport("[SEVERE] Caught a runtime exception while initializing [" + c.getName() + "]", x);
            } catch (Error x) {
                logger.error("[SEVERE] Caught an error while initializing [" + c.getName() + "]:", x);
                sendExceptionReport("[SEVERE] Caught an error while initializing [" + c.getName() + "]", x);
            } catch (Exception x) {
                logger.error("Caught an exception while initializing [" + c.getName() + "]:", x);
            }
        }
    }

    public void terminate()
    {
        logger.debug("Terminating the application...");
        ApplicationComponent[] compArray = components.values().toArray(new ApplicationComponent[components.size()]);

        for (int i = compArray.length - 1; i >= 0; --i) {
            ApplicationComponent c = compArray[i];
            logger.info("Terminating component [{}]", c.getName());
            try {
                c.terminate();
            } catch (Throwable x) {
                logger.error("Caught an exception while terminating [" + c.getName() + "]:", x);
            }
        }
        // release references to application components
        components.clear();
        components = null;

        if (null != appInstance) {
            // remove reference to self
            appInstance = null;
        }
    }

    public void sendEmail( String subject, String message )
    {
        try {
            Thread currentThread = Thread.currentThread();
            String hostName = "unknown";
            try {
                InetAddress localMachine = InetAddress.getLocalHost();
                hostName = localMachine.getHostName();
            } catch (Exception xx) {
                logger.debug("Caught an exception:", xx);
            }

            Map<String, String> params = new HashMap<String, String>();
            params.put("variable.appname", getName());
            params.put("variable.thread", String.valueOf(currentThread));
            params.put("variable.hostname", hostName);
            StrSubstitutor sub = new StrSubstitutor(params);
            
            emailer.send(getPreferences().getStringArray("app.reports.recipients")
                    , subject
                    , sub.replace(message)
                    , getPreferences().getString("app.reports.originator")
            );

        } catch (Throwable x) {
            logger.error("[SEVERE] Cannot even send an email without an exception:", x);
        }
    }

    public void sendExceptionReport( String message, Throwable x )
    {
        sendEmail( getPreferences().getString("app.reports.subject")
                , message + ": " + x.getMessage() + StringTools.EOL
                    + "Application [${variable.appname}]" + StringTools.EOL
                    + "Host [${variable.hostname}]" + StringTools.EOL
                    + "Thread [${variable.thread}]" + StringTools.EOL
                    + getStackTrace(x)
        );
    }

    private String getStackTrace( Throwable x )
    {
        final Writer result = new StringWriter();
        final PrintWriter printWriter = new PrintWriter(result);
        x.printStackTrace(printWriter);
        return result.toString();
    }

    public static Application getInstance()
    {
        if (null == appInstance) {
            logger.error("Attempted to obtain application instance before initialization or after destruction");
        }
        return appInstance;
    }

    public static ApplicationComponent getAppComponent( String name )
    {
        return getInstance().getComponent(name);
    }
}
