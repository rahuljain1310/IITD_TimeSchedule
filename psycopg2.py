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
cur.execute("select num from runproof where name = 'sameerphone';")
#now i will show how i would use a variable x of python as a PARAMETER in another query
x= 2*3
cur.execute("create table variable (nume integer );")
cur.execute("insert into variable (nume) values (%s)",(x,))
cur.execute("select name from runproof where num in (select nume from variable);")
y =cur.fetchone()[0]
print(y)

