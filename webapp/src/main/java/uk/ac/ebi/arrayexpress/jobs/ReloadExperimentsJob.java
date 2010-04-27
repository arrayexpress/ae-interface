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
import uk.ac.ebi.arrayexpress.components.Experiments;
import uk.ac.ebi.arrayexpress.components.JobsController;
import uk.ac.ebi.arrayexpress.components.Users;
import uk.ac.ebi.arrayexpress.utils.StringTools;
import uk.ac.ebi.arrayexpress.utils.db.DataSourceFinder;
import uk.ac.ebi.arrayexpress.utils.db.ExperimentListDatabaseRetriever;
import uk.ac.ebi.arrayexpress.utils.db.UserListDatabaseRetriever;
import uk.ac.ebi.arrayexpress.utils.users.UserList;

import javax.sql.DataSource;
import java.io.File;
import java.util.List;

public class ReloadExperimentsJob extends ApplicationJob implements JobListener
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private List<Long> exps;
    private DataSource ds;
    private StringBuffer xmlBuffer;

    private int numThreadsCompleted;
    private int expsPerThread;

    public void doExecute( JobExecutionContext jec ) throws Exception
    {
        try {
            Long threads = getPreferences().getLong("ae.experiments.reload.threads");
            if (null != threads) {
                int numThreadsForRetrieval = threads.intValue();
                numThreadsCompleted = 0;
                xmlBuffer = new StringBuffer(20000000);

                JobDataMap jdm = jec.getMergedJobDataMap();
                String dsNames = jdm.getString("dsnames");
                if (null == dsNames || 0 == dsNames.length()) {
                    dsNames = ((Experiments) getComponent("Experiments")).getDataSource();
                }
                logger.info("Reload of experiment data from [{}] requested", dsNames);

                ds = new DataSourceFinder().findDataSource(dsNames);
                if (null != ds) {
                    UserList userList = new UserListDatabaseRetriever(ds).getUserList();
                    ((Users)getComponent("Users")).setUserList(userList);
                    logger.info("Reloaded the user list from the database");

                    exps = new ExperimentListDatabaseRetriever(ds).getExperimentList();
                    Thread.sleep(1);

                    logger.info("Got [{}] experiments listed in the database, scheduling retrieval", exps.size());
                    xmlBuffer.append("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><experiments total=\"").append(exps.size()).append("\">");

                    ((JobsController)getComponent("JobsController")).setJobListener(this);

                    if (exps.size() > 0) {
                        if (exps.size() <= numThreadsForRetrieval) {
                            numThreadsForRetrieval = 1;
                        }
                        // split list into several pieces
                        expsPerThread = (int) Math.ceil(((double)exps.size()) / ((double)numThreadsForRetrieval));
                        for ( int i = 0; i < numThreadsForRetrieval; ++i ) {
                            ((JobsController)getComponent("JobsController")).executeJobWithParam("retrieve-xml", "index", String.valueOf(i));
                            Thread.sleep(1);
                        }

                        while ( numThreadsCompleted < numThreadsForRetrieval ) {
                            Thread.sleep(1000);
                        }

                        ((JobsController)getComponent("JobsController")).setJobListener(null);
                        xmlBuffer.append("</experiments>");

                        String xmlString = xmlBuffer.toString().replaceAll("[^\\p{Print}]", " ");
                        if (logger.isDebugEnabled()) {
                            StringTools.stringToFile(xmlString, new File(System.getProperty("java.io.tmpdir"), "raw-experiments.xml"));
                        }
                        ((Experiments)getComponent("Experiments")).reload(xmlString);
                        logger.info("Reload of experiment data completed");
                        xmlBuffer = null;
                    } else {
                        logger.warn("No experiments found, reload aborted");
                    }
                } else {
                    logger.warn("No data sources available, reload aborted");
                }
            }
        } catch (Exception x) {
            throw new RuntimeException(x);
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
            jdm.put("ds", ds);
            jdm.put("exps", exps.subList(index * expsPerThread, Math.min(((index + 1) * expsPerThread), exps.size())));
        }
    }

    public void jobExecutionVetoed( JobExecutionContext jec )
    {
        if (jec.getJobDetail().getName().equals("retrieve-xml")) {
            try {
                interrupt();
            } catch ( Exception x ) {
                logger.error("Caught an exception:", x);
            }
        }
    }

    public void jobWasExecuted( JobExecutionContext jec, JobExecutionException jobException )
    {
        if (jec.getJobDetail().getName().equals("retrieve-xml")) {
            JobDataMap jdm = jec.getMergedJobDataMap();
            jdm.remove("xmlObject");
            jdm.remove("ds");
            jdm.remove("exps");

            incrementCompletedThreadsCounter();
        }
    }

    private synchronized void incrementCompletedThreadsCounter()
    {
        numThreadsCompleted++;
    }
}
