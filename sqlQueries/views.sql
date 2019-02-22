-- create index namesorted on users(name);
-- create index curr_stu_sorted on curr_stu(name);
-- create index curr_prof_sorted on curr_prof(name);
-- create index coursenamesorted on courses(name);




----------------

create materialized view usrgrp as
  (select users.userid,users.alias as alias,users.name,groups.alias as gal
    from users,usersgroups,groups
    where users.userid=usersgroups.userid
    and groups.gid=usersgroups.gid
  );
create index usrgrpsorted on usrgrp(gal);
create index usrnmsorted on usrgrp(name);
---------------------------------
