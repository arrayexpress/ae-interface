/*
 * Copyright 2009-2015 European Molecular Biology Laboratory
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

package uk.ac.ebi.arrayexpress.utils.saxon;

import com.google.common.hash.Hashing;
import com.google.common.io.Files;
import net.sf.saxon.om.NodeInfo;
import uk.ac.ebi.arrayexpress.app.Application;
import uk.ac.ebi.arrayexpress.components.SaxonEngine;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;

public class StoredDocument implements Document {

    private final static Charset CHARSET = Charset.forName(SaxonEngine.XML_STRING_ENCODING);

    private final NodeInfo rootNode;
    private final String hash;

    public StoredDocument(File storageFile, String rootElement) throws IOException, SaxonException {
        String xml = null;
        if (null != storageFile && storageFile.canRead()) {
            xml = load(storageFile);
        }
        if (null == xml) {
            xml = "<?xml version=\"1.0\" encoding=\"" + SaxonEngine.XML_STRING_ENCODING +"\"?><" + rootElement + "/>";
            if (null != storageFile) {
                save(xml, storageFile);
            }
        }
        rootNode = build(xml);
        hash = calculateHash(xml);
    }

    public StoredDocument(String xml, File storageFile) throws IOException, SaxonException {
        rootNode = build(xml);
        hash = calculateHash(xml);
        if (null != storageFile) {
            save(xml, storageFile);
        }
    }

    public StoredDocument(NodeInfo rootNode, File storageFile) throws IOException, SaxonException {
        this.rootNode = rootNode;
        String xml = serialize(rootNode);
        hash = calculateHash(xml);
        if (null != storageFile) {
            save(xml, storageFile);
        }
    }

    @Override
    public NodeInfo getRootNode() {
        return rootNode;
    }

    @Override
    public String getHash() {
        return hash;
    }

    private String load(File file) throws IOException {
        return Files.toString(file, CHARSET);
    }

    private void save(String xml, File file) throws IOException {
        Files.write(xml, file, CHARSET);
    }

    private NodeInfo build(String xml) throws SaxonException {
        return ((SaxonEngine)Application.getAppComponent("SaxonEngine")).buildDocument(xml);
    }

    private String serialize(NodeInfo rootNode) throws SaxonException {
        return ((SaxonEngine)Application.getAppComponent("SaxonEngine")).serializeDocument(rootNode);
    }

    private String calculateHash(String xml) {
        return Hashing.md5().hashString(xml, CHARSET).toString();
    }
}
