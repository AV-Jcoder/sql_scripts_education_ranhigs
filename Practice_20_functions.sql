
/**
 * 
 * Практическая №20
 * от 04.10.2022
 * Встроенные Функции.
 * 
 * Часть практической относится к Заводуправлению.
 *    
 */

/***** Для дропов ***********************************/
DROP FUNCTION IF EXISTS factor;
/**********************************/
DROP TABLE IF EXISTS fc1;
TRUNCATE TABLE fc1;
/**********************************/
DROP FUNCTION IF EXISTS insertion(int);
/**********************************/
DROP FUNCTION IF EXISTS rand_beetwin(int, int);
/**********************************/
DROP FUNCTION IF EXISTS rand_beetwin(int, int);
/**********************************/
DROP FUNCTION IF EXISTS abs_between(int,int);
/***************************************************/


/***** Проверка таблицы *********/
SELECT * FROM работники;

/***** Выдать псевдонимы всем рабочим. ****/
UPDATE работники
SET имя = имя || '-Викторович';



/***** Создаём функцию, которая возвращает факториал *****/
CREATE OR REPLACE FUNCTION factor(число int) 
RETURNS NUMERIC AS $$
	SELECT factorial(число);
$$ LANGUAGE SQL;

/**** Проверка ****/
SELECT factor(3); 



/**** Создаём таблицу для наполнения факториалами *********/
CREATE TABLE IF NOT EXISTS fc1(
	id_pk serial PRIMARY KEY,
	name varchar,
	factor NUMERIC -- тут должны быть факториалы
);



/**** Создаём функцию для вставки значений в таблицу ****/
CREATE OR REPLACE FUNCTION insertion(seq int) 
RETURNS void AS $$
BEGIN 
	FOR i IN 1 .. seq
	LOOP 
		INSERT INTO fc1 (name, factor)
		VALUES ('Факториал числа '||i, factor(i));
	END LOOP;
END 
$$ LANGUAGE plpgsql;


/***** Делаем вставку 10 значений ****/
SELECT insertion(10);

/***** Проверка *****/
SELECT * FROM fc1;


/***** Вставка с помощью генератора серий **********************/
INSERT INTO fc1 (name, factor) 
values (generate_series(4,20) ,factor(generate_series(4,20)));

/***** Проверка *****/
SELECT * FROM fc1;



/***** Проверка функции - возвращает-ли random() внутри одной функции одинаковые значения ********/
CREATE OR REPLACE FUNCTION rand_beetwin(low int , hight int, OUT text, OUT float8 ,OUT float8, OUT float8)
AS 
$$
	SELECT (random()*hight-low+1)::text, random(),random(), random();
$$ LANGUAGE SQL;

SELECT rand_beetwin(1,5); -- возвращает все разные

DROP FUNCTION rand_beetwin(int, int); -- удалить
/**************************************************************************************************/



/***** Функция возвращает случайное число между указаным диапазоном, для назначения зарплаты рабочим ************/
CREATE OR REPLACE FUNCTION rand_between(low integer,high integer)
returns integer as 
$$
begin 
	return floor(random()*(high-low +1) + low);
end
$$ language plpgsql strict;



/***** Проверка ************/
select rand_between(8,25);

/***** Функция возвращает модуль числа *****************************/
create or replace function abs_between(low integer,high integer)
returns integer as 
$$
begin 
	return abs(random()*(high-low ) + low) ;
end
$$ language plpgsql strict;


/***** Проверка **********/
SELECT abs_between(8,15);


/***** Проверка *************/
SELECT rand_between(8,50);


/***** Добавляем столбец в таблицу рабочие **************/
ALTER TABLE работники ADD COLUMN зарплата integer ;


/***** Назначаем всем зарплату *********/
UPDATE работники 
SET зарплата = rand_between(12000,15000);

/***** Проверка ***********/
SELECT * FROM работники;
-- зп назначена всем рабочим













