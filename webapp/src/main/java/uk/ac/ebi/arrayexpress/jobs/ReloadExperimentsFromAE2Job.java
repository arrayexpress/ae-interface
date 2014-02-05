package uk.ac.ebi.arrayexpress.jobs;

import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationJob;
import uk.ac.ebi.arrayexpress.components.*;
import uk.ac.ebi.arrayexpress.components.Experiments.UpdateSourceInformation;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.io.File;
import java.io.IOException;

/*
 * Copyright 2009-2014 European Molecular Biology Laboratory
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

    @Override
    public void doExecute( JobExecutionContext jec ) throws Exception
    {


        try {
            // check preferences and if source location is defined, use that
            String sourceLocation = getPreferences().getString("ae.experiments.ae2.source-location");
            Experiments.UpdateSourceInformation sourceInformation = null;
            if (!"".equals(sourceLocation)) {
                logger.info("Reload of experiment data from [{}] requested", sourceLocation);

                File newsFile = new File(sourceLocation, "news.xml");
                String newsXml = null;
                if (newsFile.exists()) {
                    newsXml = getXmlFromFile(newsFile);
                }

                String usersXml = getXmlFromFile(new File(sourceLocation, "users.xml"));
                String arrayDesignsXml = getXmlFromFile(new File(sourceLocation, "arrays.xml"));
                String protocolsXml = getXmlFromFile(new File(sourceLocation, "protocols.xml"));
                File experimentsSourceFile = new File(sourceLocation, "experiments.xml");
                String experimentsXml = getXmlFromFile(experimentsSourceFile);
                sourceInformation = new UpdateSourceInformation(
                        Experiments.ExperimentSource.AE2
                        , experimentsSourceFile)
                ;

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

                if (null != newsXml && !"".equals(newsXml)) {
                    updateNews(newsXml);
                }

                if (null != usersXml && !"".equals(usersXml)) {
                    updateUsers(usersXml);
                }

                // update experiments first so protocols and arrays can access experiment information when updating
                if (null != experimentsXml && !"".equals(experimentsXml)) {
                    updateExperiments(experimentsXml, sourceInformation);
                }

                if (null != arrayDesignsXml && !"".equals(arrayDesignsXml)) {
                    updateArrayDesigns(arrayDesignsXml);
                }

                if (null != protocolsXml && !"".equals(protocolsXml)) {
                    updateProtocols(protocolsXml);
                }

                logger.info("Reload of experiment data from [{}] completed", sourceLocation);
            }

        } catch (Exception x) {
            throw new RuntimeException(x);
        }
    }

    private String getXmlFromFile(File xmlFile) throws IOException
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

    private void updateNews( String xmlString ) throws IOException, InterruptedException
    {
        ((News) getComponent("News")).update(xmlString);

        logger.info("News reload completed");

    }

    private void updateUsers( String xmlString ) throws IOException, InterruptedException
    {
        ((Users) getComponent("Users")).update(xmlString, Users.UserSource.AE2);

        logger.info("User information reload completed");

    }

    private void updateArrayDesigns( String xmlString ) throws IOException, InterruptedException
    {
        ((ArrayDesigns) getComponent("ArrayDesigns")).update(xmlString, ArrayDesigns.ArrayDesignSource.AE2);

        logger.info("Platform design information reload completed");

    }

    private void updateProtocols( String xmlString ) throws IOException, InterruptedException
    {
        ((Protocols) getComponent("Protocols")).update(xmlString, Protocols.ProtocolsSource.AE2);

        logger.info("Protocols information reload completed");

    }

    private void updateExperiments( String xmlString, UpdateSourceInformation sourceInformation ) throws IOException, InterruptedException
    {
        ((Experiments) getComponent("Experiments")).update(
                xmlString
                , sourceInformation
        );

        logger.info("Experiment information reload completed");

    }

}