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

import org.dissertation.acqrestproxy.dtos.AuthRequestDto;
import org.dissertation.acqrestproxy.dtos.RawIsoMessage;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.DirtiesContext;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@DirtiesContext
public class AuthRequestServiceTest
{
    @Autowired
    AuthRequestService authRequestService;

    @Test
    public void whenResponseArrivesOnTime_thenRepliesResponse()
    {
        var msg = new AuthRequestDto();
        msg.setRawIsoMessage( TestUtils.rawRequestMsg );

        Optional<RawIsoMessage> resp = authRequestService.request( msg );

        assertThat( resp ).isPresent();
        assertThat( resp.get().getRawIsoMessage() ).containsExactly( TestUtils.rawResponseMsg );
    }

    @Test
    public void whenLateResponseArrives_thenRepliesTimeout()
    {
        var msg = new AuthRequestDto();
        msg.setRawIsoMessage(TestUtils.rawLateResponseRequestMsg);

        Optional<RawIsoMessage> resp = authRequestService.request( msg );

        assertThat( resp ).isEmpty();
    }

    @Test
    public void whenResponseNeverArrives_thenRepliesTimeout()
    {
        var msg = new AuthRequestDto();
        msg.setRawIsoMessage(TestUtils.rawNoResponseRequestMsg);

        Optional<RawIsoMessage> resp = authRequestService.request( msg );

        assertThat( resp ).isEmpty();
    }
}
