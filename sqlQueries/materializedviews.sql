create view cbys18_2 as
  (select users.alias as entrynum,users.name as name,code,courses.name as coursename,slot,credits,lec_dur,tut_dur,prac_dur
  from users,studentsincourse,courses
  where users.userid=studentid
  and studentsincourse.courseid=courses.courseid
  and year=2018 and semester=2
  );
create view cbys as
  (select users.alias as entrynum,users.name as name,code,courses.name as coursename,year,semester,slot,credits,lec_dur,tut_dur,prac_dur
  from users,studentsincourse,courses
  where users.userid=studentid
  and studentsincourse.courseid=courses.courseid
  );
create view pbys18_2 as
  (select users.alias as profalias,users.name as name,code,courses.name as coursename,slot,credits,lec_dur,tut_dur,prac_dur
  from users,coursebyprof,courses
  where users.userid=profid
  and coursebyprof.courseid=courses.courseid
  and year=2018 and semester=2
  );
create view pbys as
  (select users.alias as profalias,users.name as name,code,year,semester,courses.name as coursename,slot,credits,lec_dur,tut_dur,prac_dur
  from users,coursebyprof,courses
  where users.userid=profid
  and coursebyprof.courseid=courses.courseid
  );
create view std as
  (select studentid,users.alias,users.name
  from studentsincourse,users
);

create view usrgrp as
  (select users.userid,users.alias as ual,users.name,groups.alias as gal
    from users,usergroups,groups
    where users.userid=usergroups.userid
    and groups.gid=usergroups.gid
  );
create view stincslot as
  (select users.alias as usal1, users.name as usn1,
    courses.slot as slot,courses.code as code,slotdetails.days as days,


  );

select * from courses
where code = %s
and year = %s
and sem = %s;


select * from courses
where slot = %s 
and year = %s 
and sem = %s 
order by code;



with astudentc18_2 as (
select * from cbys18_2
where entrynum = %s)

with stdctiming18_2 as (
select days,code,coursename,slotdetails.slot as slot,begintime,endtime from 
astudentc18_2,slotdetails
where astudentc.slot = slotdetails.slotname 
or astudentc.slot = 'P'+slotdetails.slotname+'1'
or astudentc.slot = 'T'+slotdetails.slotname+'1'
order by days,begintime )





select * from pbys18_2
where profalias = %s


select * from astudentc 
where 


where name = %s;

select alias from groups
where name = %s;ergroup

select * from usrgrp
where gal = %s;

select * from cbys18_2
where code = %s
order by entrynum;


select * from cbys
where code = %s
and year = %s
and semester = %s
order by entrynum;

select * from pbys
where code= %s
and year = %s
and semester = %s;

select * from pbys18_2
where code = %s

select * from slotdetails
where slot = %s;
