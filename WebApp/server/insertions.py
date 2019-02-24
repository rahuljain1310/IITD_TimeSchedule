

# no authentication
create_group="insert into groups(alias) values(%s)"




# requires user authentication
update_user_webpage="update users set webpage = %s where users.alias = %s"
login_user="select exists (select * from users where alias = %s and password = %s)"


check_ifhost="select exists(select * from groupshost where groupalias = %s and useralias = %s)"
assign_groupto_user="select assign_groupto_user(%s,%s,%s)"



# requires administrator authentication

# users change
update_user_name="update users set name = %s where users.alias  = %s"
insert_user="insert into users(alias,name,webpage) values(%s,%s,%s)"
assign_prof="insert into curr_prof_course(profalias,coursecode) values(%s,%s)"


# courses change
update_course_name="update curr_courses set name = %s where code = %s"
update_increment_registration="update curr_courses set registered = registered+1 where code = %s"
update_groupedin="update curr_courses_of_student set groupedin = %s where entrynum = %s and code= %s"
register_student="insert into curr_stu_course values (%s,%s)"
insert_course="insert into curr_courses(code,name,slot,type,credits,lec_dur,tut_dur,prac_dur,strength,registered) values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"

# change year and sem

# slots
create_slot="insert into slotdetails (%s,%s,%s,%s)"

# events
insert_event="insert into events(alias,name,linkto) values(%s,%s,%s)"
copy_users_to_group="insert into usersgroups (select useralias,%s from usersgroups where groupalias = %s )"
# update year semester
update_year_sem="select update_current_year_semester(%s,%s)"
