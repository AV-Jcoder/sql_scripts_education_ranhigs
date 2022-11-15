
Создать таблицу ученики(id, имя, класс) 

Сделать запрос, который выведет список классов с количеством учеников в нем 

DROP TABLE ученики;

CREATE TABLE ученики(
	id serial PRIMARY key,
	имя varchar,
	класс varchar
);

INSERT INTO ученики(id,имя,класс)
VALUES
	(1,'Ivan','1a'),
	(2,'Egor','1a'),
	(3,'Svetlana','2b'),
	(4,'Konstantin','2b'),
	(5,'Ilja','3a'),
	(6,'Kate','3a'),
	(7,'Julia','4b'),
	(8,'Nikita','4b');


SELECT класс, count(id) 
FROM ученики
GROUP BY класс;

--вывести на дисплей все записи из таблицы учеников + сколько учеников учатся классе для каждой записи.

SELECT 	уч1.имя,
		уч1.класс, 
		уч3.count
FROM ученики уч1,(	SELECT уч2.класс, count(id) 
				FROM ученики уч2
				GROUP BY уч2.класс) AS уч3
WHERE уч1.класс=уч3.класс;
		







