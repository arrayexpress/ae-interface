package uk.ac.ebi.arrayexpress.components;

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

import org.apache.commons.configuration.HierarchicalConfiguration;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.saxon.functions.search.GetExperimentScoreFunction;
import uk.ac.ebi.arrayexpress.utils.saxon.functions.search.HighlightQueryFunction;
import uk.ac.ebi.arrayexpress.utils.saxon.functions.search.QueryIndexFunction;
import uk.ac.ebi.arrayexpress.utils.saxon.search.Controller;
import uk.ac.ebi.arrayexpress.utils.search.BatchQueryConstructor;

public class SearchEngine extends ApplicationComponent
{
    private Controller controller;

    public SearchEngine()
    {
    }

    @Override
    public void initialize() throws Exception
    {
        SaxonEngine saxon = (SaxonEngine)getComponent("SaxonEngine");

        this.controller = new Controller((HierarchicalConfiguration)getPreferences().getConfSubset("ae"));
        getController().setQueryConstructor(new BatchQueryConstructor());
        getController().setXPathEngine(saxon);
        if (null != saxon) {
            saxon.registerExtensionFunction(new QueryIndexFunction(getController()));
            saxon.registerExtensionFunction(new HighlightQueryFunction(getController()));
            saxon.registerExtensionFunction(new GetExperimentScoreFunction(getController()));
        }
    }

    @Override
    public void terminate() throws Exception
    {
    }

    public Controller getController()
    {
        return this.controller;
    }
}
