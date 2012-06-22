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

public class UnescapingXMLNumericReferencesReader extends Reader
{
    private Reader in;

    private enum UnescapeState {
        AnyCharExpected
        , NumberSignExpected
        , HexPrefixOrDecDigitExpected
        , DecDigitOrSemicolonExpected
        , HexDigitOrSemicolonExpected
    }

    private char[] lastReadExcess;

    public UnescapingXMLNumericReferencesReader( Reader in )
    {
        super(in);
        this.in = in;
        this.lastReadExcess = null;
    }

    public int read(char[] cbuf, int off, int len) throws IOException
    {
        synchronized (lock) {

            if (null == cbuf)
                throw new IOException("Null array passed for reading");

            // allocate temporary buffer for input stream reading
            char[] inBuffer = new char[len];
            int inSize;
            if (null != lastReadExcess) {

                inSize = Math.min(inBuffer.length, lastReadExcess.length);
                System.arraycopy(lastReadExcess, 0, inBuffer, 0, inSize);

                if (inBuffer.length < lastReadExcess.length) {
                    // not all excess has been copied so we need to save the remainder until next read

                    char[] nb = new char[lastReadExcess.length - inBuffer.length];
                    System.arraycopy(lastReadExcess, 1, nb, 0, nb.length);
                    lastReadExcess = nb;
                } else {
                    lastReadExcess = null;
                    if (inBuffer.length > inSize) {
                        // there is some room in buffer to read from input stream
                        int readSize = in.read(inBuffer, inSize, inBuffer.length - inSize);
                        if (-1 != readSize) {
                            inSize += readSize;
                        }
                    }
                }
            } else {
                inSize = in.read(inBuffer, 0, inBuffer.length);
            }

            if (-1 != inSize) {
                // now, as we've got the stuff, let's try to process it

                int cbufPos = off;
                int ampPos = 0;
                UnescapeState state = UnescapeState.AnyCharExpected;
                StringBuilder number = new StringBuilder();

                for (int pos = 0; pos < inSize; ) {
                    char ch = inBuffer[pos];
                    switch (state) {
                        case AnyCharExpected:
                            if ('&' == ch) {
                                state = UnescapeState.NumberSignExpected;
                                ampPos = pos;
                            } else {
                                cbuf[cbufPos++] = ch;
                            }
                            pos++;
                            break;

                        case NumberSignExpected:
                            if ('#' == ch) {
                                state = UnescapeState.HexPrefixOrDecDigitExpected;
                                number.setLength(0);
                                pos++;
                            } else {
                                state = UnescapeState.AnyCharExpected;
                                cbuf[cbufPos++] = '&';
                                pos = ampPos + 1;
                            }
                            break;

                        case HexPrefixOrDecDigitExpected:
                            if ('x' == ch) {
                                state = UnescapeState.HexDigitOrSemicolonExpected;
                                pos++;
                            } else if (ch >= 0x30 && ch <= 0x39) {
                                state = UnescapeState.DecDigitOrSemicolonExpected;
                                number.append(ch);
                                pos++;
                            } else {
                                state = UnescapeState.AnyCharExpected;
                                cbuf[cbufPos++] = '&';
                                pos = ampPos + 1;
                            }
                            break;

                        case DecDigitOrSemicolonExpected:
                            if (';' == ch) {
                                cbuf[cbufPos++] = (char)((int)Integer.valueOf(number.toString()));
                                state = UnescapeState.AnyCharExpected;
                                pos++;
                            } else if (Character.isDigit(ch)) {
                                number.append(ch);
                                pos++;
                            } else {
                                state = UnescapeState.AnyCharExpected;
                                cbuf[cbufPos++] = '&';
                                pos = ampPos + 1;
                            }
                            break;

                        case HexDigitOrSemicolonExpected:
                            if (';' == ch) {
                                cbuf[cbufPos++] = (char)((int)Integer.valueOf(number.toString(), 16));
                                state = UnescapeState.AnyCharExpected;
                                pos++;
                            } else if (Character.isDigit(ch)
                                    || (ch >= 0x41 && ch <= 0x46)
                                    || (ch >= 0x61 && ch <= 0x66)) {
                                number.append(ch);
                                pos++;
                            } else {
                                state = UnescapeState.AnyCharExpected;
                                cbuf[cbufPos++] = '&';
                                pos = ampPos + 1;
                            }
                            break;
                    }
                }

                if (UnescapeState.AnyCharExpected != state) {
                    // we were in a middle of something, but didn't finish
                    // so we save this part until next time
                    // TODO: BUG! we need to save state as well
                    if (null == lastReadExcess) {
                        lastReadExcess = new char[inSize - ampPos];
                        System.arraycopy(inBuffer, ampPos, lastReadExcess, 0, lastReadExcess.length);
                    } else {
                        // ok, if we ever get here, we're in deep stuff; will throw exception now
                        throw new IOException("Read buffer too small to decode");
                    }
                }

                inSize = cbufPos - off;
            }

        return inSize;
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
