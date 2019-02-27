# app.py
import os
import requests
import json
# import Crypto
# from Crypto.PublicKey import RSA
# from Crypto import Random
from flask import request, jsonify
from flask import Flask, render_template
import read_queries as rq
import insertions as iq
import Crypto
from Crypto.PublicKey import RSA
from Crypto import Random
import ast
random_generator = Random.new().read
key = RSA.generate(1024, random_generator) #generate pub and priv key
publickey = key.publickey()

# from flask_sqlalchemy import SQLAlchemy
# from models import db
from flask_cors import CORS
curr_year=2018
curr_sem=2
import psycopg2 as ps
conn = ps.connect("dbname=project_3 user=postgres password=Ishu@1003 host=localhost port=5432")
# conn = ps.connect("dbname=postgres user=postgres password=postgres ")
# conn = ps.connect("dbname=group_25 user=group_25 password=887-323-760 host=10.17.50.115 port=5432")
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


## DROP API
@app.route("/change_password/",methods=['GET'])
def changepass():
    alias = request.args.get('alias')
    curr_pass = request.args.get('curr_password')
    new_pass = request.args.get('new_password')
    cur.execute(iq.update_pass,(new_pass,alias,curr_pass))
    success = cur.fetchall()
    if (success!=[]):
        return jsonify({'results':success})
    else:
        return None
@app.route("/check_password/",methods=['GET'])
def checkpass():
    alias = request.args.get('alias')
    password = request.args.get('password')
    cur.execute(iq.login_user,(alias,password))
    success = cur.fetchall()
    if (success!=[]):
        return jsonify({'results':success})
    else:
        return None
@app.route("/drop_course/",methods=['GET'])
def dropCrs():
    course = request.args.get('code')
    alias = request.args.get('alias')
    ### Deregister Student       
    #                       ### YAhan Kaaam kar 
    cur.execute(iq.deregister_student,(course,alias))
    success = cur.fetchall()
    conn.commit()
    print(success)
    if True:
        return jsonify({'results':success})
    else:
        return None



## INSERT API's
@app.route("/slotdetails",methods=['GET'])
def slotdetails():
    slotcode = request.args.get('slot')
    cur.execute(rq.get_slot_details,(slotcode,))
    slotdetails = cur.fetchall()
    return jsonify({'slotdetails':slotdetails,'slotname':slotcode})
@app.route("/update_yearsem",methods=['GET'])
def updatesession():
    global curr_sem
    global curr_year
    curr_sem = 1+ (curr_sem % 2)
    if (curr_sem==1):
        curr_year=curr_year+1
    try:
        cur.execute(iq.update_year_sem,(curr_year,curr_sem))
        return jsonify({'results':curr.fetchall()[0][0]})
    except:
        None
@app.route("/add_slot/",methods=['GET'])
def addslot():
    slotcode = request.args.get('slot')
    begintime = request.args.get('begintime')
    endtime = request.args.get('endtime')
    day = request.args.get('day')
    try:
        cur.execute(create_slot,(slotcode,day,begintime,endtime))
        cur.fetchall()[0][0]
        conn.commit()
        return jsonify({'results':success})
    except:
        return None
    
@app.route("/upd_course/",methods=['GET'])
def updatecourse():
    code = request.args.get('code')
    name = request.args.get('name')
    strength = request.args.get('strength')
    webpage = request.args.get('webpage')
    # 0 indicates change name   # 1 indicate change webpage  # 2 indicates change strength
    try:
        if (type=='0'):               ## Bhai Time Bacha , 3 FIeld ek saath update karde
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
        return None
@app.route("/ins_usergroup/",methods=['GET'])
def addusergroup():
    alias = request.args.get('usergroup')
    try:
        cur.execute(iq.create_group,(alias,))
        success = cur.fetchall()[0][0]
        return jsonify({'results':success})
    except:
        return None
@app.route("/register_student/",methods=['GET'])  
def regstudent():
    groupno = request.args.get('groupno')
    code = request.args.get('code')
    alias = request.args.get('alias')
    try :
        cur.execute(iq.register_student,(alias,code,groupno)) 
        success = cur.fetchall()[0][0]
        cur.commit()                 ## Bhai Yahan Code likh De
        return jsonify({'results':success})
    except:
        return None

@app.route("/remove_user/",methods=['GET'])
def removeuser():
    alias=request.args.get('alias')
    cur.execute(iq.delete_user,(alias,))
    conn.commit()
    return jsonify({'results':''})

@app.route("/removeuser_fromgroup/",methods=['GET'])
def removeuserfromgroup():
    ualias = request.args.get('useralias')
    galias = request.args.get('groupalias')
    cur.execute(iq.delete_user_from_group,(ualias,galias))
    conn.commit()
    return jsonify({'results':''})

@app.route("/removegroupashost/",methods=['GET'])
def removegroupashost():
    groupalias = request.args.get('groupalias')
    hostalias = request.args.get('hostalias')
    cur.execute(iq.grouphost_exist,(groupalias,hostalias))
    e1 = cur.fetchall()
    if (e1==[]): 
        return None
    cur.execute(iq.delete_groups_host,(groupalias,hostalias))
    succ = cur.fetchall()
    if (succ!=[]):
        return None
    else:
        cur.execute(iq.delete_users_groups,(groupalias))
        cur.execute(iq.delete_group,(groupalias))
        conn.commit()
        return jsonify({'results':''})
@app.route("/removegroup",methods=['GET'])
def removegroup():
    alias = request.args.get('groupalias')
    cur.execute(iq.delete_groups_host_all,(alias,))
    cur.execute(iq.delete_usersgroups,(alias,))
    cur.execute(iq.delete_group,(alias,))
    success = cur.fetchall()
    if (success!=[]):
        return jsonify({'results':True})
    else:
        return None


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
    type1 = request.args.get('type')
    # 0 for add weekly time, 1 for add exact date and time
    eventid = request.args.get('eventid')
    ondate = request.args.get('ondate')
    begintime = request.args.get('begintime')
    endtime = request.args.get('endtime')
    venue = request.args.get('venue')
    slot = request.args.get('slot')
    try:
        if type1==0:
            cur.execute(iq.set_eventtimeweekly,(eventid,slot,venue))
        elif type1==1:
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

@app.route("/user_details/",methods = ['GET'])
def user_details():
    alias = request.args.get('alias')
    print(alias)
    cur.execute(rq.get_user_data,(alias,))
    userdata= cur.fetchall()
    print(userdata)
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
    # cur.execute(rq.get_users,(event_group,))
    # event_users = cur.fetchall()
    cur.execute(rq.get_eventtime_weekly,(eventid,))
    event_weekly = cur.fetchall()
    cur.execute(rq.get_eventtime_once,(eventid,))
    event_timeonce = cur.fetchall()
    event_hosts = cur.execute(rq.get_hosts,(event_group,))
    return jsonify({'e_id':eventid,'e_group':event_group,'e_name':event_name,'e_linkto':event_linkto,'e_weekly':event_weekly,'e_hosts':event_hosts,'e_time':event_timeonce})

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
@app.route("/update_user/<x>")
def details(x):
    return render_template('index.html')

@app.route("/user/<x>")
def redirect(x):
    return "Redirect this page to student or faculty on the basis of its category"

if __name__ == "__main__":
    app.config['DEBUG'] = True
    app.run()

# extrra functions
