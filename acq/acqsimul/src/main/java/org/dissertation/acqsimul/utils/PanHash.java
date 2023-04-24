/*
 * MIT License
 *
 * Copyright (c) 2022 Sergio Andres Penen
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

package org.dissertation.acqsimul.utils;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.HexFormat;

/**
 * Generates a hash of the PAN
 */
public class PanHash {


    /**
     * Generates a PAN hash
     *
     * @param pan
     * @return  Sha-256 PAn hash
     */
    public static String process( char[] pan ) throws NoSuchAlgorithmException {
        /*
         * Even so PAN is a string, due to string immutability we handle
         * it as a char[] in order to avoid hundreds of PAN string instances
         * in memory, so whenever there's a PAN it will be handled as char[]
         * and this char[] will be erased as soon as possible.
         */
        byte[] bytePasswd = new byte[pan.length];

        try
        {
            bytePasswd = PanToByteArray.process( pan, bytePasswd );

            return HexFormat.of().formatHex( MessageDigest.getInstance( "SHA-256" ).digest(bytePasswd) );
        }
        finally
        {
            Arrays.fill( bytePasswd, (byte)0 );
        }

    }

}
