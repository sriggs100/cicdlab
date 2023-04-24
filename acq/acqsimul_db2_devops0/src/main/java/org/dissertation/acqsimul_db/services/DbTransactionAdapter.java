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

package org.dissertation.acqsimul_db.services;

import lombok.Getter;
import org.dissertation.acqsimul_db.model.TransactionEmvData;
import org.dissertation.acqsimul_db.model.TransactionLog;
import org.dissertation.transaction.TransactionDto;

public class DbTransactionAdapter {
    public DbTransactionAdapter(TransactionDto txn)
    {
        txnLog.setTransactionEmvData( txnEmvData );
        txnEmvData.setTransactionLog(txnLog);

        txnLog.setAmount( txn.getAmount() );

        txnLog.setMsgType( txn.getMsgType() );

        txnLog.setPanHash( txn.getPanHash() );

        if( txn.getCardScheme().equals( TransactionDto.CardScheme.MASTERCARD ) )
            txnLog.setCardScheme(TransactionLog.CardScheme.MASTERCARD);
        else
            txnLog.setCardScheme(TransactionLog.CardScheme.VISA);

        txnLog.setEncryptedPan( txn.getEncryptedPan() );

        txnLog.setPanSequenceNumber( txn.getPanSequenceNumber() );

        txnLog.setProcCode( txn.getProcCode() );
        txnLog.setStan( txn.getStan() );
        txnLog.setFunctionCode( txn.getFunctionCode() );

        txnLog.setTransactionDateTime( txn.getTransactionDateTime() );
        txnLog.setPointOfServiceDataCode( txn.getPointOfServiceDataCode() );
        txnLog.setMerchantCategoryCode( txn.getMerchantCategoryCode() );
        txnLog.setTerminalId( txn.getTerminalId() );
        txnLog.setMerchantId( txn.getMerchantId() );
        txnLog.setCardAcceptorNameAndLocation( txn.getCardAcceptorNameAndLocation() );
        txnLog.setAdditionalData( txn.getAdditionalData() );
        txnLog.setTransactionCurrencyCode( txn.getTransactionCurrencyCode() );
        txnLog.setChipData( txn.getChipData() );

        txnLog.setTransactionToken( txn.getTransactionToken() );
        txnLog.setApplicationTransactionCounter( txn.getApplicationTransactionCounter() );

        txnEmvData.setApplicationTransactionCounter( txn.getApplicationTransactionCounter() );
        // TODO transactionEmvData.setApplicationExpirationDate( );
        // TODO transactionEmvData.setTerminalCapabilities();
        txnEmvData.setInterfaceDeviceSerialNumber( txn.getInterfaceDeviceSerialNumber() );
    }

    @Getter
    private final TransactionLog txnLog = new TransactionLog();

    @Getter
    private final TransactionEmvData txnEmvData = new TransactionEmvData();
}
