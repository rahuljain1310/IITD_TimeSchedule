create table groupdependency(childgroup varchar(30) references groups(alias),parentgroup varchar(30) references groups(alias));

insert into events(alias,name) (select distinct code,'lecture' from curr_courses_of_student,slot_details
where )

;

-- create table coursegroupvenue(code varchar(8) ,slot varchar(3), venue varchar(30),constraint foreign key (code,slot) references curr_courses(code,slot))
alter table usersgroups add column subgroup int;
update usersgroups set subgroup = 1  where curr_stu_course.coursecode=usersgroups.groupalias;
alter table events add column subgroup varchar(10);

alter table curr_stu_course add constraint ccg foreign key (entrynum,coursecode,groupedin) references usersgroups(useralias,groupalias,subgroup);