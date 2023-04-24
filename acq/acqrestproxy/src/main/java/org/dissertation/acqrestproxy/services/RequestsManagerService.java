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

import lombok.Getter;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.dissertation.acqrestproxy.exceptions.DuplicateUniqueKeyException;
import org.dissertation.acqrestproxy.exceptions.KeyNotFoundException;
import org.dissertation.jmspojo.AuthRequestRespJmsDto;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadPoolExecutor;

@Slf4j
@Component
public class RequestsManagerService
{
    private static final Map<String, RequestMonitor> threadsMap = new ConcurrentHashMap<>();

    @Setter
    @Getter
    public static class RequestMonitor
    {
        private AuthRequestRespJmsDto responseObject;

        public synchronized void waitForResponse( int timeout ) throws InterruptedException {
            wait( timeout );
        }

        public synchronized void notifyThread() {
            notify();
        }
    }

    public RequestMonitor addRequest(String uniqueKey ) throws DuplicateUniqueKeyException
    {
        log.trace( "addRequest()" );

        var monitor = new RequestMonitor();

        log.debug( "About to add new object with key: {} / instance: {}", uniqueKey, monitor );

        threadsMap.put( uniqueKey, monitor );

        return monitor;
    }


    public void removeRequestObject(String uniqueKey ) throws KeyNotFoundException
    {
        log.trace( "removeRequestObject()" );

        log.debug( "About remove object with key: {}", uniqueKey );

        if( !threadsMap.containsKey(uniqueKey) )
            throw new KeyNotFoundException( uniqueKey );

        threadsMap.remove( uniqueKey );
    }

    public void notifyRequestObject(String uniqueKey, AuthRequestRespJmsDto response)
    {
        log.trace( "notifyRequestObject()" );

        executor.execute(() -> {

            // Find the correspondent thread to respond
            try
            {
                RequestMonitor requestDto = threadsMap.remove(uniqueKey);

                if (requestDto == null)
                    throw new KeyNotFoundException(uniqueKey);


                log.debug("Found object associated to key: {} / instance: {}", uniqueKey, requestDto);

                requestDto.setResponseObject(response);

                log.info("About to notify thread for key: {}", uniqueKey);
                requestDto.notifyThread();
            }
            catch ( Exception ex )
            {
                log.error( "Error! Exception {} caught while trying to notify the request object thread with message {}. Message <{}> will not be processed... it is probably a late response.",
                        ex.getClass().getName(), ex.getMessage(), response );
            }

        });
    }

    private static ThreadPoolExecutor executor = (ThreadPoolExecutor) Executors.newFixedThreadPool(50 );
}
