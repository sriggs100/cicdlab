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

package org.dissertation.acqsimul.services;

import org.dissertation.acqsimul.TestMsgUtils;
import org.dissertation.acqsimul_db.services.DbStorageService;
import org.dissertation.iso8583.IsoMsgDefinition;
import org.dissertation.iso8583.IsoParser;
import org.dissertation.isomsgs.AuthRequestMsgDef;
import org.dissertation.transaction.TransactionDto;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.LinkedList;
import java.util.UUID;

import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@SpringBootTest
public class StorageServiceTest
{
    @Mock
    DbStorageService mockDbStorageService;

    @InjectMocks
    StorageService mockedStorageService;

    @Autowired
    StorageService storageService;


    private static final IsoParser isoParser = new IsoParser(new LinkedList<IsoMsgDefinition>() {{ add(new AuthRequestMsgDef()); }} );

    @Test
    public void givenRepositoryObject_whenValidIsoMessageReceived_thenInsertMethosIsInvoked() throws Exception
    {
        var isoMessage = isoParser.parse( TestMsgUtils.rawIsoMsg );

        when( mockDbStorageService.insertRecord( any(TransactionDto.class) ) )
                .thenReturn( true );

        assertThat( mockedStorageService.insertRecord(UUID.randomUUID().toString(), isoMessage) ).isTrue();

        verify(mockDbStorageService, times( 1 ) ).insertRecord( any( TransactionDto.class) );
    }

}
