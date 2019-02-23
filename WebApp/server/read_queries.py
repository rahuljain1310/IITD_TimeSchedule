
# Reads requires no authentication

# courses details
get_oldco="select * from courses where code = %s and year = %s and semester = %s"

get_co="select * from curr_courses where code = %s"


allco_slot="select code,name,slot,credits from courses where code ilike concat('%%',%s,'%%') and name ilike concat('%%',%s,'%%') and slot = %s and year = %s and semester = %s"

allco="select code,name,slot,credits from courses where code ilike concat('%%',%s,'%%') and name ilike concat('%%',%s,'%%') and year = %s and semester = %s"

curco_slot="select code,name,slot,credits from curr_courses where code ilike concat('%%',%s,'%%') and name ilike concat('%%',%s,'%%') and slot = %s"

curco="select code,name,slot,credits from curr_courses where code ilike concat('%%',%s,'%%') and name ilike concat('%%',%s,'%%') escape ''"

# -------get courses from students and professors----

# ---users details----
search_user="select alias,name "\
"from users "\
"where alias ilike concat('%%',%s,'%%') and name ilike concat('%%',%s,'%%') order by name "

search_stu="select alias,name from curr_stu where alias ilike concat('%%',%s,'%%') and name ilike concat('%%',%s,'%%') order by name"

search_prof="select alias,name "\
"from curr_prof "\
"where alias ilike concat('%%',%s,'%%') "\
"and name ilike concat('%%',%s,'%%') "\
"order by name"

# defined as currently doing some course
stu_exists="select exists( "\
"select alias,name "\
"from curr_stu where alias = %s) "

# defined as currently taking some course
prof_exists="select exists( "\
  "select alias,name "\
  "from curr_prof where alias = %s) "
# users data
get_user_data = "select name,webpage from users where alias = %s"
co_stu="select curr_courses_of_student.code,curr_courses_of_student.coursename,slot,curr_courses_of_student.type,credits from curr_courses_of_student where entrynum = %s"
oldco_stu="select courses_of_student.code,courses_of_student.name as coursename,slot,credits from courses_of_student where entrynum = %s and year = %s and semester = %s"
co_prof="select curr_courses_by_prof.code,curr_courses_by_prof.coursename as coursename,slot,credits from curr_courses_by_prof where profalias = %s"
oldco_prof="select courses_by_prof.code,courses_by_prof.name as coursename,slot,credits from courses_by_prof where profalias = %s and year = %s and semester = %s"

get_events_hosted = "select id,groupalias,name from events,groupshost where groupshost.useralias = %s and groupshost.groupalias = events.alias "
get_groups="select groupalias,name from usersgroups,users where useralias= %s and users.alias=useralias"

get_all_events = "with groups_in as ( "\
"select groupalias,name from usersgroups,users where useralias= %s and users.alias=useralias) "\
"select id,groupalias,name,linkto from groups_in,events "\
"where events.alias = groups_in.groupalias"


# time table of user


#---groups----
search_group="select gal "\
"from groups "\
"where gal ilike concat('%%',%s,'%%')"

get_groups="select useralias,name from usersgroups,users where useralias= %s and users.alias=useralias"
get_users="select * from usersgroups where groupalias= %s "

get_events="select id,alias,name from events where alias = %s"

# ----events---
get_exact_event="select * from events where events.id = %s"

get_eventtime_weekly="select slotname,days,begintime,endtime from (events natural join weeklyeventtime on events.id = %s) natural join slotdetails "\
"order by case when days = 'Mon' then 1 when days='Tue' then 2 when days='Wed' then 3 when days='Thu' then 4 when days = 'Fri' then 5 when days='Sat' then 6 when days = 'Sun' then 7,begintime"

get_eventtime_once="select ondate,begintime,endtime from (events natural join onetimeeventtime on events.id = %s) order by ondate,begintime"


# events page
get_events="select * from events where events.alias ilike concat('%%',%s,'%%') and events.name ilike concat('%%',%s,'%%')"


#  get students slots
#  update user details
# update_group="update curr_stu_course set groupedin (select %s)"
