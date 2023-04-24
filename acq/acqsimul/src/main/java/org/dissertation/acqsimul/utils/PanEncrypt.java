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

import javax.crypto.*;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import java.lang.reflect.Array;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Arrays;
import java.util.HexFormat;
import java.util.Random;
import java.util.stream.Stream;

/**
 * Encrypts the PAN
 */
public class PanEncrypt
{

    /**
     * Encrypts PAN using a secret key and a random salt
     *
     * @param pan
     * @return  Hex encoded string containing salt (first 16 bytes) + encrypted PAN
     */
    public static String process( char[] pan ) throws NoSuchPaddingException, NoSuchAlgorithmException, IllegalBlockSizeException, BadPaddingException, InvalidKeySpecException, InvalidKeyException, InvalidAlgorithmParameterException {
        /*
         * Even so PAN is a string, due to string immutability we handle
         * it as a char[] in order to avoid hundreds of PAN string instances
         * in memory, so whenever there's a PAN it will be handled as char[]
         * and this char[] will be erased as soon as possible.
         */

        byte[] panByteArray = new byte[pan.length];
        try {
            // Generate a random input vector
            byte[] iv = new byte[16];
            RANDOM.nextBytes(iv);

            IvParameterSpec ivParams = new IvParameterSpec(iv);

            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5PADDING");
            cipher.init(Cipher.ENCRYPT_MODE, secretKeySpec, ivParams);

            byte[] cipherText = cipher.doFinal( PanToByteArray.process(pan, panByteArray) );

            return HexFormat.of().formatHex(iv) + HexFormat.of().formatHex(cipherText);

        }
        finally
        {
            Arrays.fill( panByteArray, (byte)0 );
        }
    }

    // As this is not a production code, and it is only a simulator
    // we will use a hardcoded encryption key.
    // If it were a production code we would probably use a key management service like AWS KMS for encryption
    private static byte[] secretKeyRaw = HexFormat.of().parseHex("2dc1df25ff678201c2ca06fe50b8cf8e");

    private static SecretKeySpec secretKeySpec = new SecretKeySpec( secretKeyRaw,"AES");

    private static final Random RANDOM = new SecureRandom();
}
