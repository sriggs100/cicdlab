package org.dissertation.acqcsproxy.tcp;

import org.springframework.integration.annotation.MessagingGateway;

@MessagingGateway( defaultRequestChannel = "masterCardOutboundChannel")
public interface MasterCardClientGateway
{
    void send(TcpMessage out);
}
