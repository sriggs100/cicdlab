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

package org.dissertation;


import org.dissertation.transaction.TransactionDto;

import javax.crypto.BadPaddingException;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import java.math.BigDecimal;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.util.UUID;

public class TestUtils {
    public static TransactionDto getNewTransactionDto() throws NoSuchAlgorithmException, InvalidAlgorithmParameterException, NoSuchPaddingException, IllegalBlockSizeException, BadPaddingException, InvalidKeySpecException, InvalidKeyException {
        TransactionDto dto = new TransactionDto();

        dto.setAmount( BigDecimal.valueOf( 110.90 ) );
        dto.setMsgType( (short)1100 );

        char[] pan = "5632890092099001".toCharArray();
        dto.setPanHash( "4bb649afb628cd0e06869bf686516e0cf9bb65a0" );
        dto.setCardScheme(TransactionDto.CardScheme.MASTERCARD);
        dto.setEncryptedPan("4bb649afb628cd0e06869bf686516e0cf9bb65a0");
        dto.setPanSequenceNumber( (short)3 );
        dto.setProcCode( "000000" );
        dto.setStan( 1000 );
        dto.setFunctionCode( (short)100 );
        dto.setTransactionDateTime( "220714195710" );
        dto.setEncryptedExpiryDate( "4bb649afb628cd0e06869bf686516e0cf9bb65a0" );
        dto.setPointOfServiceDataCode( "03M012887675" );
        dto.setReasonCode( (short)10 );
        dto.setMerchantCategoryCode( (short) 1006);
        dto.setTerminalId( "Term0002" );
        dto.setMerchantId( "Merch1909228237" );
        dto.setCardAcceptorNameAndLocation( "INSURANCE LTD\\Main Street\\London\\    E143GJ   UK" );
        dto.setAdditionalData( "6F1A840E315041592E5359532E4444463031A5088801025F2D02656E6F1A840E315041592E5359532E4444463031A5088801025F2D02656E6F1A840E315041592E5359532E4444463031A5088801025F2D02656E" );
        dto.setTransactionCurrencyCode( "840" );
        dto.setChipData( "820212908407A0000000041010950500000000019A030201229C01005F24032005315F2A0209789F02060000000000019F03060000000000009F090200029F1012F110A04003223000000000000000000000FF9F1A0202339F1E0832383032313836309F26086229F3A0784832AF9F2701809F3303E008089F34031F03029F3501229F360201019F3704DDD0D03C9F530152" );
        dto.setAuthorisationCode( " 12Ab " );
        dto.setActionCode( (short)0 );
        dto.setTransactionToken( UUID.randomUUID().toString() );

        return dto;
    }

}
