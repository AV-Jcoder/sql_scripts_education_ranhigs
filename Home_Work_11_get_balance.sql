
/**
 * Домашнее задание №11.
 * Часть 2.
 * 
 * В дополнение к таблицам задания 10 создать таблицы:
 * 
 * "поступления" (
 * 	код int, 
 * 	товар text, 
 * 	количество int); 
 * 
 * 		и
 * 
 * "требования" (
 * 	код int,
 * 	товар text, 
 * 	сообщение text);
 * 
 * Для таблицы "заказы" создать триггер, 
 * проверяющий по совокупности поступлений и 
 * заказов остаток на складе, 
 * и создающий новый заказ только 
 * в случае достаточного для заказа остатка на складе. 
 * 
 * В случае недостатка товаров 
 * запись заказа не создавать, 
 * а в таблице "требования" сделать запись с 
 * требованием закупи недостающих товаров в нужном количестве. 
 * 
 */

/**** Сперва идём по скрипту из 10 домашнего ****/

/**** 1. Создаём таблицу заказы*************/
CREATE TABLE IF NOT EXISTS заказы(		/***/
	код int, 						/***/
	заказчик text, 				/***/
	товар text, 					/***/
	цена int,    					/***/
	количество int);				/***/
/*******************************************/

/**** 2. Создаём таблицу удалённые заказы ************/
CREATE TABLE IF NOT EXISTS удаленные_заказы (	/***/
	код int, 								/***/
	заказчик text,							/***/
	товар text, 							/***/
	цена int, 							/***/
	количество int, 						/***/
	время timestamp, 						/***/
	пользователь TEXT);						/***/
/*****************************************************/




/**** Демонстрация работы скриптов из 11 домашнего задания **************/

/****  Ознакомительная информация о логике работы ***********************/ 
/****/ 												;/******/
/****/	SQL функция "дай_мне_баланс_по( )" - вычисляет		;/******/
/****/ баланс товаров на сладе, который составляет разницу		;/******/
/****/ между количеством имеющихся на складе товаров			;/******/
/****/ и количеством товаров которые уже заказаны, по выбранной	;/******/
/****/ категории.										;/******/
/****/ 	Триггерая функция "контроль_остатков( )" -			;/******/
/****/ если количество товаров в заказе превышает 			;/******/
/****/ балансовую величину, которую вычислила SQL функция		;/******/
/****/ по выбранной категории, то 							;/******/
/****/ такой заказ будет отклонён и 						;/******/
/****/ будет создана запись в таблице требований,				;/******/
/****/ иначе будет создана запись в таблице заказов.			;/******/
/****/												;/******/
/************************************************************************/

/**** 1. Создаём таблицу отслеживающую поступления на склад	**************/
 CREATE TABLE IF NOT EXISTS поступления (						/***/
 	код int, -- это код товара, это не id записи.				/***/
 	товар text, 											/***/
 	количество int); 										/***/
/*************************************************************************/

 	
/**** 2. Создаём таблицу в которой фиксируются нужды склада ****/
CREATE TABLE IF NOT EXISTS требования (					/***/
  	код int,										/***/
  	товар text, 									/***/
  	сообщение text);								/***/
/***************************************************************/

  
/**** 3. Теперь займёмся созданием ТРИГГЕРА И ФУНКЦИИ для него. ******************/  
/**** 3.1 Делаем декомпозицию сложной логики. ************************************/
/**** Пускай у нас будет обычная функция, которая сводит данные ******************/	
/**** и показывает баланс по группе товара, которыую *****************************/
/**** мы запрашиваем во входящих параметрах **************************************/	
CREATE OR REPLACE FUNCTION дай_мне_баланс_по(IN tovar_name text, OUT numeric)/****/
AS 															/******/
$sql$														/******/
SELECT balance.sum												/******/
FROM		(SELECT 	total.товар,									/******/
		  		sum(total.sum)  								/******/
		FROM	(SELECT по.товар,									/******/
				   sum(по.количество)							/******/
		 	 FROM поступления по								/******/
		 	 GROUP BY по.товар									/******/
			 	UNION ALL										/******/
		 	 SELECT за.товар,									/******/
			  	  (-1)*sum(за.количество)						/******/
		 	 FROM заказы за									/******/
		 	 GROUP BY за.товар) AS total							/******/
		GROUP BY total.товар) AS balance							/******/
WHERE balance.товар = tovar_name;									/******/
$sql$ LANGUAGE SQL;												/******/
/*********************************************************************************/	
/*********************************************************************************/	
/*********************************************************************************/	
	

/**** 3.2 Триггерная функция *****************************************************/
/**** Проверяющая разность между поступлениями и заказами ************************/
/**** IF Поступления - Заказы < 0, то RETURN NULL ********************************/
/**** AND Создать запись в таблице Требований ************************************/
CREATE OR REPLACE FUNCTION контроль_остатков()						/******/
RETURNS TRIGGER AS 												/******/			
$TrigFunc$													/******/
BEGIN	 													/******/
	IF ver2_дай_мне_баланс_по(NEW.товар) < NEW.количество THEN -- если товаров меньше, чем хотят заказть
		INSERT INTO требования SELECT NEW.код, NEW.товар, NEW.количество||' ШТУК(И), '||
		'ПОКУПАТЕЛЬ - '||NEW.заказчик||', СРОЧНО, СРОЧНО, СРОЧНО!!!';	/******/
		RAISE NOTICE 'Заказ отклонён';							/******/
		RETURN NULL; 											/******/
	END IF;													/******/
	RAISE NOTICE 'Заказ принят в работу для %',NEW.заказчик;			/******/
	RETURN NEW; -- если товары есть 								/******/
END;															/******/
$TrigFunc$ language plpgsql;										/******/
/*********************************************************************************/
/*********************************************************************************/


/**** 3.3 Триггер, срабатывает на добавление заказа ******************************/
CREATE TRIGGER контроль_остатков_триггер --имя триггера				/******/
BEFORE INSERT -- события											/******/
ON заказы														/******/
FOR EACH ROW -- условия											/******/
EXECUTE FUNCTION контроль_остатков();  -- имя функции;					/******/
/*********************************************************************************/
															/******/
/**** 3.4 Проверка, триггер создан или нет *****/						/******/
SELECT * FROM pg_catalog.pg_trigger								/******/
WHERE tgname = 'контроль_остатков_триггер';							/******/
/*********************************************************************************/

/**** 3.5 Проверим содержимое таблиц ***************************/
SELECT * FROM заказы; 		  -- пока что ничего нет;	/***/
SELECT * FROM удаленные_заказы; -- пока что ничего нет;	/***/
SELECT * FROM поступления;	  -- пока что ничего нет;	/***/
SELECT * FROM требования;	  -- пока что ничего нет;	/***/
/***************************************************************/



/**** Теперь проверяем работоспособность системы ****************************************/



/************************************************************************/
/****/ 												;/******/
/****/ Пусть изначально на складе было:						;/******/
/****/ Одна лодка										;/******/
/****/ 	и											;/******/
/****/ Один топор 										;/******/
/****/												;/******/
/************************************************************************/
 
 
/**** 1. Создаём записи на складе ********************/
INSERT INTO поступления (код, товар, количество)	/***/
VALUES 	(1, 'Топор', 1),					/***/
		(2, 'Лодка', 1);					/***/	
/*****************************************************/		
	
/**** 2. Проверка поступления ******************************************************/	
SELECT * FROM поступления;	     -- Топор и Лодка в наличии				/***/
SELECT дай_мне_баланс_по('Топор'); -- Можно проверить работу функции.			/***/
SELECT дай_мне_баланс_по('Лодка'); -- Тут аналогично.						/***/
/***********************************************************************************/	

/**** 3. Родион хочет купить сразу 2 топора ! ! ! *************************************************/	
INSERT INTO заказы (код, заказчик, товар, цена, количество)								/***/
VALUES 	(1, 'Родион','Топор',1000,2); 											/***/
-- информация в консоли вывода сообщает о том, что									/***/
-- мы вынуждены ему отказать, временно, до тех пор пока не закупят на склад побольше топоров.	/***/
/**************************************************************************************************/

/**** 4. Проверка работы триггера *********************************************/
SELECT * FROM заказы; -- запись о заказах не добавлена -(				/***/
SELECT * FROM требования; -- зато добавлена запись в таблицу требований	/***/
/******************************************************************************/

/**** 5. Родион подумал и решил, что ему хватит одного топора *******/
INSERT INTO заказы (код, заказчик, товар, цена, количество)		/***/
VALUES 	(1, 'Родион','Топор',1000,1); 					/***/
/********************************************************************/

/**** 6. Снова проверка работы триггера *************************************************/
SELECT * FROM заказы; -- заказ принят в работу, сообщение в консоли это подтверждает	/***/
SELECT * FROM требования; -- прежняя запись о 2-ух топорах	 					/***/
SELECT ver2_дай_мне_баланс_по('Топор'); -- можем посмотреть баланс по топорам 			/***/
SELECT ver2_дай_мне_баланс_по('Лодка'); -- и по лодкам через SQL функцию				/***/	
/****************************************************************************************/

/**** 7. Пробуем обработать другой заказ ************************/
INSERT INTO заказы (код, заказчик, товар, цена, количество)	/****/
VALUES 	(2, 'Герасим','Лодка',3500,5);				/****/
-- заказ отклонён, т.к. на складе только 1 лодка.			/****/
/****************************************************************/	

/**** 8. Снова проверка работы триггера *************************************************/
SELECT * FROM заказы; -- заказ был отклонён, и не попал в таблицу "заказы"			/***/
SELECT * FROM требования; -- зато добавлена запись в таблицу "требования"			/***/
SELECT ver2_дай_мне_баланс_по('Топор'); -- можем посмотреть баланс по топору 			/***/
SELECT ver2_дай_мне_баланс_по('Лодка'); -- и по лодке через SQL функцию				/***/	
/****************************************************************************************/

/**** 9. И наконец таки лодка продаётся *************************/
INSERT INTO заказы (код, заказчик, товар, цена, количество)	/****/
VALUES 	(2, 'Мазай','Лодка',3500,1);					/****/
-- в выводе указывается информация о состоянии заказа		/****/
/****************************************************************/	

/**** Для дропов ********************************************************/
TRUNCATE заказы, удаленные_заказы, поступления, требования CASCADE;	/**/
DROP TRIGGER IF EXISTS контроль_остатков_триггер ON заказы CASCADE;	/**/
DROP FUNCTION IF EXISTS контроль_остатков, дай_мне_баланс_по CASCADE;	/**/
DROP TABLE IF EXISTS заказы, удаленные_заказы CASCADE;				/**/
DROP TABLE IF EXISTS поступления, требования CASCADE;				/**/
/************************************************************************/


/**** Версия  метода №2 **********************************************************/
CREATE OR REPLACE FUNCTION ver2_дай_мне_баланс_по(IN tovar_name text, OUT numeric)
AS 															/******/
$sql$														/******/
SELECT sum(total.sum)											/******/															/******/
FROM	(SELECT sum(по.количество)									/******/				   							/******/
	 FROM поступления по										/******/
	 WHERE товар = tovar_name		 	 						/******/
	 	UNION ALL												/******/
	 SELECT (-1)*sum(за.количество)				  	  			/******/
	 FROM заказы за											/******/
	 WHERE товар = tovar_name) AS total							/******/															/******/
$sql$ LANGUAGE SQL;												/******/
/*********************************************************************************/	
/*********************************************************************************/	
/*********************************************************************************/	



