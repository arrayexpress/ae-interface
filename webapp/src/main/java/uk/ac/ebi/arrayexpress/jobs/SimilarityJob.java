package uk.ac.ebi.arrayexpress.jobs;

/*
 * Copyright 2009-2014 European Molecular Biology Laboratory
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

import net.sf.saxon.xpath.XPathEvaluator;
import org.apache.commons.configuration.Configuration;
import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationJob;
import uk.ac.ebi.arrayexpress.components.Experiments;
import uk.ac.ebi.arrayexpress.components.JobsController;
import uk.ac.ebi.arrayexpress.components.Ontologies;
import uk.ac.ebi.arrayexpress.utils.StringTools;
import uk.ac.ebi.arrayexpress.utils.efo.IEFO;
import uk.ac.ebi.fg.utils.objects.EFO;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;

public class SimilarityJob extends ApplicationJob
{
    private final Logger logger = LoggerFactory.getLogger(getClass());

    @Override
    public void doExecute(JobExecutionContext jobExecutionContext) throws Exception
    {
        Ontologies ontologies = ((Ontologies) getComponent("Ontologies"));

        synchronized (this) {
            while (!ontologies.getEfoLoadedFlag()) {
                this.wait(1000);
            }
            logger.info("SimilarityJob started ");

            Configuration properties = loadProperties();
            JobsController jobController =  (JobsController) getComponent("JobsController");

            // make efo accessible
            IEFO efo = ontologies.removeIgnoredClasses(ontologies.getEfo(), properties.getString("properties.ignoreList"));
            EFO.setEfo(efo);

            SortedSet<String> lowPriorityOntologyURIs = getLowPriorityURIList(efo, properties.getString("properties.lowPriorityOntologyURIs"));

            // get experiments
            Experiments exp = (Experiments) getComponent("Experiments");
            XPath xp = new XPathEvaluator(exp.getRootNode().getConfiguration());
            XPathExpression xpe = xp.compile("/experiments/experiment[source/@visible = 'true']");
            List experiments = (List) xpe.evaluate(exp.getRootNode(), XPathConstants.NODESET);
            logger.info("Got " + experiments.size() + " experiments.");

// TODO: reinstate this
//            new JobController( ((Similarity) Application.getAppComponent("Similarity")),
//                    ((SaxonEngine) getComponent("SaxonEngine")), properties, experiments,
//                    xp, jobController, lowPriorityOntologyURIs);
        }
    }

    private Configuration loadProperties()
    {
        Configuration properties = null;
        try{
            properties = getPreferences().getConfSubset("ae.similarity");
        } catch (Exception e) {
            logger.error("Failed to get properties from file; exception: " + e.getMessage());
        }

        return properties;
    }

    private SortedSet<String> getLowPriorityURIList( IEFO efo, String ignoreListFileLocation ) throws IOException
    {
        SortedSet<String> lowPriorityURIs = new TreeSet<>();

        if (null != ignoreListFileLocation) {

            try (InputStream is = getApplication().getResource(ignoreListFileLocation).openStream()){
                Set<String> lowPriorityURIList = StringTools.streamToStringSet(is, "UTF-8");

                logger.debug("Loaded low priority ontology classes from [{}]", ignoreListFileLocation);
                for (String uri : lowPriorityURIList) {
                    if (null != uri && !"".equals(uri) && !uri.startsWith("#") ) {
                        if ( efo.getMap().containsKey(uri) )
                            lowPriorityURIs.add(uri);
                        else
                            logger.warn("URI: " + uri + " doesn't exist in EFO");
                    }
                }
            }
        }
        return Collections.synchronizedSortedSet(lowPriorityURIs);
    }
}
