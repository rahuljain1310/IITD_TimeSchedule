create view student_course_slots as
  (select students(name) as student_name,
        students(entrynumber) as entry_no,
        courses(code) as coursecode,
      courses(slot) as slot,
      courses(credits) as credits
    from coursesstudents natural join students natural join courses
  );
create view prof_course as
  (select professor(name) as profname,
    professor(alias) as profalias,
    courses(code) as coursecode,
  courses(slot) as slot
  from professor natural join professorcourses natural join courses
  )

select * from courses
where code=%(code)s;

select * from faculty
where name=;

select * from faculty
where alias=;

select * from student
where name=;

select * from slottimings
where slotname=;

select * from courses
where code=;

select * from departments
where alias=;

select * from department
where name ILIKE '%%';

select * from prof_course
where profname=;

select * from prof_course
where profalias=;

select * from courseextratimings
where courseid=;

select coursecode,slot,credits from
student_course_slots where
entry_no=%(inputentryno)d


select entry_no,name from
student_course_slots where
coursecode=%(code)s
