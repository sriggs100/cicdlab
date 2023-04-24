package org.dissertation.acqcsproxy.tcp;

import org.springframework.integration.annotation.MessagingGateway;

@MessagingGateway( defaultRequestChannel = "visaOutboundChannel")
public interface VisaClientGateway
{
    void send(TcpMessage out);
}
