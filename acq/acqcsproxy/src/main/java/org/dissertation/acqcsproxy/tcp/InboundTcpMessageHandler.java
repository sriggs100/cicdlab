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

package org.dissertation.acqcsproxy.tcp;

import lombok.extern.slf4j.Slf4j;
import org.dissertation.acqcsproxy.iso.IsoMsgToKey;
import org.dissertation.acqcsproxy.jms.JmsProducer;
import org.dissertation.acqcsproxy.services.RequestsManagerService;
import org.dissertation.jmspojo.AuthRequestRespJmsDto;

import java.util.Date;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadPoolExecutor;

@Slf4j
public class InboundTcpMessageHandler
{
    public InboundTcpMessageHandler(JmsProducer jmsProducer, RequestsManagerService requestsManagerService )
    {
        this.jmsProducer = jmsProducer;
        this.requestsManagerService = requestsManagerService;
    }

    private final JmsProducer jmsProducer;

    private final RequestsManagerService requestsManagerService;


    private static ThreadPoolExecutor executor =
            (ThreadPoolExecutor) Executors.newFixedThreadPool(20 );

    protected void incomingMsg(TcpMessage in)
    {
        log.trace( "incomingMsg()" );

        executor.execute(() -> {
            try {
                var msgKey = IsoMsgToKey.getKey(in.isoMsg);

                log.info("Received message key from socket: {}", msgKey);

                var requestObjectOpt = requestsManagerService.getRequestObject(msgKey);

                if (requestObjectOpt.isEmpty()) {
                    log.warn("Error! Message has not been found for key {}. This should never happen. The current message will be discarded.", msgKey);

                    return;
                }

                requestsManagerService.removeRequestObject(msgKey);

                var responseMsg = new AuthRequestRespJmsDto(requestObjectOpt.get().getUniqueId(),
                        requestObjectOpt.get().getTimestamp(), new Date(), in.isoMsg, requestObjectOpt.get().getMerchid(),
                        requestObjectOpt.get().getTermid(), requestObjectOpt.get().getStan());

                Date sentT1 = new Date();
                jmsProducer.send(responseMsg);
                var sentTime = new Date().getTime() - sentT1.getTime();

                log.info("Response message with id {} sent ms: {}", requestObjectOpt.get().getUniqueId(), sentTime);
            } catch (Exception ex) {
                log.warn("Error! Exception {} caught while reading a new message from the socket with error message {}. The current message will be discarded.",
                        ex.getClass().getName(), ex.getMessage(), ex);

            }
        });
    }

}
