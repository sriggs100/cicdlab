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

package org.dissertation.acqsimul;

import lombok.extern.slf4j.Slf4j;
import org.dissertation.acqsimul.jms.JmsErrorHandler;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.autoconfigure.jms.DefaultJmsListenerContainerFactoryConfigurer;
import org.springframework.context.annotation.Bean;
import org.springframework.jms.annotation.EnableJms;
import org.springframework.jms.config.DefaultJmsListenerContainerFactory;
import org.springframework.jms.config.JmsListenerContainerFactory;
import org.springframework.jms.support.converter.MappingJackson2MessageConverter;
import org.springframework.jms.support.converter.MessageConverter;
import org.springframework.jms.support.converter.MessageType;

import javax.annotation.PreDestroy;
import javax.jms.ConnectionFactory;

// Use the following command-line arguments to override application.properties
// --spring.config.location=file:///d:/TMP/acqsimul.properties

@Slf4j
@EnableJms
@SpringBootApplication( scanBasePackages = { "org.dissertation.acqsimul", "org.dissertation.acqsimul_db.services" } )
@EntityScan("org.dissertation.acqsimul_db.model")
public class AcqsimulApplication {

	public static void main(String[] args)
	{
		SpringApplication springApplication =
				new SpringApplication(AcqsimulApplication.class);
		springApplication.addListeners(new BuiltInEventsListener());
		springApplication.run(args);
	}


	@Bean
	public JmsListenerContainerFactory<?> listenerFactory(ConnectionFactory connectionFactory,
														  DefaultJmsListenerContainerFactoryConfigurer configurer)
	{
		DefaultJmsListenerContainerFactory factory = new DefaultJmsListenerContainerFactory();
		factory.setErrorHandler( new JmsErrorHandler() );

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

	@PreDestroy
	public void onExit()
	{
		log.info( "Acqsimul is EXITING" );
	}
}
