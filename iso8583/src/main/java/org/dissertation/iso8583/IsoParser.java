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

import org.dissertation.iso8583.exceptions.InvalidISOMsgException;

import java.util.*;

public class IsoParser {
    private final List<IsoMsgDefinition> definitions;

    public IsoParser(List<IsoMsgDefinition> definitions)
    {
        this.definitions = definitions;
    }


    public IsoMessage parse(byte[] rawIsoMsg) throws InvalidISOMsgException {
        IsoMsgDefinition currDefintion = null;
        for( var elementDef : definitions )
            if( elementDef.isMsg(rawIsoMsg) )
                currDefintion = elementDef;

        if( currDefintion == null )
            throw new InvalidISOMsgException( String.format( "Message cannot be parsed: %s", HexFormat.of().formatHex(rawIsoMsg) ) );

        int parsingByteIdx = 0;
        Map<Integer, IsoElement> isoElements = new HashMap<Integer, IsoElement>();
        var mtiElement = parseElement( rawIsoMsg, parsingByteIdx, 0, currDefintion.getElementDefinition( 0 ) );
        isoElements.put( 0 /* MTI */, mtiElement );


        TreeSet<Integer> isoBitmaps = parseBitMaps( rawIsoMsg, mtiElement.getEndPos(), currDefintion.getBitmapsEncoding() );

        parsingByteIdx = mtiElement.getEndPos() + calculateBitmapsSize( isoBitmaps, currDefintion.getBitmapsEncoding() );
        for( var bit : isoBitmaps )
            if( bit != 1 )
            {
                var elementDefinition = currDefintion.getElementDefinition( bit );

                if( elementDefinition == null )
                    throw new InvalidISOMsgException( String.format( "Element %d not defined for message type=%s / %s", bit, new String(mtiElement.getRawContent()), currDefintion.getName() ) );

                var currElement = parseElement( rawIsoMsg, parsingByteIdx, bit, elementDefinition );
                isoElements.put( bit, currElement );
                parsingByteIdx = currElement.getEndPos();
            }

        IsoMessage msg = new IsoMessage( currDefintion );
        msg.setBitmaps( isoBitmaps );
        msg.setIsoElements( isoElements );

        return msg;
    }

    private int calculateBitmapsSize(TreeSet<Integer> isoBitmaps, IsoElementDefinition.ENCODING bitmapsEncoding)
    {
        int howManyBitmaps = isoBitmaps.last() > 64 ? 2 : 1;

        if( bitmapsEncoding.equals( IsoElementDefinition.ENCODING.BINARY ) )
            return 8 * howManyBitmaps;
        else
            return 8 * 2 * howManyBitmaps;  // HEX encoding
    }

    private IsoElement parseElement(byte[] rawIsoMsg, Integer parsingByteIdx, Integer elementId, IsoElementDefinition elementDefinition)
    {
        var isoElement = new IsoElement();
        isoElement.setElementId( elementId );
        isoElement.setIsoElementDefinition(elementDefinition);
        isoElement.setStartPos( parsingByteIdx );

        var totalLen = getElementTotalLen( rawIsoMsg, parsingByteIdx, elementDefinition );

        isoElement.setEndPos( parsingByteIdx + totalLen );

        var contentLen = getElementContentLen( rawIsoMsg, parsingByteIdx, elementDefinition );

        isoElement.setRawContent( Arrays.copyOfRange( rawIsoMsg, parsingByteIdx + totalLen - contentLen, parsingByteIdx + totalLen ) );

        return isoElement;
    }

    private int getElementContentLen(byte[] rawIsoMsg, Integer parsingByteIdx, IsoElementDefinition elementDefinition)
    {
        int contentLen = 0;
        switch( elementDefinition.getFormat() )
        {
            case FIXED -> { contentLen = getFixedLen( rawIsoMsg, parsingByteIdx, elementDefinition); }
            case LLVAR -> { contentLen = getLLVARLen( rawIsoMsg, parsingByteIdx, elementDefinition); }
            case LLLVAR -> { contentLen = getLLLVARLen( rawIsoMsg, parsingByteIdx, elementDefinition); }
        }

        return contentLen;
    }

    private int getElementTotalLen(byte[] rawIsoMsg, Integer parsingByteIdx, IsoElementDefinition elementDefinition)
    {
        int totalLen = 0;
        switch( elementDefinition.getFormat() )
        {
            case FIXED -> { totalLen = getFixedLen( rawIsoMsg, parsingByteIdx, elementDefinition); }
            case LLVAR -> { totalLen = getLLVARLen( rawIsoMsg, parsingByteIdx, elementDefinition) + 2 / getDigitsPerByte(elementDefinition.getEncoding()); }
            case LLLVAR -> {
                int sizeLenDigits = 3;
                if( elementDefinition.getEncoding().equals( IsoElementDefinition.ENCODING.BCD ) )
                    sizeLenDigits = 4;  // odd quantities in BCD format contain always a filler.

                totalLen = getLLLVARLen( rawIsoMsg, parsingByteIdx, elementDefinition) + sizeLenDigits / getDigitsPerByte(elementDefinition.getEncoding());
            }
        }

        return totalLen;
    }

    private int getLLLVARLen(byte[] rawIsoMsg, Integer parsingByteIdx, IsoElementDefinition elementDefinition)
    {
        int charsLen = 0;

        switch( elementDefinition.getEncoding() )
        {
            case ASCII -> { charsLen = Integer.parseInt( new String( Arrays.copyOfRange( rawIsoMsg, parsingByteIdx, parsingByteIdx + 3 ))); }
            case BINARY -> { charsLen = Integer.parseInt( new String( Arrays.copyOfRange( rawIsoMsg, parsingByteIdx, parsingByteIdx + 3 ))); }
        }

        return charsLen / getDigitsPerByte( elementDefinition.getEncoding() );
    }

    private int getLLVARLen(byte[] rawIsoMsg, Integer parsingByteIdx, IsoElementDefinition elementDefinition)
    {
        int charsLen = 0;

        switch( elementDefinition.getEncoding() )
        {
            case ASCII -> { charsLen = Integer.parseInt( new String( Arrays.copyOfRange( rawIsoMsg, parsingByteIdx, parsingByteIdx + 2 ))); }
            case BINARY -> { charsLen = Integer.parseInt( new String( Arrays.copyOfRange( rawIsoMsg, parsingByteIdx, parsingByteIdx + 2 ))); }
        }

        return charsLen / getDigitsPerByte( elementDefinition.getEncoding() );
    }

    private int getFixedLen(byte[] rawIsoMsg, Integer parsingByteIdx, IsoElementDefinition elementDefinition)
    {
        return elementDefinition.getLen() / getDigitsPerByte( elementDefinition.getEncoding() );
    }

    private static int getDigitsPerByte(IsoElementDefinition.ENCODING encoding)
    {
        switch( encoding )
        {
            case ASCII -> { return 1; }
            case BCD -> { return 2; }
            case BINARY -> { return 1; }
            case EBCDIC -> { return 1; }
            case HEX -> { return 1; }
        }

        // this should never happen
        throw new RuntimeException( String.format( "Invalid Encoding: %s", encoding ) );
    }

    private TreeSet<Integer> parseBitMaps(byte[] rawIsoMsg, Integer parsingByteIdx, IsoElementDefinition.ENCODING bitmapsFormat)
    {
        boolean isSecondBitmapPresent = (rawIsoMsg[parsingByteIdx] & 0x80) != 0;
        int maxBits = isSecondBitmapPresent ? 128 : 64;

        byte[] rawBitmaps = Arrays.copyOfRange( rawIsoMsg, parsingByteIdx, parsingByteIdx+ maxBits/8 );
        if( bitmapsFormat.equals(IsoElementDefinition.ENCODING.HEX) )
            rawBitmaps =  HexFormat.of().parseHex( new String(Arrays.copyOfRange( rawIsoMsg, parsingByteIdx, (parsingByteIdx+ maxBits/8)*2 )) );


        //BitSet bitset = BitSet.valueOf( Arrays.copyOfRange( rawIsoMsg, parsingByteIdx, parsingByteIdx+ maxBits/8 ));
        var bits = new TreeSet<Integer>();
        for( int bit = 1; bit <= maxBits; bit++ )
        {
            int offset = (bit-1) / 8;
            int bitOffset = (bit-1) % 8;

            byte mask = (byte)(0xFF & ( 0x80 >>> bitOffset ));

            if( (0xFF & (rawBitmaps[offset] & mask)) != 0 )
                bits.add( bit );
        }

        return bits;
    }
}
