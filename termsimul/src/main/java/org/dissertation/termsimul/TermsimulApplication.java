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

import lombok.extern.slf4j.Slf4j;
import org.dissertation.termsimul.utils.OutputReport;
import org.dissertation.termsimul.utils.OutputReportFile;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Properties;

@Slf4j
public class TermsimulApplication
{
    final static int instances = 2;
    final static int transactionsPerDay = 3_700_000;
    static int tpsPerInstance = transactionsPerDay / 24 / 3600 / instances;
    static int delayPerTransaction = (int)((1.0/tpsPerInstance) * 1000); // milliseconds

    static int socketResponseTimeout = 16; // seconds
    static int transactionResponseTimeout = 15; // seconds

    static Integer transactionsLimit = null;

    /**
     * Receives a transaction file name and an instance id as a command-line argument
     *
     * @param args
     */
    public static void main(String[] args) throws IOException
    {
        log.info( "Starting Terminals simulator" );

        if( args.length == 0 || args[0].equals("--help") )
        {
            System.err.println( "\n\tCommand-line arguments: <input file name | \"-\" for stdin> <output dir> <instance id> [tps] [limit]");
            System.exit( 1 );
        }

        String inputFileName = args[0];
        String outputDirName = args[1];
        int instanceId = Integer.parseInt( args[2] );

        if( args.length > 3 )
        {
            tpsPerInstance = Integer.parseInt(args[3]);
            delayPerTransaction = (int) ((1.0 / tpsPerInstance) * 1000);
        }

        if( args.length > 4 )
            transactionsLimit = Integer.parseInt( args[4] );

        Properties props = new Properties();
        props.load( new InputStreamReader( TermsimulApplication.class.getClassLoader().getResourceAsStream( "config.properties" ) ));


        TerminalSimulator simulator = new TerminalSimulatorTxnInjector( props.getProperty( "acqsimul.uri" ) );
        //TerminalSimulator simulator = new TerminalSimulatorRespFilesGeneration();
        simulator.init( tpsPerInstance, socketResponseTimeout * 1000, transactionResponseTimeout * 1000);
        OutputReport ourReport = new OutputReport();
        ourReport.setOutputReportFile( new OutputReportFile( outputDirName, instanceId ));
        simulator.setReport( ourReport );

        int transactionsCnt = 0;
        try(  BufferedReader br = inputFileName.equals("-") ?
                new BufferedReader( new InputStreamReader(System.in) )
                : new BufferedReader( new FileReader(inputFileName)) )
        {

            String strLine;
            boolean isFirstLine = true;

            while( ((strLine = br.readLine()) != null) && ((transactionsLimit==null) || (transactionsCnt < transactionsLimit)) )
            {
                try
                {
                    // Ignore header line
                    if( !isFirstLine )
                    {
                        String transaction[] = strLine.split(",");

                        simulator.process(transaction);

                        // Don't send the first transactions with the maximum TPS to allow the system to warm-up.
                        if( transactionsCnt < 10 )
                            Thread.sleep(300);
                        else
                            Thread.sleep(delayPerTransaction);

                        transactionsCnt++;
                    }
                    else
                        isFirstLine = false;

                    if (simulator.getErrorCondition() == true)
                    {
                        log.error("Error condition detected. Aborting.");

                        break;
                    }
                }
                catch( Exception ex )
                {
                    log.error( "Error, exception {} caught. Details: {}. Ignored", ex.getClass().getName(), ex.getMessage(), ex );
                }
            }

            simulator.waitForAllThreads();
            simulator.printReport();

            int errorCd = simulator.getErrorCondition() == true ? 10 : 0;

            log.info( "Processing finished. Total transactions injected: {}. Exiting with error code {}", transactionsCnt, errorCd );

            System.exit( errorCd );
        }
        catch( Exception ex )
        {
            int errorCd = 3;
            log.error( "Error, exception {} caught. Details: {}. Exiting with error code {}", ex.getClass().getName(), ex.getMessage(), errorCd, ex );

            System.exit(errorCd);
        }
        catch( OutOfMemoryError ex )
        {
            int errorCd = 4;
            log.error( "Error, exception {} caught. Details: {}. Exiting with error code {}", ex.getClass().getName(), ex.getMessage(), errorCd, ex );

            System.exit(errorCd);
        }
    }
}
