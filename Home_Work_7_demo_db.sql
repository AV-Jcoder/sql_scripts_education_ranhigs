
/**
 * Домашнее задание №7.
 * 
 * Написать SQL скрипт для БД "demo" для  получения 
 * списка броней с указанием для каждой брони билетов, 
 * а для каждого билета - имени пассажира, номера билета, 
 * номера рейса, времени вылета, аэропортов улета и прилета, 
 * времени в пути и цены билета.
 *
 * Отсортировать по номеру брони, 
 * имени пассажира, номеру билета, 
 * рейса, времени вылета.
 *  
 */

-- #Брони -> Имя пассажира -> #Билета -> #Рейса -> Время вылета -> Аэропорты Откуда-Куда -> Время в пути -> Цена


SELECT 	boo.book_ref 		AS "Бронь", 		
		ti.passenger_name 	AS "Пассажир",
		ti.ticket_no 		AS "Билет",
		fl.flight_no 		AS "Маршрут", 
		fl.actual_departure AS "Время вылета",  
		arp1.city 		AS "Откуда",
		arp2.city 		AS "Куда",		
		(fl.actual_arrival -
		fl.actual_departure)AS "Время в пути",
		tf.amount 		AS "Цена за перелёт",
		sum(tf.amount) OVER (PARTITION BY tf.ticket_no) AS "Цена за билет"
FROM bookings boo	INNER JOIN tickets ti 		ON boo.book_ref = ti.book_ref
				INNER JOIN ticket_flights tf	ON ti.ticket_no = tf.ticket_no
				INNER JOIN flights fl		ON tf.flight_id = fl.flight_id
				INNER JOIN airports arp1		ON fl.departure_airport = arp1.airport_code
				INNER JOIN airports arp2		ON fl.arrival_airport = arp2.airport_code
ORDER BY 	boo.book_ref, 
		ti.passenger_name, 
		ti.ticket_no, 
		fl.flight_no, 
		fl.actual_departure;
		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
