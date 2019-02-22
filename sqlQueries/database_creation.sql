create database project_3;
\connect project_3
\set curr_year 2018
\set curr_sem 2

create domain day as
  varchar(3) not null check (value like 'Mon'or value like 'Tue' or value like 'Wed' or value like 'Thu' or value like 'Fri' or value like 'Sat' or value like 'Sun');

create domain eventtype as
  varchar(3) not null check (value = 'W' or value = 'O');

create domain classtype as
  char not null check(value like 'L' or value like 'T' or value like 'P');

create table users(userid serial primary key,alias varchar(30) unique not null,name varchar(70));

create table groups(gid serial primary key, alias varchar(30) not null unique);

create table events(id serial primary key,alias varchar(30) references groups(alias),name varchar(120),type eventtype,linkto varchar(120));

create table weeklyeventtime(id int references events(id),slotname varchar(4) not null);

create table onetimeeventtime(id int references events(id),ondate date,begintime time(0),endtime time(0));

create table slotdetails(slotname varchar(4),days day not null,begintime time(0) not null,endtime time(0) not null);

create table usersgroups(
  userid int references users(userid),
  gid int references groups(gid),unique(userid,gid));


create table courses(courseid serial primary key,code varchar(8) not null,name varchar(120),
  slot varchar(4),type varchar(10),
  credits float, lec_dur float, tut_dur float, prac_dur float,
  check (credits = lec_dur+tut_dur+prac_dur/2 ),
  strength int, registered int,year int, semester int check(semester=1 or semester=2),constraint ckeysem unique(code,year,semester));

create table studentsincourse(studentid int references users(userid),courseid int references courses(courseid), unique(studentid,courseid));
create table coursesbyprof(profid int references users(userid), courseid int references courses(courseid),constraint course_prof_pkey unique(profid,courseid));


create table curr_courses(courseid serial primary key,code varchar(8) unique not null,name varchar(120),
  slot varchar(4),type varchar(10),
  credits float, lec_dur float, tut_dur float, prac_dur float,
  check (credits = lec_dur+tut_dur+prac_dur/2 ),
  strength int, registered int);

create table curr_stu_course(entrynum varchar(30) references users(alias),courseid int references curr_courses(courseid), unique(entrynum,courseid));

create table curr_prof_course(profalias varchar(30) references users(alias), courseid int references curr_courses(courseid),unique(profalias,courseid));

create table curr_prof(profalias varchar(30) primary key,profname varchar(70));
create table curr_stu(entrynum varchar(30) primary key,studentname varchar(70));

create table courses1 as (select * from courses);
create table users1 as (select * from users);
create table groups1 as (select * from groups);

\copy users1 from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/userdata.csv' delimiter '$';
\copy groups1 from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/groupsdata.csv' delimiter '$';
insert into users(alias,name)
  (select alias,name from
  users1 order by userid);
drop table users1;

insert into groups(alias)
  (select alias from
  groups1 order by gid);
drop table groups1;

\copy usersgroups from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/usersingroup.csv' delimiter '$';
\copy slotdetails from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/slotdetails.csv' delimiter '$';

\copy courses1 from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/courses.csv' delimiter '$';
insert into courses (code,name,slot,type,credits,lec_dur,
  tut_dur,prac_dur,strength,registered,year,semester)
  (select code,name,slot,type,credits,lec_dur,
    tut_dur,prac_dur,strength,registered,year,semester
  from courses1 order by courseid);
drop table courses1;

\copy studentsincourse from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/studentsincourse.csv' delimiter '$';
\copy coursesbyprof from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/coursesbyprof.csv' delimiter '$';






insert into curr_courses(code,name,slot,type,credits,lec_dur,
  tut_dur,prac_dur,strength,registered)
  (select code,name,slot,type,credits,lec_dur,
    tut_dur,prac_dur,strength,registered from
  courses);

  insert into curr_prof_course (select alias as profalias,
    courseid from coursesbyprof,users
    where coursesbyprof.profid=users.userid);

  insert into curr_stu_course (select alias as entrynum,courseid
    from studentsincourse,users
    where users.userid = studentsincourse.studentid);

  alter table curr_stu_course add column groupedin int;

  update curr_stu_course set groupedin = 1;

  insert into curr_stu (select distinct entrynum,name from users,curr_stu_course where alias=entrynum);
  insert into curr_prof (select distinct profalias,name from users,curr_prof_course where alias=profalias);


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

 create view curr_courses_of_student as
   (select curr_stu.entrynum as entrynum,curr_stu.studentname as studentname,code,curr_courses.name as coursename,curr_courses.type,slot,groupedin,credits,lec_dur,tut_dur,prac_dur,registered,strength
   from curr_courses natural join curr_stu_course natural join curr_stu
 );


 create view courses_of_student as
   (select users.alias as entrynum,users.name as studentname,code,courses.name as coursename,year,semester,slot,courses.type,credits,lec_dur,tut_dur,prac_dur,registered,strength
   from users,studentsincourse natural join courses
   where users.userid=studentid
   );

 create view curr_courses_by_prof as
   (select curr_prof.profalias as profalias,curr_prof.profname as profname,code,curr_courses.name as coursename,slot,curr_courses.type,credits,lec_dur,tut_dur,prac_dur,registered,strength
   from curr_prof natural join curr_prof_course natural join curr_courses
   );

 create view courses_by_prof as
   (select users.alias as profalias,users.name as profname,code,courses.name as coursename,slot,courses.type,credits,lec_dur,tut_dur,prac_dur,registered,strength,year,semester
   from users,coursesbyprof natural join courses
   where users.userid=profid
   );
