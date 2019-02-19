
create domain course_code as
  varchar(6) not null check (value not similar to  '_{0,5}\s')
create domain day as
  varchar(3) not null check (value like 'Mon'or value like 'Tue' or value like 'Wed' or value like 'Thu' or value like 'Fri' or value like 'Sat' or value like 'Sun');
create domain classtype as
  char not null check(value like 'L' or value like 'T' or value like 'P');
create table slottimings (slotname varchar(2),days day not null,begintime time(0) not null,endtime time(0) not null,type classtype not null, unique(slotname,days,type));
create table courseextratimings (courseid int references courses(courseid),days day,begintime time(0),endtime time(0),type classtype,unique (courseid,days,type)  );

create table faculty (id int primary key, name varchar(40) not null, alias varchar(10) not null,emailid varchar(30),unique(alias))
create table department (id int primary key,alias varchar(5), name varchar(40) not null)

create table students (id int primary key,depid int references department(id), entrynumber varchar(15) not null unique, name varchar(40))
create table ProfessorCourses (profid int references faculty(id) not null, courseid int not null);

create table courses(courseid int primary key,code course_code not null,name varchar(40),coursecordid int references faculty(id),
  credits float check(credits>0 and credits < 50), lec_dur int, tut_dur int, prac_dur int,
  check (credits = lec_dur+tut_dur+cast(prac_dur as float)/2 ));
create table coursewithslots(courseid int ,slot varchar(2),strength int, registered int,check (registered<=strength),unique(courseid,slot) );

alter table professorcourses add constraint fkey foreign key ( courseid) references courses(courseid) deferrable initially deferred;
create table coursesstudents(studentid int references students(id),courseid int references courses(courseid),slot varchar(2) not null,unique(studentid,courseid),unique(studentid,slot));
--create index studentsort on coursesstudents(studentid);
--create index coursesort on coursesstudents(courseid);
