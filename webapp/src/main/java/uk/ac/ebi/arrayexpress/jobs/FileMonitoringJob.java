package uk.ac.ebi.arrayexpress.jobs;

import org.quartz.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

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

public class FileMonitoringJob implements InterruptableJob, StatefulJob
{
    // logging facitlity
    private final Logger logger = LoggerFactory.getLogger(getClass());
    // worker thread object
    private Thread myThread;

    public void execute( JobExecutionContext jec ) throws JobExecutionException
    {
        this.myThread = Thread.currentThread();
    }

    public void interrupt() throws UnableToInterruptJobException
    {
        logger.debug("Attempting to interrupt job");
        if (null != this.myThread)
            this.myThread.interrupt();
    }
}
