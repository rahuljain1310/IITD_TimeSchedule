create database project_3;
\connect project_3
\set curr_year 2018
\set curr_sem 2

create domain day as
  varchar(3) not null check (value like 'Mon'or value like 'Tue' or value like 'Wed' or value like 'Thu' or value like 'Fri' or value like 'Sat' or value like 'Sun');

create domain eventtype as
  varchar(1) not null check (value = 'W' or value = 'O');

create domain classtype as
  char not null check(value like 'L' or value like 'T' or value like 'P');

create table users(userid serial primary key,alias varchar(30) unique not null,name varchar(70),webpage varchar(100),password varchar(30));

create table groups(gid serial primary key, alias varchar(30) not null unique);

create table events(id serial primary key,alias varchar(30) references groups(alias),name varchar(120),type eventtype,linkto varchar(120));
create index events_alias_key on events(alias);
create index events_name_key on events(name);

create table weeklyeventtime(id int references events(id),slotname varchar(4) not null);
create index weeklyeventtime_id_key on weeklyeventtime(id);

create table onetimeeventtime(id int references events(id),ondate date,begintime time(0),endtime time(0));
create index onetimeeventtime_id_key on onetimeeventtime(id);
create index onetimeeventtime_time_key on onetimeeventtime(ondate,begintime);

create table groupshost(groupalias varchar(30) references groups(alias),useralias varchar(30) references users(alias),unique(groupalias,useralias));
create index groupshost_id_key on groupshost(groupalias);
create index groupshost_useralias_key on groupshost(useralias);

create table slotdetails(slotname varchar(4),days day not null,begintime time(0) not null,endtime time(0) not null);

create table usersgroups(
  useralias varchar(30) references users(alias),
  groupalias varchar(30) references groups(alias),unique(useralias,groupalias));

create index usersgroups_groupalias_index on usersgroups(groupalias);
create index usersgroups_useralias_index on usersgroups(useralias);

create table courses(courseid serial primary key,code varchar(8) not null,name varchar(120),
  slot varchar(4),type varchar(10),
  credits float, lec_dur float, tut_dur float, prac_dur float,
  check (credits = lec_dur+tut_dur+prac_dur/2 ),
  strength int, registered int,year int, semester int check(semester=1 or semester=2),constraint ckeysem unique(code,year,semester));

create table studentsincourse(studentid int references users(userid),courseid int references courses(courseid), unique(studentid,courseid));
create table coursesbyprof(profid int references users(userid), courseid int references courses(courseid),constraint course_prof_pkey unique(profid,courseid));
create index studentsincourse_stid_key on studentsincourse(studentid);
create index studentsincourse_cid_key on studentsincourse(courseid);
create index coursesbyprof_cid_key on coursesbyprof(courseid);
create index coursesbyprof_pid_key on coursesbyprof(profid);


create table curr_courses(courseid serial primary key,code varchar(8) unique not null,name varchar(120),
  slot varchar(4),type varchar(10),
  credits float, lec_dur float, tut_dur float, prac_dur float,
  check (credits = lec_dur+tut_dur+prac_dur/2 ),
  strength int, registered int);

create table curr_stu_course(entrynum varchar(30) references users(alias),coursecode int references curr_courses(code), unique(entrynum,coursecode));
create index curr_stu_course_coursecode_key on curr_stu_course(coursecode);
create index curr_stu_coures_entrynum_key on curr_stu_course(entrynum);
create table curr_prof_course(profalias varchar(30) references users(alias),coursecode int references curr_courses(code),unique(profalias,coursecode));
create index curr_prof_course_profalias_key on curr_prof_course(profalias);
create index curr_prof_course_coursecode_key on curr_prof_course(coursecode);

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

create table usersgroups1 (userid int,gid int);
\copy usersgroups1 from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/usersingroup.csv' delimiter '$';
insert into usersgroups (select users.alias as useralias,groups.alias as groupalias from usersgroups1,users,groups where usersgroups1.gid = groups.gid and users.userid = usersgroups1.userid order by groupalias,useralias);
drop table usersgroups1;

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
    code from coursesbyprof,users,curr_courses
    where coursesbyprof.profid=users.userid
  and courses.courseid=coursesbyprof.courseid);

  insert into curr_stu_course (select alias as entrynum,courseid
    from studentsincourse,users
    where users.userid = studentsincourse.studentid);

  alter table curr_stu_course add column groupedin int;
  update curr_stu_course set groupedin = 1;

  insert into curr_stu (select distinct entrynum,name from users,curr_stu_course where alias=entrynum);
  insert into curr_prof (select distinct profalias,name from users,curr_prof_course where alias=profalias);






 create view curr_courses_of_student as
   (select entrynum,studentname,code,curr_courses.name as coursename,curr_courses.type,slot,groupedin,credits,lec_dur,tut_dur,prac_dur,registered,strength
   from curr_courses join (curr_stu_course natural join curr_stu) as stucourse on curr_courses.code=stucourse.coursecode
 );


 create view courses_of_student as
   (select users.alias as entrynum,users.name as studentname,code,courses.name as coursename,year,semester,slot,courses.type,credits,lec_dur,tut_dur,prac_dur,registered,strength
   from users,studentsincourse natural join courses
   where users.userid=studentid
   );

 create view curr_courses_by_prof as
   (select profalias as profalias,profname,code,curr_courses.name as coursename,slot,curr_courses.type,credits,lec_dur,tut_dur,prac_dur,registered,strength
   from (curr_prof natural join curr_prof_course) as profwithcourse join curr_courses on profwithcourse.coursecode = curr_courses.code
   );

 create view courses_by_prof as
   (select users.alias as profalias,users.name as profname,code,courses.name as coursename,slot,courses.type,credits,lec_dur,tut_dur,prac_dur,registered,strength,year,semester
   from users,coursesbyprof natural join courses
   where users.userid=profid
   );

alter table users add column webpage varchar(100);
alter table users add column password varchar(30);
alter table curr_courses add column webpage varchar(100);
