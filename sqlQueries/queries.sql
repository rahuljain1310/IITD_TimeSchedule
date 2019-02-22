-- course as result ---

select * from pbys
where code = %s
and year = %s
and sem = %s

select * from curr_courses_by_prof
where code = %s
--------single result------------------------
select * from courses
where code = %s
and year = %s
and sem = %s

select * from curr_courses
where code = %s

-----multiple result of courses----

allco_slot=select code,name,slot,credits from courses
where code ilike concat('%',%s,'%')
and name ilike concat('%',%s,'%')
and slot = %s
and year = %s and semester = %s

allco=select code,name,slot,credits from courses
where code ilike concat('%',%s,'%')
and name ilike concat('%',%s,'%')
and year = %s and semester = %s


select code,name,slot,credits from curr_courses
where code ilike concat('%',%s,'%')
and name ilike concat('%',%s,'%')
and slot = %s

select code,name,slot,credits from curr_courses
where code ilike concat('%',%s,'%')
and name ilike concat('%',%s,'%')
------------
--------get courses from students and professors----

select curr_courses_of_student.code,curr_courses_of_student.coursename,slot,curr_courses_of_student.type,credits
from cbys18_2
where entrynum = %s

select cbys.code,cbys.name as coursename,slot,credits
from cbys
where entrynum = %s and year = %s and semester = %s

select curr_courses_by_prof.code,curr_courses_by_prof.coursename as coursename,slot,credits
from curr_courses_by_prof
where profalias = %s

select pbys.code,pbys.name as coursename,slot,credits
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

select alias,name
from curr_prof
where alias ilike concat('%',%s,'%')
and name ilike concat('%',%s,'%')
order by name

select exists(
select alias,name
from curr_stu where alias = %s)

select exists(
  select alias,name
  from curr_prof where alias = %s)

---mailing list---
--------------
---- group data of a user---
---student/group
select gal from
usrgrp where
alias = %s
order by gal
-- to find groups--
select gal
from groups
where gal ilike concat('%',%s,'%')
--- to get users of a group---
select alias,name
from usrgrp
where alias ilike concat('%',%s,'%') and name ilike concat('%',%s,'%') and gal = %s
order by alias

select alias,name
from usrgrp
where gal = %s
order by alias
--------------------------
/*select alias,name
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
*/


---generate time table of course---

-- group data---

--------
select * from (
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
when days='Sun' then 7 end)
as slottimings where type = %s or type = %s or type = %s
-----
-----

-----------
------------


with astudentc18_2 as (
select * from cbys18_2
where entrynum = %s )
,
stdctiming18_2 as (
select days,code,slot,begintime,endtime from
astudentc18_2 left outer join slotdetails
where astudentc18_2.slot = slotdetails.slotname
or (astudentc18_2.prac_dur > 0 and slotdetails.slotname = concat('P',astudentc18_2.slot,groupedin))
or (astudentc18_2.tut_dur > 0 and slotdetails.slotname = concat('T',astudentc18_2.slot,groupedin))
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
