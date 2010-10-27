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

import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.quartz.JobListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationJob;
import uk.ac.ebi.arrayexpress.components.DbConnectionPool;
import uk.ac.ebi.arrayexpress.components.Experiments;
import uk.ac.ebi.arrayexpress.components.JobsController;
import uk.ac.ebi.arrayexpress.components.Users;
import uk.ac.ebi.arrayexpress.utils.StringTools;
import uk.ac.ebi.arrayexpress.utils.db.ExperimentListDatabaseRetriever;
import uk.ac.ebi.arrayexpress.utils.db.IConnectionSource;
import uk.ac.ebi.arrayexpress.utils.db.UserListDatabaseRetriever;
import uk.ac.ebi.arrayexpress.utils.users.UserList;

import java.io.File;
import java.util.List;

public class ReloadExperimentsFromAE1Job extends ApplicationJob implements JobListener
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private List<Long> exps;
    private IConnectionSource connectionSource;
    private StringBuffer xmlBuffer;

    private int numThreadsCompleted;
    private int expsPerThread;

    public void doExecute( JobExecutionContext jec ) throws Exception
    {
        try {
            Long threads = getPreferences().getLong("ae.experiments.ae1.reload.threads");
            if (null != threads) {
                int numThreadsForRetrieval = threads.intValue();
                numThreadsCompleted = 0;
                xmlBuffer = new StringBuffer(20000000);

                JobDataMap jdm = jec.getMergedJobDataMap();
                String connNames = jdm.getString("connections");
                if (null == connNames || 0 == connNames.length()) {
                    connNames = getPreferences().getString("ae.experiments.ae1.db-connections");
                }
                logger.info("Reload of experiment data from [{}] requested", connNames);

                connectionSource = ((DbConnectionPool) getComponent("DbConnectionPool")).getConnectionSource(connNames);

                if (null != connectionSource) {
                    // kicks reload of atlas experiments just in case
                    ((JobsController) getComponent("JobsController")).executeJob("reload-atlas-info");

                    UserList userList = new UserListDatabaseRetriever(connectionSource).getUserList();
                    ((Users) getComponent("Users")).setUserList(userList);
                    logger.info("Reloaded the user list from the database");

                    exps = new ExperimentListDatabaseRetriever(connectionSource).getExperimentList();
                    Thread.sleep(1);

                    logger.info("Got [{}] experiments listed in the database, scheduling retrieval", exps.size());
                    xmlBuffer.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
                            .append("<experiments total=\"").append(exps.size()).append("\">")
                            ;

                    ((JobsController) getComponent("JobsController")).setJobListener(this);

                    if (exps.size() > 0) {
                        if (exps.size() <= numThreadsForRetrieval) {
                            numThreadsForRetrieval = 1;
                        }
                        // split list into several pieces
                        expsPerThread = (int) Math.ceil(((double) exps.size()) / ((double) numThreadsForRetrieval));
                        for (int i = 0; i < numThreadsForRetrieval; ++i) {
                            ((JobsController) getComponent("JobsController")).executeJobWithParam("retrieve-xml", "index", String.valueOf(i));
                            Thread.sleep(1);
                        }

                        while (numThreadsCompleted < numThreadsForRetrieval) {
                            Thread.sleep(1000);
                        }

                        ((JobsController) getComponent("JobsController")).setJobListener(null);
                        xmlBuffer.append("</experiments>");

                        String experimentsXmlText = xmlBuffer.toString();

                        if (logger.isDebugEnabled()) {
                            StringTools.stringToFile(experimentsXmlText, new File(System.getProperty("java.io.tmpdir"), "ae1-raw-experiments.txt"));
                        }

                        experimentsXmlText = StringTools.replaceIllegalHTMLCharacters(       // filter out all junk Unicode chars
                                StringTools.unescapeXMLDecimalEntities(             // convert &#dddd; entities to their Unicode values
                                        StringTools.detectDecodeUTF8Sequences(      // attempt to intelligently convert UTF-8 to Unicode
                                                experimentsXmlText
                                        ).replaceAll("&amp;#(\\d+);", "&#$1;")      // transform &amp;#dddd; -> &#dddd;
                                )
                        );

                        if (logger.isDebugEnabled()) {
                            StringTools.stringToFile(experimentsXmlText, new File(System.getProperty("java.io.tmpdir"), "ae1-raw-experiments.xml"));
                        }
                        ((Experiments) getComponent("Experiments")).update(experimentsXmlText, Experiments.ExperimentSource.AE1);
                        logger.info("Reload of experiment data completed");
                        xmlBuffer = null;
                    } else {
                        logger.warn("No experiments found, reload aborted");
                    }
                } else {
                    logger.warn("No connections available from [{}], reload aborted", connNames);
                }
            }
        } catch (Exception x) {
            throw new RuntimeException(x);
        } finally {
            if (null != connectionSource) {
                connectionSource.close();
                connectionSource = null;
            }
        }
    }

    // jobListener support
    public String getName()
    {
        return "job-listener";
    }

    public void jobToBeExecuted( JobExecutionContext jec )
    {
        if (jec.getJobDetail().getName().equals("retrieve-xml")) {
            JobDataMap jdm = jec.getMergedJobDataMap();
            int index = Integer.parseInt(jdm.getString("index"));
            jdm.put("xmlBuffer", xmlBuffer);
            jdm.put("connectionSource", connectionSource);
            jdm.put("exps", exps.subList(index * expsPerThread, Math.min(((index + 1) * expsPerThread), exps.size())));
        }
    }

    public void jobExecutionVetoed( JobExecutionContext jec )
    {
        if (jec.getJobDetail().getName().equals("retrieve-xml")) {
            try {
                interrupt();
            } catch (Exception x) {
                logger.error("Caught an exception:", x);
            }
        }
    }

    public void jobWasExecuted( JobExecutionContext jec, JobExecutionException jobException )
    {
        if (jec.getJobDetail().getName().equals("retrieve-xml")) {
            JobDataMap jdm = jec.getMergedJobDataMap();
            jdm.remove("xmlObject");
            jdm.remove("connectionSource");
            jdm.remove("exps");

            incrementCompletedThreadsCounter();
        }
    }

    private synchronized void incrementCompletedThreadsCounter()
    {
        numThreadsCompleted++;
    }
}
