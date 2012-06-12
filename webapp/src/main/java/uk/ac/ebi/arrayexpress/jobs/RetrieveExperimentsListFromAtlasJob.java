package uk.ac.ebi.arrayexpress.jobs;

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

import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.app.ApplicationJob;
import uk.ac.ebi.arrayexpress.components.Experiments;

public class RetrieveExperimentsListFromAtlasJob extends ApplicationJob
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public void doExecute( JobExecutionContext jec ) throws Exception
    {
        Application app = Application.getInstance();
        String srcLocation = app.getPreferences().getString("ae.atlasexperiments.source.location");
        logger.info("Reloading a list of experiments present in GXA from [{}]", srcLocation);

        if (null != srcLocation && srcLocation.length() > 0) {
            try {
                ((Experiments) app.getComponent("Experiments")).reloadExperimentsInAtlas(srcLocation);
            } catch (Exception x) {
                // update didn't happen - reschedule
                getController().scheduleJobInFuture(
                        jec.getJobDetail().getKey().getName()
                        , app.getPreferences().getInteger("ae.atlasexperiments.reload.retry")
                );
                throw new RuntimeException(x);
            }
        } else {
            logger.warn("No source location specified, reload not completed");
        }
    }
}
