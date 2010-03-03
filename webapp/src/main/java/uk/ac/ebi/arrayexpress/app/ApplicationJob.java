package uk.ac.ebi.arrayexpress.app;

/*
 * Copyright 2009-2010 Microarray Informatics Group, European Bioinformatics Institute
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

abstract public class ApplicationJob implements InterruptableJob, StatefulJob
{
    // logging facitlity
    private final Logger logger = LoggerFactory.getLogger(getClass());
    // worker thread object
    private Thread myThread;

    public void execute( JobExecutionContext jec ) throws JobExecutionException
    {
        myThread = Thread.currentThread();
        try {
            doExecute(jec);
        } catch ( InterruptedException x ) {
            logger.debug("Job [{}] was interrupted", jec.getJobDetail().getFullName());
        } catch ( RuntimeException x ) {
            logger.error("[SEVERE] Runtime exception while executing job [" + jec.getJobDetail().getFullName() + "]:", x);
            Application.getInstance().sendExceptionReport("[SEVERE] Runtime exception while executing job [" + jec.getJobDetail().getFullName() + "]", x);
        } catch ( Error x ) {
            logger.error("[SEVERE] Runtime error while executing job [" + jec.getJobDetail().getFullName() + "]:", x);
            Application.getInstance().sendExceptionReport("[SEVERE] Runtime error while executing job [" + jec.getJobDetail().getFullName() + "]", x);
        } catch ( Exception x ) {
            logger.error("Exception while executing job [" + jec.getJobDetail().getFullName() + "]:", x);
            throw new JobExecutionException(x);
        }
        myThread = null;
    }

    public abstract void doExecute( JobExecutionContext jec ) throws InterruptedException;

    public void interrupt() throws UnableToInterruptJobException
    {
        logger.debug("Attempting to interrupt job");
        if (null != myThread)
            myThread.interrupt();
    }
}