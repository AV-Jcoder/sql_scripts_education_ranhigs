
/*
Вывести на дисплей:
имя пассажира
номер рейса
стоимость билета
название самолёта
названия аэропортов откуда куда
средняя цена билета по каждому направлению 
(Подразумевается что для одного и того же рейса
двух направлений быть не может.
Один рейс всегда летает по одному и тому же направлению.)
*/

/*********************************************************************************************/

SELECT 	result1.*,
		avg(result1."Цена за билет") OVER (PARTITION BY result1.flight_no) AS "Средняя цена за билет по направлению"
FROM (SELECT 	ti.passenger_name, 
			fl.flight_no, 
			ai.model, 
			arp.airport_name AS "Откуда", 
			arp2.airport_name  AS "Куда",
			tf.amount AS "Цена за перелёт",
			sum(tf.amount) OVER (PARTITION BY ti.ticket_no) AS "Цена за билет"			
	FROM tickets ti 
		JOIN ticket_flights tf 	ON ti.ticket_no = tf.ticket_no
		JOIN flights fl		ON tf.flight_id = fl.flight_id 	
		JOIN aircrafts ai		ON fl.aircraft_code = ai.aircraft_code
		JOIN airports arp		ON fl.departure_airport = arp.airport_code 
		JOIN airports arp2		ON fl.arrival_airport = arp2.airport_code) AS result1; 
/*********************************************************************************************/





















