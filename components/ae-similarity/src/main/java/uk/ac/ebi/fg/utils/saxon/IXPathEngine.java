package uk.ac.ebi.fg.utils.saxon;

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
import net.sf.saxon.trans.XPathException;

import javax.xml.xpath.XPathExpressionException;
import java.io.InputStream;
import java.util.List;

public interface IXPathEngine
{
    DocumentInfo buildDocument( String xml ) throws XPathException;

    DocumentInfo buildDocument( InputStream stream ) throws XPathException;

    List evaluateXPath( DocumentInfo document, String xPath ) throws XPathExpressionException;
}
