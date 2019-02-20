drop table coursesoffered cascade;
create table coursesoffered (SNo integer, CourseName varchar(100),CourseCode varchar(7), Slot varchar(2),Credits float(5),L float(5),T float(5),P float(5),type varchar(10), instructor varchar(100),instructoremail varchar(40),lectime varchar(40), tuttime varchar(20),practime varchar(20),vacancy int, currentstrength int);
\copy CoursesOffered from 'C:/Users/rahul/IITD_TimeSchedule/Courses_Offered_Edit2.csv' DELIMITER '$';
drop table courseslist;
create table courseslist (courseid integer, CourseCode varchar(7));
\copy courseslist from 'C:/Users/rahul/IITD_TimeSchedule/CoursesList.csv' DELIMITER ',';