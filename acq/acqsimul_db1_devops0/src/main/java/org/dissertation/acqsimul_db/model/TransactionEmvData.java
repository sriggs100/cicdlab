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
@Table( name = "transaction_emv_data" )
@Getter
@Setter
@NoArgsConstructor
public class TransactionEmvData extends TransactionEmvDataSuper {
    @Id
    @TableGenerator(name = "TransactionEmvDataGenId", table= "jpa_sequences_table", pkColumnValue = "TransactionEmvData", initialValue = 130_000_000, allocationSize = 50)
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "TransactionEmvDataGenId")
    @Column(name = "id", nullable = false)
    private Long id;

    @OneToOne( mappedBy = "transactionEmvData" )
    @JoinColumn(name = "transaction_log_id", nullable = false)
    TransactionLog transactionLog;
}
