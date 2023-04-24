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

package org.dissertation.termsimul.utils;

import org.dissertation.termsimul.statistics.Statistics;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.text.SimpleDateFormat;
import java.util.Date;

public class OutputReportFile
{
    private final int instanceId;

    private final Path processedFileName;
    private final Path lateResponseFileName;
    private final Path notRepliedFileName;
    private final Path failedFileName;
    private final Path badResponseFileName;
    private final Path statisticsFileName;

    public OutputReportFile(String outputDirName, int instanceId)
    {
        this.instanceId = instanceId;
        this.processedFileName = FileSystems.getDefault().getPath( outputDirName, "termsimul", String.format( "Processed_%d.txt", instanceId ) );
        this.lateResponseFileName = FileSystems.getDefault().getPath( outputDirName, "termsimul", String.format( "LateResponse_%d.txt", instanceId ) );
        this.notRepliedFileName = FileSystems.getDefault().getPath( outputDirName, "termsimul", String.format( "NotReplied_%d.txt", instanceId ) );
        this.failedFileName = FileSystems.getDefault().getPath( outputDirName, "termsimul", String.format( "Failed_%d.txt", instanceId ) );
        this.badResponseFileName = FileSystems.getDefault().getPath( outputDirName, "termsimul", String.format( "BadResponse_%d.txt", instanceId ) );
        this.statisticsFileName = FileSystems.getDefault().getPath( outputDirName, "termsimul", String.format( "Statistics_%d.txt", instanceId ) );
    }

    public void appendToOutProcessedFile(long responseTime, Date sent, Date received, String msgType, String merchId, String termId,
                                         String stan, String amount, String cardScheme, String functionCode, String actionCode, String authCode) throws IOException {
        Files.write(processedFileName,
                String.format( "%d,%s,%s,%s,%s,%s,%s,%s,%s,%s\n", responseTime, msgType, merchId, termId,
                        stan, amount, cardScheme, functionCode, actionCode, authCode ).getBytes(), StandardOpenOption.APPEND, StandardOpenOption.CREATE);
    }

    public void appendToOutLateResponseFile(long responseTime, Date sent, Date received, String msgType, String merchId, String termId, String stan, String amount, String cardScheme, String functionCode, String actionCode, String authCode) throws IOException {
        Files.write(lateResponseFileName,
                String.format( "%s,%d,%s,%s,%s,%s,%s,%s,%s,%s,%s\n", dateFmt.format(sent), responseTime, msgType, merchId, termId,
                        stan, amount, cardScheme, functionCode, actionCode, authCode ).getBytes(), StandardOpenOption.APPEND, StandardOpenOption.CREATE);
    }

    public void appendToOutNotRepliedFile(Date sent, String msgType, String merchId, String termId, String stan, String amount, String cardScheme, String functionCode) throws IOException {
        Files.write(notRepliedFileName,
                String.format( "%s,%s,%s,%s,%s,%s,%s,%s\n", dateFmt.format(sent), msgType, merchId, termId,
                        stan, amount, cardScheme, functionCode ).getBytes(), StandardOpenOption.APPEND, StandardOpenOption.CREATE);
    }

    public void appendToOutFailedFile(Date sent, String msgType, String merchId, String termId, String stan, String amount, String cardScheme, String functionCode, int statusCode) throws IOException {
        Files.write(failedFileName,
                String.format( "%s,%s,%s,%s,%s,%s,%s,%s,%d\n", dateFmt.format(sent), msgType, merchId, termId,
                        stan, amount, cardScheme, functionCode, statusCode ).getBytes(), StandardOpenOption.APPEND, StandardOpenOption.CREATE);
    }

    public void appendToBadResponseFile(long responseTime, Date sent, Date received,
               String merchId, String termId, String stan, String amount, String functionCode, String actionCode, String authCode,
               String expMerchId, String expTermId, String expStan, String expAmount, String expFunctionCode, String expActionCode, String expAuthCode                         ) throws IOException {
        Files.write(badResponseFileName,
                String.format( "%s,%d,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n", dateFmt.format(sent), responseTime,
                        merchId, termId, stan, amount, functionCode, actionCode, authCode,
                        expMerchId, expTermId, expStan, expAmount, expFunctionCode, expActionCode, expAuthCode
                ).getBytes() , StandardOpenOption.APPEND, StandardOpenOption.CREATE);
    }

    public void appendToOutStatisticsFile(Statistics statistics) throws IOException {
        Files.write(statisticsFileName,
                String.format( "%s\n", statistics.toString() ).getBytes(), StandardOpenOption.APPEND, StandardOpenOption.CREATE);
    }

    private SimpleDateFormat dateFmt = new SimpleDateFormat( "yyyy-MM-dd HH:mm:ss.SSS" );
}
