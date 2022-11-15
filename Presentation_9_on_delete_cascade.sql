/***********************************/
SELECT current_user;
SET search_path TO public;
SHOW search_path;
/***********************************/

/**
 * Презентация 9. Связи.
 * Отношения. Сохранение цельности. стр.10 * 
 * 1. Вопрос: name и "name" - для чего экранировать кавычками? ()
 * 2. Вопрос: Таблица pupils не указано на какой ключ ссылается поле class, а только таблица.
 * 3. Вопрос: изменения поведения внешнего ключа с on delete на 
 *    on action или restrict или set null или set default.
 * 	 Как это сделать? 
 *    Посмотреть поведение данных, сделав запросы.
 * 
 * 4. Разобрать запрос на стр.9,  || - конкатенация? Форма Бэкуса Науэра През№5,стр3 такого небыло.
 * 5. Где можно узнать про эти спец символы?
 * 
 * 6. Презентация 6. Иерархия метаданных в БД (БД - каталог - схема - таблица - аттрибуты)
 * 	Что такое каталог и где он?
 * 
 * 7. Если будет время разобрать запрос из учебника Рогова по демобазе там тоже спецсимволы :: ?
 */

DROP TABLE IF EXISTS pupils;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS specializations;
TRUNCATE TABLE specializations;

CREATE TABLE specializations (
    spec_id integer PRIMARY KEY,
    name varchar    
);

INSERT INTO specializations (spec_id, name)
VALUES (1, 'гуманитарный'),
       (2, 'физ-мат'),
       (3, 'естественный');
       
CREATE TABLE classes (
    class_id int PRIMARY KEY,
    name varchar,
    spec int REFERENCES specializations ON DELETE set default --SET NULL	--CASCADE ON UPDATE CASCADE
);

INSERT INTO classes (class_id, name, spec)
VALUES	(1,'7а',1),
		(2,'7б',1),
		(3,'8а',2),
		(4,'8б',2),
		(5,'9а',3),
		(6,'9б',3);

CREATE TABLE pupils(
    pupil_id int PRIMARY KEY,
    "name" varchar,
    "class" int REFERENCES classes ON DELETE set default -- SET NULL  --CASCADE ON UPDATE CASCADE
);

INSERT INTO pupils (pupil_id,"name","class")
VALUES	( 1,'Ваня',1),
		( 2,'Петя',1),
		( 3,'Маша',2),
		( 4,'Коля',2),
		( 5,'Соня',3),
		( 6,'Женя',3),
		( 7,'Вася',4),
		( 8,'Ася',4),
		( 9,'Саша',5),
		(10,'Тоша',5),
		(11,'Леша',6),
		(12,'Сеня',6);
	
SELECT pu.pupil_id, pu.name, cl.name, sp.name
FROM pupils pu, classes cl, specializations sp 
WHERE pu.class=cl.class_id
AND cl.spec=sp.spec_id;

SELECT * FROM pupils;
SELECT * FROM classes;
SELECT * FROM specializations ;

DELETE FROM classes 
WHERE class_id = 1;

UPDATE classes 
SET class_id = 12
WHERE class_id = 2;


DELETE FROM specializations 
WHERE "name"='гуманитарный';

ALTER TABLE pupils 
ALTER COLUMN class 
SET CONSTRAINT ON DELETE CASCADE;
	
	
	
	
	
	
	
	
	
	
	
	
	

 
