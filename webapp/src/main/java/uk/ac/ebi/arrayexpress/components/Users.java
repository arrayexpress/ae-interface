package uk.ac.ebi.arrayexpress.components;

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

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.utils.DocumentTypes;
import uk.ac.ebi.microarray.arrayexpress.shared.auth.AuthenticationHelper;

public class Users extends XMLDocumentComponent
{
     // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private AuthenticationHelper authHelper;


    public Users()
    {
        super("Users");
    }

    public void initialize() throws Exception
    {
        super.initialize();
        authHelper = new AuthenticationHelper();
    }

    public void terminate() throws Exception
    {
         saxon = null;
    }

    public void reload( String xmlString ) throws Exception {

        loadXMLString(DocumentTypes.USERS, xmlString);
    }


    public String hashLoginAE2( String username, String password, String suffix ) throws Exception
    {
        String correctPassword = getPasswordAE2(username);

        if ( null != username && null != suffix && null != password && password.equals(correctPassword)) {
            return authHelper.generateHash(username, password, suffix);
        }
        return "";
    }

    public boolean verifyLoginAE2( String username, String hash, String suffix ) throws Exception
    {
        String password = getPasswordAE2(username);

        if ( null != username && null != hash && null != suffix && null != password ) {
            return authHelper.verifyHash(hash, username, password, suffix);
        }
        return false;
    }

    private String getPasswordAE2( String username ) throws Exception
    {
        return saxon.evaluateXPathSingle(
                documentContainer.getDocument(DocumentTypes.USERS)
                , "/users/user[name = '" + username + "']/password"
            );

    }


    //ToDo: Original method  getUserRecord( String username ) is only used to retrieve a UserId -
    //ToDo: replace usage of getUserRecord with getUserId method
    public Long getUserId( String username ) throws Exception
    {
        String idString = saxon.evaluateXPathSingle(
                documentContainer.getDocument(DocumentTypes.USERS)
                , "/users/user[name = '" + username + "']/id"
        );

        Long id = Long.valueOf(-1l);
        if (id != null) {
            try {
                id = Long.valueOf(idString.trim());
                logger.debug("User ID = " + id);
            } catch (NumberFormatException nfe) {
                logger.error("User ID is not a number: " + nfe.getMessage());
            }
        }

        return id;
    }
}
