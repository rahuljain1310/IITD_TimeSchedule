

# no authentication
create_group="insert into groups(alias) values(%s) on conflict do nothing returning alias"




# requires user authentication
update_user_webpage="update users set webpage = %s where users.alias = %s returning exists (alias)"
    login_user="select exists (select * from users where alias = %s and password = %s)"


    check_ifhost="select exists(select * from groupshost where groupalias = %s and useralias = %s)"
    assign_groupto_user="select assign_groupto_user(%s,%s,%s)"



# requires administrator authentication

# users change
update_user_name="update users set name = %s where users.alias  = %s returning exists (select)"
insert_user="""insert into users(alias,name,webpage) values(%s,%s,%s) on conflict do nothing returning exists (select)"""
assign_prof="insert into curr_prof_course(profalias,coursecode) values(%s,%s) on conflict do nothing returning exists (select )"
delete_user="delete from users where users.alias = %s returning exists (select)"
delete_user_from_group="delete from usersgroups where useralias= %s and groupalias = %s returning exists(select)"
# courses change
update_course_name="update curr_courses set name = %s where code = %s on conflict do nothing returning exists (select)"
    update_increment_registration="update curr_courses set registered = registered+1 where code = %s"
update_groupedin="update curr_courses_of_student set groupedin = %s where entrynum = %s and code= %s on conflict do nothing exists (select)"
register_student="insert into curr_stu_course values (%s,%s,%s) on conflict do nothing exists (select)"
insert_course="insert into curr_courses(code,name,slot,type,credits,lec_dur,tut_dur,prac_dur,strength,registered) values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) on conflict do nothing exists (select)"
change_strength="update curr_courses set strength = %s where code = %s returning exists (select)"
deregister_student="delete from curr_stu_course where coursecode = %s and entrynum = %s returning exists (select)"
change_coursepage="""update curr_courses set webpage = %s where code = %s returning exists (select)"""

# deletion
delete_groups_host="delete from groupshost where groupalias = %s and useralias = %s returning exists (select * from groupshost where groupalias = %s)"
grouphost_exist="exists (select * from groupshost where groupalias = %s and useralias = %s)"

delete_groups_host_all="delete from groupshost where groupalias = %s "
delete_users_groups="delete from usersgroups where groupalias = %s"
delete_group="delete from groups where alias = %s returninig exists (select)"
# change year and sem

# slots
create_slot="insert into slotdetails (%s,%s,%s,%s) on conflict do nothing returning exists (select)"

# events
insert_event="select create_event(%s,%s,%s,%s) as returned"
    copy_users_to_group="insert into usersgroups (select useralias,%s from usersgroups where groupalias = %s )"
set_eventtimeonce="insert into onetimeeventtime values(%s,%s,%s,%s,%s) on conflict do nothing select exists (select)"
set_eventtimeweekly="insert into weeklyeventtime values(%s,%s,%s) on conflict do nothing exists (select)"
# update year semester
    update_year_sem="select update_current_year_semester(%s,%s)"
