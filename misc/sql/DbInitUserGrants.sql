

CREATE DATABASE experiment CHARACTER SET utf8mb4;

CREATE USER 'admin-cicdlab'@'%' IDENTIFIED WITH mysql_native_password BY '<password>';

GRANT ALL PRIVILEGES ON experiment.* TO 'admin-cicdlab'@'%';
GRANT SESSION_VARIABLES_ADMIN ON *.* TO 'admin-cicdlab'@'%';
GRANT PROCESS, BINLOG_ADMIN ON *.* TO 'admin-cicdlab'@'%';
-- GRANT GRANT OPTION ON *.* TO 'admin-cicdlab'@'%';

FLUSH PRIVILEGES;

EXIT;


