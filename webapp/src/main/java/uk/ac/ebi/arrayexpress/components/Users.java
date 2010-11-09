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
import uk.ac.ebi.arrayexpress.utils.persistence.PersistableDocumentContainer;
import uk.ac.ebi.arrayexpress.utils.persistence.TextFilePersistence;
import uk.ac.ebi.arrayexpress.utils.saxon.DocumentUpdater;
import uk.ac.ebi.arrayexpress.utils.saxon.IDocumentSource;
import uk.ac.ebi.microarray.arrayexpress.shared.auth.AuthenticationHelper;

import java.io.File;

public class Users extends ApplicationComponent implements IDocumentSource
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private AuthenticationHelper authHelper;
    private TextFilePersistence<PersistableDocumentContainer> users;
    private SaxonEngine saxon;

    public enum UserSource
    {
        AE1, AE2;

        public String getStylesheetName()
        {
            switch (this) {
                case AE1:   return "preprocess-users-ae1-xml.xsl";
                case AE2:   return "preprocess-users-ae2-xml.xsl";
            }
            return null;
        }
    }

    public Users()
    {
    }

    public void initialize() throws Exception
    {
        saxon = (SaxonEngine) getComponent("SaxonEngine");
        users = new TextFilePersistence<PersistableDocumentContainer>(
                new PersistableDocumentContainer("users")
                , new File(getPreferences().getString("ae.users.persistence-location"))
        );

        authHelper = new AuthenticationHelper();
    }

    public void terminate() throws Exception
    {
    }

    // implementation of IDocumentSource.getDocumentURI()
    public String getDocumentURI()
    {
        return "users.xml";
    }

    // implementation of IDocumentSource.getDocument()
    public synchronized DocumentInfo getDocument() throws Exception
    {
        return this.users.getObject().getDocument();
    }

    // implementation of IDocumentSource.setDocument(DocumentInfo)
    public synchronized void setDocument( DocumentInfo doc ) throws Exception
    {
        if (null != doc) {
            this.users.setObject(new PersistableDocumentContainer("users", doc));
        } else {
            this.logger.error("Experiments NOT updated, NULL document passed");
        }
    }

    public void update( String xmlString, UserSource source ) throws Exception
    {
        DocumentInfo updateDoc = saxon.transform(xmlString, source.getStylesheetName(), null);
        if (null != updateDoc) {
            new DocumentUpdater(this, updateDoc).update();
        }
    }

    public Long getUserID( String username ) throws Exception
    {
        String id = saxon.evaluateXPathSingle(
                        getDocument()
                        , "/users/user[name = \"" + username.replaceAll("\"", "&quot;") + "\"]/id"
                );
        if ("".equals(id)) {
            return null;
        } else {
            return Long.parseLong(id);
        }
    }

    private String getUserPassword( String username ) throws Exception
    {
        return saxon.evaluateXPathSingle(
                getDocument()
                , "/users/user[name = \"" + username.replaceAll("\"", "&quot;") + "\"]/password"
        );
    }

    public String hashLogin( String username, String password, String suffix ) throws Exception
    {
        if ( null != username && null != password && null != suffix
                && null != getUserID(username) ) {
            if ( password.equals(getUserPassword(username)) ) {
                return authHelper.generateHash(username, password, suffix);
            }
        }
        // otherwise
        return "";
    }

    public boolean verifyLogin( String username, String hash, String suffix ) throws Exception
    {
        if ( null != username && null != hash && null != suffix
                && null != getUserID(username) ) {
            return authHelper.verifyHash(hash, username, getUserPassword(username), suffix);
        }
        return false;
    }
}
