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

import lombok.extern.slf4j.Slf4j;
import org.dissertation.iso8583.exceptions.InvalidISOMsgException;
import org.dissertation.isomsgs.AuthRequestMsgDef;
import org.dissertation.isomsgs.AuthResponseMsgDef;
import org.junit.jupiter.api.Test;

import java.util.HexFormat;
import java.util.LinkedList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@Slf4j
public class IsoParserTest {

    private static IsoParser isoParser = new IsoParser( new LinkedList<IsoMsgDefinition>() {{ add(new AuthRequestMsgDef()); add(new AuthResponseMsgDef()); }} );

    @Test
    public void whenReceivingValidMessage_thenShouldParseAllElements() throws InvalidISOMsgException
    {
        var isoMessage = isoParser.parse( TestMsgUtils.rawIsoMsg );

        log.debug( "Message: {}", isoMessage );

        assertThat( isoMessage.getBitmaps().toArray() ).containsExactly( List.of( 1, 2, 3, 4, 11, 12, 22, 23, 24, 25, 26, 37, 41, 42, 43, 48, 49, 55, 93).toArray() );    // TODO

        assertThat( isoMessage.getMessageType().asString() ).isEqualTo( "1100" );
        assertThat( isoMessage.getElement( 2 ).asString() ).isEqualTo( "5355464152170001" );
        assertThat( isoMessage.getElement( 3 ).asString() ).isEqualTo( "000000" );
        assertThat( isoMessage.getElement( 4 ).asString() ).isEqualTo( "000000000410" );
        assertThat( isoMessage.getElement( 11 ).asString() ).isEqualTo( "898394" );
        assertThat( isoMessage.getElement( 12 ).asString() ).isEqualTo( "220809154758" );
        assertThat( isoMessage.getElement( 22 ).asString() ).isEqualTo( "100550J85100" );
        assertThat( isoMessage.getElement( 23 ).asString() ).isEqualTo( "001" );
        assertThat( isoMessage.getElement( 24 ).asString() ).isEqualTo( "100" );
        assertThat( isoMessage.getElement( 25 ).asString() ).isEqualTo( "1503" );
        assertThat( isoMessage.getElement( 26 ).asString() ).isEqualTo( "5619" );
        assertThat( isoMessage.getElement( 37 ).asString() ).isEqualTo( "534305898384" );
        assertThat( isoMessage.getElement( 41 ).asString() ).isEqualTo( "76011061" );
        assertThat( isoMessage.getElement( 42 ).asString() ).isEqualTo( "965949256594925" );
        assertThat( isoMessage.getElement( 43 ).asString() ).isEqualTo( "INSURANCE LTD\\Main Street\\London\\    E143GJ   UK" );
        assertThat( isoMessage.getElement( 48 ).asString() ).isEqualTo( "020510203" );
        assertThat( isoMessage.getElement( 49 ).asString() ).isEqualTo( "978" );

        byte byteArray[] = new byte[isoMessage.getElement( 55 ).getLength()];
        assertThat( isoMessage.getElement( 55 ).asBinary( byteArray ) ).isEqualTo( HexFormat.of().parseHex("820212908407A0000000041010950500000000019A032208019C01005F24032005315F2A0209789F02060000000000019F03060000000000009F090200029F1012F110A04003223000000000000000000000FF9F1A0202339F1E0832383032313836309F26086229F3A0784832AF9F2701809F3303E008089F34031F03029F3501229F360201019F3704DDD0D03C9F530152") );
        assertThat( isoMessage.getElement( 93 ).asString() ).isEqualTo( "12345678" );
    }
}
