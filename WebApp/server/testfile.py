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
conn = ps.connect("dbname=project_3 user=postgres host=localhost port=5432 password=Ishu@1003")
cur = conn.cursor()
cur.execute(rq.curco,('col1','data'))
list = cur.fetchall()
