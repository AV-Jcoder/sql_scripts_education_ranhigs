
/**
 * Как быстро залить данные
 * из таблицы А в таблицу Б?
 *  
 * Не ясяен механиз вставки
 * через оператор SELECT.
 * Как это работает?
 * 		и
 * Почему это законно?
 * 		и
 * И откуда это взялось?
 * 
 */

/**** Таблица1 ****/
CREATE TABLE IF NOT EXISTS my_table1(
	id int,
	id2 int	
);

/**** Так не работает ****/
INSERT INTO my_table1 2, 1;

/**** А так работает ****/
INSERT INTO my_table1 SELECT 2, 1;

/**** Проверка ****/
SELECT * FROM my_table1;

/**** Таблица2 ****/
CREATE TABLE IF NOT EXISTS my_table2(
	id int,
	id2 int	
);
/**** А так работает ****/
INSERT INTO my_table2 SELECT 99, 88;
INSERT INTO my_table2 SELECT 77, 66;
INSERT INTO my_table2 SELECT 55, 44;
INSERT INTO my_table2 SELECT 33, 22;

/**** Проверка ****/
SELECT * FROM my_table2;

/**** Так можно залить ВСЮ ТАБЛИЦУ 2 в ТАБЛИЦУ 1 ****/
INSERT INTO my_table1 SELECT * FROM my_table2 ORDER BY id ASC;

/**** Проверка ****/
SELECT * FROM my_table1;

/**** Дропы ****/
DROP TABLE IF EXISTS my_table1, my_table2;
TRUNCATE TABLE my_table1, my_table2;







