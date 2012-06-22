package uk.ac.ebi.fg.jobs;

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

import org.apache.commons.configuration.Configuration;
import org.quartz.SchedulerException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.utils.controller.IJobsController;
import uk.ac.ebi.arrayexpress.utils.efo.IEFO;
import uk.ac.ebi.fg.jobListeners.*;
import uk.ac.ebi.fg.utils.ISimilarityComponent;
import uk.ac.ebi.fg.utils.OntologyDistanceCalculator;
import uk.ac.ebi.fg.utils.PubMedRetriever;
import uk.ac.ebi.fg.utils.objects.*;
import uk.ac.ebi.fg.utils.saxon.IXPathEngine;

import javax.xml.xpath.XPath;
import java.io.*;
import java.util.List;
import java.util.Map;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Prepares jobs for execution
 */
public class JobController
{

    private final Logger logger = LoggerFactory.getLogger(getClass());
    private Map<String, Object> dataMap = new ConcurrentHashMap<String, Object>();
    private IJobsController jobsController;

    private Map<ExperimentId, SortedSet<EfoTerm>> expToURIMap =
            new ConcurrentHashMap<ExperimentId, SortedSet<EfoTerm>>();

    private Map<ExperimentId, SortedSet<ExperimentId>> ontologyResults =
            new ConcurrentHashMap<ExperimentId, SortedSet<ExperimentId>>();

    private Map<String, SortedSet<ExperimentId>> pubMedResults =
            new ConcurrentHashMap<String, SortedSet<ExperimentId>>();

    private Map<String, String> expToPubMedIdMap =
            new ConcurrentHashMap<String, String>();

    private Map<String, SortedSet<PubMedId>> pubMedIdRelationMap =
            new ConcurrentHashMap<String, SortedSet<PubMedId>>();

    // default properties, used if properties are not found in arrayexpress.xml
    private final String[][] defaultProperties = {
            { "ignoreList", "/WEB-INF/classes/sim-efo-ignore.txt" },
            { "lowPriorityOntologyURIs", "/WEB-INF/classes/low-priority-URIs.txt" },
            { "persistence-location-distances", "ontology-distances.ser" },
            { "pub_med_url", "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?db=pubmed&fromdb=pubmed&rettype=xml&id=" },
            { "max_ontology_distance", "2" },
            { "max_pubmed_distance", "1" },
            { "max_displayed_OWL_similarities", "20" },
            { "max_displayed_PubMed_similarities", "20" },
            { "small_experiment_assay_count_limit", "500" },
            { "minimal_calculated_ontology_distance", "2.0" },
            { "quartz_job_group_name", "similarity-jobs" }
    };


    public JobController( ISimilarityComponent similarityComponent, IXPathEngine saxonEngine,
                          Configuration properties, List experiments, XPath xp, IJobsController jobsController,
                          SortedSet<String> lowPriorityOntologyURIs )
            throws Exception
    {

        init(similarityComponent, saxonEngine, properties, experiments, xp, jobsController, lowPriorityOntologyURIs);
        String group = properties.getString("properties.quartz_job_group_name");

        jobsController.addJob("LuceneEFOIndexJob", LuceneEFOIndexJob.class, getDataMap(), group);
        jobsController.addJob("TermToURIMappingWrapperJob", TermToURIMappingWrapperJob.class, getDataMap(), group);

        jobsController.addJob("OntologySimilarityWrapperJob", OntologySimilarityWrapperJob.class, getDataMap(), group);

        jobsController.addJob("PubMedLoadFromFileJob", PubMedLoadFromFileJob.class, getDataMap(), group);
        jobsController.addJob("PubMedDataMinerWrapperJob", PubMedDataMinerWrapperJob.class, getDataMap(), group);
        jobsController.addJob("PubMedUpdateFileJob", PubMedUpdateFileJob.class, getDataMap(), group);
        jobsController.addJob("PubMedSimilarityJob", PubMedSimilarityJob.class, getDataMap(), group);

        jobsController.addJob("XmlWriterJob", XmlWriterJob.class, getDataMap(), group);

        addListerners();

        jobsController.executeJob("LuceneEFOIndexJob", group);
    }

    /**
     * Creates and adds all required job listeners
     *
     * @throws SchedulerException
     */
    private void addListerners() throws SchedulerException
    {
        PubMedUpdateFileJobListener pubMedUpdateFileJobListener = new PubMedUpdateFileJobListener("pubMedUpdateFileJobListener");
        jobsController.addJobListener(pubMedUpdateFileJobListener);


        TermToURIMappingWrapperJobListener termToURIMappingJobListener = new TermToURIMappingWrapperJobListener("termToURIMappingJobListener");
        jobsController.addJobListener(termToURIMappingJobListener);

        ExperimentDataExtractionFinishListener ontologySimilarityJobListener = new ExperimentDataExtractionFinishListener("ontologySimilarityJobListener");
        jobsController.addJobListener(ontologySimilarityJobListener);

        PubMedDataMinerWrapperJobListener pubMedDataMinerWrapperJobListener = new PubMedDataMinerWrapperJobListener("pubMedDataMinerWrapperJobListener");
        jobsController.addJobListener(pubMedDataMinerWrapperJobListener);

        PubMedDataMinerJobListener pubMedDataMinerJobListener = new PubMedDataMinerJobListener("pubMedDataMinerJobListener");
        jobsController.addJobListener(pubMedDataMinerJobListener);

        PubMedSimilarityJobListener pubMedSimilarityJobListener = new PubMedSimilarityJobListener("pubMedSimilarityJobListener");
        jobsController.addJobListener(pubMedSimilarityJobListener);

        XmlWriterJobListener xmlWriterJobListener = new XmlWriterJobListener("xmlWriterJobListener");
        jobsController.addJobListener(xmlWriterJobListener);
    }

    /**
     * Initializes data map for jobs and other objects
     *
     * @param similarityComponent
     * @param saxonEngine
     * @param configuration
     * @param experiments
     * @param xp
     * @param jobsController
     * @param lowPriorityOntologyURIs
     * @throws Exception
     */
    public void init( ISimilarityComponent similarityComponent, IXPathEngine saxonEngine,
                      Configuration configuration, List experiments, XPath xp,
                      IJobsController jobsController, SortedSet<String> lowPriorityOntologyURIs )
            throws Exception
    {
        StaticSimilarityComponent.setComponent(similarityComponent);
        StaticJobController.setJobController(jobsController);
        this.jobsController = jobsController;
        Configuration properties = loadProperties(configuration);
        OntologyDistanceCalculator distanceCalculator = getOntologyDistanceCalculator(EFO.getEfo(),
                properties.getInt("max_ontology_distance"),
                properties.getString("persistence-location-distances"));

        dataMap.put("experiments", experiments);
        dataMap.put("experimentXPath", xp);
        dataMap.put("ontologyResults", ontologyResults);
        dataMap.put("properties", properties);
        dataMap.put("saxonEngine", saxonEngine);
        dataMap.put("pubMedRetriever", new PubMedRetriever(saxonEngine));
        dataMap.put("distanceCalculator", distanceCalculator);
        dataMap.put("expToPubMedIdMap", expToPubMedIdMap);
        dataMap.put("pubMedIdRelationMap", pubMedIdRelationMap);
        dataMap.put("pubMedResults", pubMedResults);
        dataMap.put("expToURIMap", expToURIMap);
        dataMap.put("lowPriorityOntologyURIs", lowPriorityOntologyURIs);
        dataMap.put("jobsController", jobsController);
        dataMap.put("pubMedNewIds", new TreeSet<String>());
    }

    private Configuration loadProperties( Configuration properties )
    {
        if (properties.getString("persistence-location") == null)
            throw new RuntimeException("ae.similarity.persistence-location doesn't exist");

        if (properties != null && !properties.isEmpty()) {
            properties = properties.subset("properties");
            return properties;
        } else {
            for (int i = 0; i < defaultProperties.length; i++) {
                properties.addProperty(defaultProperties[i][0], defaultProperties[i][1]);
            }
            logger.error("Default properties loaded.");

            return properties;
        }
    }

    /**
     * @return data map that is shared between all jobs
     */
    private Map<String, Object> getDataMap()
    {
        return dataMap;
    }

    /**
     * Retrieves ontology distance calculator object from file or creates new object in case EFO version or
     * ontology distance is different to file
     *
     * @param efo                 currently used EFO
     * @param maxOntologyDistance maximal ontology distance for ontology term distance calculations
     * @param fileLocation
     * @return
     * @throws Exception
     */
    private OntologyDistanceCalculator getOntologyDistanceCalculator( IEFO efo, int maxOntologyDistance, String fileLocation ) throws Exception
    {
        String version = efo.getVersionInfo();
        OntologyDistanceCalculator distCalc = null;

        File ontDistFile = new File(fileLocation);

        if (ontDistFile.exists()) {
            FileInputStream fis = new FileInputStream(ontDistFile);
            ObjectInputStream ois = new ObjectInputStream(fis);

            if ((ois.readInt() == maxOntologyDistance) && (ois.readUTF().equals(version))) {
                logger.info("Precalculated ontology distance file found for version " + version +
                        " and distance " + maxOntologyDistance);

                distCalc = (OntologyDistanceCalculator) ois.readObject();

                logger.info("\'ontology distance calculator\' object retrieved from file");
            }
            ois.close();
        }
        if (null == distCalc) {
            logger.info("Matching precalculated ontology distance file not found.");
            distCalc = new OntologyDistanceCalculator(efo, maxOntologyDistance);

            logger.info("Creating file " + ontDistFile);
            FileOutputStream fos = new FileOutputStream(ontDistFile);
            ObjectOutputStream oos = new ObjectOutputStream(fos);
            oos.writeInt(maxOntologyDistance);
            oos.writeUTF(version);
            oos.writeObject(distCalc);

            oos.close();
            logger.info("File " + ontDistFile + " successfully created");
        }

        return distCalc;
    }
}
