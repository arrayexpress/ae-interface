package uk.ac.ebi.arrayexpress.components;

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

import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.persistence.PersistableUserList;
import uk.ac.ebi.arrayexpress.utils.persistence.TextFilePersistence;
import uk.ac.ebi.arrayexpress.utils.users.UserList;
import uk.ac.ebi.arrayexpress.utils.users.UserRecord;
import uk.ac.ebi.microarray.arrayexpress.shared.auth.AuthenticationHelper;

import java.io.File;

public class Users extends ApplicationComponent
{
    private TextFilePersistence<PersistableUserList> userList;
    private AuthenticationHelper authHelper;

    public Users()
    {
        super("Users");
    }

    public void initialize() throws Exception
    {
        userList = new TextFilePersistence<PersistableUserList>(
                new PersistableUserList()
                , new File(getPreferences().getString("ae.users.file.location"))
        );

        authHelper = new AuthenticationHelper();
    }

    public void terminate() throws Exception
    {
    }

    public void setUserList( UserList _userList )
    {
        userList.setObject(new PersistableUserList(_userList));
    }

    public String hashLogin( String username, String password, String suffix )
    {
        if ( null != username && null != password && null != suffix
                && userList.getObject().containsKey(username) ) {
            UserRecord user = userList.getObject().get(username);
            if ( user.getPassword().equals(password) ) {
                return authHelper.generateHash(username, password, suffix);
            }
        }
        // otherwise
        return "";
    }

    public boolean verifyLogin( String username, String hash, String suffix )
    {
        if ( null != username && null != hash && null != suffix
                && userList.getObject().containsKey(username) ) {
            UserRecord user = userList.getObject().get(username);
            return authHelper.verifyHash(hash, username, user.getPassword(), suffix);
        }
        return false;
    }

    public UserRecord getUserRecord( String username )
    {
        return ( null != username ) ? userList.getObject().get(username) : null;
    }
}
