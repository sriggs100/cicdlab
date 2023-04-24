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
import org.dissertation.jmspojo.AuthRequestJmsDto;
import org.dissertation.jmspojo.AuthRequestRespJmsDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class JmsProducer
{
    @Autowired
    JmsTemplate jmsTemplate;

    public void send( String destMailbox, AuthRequestJmsDto req )
    {
        log.trace( "JmsProducer.send( dest = {} )", destMailbox );

        try {
            jmsTemplate.convertAndSend(destMailbox, req);
        }
        catch( Exception ex )
        {
            log.error( "Fatal error! Exception {} caught while trying to send jms object [{}]. Message <{}> will not be processed.",
                    ex.getClass().getName(), ex.getMessage(), req );
        }
    }

    public void send( String destMailbox, AuthRequestRespJmsDto resp )
    {
        log.trace( "JmsProducer.send( dest = {} )", destMailbox );

        try {
            jmsTemplate.convertAndSend(destMailbox, resp);
        }
        catch( Exception ex )
        {
            log.error( "Fatal error! Exception {} caught while trying to send jms object [{}]. Message <{}> will not be processed.",
                    ex.getClass().getName(), ex.getMessage(), resp );
        }

    }
}
