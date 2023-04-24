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

package org.dissertation.acqsimul_db.model;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;
import java.math.BigDecimal;
import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@MappedSuperclass
public abstract class TransactionLogSuper {

    /**
     * Record creation timestamp (UTC)
     */
    @Column(nullable = false, updatable = false)
    private Date utcCaptureDateTime = new Date();

    /**
     * For this experiment, the domain will be as follows:
     *
     *  1100    Authorization Request
     *  1110    Authorization Request Response
     *
     */
    @Column(nullable = false)
    private Short msgType;

    /**
     * Card number hash
     */
    @Column(nullable = false, length = 64)
    private String panHash;

    /**
     * Encrypted card number
     */
    @Column(nullable = false, length = 96)
    private String encryptedPan;


    /**
     * Card Scheme
     */
    public enum CardScheme { VISA, MASTERCARD };
    @Column(nullable = false)
    private CardScheme cardScheme;

    @Column(nullable = false)
    private Short panSequenceNumber;

    @Column(nullable = false, length = 6)
    private String procCode;

    @Column(nullable = false, scale = 2)
    private BigDecimal amount;

    @Column(nullable = false)
    private Integer stan;

    /**
     * UTC transaction date and time from terminal - format: YYMMDDhhmmss
     */
    @Column(nullable = false, length = 12)
    private String transactionDateTime;

    /**
     * Card expiration date (encrypted)
     */
    @Column(nullable = true, length = 96)
    private String encryptedExpiryDate;

    @Column(nullable = false, length = 12)
    private String pointOfServiceDataCode;

    /**
     * For this experiment, the domain will be as follows:
     *
     *  100    Credit Transaction
     *  200    Debit Transaction
     *
     */
    @Column(nullable = false)
    private Short functionCode;


    @Column(nullable = true)
    private Short reasonCode;

    @Column(nullable = false, length = 8)
    private String terminalId;

    @Column(nullable = false, length = 15)
    private String merchantId;

    @Column(nullable = false, length = 99)
    private String cardAcceptorNameAndLocation;

    @Column(nullable = true, length = 500)
    private String additionalData;

    @Column(nullable = true, length = 3)
    private String transactionCurrencyCode;

    @Column(nullable = true, length = 512)
    private String chipData;


    //
    //  Fields from acquirer's response message
    //

    @Column(length = 6)
    private String authorisationCode;

    /**
     * Response code
     */
    private Short actionCode;


    //
    // **********************  The following columns will be affected by teh experiment
    //

    /*
     *  applicationTransactionCounter (EMV Tag 9F36) is being created here in order to be migrated to
     *  TransactionEmvData as part of the experiment
     */
    @Column(nullable = true, length = 4)
    private String applicationTransactionCounter;

    /*
     * merchantCategoryCode column type will be changed to VARCHAR
     */
//    @Column(nullable = false)
//    private Short merchantCategoryCode;
    @Column(nullable = false, length = 4)
    private String merchantCategoryCode;

    public void setMerchantCategoryCode( Short merchantCategoryCode )
    {
        // This is just to maintain compatibility among the different schemas
        this.merchantCategoryCode = Short.toString(merchantCategoryCode);
    }

    public void setMerchantCategoryCode( String merchantCategoryCode )
    {
        this.merchantCategoryCode = merchantCategoryCode;
    }


    /*
     * transaction_token NOT NULL UNIQUE column will be added to this table as part of the experiment
     */
    @Transient
    //@Column(nullable = false, length = 36, unique = true)
    private String transactionToken;
}
