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

package org.dissertation.acqrestproxy.services;

import lombok.extern.slf4j.Slf4j;
import org.dissertation.jmspojo.AuthRequestJmsDto;
import org.dissertation.jmspojo.AuthRequestRespJmsDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.Date;

@Slf4j
@Component
public class TestUtils {
    public static final byte[] rawRequestMsg = new byte[] { 0x31, 0x31, 0x30, 0x30 };
    public static final byte[] rawResponseMsg = new byte[] { 0x31, 0x31, 0x31, 0x30 };
    public static final byte[] rawLateResponseRequestMsg = new byte[] { 0x31, 0x31, 0x32, 0x30 };
    public static final byte[] rawNoResponseRequestMsg = new byte[] { 0x31, 0x31, 0x34, 0x30 };

    @Autowired
    JmsTemplate jmsTemplate;


    @Value("${authrequest.timeout}")
    private Integer reqTimeout;

    @JmsListener(destination = "inc_term_acq" /*, containerFactory = "responseFactory" */)
    public void receiveMessage( AuthRequestJmsDto authRequestJmsDto ) throws InterruptedException
    {
        log.debug("Received <" + authRequestJmsDto + ">");


        var authRequestRespJmsDto = new AuthRequestRespJmsDto();
        authRequestRespJmsDto.setUniqueId( authRequestJmsDto.getUniqueId() );
        authRequestRespJmsDto.setRequestTimestamp( authRequestJmsDto.getTimestamp() );
        authRequestRespJmsDto.setIsoMessage( rawResponseMsg );

        if( Arrays.equals( authRequestJmsDto.getIsoMessage(), rawRequestMsg) )
        {
            authRequestRespJmsDto.setResponseTimestamp( new Date() );
            jmsTemplate.convertAndSend( "out_term_msg", authRequestRespJmsDto );
        }
        else if( Arrays.equals( authRequestJmsDto.getIsoMessage(), rawLateResponseRequestMsg) )
        {
            Thread.sleep( reqTimeout * 1000 + 1 );

            authRequestRespJmsDto.setResponseTimestamp( new Date() );
            jmsTemplate.convertAndSend( "out_term_msg", authRequestRespJmsDto );
        }

        // otherwise the message won't be replied

    }
}
