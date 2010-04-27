package uk.ac.ebi.arrayexpress.jobs;

import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationJob;
import uk.ac.ebi.arrayexpress.components.Experiments;
import uk.ac.ebi.arrayexpress.components.SearchEngine;
import uk.ac.ebi.arrayexpress.utils.saxon.search.Controller;
import uk.ac.ebi.arrayexpress.utils.search.EFOExpandedHighlighter;
import uk.ac.ebi.arrayexpress.utils.search.EFOExpansionLookupIndex;
import uk.ac.ebi.arrayexpress.utils.search.EFOQueryExpander;
import uk.ac.ebi.microarray.ontology.efo.EFOOntologyHelper;

import java.io.InputStream;
import java.util.Map;
import java.util.Set;

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

public class ReloadOntologyJob extends ApplicationJob
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public void doExecute( JobExecutionContext jec ) throws Exception
    {
        String efoLocation = "/WEB-INF/classes/efo.owl";
        logger.info("Loading EFO ontology from [{}]", efoLocation);
        InputStream is = null;
        try {
            is = getApplication().getResource(efoLocation).openStream();
            EFOOntologyHelper efoHelper = new EFOOntologyHelper(is);

            Map<String, Set<String>> efoFullExpansionMap = efoHelper.getFullOntologyExpansionMap();
            Map<String, Set<String>> efoSynonymMap = efoHelper.getSynonymMap();

            String[] synFiles = getPreferences().getStringArray("ae.synonmym.file.name");

            Map<String, String> efoTermById = efoHelper.getTermByIdMap();
            Map<String, Set<String>> efoChildIdsById = efoHelper.getOntologyIdExpansionMap();
            ((Experiments)getComponent("Experiments")).setEfoMaps(efoTermById, efoChildIdsById, efoSynonymMap);

            EFOExpansionLookupIndex ix = new EFOExpansionLookupIndex(getPreferences().getString("ae.efo.index.location"));
            ix.addMaps(efoSynonymMap, efoFullExpansionMap);

            Controller c = ((SearchEngine)getComponent("SearchEngine")).getController();
            c.setQueryExpander(new EFOQueryExpander(ix));
            c.setQueryHighlighter(new EFOExpandedHighlighter());
            logger.info("EFO loading completed");
        } finally {
            if (null != is) {
                is.close();
            }
        }

    }
}