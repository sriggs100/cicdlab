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

import lombok.extern.slf4j.Slf4j;
import org.dissertation.acqsimul.repo.TransactionLog1Repository;
import org.dissertation.acqsimul.repo.TransactionLogRepository;
import org.dissertation.acqsimul_db.model.*;
import org.dissertation.transaction.TransactionDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class DbStorageService
{
    @Autowired
    TransactionLogRepository repo;

    @Autowired
    TransactionLog1Repository repo1;

    public static String getVersion()
    {
        return "DbStorageService (acqsimul_db1_devops1)";
    }


    public boolean insertRecord( TransactionDto txn )
    {
        log.trace( "insertRecord() for project acqsimul_db1_devops1" );

        // First try to insert to TransactionLog1 and if it fails, try to insert to TransactionLog
        try
        {
            return insertRecord( txn, new TransactionLog1(), new TransactionEmvData1());
        }
        catch( Exception ex )
        {
            log.error( "Error! Exception {} caught inserting record into the database with message {}. Activating Fail Over.",
                    ex.getClass().getName(), ex.getMessage(), ex );
        }


        try
        {
            return insertRecord( txn, new TransactionLog(), new TransactionEmvData() );
        }
        catch( Exception ex )
        {
            log.error( "Fatal error! Exception {} caught inserting record into the database with message {}. The transaction is being discarded.",
                    ex.getClass().getName(), ex.getMessage(), ex );

            return false;
        }

    }

    private boolean insertRecord(TransactionDto txn, TransactionLogSuper pTxnLog, TransactionEmvDataSuper pTxnEmvData )
    {
        log.trace( "insertRecord() (private)" );
        var adapter = new org.dissertation.acqsimul_db.services.DbTransactionAdapter( txn, pTxnLog, pTxnEmvData );

        adapter.getTxnLog().setMerchantCategoryCode( "M" + adapter.getTxnLog().getMerchantCategoryCode() );

        if( pTxnLog instanceof TransactionLog ) {
            log.info( "inserting into TransactionLog" );
            repo.save((TransactionLog) adapter.getTxnLog());
            repo.flush();
        }
        else {
            log.info( "inserting into TransactionLog1" );
            repo1.save((TransactionLog1) adapter.getTxnLog());
            repo1.flush();
        }

        return true;
    }



    public int update(short actionCode, String authCode, String merchid, String termid, int stan)
    {
        log.trace( "update() for project acqsimul_db1_devops1" );


        // First try to update TransactionLog1 and if it fails or if the record is not found, try to update TransactionLog
        try
        {
            int upd = repo1.update( actionCode, authCode, merchid, termid, stan );

            if( upd != 0 )
                return upd;
        }
        catch( Exception ex )
        {
            log.error( "Error! Exception {} caught updating transaction_log1 record with message {}. Activating Fail Over.",
                    ex.getClass().getName(), ex.getMessage(), ex );
        }


        try
        {
            return repo.update( actionCode, authCode, merchid, termid, stan );
        }
        catch( Exception ex )
        {
            log.error( "Fatal error! Exception {} caught updating transaction_log record with message {}. The transaction is being discarded.",
                    ex.getClass().getName(), ex.getMessage(), ex );

            return 0;
        }

    }
}
