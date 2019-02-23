insert_course="select insert_new_course(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"

register_student="select insert_stu_in_course(%s,%s,%s)"

assign_prof="select insert_prof_in_course(%s,%s)"

create_group="insert into groups(alias) values(%s)"

insert_user="insert into users(alias,name) values(%s,%s)"

assign_groupto_user="insert into usersgroups values(%s,%s)"

create_slot="insert into slotdetails (%s,%s,%s,%s)"

create_event="select create_event(%s,%s,%s,%s)"

update_webpage="update users set webpage = %s where users.alias = %s"
update_groupedin="update curr_courses_of_student set groupedin = %s where entrynum = %s and code= %s"
