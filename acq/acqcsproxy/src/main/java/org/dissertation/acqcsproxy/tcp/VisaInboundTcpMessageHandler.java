package org.dissertation.acqcsproxy.tcp;

import lombok.extern.slf4j.Slf4j;
import org.dissertation.acqcsproxy.jms.JmsProducer;
import org.dissertation.acqcsproxy.services.RequestsManagerService;
import org.springframework.context.event.EventListener;
import org.springframework.integration.ip.tcp.connection.TcpConnectionCloseEvent;
import org.springframework.integration.ip.tcp.connection.TcpConnectionOpenEvent;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class VisaInboundTcpMessageHandler extends InboundTcpMessageHandler
{
    public VisaInboundTcpMessageHandler(JmsProducer jmsProducer, RequestsManagerService requestsManagerService) {
        super(jmsProducer, requestsManagerService);
    }

    public void incomingMsg(TcpMessage in)
    {
        log.trace( "Visa incoming Msg" );

        log.debug( "received: {}", in);

        super.incomingMsg( in );
    }

    @EventListener
    public void opens(TcpConnectionOpenEvent event)
    {
        log.info( "Visa opens() / event={}", event );
    }

    @EventListener
    public void closes(TcpConnectionCloseEvent event)
    {
        log.info( "Visa closes() / event={}", event );
    }

}
