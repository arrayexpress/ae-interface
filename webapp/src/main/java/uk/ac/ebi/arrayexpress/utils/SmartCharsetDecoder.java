package uk.ac.ebi.arrayexpress.utils;

/*
 * Copyright 2009-2011 European Molecular Biology Laboratory
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

import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CoderResult;

public class SmartCharsetDecoder extends CharsetDecoder
{
    int[] buffer;
    int decodeState;

    public SmartCharsetDecoder()
    {
        super(Charset.forName("iso-8859-1"), 1f, 1f);
    }

    protected CoderResult decodeLoop(ByteBuffer in, CharBuffer out)
    {
        if (!flushBuffer(out)) {
            return CoderResult.OVERFLOW;
        }

        while (in.remaining() > 0) {
            // flush out buffer if there is no capacity
            if (0 == out.remaining()) {
                return CoderResult.OVERFLOW;
            }

            int b = in.get() & 0xff;
            boolean shouldJustDecodeThisChar = false;

            switch (decodeState) {
                case 0:
                    if (b >= 0xc2 && b <= 0xdf) {
                        // start of possible 2 byte utf-8 sequence detected
                        buffer = new int[]{b, 0x0};
                        decodeState = 1;
                    } else if (b >= 0xe0 && b <= 0xef) {
                        // start of possible 3 byte utf-8 sequence detected
                        buffer = new int[]{b, 0x0, 0x0};
                        decodeState = 1;
                    } else {
                        shouldJustDecodeThisChar = true;
                    }
                    break;
                case 1:
                    if (null != buffer) {
                        buffer[1] = b;
                        if (2 == buffer.length) {
                            decodeState = 0;
                            char utf8Decoded = StringTools.decodeUTF8(buffer);
                            if (StringTools.ILLEGAL_CHAR_REPRESENATION == utf8Decoded) {
                                if (!flushBuffer(out)) {
                                    return CoderResult.OVERFLOW;
                                }
                            } else {
                                out.put(utf8Decoded);
                                implReset();
                            }
                        } else if (3 == buffer.length) {
                            decodeState = 2;
                        }

                    } else {
                        // in theory we should never reach this state
                        // but just in case... "keep calm and carry on" (c)
                        decodeState = 0;
                        shouldJustDecodeThisChar = true;
                    }
                    break;
                case 2:
                    decodeState = 0;
                    if (null != buffer) {
                        if (3 == buffer.length) {
                            buffer[2] = b;
                            char utf8Decoded = StringTools.decodeUTF8(buffer);
                            if (StringTools.ILLEGAL_CHAR_REPRESENATION == utf8Decoded) {
                                if (!flushBuffer(out)) {
                                    return CoderResult.OVERFLOW;
                                }
                            } else {
                                out.put(utf8Decoded);
                                implReset();
                            }
                        }
                    } else {
                        shouldJustDecodeThisChar = true;
                    }
            }

            if (shouldJustDecodeThisChar) {
                if (!decodeAndOut(out, b)) {
                    return CoderResult.OVERFLOW;
                }
            }
        }
        return CoderResult.UNDERFLOW;
    }

    protected void implReset()
    {
        buffer = null;
        decodeState = 0;
    }

    protected CoderResult implFlush(CharBuffer out)
    {
        if (!flushBuffer(out)) {
            return CoderResult.OVERFLOW;
        }

        implReset();
        return CoderResult.UNDERFLOW;
    }

    private boolean flushBuffer( CharBuffer out )
    {
        if (buffer == null)
            return true;
        for (int i = 0; i < buffer.length; i++)
            if (out.remaining() > 0)
                decodeAndOut(out, buffer[i]);
            else {
                int[] nb = new int[buffer.length - i];
                System.arraycopy(buffer, i, nb, 0, nb.length);
                buffer = nb;
                return false;
            }
        buffer = null;
        return true;
    }

    private boolean decodeAndOut( CharBuffer out, int b )
    {
        if(out.remaining() > 0) {
            Character decoded = StringTools.decodeIso88591Char((char)b);
            if (null != decoded) {
                out.put(decoded);
            }
            return true;
        } else {
            buffer = new int[]{b};
            return false;
        }
    }
}
