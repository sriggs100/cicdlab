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
import org.dissertation.iso8583.IsoMsgDefinition;
import org.dissertation.iso8583.IsoParser;
import org.dissertation.isomsgs.AuthResponseMsgDef;
import org.dissertation.jmspojo.AuthRequestRespJmsDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.LinkedList;

@Slf4j
@Component
public class JmsResponsesConsumer
{
    @Autowired
    private StorageService storageService;

    @Autowired
    private JmsProducer jmsProducer;

    private static final IsoParser isoParser = new IsoParser(new LinkedList<IsoMsgDefinition>() {{ add(new AuthResponseMsgDef()); }} );

    private static final String incResponseMailbox = "out_term_acq";

    private static final String destinationMailbox = "out_term_msg";

    @JmsListener(destination = incResponseMailbox, containerFactory = "listenerFactory")
    public void receiveMessage( AuthRequestRespJmsDto authRequestRespJmsDto )
    {
        log.trace( "receiveMessage( mb = {} )", incResponseMailbox);

        log.debug("Received <" + authRequestRespJmsDto + ">");

        try
        {
            log.info("Received response unique key: {}", authRequestRespJmsDto.getUniqueId() );


            // Parse incoming message
            var isoMessage = isoParser.parse( authRequestRespJmsDto.getIsoMessage() );

            // Update database with the response
            Date updateT1 = new Date();
            var isUpdated = storageService.updateRecord( isoMessage);
            Date updateT2 = new Date();

            long sentTime = 0;
            if( isUpdated )
            {
                // Send the message to destination
                Date sentT1 = new Date();
                jmsProducer.send(destinationMailbox, authRequestRespJmsDto);
                sentTime = new Date().getTime() - sentT1.getTime();
            }

            if( isUpdated )
                log.info("Unique key: {} / Iso message key: MerchId: {} / TermId: {} / Stan: {} / Db update ms: {} / Jms time (sent): {}", authRequestRespJmsDto.getUniqueId(),
                        authRequestRespJmsDto.getMerchid(), authRequestRespJmsDto.getTermid(), authRequestRespJmsDto.getStan(),
                        updateT2.getTime() - updateT1.getTime(), sentTime );
            else
                log.info("Unique key: {} / Iso message key: MerchId: {} / TermId: {} / Stan: {} / Db update ms: {}", authRequestRespJmsDto.getUniqueId(),
                    authRequestRespJmsDto.getMerchid(), authRequestRespJmsDto.getTermid(), authRequestRespJmsDto.getStan(),
                    updateT2.getTime() - updateT1.getTime() );
        }
        catch( Exception ex )
        {
            log.error( "Fatal error! Exception {} caught while processing a response with error message {}. The message is being discarded.",
                    ex.getClass().getName(), ex.getMessage() );
        }
    }

}
