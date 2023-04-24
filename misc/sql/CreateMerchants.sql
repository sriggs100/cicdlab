use experiment;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE terminal;
TRUNCATE TABLE merchant_terminals;
TRUNCATE TABLE merchant;
SET FOREIGN_KEY_CHECKS = 1;

DROP PROCEDURE IF EXISTS createMerchants;

DELIMITER //
CREATE PROCEDURE createMerchants()
BEGIN
DECLARE merchantIdx INT DEFAULT 1000000;

START TRANSACTION;

WHILE (merchantIdx < 1300000) DO
    INSERT INTO `merchant` ( id, merchant_id, name_and_location) values ( merchantIdx, CONCAT("LabMerch", merchantIdx), "INSURANCE LTD\Main Street\London\    E143GJ   UK" );
    SET merchantIdx = merchantIdx + 1;

    if( (merchantIdx % 10000) = 0 )
    THEN
        SELECT merchantIdx;

        COMMIT;
        START TRANSACTION;
    END IF;

END WHILE;

COMMIT;

END;
//

DELIMITER ;

SET @@session.sql_log_bin=0;
CALL createMerchants();
SET @@session.sql_log_bin=1;

