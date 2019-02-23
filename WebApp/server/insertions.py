

# no authentication
create_group="insert into groups(alias) values(%s)"




# requires user authentication
update_user_webpage="update users set webpage = %s where users.alias = %s"
update_user_name="update users set name = %s where users.alias  = %s"
login_user="select exists (select * from users where alias = %s and password = %s)"


check_ifhost="select exists(select * from groupshost where groupalias = alias1 and useralias = useralias1)"
assign_groupto_user="select assign_groupto_user(%s,%s,%s)"



# requires administrator authentication

# users change
update_user_name="update users set name = %s where users.alias  = %s"
insert_user="insert into users(alias,name) values(%s,%s)"
assign_prof="select insert_prof_in_course(%s,%s)"


# courses change
update_curr_course_name="update curr_courses set name = %s where code = %s"
update_increment_registration="update curr_courses set registered = registered+1 where code = %s"
update_groupedin="update curr_courses_of_student set groupedin = %s where entrynum = %s and code= %s"
register_student="select insert_stu_in_course(%s,%s,%s)"
insert_course="select insert_new_course(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"

# change year and sem

# slots
create_slot="insert into slotdetails (%s,%s,%s,%s)"

# events
copy_users_to_group="insert into usersgroups (select useralias,%s from usersgroups where groupalias = %s )"
