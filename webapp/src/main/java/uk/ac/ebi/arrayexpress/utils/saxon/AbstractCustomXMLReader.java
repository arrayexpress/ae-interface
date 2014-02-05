package uk.ac.ebi.arrayexpress.utils.saxon;

/*
 * Copyright 2009-2014 European Molecular Biology Laboratory
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

public abstract class AbstractCustomXMLReader implements XMLReader
{
    private Map<String, Boolean> featureMap = new HashMap<String, Boolean>();
    private Map<String, Object> propertyMap = new HashMap<String, Object>();
    private EntityResolver entityResolver;
    private DTDHandler dtdHandler;
    private ContentHandler contentHandler;
    private ErrorHandler errorHandler;

    /**
     * The only abstract method in this class. Derived classes can parse
     * any source of data and emit SAX2 events to the ContentHandler.
     */
    @Override
    public abstract void parse( InputSource input ) throws IOException, SAXException;

    @Override
    public boolean getFeature( String name ) throws SAXNotRecognizedException, SAXNotSupportedException
    {
        Boolean featureValue = this.featureMap.get(name);
        return (featureValue != null) && featureValue;
    }

    @Override
    public void setFeature( String name, boolean value ) throws SAXNotRecognizedException, SAXNotSupportedException
    {
        this.featureMap.put(name, value);
    }

    @Override
    public Object getProperty( String name ) throws SAXNotRecognizedException, SAXNotSupportedException
    {
        return this.propertyMap.get(name);
    }

    @Override
    public void setProperty( String name, Object value ) throws SAXNotRecognizedException, SAXNotSupportedException
    {
        this.propertyMap.put(name, value);
    }

    @Override
    public void setEntityResolver( EntityResolver entityResolver )
    {
        this.entityResolver = entityResolver;
    }

    @Override
    public EntityResolver getEntityResolver()
    {
        return this.entityResolver;
    }

    @Override
    public void setDTDHandler( DTDHandler dtdHandler )
    {
        this.dtdHandler = dtdHandler;
    }

    @Override
    public DTDHandler getDTDHandler()
    {
        return this.dtdHandler;
    }

    @Override
    public void setContentHandler( ContentHandler contentHandler )
    {
        this.contentHandler = contentHandler;
    }

    @Override
    public ContentHandler getContentHandler()
    {
        return this.contentHandler;
    }

    @Override
    public void setErrorHandler( ErrorHandler errorHandler )
    {
        this.errorHandler = errorHandler;
    }

    @Override
    public ErrorHandler getErrorHandler()
    {
        return this.errorHandler;
    }

    @Override
    public void parse( String systemId ) throws IOException, SAXException
    {
        parse(new InputSource(systemId));
    }
}