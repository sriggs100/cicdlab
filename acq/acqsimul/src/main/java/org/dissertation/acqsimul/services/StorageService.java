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

package org.dissertation.acqsimul.services;

import lombok.extern.slf4j.Slf4j;
import org.dissertation.acqsimul.utils.ByteArrayToPan;
import org.dissertation.acqsimul.utils.PanEncrypt;
import org.dissertation.acqsimul.utils.PanHash;
import org.dissertation.iso8583.IsoMessage;
import org.dissertation.acqsimul_db.services.DbStorageService;
import org.dissertation.transaction.TransactionDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Slf4j
@Service
public class StorageService {

    @Autowired
    DbStorageService dbService;

    public boolean insertRecord(String uniqueId, IsoMessage isoMessage)
    {
        try
        {
            var txn = new TransactionDto();

            // Amount is exponent 2
            txn.setAmount( new BigDecimal( isoMessage.getElement( 4 ).asString() ).divide( BigDecimal.valueOf( 100 ) ) );

            txn.setMsgType( Short.parseShort(isoMessage.getMessageType().asString()) );

            byte[] binaryPan = isoMessage.getElement( 2 ).asBinary();
            char[] pan = new char[binaryPan.length];
            ByteArrayToPan.process( binaryPan, pan );

            txn.setPanHash( PanHash.process( pan ) );

            if( pan[0] == '5' )
                txn.setCardScheme(TransactionDto.CardScheme.MASTERCARD);
            else
                txn.setCardScheme(TransactionDto.CardScheme.VISA);

            txn.setEncryptedPan(PanEncrypt.process(pan));

            if( isoMessage.getBitmaps().contains( 23 ) )
                txn.setPanSequenceNumber( Short.parseShort(isoMessage.getElement( 23 ).asString()) );

            txn.setProcCode( isoMessage.getElement( 3 ).asString() );
            txn.setStan( Integer.parseInt(isoMessage.getElement( 11 ).asString()) );
            txn.setFunctionCode( Short.parseShort(isoMessage.getElement( 24 ).asString()) );

            txn.setTransactionDateTime( isoMessage.getElement( 12 ).asString() );
            txn.setPointOfServiceDataCode( isoMessage.getElement( 22 ).asString() );
            txn.setMerchantCategoryCode( Short.parseShort( isoMessage.getElement( 26 ).asString() ) );
            txn.setTerminalId( isoMessage.getElement( 41 ).asString() );
            txn.setMerchantId( isoMessage.getElement( 42 ).asString() );
            txn.setCardAcceptorNameAndLocation(  isoMessage.getElement( 43 ).asString() );
            txn.setAdditionalData( isoMessage.getElement( 48 ).asString() );
            txn.setTransactionCurrencyCode( isoMessage.getElement( 49 ).asString() );
            txn.setChipData( isoMessage.getElement( 55 ).asString() );

            txn.setTransactionToken( uniqueId );

            String chipData = isoMessage.getElement( 55 ).asString();
            int tagIdx = chipData.indexOf("9F3602");
            txn.setApplicationTransactionCounter( chipData.substring( tagIdx + 6, tagIdx + 6 + 4) );

            // TODO transactionEmvData.setApplicationExpirationDate( );
            // TODO transactionEmvData.setTerminalCapabilities();
            txn.setInterfaceDeviceSerialNumber( isoMessage.getElement( 93 ).asString() );



            return dbService.insertRecord( txn );
        }
        catch( Exception ex )
        {
            log.error( "Fatal error! Exception {} caught inserting record into the database with message {}. The transaction is being discarded.",
                    ex.getClass().getName(), ex.getMessage(), ex );

            return false;
        }
    }

    public boolean updateRecord(IsoMessage isoMessage)
    {
        var merchid = isoMessage.getElement( 42 ).asString();
        var termid = isoMessage.getElement( 41 ).asString();
        var stan = Integer.parseInt( isoMessage.getElement( 11 ).asString() );

        var actionCode = Short.parseShort(isoMessage.getElement( 39 ).asString());

        String authCode = null;
        if( isoMessage.getBitmaps().contains( 38 ) )
            authCode = isoMessage.getElement( 38 ).asString();

        if( dbService.update( actionCode, authCode, merchid, termid, stan ) == 0 )
        {
            log.error( "Transaction not found in database for key: merchid={} / termid={} / stan={}", merchid, termid, stan );

            return false;
        }

        return true;
    }
}
