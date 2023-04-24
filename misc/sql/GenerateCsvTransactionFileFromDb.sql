

SET @old_sql_mode=@@sql_mode;
SET @@sql_mode=PIPES_AS_CONCAT;

DROP PROCEDURE IF EXISTS sp_create_transactions_file1;

DELIMITER //
CREATE PROCEDURE sp_create_transactions_file1()
BEGIN
    -- CSV Header
    SELECT
        "action_code" || "," ||
        " additional_data" || "," ||
        " amount" || "," ||
        " application_transaction_counter" || "," ||
        " authorisation_code" || "," ||
        " card_acceptor_name_and_location" || "," ||
        " card_scheme" || "," ||
        " chip_data" || "," ||
        " function_code" || "," ||
        " merchant_category_code" || "," ||
        " merchant_id" || "," ||
        " msg_type" || "," ||
        " pan_sequence_number" || "," ||
        " point_of_service_data_code" || "," ||
        " proc_code" || "," ||
        " reason_code" || "," ||
        " stan" || "," ||
        " terminal_id" || "," ||
        " transaction_currency_code" || "," ||
        " transaction_date_time" || "," ||
        " transaction_emv_data_id" AS HEADER;

    SELECT
        COALESCE( `action_code`, "" ) || "," ||
        COALESCE( `additional_data`, "" ) || "," ||
        COALESCE( `amount`, "" ) || "," ||
        COALESCE( `application_transaction_counter`, "" ) || "," ||
        COALESCE( `authorisation_code`, "" ) || "," ||
        COALESCE( `card_acceptor_name_and_location`, "" ) || "," ||
        COALESCE( `card_scheme`, "" ) || "," ||
        COALESCE( `chip_data`, "" ) || "," ||
        COALESCE( `function_code`, "" ) || "," ||
        COALESCE( `merchant_category_code`, "" ) || "," ||
        COALESCE( `merchant_id`, "" ) || "," ||
        COALESCE( `msg_type`, "" ) || "," ||
        COALESCE( `pan_sequence_number`, "" ) || "," ||
        COALESCE( `point_of_service_data_code`, "" ) || "," ||
        COALESCE( `proc_code`, "" ) || "," ||
        COALESCE( `reason_code`, "" ) || "," ||
        COALESCE( `stan`, "" ) || "," ||
        COALESCE( `terminal_id`, "" ) || "," ||
        COALESCE( `transaction_currency_code`, "" ) || "," ||
        COALESCE( `transaction_date_time`, "" ) || "," ||
        COALESCE( `transaction_emv_data_id`, "" ) AS CSV_RECORD
    FROM `transaction_log`
    WHERE id > 129499965 AND ( merchant_id like "%1" OR  merchant_id like "%2" OR  merchant_id like "%3" OR  merchant_id like "%4" OR merchant_id like "%5" );

END;
//
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_create_transactions_file2;

DELIMITER //
CREATE PROCEDURE sp_create_transactions_file2()
BEGIN
    -- CSV Header
    SELECT
        "action_code" || "," ||
        " additional_data" || "," ||
        " amount" || "," ||
        " application_transaction_counter" || "," ||
        " authorisation_code" || "," ||
        " card_acceptor_name_and_location" || "," ||
        " card_scheme" || "," ||
        " chip_data" || "," ||
        " function_code" || "," ||
        " merchant_category_code" || "," ||
        " merchant_id" || "," ||
        " msg_type" || "," ||
        " pan_sequence_number" || "," ||
        " point_of_service_data_code" || "," ||
        " proc_code" || "," ||
        " reason_code" || "," ||
        " stan" || "," ||
        " terminal_id" || "," ||
        " transaction_currency_code" || "," ||
        " transaction_date_time" || "," ||
        " transaction_emv_data_id" AS HEADER;

    SELECT
        COALESCE( `action_code`, "" ) || "," ||
        COALESCE( `additional_data`, "" ) || "," ||
        COALESCE( `amount`, "" ) || "," ||
        COALESCE( `application_transaction_counter`, "" ) || "," ||
        COALESCE( `authorisation_code`, "" ) || "," ||
        COALESCE( `card_acceptor_name_and_location`, "" ) || "," ||
        COALESCE( `card_scheme`, "" ) || "," ||
        COALESCE( `chip_data`, "" ) || "," ||
        COALESCE( `function_code`, "" ) || "," ||
        COALESCE( `merchant_category_code`, "" ) || "," ||
        COALESCE( `merchant_id`, "" ) || "," ||
        COALESCE( `msg_type`, "" ) || "," ||
        COALESCE( `pan_sequence_number`, "" ) || "," ||
        COALESCE( `point_of_service_data_code`, "" ) || "," ||
        COALESCE( `proc_code`, "" ) || "," ||
        COALESCE( `reason_code`, "" ) || "," ||
        COALESCE( `stan`, "" ) || "," ||
        COALESCE( `terminal_id`, "" ) || "," ||
        COALESCE( `transaction_currency_code`, "" ) || "," ||
        COALESCE( `transaction_date_time`, "" ) || "," ||
        COALESCE( `transaction_emv_data_id`, "" ) AS CSV_RECORD
    FROM `transaction_log`
    WHERE id > 129499965 AND ( merchant_id like "%6" OR  merchant_id like "%7" OR  merchant_id like "%8" OR  merchant_id like "%9" OR merchant_id like "%0" );

END;
//
DELIMITER ;

SET @@sql_mode=@old_sql_mode;

-- To be executed from a shell script
mysql <<END | grep -v -E "CALL|HEADER|CSV_RECORD" > transactions_file1.csv
CALL sp_create_transactions_file1;
END

mysql <<END |grep -v -E "CALL|HEADER|CSV_RECORD" > transactions_file2.csv
CALL sp_create_transactions_file2;
END

