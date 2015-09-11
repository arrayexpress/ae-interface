package uk.ac.ebi.arrayexpress.utils.io;

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

import uk.ac.ebi.arrayexpress.utils.StringTools;

import java.io.*;

public class FilteredMageTabDownloadFile implements IDownloadFile
{
    private final File file;
    private final boolean isMageTabFile;

    private final static String IDF_FILE_NAME_PATTERN = "^.+[.]idf[.]txt$";
    private final static String SDRF_FILE_NAME_PATTERN = "^.+[.]sdrf[.]txt$";
    private final static String SDRF_FILTER_PATTERN = "^(performer|provider)$";

    public FilteredMageTabDownloadFile( File file )
    {
        if (null == file) {
            throw new IllegalArgumentException("File cannot be null");
        }
        this.file = file;
        this.isMageTabFile = getName().matches(IDF_FILE_NAME_PATTERN) || getName().matches(SDRF_FILE_NAME_PATTERN);
    }

    private File getFile()
    {
        return this.file;
    }

    public String getName()
    {
        return getFile().getName();
    }

    public String getPath()
    {
        return getFile().getPath();
    }

    public long getLength()
    {
        return getFile().length();
    }

    public long getLastModified()
    {
        return getFile().lastModified();
    }

    public boolean canDownload()
    {
        return getFile().exists() && getFile().isFile() && getFile().canRead();
    }

    public boolean isRandomAccessSupported()
    {
        return !isMageTabFile;
    }

    public RandomAccessFile getRandomAccessFile() throws IOException
    {
        if (isRandomAccessSupported()) {
            return new RandomAccessFile(getFile(), "r");
        } else {
            throw new IllegalStateException("Unable to provide direct access to MAGE-TAB file [" + getName() + "]");
        }
    }

    public InputStream getInputStream() throws IOException
    {
        if (getName().matches(IDF_FILE_NAME_PATTERN)) {
            return new IdfFilter(getFile()).getFilteredStream();
        } else if (getName().matches(SDRF_FILE_NAME_PATTERN)) {
            return new SdrfFilter(getFile()).getFilteredStream();
        }
        return new FileInputStream(getFile());
    }

    public void close() throws IOException
    {
    }

    private static final char DEFAULT_COL_DELIMITER = 0x9;
    private static final char DEFAULT_COL_QUOTE_CHAR = '"';
    private static final String DEFAILT_CHARSET = "UTF-8";

    static class IdfFilter
    {
        private final File file;

        private final static String IDF_FILTER_PATTERN = "^(person.+|pubmedid|publication.+|comment\\[AEAnonymousReview\\])$";

        public IdfFilter( File file )
        {
            this.file = file;
        }

        public InputStream getFilteredStream() throws IOException
        {
            StringBuilder sb = new StringBuilder();

            try(BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), DEFAILT_CHARSET))) {
                for(String line; (line = br.readLine()) != null; ) {
                    String header = processHeader(line.replaceFirst("^([^\t]*).*$", "$1"));
                    if (!header.matches(IDF_FILTER_PATTERN)) {
                        sb.append(line).append(StringTools.EOL);
                    }
                }
            }

            return new ByteArrayInputStream(sb.toString().getBytes(DEFAILT_CHARSET));
        }

        public static String processHeader(String header) {
            if (header == null) {
                return "";
            }
            else {
                String main = "";
                String type = "";
                String subtype = "";

                // reduce header to only text, excluding types and subtype
                main = header;

                // remove subtype first
                if (header.contains("(")) {
                    // the main part is everything up to ( - there shouldn't be cases of this?
                    main = header.substring(0, header.indexOf('('));
                    // the qualifier is everything after (
                    subtype = "(" + extractSubtype(header) + ")";
                }
                // remove type second
                if (header.contains("[")) {
                    // the main part is everything up to [
                    main = header.substring(0, header.indexOf('['));
                    // the qualifier is everything after [
                    type = "[" + extractType(header) + "]";
                }

                StringBuilder processed = new StringBuilder();

                for (int i = 0; i < main.length(); i++) {
                    char c = main.charAt(i);
                    switch (c) {
                        case ' ':
                        case '\t':
                            continue;
                        default:
                            processed.append(Character.toLowerCase(c));
                    }
                }

                // add any [] (type) or () (subtype) qualifiers
                processed.append(type).append(subtype);

                return processed.toString();
            }
        }

        public static String extractType(String header) {
            return header.contains("[") ? header.substring(header.indexOf("[") + 1, header.lastIndexOf("]")) : "";
        }

        public static String extractSubtype(String header) {
            // remove typing first
            String untypedHeader = (header.contains("[")
                    ? header.replace(header.substring(header.indexOf("[") + 1, header.lastIndexOf("]")), "")
                    : header);
            // now check untypedHeader for parentheses
            return untypedHeader.contains("(") ?
                    untypedHeader.substring(untypedHeader.indexOf("(") + 1, untypedHeader.lastIndexOf(")")) : "";
        }
    }

    static class SdrfFilter
    {
        private final File file;

        public SdrfFilter( File file )
        {
            this.file = file;
        }

        public InputStream getFilteredStream() throws IOException
        {
            return new FileInputStream(file);
        }
    }

}
