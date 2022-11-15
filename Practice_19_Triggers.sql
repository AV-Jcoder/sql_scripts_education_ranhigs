
/*
 * Практическая работа №19  
 * от 01.10.2022
 *   
 * Триггеры
 * 42.10. Триггерные функции
 *  
 */

-- Функции которым можно делать ON OFF
-- Disable trigger
-- Enable triggers
-- У триггеров не должно быть аргументов
-- Возвращает тип ТРИГГЕР, это псевдотип, по факту тип RECORD.
-- В триггерные функции  включены спец переменные - new и old.

DROP TABLE IF EXISTS staff;

TRUNCATE staff;

CREATE TABLE IF NOT EXISTS staff(
	name text,
	salary integer,
	date_last_update timestamp, -- дата последнего изменения 
	user_last_update text	   -- пользователь последнего изменения
);


/**** Создаём триггерную функцию *********************************/
/**
 * Функция ниже будет срабатывать 
 * перед вставкой(задаётся в триггере).
 * Триггерные функции могут 
 * вызываться только в триггерах.
 */
DROP FUNCTION IF EXISTS staff_check();

CREATE OR REPLACE FUNCTION staff_check() 
	RETURNS TRIGGER -- Возвращаемое значение триггерной функции игнорируется;	
	AS 
$code$
	BEGIN  
		RAISE NOTICE 'old = %',  OLD; -- OLD - спец переменная, храниит ПРЕЖНЕЕ значение строки.
		RAISE NOTICE 'new = %', NEW;  -- NEW - спец переменная, хранит ОБНОВЛЁННОЕ значение строки.
		RETURN NEW; -- возвратится запись, которую будут вставлять, если это триггер на вставку. 
	END;			  -- И она будет вставлена. Если вернуть NULL, то вставки не будет.
$code$ LANGUAGE plpgsql;
/********************************************************************/

/**** Создадим триггер ************************************************************************/
-- триггеры в ПГ сделаны красиво, даже лучше чем в майкрософте и оракле.((с) Олег Николаевич)
CREATE TRIGGER staff_check_trigger 
BEFORE INSERT OR UPDATE 			-- события (insert, update, delete, truncate)
ON staff 						-- таблица
FOR EACH ROW 					-- уровень (строка или оператор)
EXECUTE FUNCTION staff_check();    -- триггерная функция
-- BEFORE - триггер будет срабатывать до действий INSERT или UPDATE.
-- AFTEER - триггер будет срабатывать после действий INSERT или UPADTE.
/**************************************************************************/
DROP TRIGGER IF EXISTS staff_check_trigger ON staff;/****/
/********************************************************/

/**** Проверка триггеров по каталогу ********/
SELECT * FROM pg_catalog.pg_trigger; /*******/
/********************************************/


/**** Добавим запись в таблицу staff ****/
INSERT INTO staff (name, salary)
VALUES 	('Ivanov', 100);
-- посмотрим как себя ведёт триггер:
-- old = <NULL> - т.к. запись новая, то и предыдущего значения у неё нет. 
-- new = (Ivanov,100,,) - новое значение изменяемой записи.
/******************************************/

/**** Проверка содержимого таблицы *****/
SELECT * FROM staff; 			/****/
/***************************************/

/**** Обновим запись в таблице ****/
UPDATE staff 
SET salary = 12000
WHERE name = 'Ivanov';
-- old = (Ivanov,100,,) - предыдущее значение изменяемой записи.
-- new = (Ivanov,12000,,) - новое значение изменяемой записи.
/**********************************/




/**** Изменим нашу  триггерную функцию ****/
CREATE OR REPLACE FUNCTION staff_check() 
	RETURNS TRIGGER 	
	AS 
$code$
	BEGIN  
		RAISE NOTICE 'old = %',  OLD;
		RAISE NOTICE 'new = %', NEW;
		NEW.salary = 25700; -- поставим внаглую значение зарплаты для всех новых записей 25700.
		RETURN NEW; 		-- а значения из оператора INSERT будут игнорироваться.
	END;			 
$code$ LANGUAGE plpgsql;
/*******************************************/

/**** Добавим запись в таблицу staff ****/
INSERT INTO staff (name, salary)
VALUES 	('Petrov', 100);
-- посмотрим как себя ведёт триггер:
-- old = <NULL>
-- new = (Petrov,100,,) - да, функция выводит на дисплей лишь передаваемые параметры.
-- нужно проверить в самой таблице.
/******************************************/

/**** Проверка содержимого таблицы *****/
SELECT * FROM staff; 			/****/
-- а в самой таблице 25700		/****/
/***************************************/




/**** Функция из презентации, делает проверки на NULL. Хотя мы могли бы делать CHECK CONSTRAINT ****/
CREATE OR REPLACE FUNCTION staff_check() 
	RETURNS TRIGGER 	
	AS 
$code$
	BEGIN  
		-- проверка имени и зарплаты на null
		IF  NEW.name IS NULL THEN 
			RAISE EXCEPTION 'name - null pointer exception';
		END IF;
		IF NEW.salary IS NULL THEN
			RAISE EXCEPTION '% salary - null pointer exception', NEW.name;
		END IF;	
		RETURN NEW; 		
	END;			 
$code$ LANGUAGE plpgsql;
-- функция делает проверку имени на значение NULL
-- и делает проверку зарплаты на значение NULL
-- если RAIS EXCEPTION поднимет ошибку, то новая запись не будет добавлена. 
/*******************************************/

/**** Добавим запись в таблицу staff ****/
INSERT INTO staff (name, salary)
VALUES 	('Sidorov', NULL);
-- посмотрим как себя ведёт триггер:
SQL Error [P0001]: ОШИБКА: Sidorov salary - null pointer exception;  
/******************************************/

/**** Добавим запись в таблицу staff ****/
INSERT INTO staff (name, salary)
VALUES 	('Sidorov', 100),
		(NULL,5000);
-- посмотрим как себя ведёт триггер:
SQL Error [P0001]: ОШИБКА: name - null pointer exception;  
/******************************************/

/**** Проверка содержимого таблицы *****/
SELECT * FROM staff; 			/****/
-- Сидоров не добавлен и это правильно,
-- т.к. промежуточные результаты
-- не должны быть сохранены,
-- оператор исполняется полностью или 
-- не исполняется вообще.		/****/
/***************************************/




/**** Добавим проверку на отрицательные числа по полю зарплата ****/
CREATE OR REPLACE FUNCTION staff_check() 
	RETURNS TRIGGER 	
	AS 
$code$
	BEGIN  
		-- проверка имени и зарплаты на null
		IF  NEW.name IS NULL THEN 
			RAISE EXCEPTION 'name - null pointer exception';
		END IF;
		IF NEW.salary IS NULL THEN
			RAISE EXCEPTION '% salary - null pointer exception', NEW.name;
		END IF;	
		-- проверка зарплаты на отрицательное значение
		IF NEW.salary < 0 THEN
			RAISE EXCEPTION '% salary - can`t be 0 or less', NEW.name;
		END IF;
		RETURN NEW; 		
	END;			 
$code$ LANGUAGE plpgsql;
/*******************************************/

/**** Добавим запись в таблицу staff ****/
INSERT INTO staff (name, salary)
VALUES 	('Sidorov', -12000);
-- посмотрим как себя ведёт триггер:
-- SQL Error [P0001]: ОШИБКА: Sidorov salary - cant be 0 or less;  
/******************************************/

/**** Проверка содержимого таблицы *****/
SELECT * FROM staff; 			/****/
-- вставка завершается сообщением  /****/
-- об ошибке, запись в базу не 	/****/
-- была добавлена				/****/
/***************************************/



/**** Добавим отслеживание в запись, кто и когда делал изменения ****/
CREATE OR REPLACE FUNCTION staff_check() 
	RETURNS TRIGGER 	
	AS 
$code$
	BEGIN  		
		-- проверка имени и зарплаты на null
		IF  NEW.name IS NULL THEN 
			RAISE EXCEPTION 'name - null pointer exception';
		END IF;
		IF NEW.salary IS NULL THEN
			RAISE EXCEPTION '% salary - null pointer exception', NEW.name;
		END IF;	
		-- проверка зарплаты на отрицательное значение
		IF NEW.salary < 0 THEN
			RAISE EXCEPTION '% salary - can`t be 0 or less', NEW.name;
		END IF;
		-- запомнить кто и когда изменил запись
		NEW.date_last_update = current_timestamp; -- дата последнего изменения 
		NEW.user_last_update = current_user;
		RETURN NEW; 		
	END;			 
$code$ LANGUAGE plpgsql;
/*******************************************/

/**** Очистим таблицу сотрудников  ****/
DELETE FROM staff;
/*************************************/

/**** Проверка триггеров по каталогу ********/
SELECT * FROM pg_catalog.pg_trigger; /*******/
/********************************************/

/**** Проверка содержимого таблицы *****/
SELECT * FROM staff; 			/****/
/***************************************/

/**** Добавим запись в таблицу staff ****/
INSERT INTO staff (name, salary)	  /***/	
VALUES 	('Ivanov', 100);		  /***/
/****************************************/

/**** Проверка содержимого таблицы *****/
SELECT * FROM staff; 			/****/
/***************************************/

/**** Добавим запись в таблицу staff ****/
INSERT INTO staff (name, salary)	  /***/	
VALUES 	('Petrov', 500);		  /***/
/****************************************/

/**** Проверка содержимого таблицы *****/
SELECT * FROM staff; 			/****/
/***************************************/

/**** Проверка скрытых переменных ****/
CREATE OR REPLACE FUNCTION staff_check() 
	RETURNS TRIGGER 	
	AS 
$code$
	BEGIN  		
		RAISE NOTICE '%, %, %, %, %, %, %, %, %', TG_NAME, TG_WHEN, TG_LEVEL, 
		TG_OP, TG_RELID, TG_RELNAME, TG_TABLE_NAME, TG_TABLE_SCHEMA, TG_NARGS;
		RETURN NEW;
	END;			 
$code$ LANGUAGE plpgsql;
/*******************************************/

/**** Добавим запись в таблицу staff ****/
INSERT INTO staff (name, salary)	  /***/	
VALUES 	('Petrov', 500);		  /***/
/****************************************/

/**** Проверка содержимого таблицы *****/
SELECT * FROM staff; 			/****/
/***************************************/








