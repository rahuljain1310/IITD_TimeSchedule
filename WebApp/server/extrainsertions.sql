create table groupdependency(childgroup varchar(30) references groups(alias),parentgroup varchar(30) references groups(alias));

insert into events(alias,name) (select distinct code,'lecture' from curr_courses_of_student,slot_details
where )

;

-- create table coursegroupvenue(code varchar(8) ,slot varchar(3), venue varchar(30),constraint foreign key (code,slot) references curr_courses(code,slot))
alter table usersgroups add column subgroup int;
update usersgroups set subgroup = 1  where curr_stu_course.coursecode=usersgroups.groupalias;
alter table events add column subgroup varchar(10);

alter table curr_stu_course add constraint ccg foreign key (entrynum,coursecode,groupedin) references usersgroups(useralias,groupalias,subgroup);

create or replace function create_event(useralias1 varchar(30),alias1 varchar(30),name1 varchar(120),linkto varchar(120))
  returns int as
$$
  DECLARE
    verify bool:='t';
    group_exists bool;
    user_exists bool;
  begin
    user_exists :=exists(select * from users where alias = useralias1);
    if (user_exists = 'f') then return 2;
    end if; --user does not exist
    group_exists:= exists(select * from groups where alias = alias1);
    if group_exists = 't' then
      verify:= exists(select * from groupshost where groupalias = alias1 and useralias = useralias1);
      if verify = 'f' then return 1; 
      else
        insert into events(alias,name,linkto) values(alias1,name,linkto);
        return 0;
      end if; -- do not have permission
    end if;
    insert into groups(alias) values(alias1);
    insert into groupshost values (alias1,useralias1);
    insert into events(alias,name,linkto)
    values (alias1,name1,linkto);
    return 0;
END
$$
 LANGUAGE 'plpgsql';