package uk.ac.ebi.arrayexpress.app;

/*
 * Copyright 2009-2012 European Molecular Biology Laboratory
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
import uk.ac.ebi.arrayexpress.components.JobsController;

@DisallowConcurrentExecution
abstract public class ApplicationJob implements InterruptableJob
{
    // logging facitlity
    private final Logger logger = LoggerFactory.getLogger(getClass());
    // worker thread object
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
        } catch ( InterruptedException x ) {
            this.logger.debug("Job [{}] was interrupted", getMyName());
        } catch ( RuntimeException x ) {
            this.logger.error("[SEVERE] Runtime exception while executing job [" + getMyName() + "]:", x);
            getApplication().sendExceptionReport("[SEVERE] Runtime exception while executing job [" + getMyName() + "]", x);
        } catch ( Error x ) {
            this.logger.error("[SEVERE] Runtime error while executing job [" + getMyName() + "]:", x);
            getApplication().sendExceptionReport("[SEVERE] Runtime error while executing job [" + getMyName() + "]", x);
        } catch ( Exception x ) {
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

    protected Application getApplication()
    {
        return Application.getInstance();
    }

    protected ApplicationPreferences getPreferences()
    {
        return getApplication().getPreferences();
    }

    protected JobsController getController()
    {
        return (JobsController)getComponent("JobsController");
    }

    protected ApplicationComponent getComponent(String name)
    {
        return getApplication().getComponent(name);
    }
}