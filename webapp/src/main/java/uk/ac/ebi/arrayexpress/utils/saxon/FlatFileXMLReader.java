package uk.ac.ebi.arrayexpress.utils.saxon;

/*
 * Copyright 2009-2013 European Molecular Biology Laboratory
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
import joptsimple.OptionParser;
import joptsimple.OptionSet;
import org.apache.commons.lang.StringUtils;
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
import java.util.Iterator;
import java.util.List;

public class FlatFileXMLReader extends AbstractCustomXMLReader
{
    private static final Attributes EMPTY_ATTR = new AttributesImpl();

    private static final String EMPTY_NAMESPACE = "";
    private static final String CDATA_TYPE = "CDATA";

    private static final char DEFAULT_COL_DELIMITER = 0x9;
    private static final char DEFAULT_COL_QUOTE_CHAR = '"';

    private static final String OPTION_HEADER_ROWS = "header";
    private static final String OPTION_PAGE = "page";
    private static final String OPTION_PAGE_SIZE = "pagesize";

    private char columnDelimiter;
    private char columnQuoteChar;

    private OptionSet options = null;

    public FlatFileXMLReader()
    {
        this.columnDelimiter = DEFAULT_COL_DELIMITER;
        this.columnQuoteChar = DEFAULT_COL_QUOTE_CHAR;
    }

    public FlatFileXMLReader( String options )
    {
        this();
        OptionParser parser = new OptionParser();
        parser.accepts(OPTION_HEADER_ROWS).withRequiredArg().ofType(Integer.class);
        parser.accepts(OPTION_PAGE).withRequiredArg().ofType(Integer.class);
        parser.accepts(OPTION_PAGE_SIZE).withRequiredArg().ofType(Integer.class);
        this.options = parser.parse(null != options ? options.split("[ ;]") : new String[]{""});
    }

    public FlatFileXMLReader( final char columnDelimiter, final char columnQuoteChar )
    {
        this.columnDelimiter = columnDelimiter;
        this.columnQuoteChar = columnQuoteChar;
    }
    
    public void parse( InputSource input ) throws IOException, SAXException
    {
        Integer headerRows = getIntOptionValue(OPTION_HEADER_ROWS, 0);
        Integer page = getIntOptionValue(OPTION_PAGE, 0);
        Integer pageSize = getIntOptionValue(OPTION_PAGE_SIZE, -1);

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

        List<String[]> ff = ffReader.readAll();
        int cols = ff.size() > 0 ? ff.get(0).length : 0;

        // removes all dodgy rows (that have less columns than the first one)
        for (Iterator<String[]> iterator = ff.iterator(); iterator.hasNext();) {
            String[] row = iterator.next();
            if (row.length != cols || isRowBlank(row)) {
                iterator.remove();
            }
        }

        int rows = ff.size() > 0 ? ff.size() - headerRows : 0;

        if (-1 == pageSize) {
            page = 1;
            pageSize = rows;
        }

        ch.startDocument();

        AttributesImpl tableAttrs = new AttributesImpl();
        tableAttrs.addAttribute(EMPTY_NAMESPACE, "rows", "rows", CDATA_TYPE, String.valueOf(rows));
        ch.startElement(EMPTY_NAMESPACE, "table", "table", tableAttrs);

        boolean isHeader = (headerRows > 0);
        String rowTag = isHeader ? "header" : "row";

        int rowSeq = 0;

        for (String[] row : ff) {
            if (!isHeader) {
                ++rowSeq;
            }
            if (isHeader || (rowSeq > (pageSize * (page - 1)) && rowSeq <= (pageSize * page))) {
                AttributesImpl rowAttrs = new AttributesImpl();
                if (!isHeader) {
                    rowAttrs.addAttribute(EMPTY_NAMESPACE, "seq", "seq", CDATA_TYPE, String.valueOf(rowSeq));
                }
                rowAttrs.addAttribute(EMPTY_NAMESPACE, "cols", "cols", CDATA_TYPE, String.valueOf(row.length));
                ch.startElement(EMPTY_NAMESPACE, rowTag, rowTag, rowAttrs);

                for (String col : row) {
                    ch.startElement(EMPTY_NAMESPACE, "col", "col", EMPTY_ATTR);
                    ch.characters(col.toCharArray(), 0, col.length());
                    ch.endElement(EMPTY_NAMESPACE, "col", "col");
                }
                ch.endElement(EMPTY_NAMESPACE, rowTag, rowTag);
                if (isHeader) {
                    rowTag = "row";
                    isHeader = false;
                }
            }
        }

        ch.endElement(EMPTY_NAMESPACE, "table", "table");
        ch.endDocument();
    }

    private Integer getIntOptionValue( String option, Integer defaultValue )
    {
        if (null != options && options.has(option)) {
            return (Integer)this.options.valueOf(option);
        } else {
            return defaultValue;
        }
    }

    private boolean isRowBlank( String[] row )
    {
        if (null != row) {
            for (String col : row) {
                if (StringUtils.isNotBlank(col)) {
                    return false;
                }
            }
        }
        return true;
    }
}
