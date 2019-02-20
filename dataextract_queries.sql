drop materialized view CourseDetails cascade;
drop view CourseD cascade;

-- Checking Whether Entries are same or not in both course code
-- 0 0 should be utput of next two queries

-- select coursecode
-- from courseslist
-- where coursecode not in (
-- 	select coursecode
-- 	from CourseDetails
-- );


-- select coursecode
-- from coursesoffered
-- where coursecode not in (
-- 	select coursecode
-- 	from courseslist
-- );

create view CourseD as
select distinct coursename, coursecode, slot, type, credits, l, t, p, vacancy, currentstrength
from coursesoffered;

create materialized view CourseDetails as
select courseid, CD.coursecode, CD.coursename, CD.slot, CD.type, CD.credits,CD.l, CD.t, CD.p, CD.vacancy, CD.currentstrength
from courseslist, CourseD as CD
where CD.coursecode = courseslist.coursecode
order by courseid;

\copy (Select * FROM CourseDetails ) to 'C:/Users/rahul/IITD_TimeSchedule/CourseDetails.csv' with csv;
