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
import org.dissertation.acqrestproxy.dtos.RawIsoMessage;
import org.dissertation.acqrestproxy.exceptions.DuplicateUniqueKeyException;
import org.dissertation.acqrestproxy.exceptions.KeyNotFoundException;
import org.dissertation.acqrestproxy.jms.JmsProducer;
import org.dissertation.jmspojo.AuthRequestJmsDto;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
public class AuthRequestService
{

    public AuthRequestService( JmsProducer producer, RequestsManagerService mgr )
    {
        jmsProducer = producer;
        requestsManagerService = mgr;
    }

    @Value("${authrequest.timeout}")
    private Integer reqTimeout;


    private final JmsProducer jmsProducer;
    private final RequestsManagerService requestsManagerService;

    public Optional<RawIsoMessage> request(RawIsoMessage requestDto )
    {
        log.trace( "request()" );

        var reqDto = new AuthRequestJmsDto();
        reqDto.setUniqueId( UUID.randomUUID().toString() );
        reqDto.setIsoMessage(requestDto.getRawIsoMessage());

        log.info( "About to send request message: {}", reqDto );

        Date sentT1 = new Date();
        jmsProducer.send( reqDto );
        var sentTime = new Date().getTime() - sentT1.getTime();

        log.info( "Send time for message id {}: {} ms", reqDto.getUniqueId(), sentTime );

        // Add the current thread to the list of threads waiting for a response
        RequestsManagerService.RequestMonitor monitor = null;
        try
        {
            monitor = requestsManagerService.addRequest( reqDto.getUniqueId() );
        }
        catch (DuplicateUniqueKeyException ex)
        {
            log.error( "Fatal error! Exception {} caught while adding a new request object. This should never happen. Aborting operation.",
                    ex.getClass().getName(), ex );

            throw new RuntimeException(ex);
        }

        try
        {
            monitor.waitForResponse( reqTimeout * 1000 );
        }
        catch (InterruptedException e)
        {
            log.warn( "Thread was interrupted during wait()" );
        }

        var elapsedTime = new Date().getTime() - reqDto.getTimestamp().getTime();
        log.debug( "Elapsed time after wait(): {} ms", elapsedTime );

        // Process response if present, otherwise return null

        var respDto = monitor.getResponseObject();
        if( respDto != null )
        {
            // Process the response
            if( elapsedTime > reqTimeout * 1000 )
            {
                log.warn( "Late response detected. It will be ignored.");
                return Optional.empty();
            }

            if( respDto.getIsoMessage() == null )
            {
                log.warn( "respDto.getIsoMessage() IS NULL" );
                return Optional.empty();
            }


            if( log.isDebugEnabled() )
                log.debug( "About to return response: {} corresponding to request: {}", respDto, reqDto );


            log.info( "About response message id: {}", reqDto.getUniqueId() );

            return Optional.of( new RawIsoMessage( respDto.getIsoMessage() ) );
        }

        log.warn( "respDto IS NULL for request: {}", reqDto );

        try
        {
            requestsManagerService.removeRequestObject( reqDto.getUniqueId() );
        }
        catch (KeyNotFoundException ex)
        {
            log.warn( "Error! Exception {} caught while removing a request object.",
                    ex.getClass().getName(), ex );
        }

        // Return empty
        return Optional.empty();
    }

    public synchronized void notifyThread()
    {
        this.notify();
    }
}
