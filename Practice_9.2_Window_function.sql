

/**
 * Практическая работа #9.
 * Оконные функции.
 */

CREATE TABLE salaries(
	employee int,
	department varchar,
	salary numeric
);

INSERT INTO salaries(department, employee, salary)
VALUES 
	('develop',11,5200),
	('develop',7,4200),
	('develop',9,4500),
	('develop',8,6000),
	('develop',10,5200),
	('personnel',5,3500),
	('personnel',2,3900),
	('salers',1,5000),
	('salers',4,4800);

SELECT *
FROM salaries s ;

SELECT *, avg(salary) OVER ()
FROM salaries;

SELECT *, avg(salary) OVER (PARTITION BY department ORDER BY salary)
FROM salaries;

SELECT *, sum(salary) OVER (PARTITION BY department ORDER BY salary)
FROM salaries;

SELECT *, sum(salary) OVER (PARTITION BY department ORDER BY salary RANGE BETWEEN
				UNBOUNDED PRECEDING AND CURRENT ROW) 
FROM salaries;

SELECT *, sum(salary) OVER (PARTITION BY department ORDER BY salary ROWS BETWEEN 
				UNBOUNDED PRECEDING AND CURRENT ROW)
FROM salaries;

SELECT *, sum(salary) OVER (PARTITION BY department ORDER BY salary ROWS BETWEEN 
				1 PRECEDING AND CURRENT ROW)
FROM salaries;

SELECT *, sum(salary) OVER (PARTITION BY department ORDER BY salary ROWS BETWEEN 
				CURRENT ROW AND UNBOUNDED FOLLOWING)
FROM salaries;

SELECT *, sum(salary) OVER (PARTITION BY department ORDER BY salary ROWS BETWEEN 
				2 PRECEDING AND 1 FOLLOWING)
FROM salaries;


SELECT *, RANK() OVER (PARTITION BY department ORDER BY salary)
FROM salaries;

SELECT *, dense_rank() OVER (PARTITION BY department ORDER BY salary)
FROM salaries;

SELECT *, row_number() OVER (PARTITION BY department ORDER BY salary)
FROM salaries;


SELECT 	*, 
		avg(salary) OVER w,
		sum(salary) OVER w,		
		row_number() OVER w
FROM salaries s
WINDOW w AS (PARTITION BY department ORDER BY salary ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW);









