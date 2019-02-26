# app.py
import os
import requests
import json
from flask import request, jsonify
from flask import Flask, render_template
import read_queries as rq
import insertions as iq
# from flask_sqlalchemy import SQLAlchemy
# from models import db
from flask_cors import CORS
curr_year=2018
curr_sem=2
import psycopg2 as ps
# conn = ps.connect("dbname=project_3 user=postgres password=Ishu@1003 host=localhost port=5432")
conn = ps.connect("dbname=postgres user=postgres password=postgres ")
cur = conn.cursor()

app = Flask(__name__, static_folder="../frontend/build/static", template_folder="../frontend/build")
CORS(app)

# app = Flask(__name__, static_folder="../frontend/build/static", template_folder="../courses")
# POSTGRES = {
#     'user': 'postgres',
#     'pw': 'postgres',
#     'db': 'project1',
#     'host': 'localhost',
#     'port': '5432',
# }
# app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
# app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://%(user)s:%(pw)s@%(host)s:%(port)s/%(db)s' % POSTGRES
# db.init_app(app)


## INSERT API's

@app.route("/update_yearsem",methods=['GET'])
def updatesession():
    curr_sem = 1+ (curr_sem % 2)
    if (curr_sem==1):
        curr_year=curr_year+1
    cur.execute(rq.update_year_semester,(curr_year,curr_sem))
@app.route("/add_slot/",methods=['GET'])
def addslot():
    slotcode = request.args.get('slot')
    begintime = request.args.get('begintime')
    endtime = request.args.get('endtime')
    day = request.args.get('day')
    try:
        cur.execute(create_slot,(slotcode,day,begintime,endtime))
    except:
        pass
    conn.commit()
    return jsonify({'results':''})
@app.route("/update_course/",methods=['GET'])
def updatecourse():
    code = request.args.get('code')
    name = request.args.get('name')
    strength = request.args.get('strength')
    webpage = request.args.get('webpage')
    type = request.args.get('type')
    group = request.args.get('group')
    # 0 indicates change name
    # 1 indicate register student
    # 5 indicates
    try:
        if (type=='0'):
            if (name!=''):
                cur.execute(iq.update_course_name,(name,code))
                conn.commit()
            if (strength!=''):
                try:
                    cur.execute(iq.change_strength,(int(strength),code))
                    conn.commit()
                except:
                    pass
            if (webpage!=''):
                cur.execute(iq.change_coursepage,(webpage,code))
                conn.commit()
        elif (type=='1'):
            try:
                cur.execute(iq.register_student,(code,name))
                conn.commit()
            except:
                pass
            cur.execute(iq.update_groupedin,(group,name,code))
            conn.commit()
        elif (type=='2'):
            cur.execute(iq.assign_prof,(code,name))
            conn.commit()
        else:
            pass
        conn.commit()
        return jsonify({'results':"Updated Successfully"})
    except:
        return jsonify({'results':"Not Updated"})

@app.route("/update_user/",methods=['GET'])
def updateuser():
    alias = request.args.get('alias')
    type = request.args.get('type')
    change = request.args.get('change')
    try:
        if type=='0':
            cur.execute(iq.update_user_name,(change,alias))
        elif type=='1':
            cur.execute(iq.update_user_webpage,(change,alias))
        else:
            pass
        conn.commit()
        return jsonify({'results':"Updated Successfully"})
    except:
        return 0
@app.route("/update_event/",methods=['GET'])
def updateevent():
    type = request.args.get('type')
    # 0 for add weekly time, 1 for add exact date and
    eventid = request.args.get('eventid')
    ondate = request.args.get('ondate')
    begintime = request.args.get('begintime')
    endtime = request.args.get('endtime')
    venue = request.args.get('venue')
    slot = request.args.get('slot')
    try:
        if type==0:
            cur.execute(iq.set_eventtimeweekly,(eventid,slot,venue))
        elif type==1:
            cur.execute(iq.set_eventtimeonce,(eventid,ondate,begintime,endtime,venue))
        else:
            raise Exception()
        return jsonify({'results':"Event Added Successfully"})
    except:
        return jsonify({'results':"Event not added Successfully"})
@app.route("/ins_user",methods=['GET'])
def insertuser():
    alias = request.args.get('alias')
    name = request.args.get('name')
    webpage = request.args.get('webpage')
    try:
        cur.execute(insert_user,(alias,name,webpage))
        return jsonify({'result':'inserted'})
    except:
        return jsonify({'result':''})

# @app.route("/update_user",methods=['GET'])
# def updateuser():
#     alias = request.args.get('alias')
#     name = request.args.get('name')
#     webpage = request.args.get('webpage')
#     cur.execute(rq.update_user_name,(name,alias))
#     cur.execute(rq.update_user_webpage,(webpage,alias))
#     return jsonify({})

@app.route("/ins_course/",methods=['GET'])
def insertcourse():
    code = request.args.get('code')
    name = request.args.get('name')
    slot = request.args.get('slot')
    type1 = request.args.get('type')
    # credits= request.args.get('credits')
    L = float(request.args.get('L'))
    T = float(request.args.get('T'))
    P = float(request.args.get('P'))
    Strength = request.args.get('Strength')
    cur.execute(iq.insert_course,(code,name,slot,type1,L+T+P/2,L,T,P,Strength,0))
    conn.commit()
    # return 0
    return jsonify({'results':[{"a":1,"b":1}]})

@app.route("/ins_event/",methods=['GET'])
def insertevent():
    user = request.args.get('user')
    usergroup = request.args.get('usergroup')
    eventname = request.args.get('eventname')
    # venue = request.args.get('venue')
    linkDescription =request.args.get('linkDescription')
    cur.execute(iq.insert_event,(user,usergroup,eventname,linkDescription))
    returned = cur.fetchall()[0][0]
    a = ""
    if returned == 0:
        a='success'
    elif returned == 1:
        a='permission denied'
    elif returned == 2:
        a='user does not exist'
    else:
        a='undefined error'
    conn.commit()
    # print(param)
    # return 0
    return jsonify({'results':a})

## DETAIL API's
@app.route("/course_details/",methods = ['GET'])
def course_details():
    code = request.args.get('code')
    # year = request.args.get('year')
    # semester = request.args.get('semester')
    # if (year=='')

    cur1 = conn.cursor()
    cur2 = conn.cursor()

    cur1.execute(rq.get_all_co,(code,curr_year,curr_sem))

    cur2.execute(rq.get_co,(code,))
    oldcourses = cur1.fetchall()
    curcourse = cur2.fetchall()[0]
    # curcode = curcourse[0][1]
    # curname = curcourse[0][2]
    # curslot = curcourse[0][3]
    # curtype = curcourse[0][4]
    # curcredits = curcourse[0][5]
    # curlec = curcourse[0][6]
    # curtut = curcourse[0][7]
    # curprac = curcourse[0][8]
    # curstrength = curcourse[0][9]
    # curregist = curcourse[0][10]
    print(curcourse)
    cur1.execute(rq.get_profs_courses,(code,))
    profs = cur1.fetchall()
    cur1.execute(rq.get_stu_course,(code,))
    registered = cur1.fetchall()

    return jsonify({'oldcourse':oldcourses,'coursedetails':curcourse,'profs':profs,'students':registered})

# @app.route("/student_details/",methods = ['GET'])
# def student_details():
#     alias = request.args.get('alias')             ## Got the only argument now send the json only
#     return jsonify({'results':cour})

# @app.route("/faculty_details/",methods = ['GET'])
# def faculty_details():
#     alias = request.args.get('alias')             ## Got the only argument now send the json only
#     return jsonify({'results':cour})

@app.route("/user_details/",methods = ['GET'])
def user_details():
    alias = request.args.get('alias')
    print(alias)
    cur.execute(rq.get_user_data,(alias,))
    userdata= cur.fetchall()
    print(userdata)
<<<<<<< HEAD
    username = userdata[0][0]
    userwebpage = userdata[0][0]
=======
    username = ""
    userwebpage = ""
    try:
        username = userdata[0][0]
    except:
        pass
    try:
        userwebpage = userdata[0][0]
    except:
        pass
>>>>>>> 5a8cddef9e7534c3a7548f2dcbaec3534082d58e
    cur.execute(rq.get_events_hosted,(alias,))
    events_hosted = cur.fetchall()
    cur.execute(rq.get_all_events,(alias,))
    all_events = cur.fetchall()
    cur.execute(rq.get_groups,(alias,))
    in_groups = cur.fetchall()
    cur.execute(rq.co_stu,(alias,))
    cur_course_registered = cur.fetchall()
    cur.execute(rq.alloldco_stu,(alias,curr_year,curr_sem))
    old_courses_registered = cur.fetchall()
    cur.execute(rq.co_prof,(alias,))
    cur_courses_taken = cur.fetchall()
    cur.execute(rq.alloldco_prof,(alias,curr_year,curr_sem))
    old_courses_taken = cur.fetchall()

    if (len(cur_course_registered)!=0):
        type1 = 'cur_stu'
    elif (len(old_courses_registered)!=0):
        type1 = 'old_stu'
    elif (len(cur_courses_taken)!=0):
        type1 = 'cur_prof'
    elif (len(old_courses_taken)!=0):
        type1 = 'old_prof'
    else:
        type1 = 'otheruser'
    return jsonify({'alias':alias,'username':username,'userwebpage':userwebpage,'cur_course_registered':cur_course_registered,'old_courses_registered':old_courses_registered,'cur_courses_taken':cur_courses_taken,'old_courses_taken':old_courses_taken,'events_hosted':events_hosted,'all_events':all_events,'type1':type1,'in_groups':in_groups})


@app.route("/usergroup_details/",methods = ['GET'])
def usergroup_details():
    alias = request.args.get('groupinput')
       ## Got the only argument now send the json only
    cur.execute(rq.get_users,(alias,))
    users = cur.fetchall()
    cur.execute(rq.get_events,(alias,))
    events = cur.fetchall()
    cur.execute(rq.get_hosts,(alias,))
    groups_host = cur.fetchall()
    # print(course)
    return jsonify({'groups_host':groups_host,'groupalias':alias,'users':users,'events':events})

@app.route("/event_details/",methods = ['GET'])
def event_details():
    eventid = request.args.get('eventid')   ## Got the only argument now send the json only
    cur.execute(rq.get_exact_event,(eventid,))
    eventdetails = cur.fetchall()[0]
    event_group = eventdetails[0]
    event_name = eventdetails[1]
    event_linkto = eventdetails[2]
    cur.execute(rq.get_users,(event_group,))
    event_users = cur.fetchall()
    cur.execute(rq.get_eventtime_weekly,(eventid,))
    event_weekly = cur.fetchall()
    cur.execute(rq.get_eventtime_once,(eventid,))
    event_timeonce = cur.fetchall()
    event_hosts = cur.execute(rq.get_hosts,(event_group,))
    return jsonify({'e_id':eventid,'e_group':event_group,'e_name':event_name,'e_linkto':event_linkto,'e_users':event_users,'e_weekly':event_weekly,'e_hosts':event_hosts,'e_time':event_timeonce})

## FIND API
@app.route("/findcourses/",methods = ['GET'])
def findcourses():
    print("API Call for Finding Courses")         ## Need to Work On this API
    code = request.args.get('code')
    name = request.args.get('name')
    slot = request.args.get('slot')
    semester = request.args.get('semester')
    year = request.args.get('year')
    if (slot==''):
        if (year==''):
            if (semester=='1'):
                cur.execute(rq.allco,(code,name,2018,1))
            else:
                cur.execute(rq.curco,(code,name))
        else:
            try:
                year=int(year)
                if (semester==''):
                    semester=2
                semester=int(semseter)
                cur.execute(rq.allco,(code,name,year,semester))
            except:
                cur.execute(rq.curco,(code,name))
    else:
        if (year==''):
            if (semester=='1'):
                cur.execute(rq.allco_slot,(code,name,slot,2018,1))
            else:
                cur.execute(rq.curco_slot,(code,name,slot))
        else:
            try:
                year=int(year)
                if (semester==''):
                    semester=2
                semester=int(semseter)
                cur.execute(rq.allco_slot,(code,name,slot,year,semester))
            except:
                cur.execute(rq.curco_slot,(code,name,slot))
    # print(code)

    course = cur.fetchall()
    print(course)
    conn.commit()
    return jsonify({'results':course})

@app.route("/findusergroups/",methods = ['GET'])
def findusergroups():
    print("API Call for Finding Groups")       ## Need to Work On this API
    alias1 = request.args.get('groupalias')
    print(alias1)
    cur.execute(rq.search_group,(alias1,))
    groups = cur.fetchall()
    print(groups)
    conn.commit()
    return jsonify({'results':groups})

@app.route("/findusers/",methods = ['GET'])
def findusers():
    print("API Call for Finding Users")
    alias = request.args.get('alias')
    name = request.args.get('name')
    type = request.args.get('type')
    group = request.args.get('code')
    if (group==''):
        if (type=='0'):
            cur.execute(rq.search_user,(alias,name))
        elif (type=='1'):
            cur.execute(rq.search_stu,(alias,name))
        else:
            cur.execute(rq.search_prof,(alias,name))
        ## Got the only argument now send the json only
    else:
        if (type=='0'):
            cur.execute(rq.search_user_withgroup,(alias,name,group))
        elif (type=='1'):
            cur.execute(rq.search_stu_with_group,(alias,name,group))
        else:
            cur.execute(rq.search_prof_withgroup,(alias,name,group))
    return jsonify({'results':cur.fetchall()})

@app.route("/findevents/",methods = ['GET'])
def findevents():
    print("API Call for Finding Events")       ## Need to Work On this API
    # host = request.args.get('host')
    name = request.args.get('name')
    group = request.args.get('group')

    cur.execute(rq.search_events,(group,name))
    outtarray = cur.fetchall()
    print(outtarray)
    # groups = cur.fetchall()
    # print(course)
    # cur.commit()
    return jsonify({'results':outtarray})


## All directed to Index.html
## React Router Redirects to Respective Components
@app.route("/", methods=['GET', 'POST'])
@app.route("/timetable", methods=['GET','POST'])
@app.route("/search_courses")
@app.route("/search_users")
@app.route("/search_usergroups")
@app.route("/search_events")
@app.route("/insert_course")
@app.route("/insert_event")
@app.route("/insert_usergroup")
def index():
    return render_template('index.html')

@app.route("/courses/<x>")
# @app.route("/student/<x>")
# @app.route("/faculty/<x>")
@app.route("/usergroup/<x>")
@app.route("/event/<x>")
@app.route("/update_course/<x>")
def details(x):
    return render_template('index.html')

@app.route("/user/<x>")
def redirect(x):
    return "Redirect this page to student or faculty on the basis of its category"

if __name__ == "__main__":
    app.config['DEBUG'] = True
    app.run()

# extrra functions
