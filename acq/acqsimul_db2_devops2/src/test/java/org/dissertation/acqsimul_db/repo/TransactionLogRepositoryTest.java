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

package org.dissertation.acqsimul_db.repo;

import org.assertj.core.api.Assertions;
import org.dissertation.EntityTestUtils;
import org.dissertation.acqsimul.repo.TransactionLogRepository;
import org.dissertation.acqsimul_db.model.TransactionLog;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.AutoConfigureTestEntityManager;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.transaction.annotation.Transactional;

import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@AutoConfigureTestEntityManager
public class TransactionLogRepositoryTest
{
    TransactionLog entity = EntityTestUtils.getNewTransactionLog();

    @Autowired
    TransactionLogRepository repo;

    public TransactionLogRepositoryTest() throws Exception
    {
    }

    @Test
    @Transactional
    public void whenInserted_thenTheNewRecordCanBeRetrieved()
    {
        TransactionLog record = repo.save( entity );

        Assertions.assertThat( repo.findById( record.getId() ) ).isPresent();
    }

    @Test
    @Transactional
    public void whenEmptyInserted_thenExceptionIsThrown()
    {
        TransactionLog emptyEntity = new TransactionLog();

        assertThatThrownBy(() -> {

            repo.save( emptyEntity );

            repo.flush();

        }).isInstanceOf(DataIntegrityViolationException.class);
    }

    @Autowired
    private TestEntityManager entityManager;

    @Test
    @Transactional
    public void whenRecordIsUpdated_thenUpdateMethodReturns1()
    {
        var record = entityManager.persist( entity );

        Assertions.assertThat( repo.update( (short)111, "abc123", entity.getMerchantId(), entity.getTerminalId(), entity.getStan() ) ).isEqualTo(1);
    }
}
