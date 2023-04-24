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

package org.dissertation.acqrestproxy.controllers;

import lombok.extern.slf4j.Slf4j;
import org.dissertation.acqrestproxy.dtos.AuthRequestDto;
import org.dissertation.acqrestproxy.dtos.AuthRequestRespDto;
import org.dissertation.acqrestproxy.dtos.RawIsoMessage;
import org.dissertation.acqrestproxy.services.AuthRequestService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;

import static org.springframework.http.MediaType.APPLICATION_JSON_VALUE;

@Slf4j
@RestController
@RequestMapping(path = {"api/v1/isomsg"}, produces = APPLICATION_JSON_VALUE)
public class TerminalsNetworkController
{
    private final AuthRequestService authRequestService;

    public TerminalsNetworkController( AuthRequestService authRequestService )
    {
        this.authRequestService = authRequestService;
    }


    @PostMapping(path = "/auth-request")
    public ResponseEntity<AuthRequestRespDto> authRequest(
            @Valid @RequestBody AuthRequestDto requestDto )
    {
        log.trace( "authRequest()" );

        var rawIsoMessageOpt = authRequestService.request( (RawIsoMessage)requestDto );
        if( rawIsoMessageOpt.isEmpty() )
        {
            log.debug( "About to respond NOT_FOUND (404)" );

            return ResponseEntity.notFound().build();
        }

        AuthRequestRespDto authRequestRespDto = new AuthRequestRespDto( rawIsoMessageOpt.get() );


        //Hateoas.addHateoasLinks( authRequestRespDto, startingDate );

        log.debug( "About to respond OK" );
        return ResponseEntity.ok(authRequestRespDto);
    }
}
