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