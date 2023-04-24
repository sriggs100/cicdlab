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

package org.dissertation.acqcsproxy;

import lombok.extern.slf4j.Slf4j;
import org.dissertation.acqcsproxy.tcp.MessageDeserializer;
import org.dissertation.acqcsproxy.tcp.MessageSerializer;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jms.DefaultJmsListenerContainerFactoryConfigurer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.DependsOn;
import org.springframework.integration.dsl.IntegrationFlow;
import org.springframework.integration.dsl.IntegrationFlows;
import org.springframework.integration.ip.dsl.Tcp;
import org.springframework.integration.ip.tcp.connection.AbstractClientConnectionFactory;
import org.springframework.jms.annotation.EnableJms;
import org.springframework.jms.config.DefaultJmsListenerContainerFactory;
import org.springframework.jms.config.JmsListenerContainerFactory;
import org.springframework.jms.support.converter.MappingJackson2MessageConverter;
import org.springframework.jms.support.converter.MessageConverter;
import org.springframework.jms.support.converter.MessageType;

import javax.jms.ConnectionFactory;

// Use the following command-line arguments to override application.properties
// --spring.config.location=file:///d:/TMP/acqcsproxy.properties

@Slf4j
@EnableJms
@SpringBootApplication
public class AcqcsproxyApplication {

	public static void main(String[] args) throws Exception
	{
		log.info( "Starting acqcsproxy" );

		SpringApplication.run(AcqcsproxyApplication.class, args);
	}


	@Bean
	public JmsListenerContainerFactory<?> listenerFactory(ConnectionFactory connectionFactory,
														  DefaultJmsListenerContainerFactoryConfigurer configurer)
	{
		DefaultJmsListenerContainerFactory factory = new DefaultJmsListenerContainerFactory();

		factory.setTransactionManager(null);
		factory.setSessionTransacted(false);

		configurer.configure(factory, connectionFactory);

		return factory;
	}



	@Bean
	public MessageConverter jacksonJmsMessageConverter()
	{
		MappingJackson2MessageConverter converter = new MappingJackson2MessageConverter();
		converter.setTargetType(MessageType.TEXT);
		converter.setTypeIdPropertyName("_type");
		return converter;
	}

	@Value("${mastercard.hostname}")
	private String masterCardHostname;

	@Value("${mastercard.port}")
	private Integer masterCardPort;


	@Bean
	AbstractClientConnectionFactory masterCardClient()
	{
		log.trace( "masterCardClient()" );

		return Tcp.netClient(masterCardHostname, masterCardPort)
				.soTcpNoDelay(true)
				.singleUseConnections(false)
				.leaveOpen(true)
				.deserializer( new MessageDeserializer() )
				.serializer( new MessageSerializer() )
				.get();
	}

	@Value("${visa.hostname}")
	private String visaHostname;

	@Value("${visa.port}")
	private Integer visaPort;

	@Bean
	AbstractClientConnectionFactory visaClient()
	{
		log.trace( "visaClient()" );

		return Tcp.netClient(visaHostname, visaPort)
				.soTcpNoDelay(true)
				.singleUseConnections(false)
				.leaveOpen(true)
				.deserializer( new MessageDeserializer() )
				.serializer( new MessageSerializer() )
				.get();
	}


	@Bean
	IntegrationFlow masterCardInbound(@Qualifier("masterCardClient") AbstractClientConnectionFactory client)
	{
		log.trace("masterCardInbound()");

		return IntegrationFlows.from(Tcp.inboundAdapter(client))
				.handle("masterCardInboundTcpMessageHandler", "incomingMsg")
				.get();
	}

	@Bean
	IntegrationFlow masterCardOutbound( @Qualifier("masterCardClient") AbstractClientConnectionFactory client)
	{
		log.trace("masterCardOutbound()");

		return IntegrationFlows.from("masterCardOutboundChannel")
				.handle(Tcp.outboundAdapter(client))
				.get();
	}

	@Bean
	@DependsOn("masterCardOutbound")
	public ApplicationRunner masterCardRunner( @Qualifier("masterCardClient") AbstractClientConnectionFactory client)
	{
		log.trace("masterCardRunner()");

		return args -> {
			client.getConnection();
		};
	}


	@Bean
	IntegrationFlow visaInbound( @Qualifier("visaClient") AbstractClientConnectionFactory client)
	{
		log.trace("visaInbound()");

		return IntegrationFlows.from(Tcp.inboundAdapter(client))
				.handle("visaInboundTcpMessageHandler", "incomingMsg")
				.get();
	}

	@Bean
	IntegrationFlow visaOutbound( @Qualifier("visaClient") AbstractClientConnectionFactory client)
	{
		log.trace("visaOutbound()");

		return IntegrationFlows.from("visaOutboundChannel")
				.handle(Tcp.outboundAdapter(client))
				.get();
	}

	@Bean
	@DependsOn("visaOutbound")
	public ApplicationRunner visaRunner( @Qualifier("visaClient") AbstractClientConnectionFactory client)
	{
		log.trace("visaRunner()");

		return args -> {
			client.getConnection();
		};
	}

}
