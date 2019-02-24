-- get day from date
create or replace function get_day(da date) returns varchar(3) as
  $$
  declare
    d int := extract(dow from da);
  begin
    if d = 0 then return 'Sun';
    elsif d = 1 then return 'Mon';
    elsif d = 2 then return 'Tue';
    elsif d = 3 then return 'Wed';
    elsif d = 4 then return 'Thu';
    elsif d = 5 then return 'Fri';
    elsif d = 6 then return 'Sat';
    else return 'Non';
    end if;
  end
  $$
  language 'plpgsql';


create or replace function assign_groupto_user(hosta1 varchar(30),groupa1 varchar(30),usera1 varchar(30))
returns bool as
$$
declare
verify bool:= exists(select * from groupshost where groupalias = groupa1 and useralias = hosta1);
begin
  if verify='f' then return 'f'; end if;
  insert into usersgroups values(usera1,groupa1);
  return 't';
end
$$
language 'plpgsql'

-- CREATE OR REPLACE FUNCTION insert_new_course(code varchar(8),name varchar(120),slot varchar(4),type varchar(10),credits int,lec_dur int,
--  tut_dur int,prac_dur int,strength int,registered int,year int default :curr_year, semester int default :curr_sem) RETURNS VOID AS
-- $$
-- declare groupexists bool:='t';
-- BEGIN
--     groupexists:=  exists(select * from groups where alias = code);
--     if (groupexists='f') then
--     INSERT INTO groups(alias) values(code);
--     end if;
--    INSERT INTO courses(code,name,slot,type,credits,lec_dur,
--      tut_dur,prac_dur,strength,registered,year,semester) VALUES (code,name,slot,type,credits,lec_dur,
--        tut_dur,prac_dur,strength,registered,year,semester);
--    INSERT INTO curr_courses(code,name,slot,type,credits,lec_dur,
--      tut_dur,prac_dur,strength,registered) VALUES (code,name,slot,type,credits,lec_dur,
--        tut_dur,prac_dur,strength,registered);
--
-- END
-- $$
--  LANGUAGE 'plpgsql';

create or replace function insert_course() returns trigger as
  $BODY$
  begin
      if (exists (select * from groups where alias = new.code)) then
        insert into groups(alias) values(new.code);
      end if;
      insert into courses(code,name,slot,type,credits,lec_dur,
        tut_dur,prac_dur,strength,registered,year,semester) VALUES (new.code,new.name,new.slot,new.type,new.credits,new.lec_dur,new.tut_dur,new.prac_dur,new.strength,new.registered,cast(TG_ARGV[0] as int),cast(TG_ARGV[1] as int));
    RETURN new;
  end;
  $BODY$
  language 'plpgsql';

CREATE TRIGGER new_course_insert AFTER INSERT ON curr_courses
for each row execute procedure insert_course(2018,2);

create or replace function change_course_trigger(year int,sem int) returns void as
  $$
    BEGIN
    drop trigger if exists new_course_insert on curr_courses;
    CREATE TRIGGER new_course_insert AFTER INSERT ON curr_courses
    execute procedure insert_course(year,semester);
    END;
  $$
language 'plpgsql';

create or replace function insert_stu_course() returns trigger as
  $$
  begin
    insert into studentsincourse (select userid,courseid from users,courses
    where users.alias=new.entrynum and courses.code=new.coursecode and courses.year =cast(TG_ARGV[0] as int)
    and courses.semester = cast(TG_ARGV[1] as int));
    update curr_courses set registered = registered+1 where code=new.coursecode;
    if exists(select * from usersgroups where useralias = new.entrynum and groupalias = new.coursecode) then
    else
    insert into usersgroups values(new.entrynum,new.coursecode);
    end if;
      return new;

  end;
  $$
  language 'plpgsql';

CREATE TRIGGER stu_add AFTER INSERT ON curr_stu_course
for each row execute procedure insert_stu_course(2018,2);

create or replace function stu_add_trigger(year int,sem int) returns void as
  $$
    BEGIN
    drop trigger if exists stu_add on curr_stu_course;
    CREATE TRIGGER stu_add AFTER INSERT ON curr_stu_course
    execute procedure insert_stu_course(year,semester);
    END;
  $$
language 'plpgsql';



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
  return new;
END
$$
 LANGUAGE 'plpgsql';

create trigger prof_add AFTER INSERT ON curr_prof_course
  for each row execute procedure insert_prof_course(2018,2);

  create or replace function prof_add_trigger(year int,sem int) returns void as
    $$
      BEGIN
      drop trigger if exists prof_add on curr_prof_course;
      CREATE TRIGGER prof_add AFTER INSERT ON curr_prof_course
      execute procedure insert_prof_course(year,semester);
      END;
    $$
  language 'plpgsql';

create or replace function create_event(useralias1 varchar(30),alias1 varchar(30),name1 varchar(120),linkto varchar(120))
  returns bool as
$$
  DECLARE
    verify bool:='t';
    group_exists bool;
  begin
    group_exists:= exists(select * from groups where alias = alias1);
    if group_exists = 't' then
      verify:= exists(select * from groupshost where groupalias = alias1 and useralias = useralias1);
      if verify = 'f' then return 'f'; end if;
    end if;
    insert into groups(alias) values(alias1);
    insert into groupshost values (alias1,useralias1);
    insert into events(alias,name,linkto)
    values (alias1,name1,linkto);
    return 't';
END
$$
 LANGUAGE 'plpgsql';

create or replace function incre_regis() returns trigger as
  $$
  begin
    update courses set registered = new.registered where code=new.code and year = cast(TG_ARGV[0] as int) and semester = cast(TG_ARGV[1] as int);
      return new;
  end;
  $$
  language 'plpgsql';
 create trigger incr_regis after update of registered on curr_courses
   for each row execute procedure incre_regis(2018,2);

create or replace function change_name() returns trigger as
  $$
  begin
  update courses set name = new.name where code = new.code and year = cast(TG_ARGV[0] as int) and semester = cast(TG_ARGV[1] as int);
    return new;
  end;
  $$
  language 'plpgsql';
create trigger chang_name after update of name on curr_courses
  for each row execute procedure change_name(2018,2);

  create or replace function update_current_year_semester(year int,sem int) returns void as
    $$
    begin
      drop trigger if exists chang_name on curr_courses;
      drop trigger if exists incr_regis on curr_courses;
      create trigger incr_regis after update of registered on curr_courses
        for each row execute procedure incre_regis(year,sem);
      create trigger chang_name after update of name on curr_courses
        for each row execute procedure change_name(year,sem);
      drop trigger if exists stu_add on curr_stu_course;
      CREATE TRIGGER stu_add AFTER INSERT ON curr_stu_course
      execute procedure insert_stu_course(year,sem);
      drop trigger if exists prof_add on curr_prof_course;
      CREATE TRIGGER prof_add AFTER INSERT ON curr_prof_course
      execute procedure insert_prof_course(year,sem);
      drop trigger if exists new_course_insert on curr_courses;
      CREATE TRIGGER new_course_insert AFTER INSERT ON curr_courses
      execute procedure insert_course(year,semester);
    end;
    $$
    language 'plpgsql';