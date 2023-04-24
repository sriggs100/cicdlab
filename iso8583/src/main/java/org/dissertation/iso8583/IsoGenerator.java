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

import java.io.ByteArrayOutputStream;
import java.util.HexFormat;
import java.util.TreeSet;

public class IsoGenerator {

    public byte[] generateIsoMsg(IsoMessage isoMessage)
    {
        ByteArrayOutputStream outMsgStream = new ByteArrayOutputStream();

        outMsgStream.writeBytes( isoMessage.getMessageType().asBinary() );

        // Create bitmaps
        byte[] bitmaps = createBitmaps( isoMessage.getBitmaps(), isoMessage );
        outMsgStream.writeBytes( bitmaps );

        for( var el : isoMessage.getBitmaps() )
            if( el != 0 )
                outMsgStream.writeBytes( generateIsoElement( el, isoMessage.getIsoElements().get(el) ) );

        return outMsgStream.toByteArray();
    }

    private byte[] generateIsoElement(Integer elementId, IsoElement element)
    {
        byte[] rawContent = element.getRawContent();

        int totalLen = getTotalLen( rawContent, element.getIsoElementDefinition() );

        byte formattedElement[] = new byte[totalLen];

        int offset = writeFormattedLen( formattedElement, element.getIsoElementDefinition(), rawContent.length );
        writeFormattedContent( formattedElement, offset, element.getIsoElementDefinition(), rawContent );

        return formattedElement;
    }

    private int writeFormattedContent(byte[] formattedElement, int offset, IsoElementDefinition isoElementDefinition, byte[] rawContent)
    {
        int formattedBytes = 0;
        switch( isoElementDefinition.getEncoding() )
        {
            case ASCII -> { formattedBytes = rawContent.length; System.arraycopy( rawContent, 0, formattedElement, offset, formattedBytes ); }
            case BINARY -> { formattedBytes = rawContent.length; System.arraycopy( rawContent, 0, formattedElement, offset, formattedBytes ); } // Raw content is already binary
        }

        return formattedBytes;
    }

    private int writeFormattedLen(byte[] formattedElement, IsoElementDefinition isoElementDefinition, int length)
    {
        int addLen = 0;
        switch( isoElementDefinition.getFormat() )
        {
            case LLVAR -> { addLen = formatLLVarLen( formattedElement, isoElementDefinition, length ); }
            case LLLVAR -> { addLen = formatLLLVarLen( formattedElement, isoElementDefinition, length ); }
        }

        return addLen;
    }

    private int formatLLLVarLen(byte[] formattedElement, IsoElementDefinition isoElementDefinition, int length)
    {
        String formattedLen = String.format( "%03d", length );

        int formattedBytes = 0;
        switch( isoElementDefinition.getEncoding() )
        {
            case ASCII -> { formattedBytes = 3; System.arraycopy( formattedLen.getBytes(), 0, formattedElement, 0, formattedBytes ); }
            case BINARY -> { formattedBytes = 3; System.arraycopy( formattedLen.getBytes(), 0, formattedElement, 0, formattedBytes ); }  // Even so the content is binary, the length is usually decimal
        }

        return formattedBytes;
    }

    private int formatLLVarLen(byte[] formattedElement, IsoElementDefinition isoElementDefinition, int length)
    {
        String formattedLen = String.format( "%02d", length );

        int formattedBytes = 0;
        switch( isoElementDefinition.getEncoding() )
        {
            case ASCII -> { formattedBytes = 2; System.arraycopy( formattedLen.getBytes(), 0, formattedElement, 0, formattedBytes ); }
            case BINARY -> { formattedBytes = 2; System.arraycopy( formattedLen.getBytes(), 0, formattedElement, 0, formattedBytes ); }  // Even so the content is binary, the length is usually decimal
        }

        return formattedBytes;
    }

    private int getTotalLen(byte[] rawContent, IsoElementDefinition isoElementDefinition)
    {
        int addLen = 0;
        switch( isoElementDefinition.getFormat() )
        {
            case LLVAR -> { addLen = 2; }
            case LLLVAR -> { addLen = 3; }
        }

        return addLen + rawContent.length;
    }

    private byte[] createBitmaps(TreeSet<Integer> bitmaps, IsoMessage isoMessage )
    {
        boolean isSecondBitmapPresent = isoMessage.getIsoElements().keySet().stream().max((a,b) -> a.compareTo(b) ).get() > 64 ? true : false;
        int maxBits = isSecondBitmapPresent ? 128 : 64;

        byte rawBitmaps[] = new byte[ maxBits/8 ];
        if( isSecondBitmapPresent )
            rawBitmaps[0] |= 0x80;      // Turn on bit 1

        for( var bit : isoMessage.getIsoElements().keySet() )
        {
            bitmaps.add(bit);
            turnBitOn(rawBitmaps, bit);
        }

        return formatBitmaps( rawBitmaps, isoMessage.getIsoMsgDefinition().getBitmapsEncoding() );
    }

    private void turnBitOn(byte[] rawBitmaps, Integer bit)
    {
        int offset = (bit-1) / 8;
        int bitOffset = (bit-1) % 8;

        byte mask = (byte)(0xFF & ( 0x80 >>> bitOffset ));

        rawBitmaps[offset] |= mask;
    }

    private byte[] formatBitmaps(byte[] rawBitmaps, IsoElementDefinition.ENCODING bitmapEncoding)
    {
        if( bitmapEncoding.equals(IsoElementDefinition.ENCODING.HEX) )
            return HexFormat.of().formatHex( rawBitmaps ).getBytes();

        return rawBitmaps;
    }

    public static TreeSet<Integer> computeBitmapFromContents(IsoMessage isoMessage)
    {
        TreeSet<Integer> bitmaps = new TreeSet<>();

        var isoElements = isoMessage.getIsoElements();

        for( var elementKey : isoElements.keySet() )
            bitmaps.add( elementKey );


        return bitmaps;
    }

}
