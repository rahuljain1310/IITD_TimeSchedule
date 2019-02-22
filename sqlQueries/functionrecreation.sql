\set curr_sem 2019
\set curr_year 1

CREATE OR REPLACE FUNCTION insert_new_course(code varchar(8),name varchar(120),slot varchar(4),type varchar(10),credits int,lec_dur int,
 tut_dur int,prac_dur int,strength int,registered int,year int default :curr_year, semester int default :curr_sem) RETURNS VOID AS
$$
BEGIN
   INSERT INTO courses(code,name,slot,type,credits,lec_dur,
     tut_dur,prac_dur,strength,registered,year,semester) VALUES (code,name,slot,type,credits,lec_dur,
       tut_dur,prac_dur,strength,registered,year,semester);
   INSERT INTO curr_courses(code,name,slot,type,credits,lec_dur,
     tut_dur,prac_dur,strength,registered) VALUES (code,name,slot,type,credits,lec_dur,
       tut_dur,prac_dur,strength,registered);
END
$$
 LANGUAGE 'plpgsql';

create or replace function insert_stu_in_course(alias1 varchar(30),code1 varchar(8),grouped int,year int default :curr_year, sem int default :curr_sem)
 returns void as
$$
BEGIN
insert into curr_stu_course (
 select userid,curr_courses.courseid
 from curr_courses,users
 where users.alias = alias1 and curr_courses.code = code1
 and groupedin = grouped
);

insert into studentsincourse(
 select userid,courses.courseid
 from courses,users
 where users.alias = alias1 and courses.code = code1
 and year = year and semester = sem
);
END
$$
LANGUAGE 'plpgsql';

create or replace function insert_prof_in_course(alias1 varchar(30),code1 varchar(8),year int default :curr_year, sem int default :curr_sem)
  returns void as
$$
BEGIN
insert into curr_prof_course (
  select userid,curr_courses.courseid
  from curr_courses,users
  where users.alias = alias1 and curr_courses.code = code1
);

insert into profbycourse (
  select userid,courses.courseid
  from courses,users
  where users.alias = alias1 and courses.code = code1
  and year = year and semester = sem
);
END
$$
 LANGUAGE 'plpgsql';

 create or replace function create_event(alias1 varchar(30),name1 varchar(120),type1 varchar(1),linkto varchar(120))
   returns void as
 $$
   begin
 insert into groups(alias) (with bool1 as (select exists
     (select alias from groups where alias=alias1) as tmp2)
    select alias1 from bool1 where bool1.tmp2 = 'f');

 insert into events(alias,name,type,linkto)
   values (alias1,name1,type1,linkto);
 END
 $$
  LANGUAGE 'plpgsql';
