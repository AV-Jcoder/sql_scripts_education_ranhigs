/**
 * 
 * Практическая 17 от 28.09.2022
 * 
 * Процедуры. 
 * 
 * 
 */
/****************************************************************/
DO 
$$
DECLARE 
	str varchar;
BEGIN
	str = 'кракодил';
	RAISE NOTICE 'Hello1, %', str;
END 
$$;
/****************************************************************/

/****************************************************************/
DO 
$$
DECLARE 
	str varchar;
	i integer;
BEGIN
	str = 'кракодил';
	i = 1;
	RAISE NOTICE '%,%,%,%', str, str, str, str;
	RAISE NOTICE '%',i;
END 
$$;
/*************** Странный код из презентации *********************/

do
$code$
    declare
        i integer;
    begin
        select balance from clients order by balance asc into i;
        raise notice 'notice i = %', i;
    end;    
$code$;

SELECT $code$abc''''def$code$;

/****************************************************************/
-- Вывести цифры по порядку.
DO 
$$
--DECLARE	
	--цифра integer;
BEGIN	
	FOR цифра IN 0 .. 9 
	LOOP 
		RAISE NOTICE '%', цифра;
	END LOOP; 
END 
$$;

/****************************************************************/

/* вывести сумму ряда 1 + 1/2 - 1/3 + 1/4 - 1/5 до 1/100 */
-- чётные складываем, нечётные вычитаем.
DO 
$$
DECLARE	
	результат float8;	
BEGIN	
	результат = 0;	
	FOR цифра IN 1 .. 100 
	LOOP 
		IF цифра % 2 = 0 THEN  результат = результат + 1.0/цифра; END IF;
		IF цифра % 2 != 0 THEN результат = результат - 1.0/цифра; END IF;		
	END LOOP;	
	RAISE NOTICE 'Сумма ряда = %', результат;
END 
$$;

/******************************************************************/

/******************************************************************/
CREATE PROCEDURE one_two_three() -- может не воззвращать значение
AS $pro$
BEGIN	
	FOR цифра IN 1 .. 3 
	LOOP 
		RAISE NOTICE '%', цифра;
	END LOOP; 
	COMMIT; -- в процедурах можно управлять транзакциями.
END 
$pro$ LANGUAGE plpgsql;

/**********/

CALL one_two_three(); -- вызов проедуры.

/******************************************************************/











