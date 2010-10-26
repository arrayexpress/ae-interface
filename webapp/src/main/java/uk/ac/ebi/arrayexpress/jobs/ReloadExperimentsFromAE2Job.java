package uk.ac.ebi.arrayexpress.jobs;

import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationJob;
import uk.ac.ebi.arrayexpress.components.Experiments;
import uk.ac.ebi.arrayexpress.components.JobsController;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.io.File;

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

public class ReloadExperimentsFromAE2Job extends ApplicationJob
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public void doExecute( JobExecutionContext jec ) throws Exception
    {
        try {
            // kicks reload of atlas experiments just in case
            ((JobsController) getComponent("JobsController")).executeJob("reload-atlas-info");

            // TODO: user info should be merged as well at some point
            // String usersFileLocation = getPreferences().getString("ae.users.source.location");
            // logger.info("Reloading user information from [{}]", usersFileLocation);
            //
            // String usersXmlText = StringTools.fileToString(new File(usersFileLocation), "UTF-8");
            // if (usersXmlText.length() > 0) {
            //      ((Users)getComponent("Users")).update(usersXmlText, "preprocess-ae2-users-txt.xsl");
            //      logger.info("Reload of user information completed");
            // } else {
            //      logger.warn("User info XML [{}] is empty", usersFileLocation);
            // }

            String experimentsFileLocation = getPreferences().getString("ae.experiments.source.location");
            logger.info("Reloading experiments from [{}]", experimentsFileLocation);

            String experimentsXmlText = StringTools.fileToString(new File(experimentsFileLocation), "UTF-8");
            experimentsXmlText = experimentsXmlText.replaceAll("&amp;#(\\d+);", "&#$1;");
            experimentsXmlText = StringTools.unescapeXMLDecimalEntities(experimentsXmlText);
            experimentsXmlText = StringTools.detectDecodeUTF8Sequences(experimentsXmlText);
            experimentsXmlText = StringTools.replaceIllegalHTMLCharacters(experimentsXmlText);

            if (logger.isDebugEnabled()) {
                StringTools.stringToFile(experimentsXmlText, new File(System.getProperty("java.io.tmpdir"), "ae2-src-experiments.xml"));
            }

            if (experimentsXmlText.length() > 0) {
                ((Experiments)getComponent("Experiments")).update(experimentsXmlText, Experiments.ExperimentSource.AE2);
                logger.info("Reload of experiments completed");
            } else {
                logger.warn("Experiments XML [{}] is empty", experimentsFileLocation);
            }
        } catch (Exception x) {
            throw new RuntimeException(x);
        }
    }
}