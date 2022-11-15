/*
 * Домашнее задание №5.
 *  
 */

/*1. Создаём таблицу студенты*/
CREATE TABLE students (
	first_name varchar,
	last_name varchar,
	date_of_birth date
);

/*2. Создаём таблицу факультеты*/
CREATE TABLE faculties (
	name varchar
);

/*3.1. Добавляем первичный ключ к таблице студенты*/
ALTER TABLE students
ADD COLUMN id serial PRIMARY KEY;

/*3.2. Добавляем первичный ключ к таблице факультеты*/
ALTER TABLE faculties 
ADD COLUMN id serial PRIMARY KEY;

/*4. Создаём в таблице студенты поле факультет и внешний ключ для связи с таблицей факультеты*/
ALTER TABLE students 
ADD COLUMN faculty int REFERENCES faculties(id);
