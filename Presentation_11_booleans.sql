
create table truth (a bool,  b bool);

DROP TABLE truth;

insert into truth (a, b)     values
        (false, false),
        (false, true),
        (true, false),
        (true, true),
        (false, null),
        (true, null),
        (null, false),
        (null, true),
        (null, null); 

select a, b, a and b "a and b", a or b "a or b", not a "not a"
from truth;