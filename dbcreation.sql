create table organizational_units(id int primary key, alias varchar(15) unique not null);
create table user_groups(id int primary key,alias varchar(20),parent_userid int null references user_groups(id), orgid int references organizational_units(id),unique(alias,orgid));
create table users(userid int primary key,alias varchar(20) unique not null,name varchar(70));
create table usersgroup (userid int references users(userid),leaf_group varchar(30),unique(userid,leaf_group));
create domain course_code as
  varchar(8) not null check (value not similar to  '_{0,5}\s')
create domain day as
  varchar(3) not null check (value like 'Mon'or value like 'Tue' or value like 'Wed' or value like 'Thu' or value like 'Fri' or value like 'Sat' or value like 'Sun');
--create domain coursetype as
  --varchar(2) not null check (value like 'DC' or value like 'DE' or value like 'OE' or value like 'BS' or value like 'PL' or value lik);
create domain classtype as
  char not null check(value like 'L' or value like 'T' or value like 'P');
create table slottimings (slotname varchar(4),days day not null,begintime time(0) not null,endtime time(0) not null,type classtype not null, unique(slotname,days,type));
create table courseextratimings (courseid int references courses(courseid),days day,begintime time(0),endtime time(0),type classtype,unique (courseid,days,type)  );

create table faculty(id int primary key, name varchar(40) not null, alias varchar(15) not null,unique(alias),webpage varchar(50))
create table department (id int primary key,name varchar(40) not null,webpage varchar(50))

create table students(id int primary key,entrynumber varchar(15) references users(alias), name varchar(40),depid null references department(id),webpage varchar(50))
create table studenstlistexp(id int primary key,entrynum varchar(15),group varchar(5),dep varchar(3),year int,roll int,name varchar(40));

create table courses(courseid int primary key,code course_code not null,name varchar(120),
  slot varchar(4),type varchar(10),
  credits float, lec_dur float, tut_dur float, prac_dur float,
  check (credits = lec_dur+tut_dur+prac_dur/2 ),
strength int, registered int);

create table ProfessorCourses (profid int not null references faculty(id) not null, courseid int not null references courses(courseid));
create table coursesstudents(studentid int references students(id),courseid int references courses(courseid),unique(studentid,courseid));
create index studentsort on coursesstudents(studentid);
create index coursesort on coursesstudents(courseid);
create table studentcourses1 (select students
create table users2 (alias varchar(20),name varchar(70),leafgroup varchar(30));
\copy users2 from '/home/vishwajeet/Desktop/COL362/IITD_TimeSchedule/Users.csv';
insert into users (select distinct alias,name from
users2);
insert into usersgroup (
  select distinct userid,leafgroup from
  users , users2 where
  users.alias = users2.alias
);
