drop table coursesoffered;
create table coursesoffered (sno varchar(10), name varchar(100),empt1 varchar(1), slot varchar(2),credits varchar(20),type varchar(20),instructor varchar(100),instructoremail varchar(40),lectime varchar(40), tuttime varchar(20),practime varchar(20),vacancy int, currentstrength int);
\copy CoursesOffered from 'C:/Users/rahul/IITD_TimeSchedule/Courses_Offered_Edit1.csv' DELIMITER '$';
