import os
import requests
import json
from flask import request, jsonify
from flask import Flask, render_template
# from flask_sqlalchemy import SQLAlchemy
# from models import db
from flask_cors import CORS

import psycopg2 as ps
conn = ps.connect("dbname=project_3 host=localhost port=5432 user=postgres password=Ishu@1003")
cur = conn.cursor()

app = Flask(__name__, static_folder="../frontend/build/static", template_folder="../frontend/build")
CORS(app)
