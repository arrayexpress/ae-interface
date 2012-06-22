package uk.ac.ebi.arrayexpress.jobs;

import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationJob;
import uk.ac.ebi.arrayexpress.components.ArrayDesigns;
import uk.ac.ebi.arrayexpress.components.Experiments;
import uk.ac.ebi.arrayexpress.components.Experiments.UpdateSourceInformation;
import uk.ac.ebi.arrayexpress.components.Protocols;
import uk.ac.ebi.arrayexpress.components.Users;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.io.File;

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

public class ReloadExperimentsFromAE2Job extends ApplicationJob
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public void doExecute( JobExecutionContext jec ) throws Exception
    {
        String usersXml = null;
        String arrayDesignsXml = null;
        String protocolsXml = null;
        String experimentsXml = null;

        try {
            // check preferences and if source location is defined, use that
            String sourceLocation = getPreferences().getString("ae.experiments.ae2.source-location");
            Experiments.UpdateSourceInformation sourceInformation = null;
            if (!"".equals(sourceLocation)) {
                logger.info("Reload of experiment data from [{}] requested", sourceLocation);
                usersXml = getXmlFromFile(new File(sourceLocation, "users.xml"));
                arrayDesignsXml = getXmlFromFile(new File(sourceLocation, "arrays.xml"));
                protocolsXml = getXmlFromFile(new File(sourceLocation, "protocols.xml"));
                File experimentsSourceFile = new File(sourceLocation, "experiments.xml");
                experimentsXml = getXmlFromFile(experimentsSourceFile);
                sourceInformation = new UpdateSourceInformation(
                        Experiments.ExperimentSource.AE2
                        , experimentsSourceFile)
                ;
            }

            // export to temp directory anyway (only if debug is enabled)
            if (logger.isDebugEnabled()) {
                StringTools.stringToFile(
                        experimentsXml
                        , new File(
                                System.getProperty("java.io.tmpdir")
                                , "ae2-src-experiments.xml"
                        )
                        , "UTF-8"
                );
            }

            if (!"".equals(usersXml)) {
                updateUsers(usersXml);
            }

            // update experiments first so protocols and arrays can access experiment information when updating
            if (!"".equals(experimentsXml)) {
                updateExperiments(experimentsXml, sourceInformation);
            }

            if (!"".equals(arrayDesignsXml)) {
                updateArrayDesigns(arrayDesignsXml);
            }

            if (!"".equals(protocolsXml)) {
                updateProtocols(protocolsXml);
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

        logger.info("Platform design information reload completed");

    }

    private void updateProtocols( String xmlString ) throws Exception
    {
        ((Protocols) getComponent("Protocols")).update(xmlString, Protocols.ProtocolsSource.AE2);

        logger.info("Protocols information reload completed");

    }

    private void updateExperiments( String xmlString, UpdateSourceInformation sourceInformation ) throws Exception
    {
        ((Experiments) getComponent("Experiments")).update(
                xmlString
                , sourceInformation
        );

        logger.info("Experiment information reload completed");

    }

}