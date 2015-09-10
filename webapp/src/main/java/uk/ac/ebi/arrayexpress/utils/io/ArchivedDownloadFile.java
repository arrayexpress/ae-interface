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

import de.schlichtherle.util.zip.ZipEntry;
import de.schlichtherle.util.zip.ZipFile;

import java.io.*;

public final class ArchivedDownloadFile implements IDownloadFile
{
    private final File file;
    private final String entryName;
    private final ZipFile zipFile;
    private final ZipEntry zipEntry;

    public ArchivedDownloadFile( File archiveFile, String entryName ) throws IOException
    {
        if ( null == archiveFile || null == entryName ) {
            throw new IllegalArgumentException("Arguments cannot be null");
        }
        this.file = archiveFile;
        this.entryName = entryName;
        this.zipFile = new ZipFile(archiveFile);
        this.zipEntry = this.zipFile.getEntry(this.entryName);
    }

    private File getFile()
    {
        return this.file;
    }

    private String getEntryName()
    {
        return this.entryName;
    }

    private ZipEntry getZipEntry()
    {
        return this.zipEntry;
    }

    public String getName()
    {
        return getEntryName();
    }

    public String getPath()
    {
        return getFile().getName() + File.separator + getEntryName();
    }

    public long getLength()
    {
        return (null != getZipEntry() ? getZipEntry().getSize() : 0L);
    }

    public long getLastModified()
    {
        return (null != getZipEntry() ? getZipEntry().getTime() : 0L);
    }

    public boolean canDownload()
    {
        return null != getZipEntry();
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
        if (null == getZipEntry())
            throw new FileNotFoundException("Archived file not found");
        return this.zipFile.getInputStream(getZipEntry());
    }

    public void close() throws IOException
    {
        if (null != this.zipFile) {
            zipFile.close();
        }
    }
}