
/**
 * Домашнее задание №9.
 * Часть 2. 
 * 
 *  Создать функцию, выдающую значение N-го члена ряда Фибонначи
 * 
 * Чи́сла Фибона́ччи — элементы числовой последовательности
 * 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377 ...
 * в которой первые два числа равны 0 и 1, 
 * а каждое последующее число равно сумме двух предыдущих чисел.
 * Названы в честь средневекового математика Леонардо Пизанского (известного как Фибоначчи).
 * 
 */

--1  2  3  4  5  6  7   8   9  10 -- номер в ряду 
--0, 1, 1, 2, 3, 5, 8, 13, 21, 34 -- числа фибоначи

SELECT get_my_fibo_nachhi_number(10); -- 10 это фактический параметр

DROP FUNCTION IF EXISTS get_my_fibo_nachhi_number;

CREATE OR REPLACE FUNCTION get_my_fibo_nachhi_number(number_in_row  integer) -- (number_in_row  integer) формальный параметр
RETURNS integer AS $code$
DECLARE
fibo_result int = 0;
fibo_presiding int = 0;
fibo_current int = 1;
BEGIN
	IF number_in_row = 1 THEN	
		RETURN 0;
	END IF;
	IF number_in_row = 2 THEN
		RETURN 1;
	END IF;
	FOR loop_num IN 0 .. (number_in_row-3)
	LOOP 
		fibo_result = fibo_presiding + fibo_current;	
		fibo_presiding = fibo_current;
		fibo_current = fibo_result;		
	END LOOP;
	RETURN fibo_result;
END;
$code$ LANGUAGE plpgsql IMMUTABLE;













