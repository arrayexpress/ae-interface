package uk.ac.ebi.arrayexpress.utils.db;

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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ExperimentListInAtlasDatabaseRetriever extends SqlStatementExecutor
{
    // logging facility
    private final Logger logger = LoggerFactory.getLogger(getClass());
    // sql to get a list of experiments from the atlas database
    private final static String getExperimentListSql =
            "select e.experiment_identifier from atlas a, ae1__experiment__main e\n" +
            "where a.experiment_id_key = e.experiment_id_key group by e.experiment_identifier having count(updn) > 0";

    // experiment list
    private List<String> experimentList;

    public ExperimentListInAtlasDatabaseRetriever( DataSource ds )
    {
        super(ds, getExperimentListSql);
        experimentList = new ArrayList<String>();
    }

    public List<String> getExperimentList()
    {
        if (!execute(false)) {
            logger.error("There was a problem retrieving the list of experiments, check log for errors or exceptions");
        }
        return experimentList;
    }

    protected void setParameters( PreparedStatement stmt ) throws SQLException
    {
    }

    protected void processResultSet( ResultSet resultSet ) throws SQLException
    {
        while ( resultSet.next() ) {
            experimentList.add(resultSet.getString(1));
        }
    }
}

