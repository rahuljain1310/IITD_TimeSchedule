

create database project1;
\connect project1;

create domain day as
  varchar(3) not null check (value like 'Mon'or value like 'Tue' or value like 'Wed' or value like 'Thu' or value like 'Fri' or value like 'Sat' or value like 'Sun');
create domain classtype as
  char not null check(value like 'L' or value like 'T' or value like 'P');

create table users(userid int primary key,alias varchar(20) unique not null,name varchar(70));
create table groups(id int primary key, alias varchar(30) not null unique,name varchar(70));
create table usersgroups(userid int references users(userid),groupid int references groups(id),unique(userid,groupid));
create table slotdetails(slotname varchar(4),days day not null,begintime time(0) not null,endtime time(0) not null,type classtype not null, unique(slotname,days,type));



create table courses(courseid int primary key,code varchar(8) not null,name varchar(120),
  slot varchar(4),type varchar(10),
  credits float, lec_dur float, tut_dur float, prac_dur float,
  check (credits = lec_dur+tut_dur+prac_dur/2 ),
  strength int, registered int,year int, semester int check(semester=1 or semester=2),constraint ckeysem unique(code,year,semester));

create table studentsincourse(studentid int references users(userid),courseid int references courses(courseid),constraint pkey unique(studentid,courseid));

create table coursebyprof(profid int references users(userid), courseid int references courses(courseid),constraint course_prof_pkey unique(profid,courseid));

  \copy users from '../finaltabs/finallast/userdata.csv' delimiter '$';
  \copy groups from '../finaltabs/finallast/groupsdata.csv' delimiter '$';
  \copy usersgroups from '../finaltabs/finallast/usersingroup.csv' delimiter '$';
  \copy slotdetails from '../finaltabs/finallast/slotdetails.csv' delimiter '$';
  \copy courses from '../finaltabs/finallast/courses.csv' delimiter '$';
  \copy studentsincourse from '../finaltabs/finallast/studentsincourse.csv' delimiter '$';
  \copy coursebyprof from '../finaltabs/finallast/coursesbyprof.csv' delimiter '$';
