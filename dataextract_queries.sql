drop materialized view CourseDetails cascade;
create materialized view CourseDetails as
select distinct coursename, coursecode, type, credits, l, t, p
from coursesoffered;
\copy (Select * FROM CourseDetails ) to 'C:/Users/rahul/IITD_TimeSchedule/CourseDetails.csv' with csv;

select coursecode
from courseslist
where coursecode not in (
	select coursecode
	from CourseDetails
);


select coursecode
from coursesoffered
where coursecode not in (
	select coursecode
	from courseslist
);


-- select courseid, coursecode, CourseDetails.coursename, slot, credits, l, t, p
-- from courseslist left outer join coursesoffered
-- where coursesoffered.coursecode = courseslist.coursecode ;