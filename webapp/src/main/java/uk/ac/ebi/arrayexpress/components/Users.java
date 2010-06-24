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

import net.sf.saxon.om.DocumentInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.DocumentTypes;
import uk.ac.ebi.arrayexpress.utils.persistence.PersistableUserList;
import uk.ac.ebi.arrayexpress.utils.persistence.TextFilePersistence;
import uk.ac.ebi.arrayexpress.utils.users.UserList;
import uk.ac.ebi.arrayexpress.utils.users.UserRecord;
import uk.ac.ebi.microarray.arrayexpress.shared.auth.AuthenticationHelper;

import java.io.File;

public class Users extends ApplicationComponent
{
     // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private TextFilePersistence<PersistableUserList> userList;

    private AuthenticationHelper authHelper;

    private SaxonEngine saxon;
    private DocumentContainer documentContainer;


    public Users()
    {
        super("Users");
    }

    public void initialize() throws Exception
    {
        saxon = (SaxonEngine)getComponent("SaxonEngine");
        documentContainer = (DocumentContainer) getComponent("DocumentContainer");

        //ToDO: remove when only XML is used
        userList = new TextFilePersistence<PersistableUserList>(
                new PersistableUserList()
                , new File(getPreferences().getString("ae.users.file.location"))
        );

        authHelper = new AuthenticationHelper();
    }

    public void terminate() throws Exception
    {
         saxon = null;
    }

    public void reload( String xmlString ) throws Exception {
        DocumentInfo users = saxon.transform(xmlString, "users.xsl", null);
        if (users != null) {
            documentContainer.putDocument(DocumentTypes.USERS, users);
        } else {
            this.logger.error("Users NOT updated, NULL document passed");
        }
    }


    public String hashLoginAE2( String username, String password, String suffix ) throws Exception
    {
        //ToDo: implement based on XML Document
        return "";
    }

    public boolean verifyLoginAE2( String username, String hash, String suffix ) throws Exception
    {

        boolean userExists = Boolean.parseBoolean(
                saxon.evaluateXPathSingle(
                        documentContainer.getDocument(DocumentTypes.EXPERIMENTS)
                        , "exists(//user[name = '" + username + "'])"
                ));

        if ( null != username && null != hash && null != suffix
                && userExists ) {

            //ToDo: extract a single user
            //ToDo: rewrite  authHelper.verifyHash(..) method
        }
        return false;
    }

    public UserRecord getUserRecordAE2( String username ) throws Exception
    {
        return ( null != username ) ? userList.getObject().get(username) : null;
    }


    //------------------
    //    Methods to work with UserList generated from AE1
    //------------------
    public void setUserList( UserList userList ) throws Exception
    {
        this.userList.setObject(new PersistableUserList(userList));
    }

    public String hashLogin( String username, String password, String suffix ) throws Exception
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

    public boolean verifyLogin( String username, String hash, String suffix ) throws Exception
    {
        if ( null != username && null != hash && null != suffix
                && userList.getObject().containsKey(username) ) {
            UserRecord user = userList.getObject().get(username);
            return authHelper.verifyHash(hash, username, user.getPassword(), suffix);
        }
        return false;
    }

    public UserRecord getUserRecord( String username ) throws Exception
    {
        return ( null != username ) ? userList.getObject().get(username) : null;
    }
}
