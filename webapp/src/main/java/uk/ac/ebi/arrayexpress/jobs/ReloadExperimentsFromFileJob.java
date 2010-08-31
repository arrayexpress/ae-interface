package uk.ac.ebi.arrayexpress.jobs;

import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationJob;
import uk.ac.ebi.arrayexpress.components.Experiments;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;

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

public class ReloadExperimentsFromFileJob extends ApplicationJob
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private final static String EOL = System.getProperty("line.separator");

    public void doExecute( JobExecutionContext jec ) throws Exception
    {
        try {
            StringBuilder xmlBuffer = new StringBuilder(20000000);

            String fileName = getPreferences().getString("ae.experiments.reload.src.file.location");
            logger.info("Reload of experiment data from [{}] requested", fileName);

            File f = new File(fileName);
            if (f.exists() && f.canRead()) {
                BufferedReader r = new BufferedReader(new InputStreamReader(new FileInputStream(f)));
                while ( r.ready() ) {
                    String str = r.readLine();
                // null means stream has reached the end
                    if (null != str) {
                        xmlBuffer.append(str).append(EOL);
                    } else {
                        break;
                    }
                    logger.debug("File successfully read");
                }
            } else {
                logger.warn("File [{}] not found or cannot be opened to read", fileName);
            }

            if (xmlBuffer.length() > 0) {
                //UserList userList = new UserListDatabaseRetriever(ds).getUserList();
                //((Users)getComponent("Users")).setUserList(userList);
                //logger.info("Reloaded the user list from the database");

                //exps = new ExperimentListDatabaseRetriever(ds).getExperimentList();
                //Thread.sleep(1);

                //logger.info("Got [{}] experiments listed in the database, scheduling retrieval", exps.size());
                //xmlBuffer.append("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><experiments total=\"").append(exps.size()).append("\">");


                ((Experiments)getComponent("Experiments")).reload(xmlBuffer.toString());
                logger.info("Reload of experiment data completed");
                xmlBuffer = null;
            } else {
                logger.warn("No experiments found, reload aborted");
            }
        } catch (Exception x) {
            throw new RuntimeException(x);
        }
    }
}
