



/**** Создать триггер ********************/
CREATE TRIGGER my_trigger_name -- имя триггера
AFTER DELETE OR TRUNCATE -- срабатывание
ON my_table_name
FOR EACH STATEMENT -- условия работы
EXECUTE FUNCTION my_function_name();
/******************************************/



/**** Проверка триггеров по каталогу ********/
SELECT * FROM pg_catalog.pg_trigger; /*******/
/********************************************/




/**** Удалить триггер *******************/
DROP TRIGGER IF EXISTS tgigger_name ON table_name;
/****************************************/




