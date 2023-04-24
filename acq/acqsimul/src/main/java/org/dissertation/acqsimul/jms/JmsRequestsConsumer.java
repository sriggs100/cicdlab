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

package org.dissertation.acqsimul.jms;

import lombok.extern.slf4j.Slf4j;
import org.dissertation.acqsimul.services.StorageService;
import org.dissertation.acqsimul.services.TransactionRouterService;
import org.dissertation.iso8583.IsoMsgDefinition;
import org.dissertation.iso8583.IsoParser;
import org.dissertation.isomsgs.AuthRequestMsgDef;
import org.dissertation.jmspojo.AuthRequestJmsDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.LinkedList;

@Slf4j
@Component
public class JmsRequestsConsumer
{
    @Autowired
    private TransactionRouterService transactionRouterService;

    @Autowired
    private StorageService storageService;

    @Autowired
    private JmsProducer jmsProducer;

    private static final IsoParser isoParser = new IsoParser(new LinkedList<IsoMsgDefinition>() {{ add(new AuthRequestMsgDef()); }} );

    private static final String incRequestMailbox = "inc_term_acq";

    @JmsListener(destination = incRequestMailbox, containerFactory = "listenerFactory" )
    public void receiveMessage( AuthRequestJmsDto authRequestJmsDto )
    {
        log.trace( "receiveMessage( mb = {} )", incRequestMailbox );

        log.debug("Received <" + authRequestJmsDto + ">");

        log.info("Received request unique key: {}", authRequestJmsDto.getUniqueId());

        try
        {
            // Parse incoming message
            var isoMessage = isoParser.parse( authRequestJmsDto.getIsoMessage() );

            Date insertT1 = new Date();
            // Insert into database
            if( !storageService.insertRecord( authRequestJmsDto.getUniqueId(), isoMessage ) )
            {
                log.error( "For some reason the transaction has not been inserted. Being discarded." );

                return; // There was an error
            }
            Date insertT2 = new Date();

            // Perform routing
            String destinationMailbox = transactionRouterService.getRoute( isoMessage.getElement( 2 ).asBinary() );

            // Add elements to the request message that will be used as an idempotent key to match with the response
            authRequestJmsDto.setMerchid( isoMessage.getElement( 42 ).asString() );
            authRequestJmsDto.setTermid( isoMessage.getElement( 41 ).asString() );
            authRequestJmsDto.setStan( Integer.parseInt( isoMessage.getElement( 11 ).asString() ) );

            // Send the message to destination
            Date sentT1 = new Date();
            jmsProducer.send( destinationMailbox, authRequestJmsDto );
            var sentTime = new Date().getTime() - sentT1.getTime();


            log.info("Unique key: {} / Iso message key: MerchId: {} / TermId: {} / Stan: {} / Db insert ms: {} / JMS sent ms: {}", authRequestJmsDto.getUniqueId(),
                    authRequestJmsDto.getMerchid(), authRequestJmsDto.getTermid(), authRequestJmsDto.getStan(),
                    insertT2.getTime() - insertT1.getTime(), sentTime );
        }
        catch( Exception ex )
        {
            log.error( "Fatal error! Exception {} caught while processing a request with error message {}. The message is being discarded.",
                    ex.getClass().getName(), ex.getMessage() );
        }
    }

}
