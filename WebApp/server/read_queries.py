
# Reads requires no authentication

# courses details
get_oldco="select * from courses where code = %s and year = %s and semester = %s"

get_co="select * from curr_courses where code = %s"
get_all_co="select code,name,credits,year,semester,strength,registered from courses where code = %s and year<> %s and semester <> %s"


allco_slot="select code,name,slot,credits from courses where code ilike concat('%%',%s,'%%') and name ilike concat('%%',%s,'%%') and slot = %s and year = %s and semester = %s"

allco="select code,name,slot,credits from courses where code ilike concat('%%',%s,'%%') and name ilike concat('%%',%s,'%%') and year = %s and semester = %s"

curco_slot="select code,name,slot,credits from curr_courses where code ilike concat('%%',%s,'%%') and name ilike concat('%%',%s,'%%') and slot = %s"

curco="select code,name,slot,credits from curr_courses where code ilike concat('%%',%s,'%%') and name ilike concat('%%',%s,'%%') escape ''"

# -------get courses from students and professors----

# ---users details----
search_user_withgroup="select alias,name "\
"from usersgroups,users  "\
"where usersgroups.useralias=users.alias and alias ilike concat('%%',%s,'%%') and name ilike concat('%%',%s,'%%') and groupalias = %s order by name "
search_user = "select alias,name "\
"from users  "\
"where alias ilike concat('%%',%s,'%%') and name ilike concat('%%',%s,'%%') order by name "

search_prof_withgroup="select profalias,profname "\
"from curr_prof,usersgroups where usersgroups.useralias=curr_prof.profalias and "\
" profalias ilike concat('%%',%s,'%%') "\
"and profname ilike concat('%%',%s,'%%') and groupalias= %s"\
"order by profname"
search_stu_with_group="select entrynum,studentname from curr_stu,usersgroups where usersgroups.useralias=curr_stu.entrynum and "\
" entrynum ilike concat('%%',%s,'%%') and studentname ilike concat('%%',%s,'%%') and groupalias = %s order by studentname"

search_stu="select entrynum,studentname from curr_stu where entrynum ilike concat('%%',%s,'%%') and studentname ilike concat('%%',%s,'%%') order by studentname"

search_prof="select profalias,profname "\
"from curr_prof "\
"where profalias ilike concat('%%',%s,'%%') "\
"and profname ilike concat('%%',%s,'%%') "\
"order by profname"

get_profs_courses="select profalias,profname from curr_courses_by_prof where code=%s"
get_stu_course="select entrynum,studentname,groupedin from curr_courses_of_student where code = %s"
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

get_events_hosted = "select id,groupalias,name,linkto from events,groupshost where groupshost.useralias = %s and groupshost.groupalias = events.alias "
get_groups="select groupalias,name from usersgroups,users where useralias= %s and users.alias=useralias"

get_all_events = "with groups_in as ( "\
"select groupalias,name from usersgroups,users where useralias= %s and users.alias=useralias) "\
"select groups_in.id,groupalias,name,linkto from groups_in,events "\
"where events.alias = groups_in.groupalias"


# time table of user


#---groups----
search_group="select alias "\
"from groups "\
"where alias ilike concat('%%',%s,'%%') "

get_groups="select useralias,name from usersgroups,users where useralias= %s and users.alias=useralias"
get_users="select * from usersgroups where groupalias= %s "
get_hosts="select * from groupshost where groupalias = %s "
get_events="select id,name,linkto from events where alias = %s"

# ----events---
get_exact_event="select alias,name,linkto from events where events.id = %s"

get_eventtime_weekly="select slotname,days,begintime,endtime from (events natural join weeklyeventtime on events.id = %s) natural join slotdetails "\
"order by case when days = 'Mon' then 1 when days='Tue' then 2 when days='Wed' then 3 when days='Thu' then 4 when days = 'Fri' then 5 when days='Sat' then 6 when days = 'Sun' then 7,begintime"

get_eventtime_once="select ondate,begintime,endtime from (events natural join onetimeeventtime on events.id = %s) order by ondate,begintime"


# events page
search_events="select * from events where events.alias ilike concat('%%',%s,'%%') and events.name ilike concat('%%',%s,'%%')"
# search_events_hosted = "select id,useralias,groupalias,name,linkto from events,groupshost where groupshost.useralias ilike concat('%%',%s,'%%') and groupshost.groupalias ilike concat('%%',%s,'%%') and events.name ilike concat('%%',%s,'%%') "


#  get students slots
#  update user details
# update_group="update curr_stu_course set groupedin (select %s)"
