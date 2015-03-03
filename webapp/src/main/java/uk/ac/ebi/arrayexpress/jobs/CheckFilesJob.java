package uk.ac.ebi.arrayexpress.jobs;

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

import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationJob;
import uk.ac.ebi.arrayexpress.components.Files;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;
import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.util.HashMap;
import java.util.Map;

public class CheckFilesJob extends ApplicationJob
{
    @SuppressWarnings("unused")
    private final Logger logger = LoggerFactory.getLogger(getClass());

    @Override
    public void doExecute( JobExecutionContext jec ) throws Exception
    {
        Files files = (Files)getComponent("Files");
        SaxonEngine saxon = (SaxonEngine)getComponent("SaxonEngine");

        Map<String, String[]> transformParams = new HashMap<String, String[]>();
        transformParams.put("rescanMessage", new String[] { files.getLastReloadMessage() });

        String report = saxon.transformToString(files.getRootNode(), "check-files-plain.xsl", transformParams);

        getApplication().sendEmail(
                null
                , null
                , "FTP Checker Report"
                , "ArrayExpress FTP Files Checker Report" + StringTools.EOL
                        + StringTools.EOL
                        + "Application [${variable.appname}]" + StringTools.EOL
                        + "Host [${variable.hostname}]" + StringTools.EOL
                        + StringTools.EOL
                        + report
        );
    }
}
