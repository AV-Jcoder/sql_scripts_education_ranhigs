create or replace view test_view (
	"Номер",
	"Имя"
) as 
select * from test;

insert into test
values
(1,'Name1');

select * from test_view;