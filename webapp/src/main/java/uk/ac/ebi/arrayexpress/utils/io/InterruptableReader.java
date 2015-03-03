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

package uk.ac.ebi.arrayexpress.utils.io;

import java.io.IOException;
import java.io.Reader;

public class InterruptableReader extends Reader
{
    private final Reader in;

    public InterruptableReader( Reader in )
    {
        super(in);
        this.in = in;
    }

    public int read(char[] cbuf, int off, int len) throws IOException
    {
        synchronized (lock) {
            if (null == cbuf)
                throw new IOException("Null array passed for reading");

            try {
                Thread.sleep(0);
            } catch (InterruptedException x) {
                throw new RuntimeException("Execution interrupted", x);
            }
            return in.read(cbuf, off, len);
        }
    }

    public void close() throws IOException
    {
        synchronized (lock) {
            if (null != in) {
                in.close();
            }
        }
    }
}