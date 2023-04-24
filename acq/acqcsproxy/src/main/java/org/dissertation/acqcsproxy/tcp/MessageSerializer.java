package org.dissertation.acqcsproxy.tcp;

import lombok.extern.slf4j.Slf4j;
import org.springframework.core.serializer.Serializer;

import java.io.IOException;
import java.io.OutputStream;
import java.util.HexFormat;

@Slf4j
public class MessageSerializer implements Serializer<TcpMessage>
{
    @Override
    public void serialize(TcpMessage msgObject, OutputStream outputStream) throws IOException
    {
        byte[] lenHeader = new byte[2];
        lenHeader[0] = (byte)( (msgObject.isoMsg.length >>> 8) & 0xFF );
        lenHeader[1] = (byte)(msgObject.isoMsg.length & 0xFF);

        log.debug( String.format( "About to write message len: %02x%02x", lenHeader[0], lenHeader[1] ) );

        outputStream.write(lenHeader);

        log.debug( "About to write message: {}}", HexFormat.of().formatHex(msgObject.isoMsg) );

        outputStream.write(msgObject.isoMsg);
    }
}
