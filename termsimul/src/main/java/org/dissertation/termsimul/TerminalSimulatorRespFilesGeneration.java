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

package org.dissertation.termsimul;

import lombok.Getter;
import org.dissertation.termsimul.utils.OutputReport;

import java.io.IOException;
import java.util.Date;

public class TerminalSimulatorRespFilesGeneration implements TerminalSimulator {
    private OutputReport outputReport;
    private int transactionCnt = 0;

    private enum CSVID { MSGTYPE(11), MERCHID(10), TERMID(17), STAN(16), AMOUNT(2),
        CARDSCHEME(6), FUNCTIONCODE(8), ACTIONCODE(0), AUTHCODE(4);

        CSVID(int val) {
            this.val = val;
        }
        @Getter
        private int val;
    }

    /**
     * This method is only used to generate response files. This is not part of the simulator that injects transactions into the system
     *
     * @param csvTransaction
     */
    @Override
    public void process(String[] csvTransaction ) throws Exception
    {

        // The following is a mock behaviour used to generate the response files for the card scheme simulators
        int respTime;
        if( Math.random() > 0.15 )
            respTime = (int)(Math.random() * 950 + 50); // Calculate response time randomly between 50ms and 1s
        else
            respTime = (int)(Math.random() * 5000 + 1000); // Calculate response time randomly between 1s and 6s

        outputReport.transactionProcessed( new Date(new Date().getTime() - respTime), new Date(), csvTransaction[CSVID.MSGTYPE.getVal()]
                ,csvTransaction[CSVID.MERCHID.getVal()],csvTransaction[CSVID.TERMID.getVal()],csvTransaction[CSVID.STAN.getVal()]
                ,csvTransaction[CSVID.AMOUNT.getVal()],csvTransaction[CSVID.CARDSCHEME.getVal()]
                ,csvTransaction[CSVID.FUNCTIONCODE.getVal()],csvTransaction[CSVID.ACTIONCODE.getVal()]
                ,csvTransaction[CSVID.AUTHCODE.getVal()]);

    }

    @Override
    public void printReport() throws IOException
    {
        outputReport.printStatistics();
    }

    @Override
    public void setReport(OutputReport outputReport)
    {
        this.outputReport = outputReport;
    }

    @Override
    public void init(int tpsPerInstance, int socketResponseTimeout, int transactionResponseTimeout)
    {
        // Do nothing
    }

    @Override
    public boolean getErrorCondition() {
        return false;
    }

    @Override
    public void waitForAllThreads()
    {
        // Do nothing
    }
}
