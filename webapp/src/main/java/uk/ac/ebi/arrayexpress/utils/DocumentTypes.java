package uk.ac.ebi.arrayexpress.utils;

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

public enum DocumentTypes
{
    EXPERIMENTS("experiments", "ae.experiments.file.location", "<?xml version=\"1.0\"?><experiments total=\"0\"></experiments>", "/experiments/@total", "preprocess-experiments-xml.xsl"),
    FILES("files", "ae.files.persistence.file.location", "<?xml version=\"1.0\"?><files total=\"0\"></files>", "/files/@total", "preprocess-files-xml.xsl"),
    PROTOCOLS("protocols", "ae.protocols.file.location", "<?xml version=\"1.0\"?><protocols total=\"0\"></protocols>", "/protocols/@total", "preprocess-protocols-xml.xsl"),
    ARRAYS("arrays", "ae.arrays.file.location", "<?xml version=\"1.0\"?><arrays total=\"0\"></arrays>", "/arrays/@total", "preprocess-arrays-xml.xsl"),
    USERS("users", "ae.users.file.location", "<?xml version=\"1.0\"?><users total=\"0\"></users>", "/users/@total", "preprocess-users-xml.xsl"),
    OTHER("other", "", "", "", "");

    private final String textName;
    private final String persistenceDocumentLocation;
    private final String emptyDocument;
    private final String countDocXpath;
    private final String xslName;

    DocumentTypes(String textName, String persistenceDocumentLocation, String emptyDocument, String countDocXpath, String xslName)
    {
        this.textName = textName;
        this.persistenceDocumentLocation = persistenceDocumentLocation;
        this.emptyDocument = emptyDocument;
        this.countDocXpath = countDocXpath;
        this.xslName = xslName;
    }

    public String getTextName()
    {
        return textName;
    }

    public String getPersistenceDocumentLocation()
    {
        return persistenceDocumentLocation;
    }

    public String getEmptyDocument() {
        return emptyDocument;
    }

    public String getCountDocXpath() {
        return countDocXpath;
    }

    public String getXslName() {
        return xslName;
    }

    public static DocumentTypes getInstanceByName( String name )
    {
        for (DocumentTypes resourceType : DocumentTypes.values()) {
            if (resourceType.textName.equalsIgnoreCase(name)) return resourceType;
        }
        return OTHER;
    }

}
