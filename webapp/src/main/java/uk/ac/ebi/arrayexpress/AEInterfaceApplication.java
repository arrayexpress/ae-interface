package uk.ac.ebi.arrayexpress;

/*
 * Copyright 2009-2011 European Molecular Biology Laboratory
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
import org.slf4j.bridge.SLF4JBridgeHandler;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.components.*;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.net.MalformedURLException;
import java.net.URL;

public class AEInterfaceApplication extends Application implements ServletContextListener
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private ServletContext servletContext;

    public AEInterfaceApplication()
    {
        super("arrayexpress");

    //    addComponent(new DbConnectionPool());
        addComponent(new SaxonEngine());
        addComponent(new SearchEngine());
        addComponent(new Events());
        addComponent(new Autocompletion());
        addComponent(new Experiments());
        addComponent(new ArrayDesigns());
        addComponent(new Protocols());
        addComponent(new Users());
        addComponent(new Files());
        addComponent(new JobsController());
        addComponent(new Ontologies());
        addComponent(new Similarity());

    }

    public String getName()
    {
        return null != servletContext ? servletContext.getServletContextName() : null;
    }

    public URL getResource( String path ) throws MalformedURLException
    {
        return null != servletContext ? servletContext.getResource(path) : null;
    }


    public synchronized void contextInitialized( ServletContextEvent sce )
    {
        servletContext = sce.getServletContext();

        logger.info("****************************************************************************************************************************");
        logger.info("*");
        logger.info("*  {}", servletContext.getServletContextName());
        logger.info("*");
        logger.info("****************************************************************************************************************************");

        // re-route all subsequent java.util.logging calls via slf4j
        SLF4JBridgeHandler.install();

        initialize();
    }

    public synchronized void contextDestroyed( ServletContextEvent sce )
    {
        terminate();

        // restore java.util.logging calls to the original state
        SLF4JBridgeHandler.uninstall();

        servletContext = null;

        logger.info("****************************************************************************************************************************" + StringTools.EOL + StringTools.EOL);
    }
}
