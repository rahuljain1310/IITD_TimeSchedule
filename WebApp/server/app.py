# app.py
import os
import requests
import json
from flask import request, jsonify
from flask import Flask, render_template
import read_queries
import insertions
# from flask_sqlalchemy import SQLAlchemy
# from models import db
from flask_cors import CORS

import psycopg2 as ps
conn = ps.connect("dbname=postgres user=postgres password=postgres")
cur = conn.cursor()

app = Flask(__name__, static_folder="../frontend/build/static", template_folder="../frontend/build")
CORS(app)

# app = Flask(__name__, static_folder="../frontend/build/static", template_folder="../demo")
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

## API's
@app.route("/course_details/",methods = ['GET'])
<<<<<<< HEAD
def course_details():      ## Returns All courses
    code = request.args.get('code')             ## Got the only argument now send the json only
=======
def course_details():     
    code = request.args.get('code')             ## Got the only argument now send the json only 
>>>>>>> refs/remotes/origin/master
    return jsonify({'results':cour})

@app.route("/student_details/",methods = ['GET'])
def student_details():    
    alias = request.args.get('alias')             ## Got the only argument now send the json only 
    return jsonify({'results':cour})
    
@app.route("/faculty_details/",methods = ['GET'])
def faculty_details():    
    alias = request.args.get('alias')             ## Got the only argument now send the json only 
    return jsonify({'results':cour})

@app.route("/usergroup_details/",methods = ['GET'])
def usergroup_details():    
    groupinput = request.args.get('groupinput')             ## Got the only argument now send the json only 
    cur.execute("select * from demo limit 20")
    course = cur.fetchall()
    print(course)
    return jsonify({'results':cour})

@app.route("/findcourses/",methods = ['GET'])
def findcourses():
    print("API Call for Finding Courses")       ## Need to Work On this API
    code = request.args.get('code')
    print(code)
    cur.execute("select * from demo limit 20")
    course = cur.fetchall()
    print(course)
    return jsonify({'results':course})

@app.route("/findusergroups/",methods = ['GET'])
def findusergroups():
    print("API Call for Finding Courses")       ## Need to Work On this API
    code = request.args.get('code')
    print(code)
    cur.execute("select * from demo limit 20")
    course = cur.fetchall()
    print(course)
    return jsonify({'results':course})

@app.route("/findusers/",methods = ['GET'])
def findusers():
    print("API Call for Finding Users")
    alias = request.args.get('alias')
    name = request.args.get('name')
    usertype = request.args.get('type')
    print(alias+name+usertype)
    query_string = "select * from demo limit 20"   ## Need to Work On this API .. Replace this query
    cur.execute(query_string)
    return jsonify({'results':cur.fetchall()})

## All directed to Index.html
## React Router Redirects to Respective Components
@app.route("/", methods=['GET', 'POST'])
@app.route("/timetable", methods=['GET','POST'])
@app.route("/search_courses")
@app.route("/search_users")
def index():
    return render_template('index.html')

@app.route("/courses/<x>")
@app.route("/student/<x>")
@app.route("/faculty/<x>")
def details(x):
    return render_template('index.html')

@app.route("/user/<x>")
def redirect(x):
    return "Redirect this page to student or faculty on the basis of its category"

if __name__ == "__main__":
    app.config['DEBUG'] = True
    app.run()
