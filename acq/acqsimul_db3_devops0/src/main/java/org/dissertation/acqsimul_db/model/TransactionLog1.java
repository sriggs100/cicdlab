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


@Entity
@Getter
@Setter
@NoArgsConstructor
@Table( name = "transaction_log1",
        indexes = {
        @Index(name = "cardScheme1Idx",  columnList="cardScheme", unique = false),
        @Index(name = "functionCode1Idx", columnList="functionCode", unique = false),
        @Index(name = "utcCaptureDateTime1Idx", columnList="utcCaptureDateTime", unique = false)  },

        uniqueConstraints = {
                @UniqueConstraint(name = "UniqueMerchantTerminalStan1", columnNames = { "merchantId", "terminalId", "stan" }) })

public class TransactionLog1 extends TransactionLogSuper
{
    @Id
    @TableGenerator(name = "TransactionLogGenId", table= "jpa_sequences_table", pkColumnValue = "TransactionLog",initialValue = 130_000_000, allocationSize = 50)
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "TransactionLogGenId")
    @Column(name = "id", nullable = false)
    private Long id;

    /*
     * transaction_token NOT NULL UNIQUE column will be added to this table as part of the experiment
     */
    @Column(nullable = false, length = 36, unique = true)
    private String transactionToken;

    @OneToOne( cascade = CascadeType.ALL )
    @JoinColumn(name = "transaction_emv_data_id", nullable = false)
    TransactionEmvData1 transactionEmvData;

}
