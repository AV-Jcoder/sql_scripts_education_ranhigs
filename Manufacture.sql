
/**
 * Скрипт создаёт таблицу работников
 * и таблицу инструментов,
 * выдаёт инструмент работникам. 
 * 
 * Создаёт цеха.
 * Даёт доступ к цехам конкретным рабочим через отношение многие ко многим.
 * 
 */	

DROP TABLE IF EXISTS работники CASCADE;
DROP TABLE IF EXISTS инструменты CASCADE;
DROP TABLE IF EXISTS цеха CASCADE;
DROP TABLE IF EXISTS работники_цеха CASCADE;
TRUNCATE работники CASCADE;

CREATE TABLE IF NOT EXISTS работники(
	работник_id serial PRIMARY KEY,
	имя varchar(255)		
);

CREATE TABLE IF NOT EXISTS инструменты(
	инструмент_id serial PRIMARY KEY,
	имя varchar(255),
	работник_id int REFERENCES работники(работник_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS цеха(
	цех_id serial PRIMARY KEY,
	назначение varchar(255)
);

CREATE TABLE IF NOT EXISTS работники_цеха(
	работник_id int REFERENCES работники(работник_id) ON DELETE CASCADE ON UPDATE CASCADE,
	цех_id int REFERENCES цеха(цех_id) ON DELETE CASCADE ON UPDATE CASCADE
);

/****** Выдаём доступ к двери от цеха рабочему **************/
INSERT INTO работники_цеха(работник_id, цех_id)
VALUES 	(1,1),
		(2,1),
		(2,2),
		(2,3),
		(3,2),
		(4,3);

INSERT INTO работники(имя)
VALUES 	('Акинфиев Акинф Акинфеевич'),
		('Иванов Иван Иванович'),		
		('Петров Петр Петрович'),
		('Сидоров Сидр Сидорович');

INSERT INTO инструменты(имя)
VALUES 	('молоток'),
		('нож'),
		('дрель'),
		('пила');
	
INSERT INTO цеха(назначение)
VALUES 	('Изготовительный'),
		('Сборочный'),
		('Испытатлеьный');


SELECT * FROM работники;
SELECT * FROM инструменты;
SELECT * FROM цеха;
SELECT * FROM работники_цеха;

/**
 * Выдаём инструменты работникам 
 */

UPDATE инструменты 
SET работник_id = 1
WHERE инструмент_id = 4;

UPDATE инструменты
SET работник_id = 1
WHERE инструмент_id = 1;

UPDATE инструменты
SET работник_id = 2
WHERE инструмент_id = 3;



SELECT * 
FROM инструменты LEFT JOIN работники ON инструменты.работник_id = работники.работник_id; 
	
/**
 * Работник c вернул на склад сломаный молоток
 * и теперь его нужно  списать в утиль. 
 */	

SELECT * 
FROM работники INNER JOIN инструменты ON работники.работник_id = инструменты.работник_id
WHERE работники.работник_id = 1;

UPDATE инструменты
SET работник_id = NULL
WHERE инструмент_id = 1;

DELETE FROM инструменты
WHERE инструмент_id = 1; 

/**
 * Вывод на экран всех работников 
 * и названия цехов к 
 * которым у них есть доступ
 *  
 */

SELECT 	р.работник_id,
		р.имя,
		це.назначение AS "Имеет доступ к цеху"
FROM работники р 	INNER JOIN работники_цеха рц ON р.работник_id = рц.работник_id
				INNER JOIN цеха це ON рц.цех_id = це.цех_id;

/**********************************************************************/





