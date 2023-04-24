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

package org.dissertation.iso8583;

import java.util.HexFormat;

public class IsoElementVariant {
    public IsoElementVariant(IsoElement isoElement)
    {
        this.isoElement = isoElement;
    }

    private final IsoElement isoElement;

    public String asString()
    {
        switch( isoElement.getIsoElementDefinition().getEncoding() )
        {
            case ASCII -> { return new String( isoElement.getRawContent() ); }
            case BINARY -> { return HexFormat.of().formatHex( isoElement.getRawContent() ); }
        }

        throw new RuntimeException( String.format( "Unimplemented encoding %s", isoElement.getIsoElementDefinition().getEncoding().toString() ) );
    }

    /**
     * Returns the length in characters or bytes (if binary)
     *
     * @return
     */
    public int getLength() {
        return isoElement.getRawContent().length;
    }

    public byte[] asBinary(byte[] byteArray)
    {
        int idx = 0;
        for( var el: isoElement.getRawContent() )
            byteArray[idx++] = el;

        return byteArray;
    }

    public byte[] asBinary()
    {
        return isoElement.getRawContent();
    }
}
