package uk.ac.ebi.microarray.arrayexpress.shared.auth;

/*
 * Copyright 2009-2010 Microarray Informatics Group, European Bioinformatics Institute
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

import java.security.MessageDigest;

public class AuthenticationHelper
{
    // embedded encoder class
    private final ModifiedBase64Encoder encoder = new ModifiedBase64Encoder();

    public boolean verifyHash(String hash, String username, String password, String suffix)
    {
        String computedHash = generateHash(username, password, suffix);
        return (null != hash && hash.equals(computedHash));
    }

    public String generateHash(String username, String password, String suffix)
    {
        String hash = null;
        try {
            MessageDigest digest = MessageDigest.getInstance("sha-512");
            byte[] hashBytes = digest.digest(
                    new StringBuilder()
                            .append(username)
                            .append(password)
                            .append(suffix)
                            .toString()
                            .getBytes()
            );
            hash = new String(encoder.encode(hashBytes));
        } catch ( Exception x ) {
            // nothing we do here, unfortunately
        }
        return hash;
    }

    private class ModifiedBase64Encoder
    {
        // Mapping table from 6-bit nibbles to Base64 characters.
        private char[] map1 = new char[64];

        public ModifiedBase64Encoder()
        {
            int i = 0;
            for ( char c = 'A'; c <= 'Z'; c++ ) map1[i++] = c;
            for ( char c = 'a'; c <= 'z'; c++ ) map1[i++] = c;
            for ( char c = '0'; c <= '9'; c++ ) map1[i++] = c;
            map1[i++] = '*';
            map1[i] = '-';
        }

        /**
         * Encodes a byte array into Base64 format.
         * No blanks or line breaks are inserted.
         *
         * @param in an array containing the data bytes to be encoded.
         * @return A character array with the Base64 encoded data.
         */
        public char[] encode( byte[] in )
        {
            return encode(in, in.length);
        }

        /**
         * Encodes a byte array into Base64 format.
         * No blanks or line breaks are inserted.
         *
         * @param in   an array containing the data bytes to be encoded.
         * @param iLen number of bytes to process in <code>in</code>.
         * @return A character array with the Base64 encoded data.
         */
        public char[] encode( byte[] in, int iLen )
        {
            int oDataLen = (iLen * 4 + 2) / 3;       // output length without padding
            int oLen = ((iLen + 2) / 3) * 4;         // output length including padding
            char[] out = new char[oLen];
            int ip = 0;
            int op = 0;
            while ( ip < iLen ) {
                int i0 = in[ip++] & 0xff;
                int i1 = ip < iLen ? in[ip++] & 0xff : 0;
                int i2 = ip < iLen ? in[ip++] & 0xff : 0;
                int o0 = i0 >>> 2;
                int o1 = ((i0 & 3) << 4) | (i1 >>> 4);
                int o2 = ((i1 & 0xf) << 2) | (i2 >>> 6);
                int o3 = i2 & 0x3F;
                out[op++] = map1[o0];
                out[op++] = map1[o1];
                out[op++] = (op < oDataLen) ? map1[o2] : '.';
                out[op++] = (op < oDataLen) ? map1[o3] : '.';
            }
            return out;
        }
    }
}
