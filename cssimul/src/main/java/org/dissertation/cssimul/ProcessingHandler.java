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

import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;
import lombok.extern.slf4j.Slf4j;
import org.dissertation.cssimul.exceptions.UnexpectedRequestMessage;
import org.dissertation.cssimul.isomsg.IsoMsgParser;
import org.dissertation.cssimul.isomsg.IsoRequestMessageDto;
import org.dissertation.cssimul.isomsg.IsoResponseFromRequest;
import org.dissertation.cssimul.isomsg.IsoResponseMessageDto;
import org.dissertation.cssimul.responsesdb.ResponseKey;
import org.dissertation.iso8583.IsoGenerator;

import java.util.Date;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadPoolExecutor;

@Slf4j
public class ProcessingHandler extends ChannelInboundHandlerAdapter
{
    @Override
    public void handlerAdded(ChannelHandlerContext ctx) throws Exception
    {
        log.trace( "ProcessingHandler.handlerAdded()" );

        // Nothing to do
    }

    @Override
    public void handlerRemoved(ChannelHandlerContext ctx) throws Exception
    {
        log.trace( "ProcessingHandler.handlerRemoved()" );

        // Nothing to do
    }

    @Override
    public void channelRegistered(ChannelHandlerContext ctx) throws Exception
    {
        log.trace( "ProcessingHandler.channelRegistered()" );

        // Nothing to do
    }

    @Override
    public void channelUnregistered(ChannelHandlerContext ctx) throws Exception
    {
        log.trace( "ProcessingHandler.channelUnregistered()" );

        // Nothing to do
    }

    @Override
    public void channelActive(ChannelHandlerContext ctx) throws Exception
    {
        log.trace( "ProcessingHandler.channelActive()" );

        // Nothing to do
    }

    @Override
    public void channelInactive(ChannelHandlerContext ctx) throws Exception
    {
        log.trace( "ProcessingHandler.channelInactive()" );

        // Nothing to do
    }

    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception
    {
        log.trace( "ProcessingHandler.channelRead()" );


        simulateDelayAndSendResponse(ctx, msg);

        //ChannelFuture future = ctx.writeAndFlush(resp);
        //future.addListener(ChannelFutureListener.CLOSE);
    }

    private static ThreadPoolExecutor executor =
            (ThreadPoolExecutor) Executors.newFixedThreadPool(50 * 5 /* overestimated TPS * average response delay in seconds */ );

    private static void simulateDelayAndSendResponse(ChannelHandlerContext ctx, Object msg) throws InterruptedException
    {
        executor.execute(() -> {
            var t1 = new Date();

            try {

                IsoRequestMessageDto readMsg = (IsoRequestMessageDto) msg;

                var isoMessage = IsoMsgParser.getParser().parse(readMsg.getRawIsoMessage());

                var msgKey = new ResponseKey(
                        isoMessage.getMessageType().asString(),
                        isoMessage.getElement(42).asString(),     // Merchant Id
                        isoMessage.getElement(41).asString(),     // Termid
                        Integer.parseInt(isoMessage.getElement(11).asString()),     // STAN
                        Integer.parseInt(isoMessage.getElement(4).asString()),      // Amount
                        Short.parseShort(isoMessage.getElement(24).asString())        // Function Code
                );

                log.info( "Request received with key: {}", msgKey );

                var respData = CssimulApplication.getResponsesDb().get( msgKey );

                if (respData == null)
                    throw new UnexpectedRequestMessage(isoMessage);

                // Wait for the specified delay time (in milliseconds)
                log.debug("About to simulate delay of {} ms", respData.getResponseDelay());

                try {
                    Thread.sleep(respData.getResponseDelay());
                } catch (InterruptedException e) {
                    log.warn("{} exception caught during Thread.sleep() with message: {}. It will be ignored.", e.getClass().getName(), e.getMessage());
                }

                // Generate the response
                var isoRespMsg = IsoResponseFromRequest.generate(isoMessage, "1110");
                var formattedAuthCode = "000000" + respData.getAuthCode();
                formattedAuthCode = formattedAuthCode.substring(formattedAuthCode.length() - 6);
                isoRespMsg.setElement(38, formattedAuthCode);
                isoRespMsg.setElement(39, String.format("%03d", Short.parseShort(respData.getActionCode())));

                IsoGenerator isoGenerator = new IsoGenerator();
                IsoResponseMessageDto resp = new IsoResponseMessageDto();
                resp.setRawIsoMessage(isoGenerator.generateIsoMsg(isoRespMsg));


                var t2 = new Date();

                // TODO: calculate response time and update statistics

                ctx.writeAndFlush(resp);
                log.info( "Response sent. Delay: {} ms / writeAndFlush(): {} ms", t2.getTime() - t1.getTime(), new Date().getTime() - t2.getTime() );
            }
            catch( Exception ex )
            {
                log.error( "Error. Exception {} caught while executing ProcessingHandler with message: {}. The message will be discarded.", ex.getClass().getName(), ex.getMessage(), ex );

                // do nothing
            }
        });
    }


    @Override
    public void channelReadComplete(ChannelHandlerContext ctx) throws Exception
    {
        log.trace( "ProcessingHandler.channelReadComplete()" );

        // Nothing to do
    }

    @Override
    public void userEventTriggered(ChannelHandlerContext ctx, Object evt) throws Exception
    {
        log.trace( "ProcessingHandler.userEventTriggered()" );

        // Nothing to do
    }

    @Override
    public void channelWritabilityChanged(ChannelHandlerContext ctx) throws Exception
    {
        log.trace( "ProcessingHandler.channelWritabilityChanged()" );

        // Nothing to do
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception
    {
        log.trace( "ProcessingHandler.exceptionCaught()" );

        log.error( "Error. Exception {} caught while executing ProcessingHandler with message: {}.", cause.getClass().getName(), cause.getMessage(), cause );
    }
}
