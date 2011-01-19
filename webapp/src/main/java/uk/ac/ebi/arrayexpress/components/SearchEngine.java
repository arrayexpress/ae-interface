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

import org.apache.commons.configuration.HierarchicalConfiguration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.saxon.search.Controller;
import uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension;
import uk.ac.ebi.arrayexpress.utils.search.BackwardsCompatibleQueryConstructor;

public class SearchEngine extends ApplicationComponent
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private Controller controller;

    public SearchEngine()
    {
    }

    public void initialize() throws Exception
    {
        this.controller = new Controller((HierarchicalConfiguration)getPreferences().getConfSubset("ae"));
        SearchExtension.setController(getController());
        getController().setQueryConstructor(new BackwardsCompatibleQueryConstructor());
    }

    public void terminate() throws Exception
    {
        SearchExtension.setController(null);
    }

    public Controller getController()
    {
        return this.controller;
    }
}
