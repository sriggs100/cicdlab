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
import io.netty.handler.codec.MessageToByteEncoder;
import lombok.extern.slf4j.Slf4j;
import org.dissertation.cssimul.isomsg.IsoResponseMessageDto;

@Slf4j
public class ResponseMessageEncoder extends MessageToByteEncoder<IsoResponseMessageDto>
{

    @Override
    protected void encode(ChannelHandlerContext ctx, IsoResponseMessageDto msg, ByteBuf out) throws Exception
    {
        log.trace( "ResponseMessageEncoder.encode()" );

        int len = msg.getRawIsoMessage().length;

        byte lenHi = (byte)( (len >>> 8) & 0xFF );
        byte lenLow = (byte)(len & 0xFF);

        log.debug( String.format( "About to write message len: %02x%02x", lenHi, lenLow ) );

        out.writeByte( lenHi );
        out.writeByte( lenLow );

        log.debug( "About to write message: {}}", msg );

        out.writeBytes( msg.getRawIsoMessage() );
    }
}
