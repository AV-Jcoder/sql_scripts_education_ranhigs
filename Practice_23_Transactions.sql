/**
 * 
 * от 08.10.2022
 * 
 * 
 * */

DROP TABLE IF EXISTS zakaz, udalen CASCADE;

CREATE TABLE IF NOT EXISTS zakaz(
	id_pk serial PRIMARY KEY,
	zakazchik varchar(50),
	tovar varchar(50) 
);

CREATE TABLE IF NOT EXISTS udalen (
	id_pk serial PRIMARY KEY,
	zak1 varchar(50),
	tov1 varchar(50),
	dat1 timestamp NOT NULL DEFAULT now()
);

INSERT INTO zakaz (zakazchik, tovar)
VALUES 	('Ivanov','Maslo'), 
		('Petrov','Svechi'),
		('Sidorov','Antifriz'),
		('Mikhailov','Remen');

SELECT * FROM zakaz;
	

CREATE OR REPLACE FUNCTION add_to_udalen()
RETURNS TRIGGER AS 
$$
BEGIN 
	INSERT INTO udalen SELECT OLD.*;
	RETURN OLD;
END;
$$ LANGUAGE plpgsql;
	

CREATE TRIGGER add_to_udalen_trigger
AFTER DELETE 
ON zakaz
FOR EACH ROW 
EXECUTE FUNCTION add_to_udalen();
	

SELECT * FROM udalen;
SELECT * FROM zakaz;

DELETE FROM zakaz AS za
WHERE za.zakazchik = 'Ivanov';
	
	
/**** Транзакции **************************/

CREATE TABLE accounts(
	id serial PRIMARY KEY,
	balance decimal CHECK (balance>=0)
);

DROP TABLE accounts;

INSERT INTO accounts 
VALUES (1,1000);
VALUES (2,1000);
VALUES (3,1000);


SELECT * FROM accounts;

-- read commited -- repeatable read -- serializable

SHOW transaction_isolation;
SHOW default_transaction_isolation;


BEGIN;	
	UPDATE accounts 
	SET balance=balance-500
	WHERE id=1;

	UPDATE accounts
	SET balance=balance+500
	WHERE id=2;
COMMIT; 
ROLLBACK;

/**********************************/

START TRANSACTION ISOLATION LEVEL SERIALIZABLE;	
	UPDATE accounts 
	SET balance=balance-500
	WHERE id=1;

	UPDATE accounts
	SET balance=balance+500
	WHERE id=2;
COMMIT; 
ROLLBACK;

/***********************************/
--Чтобы начать новую транзакцию со снимком данных, 
--который получила уже существующая транзакция, его 
--нужно сначала экспортировать из первой транзакции. 
--При этом будет получен идентификатор снимка, например:

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT pg_export_snapshot();
 pg_export_snapshot
---------------------
 00000003-0000001B-1
(1 row)

Затем этот идентификатор нужно передать команде SET TRANSACTION SNAPSHOT в начале новой транзакции:

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET TRANSACTION SNAPSHOT '00000003-0000001B-1';

















	
	
