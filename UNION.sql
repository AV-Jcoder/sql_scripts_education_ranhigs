/**
 * 
 * Демонстрация работы 
 * предиката UNION и UNION ALL
 * 
 * UNION - при слиянии группирует одинаковые строки.
 * 
 * UNION ALL - при  слиянии не группирует одинаковые строки.
 *  
 */

DROP TABLE staff,clients;
TRUNCATE staff, clients;

CREATE TABLE staff(
	id serial,
	first_name varchar,
	last_name varchar
);

CREATE TABLE clients(
	id serial,
	first_name varchar,
	last_name varchar,
	balance decimal
); 

INSERT INTO staff(first_name, last_name)
VALUES 	('Ivan','Ivanov'),
		('Fedor','Fedorov');

INSERT INTO clients(first_name, last_name, balance)
VALUES 	('Ivan','Ivanov', 1000),
		('Fedor','Fedorov',2000),
		('Stepan', 'Stepanov',500);	
	

	
SELECT *
FROM staff;

SELECT * 
FROM clients ;

SELECT first_name, last_name
FROM staff
	UNION
SELECT first_name, last_name
FROM clients;

SELECT first_name, last_name
FROM staff
	UNION ALL
SELECT first_name, last_name
FROM clients;




















