
#---single result of courses---
get_oldco="select * from courses where code = %s and year = %s and sem = %s"

get_co="select * from curr_courses where code = %s"

# -----multiple result of courses----

allco_slot="select code,name,slot,credits from courses where code ilike concat('%',%s,'%') and name ilike concat('%',%s,'%') and slot = %s and year = %s and semester = %s"

allco="select code,name,slot,credits from courses where code ilike concat('%',%s,'%') and name ilike concat('%',%s,'%') and year = %s and semester = %s"


curco_slot="select code,name,slot,credits from curr_courses where code ilike concat('%',%s,'%') and name ilike concat('%',%s,'%') and slot = %s"

curco="select code,name,slot,credits from curr_courses where code ilike concat('%',%s,'%') and name ilike concat('%',%s,'%')"
# ------------
# -------get courses from students and professors----

co_stu="select curr_courses_of_student.code,curr_courses_of_student.coursename,slot,curr_courses_of_student.type,credits from curr_courses_of_student where entrynum = %s"

oldco_stu="select courses_of_student.code,courses_of_student.name as coursename,slot,credits from courses_of_student where entrynum = %s and year = %s and semester = %s"

co_prof="select curr_courses_by_prof.code,curr_courses_by_prof.coursename as coursename,slot,credits from curr_courses_by_prof where profalias = %s"

oldco_prof="select courses_by_prof.code,courses_by_prof.name as coursename,slot,credits from courses_by_prof where profalias = %s and year = %s and semester = %s"


# ---users----
search_user="select alias,name"\
"from users"\
"where alias ilike concat('%',%s,'%') and name ilike concat('%',%s,'%') order by name"

search_stu="select alias,name from curr_stu where alias ilike concat('%',%s,'%') and name ilike concat('%',%s,'%') order by name"

search_prof="select alias,name"\
"from curr_prof"\
"where alias ilike concat('%',%s,'%')"\
"and name ilike concat('%',%s,'%')"\
"order by name"


stu_exists="select exists("\
"select alias,name"\
"from curr_stu where alias = %s)"\

prof_exists="select exists("\
  "select alias,name"\
  "from curr_prof where alias = %s)"
# users data
get_stu_data="select entrynum,studentname,webpage from users where entrynum = %s"

#---groups----
search_group="select gal"\
"from groups"\
"where gal ilike concat('%',%s,'%')"

get_groups="select useralias,name from usersgroups,users where useralias= %s and users.alias=useralias"
get_users="select * from usersgroups where groupalias= %s "

# ----events---
get_event_weekly="select slotname,days,begintime,endtime from (events natural join weeklyeventtime on events.id = %s) natural join slotdetails"\
"order by case when days = 'Mon' then 1 when days='Tue' then 2 when days='Wed' then 3 when days='Thu' then 4 when days = 'Fri' then 5 when days='Sat' then 6 when days = 'Sun' then 7,begintime"

get_event_once="select ondate,begintime,endtime from (events natural join onetimeeventtime on events.id = %s) order by ondate,begintime"

get_events="select * from events where events.alias ilike concat('%',%s,'%') and events.name ilike concat('%',%s,'%')"
get_matched_events="select * from events where events.alias = %s"

#  update user details
# update_group="update curr_stu_course set groupedin (select %s)"
