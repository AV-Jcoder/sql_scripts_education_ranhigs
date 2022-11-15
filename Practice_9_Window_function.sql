
/**
 * Группировка, агрегатные, оконные функции.
 * Лабораторная №9. * 
 */

DROP TABLE IF EXISTS staff;

CREATE TABLE IF NOT EXISTS staff (
	id serial PRIMARY KEY,
	name varchar,
	age int
);

INSERT INTO staff(name, age)
VALUES 
	('Алексей',34),
	('Алексей',23),
	('Виктор',51),
	('Виктор',53),
	('Виктор',42),
	('Светлана',28),
	('Светлана',22),
	('Светлана',30),
	('Любовь',25);

SELECT name, age
FROM staff;

SELECT name, avg(age)
FROM staff 
GROUP BY name;

SELECT *, avg(age) OVER ()
FROM staff
ORDER BY id;

SELECT *
FROM (SELECT name,age, avg(age) OVER (PARTITION BY name) AS avg_age
	 FROM staff) AS result
WHERE result.age>result.avg_age;

SELECT *, avg(age) OVER (PARTITION BY name ORDER BY age)
FROM staff;





	















