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

import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelOption;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import lombok.extern.slf4j.Slf4j;
import org.dissertation.cssimul.responsesdb.ReadResponsesFromStream;
import org.dissertation.cssimul.responsesdb.ResponseData;
import org.dissertation.cssimul.responsesdb.ResponseKey;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Map;


@Slf4j
public class CssimulApplication {

	private int tcpPort;
	private static Map<ResponseKey, ResponseData> responsesDb;

	public CssimulApplication(int port) {
		this.tcpPort = port;
	}

	public static void main(String[] args) throws InterruptedException, IOException
	{
		log.info( "Starting Card Scheme simulator" );

		if( args.length == 0 || args[0].equals("--help") )
		{
			System.err.println( "\n\tCommand-line arguments: <Card Scheme: 0 = Visa / 1 = MasterCard> [port number]\n\n\tCSV file containing responses to be read from stdin\n\n");
			System.exit( 1 );
		}

		int cardScheme = Integer.parseInt( args[0] );

		int port = 4900;
		if( args.length > 1 )
			port = Integer.parseInt(args[1]);


		var csSimulApp = new CssimulApplication(port);

		try	{
			csSimulApp.setResponsesDb(ReadResponsesFromStream.read(cardScheme, new BufferedReader(new InputStreamReader(System.in))));
		}
		catch( Exception ex )
		{
			log.error( "Error. Exception {} caught while reading from input file with message: {}. Exiting with error code 2.", ex.getClass().getName(), ex.getMessage(), ex );

			System.exit( 2 );
		}

		try {
			csSimulApp.process();
		}
		catch( Exception ex )
		{
			log.error( "Error. Exception {} caught while processing with message: {}. Exiting with error code 3.", ex.getClass().getName(), ex.getMessage(), ex );

			System.exit( 3 );
		}
		catch( OutOfMemoryError ex )
		{
			int errorCd = 4;
			log.error( "Error, exception {} caught. Details: {}. Exiting with error code {}", ex.getClass().getName(), ex.getMessage(), errorCd, ex );

			System.exit(errorCd);
		}
	}

	private void process() throws InterruptedException
	{
		log.info( "process() started. Listening on port {}", tcpPort );

		EventLoopGroup masterGroup = new NioEventLoopGroup(1);
		EventLoopGroup workerGroup = new NioEventLoopGroup();

		try
		{
			ServerBootstrap b = new ServerBootstrap();
			b.group(masterGroup, workerGroup)
				.channel(NioServerSocketChannel.class)
				.childHandler(new ChannelInitializer<SocketChannel>() {
					@Override
					public void initChannel(SocketChannel ch)
							throws Exception {
						ch.pipeline().addLast(
								new RequestMessageDecoder(),
								new ResponseMessageEncoder(),
								new ProcessingHandler());
					}
				}).option(ChannelOption.SO_BACKLOG, 100)
				.childOption(ChannelOption.SO_KEEPALIVE, true)
					.childOption( ChannelOption.TCP_NODELAY, true )
					.childOption( ChannelOption.AUTO_CLOSE, false )
				;

			ChannelFuture f = b.bind(tcpPort).sync();
			f.channel().closeFuture().sync();
		}
		finally
		{
			workerGroup.shutdownGracefully();
			masterGroup.shutdownGracefully();
		}

		log.info( "process() successfully finished" );
	}

	public static void setResponsesDb(Map<ResponseKey, ResponseData> responsesDb) {
		CssimulApplication.responsesDb = responsesDb;
	}

	public static Map<ResponseKey, ResponseData> getResponsesDb() {
		return responsesDb;
	}
}
