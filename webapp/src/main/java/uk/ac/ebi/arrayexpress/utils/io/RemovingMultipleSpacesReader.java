package uk.ac.ebi.arrayexpress.utils.io;

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

import java.io.IOException;
import java.io.Reader;

public class RemovingMultipleSpacesReader extends Reader
{
    private Reader in;

    private enum ReaderState {
        NormalCharacterFlow
        , SuppressWhiteSpaceCharacter
    }

    private ReaderState state;

    public RemovingMultipleSpacesReader( Reader in )
    {
        super(in);
        this.in = in;
        this.state = ReaderState.NormalCharacterFlow;
    }

    public int read(char[] cbuf, int off, int len) throws IOException
    {
        synchronized (lock) {
            if (null == cbuf)
                throw new IOException("Null array passed for reading");

            char[] inBuffer = new char[len];
            int charsRead = in.read(inBuffer, 0, len);
            if (-1 != charsRead) {
                int result = 0;
                Character ch;
    
                for (int pos = 0; pos < charsRead; ++pos) {
                    ch = inBuffer[pos];
                    if (0x20 == ch) {
                        if (ReaderState.NormalCharacterFlow == this.state) {
                            this.state = ReaderState.SuppressWhiteSpaceCharacter;
                            cbuf[result + off] = ch;
                            result++;
                        }
                    } else {
                        cbuf[result + off] = ch;
                        result++;
                        if (ReaderState.SuppressWhiteSpaceCharacter == this.state) {
                            this.state = ReaderState.NormalCharacterFlow;
                        }
                    }
                }
                return result;
            } else {
                return -1;
            }
        }
    }

    public void close() throws IOException
    {
        synchronized (lock) {
            if (null != in) {
                in.close();
                in = null;
            }
        }
    }
}
