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

import java.io.*;

public class FilteredMageTabDownloadFile implements IDownloadFile
{
    private final File file;

    private final static String IDF_FILE_NAME_PATTERN = "^.+[.]idf[.]txt$";
    private final static String IDF_FILTER_PATTERN = "^(person.+|pubmedid|publication.+)$";
    private final static String SDRF_FILE_NAME_PATTERN = "^.+[.]sdrf[.]txt$";
    private final static String SDRF_FILTER_PATTERN = "^(performer|provider)$";

    public FilteredMageTabDownloadFile( File file )
    {
        if (null == file) {
            throw new IllegalArgumentException("File cannot be null");
        }
        this.file = file;
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
        return false;
    }

    public RandomAccessFile getRandomAccessFile() throws IOException
    {
        throw new IllegalArgumentException("Method not supported");
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


    static class IdfFilter
    {
        private final File file;

        public IdfFilter( File file )
        {
            this.file = file;
        }

        public InputStream getFilteredStream() throws IOException
        {
            return new FileInputStream(file);
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
