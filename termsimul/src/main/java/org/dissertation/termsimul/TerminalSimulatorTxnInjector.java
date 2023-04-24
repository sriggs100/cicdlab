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

package org.dissertation.termsimul;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.NoHttpResponseException;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.dissertation.iso8583.IsoGenerator;
import org.dissertation.termsimul.dtos.AuthRequestDto;
import org.dissertation.termsimul.dtos.AuthRequestRespDto;
import org.dissertation.termsimul.utils.OutputReport;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Date;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import org.apache.http.client.fluent.Request;
import org.dissertation.termsimul.utils.IsoUtils;

@Slf4j
public class TerminalSimulatorTxnInjector implements TerminalSimulator {
    private OutputReport outputReport;

    private int socketResponseTimeout;
    private int transactionTimeOut;

    public TerminalSimulatorTxnInjector(String acqsimulUri)
    {
        this.acqsimulUri = acqsimulUri;
    }

    /**
     * Inject the transaction and wait for the response before updating statistics data
     * This method must be non-blocking, hence it should start its own thread to wait for a response
     *
     * @param csvTransaction
     */
    @Override
    public void process(String[] csvTransaction ) throws Exception
    {
        log.trace( "TerminalSimulatorTxnInjector.process()" );

        try {

            executor.execute(new Runnable() {
                @Override
                public void run()
                {
                    // Get transaction information
                    String msgType = csvTransaction[IsoUtils.CSVID.MSGTYPE.getVal()];

                    String amount = IsoUtils.formatAmount( new BigDecimal(csvTransaction[IsoUtils.CSVID.AMOUNT.getVal()]), 2);
                    String stan = String.format( "%06d", Integer.parseInt(csvTransaction[IsoUtils.CSVID.STAN.getVal()]));
                    String functionCode = csvTransaction[IsoUtils.CSVID.FUNCTION_CODE.getVal()];
                    String termId = csvTransaction[IsoUtils.CSVID.TERMID.getVal()];
                    String merchId = csvTransaction[IsoUtils.CSVID.MERCHID.getVal()];
                    String cardScheme = csvTransaction[IsoUtils.CSVID.CARD_SCHEME.getVal()];
                    String expectedActionCode = String.format( "%03d", Short.parseShort(csvTransaction[IsoUtils.CSVID.ACTIONCODE.getVal()]));
                    String expectedAuthCode = "000000" + csvTransaction[IsoUtils.CSVID.AUTHCODE.getVal()];
                    expectedAuthCode = expectedAuthCode.substring( expectedAuthCode.length() - 6);
                    Date t1 = null;

                    try
                    {
                        // Inject the transaction and wait for the response
                        t1 = new Date();

                        var isoMessage = IsoUtils.createAuthRequest( csvTransaction );
                        var isoGenerator = new IsoGenerator();

                        log.debug( "ISO message created: {}", isoMessage );

                        outputReport.transactionSent();

                        var isoRequest = new AuthRequestDto( isoGenerator.generateIsoMsg( isoMessage ) );

                        log.debug( "About to send request message: {}", isoRequest );

                        log.info( "About to send request message with key elements: MerchId={} / TermId={} / Stan={} ",
                                merchId, termId, stan );

                        var response = Request.Post(acqsimulUri)
                                .bodyString( new ObjectMapper().writeValueAsString(
                                        isoRequest ), ContentType.APPLICATION_JSON )
                                .connectTimeout( 5 * 1000 )
                                .socketTimeout( socketResponseTimeout )
                                .execute().returnResponse();

                        log.debug( "Response message: {}", response );

                        Date t2 = new Date();   // Response timestamp

                        // Validate response data
                        if( response.getStatusLine().getStatusCode() != 200 )
                        {
                            // Error condition returned by the acquirer. update statistics

                            log.info( "Failed with http status code = {} / MerchId={} / TermId={} / Stan={} / Amount={}",
                                    response.getStatusLine().getStatusCode(), merchId, termId, stan, amount );

                            outputReport.transactionFailed( t1, msgType, merchId, termId, stan, amount, cardScheme, functionCode, response.getStatusLine().getStatusCode() );
                        }
                        else {


                            var authRequestRespDto = new ObjectMapper().readValue(response.getEntity().getContent(), AuthRequestRespDto.class);

                            log.debug("Parsed response message: {}", authRequestRespDto);

                            var responseIsoMsg = IsoUtils.getIsoParser().parse(authRequestRespDto.getRawIsoMessage());

                            // validate expected response data
                            var receivedAmount = responseIsoMsg.getElement(4).asString();
                            var receivedStan = responseIsoMsg.getElement(11).asString();
                            var receivedFunctionCode = responseIsoMsg.getElement(24).asString();
                            var receivedTermId = responseIsoMsg.getElement(41).asString();
                            var receivedMerchId = responseIsoMsg.getElement(42).asString();
                            var receivedAuthCode = responseIsoMsg.getElement(38).asString();
                            var receivedActionCode = responseIsoMsg.getElement(39).asString();

                            log.debug("Response message key elements: Amount={} / Stan={} / Function Code={} " +
                                            "/ TermId={} / MerchId={} / Auth Code={} / Action Code={}",
                                    receivedAmount, receivedStan, receivedFunctionCode, receivedTermId,
                                    receivedMerchId, receivedAuthCode, receivedActionCode);

                            log.debug("Expected key elements: Amount={} / Stan={} / Function Code={} " +
                                            "/ TermId={} / MerchId={} / Auth Code={} / Action Code={}",
                                    amount, stan, functionCode, termId,
                                    merchId, expectedAuthCode, expectedActionCode);

                            if (receivedAmount.equals(amount)
                                    && receivedStan.equals(stan)
                                    && receivedFunctionCode.equals(functionCode)
                                    && receivedTermId.equals(termId)
                                    && receivedMerchId.equals(merchId)
                                    && receivedAuthCode.equals(expectedAuthCode)
                                    && receivedActionCode.equals(expectedActionCode)) {
                                if (t2.getTime() - t1.getTime() > transactionTimeOut) {
                                    // Late response condition

                                    log.info("Late response, t1={} / t2={} / key={}{}{}", t1, t2, merchId, termId, stan);

                                    outputReport.transactionLateResponse(t1, t2, msgType, merchId, termId, stan, amount, cardScheme, functionCode, expectedActionCode, expectedAuthCode);
                                } else {
                                    log.info("Response OK / MerchId={} / TermId={} / Stan={} / Amount={}", merchId, termId, stan, amount);

                                    outputReport.transactionProcessed(t1, t2, msgType, merchId, termId, stan, amount, cardScheme, functionCode, expectedActionCode, expectedAuthCode);
                                }
                            } else {
                                log.info("Bad response");

                                outputReport.transactionBadResponse(t1, t2, responseIsoMsg.getElement(42).asString(), responseIsoMsg.getElement(41).asString(),
                                        responseIsoMsg.getElement(11).asString(), responseIsoMsg.getElement(4).asString(), responseIsoMsg.getElement(24).asString(),
                                        responseIsoMsg.getElement(39).asString(), responseIsoMsg.getElement(38).asString(),
                                        merchId, termId, stan, amount, functionCode, expectedActionCode, expectedAuthCode);
                            }

                        }
                    }
                    catch ( java.net.SocketException ct )
                    {
                        // Connection Timeout
                        log.warn( "Exception {} caught while injecting transactions inside a worker thread with message: {}.", ct.getClass().getName(), ct.getMessage(), ct );

                        try {
                            log.info( "Not replied, t1={} / key={}{}{}", t1, merchId, termId, stan );

                            outputReport.transactionNotReplied( t1, msgType, merchId, termId, stan, amount, cardScheme, functionCode );
                        } catch (IOException e) {
                            throw new RuntimeException(e);
                        }

                    }
                    catch( java.net.SocketTimeoutException st )
                    {
                        // Socket Timeout
                        log.warn( "Exception {} caught while injecting transactions inside a worker thread with message: {}.", st.getClass().getName(), st.getMessage(), st );

                        try {
                            log.info( "Not replied, t1={} / key={}{}{}", t1, merchId, termId, stan );

                            outputReport.transactionNotReplied( t1, msgType, merchId, termId, stan, amount, cardScheme, functionCode );
                        } catch (IOException e) {
                            throw new RuntimeException(e);
                        }
                    }
                    catch( NoHttpResponseException ex )
                    {
                        log.warn( "Exception {} caught while injecting transactions inside a worker thread with message: {}.", ex.getClass().getName(), ex.getMessage(), ex );

                        try {
                            log.info( "Not replied, t1={} / key={}{}{}", t1, merchId, termId, stan );

                            outputReport.transactionNotReplied( t1, msgType, merchId, termId, stan, amount, cardScheme, functionCode );
                        } catch (IOException e) {
                            throw new RuntimeException(e);
                        }
                    }
                    catch( Exception ex )
                    {
                        log.error( "Error. Exception {} caught while injecting transactions inside a worker thread with message: {}. Error condition set to true", ex.getClass().getName(), ex.getMessage(), ex );

                        errorCondition = true;
                    }
                }
            });
        }
        catch( Exception ex )
        {
            log.error( "Error. Exception {} caught while injecting transactions with message: {}.", ex.getClass().getName(), ex.getMessage(), ex );

            throw ex;
        }
    }

    private final String acqsimulUri;

    private volatile boolean errorCondition = false;

    @Override
    public void printReport() throws IOException
    {
        outputReport.printStatistics();
    }

    @Override
    public void setReport(OutputReport outputReport)
    {
        this.outputReport = outputReport;
    }

    /**
     *
     * @param tpsPerInstance
     * @param socketResponseTimeout         Will be slightly higher than <code>transactionResponseTimeout</code> in order to detect late responses
     * @param transactionResponseTimeout
     */
    @Override
    public void init(int tpsPerInstance, int socketResponseTimeout, int transactionResponseTimeout)
    {
        // Calculate the number of necessary threads based on the worst-case scenario. Considering that
        // there will be one thread per message being processed, the simulator will inject messages
        // at 'tpsPerInstance' rate, and the maximum response timeout 'socketResponseTimeout'
        int numberOfThreads = tpsPerInstance * socketResponseTimeout/1000;
        executor = Executors.newFixedThreadPool(numberOfThreads);

        this.socketResponseTimeout = socketResponseTimeout;
        this.transactionTimeOut = transactionResponseTimeout;

        log.info( "Created thread pool: {} threads", numberOfThreads );

    }

    @Override
    public boolean getErrorCondition() {
        return errorCondition;
    }

    @Override
    public void waitForAllThreads()
    {
        try {
            executor.awaitTermination(15, TimeUnit.SECONDS);
        }
        catch( Exception ex )
        {
            log.error( "Error. Exception {} caught while waiting for the process to finish with message: {}.", ex.getClass().getName(), ex.getMessage(), ex );
        }
    }

    private ExecutorService executor;
}
