

create database project_1;
\connect project_1

create domain day as
  varchar(3) not null check (value like 'Mon'or value like 'Tue' or value like 'Wed' or value like 'Thu' or value like 'Fri' or value like 'Sat' or value like 'Sun');

create domain classtype as
  char not null check(value like 'L' or value like 'T' or value like 'P');

create table users(userid int primary key,alias varchar(20) unique not null,name varchar(70));

create table groups(gid int primary key, alias varchar(30) not null unique);

create table usersgroups(userid int references users(userid),gid int references groups(gid),unique(userid,gid));

create table slotdetails(slotname varchar(4),days day not null,begintime time(0) not null,endtime time(0) not null,type classtype not null, unique(slotname,days,type));

create table courses(courseid int primary key,code varchar(8) not null,name varchar(120),
  slot varchar(4),type varchar(10),
  credits float, lec_dur float, tut_dur float, prac_dur float,
  check (credits = lec_dur+tut_dur+prac_dur/2 ),
  strength int, registered int,year int, semester int check(semester=1 or semester=2),constraint ckeysem unique(code,year,semester));

create table studentsincourse(studentid int references users(userid),courseid int references courses(courseid),constraint pkey unique(studentid,courseid));

create table coursebyprof(profid int references users(userid), courseid int references courses(courseid),constraint course_prof_pkey unique(profid,courseid));

\copy users from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/userdata.csv' delimiter '$';
\copy groups from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/groupsdata.csv' delimiter '$';
\copy usersgroups from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/usersingroup.csv' delimiter '$';
\copy slotdetails from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/slotdetails.csv' delimiter '$';
\copy courses from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/courses.csv' delimiter '$';
\copy studentsincourse from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/studentsincourse.csv' delimiter '$';
\copy coursebyprof from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/finaltables/finallast/coursesbyprof.csv' delimiter '$';
