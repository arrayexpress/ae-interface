package uk.ac.ebi.fg.utils.objects;

import uk.ac.ebi.arrayexpress.utils.controller.IJobsController;

public class StaticJobController
{
    static IJobsController jobController;

    public StaticJobController ( )
    {}

    public static void setJobController( IJobsController jobsController )
    {
        jobController = jobsController;
    }

    public static IJobsController getJobController()
    {
        return jobController;
    }
}
