insert_course="select insert_new_course(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"

register_student="select insert_stu_in_course(%s,%s,%s)"

assign_prof="select insert_prof_in_course(%s,%s)"

create_group="insert into groups(alias) values(%s)"

insert_user="insert into users(alias,name) values(%s,%s)"

assign_groupto_user="insert into usersgroups(userid,gid) (select userid,gid from users,groups where users.alias = %s and groups.alias = %s)"

create_slot="insert into slotdetails (%s,%s,%s,%s)"

create_event="select create_event(%s,%s,%s,%s)"
