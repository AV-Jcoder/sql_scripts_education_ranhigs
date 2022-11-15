сделать запрос, выдающий 
записи с названием самолета и 
количеством мест каждого класаа  
 

название самолёта, класс комфорта, количество мест в каждом из классов

 
/****************** Через вложеный запрос **************************************/
SELECT 	ai.model, 
		t2.fare_conditions, 
		t2.total_seats
FROM aircrafts ai 
		JOIN ( 	SELECT 	s. aircraft_code ,
						s.fare_conditions, 
						count(seat_no) AS total_seats
				FROM seats s
				GROUP BY 	s.fare_conditions, 
						s.aircraft_code) AS t2
		ON ai.aircraft_code = t2.aircraft_code
ORDER BY 	ai.model, 
		t2.fare_conditions, 
		t2.total_seats;	
/*******************************************************************************/	

/********************** Без вложенного запроса *********************************/
SELECT 	ai.model,
		s.fare_conditions,
		count(s.*) AS total_seats
FROM aircrafts ai 
		JOIN seats s ON ai.aircraft_code = s.aircraft_code
GROUP BY 	s.aircraft_code,
		s.fare_conditions,
		ai.model
ORDER BY 	ai.model, 
		s.fare_conditions, 
		count(s.*);
/*******************************************************************************/	










