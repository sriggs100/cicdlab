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

package org.dissertation.acqcsproxy.services;

import lombok.extern.slf4j.Slf4j;
import org.dissertation.acqcsproxy.exceptions.KeyNotFoundException;
import org.dissertation.acqcsproxy.iso.IsoMsgKey;
import org.dissertation.jmspojo.AuthRequestJmsDto;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Component
public class RequestsManagerService
{
    private static final Map<IsoMsgKey, AuthRequestJmsDto> requestsMap = new ConcurrentHashMap<IsoMsgKey,AuthRequestJmsDto>();

    public void addRequest( IsoMsgKey uniqueKey, AuthRequestJmsDto authRequestJmsDto )
    {
        log.trace( "addRequest()" );

        requestsMap.put( uniqueKey, authRequestJmsDto );
    }

    public Optional<AuthRequestJmsDto> getRequestObject(IsoMsgKey uniqueKey )
    {
        log.trace( "getRequestObject()" );

        return Optional.of( requestsMap.get( uniqueKey ) );
    }

    public void removeRequestObject(IsoMsgKey uniqueKey ) throws KeyNotFoundException
    {
        log.trace( "removeRequestObject()" );

        if( !requestsMap.containsKey(uniqueKey) )
            throw new KeyNotFoundException();

        requestsMap.remove( uniqueKey );
    }

}
