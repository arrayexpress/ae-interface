package uk.ac.ebi.arrayexpress.components;

/*
 * Copyright 2009-2010 Microarray Informatics Group, European Bioinformatics Institute
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
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.saxon.search.Controller;
import uk.ac.ebi.arrayexpress.utils.search.EFOExpandedHighlighter;
import uk.ac.ebi.arrayexpress.utils.search.EFOExpansionLookupIndex;
import uk.ac.ebi.arrayexpress.utils.search.EFOQueryExpander;
import uk.ac.ebi.microarray.ontology.efo.EFOOntologyHelper;

import java.util.Map;
import java.util.Set;


public class Ontologies extends ApplicationComponent
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public Ontologies()
    {
        super("Ontologies");
    }

    public void initialize()
    {
        try {
            EFOOntologyHelper efoHelper = new EFOOntologyHelper(this.getApplication().getResource("/WEB-INF/classes/efo.owl").openStream());

            Map<String, Set<String>> efoFullExpansionMap = efoHelper.getFullOntologyExpansionMap();
            Map<String, Set<String>> efoSynonymMap = efoHelper.getSynonymMap();

            EFOExpansionLookupIndex ix = new EFOExpansionLookupIndex(getPreferences().getString("ae.efo.index.location"));
            ix.addMaps(efoSynonymMap, efoFullExpansionMap);

            Controller c = ((SearchEngine)getComponent("SearchEngine")).getController();
            c.setQueryExpander(new EFOQueryExpander(ix));
            c.setQueryHighlighter(new EFOExpandedHighlighter());

        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }
    }

    public void terminate()
    {
    }
}
