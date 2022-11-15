
/**
 *
 * Практическая №18 от 30.09.2022
 * Индексы, ускорение, оптимизация запросов.
 * 
 */
/*****************************************************************************/
/***** Часть 1. Проверка работы методов доступа на малом количестве данных  **/
/*****************************************************************************/
DROP TABLE IF EXISTS persons1;

CREATE TABLE IF NOT EXISTS persons1(
	pk_id serial PRIMARY KEY,
	fam1 varchar(50),
	nam1 varchar(50),	
	sur1 varchar(50)
);

INSERT INTO persons1(fam1,nam1,sur1)
VALUES 	('Сергеев','Сергей','Сергеевич'),
		('Петров','Пётр','Петрович'),
		('Иванов','Иван','Иванович'),
		('Сидор','Сидор','Сидоривич'),
		('Алексеев','Алексей','Алексеевич'),
		('Викторов','Виктор','Виктторович'),
		('Николаев','Николай','Николаевич'),
		('Петров','Сергей','Петрович'),
		('Алексеев','Сергей','Сергеевич'),
		('Сидоров','Алексей','Алексеевич'),
		('Петров','Алексей','Алексеевич'),
		('Викторов','Алексей','Алексеевич'),
		('Иванов','Алексей','Алексеевич'),
		('Круглов','Сидор','Сидоривич'),
		('Круглов','Алексей','Сидоривич');
	
/****  Смотрим метод доступа к данным **************************/
SELECT * FROM persons1 ;
EXPLAIN SELECT * FROM persons1 ;
EXPLAIN ANALYSE SELECT * FROM persons1 ;
-- Метод доступа seq scan = последовательный доступ без использования индекса,
-- несмотря на то, что PRIMARY KEY создаёт индекс.
/*****************************************************************/

/****** Смотрим в католог индексов , чтобы убедиться, что PRIMARY KEY создал индекс**********/
SELECT * FROM pg_catalog.pg_indexes WHERE schemaname = 'public' ORDER BY tablename;
/********************************************************************************************/

/****** Создаём индекс по полю fam1 *******************************/
CREATE INDEX fam_idx ON persons1 (fam1);
/******************************************************************/

/****** Проверяем, будет ли использован индекс для высоко селективной выборки ********/
SELECT * FROM persons1 WHERE fam1 = 'Петров';
EXPLAIN SELECT * FROM persons1 WHERE fam1 = 'Петров';
EXPLAIN ANALYZE SELECT * FROM persons1 WHERE fam1 = 'Петров';
-- как видим опять  seq scan = последовательное сканирование без индекса
/*************************************************************************************/

/******* Создадим Хеш-индекс, возможно база использует его ***************************/
CREATE INDEX fam_idx2
ON persons1 USING hash (fam1);
/*************************************************************************************/

/******** Проверяем на запросе *******************************************************/
SELECT * FROM persons1 WHERE fam1 = 'Петров';
EXPLAIN SELECT * FROM persons1 WHERE fam1 = 'Петров';
EXPLAIN ANALYZE SELECT * FROM persons1 WHERE fam1 = 'Петров';
-- снова seq scan = последовательный доступ без индекса.
-- так происходит потому что считать небольшое кол-во данных
-- намного быстрее, чем подготовить хеш-таблицу.
/****************************************************************/
DROP TABLE IF EXISTS persons1;/****/ 
/**********************************/





/**************************************************************************/
/******* Часть 2. Проверка работы индексов на большом количестве данных ***/
/**************************************************************************/

/********** Создаём и заполняем таблицу случайными значениями****/
DROP TABLE IF EXISTS perf_test;

CREATE TABLE  IF NOT EXISTS perf_test(
	id int,
	reason TEXT COLLATE "C", -- COLLATE это проавло сравнения для сортировки, для чего и как.
	annotation TEXT COLLATE "C" 
);

/******** Ноу-Хау от Николая Александровича, как заполнить таблицу *************/
INSERT INTO perf_test(id, reason, annotation)
SELECT s.id, md5(random()::text), NULL
FROM pg_catalog.generate_series(1, 10000000) AS s(id)
ORDER BY random();
/*******************/
UPDATE perf_test SET annotation = UPPER(md5(random()::text));
-- random()::text -  метод random() возвращает случайное число, 
-- которое преобразуется в текст с помощью ::text
-- md5() преобразует текст в хеш-код.
-- UPPER() переводит символы в верхний регистр.	
/*************************************************************/

SELECT * FROM perf_test; -- проверка

/*********** Проверяем метод доступа ***************************************/
SELECT * FROM perf_test WHERE id = 9888777;
EXPLAIN SELECT * FROM perf_test WHERE id = 9888777;
EXPLAIN ANALYZE SELECT * FROM perf_test WHERE id = 9888777;
-- снова seq scan, но уже параллельный, 
-- т.к. праймари кей нет, то инет индексного метода доступа.
-- Execution Time: 602.169 ms
/**********************************************************/
 
/********** Попробуем создать индекс ****/
CREATE INDEX perf_test_id_idx
ON perf_test (id);
/****************************************/

/****** Смотрим в католог индексов , чтобы убедиться в наличии ******************************/
SELECT * FROM pg_catalog.pg_indexes WHERE schemaname = 'public' ORDER BY tablename;/*********/
/********************************************************************************************/

/*********** Снова проверяем метод доступа ***************************************/
SELECT * FROM perf_test WHERE id = 9888777;
EXPLAIN SELECT * FROM perf_test WHERE id = 9888777;
EXPLAIN ANALYZE SELECT * FROM perf_test WHERE id = 9888777;
-- Доступ на основе индекса. 
-- Index Scan using perf_test_id_idx on perf_test  (cost=0.43..8.45 rows=1 width=70)
-- (actual time=0.029..0.032 rows=1 loops=1)
-- Execution Time: 0.038 ms  -  разница более чем в 10 000 раз. 
/***************************************************************/


/*********** Пробуем отискать данные в колонке reason, по которой не создан индекс ********/
SELECT * FROM perf_test WHERE reason LIKE 'bc%';
EXPLAIN SELECT * FROM perf_test WHERE reason LIKE 'bc%';
EXPLAIN ANALYZE SELECT * FROM perf_test WHERE reason LIKE 'bc%';
-- ->  Parallel Seq Scan on perf_test  (cost=0.00..258874.33 rows=417 width=70)
-- Execution Time: 661.242 ms
/****************************************************************/

/********** Попробуем создать индекс по колонке reason *****************************/
CREATE INDEX perf_test_reason_idx
ON perf_test (reason);
/********************************/

/****** Смотрим в католог индексов , чтобы убедиться в наличии ******************************/
SELECT * FROM pg_catalog.pg_indexes WHERE schemaname = 'public' ORDER BY tablename;/*********/
/********************************************************************************************/

/*********** Пробуем отискать данные в колонке reason *******************/
SELECT * FROM perf_test WHERE reason LIKE 'bc%';
EXPLAIN SELECT * FROM perf_test WHERE reason LIKE 'bc%';
EXPLAIN ANALYZE SELECT * FROM perf_test WHERE reason LIKE 'bc%';
-- Доступ с помощью индекса + битовой карты.
--   ->  Bitmap Index Scan on perf_test_reason_idx  (cost=0.00..1621.50 rows=41694 width=0) 
-- Execution Time: 232.905 ms
-- Поиск быстрее в 3 раза.
/**************************************************************/

/******* Пробуем выполнить поиск сразу по двум колонкам reason + annotation ****************/
SELECT * FROM perf_test WHERE reason LIKE 'bc%' AND annotation LIKE '%5D';
EXPLAIN SELECT * FROM perf_test WHERE reason LIKE 'bc%' AND annotation LIKE '%5D';
EXPLAIN ANALYZE SELECT * FROM perf_test WHERE reason LIKE 'bc%' AND annotation LIKE '%5D';
-- Доступ с помощью индекса + битовой карты.
--  ->  Bitmap Index Scan on perf_test_reason_idx  (cost=0.00..1605.64 rows=41308 width=0)
-- Execution Time: 225.152 ms
-- Как видим разницы нет.
/********************************************************************************************/

/******* Удалим ненужные индексы ************/
DROP INDEX perf_test_reason_idx;
DROP INDEX perf_test_id_idx;
/********************************************/

/******* Пробуем создать индекс по двум колонкам reason + annotation *********/
CREATE INDEX perf_test_reason_annotation_idx
ON perf_test (reason, annotation);
/********************************************/

/****** Смотрим в католог индексов , чтобы убедиться в наличии ******************************/
SELECT * FROM pg_catalog.pg_indexes WHERE schemaname = 'public' ORDER BY tablename;/*********/
/********************************************************************************************/

/******* Выполним поиск сразу по двум колонкам reason + annotation                    ****/
/******* И сравним  результаты с предыдущим запросом                                  ****/
/******* Разница только в индексах - предыдущий был по одному полю, теперь по двум    ****/
SELECT * FROM perf_test WHERE reason LIKE 'bc%' AND annotation LIKE '%5D';
EXPLAIN SELECT * FROM perf_test WHERE reason LIKE 'bc%' AND annotation LIKE '%5D';
EXPLAIN ANALYZE SELECT * FROM perf_test WHERE reason LIKE 'bc%' AND annotation LIKE '%5D';
-- Доступ с помощью индекса + битовой карты.
--    ->  Bitmap Index Scan on perf_test_reason_annotation_idx  (cost=0.00..2333.64 rows=41308 width=0) 
-- Execution Time: 229.452 ms
-- Как видно разницы нет. И решение создавать индекс сразу по двум полям  не дало прибавку в скорости.
/*******************************************************************************************************/

/****** Ради интереса выполним поиск по двум полям без индексов вообще **************/

/***** Удаляем индекс **********************/
DROP INDEX perf_test_reason_annotation_idx;
/*******************************************/

/****** Смотрим в католог индексов , чтобы убедиться в отсутствии ******************************/
SELECT * FROM pg_catalog.pg_indexes WHERE schemaname = 'public' ORDER BY tablename;/*********/
/********************************************************************************************/

/******** Выполним поиск **********************************************************************/
SELECT * FROM perf_test WHERE reason LIKE 'bc%' AND annotation LIKE '%5D';
EXPLAIN SELECT * FROM perf_test WHERE reason LIKE 'bc%' AND annotation LIKE '%5D';
EXPLAIN ANALYZE SELECT * FROM perf_test WHERE reason LIKE 'bc%' AND annotation LIKE '%5D';
-- Метод последовательного доступа к строкам.
--  ->  Parallel Seq Scan on perf_test  (cost=0.00..269291.00 rows=1 width=70)
-- Execution Time: 751.256 ms
-- Вывод -> индексы нужно применять обдуманно.
/***********************************************************************************************/
DROP TABLE IF EXISTS perf_test;/****************************************************************/
/***********************************************************************************************/






/**************************************************************/
/*****   Часть 3. Индекс GIN            				***/
/*****   Для поиска данных в массивах[] .				***/
/*****   Используют операторы	<@   @>   =   &&  			***/
/*****   9.19. Функции и операторы для работы с массивами	***/
/**************************************************************/

/************* Создаём таблицу про фильмы ************************************************/
DROP TABLE IF EXISTS movies;

CREATE TABLE IF NOT EXISTS movies(
	id serial PRIMARY KEY,
	title text NOT NULL,
	genres text[] NOT NULL -- text[] это массив.
);
/*************************************************/

/****** Пытаемся наполнить данными *******************************************************/
INSERT INTO movies (title, genres)
VALUES 	('Terminator2','{Action,Sci-Fi}'),
		('Ghostbusters','{Sci-Fi,Horror,Comedy}'),
		('Cars','{Children,Animation,Comedy}'),
		('Toy Story','{Children,Animation,Comedy}'),
		('Tor','{Action,Sci-Fi}'),
		('Beny Hill Show','{Action,Fanny,Comedy,Serial}'),
		('Fredy Cruger','{Horror, Retro}'),
		('Custo Odesy Diving','{Adventure, Animal, Serial, Nature}');
/************************************************************************/

SELECT * FROM movies; -- проверка	
	
/******* Создаём запрос, смотрим в планировщик *********************************************************/	
SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
EXPLAIN SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
EXPLAIN ANALYZE SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
-- Оператор @> проверяет вхождение в массив А массива Б
-- Seq Scan on movies  (cost=0.00..1.10 rows=1 width=68) 
-- Execution Time: 0.038 ms
/*************************************************************************************************/

/****** Cоздаём индекс GIN по столбцу genre, содержащему массив данных[] ******/
CREATE INDEX movies_genres_idx
ON movies USING gin (genres);
/****************************/

/****** Смотрим в католог индексов , чтобы убедиться в наличии ******************************/
SELECT * FROM pg_catalog.pg_indexes WHERE schemaname = 'public' ORDER BY tablename;/*********/
/********************************************************************************************/

/******* Повторяем запрос, смотрим в планировщик *********************************************************/	
SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
EXPLAIN SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
EXPLAIN ANALYZE SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
-- Seq Scan on movies  (cost=0.00..1.10 rows=1 width=68)
-- Execution Time: 0.038 ms
-- разницы нет, т.к. на небольшом количестве данных СУБД индекс не использует,
-- т.к. это не даёт выигрыш по времени, а возможно и замедляет скорость доступа к данным. 
/*************************************************************************************************/

/****** Наполним таблицу большими данными, но сперва ****************************/
/****** Дропнем индекс, так как он замедляет вставку ****************************/
DROP INDEX movies_genres_idx;
/**** И удалим ограничение PRIMARY KEY вместе с его индексом *****/
ALTER TABLE public.movies DROP CONSTRAINT movies_pkey;
/*******************************************************/

/****** Смотрим в католог индексов , чтобы убедиться в отсутствии ******************************/
SELECT * FROM pg_catalog.pg_indexes WHERE schemaname = 'public' ORDER BY tablename;/*********/
/********************************************************************************************/
	
/****** Наполняем таблицу данными по-новому способу *********************************************/	
DO
$code$
DECLARE
one 	 text; -- объявлются переменные
two 	 text; -- в которые потом сохраняется
three text; -- рандомный текст
BEGIN 
	FOR шаг IN 0 .. 1000000 -- тут происходит 1 млн. итераций для вставки значений в таблицу movies;
	LOOP 				-- длится примерно сек 30, но 10 млн. лучше не делать.
		one = md5(random()::text);
		two = md5(random()::text); -- присваивание рандомного текста в переменые
		three = md5(random()::text); 
		INSERT INTO movies (title, genres) -- сама вставка в таблицу
		VALUES (md5(random()::text),(SELECT ARRAY[one,two,three]::text[])); -- 4.2.12. Конструкторы массивов
	END LOOP;	
END 	
$code$; -- код  можно запускать тут.		
/*********************************************************************************/

SELECT * FROM movies; -- проверка, данных должно быть много.

/******* Повторяем запрос, смотрим в планировщик *********************************************************/	
SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
EXPLAIN SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
EXPLAIN ANALYZE SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
-- ->  Parallel Seq Scan on movies  (cost=0.00..30209.38 rows=1 width=169)
-- Execution Time: 175.950 ms
/************************************************************************************/

/****** Cоздаём индекс GIN ******************/
CREATE INDEX movies_genres_idx
ON movies USING gin (genres);
/****************************/

/****** Смотрим в католог индексов , чтобы убедиться в наличии ******************************/
SELECT * FROM pg_catalog.pg_indexes WHERE schemaname = 'public' ORDER BY tablename;/*********/
/********************************************************************************************/

/******* Повторяем запрос, смотрим в планировщик *********************************************************/	
SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
EXPLAIN SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
EXPLAIN ANALYZE SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
--   ->  Bitmap Index Scan on movies_genres_idx  (cost=0.00..84.00 rows=1 width=0)
-- Execution Time: 0.060 ms 
-- разница по времени около 3 000 раз.
/************************************************************************************/

/******* А что если создать обычный индекс и проверить быстродействие? ****************/

/****** Дропнем gin индекс *******/
DROP INDEX movies_genres_idx;
/****** Создадим обычный btree ***/
CREATE INDEX movies_genres_idx
ON movies USING btree (genres);
/**********************************/

/****** Смотрим в католог индексов , чтобы убедиться в наличии ******************************/
SELECT * FROM pg_catalog.pg_indexes WHERE schemaname = 'public' ORDER BY tablename;/*********/
/********************************************************************************************/

/******* Повторяем запрос, смотрим в планировщик *********************************************************/	
SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
EXPLAIN SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
EXPLAIN ANALYZE SELECT * FROM movies WHERE genres @> '{Sci-Fi,Horror,Comedy,Horror}';
-- ->  Parallel Seq Scan on movies  (cost=0.00..30209.38 rows=1 width=169) 
-- Execution Time: 167.961 ms
-- Тут последовательное сканирование без индекса.
-- btree ищет строку в дереве по какому-то одному значению,
-- с массивами значений не работает.
-- для поиска в массивах используется GIN - Generalized INverted index.
/************************************************************************************/
DROP TABLE IF EXISTS movies;/****/
/********************************/













