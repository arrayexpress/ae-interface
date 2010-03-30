package uk.ac.ebi.arrayexpress.utils.users;

/*
 * Copyright 2009-2010 Functional Genomics Group, European Bioinformatics Institute
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

public class UserRecord
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private Long     id;
    private String   name;
    private String   password;
    private String   email;
    private boolean  isPrivileged;

    public UserRecord( Long _id, String _name, String _password, String _email, boolean _isPrivileged )
    {
        id = _id;
        name = _name;
        password = _password;
        email = _email;
        isPrivileged = _isPrivileged;
    }

    public Long getId()
    {
        return id;
    }

    public String getName()
    {
        return name;
    }

    public String getPassword()
    {
        return password;
    }

    public String getEmail()
    {
        return email;
    }

    public boolean isPrivileged()
    {
        return isPrivileged;
    }
}
