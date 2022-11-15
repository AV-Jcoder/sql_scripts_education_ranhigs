/** 
 * Домашнее задание №6.
 *  
 */

/*
 * 1. Создаём таблицу отделы.
 */
CREATE TABLE departments(
	id serial PRIMARY key,
	name varchar
);

/*
 * 1. Создаём таблицу сотрудников.
 */
CREATE TABLE staff(
	id serial PRIMARY key,
	last_name varchar,
	first_name varchar,
	father_name varchar,
	salary decimal,
	boss int REFERENCES staff(id),
	department int REFERENCES departments(id)
);

/*
 * 1. Наполняем таблицу отделов.
 */
INSERT INTO departments(name)
VALUES 	('Управление'),
		('Финансы'),		
		('Реклама'),
		('Сбыт'),
		('Охрана');
	
/*
 * 1. Наполняем таблицу сотрудников.
 */
INSERT INTO staff(last_name, first_name, father_name, salary, boss, department)
VALUES 	('Генералов', 'Майор', 'Полковникович', 10000,NULL,1),
		('ЗамГенералов','ЗамМайор','ЗамПолковникович',8000,1,1),
		('Посчитай','Ирина','Васильевна',6000,2,2),
		('Проверяй','Галина','Юрьевна',5000,3,2),
		('Дебет','Иван','Сергеевич',5000,3,2),
		('Кредет','Сергей','Михайлович',5000,3,2),
		('Креативный','Василий','Олегович',6000,2,3),
		('Дизайнерская','Ольга','Николаевна',5000,7,3),
		('Мечтательная','Елена','Леонидовна',5000,7,3),
		('Продавай','Константин','Вадимович',8000,1,4),
		('Комуникабельная','Оксана','Анатольевна',7000,10,4),
		('Сэллер','Ганс','Фердинандович',7500,10,4),
		('Настырный','Кузьма','Владимирович',7500,10,4),
		('Сторожевой','Егор','Иванович',4000,2,5),
		('Дозорный','Добрыня','Никитович',3000,14,5),
		('Бородач','Фёдор','Фёдорович',3000,14,5),
		('Караул','Илья','Секирголовович',2500,14,5);

/* 
 * 2. Вывод на дисплей сотрудников,
 * их принадлежность к отделам, 
 * имена руководителей для каждого сотрудника.
 * Вывод должен содержать сотрудников без руководителя.
 */	
SELECT st.last_name, st.first_name, st.father_name, de.name AS department, st2.last_name AS BOSS
FROM staff st 
LEFT OUTER JOIN departments de
ON st.department=de.id
LEFT JOIN staff st2
ON st.boss=st2.id;

/*
 * 3. Вывод на дисплей названий всех отделов
 * с указанием количества сотрудников в каждом.
 */
SELECT de.name, count(st.last_name)
FROM staff st, departments de
WHERE st.department=de.id
GROUP BY de.name;

/*
 * 3. Вывести на дисплей сотрудников с зарплатой выше средней по отделу
 * с указанием и зарплаты сотрудника
 * и средней по отделу.  
 */	
SELECT st.last_name, st.salary, av 
FROM staff st, (SELECT st2.department, avg(st2.salary) AS av
			FROM staff st2
			GROUP BY st2.department) AS t2
WHERE st.department=t2.department
AND st.salary>av;

/* Тоже самое, но 
 * через внешний джоин.
 */
SELECT st.last_name, st.salary, av 
FROM staff st
LEFT OUTER JOIN (SELECT st2.department, avg(st2.salary) AS av
			FROM staff st2
			GROUP BY st2.department) AS t2
ON st.department = t2.department
WHERE st.salary>av;

/**
 * Дополнение тут. 
 * Тоже самое, но
 * через оконную функцию.
 */

SELECT *
FROM (SELECT 	last_name, 
			salary,
			avg(salary) OVER (PARTITION BY department) AS avg_salary
	 FROM staff) AS "result"
WHERE "result".salary > 
	 "result".avg_salary;














