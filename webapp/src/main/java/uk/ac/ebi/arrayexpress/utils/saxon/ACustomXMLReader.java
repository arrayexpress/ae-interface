package uk.ac.ebi.arrayexpress.utils.saxon;

/*
 * Copyright 2009-2011 European Molecular Biology Laboratory
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

import org.xml.sax.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public abstract class ACustomXMLReader implements XMLReader
{
    private Map featureMap = new HashMap();
    private Map propertyMap = new HashMap();
    private EntityResolver entityResolver;
    private DTDHandler dtdHandler;
    private ContentHandler contentHandler;
    private ErrorHandler errorHandler;

    /**
     * The only abstract method in this class. Derived classes can parse
     * any source of data and emit SAX2 events to the ContentHandler.
     */
    public abstract void parse(InputSource input) throws IOException,
            SAXException;

    public boolean getFeature(String name) throws SAXNotRecognizedException, SAXNotSupportedException
    {
        Boolean featureValue = (Boolean) this.featureMap.get(name);
        return (featureValue == null) ? false
                : featureValue.booleanValue();
    }

    public void setFeature(String name, boolean value) throws SAXNotRecognizedException, SAXNotSupportedException
    {
        this.featureMap.put(name, new Boolean(value));
    }

    public Object getProperty(String name) throws SAXNotRecognizedException, SAXNotSupportedException
    {
        return this.propertyMap.get(name);
    }

    public void setProperty(String name, Object value) throws SAXNotRecognizedException, SAXNotSupportedException
    {
        this.propertyMap.put(name, value);
    }

    public void setEntityResolver(EntityResolver entityResolver)
    {
        this.entityResolver = entityResolver;
    }

    public EntityResolver getEntityResolver()
    {
        return this.entityResolver;
    }

    public void setDTDHandler(DTDHandler dtdHandler)
    {
        this.dtdHandler = dtdHandler;
    }

    public DTDHandler getDTDHandler()
    {
        return this.dtdHandler;
    }

    public void setContentHandler(ContentHandler contentHandler)
    {
        this.contentHandler = contentHandler;
    }

    public ContentHandler getContentHandler()
    {
        return this.contentHandler;
    }

    public void setErrorHandler(ErrorHandler errorHandler)
    {
        this.errorHandler = errorHandler;
    }

    public ErrorHandler getErrorHandler()
    {
        return this.errorHandler;
    }

    public void parse(String systemId) throws IOException, SAXException
    {
        parse(new InputSource(systemId));
    }
}