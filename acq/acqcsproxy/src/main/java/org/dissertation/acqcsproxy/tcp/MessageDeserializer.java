package org.dissertation.acqcsproxy.tcp;

import lombok.extern.slf4j.Slf4j;
import org.springframework.core.serializer.Deserializer;

import java.io.IOException;
import java.io.InputStream;
import java.util.HexFormat;

@Slf4j
public class MessageDeserializer implements Deserializer<TcpMessage>
{
    @Override
    public TcpMessage deserialize(InputStream inputStream) throws IOException
    {
        byte[] lenBytes = inputStream.readNBytes(2);

        int len = (0xFF & lenBytes[0]) * 0x100 + (0xFF & lenBytes[1]);

        log.debug( String.format( "About to read message len: %02x%02x (%d)", 0xFF&lenBytes[0], 0xFF&lenBytes[1], len ) );

        var read = inputStream.readNBytes(len);

        log.debug( "Message received from socket: {}}", HexFormat.of().formatHex(read) );

        return new TcpMessage( read );
    }
}
