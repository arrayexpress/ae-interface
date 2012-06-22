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
import uk.ac.ebi.arrayexpress.utils.HTMLOptions;
import uk.ac.ebi.arrayexpress.utils.StringTools;
import uk.ac.ebi.arrayexpress.utils.SynonymsFileReader;
import uk.ac.ebi.arrayexpress.utils.efo.EFOLoader;
import uk.ac.ebi.arrayexpress.utils.efo.EFONode;
import uk.ac.ebi.arrayexpress.utils.efo.IEFO;
import uk.ac.ebi.arrayexpress.utils.saxon.search.Controller;
import uk.ac.ebi.arrayexpress.utils.search.EFOExpandedHighlighter;
import uk.ac.ebi.arrayexpress.utils.search.EFOExpansionLookupIndex;
import uk.ac.ebi.arrayexpress.utils.search.EFOQueryExpander;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;


public class Ontologies extends ApplicationComponent
{
    private class EFOSubclassesOptions extends HTMLOptions
    {
        private String defaultOption;

        public EFOSubclassesOptions( String defaultOption )
        {
            this.defaultOption = defaultOption;
            initialize();
            initialize();
        }

        private void initialize()
        {
            clearOptions();
            addOption("", defaultOption);
        }

        public void reload( IEFO efo, String baseNode )
        {
            initialize();
            EFONode node = efo.getMap().get(baseNode);
            if (null != node) {
                for (EFONode subclass : node.getChildren()) {
                    addOption("\"" + subclass.getTerm().toLowerCase() + "\"", subclass.getTerm());
                }
            }
        }
    }

    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private IEFO efo;
    private EFOExpansionLookupIndex lookupIndex;
    private AtomicBoolean hasEfoLoaded = new AtomicBoolean(false);

    private SearchEngine search;
    private Autocompletion autocompletion;

    private EFOSubclassesOptions assayByMolecule;
    private EFOSubclassesOptions assayByInstrument;

    public Ontologies()
    {
    }

    public void initialize() throws Exception
    {
        this.search = (SearchEngine) getComponent("SearchEngine");
        this.autocompletion = (Autocompletion) getComponent("Autocompletion");
        initLookupIndex();
        ((JobsController) getComponent("JobsController")).scheduleJobNow("reload-efo");

        this.assayByMolecule = new EFOSubclassesOptions("All assays by molecule");
        this.assayByInstrument = new EFOSubclassesOptions("All technologies");
    }

    public void terminate() throws Exception
    {
    }

    public void update( InputStream ontologyStream ) throws IOException, InterruptedException
    {
        setEfoLoadedFlag(false);

        // load custom synonyms to lookup index
        loadCustomSynonyms();

        this.efo = removeIgnoredClasses(new EFOLoader().load(ontologyStream));

        this.lookupIndex.setEfo(getEfo());
        this.lookupIndex.buildIndex();

        if (null != this.autocompletion) {
            this.autocompletion.setEfo(getEfo());
            this.autocompletion.rebuild();
        }

        this.assayByMolecule.reload(getEfo(), "http://www.ebi.ac.uk/efo/EFO_0002772");
        this.assayByInstrument.reload(getEfo(), "http://www.ebi.ac.uk/efo/EFO_0002773");

        setEfoLoadedFlag(true);
    }

    public IEFO getEfo()
    {
        return this.efo;
    }

    public String getAssayByMoleculeOptions()
    {
        return this.assayByMolecule.getHtml();
    }

    public String getAssayByInstrumentOptions()
    {
        return this.assayByInstrument.getHtml();
    }

    private void loadCustomSynonyms() throws IOException
    {
        String synFileLocation = getPreferences().getString("ae.efo.synonyms");
        if (null != synFileLocation) {
            InputStream is = null;
            try {
                is = getApplication().getResource(synFileLocation).openStream();
                Map<String, Set<String>> synonyms = new SynonymsFileReader(new InputStreamReader(is)).readSynonyms();
                this.lookupIndex.setCustomSynonyms(synonyms);
                logger.debug("Loaded custom synonyms from [{}]", synFileLocation);
            } finally {
                if (null != is) {
                    is.close();
                }
            }
        }
    }

    public IEFO removeIgnoredClasses( IEFO efo, String ignoreListFileLocation ) throws IOException
    {
        if (null != ignoreListFileLocation) {
            InputStream is = null;
            try {
                is = getApplication().getResource(ignoreListFileLocation).openStream();
                Set<String> ignoreList = StringTools.streamToStringSet(is, "UTF-8");

                logger.debug("Loaded EFO ignored classes from [{}]", ignoreListFileLocation);
                for (String id : ignoreList) {
                    if (null != id && !"".equals(id) && !id.startsWith("#") && efo.getMap().containsKey(id)) {
                        removeEFONode(efo, id);
                    }
                }
            } finally {
                if (null != is) {
                    is.close();
                }
            }
        }
        return efo;
    }

    private IEFO removeIgnoredClasses( IEFO efo ) throws IOException
    {
        return removeIgnoredClasses(efo, getPreferences().getString("ae.efo.ignoreList"));
    }

    private void removeEFONode( IEFO efo, String nodeId )
    {
        EFONode node = efo.getMap().get(nodeId);
        // step 1: for all parents remove node as a child
        for (EFONode parent : node.getParents()) {
            parent.getChildren().remove(node);
        }
        // step 2: for all children remove node as a parent; is child node has no other parents, remove it completely
        for (EFONode child : node.getChildren()) {
            child.getParents().remove(node);
            if (0 == child.getParents().size()) {
                removeEFONode(efo, child.getId());
            }
        }

        // step 3: remove node from efo map
        efo.getMap().remove(nodeId);
        logger.debug("Removed [{}] -> [{}]", node.getId(), node.getTerm());
    }

    private void initLookupIndex() throws IOException
    {
        Set<String> stopWords = new HashSet<String>();
        String[] words = getPreferences().getString("ae.efo.stopWords").split("\\s*,\\s*");
        if (null != words && words.length > 0) {
            stopWords.addAll(Arrays.asList(words));
        }
        this.lookupIndex = new EFOExpansionLookupIndex(
                getPreferences().getString("ae.efo.index.location")
                , stopWords
        );

        Controller c = search.getController();
        c.setQueryExpander(new EFOQueryExpander(this.lookupIndex));
        c.setQueryHighlighter(new EFOExpandedHighlighter());
    }

    public boolean getEfoLoadedFlag()
    {
        return hasEfoLoaded.get();
    }

    private void setEfoLoadedFlag( boolean flag )
    {
        hasEfoLoaded.set(flag);
    }
}
