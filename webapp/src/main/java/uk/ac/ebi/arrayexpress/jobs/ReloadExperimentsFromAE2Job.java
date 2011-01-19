package uk.ac.ebi.arrayexpress.jobs;

import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationJob;
import uk.ac.ebi.arrayexpress.components.ArrayDesigns;
import uk.ac.ebi.arrayexpress.components.Experiments;
import uk.ac.ebi.arrayexpress.components.JobsController;
import uk.ac.ebi.arrayexpress.components.Users;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.io.File;

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

public class ReloadExperimentsFromAE2Job extends ApplicationJob
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public void doExecute( JobExecutionContext jec ) throws Exception
    {
        String usersXml = null;
        String arrayDesignsXml = null;
        String experimentsXml = null;
        String sourceDescription = null;

        // kicks reload of atlas experiments just in case
        ((JobsController) getComponent("JobsController")).executeJob("reload-atlas-info");

        try {
            // check preferences and if source location is defined, use that
            String sourceLocation = getPreferences().getString("ae.experiments.ae2.source-location");
            if (!"".equals(sourceLocation)) {
                logger.info("Reload of experiment data from [{}] requested", sourceLocation);
                usersXml = getXmlFromFile(new File(sourceLocation, "users.xml"));
                arrayDesignsXml = getXmlFromFile(new File(sourceLocation, "arrays.xml"));
                File experimentsSourceFile = new File(sourceLocation, "experiments.xml");
                experimentsXml = getXmlFromFile(experimentsSourceFile);
                sourceDescription = experimentsSourceFile.getAbsolutePath()
                        + " (" + StringTools.longDateTimeToString(experimentsSourceFile.lastModified()) + ")";
            }

            // export to temp directory anyway (only if debug is enabled)
            if (logger.isDebugEnabled()) {
                StringTools.stringToFile(
                        experimentsXml
                        , new File(
                                System.getProperty("java.io.tmpdir")
                                , "ae2-src-experiments.xml"
                        )
                );
            }

            if (!"".equals(arrayDesignsXml)) {
                updateArrayDesigns(arrayDesignsXml);
            }

            if (!"".equals(usersXml)) {
                updateUsers(usersXml);
            }

            if (!"".equals(experimentsXml)) {
                updateExperiments(experimentsXml, sourceDescription);
            }

        } catch (Exception x) {
            throw new RuntimeException(x);
        }
    }

    private String getXmlFromFile(File xmlFile) throws Exception
    {
        logger.info("Getting XML from file [{}]", xmlFile);
        String xml =  StringTools.fileToString(
                xmlFile
                , "UTF-8"
        );
        xml = xml.replaceAll("&amp;#(\\d+);", "&#$1;");
        xml = StringTools.unescapeXMLDecimalEntities(xml);
        xml = StringTools.detectDecodeUTF8Sequences(xml);
        xml = StringTools.replaceIllegalHTMLCharacters(xml);
        return xml;
    }

    private void updateUsers( String xmlString ) throws Exception
    {
        ((Users) getComponent("Users")).update(xmlString, Users.UserSource.AE2);

        logger.info("User information reload completed");

    }

    private void updateArrayDesigns( String xmlString ) throws Exception
    {
        ((ArrayDesigns) getComponent("ArrayDesigns")).update(xmlString, ArrayDesigns.ArrayDesignSource.AE2);

        logger.info("User information reload completed");

    }
    private void updateExperiments( String xmlString, String sourceDescription ) throws Exception
    {
        ((Experiments) getComponent("Experiments")).update(
                xmlString
                , Experiments.ExperimentSource.AE2
                , sourceDescription
        );

        logger.info("Experiment information reload completed");

    }

}