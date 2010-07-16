package uk.ac.ebi.arrayexpress.jobs;

import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationJob;
import uk.ac.ebi.arrayexpress.components.Experiments;
import uk.ac.ebi.arrayexpress.components.Protocols;
import uk.ac.ebi.arrayexpress.components.Users;

import java.io.*;

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
        loadExperiments();
        loadUsers();
        loadProtocols();
    }

    private void loadExperiments() {
        try {

            //ToDO: put file name in configuration
            String xmlString = readXMLString("experiments");

            if (xmlString.length() > 0) {
                //ToDo: refactor Component -  add "reload(xmlString)" method, then merge load... methods
                ((Experiments)getComponent("Experiments")).reload(xmlString);
                logger.info("Reload of experiment data completed");
            } else {
                logger.warn("No experiments found, reload aborted");
            }

        } catch (Exception x) {
            throw new RuntimeException(x);
        }
    }

    private void loadUsers() {
        try {

            //ToDO: put file name in configuration
            String xmlString = readXMLString("users");

            if (xmlString.length() > 0) {
                ((Users)getComponent("Users")).reload(xmlString);
                logger.info("Reload of users data completed");
            } else {
                logger.warn("No users found, reload aborted");
            }

        } catch (Exception x) {
            throw new RuntimeException(x);
        }
    }

    private void loadProtocols() {
        try {

            //ToDO: put file name in configuration
            String xmlString = readXMLString("protocols");

            if (xmlString.length() > 0) {
                ((Protocols)getComponent("Protocols")).reload(xmlString);
                logger.info("Reload of protocols data completed");
            } else {
                logger.warn("No users protocols, reload aborted");
            }

        } catch (Exception x) {
            throw new RuntimeException(x);
        }
    }


    private String readXMLString(String dataType) throws IOException {
        StringBuilder xmlBuffer = new StringBuilder(20000000);
        String fileName = getPreferences().getString("ae.reload.xml.file.location") +"/" + dataType + ".xml";
        logger.info("Reload of " + dataType + " data from [{}] requested", fileName);

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
        return xmlBuffer.toString();
    }
}
