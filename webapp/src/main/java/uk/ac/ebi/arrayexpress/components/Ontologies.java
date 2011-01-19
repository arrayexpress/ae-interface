package uk.ac.ebi.arrayexpress.components;

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
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.SynonymsFileReader;
import uk.ac.ebi.arrayexpress.utils.saxon.search.Controller;
import uk.ac.ebi.arrayexpress.utils.search.EFOExpandedHighlighter;
import uk.ac.ebi.arrayexpress.utils.search.EFOExpansionLookupIndex;
import uk.ac.ebi.arrayexpress.utils.search.EFOQueryExpander;
import uk.ac.ebi.microarray.ontology.efo.EFONode;
import uk.ac.ebi.microarray.ontology.efo.EFOOntologyHelper;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;


public class Ontologies extends ApplicationComponent
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private EFOOntologyHelper ontology;

    private SearchEngine search;
    private Autocompletion autocompletion;

    public Ontologies()
    {
    }

    public void initialize() throws Exception
    {
        search = (SearchEngine) getComponent("SearchEngine");
        autocompletion = (Autocompletion) getComponent("Autocompletion");

        ((JobsController)getComponent("JobsController")).executeJob("reload-ontology");
    }

    public void terminate() throws Exception
    {
    }

    public void setOntology( EFOOntologyHelper efoOntology ) throws IOException
    {
        this.ontology = efoOntology;

        autocompletion.rebuild();

        Set<String> stopWords = new HashSet<String>();
        String[] words = getPreferences().getString("ae.efo.stopWords").split("\\s*,\\s*");
        if (null != words && words.length > 0) {
            stopWords.addAll(Arrays.asList(words));
        }
        EFOExpansionLookupIndex ix = new EFOExpansionLookupIndex(
                getPreferences().getString("ae.efo.index.location")
                , stopWords
        );

        String synFileLocation = getPreferences().getString("ae.efo.synonyms");
        if (null != synFileLocation) {
            InputStream is = null;
            try {
                is = getApplication().getResource(synFileLocation).openStream();
                Map<String, Set<String>> synonyms = new SynonymsFileReader(new InputStreamReader(is)).readSynonyms();
                ix.setCustomSynonyms(synonyms);
                logger.debug("Loaded custom synonyms from [{}]", synFileLocation);
            } finally {
                if (null != is) {
                    is.close();
                }
            }
        }
        ix.setOntology(getOntology());
        ix.buildIndex();

        Controller c = search.getController();
        c.setQueryExpander(new EFOQueryExpander(ix));
        c.setQueryHighlighter(new EFOExpandedHighlighter());
    }

    public EFOOntologyHelper getOntology()
    {
        return this.ontology;
    }

    public String getEfoChildren( String efoId )
    {
        StringBuilder sb = new StringBuilder();

        if (null != getOntology()) {
            EFONode node = getOntology().getEfoMap().get(efoId);
            if (null != node) {
                Set<EFONode> children = node.getChildren();
                if (null != children) {
                    for (EFONode child : children) {
                        sb.append(child.getTerm()).append("|o|");
                        if (child.hasChildren()) {
                            sb.append(child.getId());
                        }
                        sb.append("\n");
                    }
                }
            }
        }
        return sb.toString();
    }
}
