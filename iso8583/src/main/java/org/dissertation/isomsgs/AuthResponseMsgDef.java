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

package org.dissertation.isomsgs;

import org.dissertation.iso8583.IsoElementDefinition;
import org.dissertation.iso8583.IsoMsgDefinition;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class AuthResponseMsgDef implements IsoMsgDefinition
{
    @Override
    public String getName()
    {
        return this.getClass().getName();
    }

    @Override
    public boolean isMsg(byte[] rawMsg)
    {
        if( Arrays.compare( Arrays.copyOf( rawMsg, 4), new byte[] { '1', '1', '1', '0' } ) == 0 )
            return true;

        return false;
    }

    @Override
    public IsoElementDefinition getElementDefinition( int id )
    {
        return isoElementDefinitions.get( id );
    }

    private static Map<Integer, IsoElementDefinition> isoElementDefinitions = null;


    @Override
    public IsoElementDefinition.ENCODING getBitmapsEncoding()
    {
        return IsoElementDefinition.ENCODING.BINARY;
    }

    static{
        if( isoElementDefinitions == null )
        {
            isoElementDefinitions = new HashMap<Integer, IsoElementDefinition>()
            {{
                put(  0, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 4 ) );       // MTI

                // Processing Code
                put(  3, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 6 ) );

                // Amount
                put(  4, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 12 ) );

                // STAN
                put( 11, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 6 ) );

                // Transaction date and time
                put( 12, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 12 ) );

                // Point of Service Data Code
                put( 22, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 12 ) );

                // Card Sequence Number
                put( 23, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 3 ) );

                // Function Code
                put( 24, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 3 ) );

                // POS Condition Code
                put( 25, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 4 ) );

                // Card Acceptor Business Code (MCC)
                put( 26, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 4 ) );

                // Retrieval Reference Number
                put( 37, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 12 ) );

                // Authorisation Code
                put( 38, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 6 ) );

                // Action Code
                put( 39, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 3 ) );

                // Terminal ID
                put( 41, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 8 ) );

                // Merchant ID
                put( 42, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 15 ) );

                // Additional Data
                put( 48, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.LLLVAR, 999 ) );

                // Currency Code
                put( 49, new IsoElementDefinition( IsoElementDefinition.ENCODING.ASCII, IsoElementDefinition.FORMAT.FIXED, 3 ) );

                // Chip Data
                put( 55, new IsoElementDefinition( IsoElementDefinition.ENCODING.BINARY, IsoElementDefinition.FORMAT.LLLVAR, 999 ) );

            }};
        }
    }
}
