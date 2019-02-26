drop table groupshost;
create table groupshost(groupalias varchar(30) references groups(alias),useralias varchar(30) references users(alias),unique(groupalias,useralias), foreign key (useralias,groupalias)  references usersgroups(useralias,groupalias));
create index groupshost_id_key on groupshost(groupalias);
create index groupshost_useralias_key on groupshost(useralias);
insert into groupshost (select groupalias,useralias from usersgroups,curr_prof_course where curr_prof_course.coursecode=usersgroups.groupalias and curr_prof_course.profalias=usersgroups.useralias);
create or replace function insert_prof_course()
  returns trigger as
$$
BEGIN
  insert into coursesbyprof (
  select users.userid,courses.courseid
  from courses,users
  where users.alias = new.profalias and courses.code = new.coursecode
  and year = cast(TG_ARGV[0] as int) and semester  = cast(TG_argv[1] as int)
  );
  if exists(select * from usersgroups where useralias=new.profalias and groupalias=new.coursecode) then else
  insert into usersgroups values(new.profalias,new.coursecode);
  end if;
  if exists(select * from groupshost where useralias=new.profalias and groupalias=new.coursecode) then else
  insert into groupshost values(new.coursecode,new.profalias);
  end if;
  return new;
END;
$$
 LANGUAGE 'plpgsql';


create or replace function delete_prof_from_course() returns trigger as
$$
BEGIN
    delete from coursesbyprof where profid = (select userid from users where alias = OLD.profalias)
    and courseid = (select courseid from courses where code = old.coursecode and courses.year = cast(TG_ARGV[0] as int) and courses.semester=cast(TG_ARGV[1] as int));
    delete from groupshost where groupalias = old.coursecode and useralias = old.profalias;
    delete from usersgroups where useralias = old.profalias and groupalias = old.coursecode;
    return old;
end;
$$
LANGUAGE 'plpgsql';

 create trigger delete_prof_course after delete on curr_prof_course
 for each row execute procedure delete_prof_from_course(2018,2);


create or replace function change_strength() returns trigger as
  $$
  begin
    update courses set strength = new.strength where code=new.code and year = cast(TG_ARGV[0] as int) and semester = cast(TG_ARGV[1] as int);
      return new;
  end;
  $$
  language 'plpgsql';

create trigger change_streng after update of strength on curr_courses for each row
execute procedure change_strength(2018,2);

    create domain grade_domain as 
    varchar(2) check (value = 'A' or value = 'A-' or value = 'B' or value = 'B-' or value = 'C' or value = 'C-' or value = 'D' or value = 'E' or value = 'F' or value = 'I' or value = 'X' )

alter table studentsincourse add column grade grade_domain;