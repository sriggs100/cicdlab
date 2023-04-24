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

package org.dissertation.termsimul.utils;

import lombok.Getter;
import org.apache.commons.codec.binary.Hex;
import org.dissertation.iso8583.IsoMessage;
import org.dissertation.iso8583.IsoMsgDefinition;
import org.dissertation.iso8583.IsoParser;
import org.dissertation.isomsgs.AuthRequestMsgDef;
import org.dissertation.isomsgs.AuthResponseMsgDef;

import java.math.BigDecimal;
import java.util.HexFormat;
import java.util.LinkedList;

public class IsoUtils
{

    public static IsoMessage createAuthRequest(String[] csvTransaction)
    {
        var isoMessage = new IsoMessage( new AuthRequestMsgDef() );

        isoMessage.setMessageType( "1100" );
        isoMessage.setElement(  2, getRandomPAN( Short.parseShort(csvTransaction[CSVID.CARD_SCHEME.val] ), Short.parseShort(csvTransaction[CSVID.FUNCTION_CODE.val]) ) );
        isoMessage.setElement(  3, csvTransaction[CSVID.PROC_CODE.val] );
        isoMessage.setElement(  4, IsoUtils.formatAmount( new BigDecimal(csvTransaction[CSVID.AMOUNT.val]), 2) );
        isoMessage.setElement( 11, csvTransaction[CSVID.STAN.val] );
        isoMessage.setElement( 12, csvTransaction[CSVID.TRANSACTION_DATE_TIME.val] );
        isoMessage.setElement( 22, csvTransaction[CSVID.POINT_OF_SERVICE_DATA_CODE.val] );
        isoMessage.setElement( 23, String.format( "%03d", Integer.parseInt(csvTransaction[CSVID.PAN_SEQUENCE_NUMBER.val]) ) );
        isoMessage.setElement( 24, String.format( "%03d", Integer.parseInt(csvTransaction[CSVID.FUNCTION_CODE.val])) );
        isoMessage.setElement( 26, String.format( "%04d", Integer.parseInt(csvTransaction[CSVID.MERCHANT_CATEGORY_CODE.val])) );
        isoMessage.setElement( 41, csvTransaction[CSVID.TERMID.val] );
        isoMessage.setElement( 42, csvTransaction[CSVID.MERCHID.val] );
        isoMessage.setElement( 43, csvTransaction[CSVID.CARD_ACCEPTOR_NAME_AND_LOCATION.val] );

        isoMessage.setElement( 49, String.format( "%03d", Integer.parseInt(csvTransaction[CSVID.TRANSACTION_CURRENCY_CODE.val])) );

        isoMessage.setElement( 93, getRandomDigits( 8 ) );

        // Generate a random content for EMV tag 9F36 Application Transaction Counter and add it to ISO element 55 (Chip Data)
        String tag9F36 = String.format( "9F3602%s", HexFormat.of().formatHex( getRandomDigits( 2 ) ) );
        isoMessage.setElement( 48, tag9F36 + csvTransaction[CSVID.ADDITIONAL_DATA.val] );

        String chipData = csvTransaction[CSVID.CHIP_DATA.val];
        int tagIdx = chipData.indexOf("9F3602");
        String modifiedChipData = chipData.substring( 0,tagIdx+6 ) + HexFormat.of().formatHex( getRandomDigits( 2 ) ) + chipData.substring( tagIdx+6+4 );

        isoMessage.setElement( 55, HexFormat.of().parseHex(modifiedChipData) );

        return isoMessage;
    }

    private static byte[] getRandomDigits(int len)
    {
        byte val[] = new byte[len];

        fillWithRandomDigits( val, (short)0, (short)len );

        return val;
    }

    private static byte[] getRandomPAN( Short cardScheme, Short functionCode )
    {
        switch( cardScheme )
        {
            case 0 -> { return generateRandomVisaPAN(); }
            case 1 -> { return generateRandomMasterCardPAN( functionCode ); }
        }

        throw new IllegalArgumentException( String.format("Card Scheme: %d", cardScheme) );
    }

    private static byte[] generateRandomMasterCardPAN( Short functionCode )
    {
        if( functionCode == 200 )
        {
            // MasterCard Maestro is usually a 19 digits PAN
            var pan = new byte[19];
            pan[0] = '5';

            fillWithRandomDigits( pan, (short)1, (short)pan.length );

            return pan;
        }

        var pan = new byte[16];
        pan[0] = '5';

        fillWithRandomDigits( pan, (short)1, (short)pan.length );

        return pan;

    }

    private static byte[] generateRandomVisaPAN()
    {
        var pan = new byte[16];
        pan[0] = '4';

        fillWithRandomDigits( pan, (short)1, (short)pan.length );

        return pan;
    }

    private static void fillWithRandomDigits(byte[] buff, short offset, short totalLen)
    {
        for( short idx = offset; idx < totalLen; idx++ )
            buff[idx] = (byte)(0x30 + (int)(Math.random() * 10));
    }

    public static String formatAmount(BigDecimal amount, int decimals)
    {
        int normalizedAmt = amount.multiply( BigDecimal.valueOf( Math.pow(10,decimals))).intValue();

        return String.format( "%012d", normalizedAmt );
    }

    public enum CSVID {

        // action_code, additional_data, amount, application_transaction_counter, authorisation_code, card_acceptor_name_and_location, card_scheme, chip_data, function_code, merchant_category_code, merchant_id, msg_type, pan_sequence_number, point_of_service_data_code, proc_code, reason_code, stan, terminal_id, transaction_currency_code, transaction_date_time, transaction_emv_data_id

        ACTIONCODE(0),

        ADDITIONAL_DATA(1),
        AMOUNT(2),
        AUTHCODE(4),

        CARD_ACCEPTOR_NAME_AND_LOCATION(5),
        CARD_SCHEME(6),

        CHIP_DATA(7),

        FUNCTION_CODE(8),

        MERCHANT_CATEGORY_CODE(9),

        MERCHID(10),
        MSGTYPE(11),

        PAN_SEQUENCE_NUMBER(12),

        POINT_OF_SERVICE_DATA_CODE(13),

        PROC_CODE(14),
        STAN(16),
        TERMID(17),

        TRANSACTION_CURRENCY_CODE(18),

        TRANSACTION_DATE_TIME(19)
        ;

        CSVID(int val) {
            this.val = val;
        }
        @Getter
        private int val;
    }

    @Getter
    private static IsoParser isoParser = new IsoParser(new LinkedList<IsoMsgDefinition>() {{ add(new AuthRequestMsgDef()); add(new AuthResponseMsgDef()); }} );
}
