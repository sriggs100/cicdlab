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

package org.dissertation.acqcsproxy.jms;

import lombok.extern.slf4j.Slf4j;
import org.dissertation.acqcsproxy.iso.IsoMsgKey;
import org.dissertation.acqcsproxy.services.RequestsManagerService;
import org.dissertation.acqcsproxy.tcp.MasterCardClientGateway;
import org.dissertation.acqcsproxy.tcp.TcpMessage;
import org.dissertation.jmspojo.AuthRequestJmsDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class JmsMasterCardConsumer
{
    public JmsMasterCardConsumer(MasterCardClientGateway masterCardClientGateway )
    {
        this.masterCardClientGateway = masterCardClientGateway;
    }

    private final MasterCardClientGateway masterCardClientGateway;

    private static final String masterMailbox = "out_master_cs_msg";

    @Autowired
    RequestsManagerService requestsManagerService;

    @JmsListener( destination = masterMailbox /*, containerFactory = "listenerFactory"*/ )
    public void receiveMessage( AuthRequestJmsDto authRequestJmsDto )
    {
        log.debug( "Received at {} msg: <{}>", masterMailbox, authRequestJmsDto );

        var msgKey = new IsoMsgKey( authRequestJmsDto.getMerchid(), authRequestJmsDto.getTermid(), authRequestJmsDto.getStan() );

        log.info( "Received at {} msg key: <{}>", masterMailbox, msgKey );

        try
        {
            // Add the request to the list of pending requests
            requestsManagerService.addRequest(
                    msgKey,
                    authRequestJmsDto );

            masterCardClientGateway.send( new TcpMessage(authRequestJmsDto.getIsoMessage()) );
        }
        catch ( Exception ex )
        {
            log.error( "Fatal error! Exception {} caught while trying to send request object to MasterCard with message {}. Message <{}> will not be processed.",
                    ex.getClass().getName(), ex.getMessage(), authRequestJmsDto );
        }
    }
}
