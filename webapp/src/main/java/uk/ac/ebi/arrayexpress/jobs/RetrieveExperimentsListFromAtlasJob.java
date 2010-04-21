package uk.ac.ebi.arrayexpress.jobs;

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

import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.app.ApplicationJob;
import uk.ac.ebi.arrayexpress.components.Experiments;
import uk.ac.ebi.arrayexpress.utils.db.DataSourceFinder;
import uk.ac.ebi.arrayexpress.utils.db.ExperimentListInAtlasDatabaseRetriever;

import javax.sql.DataSource;
import java.util.List;

public class RetrieveExperimentsListFromAtlasJob extends ApplicationJob
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public void doExecute( JobExecutionContext jec ) throws InterruptedException
    {
        List<String> exps;
        DataSource ds;

        Application app = Application.getInstance();
        String dsNames = app.getPreferences().getString("ae.atlasexperiments.datasources");
        logger.info("Reload of list of Atlas experiments from [{}] requested", dsNames);

        ds = new DataSourceFinder().findDataSource(dsNames);
        if (null != ds) {
            exps = new ExperimentListInAtlasDatabaseRetriever(ds).getExperimentList();
            Thread.sleep(1);
            try {
                ((Experiments) app.getComponent("Experiments")).setExperimentsInAtlas(exps);
            } catch (Exception x) {
                throw new RuntimeException(x);
            }
            logger.info("Got [{}] experiments listed in Atlas", exps.size());
        } else {
            logger.warn("No data sources available, reload aborted");
        }
    }
}
