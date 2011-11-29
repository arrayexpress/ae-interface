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

import org.quartz.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.utils.db.ExperimentXmlDatabaseRetriever;
import uk.ac.ebi.arrayexpress.utils.db.IConnectionSource;

import java.util.List;

public class RetrieveExperimentsXmlJob implements InterruptableJob
{
    // logging facitlity
    private final Logger logger = LoggerFactory.getLogger(getClass());
    // worker thread object
    private Thread myThread;

    public void execute( JobExecutionContext jec ) throws JobExecutionException
    {
        myThread = Thread.currentThread();
        try {
            JobDataMap jdm = jec.getMergedJobDataMap();
            IConnectionSource connSource = (IConnectionSource)jdm.get("connectionSource");
            List exps = (List) jdm.get("exps");
            StringBuffer xmlBuffer = (StringBuffer) jdm.get("xmlBuffer");
            xmlBuffer.append(
                    new ExperimentXmlDatabaseRetriever(
                            connSource,
                            exps).getExperimentXml()
            );
        } catch ( InterruptedException x ) {
            logger.debug("Job [{}] was interrupted", jec.getJobDetail().getKey());
        } catch ( Error x ) {
            logger.error("[SEVERE] Runtime error while executing job [" + jec.getJobDetail().getKey() + "]:", x);
            Application.getInstance().sendExceptionReport("[SEVERE] Runtime error while executing job [" + jec.getJobDetail().getKey() + "]", x);
            throw new JobExecutionException(x);
        }
        myThread = null;
    }

    public void interrupt() throws UnableToInterruptJobException
    {
        logger.debug("Attempting to interrupt job");
        if (null != myThread)
            myThread.interrupt();
    }
}
