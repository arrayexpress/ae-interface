package uk.ac.ebi.arrayexpress.components;

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

import net.sf.saxon.om.DocumentInfo;
import net.sf.saxon.om.NodeInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import uk.ac.ebi.arrayexpress.app.ApplicationComponent;
import uk.ac.ebi.arrayexpress.utils.StringTools;
import uk.ac.ebi.arrayexpress.utils.persistence.FilePersistence;
import uk.ac.ebi.arrayexpress.utils.saxon.DocumentUpdater;
import uk.ac.ebi.arrayexpress.utils.saxon.IDocumentSource;
import uk.ac.ebi.arrayexpress.utils.saxon.PersistableDocumentContainer;
import uk.ac.ebi.microarray.arrayexpress.shared.auth.AuthenticationHelper;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class Users extends ApplicationComponent implements IDocumentSource
{
    // logging machinery
    private final Logger logger = LoggerFactory.getLogger(getClass());

    private AuthenticationHelper authHelper;
    private FilePersistence<PersistableDocumentContainer> document;
    private SaxonEngine saxon;
    private SearchEngine search;

    public final String INDEX_ID = "users";

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
        this.saxon = (SaxonEngine) getComponent("SaxonEngine");
        this.search = (SearchEngine) getComponent("SearchEngine");
        this.document = new FilePersistence<PersistableDocumentContainer>(
                new PersistableDocumentContainer("users")
                , new File(getPreferences().getString("ae.users.persistence-location"))
        );

        updateIndex();
        this.authHelper = new AuthenticationHelper();
        this.saxon.registerDocumentSource(this);
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
        return this.document.getObject().getDocument();
    }

    // implementation of IDocumentSource.setDocument(DocumentInfo)
    public synchronized void setDocument( DocumentInfo doc ) throws Exception
    {
        if (null != doc) {
            this.document.setObject(new PersistableDocumentContainer("users", doc));
            updateIndex();
        } else {
            this.logger.error("User information NOT updated, NULL document passed");
        }
    }

    public void update( String xmlString, UserSource source ) throws Exception
    {
        DocumentInfo updateDoc = this.saxon.transform(xmlString, source.getStylesheetName(), null);
        if (null != updateDoc) {
            new DocumentUpdater(this, updateDoc).update();
        }
    }

    private void updateIndex()
    {
        try {
            this.search.getController().index(INDEX_ID, this.getDocument());
        } catch (Exception x) {
            this.logger.error("Caught an exception:", x);
        }
    }

    public boolean isPrivileged( String username ) throws Exception
    {
        List boolNodes = this.saxon.evaluateXPath(
                        getDocument()
                        , "/users/user[name = \"" + username.replaceAll("\"", "&quot;") + "\"]/is_privileged"
                );

        for (Object node : boolNodes ) {
            if (StringTools.stringToBoolean(((NodeInfo)node).getStringValue())) {
                return true;
            }
        }
        return false;
    }

    public List<String> getUserIDs( String username ) throws Exception
    {
        List idNodes = this.saxon.evaluateXPath(
                        getDocument()
                        , "/users/user[name = \"" + username.replaceAll("\"", "&quot;") + "\"]/id"
                );

        ArrayList<String> ids = new ArrayList<String>(idNodes.size());
        for (Object node : idNodes ) {
            ids.add(((NodeInfo)node).getStringValue());
        }

        return ids;
    }

    private List<String> getUserPasswords( String username ) throws Exception
    {
        List passwordNodes = this.saxon.evaluateXPath(
                getDocument()
                , "/users/user[name = \"" + username.replaceAll("\"", "&quot;") + "\"]/password"
        );

        ArrayList<String> passwords = new ArrayList<String>(passwordNodes.size());
        for (Object node : passwordNodes ) {
            passwords.add(((NodeInfo)node).getStringValue());
        }

        return passwords;

    }

    public String hashLogin( String username, String password, String suffix ) throws Exception
    {
        if ( null != username && null != password && null != suffix ) {
            List<String> userPasswords = getUserPasswords(username);
            for (String userPassword : userPasswords)
                if ( password.equals(userPassword) ) {
                    return this.authHelper.generateHash(username, password, suffix);
                }
        }
        return "";
    }

    public boolean verifyLogin( String username, String hash, String suffix ) throws Exception
    {
        if ( null != username && null != hash && null != suffix ) {
            List<String> userPasswords = getUserPasswords(username);
            for (String userPassword : userPasswords)
                if ( this.authHelper.verifyHash(hash, username, userPassword, suffix) ) {
                    return true;
                }
        }
        return false;
    }
}
