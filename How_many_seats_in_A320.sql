
*************************************************************************
  Какое количество посадочных мест в модели самолёта Аэробус А320 ?
**********
	Решение:
	1. Дробим сложную задачу на более мелкие - Принцип "разделяй и влавствуй". 
	   Смотрим диаграмму, делаем запрос по таблице? самолётов.
	
SELECT *
FROM aircrafts;

**********	
	2. Смотрим диаграмму, какие поля нам нужны? Делаем выборку самолётов по входным данным "Аэробус А320".
		Убеждаемся что такая запись в таблице есть, делая запрос.
	
SELECT * 
FROM aircrafts ai
WHERE ai.model LIKE '%Аэробус%' || '%A320%';

**********
	3. Соединяем таблицы: самолёты - места. Добавляем дополнительное условие к функции WHERE.  

SELECT * 
FROM  aircrafts ai, seats se
WHERE ai.model LIKE '%Аэробус%' || '%A320%'
AND ai.aircraft_code = se.aircraft_code;

**********
	4. Оставим только нужные нам атрибуты - модель и посадочное место.
	
SELECT ai.model, se.seat_no  
FROM  aircrafts ai, seats se
WHERE ai.model LIKE '%Аэробус%' || '%A320%'
AND ai.aircraft_code = se.aircraft_code;

*********
	5. Сгруппируем первую колонку, т.к. значения в ней все одинаковые. А во второй колонке значения разные,
		поэтому мы должны явно указать как группировать вторую колонку. Для этого используем 
		 агрегатную функцию count(), которая считает количество ячеек в стобце.

SELECT ai.model, count(se.seat_no)  
FROM  aircrafts ai, seats se
WHERE ai.model LIKE '%Аэробус%' || '%A320%'
AND ai.aircraft_code = se.aircraft_code
GROUP BY ai.model;

*********
	Ответ: В Аэробусе А320 140 посадочных мест.


******************************************************************************
















