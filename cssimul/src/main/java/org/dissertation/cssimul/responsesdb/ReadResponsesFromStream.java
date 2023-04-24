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

package org.dissertation.cssimul.responsesdb;

import lombok.extern.slf4j.Slf4j;

import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@Slf4j
public class ReadResponsesFromStream
{
    private static final int approxResponsesQty = 2_000_000;

    public static Map<ResponseKey, ResponseData> read( int cardScheme, BufferedReader br) throws IOException
    {
        var map = new HashMap<ResponseKey, ResponseData>(approxResponsesQty);

        String strLine;

        while( (strLine = br.readLine()) != null )
        {
            String response[] = strLine.split(",");

            if( Integer.parseInt(response[6]) == cardScheme )
            {
                // This is a response that belongs to our card scheme.
                Integer stan = Integer.parseInt(response[4]);
                Integer amount =  new BigDecimal(response[5]).multiply( BigDecimal.valueOf(100)).intValue();
                Short functionCode = Short.parseShort(response[7]);

                var key = new ResponseKey( response[1], response[2], response[3], stan, amount, functionCode );
                var value = new ResponseData( Short.parseShort(response[0]), response[8] /* Action Code */, response[9] /* Auth Code */ );
                map.put( key, value );

                // log.debug( "Response key={} / value={}", key, value );
            }

        }

        return map;
    }
}
