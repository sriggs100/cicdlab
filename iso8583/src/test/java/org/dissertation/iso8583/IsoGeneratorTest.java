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
import org.dissertation.isomsgs.AuthRequestMsgDef;
import org.junit.jupiter.api.Test;

import java.util.HexFormat;

import static org.assertj.core.api.Assertions.assertThat;

public class IsoGeneratorTest
{
    private static IsoGenerator isoGenerator = new IsoGenerator();

    @Test
    public void whenReceivingValidElements_thenShouldGenerateIsoMessage() throws InvalidISOMsgException
    {
        var isoMessage = new IsoMessage( new AuthRequestMsgDef() );

        isoMessage.setMessageType( "1100" );
        isoMessage.setElement(  2,"5355464152170001" );
        isoMessage.setElement(  3,"000000" );
        isoMessage.setElement(  4,"000000000410" );
        isoMessage.setElement( 11, "898394" );
        isoMessage.setElement( 12, "220809154758" );
        isoMessage.setElement( 22, "100550J85100" );
        isoMessage.setElement( 23, "001" );
        isoMessage.setElement( 24, "100" );
        isoMessage.setElement( 25, "1503" );
        isoMessage.setElement( 26, "5619" );
        isoMessage.setElement( 37, "534305898384" );
        isoMessage.setElement( 41, "76011061" );
        isoMessage.setElement( 42, "965949256594925" );
        isoMessage.setElement( 43, "INSURANCE LTD\\Main Street\\London\\    E143GJ   UK" );
        isoMessage.setElement( 48, "020510203" );
        isoMessage.setElement( 49, "978" );
        isoMessage.setElement( 55, HexFormat.of().parseHex("820212908407A0000000041010950500000000019A032208019C01005F24032005315F2A0209789F02060000000000019F03060000000000009F090200029F1012F110A04003223000000000000000000000FF9F1A0202339F1E0832383032313836309F26086229F3A0784832AF9F2701809F3303E008089F34031F03029F3501229F360201019F3704DDD0D03C9F530152") );
        isoMessage.setElement( 93, "12345678" );

        assertThat( isoGenerator.generateIsoMsg( isoMessage ) ).containsExactly( TestMsgUtils.rawIsoMsg );
    }
}
