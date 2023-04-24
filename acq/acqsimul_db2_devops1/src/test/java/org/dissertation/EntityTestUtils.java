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


import org.dissertation.acqsimul_db.model.TransactionEmvData;
import org.dissertation.acqsimul_db.model.TransactionLog;

import javax.crypto.BadPaddingException;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import java.math.BigDecimal;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.util.UUID;

public class EntityTestUtils {
    public static TransactionLog getNewTransactionLog() throws NoSuchAlgorithmException, InvalidAlgorithmParameterException, NoSuchPaddingException, IllegalBlockSizeException, BadPaddingException, InvalidKeySpecException, InvalidKeyException {
        TransactionLog entity = new TransactionLog();

        entity.setAmount( BigDecimal.valueOf( 110.90 ) );
        entity.setMsgType( (short)1100 );

        char[] pan = "5632890092099001".toCharArray();
        entity.setPanHash( "4bb649afb628cd0e06869bf686516e0cf9bb65a0" );
        entity.setCardScheme(TransactionLog.CardScheme.MASTERCARD);
        entity.setEncryptedPan("4bb649afb628cd0e06869bf686516e0cf9bb65a0");
        entity.setPanSequenceNumber( (short)3 );
        entity.setProcCode( "000000" );
        entity.setStan( 1000 );
        entity.setFunctionCode( (short)100 );
        entity.setTransactionDateTime( "220714195710" );
        entity.setEncryptedExpiryDate( "4bb649afb628cd0e06869bf686516e0cf9bb65a0" );
        entity.setPointOfServiceDataCode( "03M012887675" );
        entity.setReasonCode( (short)10 );
        entity.setMerchantCategoryCode( (short) 1006);
        entity.setTerminalId( "Term0002" );
        entity.setMerchantId( "Merch1909228237" );
        entity.setCardAcceptorNameAndLocation( "INSURANCE LTD\\Main Street\\London\\    E143GJ   UK" );
        entity.setAdditionalData( "6F1A840E315041592E5359532E4444463031A5088801025F2D02656E6F1A840E315041592E5359532E4444463031A5088801025F2D02656E6F1A840E315041592E5359532E4444463031A5088801025F2D02656E" );
        entity.setTransactionCurrencyCode( "840" );
        entity.setChipData( "820212908407A0000000041010950500000000019A030201229C01005F24032005315F2A0209789F02060000000000019F03060000000000009F090200029F1012F110A04003223000000000000000000000FF9F1A0202339F1E0832383032313836309F26086229F3A0784832AF9F2701809F3303E008089F34031F03029F3501229F360201019F3704DDD0D03C9F530152" );
        entity.setAuthorisationCode( " 12Ab " );
        entity.setActionCode( (short)0 );
        entity.setTransactionToken( UUID.randomUUID().toString() );

        var emvData = new TransactionEmvData();
        emvData.setTransactionLog( entity );
        emvData.setApplicationExpirationDate("220716");
        emvData.setInterfaceDeviceSerialNumber( "12345678" );
        entity.setTransactionEmvData( emvData );

        return entity;
    }

}
