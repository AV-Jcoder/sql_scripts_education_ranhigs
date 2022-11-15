/**
 * 
 */


CREATE TABLE clients(
    id serial PRIMARY KEY, -- строка эквивалентна id int DEFAULT nextval('clients_id_seq') PRIMARY KEY
    name varchar NOT NULL
);



