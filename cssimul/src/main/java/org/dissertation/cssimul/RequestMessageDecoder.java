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

package org.dissertation.cssimul;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.ReplayingDecoder;
import lombok.extern.slf4j.Slf4j;
import org.dissertation.cssimul.isomsg.IsoRequestMessageDto;

import java.util.List;

@Slf4j
public class RequestMessageDecoder extends ReplayingDecoder<IsoRequestMessageDto>
{
    @Override
    protected void decode(ChannelHandlerContext ctx, ByteBuf in, List<Object> out) throws Exception
    {
        log.trace( "RequestMessageDecoder.decode()" );

        byte lenHi = in.readByte();
        byte lenLow = in.readByte();

        int len = (0xFF & lenHi) * 0x100 + (0xFF & lenLow);

        log.debug( "Incoming message length: {}", len );

        byte isoRawMsg[] = new byte[len];
        in.readBytes( isoRawMsg,0, len);

        IsoRequestMessageDto msg = new IsoRequestMessageDto();
        msg.setRawIsoMessage(isoRawMsg);

        log.debug( "Incoming message: {}", msg );

        out.add( msg );
    }
}
