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
import java.util.Collections;
import java.util.Comparator;
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
    private static final String OPTION_SORT_BY = "sortby";
    private static final String OPTION_SORT_ORDER = "sortorder";

    private enum ColDataType { STRING, INTEGER, DECIMAL }

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
        parser.accepts(OPTION_SORT_BY).withRequiredArg().ofType(Integer.class);
        parser.accepts(OPTION_SORT_ORDER).withRequiredArg().ofType(String.class);

        this.options = parser.parse(null != options ? options.split("[ ;]") : new String[]{""});
    }

    public FlatFileXMLReader( final char columnDelimiter, final char columnQuoteChar )
    {
        this.columnDelimiter = columnDelimiter;
        this.columnQuoteChar = columnQuoteChar;
    }
    
    public void parse( InputSource input ) throws IOException, SAXException
    {
        int headerRows = getIntOptionValue(OPTION_HEADER_ROWS, 0);
        int page = getIntOptionValue(OPTION_PAGE, 0);
        int pageSize = getIntOptionValue(OPTION_PAGE_SIZE, -1);
        Integer sortBy = getIntOptionValue(OPTION_SORT_BY, null);
        String sortOrder = getStringOptionValue(OPTION_SORT_ORDER, "a");

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

        // verify that sort by column is with in range of columns
        // if not then sort will not be performed
        // else - switch from 1-based to 0-based index
        if (null != sortBy && (sortBy < 1 || sortBy > cols)) {
            sortBy = null;
        } else {
            sortBy = sortBy - 1;
        }

        // 1. removes all dodgy rows (that have less columns than the first one)
        // 2. determines if column to be sorted is numeric
        ColDataType sortColDataType = ColDataType.INTEGER;
        int colTypeSkipRows = headerRows;
        for (Iterator<String[]> iterator = ff.iterator(); iterator.hasNext();) {
            String[] row = iterator.next();
            if (row.length != cols || isRowBlank(row)) {
                iterator.remove();
            } else {
                if (null != sortBy && 0 == colTypeSkipRows && ColDataType.STRING != sortColDataType) {
                    ColDataType dataType = getColDataType(row[sortBy]);

                    if (ColDataType.INTEGER == sortColDataType && ColDataType.INTEGER != dataType) {
                        sortColDataType = dataType;
                    }
                }
                if (colTypeSkipRows > 0) {
                    colTypeSkipRows--;
                }
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

        for (Iterator<String[]> iterator = ff.iterator(); iterator.hasNext() && headerRows > 0; headerRows--) {
            String[] row = iterator.next();
            outputRow(ch, "header", null, row);
            iterator.remove();
        }

        if (null != sortBy) {
            Collections.sort(ff, new SortColumnComparator(sortBy, sortOrder, sortColDataType));
        }

        int rowSeq = 1;
        for (String[] row : ff) {
            if (rowSeq > (pageSize * (page - 1)) && rowSeq <= (pageSize * page)) {
                outputRow(ch, "row", String.valueOf(rowSeq), row);
            }
            ++rowSeq;
        }

        ch.endElement(EMPTY_NAMESPACE, "table", "table");
        ch.endDocument();
    }

    private void outputRow( ContentHandler ch, String rowElement, String seqValue, String[] rowData ) throws SAXException
    {
        AttributesImpl rowAttrs = new AttributesImpl();
        if (null !=seqValue) {
            rowAttrs.addAttribute(EMPTY_NAMESPACE, "seq", "seq", CDATA_TYPE, seqValue);
        }
        rowAttrs.addAttribute(EMPTY_NAMESPACE, "cols", "cols", CDATA_TYPE, String.valueOf(rowData.length));
        ch.startElement(EMPTY_NAMESPACE, rowElement, rowElement, rowAttrs);

        for (String col : rowData) {
            ch.startElement(EMPTY_NAMESPACE, "col", "col", EMPTY_ATTR);
            ch.characters(col.toCharArray(), 0, col.length());
            ch.endElement(EMPTY_NAMESPACE, "col", "col");
        }
        ch.endElement(EMPTY_NAMESPACE, rowElement, rowElement);
    }

    private Integer getIntOptionValue( String option, Integer defaultValue )
    {
        if (null != options && options.has(option)) {
            return (Integer)this.options.valueOf(option);
        } else {
            return defaultValue;
        }
    }

    private String getStringOptionValue( String option, String defaultValue )
    {
        if (null != options && options.has(option)) {
            return (String)this.options.valueOf(option);
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

    private ColDataType getColDataType( String string )
    {
        if (null != string) {
            if (string.matches("^\\s*\\d+\\s*$")) {
                return ColDataType.INTEGER;
            } else if (string.matches("^\\s*\\d*[.]\\d+\\s*$")) {
                return ColDataType.DECIMAL;
            }
        }
        return ColDataType.STRING;
    }

    private class SortColumnComparator implements Comparator<String[]>
    {
        private int sortBy;
        private String sortOrder;
        ColDataType sortColDataType;

        public SortColumnComparator( int sortBy, String sortOrder, ColDataType sortColDataType )
        {
            this.sortBy = sortBy;
            this.sortOrder = sortOrder;
            this.sortColDataType = sortColDataType;
        }

        @Override
        public int compare(String[] o1, String[] o2) {
            int result;
            switch (sortColDataType) {
                case INTEGER:
                    long int1 = Long.valueOf(o1[sortBy]);
                    long int2 = Long.valueOf(o2[sortBy]);

                    result = Long.compare(int1, int2);
                    break;
                case DECIMAL:
                    double dec1 = Double.valueOf(o1[sortBy]);
                    double dec2 = Double.valueOf(o2[sortBy]);

                    result = Double.compare(dec1, dec2);
                    break;
                case STRING:
                    result = o1[sortBy].compareToIgnoreCase(o2[sortBy]);
                    break;
                default:
                    throw new IllegalArgumentException("Sort column data type is not defined");
            }
            return ("a".equalsIgnoreCase(sortOrder)) ? result : -result;
        }
    }
}
