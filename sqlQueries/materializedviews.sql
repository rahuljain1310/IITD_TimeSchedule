

create materialized view curr_stu_course as
  (select studentid,courses.courseid,groupedin
  from studentsincourse natural join courses
  where year=2018 and semester=2);

create materialized view curr_stu as
  (
    select users.* from
    (select studentid from curr_stu_course
    group by studentid) as T1,users
    where T1.studentid=users.userid
  )
create materialized view curr_prof_course as
  (select coursebyprof.profid,coursebyprof.courseid
  from coursebyprof,users,courses
  where users.userid=coursebyprof.profid
  and courses.courseid=coursebyprof.courseid
  and year=2018 and semester=2);

create materialized view curr_prof as
  (
    select users.* from
    (select profid from curr_prof_course
    group by profid) as T1,users
    where T1.profid=users.userid
  )

create materialized view curr_course as
  (select courseid from
  courses where year=2018 and semester=2);


create index namesorted on users(name);
create index curr_stu_sorted on curr_stu(name);
create index curr_prof_sorted on curr_prof(name);
create index coursenamesorted on courses(name);

create view curr_courses as
  (
    select courses.* from
    curr_course natural join courses
  )


create view cbys18_2 as
  (select curr_stu.alias as entrynum,curr_stu.name as name,code,curr_courses.name as coursename,curr_courses.type,slot,groupedin,credits,lec_dur,tut_dur,prac_dur,registered,strength
  from curr_stu_course,curr_courses,curr_stu
  where curr_stu.userid=studentid
  and curr_stu_course.courseid=curr_courses.courseid
  );

create view cbys as
  (select users.alias as entrynum,users.name as name,code,courses.name as coursename,year,semester,slot,groupedin,credits,lec_dur,tut_dur,prac_dur,registered,strength
  from users,studentsincourse,courses
  where users.userid=studentid
  and studentsincourse.courseid=courses.courseid
  );

create view pbys18_2 as
  (select curr_prof.alias as profalias,curr_prof.name as name,code,courses.name as coursename,slot,credits,lec_dur,tut_dur,prac_dur,registered,strength,courses.type
  from curr_prof,curr_prof_course,courses
  where curr_prof.userid=profid
  and curr_prof_course.courseid=courses.courseid
  );

create view pbys as
  (select users.alias as profalias,users.name as name,code,year,semester,courses.name as coursename,slot,credits,lec_dur,tut_dur,prac_dur,registered,strength,courses.type
  from users,coursebyprof,courses
  where users.userid=profid
  and coursebyprof.courseid=courses.courseid
  );

----------------

create materialized view usrgrp as
  (select users.userid,users.alias as alias,users.name,groups.alias as gal
    from users,usersgroups,groups
    where users.userid=usersgroups.userid
    and groups.gid=usersgroups.gid
  );
create index usrgrpsorted on usrgrp(gal);
create index usrnmsorted on usrgrp(name);
---------------------------------
create view stincslot as
  (select users.alias as usal1, users.name as usn1,
    courses.slot as slot,courses.code as code,slotdetails.days as days,


  );




-- course as result ---



select * from pbys
where code = %s
and year = %s
and sem = %s)

select * from pbys18_2
where code = %s

--------no prof------------------------
select * from courses
where slot = %s
and year = %s
and sem = %s
---exact----
----------------------


select * from courses
where code ilike concat('%',%s,'%')
and name ilike concat('%',%s,'%')
and slot = %s
and year = %s and semester = %s


select * from curr_courses
where code ilike concat('%',%s,'%')
and name ilike concat('%',%s,'%')
and slot = %s

------------
------------

select cbys18_2.code,cbys18_2.name as coursename,slot,cbys18_2.type,credits,lec_dur,tut_dur,prac_dur,registered,strength
from cbys18_2
where entrynum = %s

select cbys.code,cbys.name as coursename,slot,cbys.type,credits,lec_dur,tut_dur,prac_dur,registered,strength
from cbys
where entrynum = %s and year = %s and semester = %s

select pbys18_2.code,pbys18_2.name as coursename,slot,pbys18_2.type,credits,lec_dur,tut_dur,prac_dur,registered,strength
from pbys18_2
where profalias = %s

select pbys.code,pbys.name as coursename,slot,pbys.type,credits,lec_dur,tut_dur,prac_dur,registered,strength
from pbys
where profalias = %s and year = %s and semester = %s

----courses-----
--- user data---

select alias,name
from users
where alias ilike concat('%',%s,'%')
and name ilike concat('%',%s,'%')
order by name

select alias,name
from curr_stu
where alias ilike concat('%',%s,'%')
and name ilike concat('%',%s,'%')
order by name
union
select alias,name
from curr_prof
where alias ilike concat('%',%s,'%')
and name ilike concat('%',%s,'%')
order by name


select alias,name
from usrgrp
where gal = %s

select alias,name
from usrgrp
where alias ilike concat('%',%s,'%') and name ilike concat('%',%s,'%') gal= %s



-- group data---
select alias
from groups
where alias ilike concat('%',%s,'%')
--------

select * from slotdetails
where slotname = %s
or slotname similar to concat('(P|T)',%s,'(1|2|3|4)')
order by slotname,
case when days='Mon' then 1
when days='Tue' then 2
when days='Wed' then 3
when days='Thu' then 4
when days='Fri' then 5
when days='Sat' then 6
when days='Sun' then 7 end
-----
-----

-----------
------------


with astudentc18_2 as (
select * from cbys18_2
where entrynum = %s )
,
stdctiming18_2 as (
select days,code,coursename,slotdetails.slotname as slot,begintime,endtime from
astudentc18_2,slotdetails
where astudentc18_2.slot = slotdetails.slotname
or slotdetails.slotname = concat('P',astudentc18_2.slot,1)
or slotdetails.slotname = concat('T',astudentc18_2.slot,1)
order by
  case
  when days='Mon' then 1
  when days='Tue' then 2
  when days='Wed' then 3
  when days='Thu' then 4
  when days='Fri' then 5
  when days='Sat' then 6
  when days='Sun' then 7 end ,begintime
) select * from stdctiming18_2;
