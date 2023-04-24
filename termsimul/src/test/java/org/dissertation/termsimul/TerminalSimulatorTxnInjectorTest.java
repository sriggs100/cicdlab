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

import com.github.tomakehurst.wiremock.client.WireMock;
import com.github.tomakehurst.wiremock.junit5.WireMockRuntimeInfo;
import com.github.tomakehurst.wiremock.junit5.WireMockTest;
import org.dissertation.termsimul.utils.IsoUtils;
import org.dissertation.termsimul.utils.OutputReport;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Base64;
import java.util.Date;

import static com.github.tomakehurst.wiremock.client.WireMock.*;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@WireMockTest(httpPort = 8080)
public class TerminalSimulatorTxnInjectorTest
{
    @Mock
    private OutputReport outputReport;

    @Test
    public void whenTransactionRepliedOnTime_thenStatisticsAreUpdatedAccordingly(WireMockRuntimeInfo wmRuntimeInfo ) throws Exception
    {
        WireMock wireMock = wmRuntimeInfo.getWireMock();
        wireMock.register(get("/instance-dsl").willReturn(ok()));

        wireMock.register( post( "/api/v1/isomsg/auth-request" )
            .willReturn( aResponse().withStatus( 200 )
               .withBody( String.format( "{ \"rawIsoMessage\" : \"%s\" }",
                       Base64.getEncoder().encodeToString(rawIsoMsg) )
               ) )
        );


        var terminalSimulatorTxnInjector = new TerminalSimulatorTxnInjector( "http://localhost:8080/api/v1/isomsg/auth-request");
        terminalSimulatorTxnInjector.init( 1, 10 * 1000, 5 * 1000 );
        terminalSimulatorTxnInjector.setReport( outputReport );

        terminalSimulatorTxnInjector.process( csvFields );

        terminalSimulatorTxnInjector.waitForAllThreads();


        verify( outputReport, times(1) ).transactionSent();
        verify( outputReport, times(1) ).transactionProcessed(
                any( Date.class ), any( Date.class ), eq(csvFields[11]), eq(csvFields[10]), eq(csvFields[17]), eq(csvFields[16]),
                eq(IsoUtils.formatAmount( new BigDecimal(csvFields[2]), 2)), eq(csvFields[6]), eq(csvFields[8]), eq("000"), eq(csvFields[4])
        );
    }

    @Test
    public void whenTransactionReturnedErrorCode_thenStatisticsAreUpdatedAccordingly(WireMockRuntimeInfo wmRuntimeInfo ) throws Exception
    {
        WireMock wireMock = wmRuntimeInfo.getWireMock();
        wireMock.register(get("/instance-dsl").willReturn(ok()));

        wireMock.register( post( "/api/v1/isomsg/auth-request" )
                .willReturn( aResponse().withStatus( 500 ) ) );


        var terminalSimulatorTxnInjector = new TerminalSimulatorTxnInjector( "http://localhost:8080/api/v1/isomsg/auth-request");
        terminalSimulatorTxnInjector.init( 1, 10 * 1000, 5 * 1000 );
        terminalSimulatorTxnInjector.setReport( outputReport );

        terminalSimulatorTxnInjector.process( csvFields );

        terminalSimulatorTxnInjector.waitForAllThreads();


        verify( outputReport, times(1) ).transactionSent();
        verify( outputReport, times(1) ).transactionFailed(
                any( Date.class ), eq(csvFields[11]), eq(csvFields[10]), eq(csvFields[17]), eq(csvFields[16]),
                eq(IsoUtils.formatAmount( new BigDecimal(csvFields[2]), 2)), eq(csvFields[6]), eq(csvFields[8]), eq(500)
        );
    }

    @Test
    public void whenTransactionRepliedLaterThanExpected_thenStatisticsAreUpdatedAccordingly(WireMockRuntimeInfo wmRuntimeInfo ) throws Exception
    {
        WireMock wireMock = wmRuntimeInfo.getWireMock();
        wireMock.register(get("/instance-dsl").willReturn(ok()));

        wireMock.register( post( "/api/v1/isomsg/auth-request" )
                .willReturn( aResponse().withStatus( 200 )
                        .withBody( String.format( "{ \"rawIsoMessage\" : \"%s\" }",
                                Base64.getEncoder().encodeToString(rawIsoMsg) )
                        )
                        .withFixedDelay(1500))
        );


        var terminalSimulatorTxnInjector = new TerminalSimulatorTxnInjector( "http://localhost:8080/api/v1/isomsg/auth-request");
        terminalSimulatorTxnInjector.init( 1, 10 * 1000, 1 * 1000 );
        terminalSimulatorTxnInjector.setReport( outputReport );

        terminalSimulatorTxnInjector.process( csvFields );

        terminalSimulatorTxnInjector.waitForAllThreads();


        verify( outputReport, times(1) ).transactionSent();
        verify( outputReport, times(1) ).transactionLateResponse(
                any( Date.class ), any( Date.class ), eq(csvFields[11]), eq(csvFields[10]), eq(csvFields[17]), eq(csvFields[16]),
                eq(IsoUtils.formatAmount( new BigDecimal(csvFields[2]), 2)), eq(csvFields[6]), eq(csvFields[8]), eq("000"), eq(csvFields[4])
        );
    }

    @Test
    public void whenTransactionRepliedWithMismatchedData_thenStatisticsAreUpdatedAccordingly(WireMockRuntimeInfo wmRuntimeInfo ) throws Exception
    {
        WireMock wireMock = wmRuntimeInfo.getWireMock();
        wireMock.register(get("/instance-dsl").willReturn(ok()));

        wireMock.register( post( "/api/v1/isomsg/auth-request" )
                .willReturn( aResponse().withStatus( 200 )
                        .withBody( String.format( "{ \"rawIsoMessage\" : \"%s\" }",
                                Base64.getEncoder().encodeToString(rawIsoMsg) )
                        )
                        .withFixedDelay(1500))
        );


        var terminalSimulatorTxnInjector = new TerminalSimulatorTxnInjector( "http://localhost:8080/api/v1/isomsg/auth-request");
        terminalSimulatorTxnInjector.init( 1, 10 * 1000, 1 * 1000 );
        terminalSimulatorTxnInjector.setReport( outputReport );

        terminalSimulatorTxnInjector.process( mismatchedCsvFields );

        terminalSimulatorTxnInjector.waitForAllThreads();


        verify( outputReport, times(1) ).transactionSent();
        verify( outputReport, times(1) ).transactionBadResponse(
                any( Date.class ), any( Date.class ), eq(csvFields[10]), eq(csvFields[17]), eq(csvFields[16]),
                eq(IsoUtils.formatAmount( new BigDecimal(csvFields[2]), 2)), eq(csvFields[8]), eq("000"), eq(csvFields[4]),

                eq(mismatchedCsvFields[10]), eq(mismatchedCsvFields[17]), eq(mismatchedCsvFields[16]),
                eq(IsoUtils.formatAmount( new BigDecimal(mismatchedCsvFields[2]), 2)), eq(mismatchedCsvFields[8]), eq("000"), eq(mismatchedCsvFields[4])
        );
    }


    @Test
    public void whenTransactionNotReplied_thenStatisticsAreUpdatedAccordingly(WireMockRuntimeInfo wmRuntimeInfo ) throws Exception
    {
        WireMock wireMock = wmRuntimeInfo.getWireMock();
        wireMock.register(get("/instance-dsl").willReturn(ok()));

        wireMock.register( post( "/api/v1/isomsg/auth-request" )
                .willReturn( aResponse().withStatus( 200 )
                        .withBody( String.format( "{ \"rawIsoMessage\" : \"%s\" }",
                                Base64.getEncoder().encodeToString(rawIsoMsg) )
                        )
                        .withFixedDelay(6 * 1000 ))
        );



        var terminalSimulatorTxnInjector = new TerminalSimulatorTxnInjector( "http://localhost:8080/api/v1/isomsg/auth-request");
        terminalSimulatorTxnInjector.init( 1, 5 * 1000, 4 * 1000 );
        terminalSimulatorTxnInjector.setReport( outputReport );

        terminalSimulatorTxnInjector.process( csvFields );

        terminalSimulatorTxnInjector.waitForAllThreads();


        verify( outputReport, times(1) ).transactionSent();
        verify( outputReport, times(1) ).transactionNotReplied(
                any( Date.class ), eq(csvFields[11]), eq(csvFields[10]), eq(csvFields[17]), eq(csvFields[16]),
                eq(IsoUtils.formatAmount( new BigDecimal(csvFields[2]), 2)), eq(csvFields[6]), eq(csvFields[8])
        );
    }


    private static String[] csvFields = new String[] {

            // 0 - action_code
            "0"
            // 1 - additional_data
            ,"020510203"
            // 2 - amount
            ,"0000000004.10"
            // 3 - application_transaction_counter
            , ""
            // 4 - authorisation_code
            , "123456"
            // 5 - card_acceptor_name_and_location
            , "INSURANCE LTD\\Main Street\\London\\    E143GJ   UK"
            // 6 - card_scheme
            , "1"
            // 7 - chip_data
            , "820212908407A0000000041010950500000000019A032208019C01005F24032005315F2A0209789F02060000000000019F03060000000000009F090200029F1012F110A04003223000000000000000000000FF9F1A0202339F1E0832383032313836309F26086229F3A0784832AF9F2701809F3303E008089F34031F03029F3501229F360201019F3704DDD0D03C9F530152"
            // 8 - function_code
            , "100"
            // 9 - merchant_category_code
            , "5619"
            // 10 - merchant_id
            , "965949256594925"
            // 11 - msg_type
            , "1100"
            // 12 - pan_sequence_number
            , "001"
            // 13 - point_of_service_data_code
            , "1503"
            // 14 - proc_code
            , "000000"
            // 15 - reason_code
            , ""
            // 16 - stan
            , "898394"
            // 17 - terminal_id
            , "76011061"
            // 18 - transaction_currency_code
            , "978"
            // 19 - transaction_date_time
            , "220809154758"
            // 20 - transaction_emv_data_id
            , ""
    };


    private static String[] mismatchedCsvFields = new String[] {

            // 0 - action_code
            "0"
            // 1 - additional_data
            ,"020510203"
            // 2 - amount
            ,"0000000014.10"
            // 3 - application_transaction_counter
            , ""
            // 4 - authorisation_code
            , "123456"
            // 5 - card_acceptor_name_and_location
            , "INSURANCE LTD\\Main Street\\London\\    E143GJ   UK"
            // 6 - card_scheme
            , "1"
            // 7 - chip_data
            , "820212908407A0000000041010950500000000019A032208019C01005F24032005315F2A0209789F02060000000000019F03060000000000009F090200029F1012F110A04003223000000000000000000000FF9F1A0202339F1E0832383032313836309F26086229F3A0784832AF9F2701809F3303E008089F34031F03029F3501229F360201019F3704DDD0D03C9F530152"
            // 8 - function_code
            , "100"
            // 9 - merchant_category_code
            , "5619"
            // 10 - merchant_id
            , "965949256594925"
            // 11 - msg_type
            , "1100"
            // 12 - pan_sequence_number
            , "001"
            // 13 - point_of_service_data_code
            , "1503"
            // 14 - proc_code
            , "000000"
            // 15 - reason_code
            , ""
            // 16 - stan
            , "898394"
            // 17 - terminal_id
            , "76011061"
            // 18 - transaction_currency_code
            , "978"
            // 19 - transaction_date_time
            , "220809154758"
            // 20 - transaction_emv_data_id
            , ""
    };


    private static byte[] rawIsoMsg = new byte[] {

            // Message Type - 				- 1110
            '1', '1', '1', '0'
            // Pri Bit Map  - 				- 303003C00EC18200
            , (byte)0x30, (byte)0x30, (byte)0x07, (byte)0xC0, (byte)0x0E, (byte)0xC1, (byte)0x82, (byte)0x00
            // Element 003  - PCODE 		- 000000
            , '0', '0', '0', '0', '0', '0'
            // Element 004  - AMOUNT 		- 000000000410
            , '0', '0', '0', '0', '0', '0', '0', '0', '0', '4', '1', '0'
            // Element 011  - STAN 			- 898394
            , '8', '9', '8', '3', '9', '4'
            // Element 012  - DATE AND TIME	- 220809154758
            , '2', '2', '0', '8', '0', '9', '1', '5', '4', '7', '5', '8'
            // Element 022  - POS DATA CD 	- 100550J85100
            , '1', '0', '0', '5', '5', '0', 'J', '8', '5', '1', '0', '0'
            // Element 023  - CARD SEQ NBR 	- 001
            , '0', '0', '1'
            // Element 024  - FUNC CODE 	- 100
            , '1', '0', '0'
            // Element 025  - POS COND CD 	- 1503
            , '1', '5', '0', '3'
            // Element 026  - MCC 			- 5619
            , '5', '6', '1', '9'
            // Element 037  - RRN 			- 534305898384
            , '5', '3', '4', '3', '0', '5', '8', '9', '8', '3', '8', '4'
            // Element 038  - Auth Code
            , '1', '2', '3', '4', '5', '6'
            // Element 039  - Action Code
            , '0', '0', '0'
            // Element 041  - TERMID 		- 76011061
            , '7', '6', '0', '1', '1', '0', '6', '1'
            // Element 042  - MERCHID 		- 965949256594925
            , '9', '6', '5', '9', '4', '9', '2', '5', '6', '5', '9', '4', '9', '2', '5'
            // Element 048  - ADD DATA 		- 009020510203
            , '0', '0', '9', '0', '2', '0', '5', '1', '0', '2', '0', '3'
            // Element 049  - CURRENCY CD 	- 978
            , '9', '7', '8'
            // Element 055  - CHIP DATA 	- 313436820212908407A0000000041010950500000000019A032208019C01005F24032005315F2A0209789F02060000000000019F03060000000000009F090200029F1012F110A04003223000000000000000000000FF9F1A0202339F1E0832383032313836309F26086229F3A0784832AF9F2701809F3303E008089F34031F03029F3501229F360201019F3704DDD0D03C9F530152
            , (byte)0x31, (byte)0x34, (byte)0x36, (byte)0x82, (byte)0x02, (byte)0x12, (byte)0x90, (byte)0x84, (byte)0x07, (byte)0xA0, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x04, (byte)0x10, (byte)0x10, (byte)0x95, (byte)0x05, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x01, (byte)0x9A, (byte)0x03, (byte)0x22, (byte)0x08, (byte)0x01, (byte)0x9C, (byte)0x01, (byte)0x00, (byte)0x5F, (byte)0x24, (byte)0x03, (byte)0x20, (byte)0x05, (byte)0x31, (byte)0x5F, (byte)0x2A, (byte)0x02, (byte)0x09, (byte)0x78, (byte)0x9F, (byte)0x02, (byte)0x06, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x01, (byte)0x9F, (byte)0x03, (byte)0x06, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x9F, (byte)0x09, (byte)0x02, (byte)0x00, (byte)0x02, (byte)0x9F, (byte)0x10, (byte)0x12, (byte)0xF1, (byte)0x10, (byte)0xA0, (byte)0x40, (byte)0x03, (byte)0x22, (byte)0x30, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0x00, (byte)0xFF, (byte)0x9F, (byte)0x1A, (byte)0x02, (byte)0x02, (byte)0x33, (byte)0x9F, (byte)0x1E, (byte)0x08, (byte)0x32, (byte)0x38, (byte)0x30, (byte)0x32, (byte)0x31, (byte)0x38, (byte)0x36, (byte)0x30, (byte)0x9F, (byte)0x26, (byte)0x08, (byte)0x62, (byte)0x29, (byte)0xF3, (byte)0xA0, (byte)0x78, (byte)0x48, (byte)0x32, (byte)0xAF, (byte)0x9F, (byte)0x27, (byte)0x01, (byte)0x80, (byte)0x9F, (byte)0x33, (byte)0x03, (byte)0xE0, (byte)0x08, (byte)0x08, (byte)0x9F, (byte)0x34, (byte)0x03, (byte)0x1F, (byte)0x03, (byte)0x02, (byte)0x9F, (byte)0x35, (byte)0x01, (byte)0x22, (byte)0x9F, (byte)0x36, (byte)0x02, (byte)0x01, (byte)0x01, (byte)0x9F, (byte)0x37, (byte)0x04, (byte)0xDD, (byte)0xD0, (byte)0xD0, (byte)0x3C, (byte)0x9F, (byte)0x53, (byte)0x01, (byte)0x52

    };

}
