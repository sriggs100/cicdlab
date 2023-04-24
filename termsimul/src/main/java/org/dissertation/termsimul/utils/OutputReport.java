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

import lombok.Setter;
import org.dissertation.termsimul.statistics.Statistics;

import java.io.IOException;
import java.util.Date;

public class OutputReport
{
    @Setter
    private OutputReportFile outputReportFile;

    private final Statistics stats = new Statistics();

    /**
     *
     * @param sent
     * @param received
     * @param msgType
     * @param merchId
     * @param termId
     * @param stan
     * @param amount
     * @param cardScheme        0 - Visa / 1 - MasterCard
     * @param functionCode      100 - Credit transaction / 200 - Debit transaction
     * @param actionCode
     * @param AuthCode
     */
    public synchronized void transactionProcessed(final Date sent, final Date received, String msgType, String merchId,
                                            String termId, String stan, String amount, String cardScheme, String functionCode,
                                                  String actionCode, String AuthCode ) throws IOException
    {
        var respTime = received.getTime() - sent.getTime();

        stats.setRepliedTxnCount( stats.getRepliedTxnCount() + 1 );
        stats.setTxnRespTime( stats.getTxnRespTime() + respTime );

        outputReportFile.appendToOutProcessedFile( respTime, sent, received, msgType, merchId,
                                        termId, stan, amount, cardScheme, functionCode, actionCode, AuthCode );
    }

    public synchronized void transactionLateResponse(final Date sent, final Date received, String msgType, String merchId,
                                            String termId, String stan, String amount, String cardScheme, String functionCode,
                                                     String actionCode, String AuthCode ) throws IOException
    {
        stats.setLateResponseTxnCount( stats.getLateResponseTxnCount() + 1 );

        outputReportFile.appendToOutLateResponseFile( received.getTime() - sent.getTime(), sent, received, msgType, merchId,
                termId, stan, amount, cardScheme, functionCode, actionCode, AuthCode );
    }

    public synchronized void transactionNotReplied(final Date sent, String msgType, String merchId,
                                                   String termId, String stan, String amount, String cardScheme, String functionCode ) throws IOException
    {
        stats.setNotRepliedTxnCount( stats.getNotRepliedTxnCount() + 1 );

        outputReportFile.appendToOutNotRepliedFile( sent, msgType, merchId, termId, stan, amount, cardScheme, functionCode );
    }

    public synchronized void transactionFailed(final Date sent, String msgType, String merchId,
                                                     String termId, String stan, String amount, String cardScheme, String functionCode, int statusCode ) throws IOException
    {
        stats.setFailedTxnCount( stats.getFailedTxnCount() + 1 );

        outputReportFile.appendToOutFailedFile( sent, msgType, merchId, termId, stan, amount, cardScheme, functionCode, statusCode );
    }

    public synchronized void transactionBadResponse(final Date sent, final Date received, String merchId,
               String termId, String stan, String amount, String functionCode, String actionCode, String authCode,
               String expMerchId, String expTermId, String expStan, String expAmount,
               String expFunctionCode, String expActionCode, String expAuthCode ) throws IOException
    {
        stats.setBadResponseTxnCount( stats.getBadResponseTxnCount() + 1 );

        outputReportFile.appendToBadResponseFile( received.getTime() - sent.getTime(), sent, received,
                merchId, termId, stan, amount, functionCode, actionCode, authCode,
                expMerchId, expTermId, expStan, expAmount, expFunctionCode, expActionCode, expAuthCode);
    }

    public synchronized void printStatistics() throws IOException
    {
        if( stats.getRepliedTxnCount() != 0 )
            stats.setAverageResponseTimeMillis( (int)(stats.getTxnRespTime() / stats.getRepliedTxnCount()) );

        outputReportFile.appendToOutStatisticsFile( stats );
    }

    public void transactionSent()
    {
        stats.setSentTxnCount( stats.getSentTxnCount() + 1 );
    }
}
