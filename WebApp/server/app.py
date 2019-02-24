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
conn = ps.connect("dbname=postgres user=postgres password=postgres")
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
cour = [
    {
        "name": "MATHS",
        "code": "MTL106",
    },
    {
        "name": "NOL",
        "code": "COL",
    }
]

## INSERT API's
@app.route("/ins_course/",methods=['GET'])
def insertcourse():
    param = request.args
    print(param)
    # return null
    return jsonify({'results':cour})

@app.route("/ins_event/",methods=['GET'])
def insertevent():
    param = request.args
    print(param)
    # return null
    return jsonify({'results':cour})


## DETAIL API's
@app.route("/course_details/",methods = ['GET'])
def course_details():
    code = request.args.get('code')             ## Got the only argument now send the json only
    return jsonify({'results':cour})

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
    alias = request.args.get('alias')             ## Got the only argument now send the json only
    return jsonify({'results':cour})

@app.route("/usergroup_details/",methods = ['GET'])
def usergroup_details():
    groupinput = request.args.get('groupinput')   ## Got the only argument now send the json only
    cur.execute("select * from courses limit 20")
    course = cur.fetchall()
    print(course)
    return jsonify({'results':cour})

@app.route("/event_details/",methods = ['GET'])
def event_details():
    event = request.args.get('event')   ## Got the only argument now send the json only
    return jsonify({'results':cour})

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
    # print(course)
    conn.commit()
    return jsonify({'results':course})

@app.route("/findusergroups/",methods = ['GET'])
def findusergroups():
    print("API Call for Finding Groups")       ## Need to Work On this API
    alias = request.args.get('groupalias')
    # print(code)
    cur.execute(rq.search_group,alias)
    groups = cur.fetchall()
    # print(course)
    conn.commit()
    return jsonify({'results':groups})

@app.route("/findusers/",methods = ['GET'])
def findusers():
    print("API Call for Finding Users")
    alias = request.args.get('alias')
    name = request.args.get('name')
    usertype = request.args.get('type')
    print(alias+name+usertype)
    # query_string = "select * from demo limit 20"   ## Need to Work On this API .. Replace this query

    if usertype ==1:
        cur.execute(rq.search_stu,(alias,name))
    elif usertype ==2:
        cur.execute(rq.search_prof,(alias,name))
    else:
        cur.execute(rq.search_user,(alias,name))
        conn.commit()
    return jsonify({'results':cur.fetchall()})

@app.route("/findevents/",methods = ['GET'])
def findevents():
    print("API Call for Finding Events")       ## Need to Work On this API
    host = request.args.get('host')
    name = request.args.get('name')
    group = request.args.get('group')
    # cur.execute(rq.search_group,alias)
    # groups = cur.fetchall()
    # print(course)
    # cur.commit()
    return jsonify({'results':cour})


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
@app.route("/register_student")
def index():
    return render_template('index.html')

@app.route("/courses/<x>")
# @app.route("/student/<x>")
# @app.route("/faculty/<x>")
@app.route("/usergroups/<x>")
@app.route("/event/<x>")
def details(x):
    return render_template('index.html')

@app.route("/user/<x>")
def redirect(x):
    return "Redirect this page to student or faculty on the basis of its category"

if __name__ == "__main__":
    app.config['DEBUG'] = True
    app.run()
    
# extrra functions
