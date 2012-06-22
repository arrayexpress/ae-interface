package uk.ac.ebi.fg.utils;

import org.quartz.JobListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.fg.utils.objects.StaticSimilarityComponent;

abstract public class ApplicationJobListener implements JobListener
{
    private String name;
    private final Logger logger = LoggerFactory.getLogger(getClass());

    public ApplicationJobListener ( String name )
    {
        this.name = name;
    }

    public String getName()
    {
        return name;
    }

    public void jobToBeExecuted(org.quartz.JobExecutionContext jobExecutionContext)
    {}

    public void jobExecutionVetoed(org.quartz.JobExecutionContext jobExecutionContext)
    {}

    public void jobWasExecuted(org.quartz.JobExecutionContext jobExecutionContext, org.quartz.JobExecutionException e)
    {
        try {
            jobExecuted(jobExecutionContext);
        } catch ( InterruptedException x ) {
            logger.debug("Job [{}] was interrupted", getName());
        } catch ( RuntimeException x ) {
            logger.error("[SEVERE] Runtime exception while executing job listener [" + getName() + "]:", x);
            StaticSimilarityComponent.getComponent().sendExceptionReport("[SEVERE] Runtime exception while executing job listener [" + getName() + "]", x);
        } catch ( Error x ) {
            logger.error("[SEVERE] Runtime error while executing job listener [" + getName() + "]:", x);
            StaticSimilarityComponent.getComponent().sendExceptionReport("[SEVERE] Runtime error while executing job listener [" + getName() + "]", x);
        } catch( Exception x ) {
            logger.error("Exception while executing job listener " + getName() + " : ", x);
            StaticSimilarityComponent.getComponent().sendExceptionReport("Exception while executing job listener " + getName() + " : ", x);
        }
    }

    abstract public void jobExecuted(org.quartz.JobExecutionContext jobExecutionContext) throws Exception;
}
