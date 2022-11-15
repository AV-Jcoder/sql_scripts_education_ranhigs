/**
 * Практическая работа №6 
 * 06.09.2022
 */
 
CREATE ROLE alex WITH nosuperuser login PASSWORD 'qwerty';

CREATE ROLE user1 WITH nosuperuser login PASSWORD 'qwerty';

CREATE DATABASE alexdb OWNER alex;

CREATE SCHEMA alex AUTHORIZATION alex;

DROP SCHEMA alex;

SELECT current_user;

DROP TABLE myfirsttable;
CREATE TABLE myfirsttable();

SHOW search_path;

SET search_path TO "$user",public; --установка пути создания/поиска по умолчанию,
SET search_path TO public,"$user"; -- в нужном нам порядке.


GRANT ALL ON ALL TABLES IN SCHEMA alex to user1;

GRANT USAGE ON ALL TABLES IN SCHEMA alex to user1;

/***************/




