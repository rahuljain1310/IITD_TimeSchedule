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

create table curr_stu_course(entrynum varchar(30) references users(alias),courseid int references curr_courses(courseid), unique(entrynum,courseid));
create index curr_stu_course_courseid_key on curr_stu_course(courseid);
create index curr_stu_coures_entrynum_key on curr_stu_course(entrynum);
create table curr_prof_course(profalias varchar(30) references users(alias), courseid int references curr_courses(courseid),unique(profalias,courseid));
create index curr_prof_course_profalias_key on curr_prof_course(profalias);
create index curr_prof_course_courseid_key on curr_prof_course(courseid);

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
declare groupexists bool:='t';
BEGIN
    groupexists:=  exists(select * from groups where alias = code);
    if (groupexists='f') then
    INSERT INTO groups(alias) values(code);
    end if;
   INSERT INTO courses(code,name,slot,type,credits,lec_dur,
     tut_dur,prac_dur,strength,registered,year,semester) VALUES (code,name,slot,type,credits,lec_dur,
       tut_dur,prac_dur,strength,registered,year,semester);
   INSERT INTO curr_courses(code,name,slot,type,credits,lec_dur,
     tut_dur,prac_dur,strength,registered) VALUES (code,name,slot,type,credits,lec_dur,
       tut_dur,prac_dur,strength,registered);

END
$$
 LANGUAGE 'plpgsql';

create or replace function insert_course() returns trigger as
  $BODY$
  begin
    INSERT INTO
      courses(code,name,slot,type,credits,lec_dur,
        tut_dur,prac_dur,strength,registered) VALUES (new.code,new.name,new.slot,new.type,new.credits,new.lec_dur,new.tut_dur,new.prac_dur,new.strength,new.registered,TG_ARGV[0],TG_ARGV[1]);
    RETURN new;
  end;
  $BODY$
  language 'plpgsql';

CREATE TRIGGER new_course_insert BEFORE INSERT ON curr_courses
execute procedure insert_course(2018,2);

create or replace function change_course_trigger(year int,sem int) returns void as
  $$
    BEGIN
    drop trigger if exists new_course_insert on curr_courses;
    CREATE TRIGGER new_course_insert BEFORE INSERT ON curr_courses
    execute procedure insert_course(year,semester);
    END;
  $$
language 'plpgsql';

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


create or replace function create_event(useralias1 varchar(30),alias1 varchar(30),name1 varchar(120),linkto varchar(120))
  returns bool as
$$
  DECLARE
    verify bool:='t';
    group_exists bool;
  begin
    group_exists:= exists(select * from groups where alias = alias1);
    if group_exists = 't' then
      verify:= exists(select * from groupshost where groupalias = alias1 and useralias = useralias1);
      if verify = 'f' then return 'f'; end if;
    end if;
    insert into groups(alias) values(alias1);
    insert into groupshost values (alias1,useralias1);
    insert into events(alias,name,linkto)
    values (alias1,name1,linkto);
    return 't';
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

alter table users add column webpage varchar(100);
alter table curr_courses add column webpage varchar(100);

  create or replace function get_day(da date) returns varchar(3) as
    $$
    declare
      d int := extract(dow from da);
    begin
      if d = 0 then return 'Sun';
      elsif d = 1 then return 'Mon';
      elsif d = 2 then return 'Tue';
      elsif d = 3 then return 'Wed';
      elsif d = 4 then return 'Thu';
      elsif d = 5 then return 'Fri';
      elsif d = 6 then return 'Sat';
      else return 'Non';
      end if;
    end
    $$
    language 'plpgsql';

create or replace function assign_groupto_user(hosta1 varchar(30),groupa1 varchar(30),usera1 varchar(30))
  returns bool as
  $$
  declare
  verify bool:= exists(select * from groupshost where groupalias = groupa1 and useralias = hosta1);
  begin
    if verify='f' then return 'f'; end if;
    insert into usersgroups values(usera1,groupa1);
    return 't';
  end
  $$
  language 'plpgsql'
