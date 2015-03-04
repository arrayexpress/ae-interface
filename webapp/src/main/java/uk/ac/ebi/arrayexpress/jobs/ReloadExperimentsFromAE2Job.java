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

import static org.apache.commons.lang.StringUtils.isNotBlank;

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
            if (isNotBlank(sourceLocation)) {
                logger.info("Reload of experiment data from [{}] requested", sourceLocation);

                updateNews(new File(sourceLocation, "news.xml"));
                updateUsers(new File(sourceLocation, "users.xml"));
                updateExperiments(new File(sourceLocation, "experiments.xml"));
                updateArrayDesigns(new File(sourceLocation, "arrays.xml"));
                updateProtocols(new File(sourceLocation, "protocols.xml"));

                logger.info("Reload of experiment data from [{}] completed", sourceLocation);
            }
        } catch (Exception x) {
            throw new RuntimeException(x);
        }
    }

    private String getXmlFromFile( File xmlFile ) throws IOException
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

    private void loadMapFromFile( String mapName, File mapFile ) throws IOException
    {
        if (null != mapFile && mapFile.exists()) {
            ((MapEngine) getComponent("MapEngine")).loadMap(mapName, mapFile);
        }
    }

    private void clearMap( String mapName )
    {
        ((MapEngine) getComponent("MapEngine")).clearMap(mapName);
    }

    private void updateNews( File xmlFile ) throws IOException, InterruptedException
    {
        if (null != xmlFile && xmlFile.exists()) {
            String xmlString = getXmlFromFile(xmlFile);
            if (isNotBlank(xmlString)) {
                ((News) getComponent("News")).update(xmlString);
                logger.info("News reload completed");
            }
        }
    }

    private void updateUsers( File xmlFile ) throws IOException, InterruptedException
    {
        if (null != xmlFile && xmlFile.exists()) {
            String xmlString = getXmlFromFile(xmlFile);
            if (isNotBlank(xmlString)) {
                ((Users) getComponent("Users")).update(xmlString, Users.UserSource.AE2);
                logger.info("User information reload completed");
            } else {
                throw new IOException("[" + xmlFile.getPath() + "] is null or empty");
            }
        } else {
            throw new IOException("Unable to locate [" + (null != xmlFile ? xmlFile.getPath() : "null") + "]");
        }
    }

    private void updateExperiments( File experimentsFile ) throws IOException, InterruptedException
    {
        if (null != experimentsFile && experimentsFile.exists()) {
            String experimentsXml = getXmlFromFile(experimentsFile);

            if (isNotBlank(experimentsXml)) {
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

                UpdateSourceInformation sourceInformation = new UpdateSourceInformation(
                        Experiments.ExperimentSource.AE2
                        , experimentsFile
                );

                loadMapFromFile(
                        Experiments.MAP_EXPERIMENTS_IN_ATLAS
                        , new File(experimentsFile.getParentFile(), "atlas-experiments.txt")
                );

                loadMapFromFile(
                        Experiments.MAP_EXPERIMENTS_VIEWS
                        , new File(experimentsFile.getParentFile(), "experiments-views.txt")
                );

                loadMapFromFile(
                        Experiments.MAP_EXPERIMENTS_DOWNLOADS
                        , new File(experimentsFile.getParentFile(), "experiments-downloads.txt")
                );

                loadMapFromFile(
                        Experiments.MAP_EXPERIMENTS_COMPLETE_DOWNLOADS
                        , new File(experimentsFile.getParentFile(), "experiments-complete-downloads.txt")
                );

                ((Experiments) getComponent("Experiments")).update(
                        experimentsXml
                        , sourceInformation
                );

                clearMap(Experiments.MAP_EXPERIMENTS_IN_ATLAS);
                clearMap(Experiments.MAP_EXPERIMENTS_VIEWS);
                clearMap(Experiments.MAP_EXPERIMENTS_DOWNLOADS);
                clearMap(Experiments.MAP_EXPERIMENTS_COMPLETE_DOWNLOADS);

                logger.info("Experiment information reload completed");
            } else {
                throw new IOException("[" + experimentsFile.getPath() + "] is null or empty");
            }
        } else {
            throw new IOException("Unable to locate [" + (null != experimentsFile ? experimentsFile.getPath() : "null") + "]");
        }
    }

    private void updateArrayDesigns( File xmlFile ) throws IOException, InterruptedException
    {
        if (null != xmlFile && xmlFile.exists()) {
            String xmlString = getXmlFromFile(xmlFile);
            if (isNotBlank(xmlString)) {
                ((ArrayDesigns) getComponent("ArrayDesigns")).update(xmlString, ArrayDesigns.ArrayDesignSource.AE2);
                logger.info("Array design information reload completed");
            } else {
                throw new IOException("[" + xmlFile.getPath() + "] is null or empty");
            }
        } else {
            throw new IOException("Unable to locate [" + (null != xmlFile ? xmlFile.getPath() : "null") + "]");
        }
    }

    private void updateProtocols( File xmlFile ) throws IOException, InterruptedException
    {
        if (null != xmlFile && xmlFile.exists()) {
            String xmlString = getXmlFromFile(xmlFile);
            if (isNotBlank(xmlString)) {
                ((Protocols) getComponent("Protocols")).update(xmlString, Protocols.ProtocolsSource.AE2);
                logger.info("Protocols information reload completed");
            } else {
                throw new IOException("[" + xmlFile.getPath() + "] is null or empty");
            }
        } else {
            throw new IOException("Unable to locate [" + (null != xmlFile ? xmlFile.getPath() : "null") + "]");
        }
    }
}