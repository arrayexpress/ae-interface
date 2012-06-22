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

import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.fg.utils.ApplicationJob;
import uk.ac.ebi.fg.utils.ReceivingType;
import uk.ac.ebi.fg.utils.lucene.IndexedDocumentController;
import uk.ac.ebi.fg.utils.objects.EfoTerm;
import uk.ac.ebi.fg.utils.objects.ExperimentId;
import uk.ac.ebi.fg.utils.objects.StaticIndexedEFODocument;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Extracts data from experiments
 */
public class TermToURIMappingJob extends ApplicationJob
{
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public TermToURIMappingJob()
    {
    }

    public void doExecute( JobExecutionContext jobExecutionContext ) throws JobExecutionException, XPathExpressionException, InterruptedException
    {
        JobDataMap dataMap = jobExecutionContext.getJobDetail().getJobDataMap();

        Map<ExperimentId, SortedSet<EfoTerm>> expToURIMap = (ConcurrentHashMap<ExperimentId, SortedSet<EfoTerm>>) dataMap.get("expToURIMap");
        Map<String, String> expToPubMedIdMap = (ConcurrentHashMap<String, String>) dataMap.get("expToPubMedIdMap");
        List experiments = (List) dataMap.get("experiments");
        XPath xp = (XPath) dataMap.get("experimentXPath");
        int counter = (Integer) dataMap.get("counter");

        XPathExpression accessionXpe = xp.compile("accession");
        XPathExpression speciesXpe = xp.compile("species");
        XPathExpression bibliographyXpe = xp.compile("bibliography/accession");
        XPathExpression numOfSampleAttributesXpe = xp.compile("count(sampleattribute)");
        XPathExpression assaycountXpe = xp.compile("assays");

        logger.info("Started " + (counter - experiments.size()) + " - " + counter + " term to URI mapping jobs");

        for (Object node : experiments) {
            Map<String, List<String>> values = new HashMap<String, List<String>>();  // category, values
            String accession = accessionXpe.evaluate(node);
            String species = speciesXpe.evaluate(node);
            int assayCount = Integer.valueOf(assaycountXpe.evaluate(node));

            if (null != accession) {
                // gets all values under sampleattribute that are not category "Organism"
                String sampleAttributeCount = numOfSampleAttributesXpe.evaluate(node);
                if (sampleAttributeCount != null) {
                    int sampleAttribCount = Integer.parseInt(sampleAttributeCount);
                    for (int i = 1; i <= sampleAttribCount; i++) {
                        XPathExpression categoryXpe = xp.compile("child::sampleattribute[position()=" + i + "]/category");
                        String category = categoryXpe.evaluate(node);
                        if (!category.equals("Organism")) {
                            XPathExpression valueCount = xp.compile("child::sampleattribute[position()=" + i + "]/count(value)");
                            if (null != valueCount.evaluate(node)) {
                                int numOfValues = Integer.parseInt(valueCount.evaluate(node));
                                for (int j = 1; j <= numOfValues; j++) {
                                    XPathExpression valueXpe = xp.compile("sampleattribute[position()=" + i + "]/value[position()=" + j + "]");
                                    String value = valueXpe.evaluate(node);

                                    if (values.containsKey(category))
                                        values.get(category).add(value);
                                    else {
                                        List<String> valueList = new LinkedList<String>();
                                        valueList.add(value);
                                        values.put(category, valueList);
                                    }
                                }
                            }
                        }
                    }
                }

                // stores bibliography accession and experiment accession
                String bibId = bibliographyXpe.evaluate(node).trim();
                if (!bibId.equals(""))
                    expToPubMedIdMap.put(accession, bibId);

                if (null != values) {
                    IndexedDocumentController indexedEFO = StaticIndexedEFODocument.getDoc();

                    SortedSet<EfoTerm> result = indexedEFO.getURIs(values);

                    if (!result.isEmpty())
                        expToURIMap.put(new ExperimentId(accession, ReceivingType.OWL, species, assayCount), result);
                }
            }
            Thread.currentThread().wait(1);
        }

        logger.info("Finished " + (counter - experiments.size()) + " - " + counter + " term to URI mapping jobs");

        experiments.clear();
    }
}
