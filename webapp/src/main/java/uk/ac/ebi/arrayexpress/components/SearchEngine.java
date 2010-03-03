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
import uk.ac.ebi.arrayexpress.utils.saxon.search.SearchExtension;

public class SearchEngine extends ApplicationComponent
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private Controller controller;

    public SearchEngine()
    {
        super("SearchEngine");
    }

    public void initialize()
    {
        try {
            this.controller = new Controller(getApplication().getResource("/WEB-INF/classes/aeindex.xml"));
            SearchExtension.setController(getController());
        } catch (Exception x) {
            logger.error("Caught an exception:", x);
        }

    }

    public void terminate()
    {
        SearchExtension.setController(null);
    }

    public Controller getController()
    {
        return this.controller;
    }
}
