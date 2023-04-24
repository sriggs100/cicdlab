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

package org.dissertation.transaction;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
public class TransactionDto
{
    private Long id;
    private Date utcCaptureDateTime;
    private Short msgType;
    private String panHash;
    private String encryptedPan;
    public enum CardScheme { VISA, MASTERCARD };
    private CardScheme cardScheme;
    private Short panSequenceNumber;
    private String procCode;
    private BigDecimal amount;
    private Integer stan;
    private String transactionDateTime;
    private String encryptedExpiryDate;
    private String pointOfServiceDataCode;
    private Short functionCode;
    private Short reasonCode;
    private String terminalId;
    private String merchantId;
    private String cardAcceptorNameAndLocation;
    private String additionalData;
    private String transactionCurrencyCode;
    private String chipData;
    private String authorisationCode;
    private Short actionCode;
    private Short merchantCategoryCode;
    private String transactionToken;

    private String applicationExpirationDate;

    private String interfaceDeviceSerialNumber;
    private byte[] terminalCapabilities;
    private String applicationTransactionCounter;
}
