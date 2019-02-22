query_getcoursebycode = "select * from courses where code = %s and year = %s and sem = %s"
query_getcoursesbyslot = "select * from courses where slot = %s and year = %s and sem = %s order by code"


qc1 = "select * from courses "\
"where code = %s "\
"and year = %s and sem = %s "


qc2 = "select * from courses where slot = %s and year = %s and sem = %s"


select * from courses
where code ilike concat(%s,'%')
and year = %s and semester = %s)


select * from courses
where name ilike concat(%s,'%')
and year = %s and semester = %s);

select * from curr_courses
where slot = %s

select * from curr_courses
where code = %s

select * from curr_courses
where name ilike concat(%s,'%')

select * from curr_courses
where code ilike concat(%s,'%')

select courses.code,courses.name as coursename,slot,courses.type,credits,lec_dur,tut_dur,prac_dur,registered,strength,year,semester
from cbys
where entrynum = %s
and year = %s
and semester = %s

select courses.code,courses.name as coursename,slot,courses.type,credits,lec_dur,tut_dur,prac_dur,registered,strength
from cbys18_2
where entrynum = %s

select courses.code,courses.name as coursename,slot,courses.type,credits,lec_dur,tut_dur,prac_dur,registered,strength
from cbys
where entrynum = %s and year = %s and semester = %s

select courses.code,courses.name as coursename,slot,courses.type,credits,lec_dur,tut_dur,prac_dur,registered,strength
from pbys18_2
where profalias = %s

select courses.code,courses.name as coursename,slot,courses.type,credits,lec_dur,tut_dur,prac_dur,registered,strength
from pbys
where profalias = %s and year = %s and semester = %s


query_
"with"
