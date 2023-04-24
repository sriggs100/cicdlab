use experiment;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE terminal;
TRUNCATE TABLE merchant_terminals;
SET FOREIGN_KEY_CHECKS = 1;

drop procedure if exists createTerminals;

DELIMITER //
CREATE PROCEDURE createTerminals()
BEGIN
DECLARE merchantIdx INT DEFAULT 1000000;
DECLARE terminalsQty INT DEFAULT 0;
DECLARE terminalsId INT DEFAULT 1000000;


SET FOREIGN_KEY_CHECKS = 0;
ALTER TABLE terminal ENABLE KEYS;
ALTER TABLE merchant_terminals ENABLE KEYS;

START TRANSACTION;

WHILE (merchantIdx < 1300000) DO

    -- For each merchant, create a random number of terminals
    SET terminalsQty = FLOOR(RAND()*(5-1+1)+1);

    WHILE( terminalsQty > 0 )
    DO
        -- Create terminal record
        INSERT INTO terminal( id, terminal_id, merchant_id ) VALUES( terminalsId, CONCAT( "T", terminalsId ), merchantIdx );

        -- Create merchant_terminals record
        INSERT INTO merchant_terminals( merchant_id, terminals_id ) VALUES( merchantIdx, terminalsId );

        SET terminalsQty = terminalsQty - 1;
        SET terminalsId = terminalsId + 1;

    END WHILE;

    SET merchantIdx = merchantIdx + 1;

    if( (merchantIdx % 5000) = 0 )
    THEN
        SELECT terminalsId;

        COMMIT;
        START TRANSACTION;
    END IF;

END WHILE;

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE terminal ENABLE KEYS;
ALTER TABLE merchant_terminals ENABLE KEYS;

END;
//
DELIMITER ;

SET @@session.sql_log_bin=0;
CALL createTerminals();
SET @@session.sql_log_bin=1;