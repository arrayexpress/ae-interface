package uk.ac.ebi.fg.utils;

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

import org.quartz.InterruptableJob;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.quartz.UnableToInterruptJobException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.fg.utils.objects.StaticSimilarityComponent;

abstract public class ApplicationJob implements InterruptableJob
{
    private final Logger logger = LoggerFactory.getLogger(getClass());
    private Thread myThread;
    private String myName;

    private void setMyThread( Thread thread )
    {
        this.myThread = thread;
    }

    private Thread getMyThread()
    {
        return this.myThread;
    }

    private void setMyName( String name )
    {
        this.myName = name;
    }

    private String getMyName()
    {
        return this.myName;
    }

    public void execute( JobExecutionContext jec ) throws JobExecutionException
    {
        setMyThread(Thread.currentThread());
        setMyName(jec.getJobDetail().getKey().getGroup() + "." + jec.getJobDetail().getKey().getName());
        try {
            doExecute(jec);
        } catch (InterruptedException x) {
            this.logger.debug("Job [{}] was interrupted", getMyName());
        } catch (RuntimeException x) {
            this.logger.error("[SEVERE] Runtime exception while executing job [" + getMyName() + "]:", x);
            StaticSimilarityComponent.getComponent().sendExceptionReport("[SEVERE] Runtime exception while executing job [" + getMyName() + "]", x);
        } catch (Error x) {
            this.logger.error("[SEVERE] Runtime error while executing job [" + getMyName() + "]:", x);
            StaticSimilarityComponent.getComponent().sendExceptionReport("[SEVERE] Runtime error while executing job [" + getMyName() + "]", x);
        } catch (Exception x) {
            this.logger.error("Exception while executing job [" + getMyName() + "]:", x);
            throw new JobExecutionException(x);
        }
        setMyThread(null);
    }

    public abstract void doExecute( JobExecutionContext jec ) throws Exception;

    public void interrupt() throws UnableToInterruptJobException
    {
        if (null != getMyThread()) {
            this.logger.debug("Attempting to interrupt job [{}]", getMyName());
            getMyThread().interrupt();
        }
    }
}
