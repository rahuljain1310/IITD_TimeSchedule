# app.py
import os
import requests
import json
from flask import request, jsonify
from flask import Flask, render_template
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

x = { "courses": [
        { "name": "MATHS","code": "MTL106"},
        { "name": "NOL", "code": "COL"}
    ]
}

@app.route("/courses_all",methods = ['GET'])
def courses_all():
    print("Hello")
    return jsonify(x)

@app.route("/courses")
@app.route("/", methods=['GET', 'POST'])
@app.route("/hello")
@app.route("/timetable", methods=['GET','POST'])
def index():
    return render_template('index.html')


if __name__ == "__main__":
    app.config['DEBUG'] = True
    app.run()