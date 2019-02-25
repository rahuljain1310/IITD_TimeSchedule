drop table groupshost;
create table groupshost(groupalias varchar(30) references groups(alias),useralias varchar(30) references users(alias),unique(groupalias,useralias), foreign key (useralias,groupalias)  references usersgroups(useralias,groupalias));
create index groupshost_id_key on groupshost(groupalias);
create index groupshost_useralias_key on groupshost(useralias);
insert into groupshost (select groupalias,useralias from usersgroups,curr_prof_course where curr_prof_course.coursecode=usersgroups.groupalias and curr_prof_course.profalias=usersgroups.useralias);
