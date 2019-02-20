import psycopg2


conn = psycopg2.connect(database = "mydata",host = "localhost" ,user = "rahul" ,password ="stayp",port ="5432")
print ("Connected successfully")
cur = conn.cursor()
cur.execute("create table runproof (num integer , name varchar);")
cur.execute("create table runp (age integer , nam varchar);")
cur.execute("insert into runproof (num,name) values (%s,%s)",(1,'adarsha'))
cur.execute("insert into runproof (num,name) values (%s,%s)",(2,'vishwajeet'))
cur.execute("insert into runproof (num,name) values (%s,%s)",(3,'rahul'))
cur.execute("insert into runproof (num,name) values (%s,%s)",(4,'amal'))
cur.execute("insert into runproof (num,name) values (%s,%s)",(5,'vedant'))
cur.execute("insert into runproof (num,name) values (%s,%s)",(6,'sameerphone'))
cur.execute("insert into runp (age,nam) values (%s,%s)",(20,'sameerphone'))
cur.execute("(select name as name1 from runproof where num=6);")
x =cur.fetchone()[0]
print x
cur.close()

conn.close()
