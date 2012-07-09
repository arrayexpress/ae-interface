package uk.ac.ebi.arrayexpress.utils.saxon;

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

import au.com.bytecode.opencsv.CSVReader;
import org.xml.sax.Attributes;
import org.xml.sax.ContentHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.AttributesImpl;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URL;

public class FlatFileXMLReader extends AbstractCustomXMLReader
{
    private static final Attributes EMPTY_ATTR = new AttributesImpl();

    private static final String EMPTY_NAMESPACE = "";

    private static final char DEFAULT_COL_DELIMITER = 0x9;
    private static final char DEFAULT_COL_QUOTECHAR = '"';

    private char columnDelimiter;
    private char columnQuoteChar;

    private String options;
    
    public FlatFileXMLReader( String options )
    {
        this.options = options;
        this.columnDelimiter = DEFAULT_COL_DELIMITER;
        this.columnQuoteChar = DEFAULT_COL_QUOTECHAR;
    }

    public FlatFileXMLReader( final char columnDelimiter, final char columnQuoteChar )
    {
        this.columnDelimiter = columnDelimiter;
        this.columnQuoteChar = columnQuoteChar;
    }
    
    public void parse( InputSource input ) throws IOException, SAXException
    {
        ContentHandler ch = getContentHandler();
        if (null == ch) {
            return;
        }

        Reader inStream;
        if (input.getCharacterStream() != null) {
            inStream = input.getCharacterStream();
        } else if (input.getByteStream() != null) {
            inStream =  new InputStreamReader(input.getByteStream());
        } else if (input.getSystemId() != null) {
            URL url = new URL(input.getSystemId());
            inStream = new InputStreamReader(url.openStream());
        } else {
            throw new SAXException("Invalid InputSource object");
        }

        CSVReader ffReader = new CSVReader(
                new BufferedReader(inStream)
                , this.columnDelimiter
                , this.columnQuoteChar
        );


        ch.startDocument();

        ch.startElement(EMPTY_NAMESPACE, "table", "table", EMPTY_ATTR);

        String[] row;
        while ((row = ffReader.readNext()) != null) {
            if (row.length > 0) {
                ch.startElement(EMPTY_NAMESPACE, "row", "row", EMPTY_ATTR);
                for (String col : row) {
                    ch.startElement(EMPTY_NAMESPACE, "col", "col", EMPTY_ATTR);
                    ch.characters(col.toCharArray(), 0, col.length());
                    ch.endElement(EMPTY_NAMESPACE, "col", "col");
                }
                ch.endElement(EMPTY_NAMESPACE, "row", "row");
            }
        }

        ch.endElement(EMPTY_NAMESPACE, "table", "table");
        ch.endDocument();
    }
}
