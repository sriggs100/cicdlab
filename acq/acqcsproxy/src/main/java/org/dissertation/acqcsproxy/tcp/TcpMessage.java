package org.dissertation.acqcsproxy.tcp;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.HexFormat;

@Data
@AllArgsConstructor
public class TcpMessage
{
    byte[] isoMsg;

    public String toString() {
        return "TcpMessage(isoMsg=" + HexFormat.of().formatHex(this.getIsoMsg()) + ")";
    }
}
