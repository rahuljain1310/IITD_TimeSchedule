--
-- PostgreSQL database dump
--

-- Dumped from database version 10.6
-- Dumped by pg_dump version 11.1 (Ubuntu 11.1-1.pgdg16.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: classtype; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.classtype AS character(1) NOT NULL
	CONSTRAINT classtype_check CHECK (((VALUE ~~ 'L'::text) OR (VALUE ~~ 'T'::text) OR (VALUE ~~ 'P'::text)));


ALTER DOMAIN public.classtype OWNER TO postgres;

--
-- Name: day; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.day AS character varying(3) NOT NULL
	CONSTRAINT day_check CHECK ((((VALUE)::text ~~ 'Mon'::text) OR ((VALUE)::text ~~ 'Tue'::text) OR ((VALUE)::text ~~ 'Wed'::text) OR ((VALUE)::text ~~ 'Thu'::text) OR ((VALUE)::text ~~ 'Fri'::text) OR ((VALUE)::text ~~ 'Sat'::text) OR ((VALUE)::text ~~ 'Sun'::text)));


ALTER DOMAIN public.day OWNER TO postgres;

--
-- Name: eventtype; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN public.eventtype AS character varying(1) NOT NULL
	CONSTRAINT eventtype_check CHECK ((((VALUE)::text = 'W'::text) OR ((VALUE)::text = 'O'::text)));


ALTER DOMAIN public.eventtype OWNER TO postgres;

--
-- Name: assign_groupto_user(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.assign_groupto_user(hosta1 character varying, groupa1 character varying, usera1 character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
  declare
  verify bool:= exists(select * from groupshost where groupalias = groupa1 and useralias = hosta1);
  begin
    if verify='f' then return 'f'; end if;
    insert into usersgroups values(usera1,groupa1);
    return 't';
  end
  $$;


ALTER FUNCTION public.assign_groupto_user(hosta1 character varying, groupa1 character varying, usera1 character varying) OWNER TO postgres;

--
-- Name: create_event(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_event(useralias1 character varying, alias1 character varying, name1 character varying, linkto character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
  DECLARE
    verify bool:='t';
    group_exists bool;
  begin
    group_exists:= exists(select * from groups where alias = alias1);
    if group_exists = 't' then
      verify:= exists(select * from groupshost where groupalias = alias1 and useralias = useralias1);
      if verify = 'f' then return 'f'; end if;
    end if;
    insert into groups(alias) values(alias1);
    insert into groupshost values (alias1,useralias1);
    insert into events(alias,name,linkto)
    values (alias1,name1,linkto);
    return 't';
END
$$;


ALTER FUNCTION public.create_event(useralias1 character varying, alias1 character varying, name1 character varying, linkto character varying) OWNER TO postgres;

--
-- Name: get_day(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_day(da date) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
    declare
      d int := extract(dow from da);
    begin
      if d = 0 then return 'Sun';
      elsif d = 1 then return 'Mon';
      elsif d = 2 then return 'Tue';
      elsif d = 3 then return 'Wed';
      elsif d = 4 then return 'Thu';
      elsif d = 5 then return 'Fri';
      elsif d = 6 then return 'Sat';
      else return 'Non';
      end if;
    end
    $$;


ALTER FUNCTION public.get_day(da date) OWNER TO postgres;

--
-- Name: insert_new_course(character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_new_course(code character varying, name character varying, slot character varying, type character varying, credits integer, lec_dur integer, tut_dur integer, prac_dur integer, strength integer, registered integer, year integer DEFAULT 2018, semester integer DEFAULT 2) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
   INSERT INTO courses(code,name,slot,type,credits,lec_dur,
     tut_dur,prac_dur,strength,registered,year,semester) VALUES (code,name,slot,type,credits,lec_dur,
       tut_dur,prac_dur,strength,registered,year,semester);
   INSERT INTO curr_courses(code,name,slot,type,credits,lec_dur,
     tut_dur,prac_dur,strength,registered) VALUES (code,name,slot,type,credits,lec_dur,
       tut_dur,prac_dur,strength,registered);
END
$$;


ALTER FUNCTION public.insert_new_course(code character varying, name character varying, slot character varying, type character varying, credits integer, lec_dur integer, tut_dur integer, prac_dur integer, strength integer, registered integer, year integer, semester integer) OWNER TO postgres;

--
-- Name: insert_prof_in_course(character varying, character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_prof_in_course(alias1 character varying, code1 character varying, year integer DEFAULT 2018, sem integer DEFAULT 2) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
insert into curr_prof_course (
  select userid,curr_courses.courseid
  from curr_courses,users
  where users.alias = alias1 and curr_courses.code = code1
);

insert into profbycourse (
  select userid,courses.courseid
  from courses,users
  where users.alias = alias1 and courses.code = code1
  and year = year and semester = sem
);
END
$$;


ALTER FUNCTION public.insert_prof_in_course(alias1 character varying, code1 character varying, year integer, sem integer) OWNER TO postgres;

--
-- Name: insert_stu_in_course(character varying, character varying, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_stu_in_course(alias1 character varying, code1 character varying, grouped integer, year integer DEFAULT 2018, sem integer DEFAULT 2) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
insert into curr_stu_course (
 select userid,curr_courses.courseid
 from curr_courses,users
 where users.alias = alias1 and curr_courses.code = code1
 and groupedin = grouped
);

insert into studentsincourse(
 select userid,courses.courseid
 from courses,users
 where users.alias = alias1 and courses.code = code1
 and year = year and semester = sem
);
END
$$;


ALTER FUNCTION public.insert_stu_in_course(alias1 character varying, code1 character varying, grouped integer, year integer, sem integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: courses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.courses (
    courseid integer NOT NULL,
    code character varying(8) NOT NULL,
    name character varying(120),
    slot character varying(4),
    type character varying(10),
    credits double precision,
    lec_dur double precision,
    tut_dur double precision,
    prac_dur double precision,
    strength integer,
    registered integer,
    year integer,
    semester integer,
    CONSTRAINT courses_check CHECK ((credits = ((lec_dur + tut_dur) + (prac_dur / (2)::double precision)))),
    CONSTRAINT courses_semester_check CHECK (((semester = 1) OR (semester = 2)))
);


ALTER TABLE public.courses OWNER TO postgres;

--
-- Name: coursesbyprof; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.coursesbyprof (
    profid integer,
    courseid integer
);


ALTER TABLE public.coursesbyprof OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    userid integer NOT NULL,
    alias character varying(30) NOT NULL,
    name character varying(70),
    webpage character varying(100),
    password character varying(100)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: courses_by_prof; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.courses_by_prof AS
 SELECT users.alias AS profalias,
    users.name AS profname,
    courses.code,
    courses.name AS coursename,
    courses.slot,
    courses.type,
    courses.credits,
    courses.lec_dur,
    courses.tut_dur,
    courses.prac_dur,
    courses.registered,
    courses.strength,
    courses.year,
    courses.semester
   FROM public.users,
    (public.coursesbyprof
     JOIN public.courses USING (courseid))
  WHERE (users.userid = coursesbyprof.profid);


ALTER TABLE public.courses_by_prof OWNER TO postgres;

--
-- Name: courses_courseid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.courses_courseid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.courses_courseid_seq OWNER TO postgres;

--
-- Name: courses_courseid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.courses_courseid_seq OWNED BY public.courses.courseid;


--
-- Name: studentsincourse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.studentsincourse (
    studentid integer,
    courseid integer
);


ALTER TABLE public.studentsincourse OWNER TO postgres;

--
-- Name: courses_of_student; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.courses_of_student AS
 SELECT users.alias AS entrynum,
    users.name AS studentname,
    courses.code,
    courses.name AS coursename,
    courses.year,
    courses.semester,
    courses.slot,
    courses.type,
    courses.credits,
    courses.lec_dur,
    courses.tut_dur,
    courses.prac_dur,
    courses.registered,
    courses.strength
   FROM public.users,
    (public.studentsincourse
     JOIN public.courses USING (courseid))
  WHERE (users.userid = studentsincourse.studentid);


ALTER TABLE public.courses_of_student OWNER TO postgres;

--
-- Name: curr_courses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.curr_courses (
    courseid integer NOT NULL,
    code character varying(8) NOT NULL,
    name character varying(120),
    slot character varying(4),
    type character varying(10),
    credits double precision,
    lec_dur double precision,
    tut_dur double precision,
    prac_dur double precision,
    strength integer,
    registered integer,
    webpage character varying(100),
    CONSTRAINT curr_courses_check CHECK ((credits = ((lec_dur + tut_dur) + (prac_dur / (2)::double precision))))
);


ALTER TABLE public.curr_courses OWNER TO postgres;

--
-- Name: curr_prof; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.curr_prof (
    profalias character varying(30) NOT NULL,
    profname character varying(70)
);


ALTER TABLE public.curr_prof OWNER TO postgres;

--
-- Name: curr_prof_course; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.curr_prof_course (
    profalias character varying(30),
    courseid integer
);


ALTER TABLE public.curr_prof_course OWNER TO postgres;

--
-- Name: curr_courses_by_prof; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.curr_courses_by_prof AS
 SELECT curr_prof.profalias,
    curr_prof.profname,
    curr_courses.code,
    curr_courses.name AS coursename,
    curr_courses.slot,
    curr_courses.type,
    curr_courses.credits,
    curr_courses.lec_dur,
    curr_courses.tut_dur,
    curr_courses.prac_dur,
    curr_courses.registered,
    curr_courses.strength
   FROM ((public.curr_prof
     JOIN public.curr_prof_course USING (profalias))
     JOIN public.curr_courses USING (courseid));


ALTER TABLE public.curr_courses_by_prof OWNER TO postgres;

--
-- Name: curr_courses_courseid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.curr_courses_courseid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.curr_courses_courseid_seq OWNER TO postgres;

--
-- Name: curr_courses_courseid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.curr_courses_courseid_seq OWNED BY public.curr_courses.courseid;


--
-- Name: curr_stu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.curr_stu (
    entrynum character varying(30) NOT NULL,
    studentname character varying(70)
);


ALTER TABLE public.curr_stu OWNER TO postgres;

--
-- Name: curr_stu_course; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.curr_stu_course (
    entrynum character varying(30),
    courseid integer,
    groupedin integer
);


ALTER TABLE public.curr_stu_course OWNER TO postgres;

--
-- Name: curr_courses_of_student; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.curr_courses_of_student AS
 SELECT curr_stu.entrynum,
    curr_stu.studentname,
    curr_courses.code,
    curr_courses.name AS coursename,
    curr_courses.type,
    curr_courses.slot,
    curr_stu_course.groupedin,
    curr_courses.credits,
    curr_courses.lec_dur,
    curr_courses.tut_dur,
    curr_courses.prac_dur,
    curr_courses.registered,
    curr_courses.strength
   FROM ((public.curr_courses
     JOIN public.curr_stu_course USING (courseid))
     JOIN public.curr_stu USING (entrynum));


ALTER TABLE public.curr_courses_of_student OWNER TO postgres;

--
-- Name: events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.events (
    id integer NOT NULL,
    alias character varying(30),
    name character varying(120),
    linkto character varying(120)
);


ALTER TABLE public.events OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_id_seq OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    gid integer NOT NULL,
    alias character varying(30) NOT NULL
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- Name: groups_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.groups_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.groups_gid_seq OWNER TO postgres;

--
-- Name: groups_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.groups_gid_seq OWNED BY public.groups.gid;


--
-- Name: groupshost; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groupshost (
    id integer,
    useralias character varying(30)
);


ALTER TABLE public.groupshost OWNER TO postgres;

--
-- Name: onetimeeventtime; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.onetimeeventtime (
    id integer,
    ondate date,
    begintime time(0) without time zone,
    endtime time(0) without time zone,
    venue character varying(30)
);


ALTER TABLE public.onetimeeventtime OWNER TO postgres;

--
-- Name: slotdetails; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slotdetails (
    slotname character varying(4),
    days public.day NOT NULL,
    begintime time(0) without time zone NOT NULL,
    endtime time(0) without time zone NOT NULL
);


ALTER TABLE public.slotdetails OWNER TO postgres;

--
-- Name: users_userid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_userid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_userid_seq OWNER TO postgres;

--
-- Name: users_userid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_userid_seq OWNED BY public.users.userid;


--
-- Name: usersgroups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usersgroups (
    useralias character varying(30),
    groupalias character varying(30)
);


ALTER TABLE public.usersgroups OWNER TO postgres;

--
-- Name: weeklyeventtime; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weeklyeventtime (
    id integer,
    slotname character varying(4) NOT NULL
);


ALTER TABLE public.weeklyeventtime OWNER TO postgres;

--
-- Name: courses courseid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courses ALTER COLUMN courseid SET DEFAULT nextval('public.courses_courseid_seq'::regclass);


--
-- Name: curr_courses courseid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.curr_courses ALTER COLUMN courseid SET DEFAULT nextval('public.curr_courses_courseid_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: groups gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups ALTER COLUMN gid SET DEFAULT nextval('public.groups_gid_seq'::regclass);


--
-- Name: users userid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN userid SET DEFAULT nextval('public.users_userid_seq'::regclass);


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.courses (courseid, code, name, slot, type, credits, lec_dur, tut_dur, prac_dur, strength, registered, year, semester) FROM stdin;
1	AMD310	MINI PROJECT (AM)                                  	P	""	3	0	0	6	30	7	2018	2
2	AMD811	MAJOR PROJECT PART I                               	P	""	6	0	0	12	30	0	2018	2
3	AMD812	MAJOR PROJECT PART II                              	P	""	12	0	0	24	30	31	2018	2
4	AMD813	MAJOR PROJECT PART I                               	P	""	6	0	0	12	30	1	2018	2
5	AMD814	MAJOR PROJECT PART II                              	P	""	12	0	0	24	30	4	2018	2
6	AMD895	MAJOR PROJECT                                      	P	""	40	0	0	80	30	2	2018	2
7	AMD897	MINOR PROJECT                                      	X	""	4	0	0	8	60	25	2018	2
8	AML702	APPLIED COMPUTATIONAL METHOD                       	F	""	4	3	0	2	100	36	2018	2
9	AML706	FINITE ELEMENT METHODS & ITS APPL.TO MARINE STRU.  	B	""	3	3	0	0	100	32	2018	2
10	AML731	APPLIED ELASTICITY                                 	X	""	4	3	1	0	60	9	2018	2
11	AML793	SHIP DYNAMICS                                      	X	""	3	3	0	0	60	25	2018	2
12	AML795	SUBMARINE DESIGN                                   	X	""	3	3	0	0	60	25	2018	2
13	AML831	THEORY OF PLATES AND SHELLS                        	A	""	3	3	0	0	50	21	2018	2
14	AML832	APPLICATIONS OF THEORY OF PLATES AND SHELLS        	A	""	2	2	0	0	50	29	2018	2
15	AML835	MECHANICS OF COMPOSITE MATERIALS                   	X	""	3	3	0	0	40	20	2018	2
16	AMP776	PRODUCT DESIGN PROJECT 1                           	F	""	4	2	0	4	60	20	2018	2
17	APL100	ENGINEERING MECHANICS                              	A	""	4	3	1	0	250	469	2018	2
18	APL102	INTR.TO MATERIAL SC. & ENGG.                       	E	""	4	3	0	2	300	131	2018	2
19	APL105	MECHANICS OF SOLIDS AND FLUIDS                     	A	""	4	3	1	0	150	122	2018	2
20	APL300	COMPUTATIONAL MECHANICS                            	A	""	4	3	0	2	100	31	2018	2
21	APL705	FINITE ELEMENT METHOD                              	B	""	4	3	0	2	100	53	2018	2
22	APL711	ADVANCED FLUID MECHANICS                           	C	""	3	3	0	0	50	12	2018	2
23	APL713	TURBULENCE AND ITS MODELING                        	D	""	3	3	0	0	50	20	2018	2
24	APL720	COMPUTATIONAL FLUID DYNAMICS                       	E	""	4	3	0	2	50	22	2018	2
25	APL750	MODERN ENGINEERING MATERIALS                       	A	""	3	3	0	0	50	13	2018	2
26	APL767	ENGG. FAILURE ANALYSIS & PREV.                     	AC	""	3	3	0	0	40	15	2018	2
27	APL774	MODELING AND ANALYSIS                              	AA	""	3	3	0	0	40	9	2018	2
28	APL796	ADVANCED SOLID MECHANICS                           	X	""	3	3	0	0	50	19	2018	2
29	APL871	PRODUCT RELIABILITY & MAINTENANCE                  	H	""	3	3	0	0	60	33	2018	2
30	APV707	Micromechanics of Fracture 	X	""	1	1	0	0	30	0	2018	2
31	ASD882	PROJECT II                                         	Q	""	12	0	0	24	12	12	2018	2
32	ASL340	Fundamentals of Weather and Climate 	F	PC	3	3	0	0	80	68	2018	2
33	ASL350	INTRODUCTION TOOCEANOGRAPHY                        	B	""	3	3	0	0	80	71	2018	2
34	ASL360	THE EARTH`S ATMOSPHERE:PHYSICAL PRINCIPLES         	M	""	3	3	0	0	80	80	2018	2
35	ASL734	DYNAMICS OF THE ATMOSPHERE                         	H	""	3	3	0	0	30	24	2018	2
36	ASL736	SCIENCE OF CLIMATE CHANGE                          	J	""	3	3	0	0	25	21	2018	2
37	ASL737	PHYSICAL AND DYNAMICAL OCEANOGRAPHY                	E	""	3	3	0	0	25	14	2018	2
38	ASL738	NUMERICAL MODELING OF THE ATMOSPHERE AND OCEAN     	AD	""	3	2	0	2	16	14	2018	2
39	ASL751	DISPERSION OF AIR POLLUTANTS                       	F	""	3	3	0	0	40	21	2018	2
40	ASL754	CLOUD PHYSICS                                      	B	""	3	3	0	0	50	7	2018	2
41	ASL760	RENEWABLE ENERGY METEOROLOGY                       	M	""	3	3	0	0	25	5	2018	2
42	ASP820	ADVANCED DATA ANALYSIS FOR WEATHER AND CLIMATE     	K	""	3	1	0	4	15	12	2018	2
43	BBD451	MAJOR PROJECT PART 1 (BB1)                         	P	""	3	0	0	6	30	4	2018	2
44	BBD452	MAJOR PROJECT PART 2 (BB1)                         	Q	""	8	0	0	16	100	0	2018	2
45	BBD851	MAJOR PROJECT PART 1 (BB5)                         	Q	""	6	0	0	12	60	0	2018	2
46	BBD852	MAJOR PROJECT PART 2 (BB5)                         	Q	""	14	0	0	28	60	5	2018	2
47	BBD853	MAJOR PROJECT PART 1 (BB5)                         	Q	""	4	0	0	8	60	0	2018	2
48	BBD854	MAJOR PROJECT PART 2 (BB5)                         	Q	""	16	0	0	32	60	11	2018	2
49	BBD895	MAJOR PROJECT                                      	Q	""	36	0	0	72	60	11	2018	2
50	BBL341	ENVIRONMENTAL BIOTECHNOLOGY                        	H	DE	3	3	0	0	100	13	2018	2
51	BBL431	BIOPROCESS TECHNOLOGY                              	J	DC	2	2	0	0	100	77	2018	2
52	BBL432	FLUID SOLID SYSTEMS                                	H	DC	2	2	0	0	100	56	2018	2
53	BBL433	ENZYME SCIENCE AND ENGINEERING                     	D	DC	4	3	0	2	100	55	2018	2
54	BBL434	BIOINFORMATICS                                     	C	DC	3	2	0	2	100	73	2018	2
55	BBL443	MODELING & SIMULATION OF BIO.                      	J	DE	4	3	0	2	100	13	2018	2
56	BBL445	MEMBRANE APPLICATIONS IN BIO.                      	E	DE	3	3	0	0	100	33	2018	2
57	BBL736	DYNAMICS OF MICROBIAL SYSTEMS                      	B	""	3	3	0	0	60	27	2018	2
58	BBL740	PLANT CELL TECHNOLOGY                              	K	""	3	2	0	2	60	19	2018	2
59	BBL742	BIOLOGICAL WASTE TREATMENT                         	D	""	4	3	0	2	60	32	2018	2
60	BBL745	COMBINATORIAL BIOTECHNOLOGY                        	J	""	3	3	0	0	60	25	2018	2
61	BBL746	CURRENT TOPICS IN BIOCHEMICALENGINEERING AND BIOTE 	H	""	3	3	0	0	60	15	2018	2
62	BBL747	BIONANOTECHNOLOGY                                  	E	""	3	3	0	0	60	22	2018	2
63	BBL749	CANCER CELL BIOLOGY                                	F	""	4.5	3	0	3	60	36	2018	2
64	BBQ301	SEMINAR COURSE   I                                 	Q	""	1	0	0	2	20	20	2018	2
65	BBQ302	SEMINAR COURSE   II                                	Q	""	1	0	0	2	20	16	2018	2
66	BBQ303	SEMINAR COURSE   III                               	Q	""	1	0	0	2	20	20	2018	2
67	BED800	MAJOR PROJECT                                      	P	""	40	0	0	80	10	1	2018	2
68	BMD802	Major Project 2 	X	PC	12	0	0	24	60	7	2018	2
69	BML735	BIOMEDICAL SIGNAL AND IMAGE PR                     	AD	PE	3	2	0	2	60	35	2018	2
70	BML737	APPLICATIONS OF MATHEMATICS IN BIOMEDICAL ENG.     	D	PC	2	2	0	0	60	16	2018	2
71	BML740	BIOMEDICAL INSTRUMENTATION                         	E	PC	3	3	0	0	60	17	2018	2
72	BML750	POINT OF CARE MEDICAL DIAG DEV                     	F	PE	3	3	0	0	60	5	2018	2
73	BML760	BIOMEDICAL ETHICS, SAFETY AND REGULATORY AFFAIRS   	B	PC	2	2	0	0	60	9	2018	2
74	BML771	Orthopaedic Device Design 	H	PE	2	2	0	0	60	8	2018	2
75	BML820	BIOMATERIALS                                       	J	PE	3	3	0	0	60	8	2018	2
76	BML860	NANOMEDICINE                                       	K	PE	3	3	0	0	60	9	2018	2
77	BMP743	BASIC BIOMEDICAL LABORATORY                        	X	PC	2	0	0	4	60	7	2018	2
78	BSD895	MAJOR PROJECT(MSR)                                 	P	""	40	0	0	80	60	4	2018	2
79	CHD771	MINOR PROJECT                                      	Q	PC	4	0	0	8	60	0	2018	2
80	CHD871	MAJOR PROJECT PART 1 (CM)                          	Q	PC	6	0	0	12	60	2	2018	2
81	CHD872	MAJOR PROJECT PART II (CM)                         	Q	PC	14	0	0	28	60	1	2018	2
82	CHD873	MAJOR PROJECT PART 1 (CM)                          	Q	PC	4	0	0	8	60	0	2018	2
83	CHD874	MAJOR PROJECT PART 2 (CM)                          	Q	PC	16	0	0	32	60	0	2018	2
84	CLD411	B. TECH. PROJECT                                   	Q	DC	4	0	0	8	100	13	2018	2
85	CLD412	MAJOR PROJECT IN ENERGY & ENV.                     	Q	DE	5	0	0	10	100	5	2018	2
86	CLD413	MAJOR PROJECT IN COMPLEX FLUID                     	Q	DE	5	0	0	10	100	0	2018	2
87	CLD414	MAJOR PROJ. IN P.E, MOD. & OP.                     	Q	DE	5	0	0	10	100	0	2018	2
88	CLD415	MAJOR PROJ IN BIOP. & FINE CH.                     	Q	DE	5	0	0	10	100	3	2018	2
89	CLD771	MINOR PROJECT                                      	Q	PC	3	0	0	6	60	32	2018	2
90	CLD781	MAJOR PROJECT   I                                  	Q	PC	8	0	0	16	60	1	2018	2
91	CLD782	MAJOR PROJECT   II                                 	Q	PC	12	0	0	24	60	15	2018	2
92	CLD880	MINOR PROJECT                                      	Q	PC	4	0	0	8	60	42	2018	2
93	CLD881	MAJOR PROJECT PARTI                                	Q	PC	8	0	0	16	60	2	2018	2
94	CLD882	MAJOR PROJECT PARTII                               	Q	PC	12	0	0	24	60	39	2018	2
95	CLL121	CHEMICAL ENGG. THERMODYNAMICS                      	A	DC	4	3	1	0	100	143	2018	2
96	CLL122	CHEMICAL REACTION ENGG I                           	D	DC	4	3	1	0	100	178	2018	2
97	CLL231	FLUID MECHS. FOR CHEM. ENGINEE                     	F	DC	4	3	1	0	100	194	2018	2
98	CLL251	HEAT TRANSFER FOR CHEMICAL ENG                     	B	DC	4	3	1	0	100	187	2018	2
99	CLL271	INTRO TO INDUSTRIAL BIOTECH.                       	D	DC	3	3	0	0	100	108	2018	2
100	CLL352	MASS TRANSFER II                                   	B	DC	4	3	1	0	100	118	2018	2
101	CLL361	INSTRUMENTATION AND AUTOMATION                     	C	DC	2.5	1	0	3	100	106	2018	2
102	CLL371	CHEM. PROCESS TECH.& ECONOMICS                     	E	DC	4	3	1	0	100	127	2018	2
103	CLL402	PROCESS PLANT DESIGN                               	D	DE	3	3	0	0	50	12	2018	2
104	CLL475	SAFETY & HAZARDS IN PROC. IND.                     	B	DE	3	3	0	0	50	25	2018	2
105	CLL722	ELECTROCHEM. CONV. & STO. DEV.                     	B	""	3	3	0	0	50	36	2018	2
106	CLL727	HETERO. CATALYSIS & CATA. REA.                     	E	""	3	3	0	0	50	41	2018	2
107	CLL731	ADVANCED TRANSPORT PHENOMENA                       	A	""	3	3	0	0	60	100	2018	2
108	CLL732	ADV. CHE. ENGG. THERMODYNAMICS                     	AA	""	3	3	0	0	60	20	2018	2
109	CLL733	INDUSTRIAL MULTIPHASE REACTORS                     	H	PC,DE,PE	3	3	0	0	110	115	2018	2
110	CLL766	INTERFACIAL ENGINEERING                            	F	""	3	3	0	0	50	61	2018	2
111	CLL767	STRUCTURES & PROP. OF POLYMERS                     	B	""	3	3	0	0	50	22	2018	2
112	CLL768	FUNDAMENTALS OF COMP. FLUID DY                     	F	""	3	2	0	2	30	12	2018	2
113	CLL771	INTRODUCTION TO COMPLEX FLUIDS                     	F	""	3	3	0	0	50	32	2018	2
114	CLL772	TRANS. PHEN. IN COMPLEX FLUIDS                     	E	""	3	3	0	0	50	12	2018	2
115	CLL779	MOL. BIOTECH. & IN VITRO DIAG.                     	D	""	3	3	0	0	50	12	2018	2
116	CLL782	PROCESS OPTIMIZATION                               	E	""	3	3	0	0	50	34	2018	2
117	CLL786	FINE CHEMICALS TECHNOLOGY                          	E	""	3	3	0	0	50	56	2018	2
118	CLL788	Process Data Analytics 	D	""	3	3	0	0	60	56	2018	2
119	CLL793	MEMBRANE SCIENCE & ENGINEERING                     	F	""	3	3	0	0	50	50	2018	2
120	CLP302	CHEMICAL ENGINEERING LAB   II                      	E	DC	1.5	0	0	3	100	159	2018	2
121	CLP704	TECHNICAL COMMUNICATION FOR CHEMICAL ENGINEERS     	Q	""	1	0	0	2	60	66	2018	2
122	CLQ301	SEMINAR COURSE   I                                 	P	""	1	0	0	2	35	43	2018	2
123	CLQ302	SEMINAR COURSE   II                                	Q	""	1	0	0	2	35	33	2018	2
124	CLV797	RECENT  ADV. IN CHEMICAL ENGG.                     	X	""	2	2	0	0	60	8	2018	2
125	CMD641	PROJECT PART II                                    	P	""	10	0	0	20	60	49	2018	2
126	CMD807	MAJOR  PROJECT PART   II                           	P	""	9	0	0	18	30	11	2018	2
127	CML100	INTRODUCTION TO CHEMISTRY                          	D	""	3	3	0	0	200	461	2018	2
128	CML521	MOLECULAR THERMODYNAMICS                           	C	""	3	3	0	0	60	55	2018	2
129	CML522	CHEMICAL DYNA. & SURFACE CHEM.                     	F	""	3	3	0	0	60	54	2018	2
130	CML523	ORGANIC SYNTHESIS                                  	D	""	3	3	0	0	60	55	2018	2
131	CML524	TRAN. & INNER TRAN. METAL CHE.                     	A	""	3	3	0	0	60	54	2018	2
132	CML525	BASIC ORGANOMETALIC CHEMISTRY                      	B	""	3	3	0	0	60	54	2018	2
133	CML526	STR. & FUNC. OF CELLULAR BIOM.                     	E	""	3	3	0	0	60	54	2018	2
134	CML665	BIOPHYSICAL CHEMISTRY                              	D	""	3	3	0	0	60	8	2018	2
135	CML673	Bio organic and Medicinal chemistry                	F	""	3	3	0	0	60	7	2018	2
136	CML682	Inorganic Polymers 	E	PC	3	3	0	0	60	30	2018	2
137	CML724	SYNTHESIS OF INDUSTRIALLY IMPO                     	H	""	3	3	0	0	60	30	2018	2
138	CML729	MATERIAL CHARACTERIZATION                          	C	""	3	3	0	0	60	28	2018	2
139	CML737	APPLIED SPECTROSCOPY                               	E	""	3	3	0	0	60	31	2018	2
140	CML738	APPLICATIONS OF P BLOCK ELEMEN                     	B	""	3	3	0	0	60	16	2018	2
141	CML739	APPLIED BIOCATALYSIS                               	K	""	3	3	0	0	60	28	2018	2
142	CML740	CHEMISTRY OF HETEROCYCLIC COMP                     	A	""	3	3	0	0	60	33	2018	2
143	CML801	MOLECULAR MODELLING AND SIMULA                     	B	""	3	3	0	0	60	21	2018	2
144	CMP100	CHEMISTRY LABORATORY                               	P	""	2	0	0	4	1000	458	2018	2
145	CMP521	LAB III                                            	P	""	2	0	0	4	240	53	2018	2
146	CMP522	LAB IV                                             	P	""	2	0	0	4	240	53	2018	2
147	CMP728	INSTRUMENTATION LABORATORY                         	P	""	3	0	0	6	60	8	2018	2
148	COD310	MINI PROJECT                                       	P	""	3	0	0	6	40	27	2018	2
149	COD492	B.TECH PROJECT PART 1                              	P	""	6	0	0	12	120	4	2018	2
150	COD494	B.TECH PROJECT PART 2                              	P	""	8	0	0	16	120	40	2018	2
151	COD891	MINOR PROJECT                                      	P	""	3	0	0	6	80	51	2018	2
152	COD892	M.TECH PROJECT PARTI                               	P	""	7	0	0	14	40	0	2018	2
153	COD893	M.TECH PROJECT PARTII                              	P	""	14	0	0	28	50	43	2018	2
154	COD895	MSR PROJECT                                        	P	""	36	0	0	72	30	5	2018	2
155	COL100	INTRO. TO COMPUTER SCIENCE                         	B	""	4	3	0	2	600	513	2018	2
156	COL106	DATA STRUCTURES AND ALGORITHMS                     	F	""	5	3	0	4	180	206	2018	2
157	COL216	COMPUTER ARCHITECTURE                              	B	""	4	3	0	2	125	113	2018	2
158	COL226	PROGRAMMING LANGUAGES                              	F	""	5	3	0	4	140	127	2018	2
159	COL331	OPERATING SYSTEMS                                  	E	""	5	3	0	4	120	121	2018	2
160	COL352	INTRO TO AUTOMATA & TH. OF CO.                     	H	""	3	3	0	0	125	120	2018	2
161	COL362	INTRO. TO DATABASE MGMT. SYST.                     	C	""	4	3	0	2	150	115	2018	2
162	COL380	INTRO. TO PARALLEL & DIS. PRO.                     	J	""	3	2	0	2	120	122	2018	2
163	COL632	INTRODUCTION TO DATA BASESYSTEMS                   	C	""	4	3	0	2	30	15	2018	2
164	COL633	RESOURCE MANAGEMENT IN COMPUTER SYSTEMS            	E	""	4	3	0	2	30	3	2018	2
165	COL724	ADVANCED COMPUTER NETWORKS                         	D	""	4	3	0	2	40	21	2018	2
166	COL726	NUMERICAL ALGORITHMS                               	M	""	4	3	0	2	70	53	2018	2
167	COL729	COMPILER OPTIMIZATION                              	A	""	4.5	3	0	3	45	11	2018	2
168	COL740	SOFTWARE ENGINEERING                               	H	""	4	3	0	2	95	64	2018	2
169	COL758	ADVANCED ALGORITHMS                                	B	""	4	3	0	2	50	32	2018	2
170	COL772	NATURAL LANGUAGE PROCESSING                        	AA	""	4	3	0	2	30	45	2018	2
171	COL774	MACHINE LEARNING                                   	F	""	4	3	0	2	130	137	2018	2
172	COL781	COMPUTER GRAPHICS                                  	K	""	4.5	3	0	3	90	53	2018	2
173	COL786	ADVANCED FUNCTIONAL BRAIN IMG.                     	AC	""	4	3	0	2	30	20	2018	2
174	COL812	SYSTEM LEVEL DESIGN& MODELLING                     	C	""	3	3	0	0	30	6	2018	2
175	COL863	SPL. TOPICS IN THEO. COMP. SC. 	AC	""	3	3	0	0	40	25	2018	2
176	COL864	SPL. TOPICS IN ARTIFICIAL INT.                     	AA	""	3	3	0	0	30	23	2018	2
177	COL872	SPL. TOPICS IN CRYPTOGRAPHY                        	AD	""	3	3	0	0	30	30	2018	2
178	COL886	Special Topics in Operating Systems 	AC	""	3	3	0	0	15	6	2018	2
179	COP290	DESIGN PRACTICES                                   	P	""	3	0	0	6	120	135	2018	2
180	COP315	EMBEDDED SYSTEM DESIGN PROJECT                     	P	""	4	0	1	6	100	56	2018	2
181	COP701	SOFTWARE SYSTEMS LABORATORY                        	P	""	3	0	0	6	40	2	2018	2
182	COQ301	SEMINAR COURSE   I                                 	P	""	1	0	0	2	60	22	2018	2
183	COQ302	SEMINAR COURSE   II                                	P	""	1	0	0	2	60	29	2018	2
184	COQ303	SEMINAR COURSE   III                               	P	""	1	0	0	2	60	19	2018	2
185	COQ304	SEMINAR COURSE   IV                                	P	""	1	0	0	2	60	24	2018	2
186	COS310	INDEPENDENT STUDY (CS)                             	P	""	3	0	3	0	30	13	2018	2
187	COS799	INDEPENDENT STUDY                                  	P	""	3	0	3	0	30	6	2018	2
188	COV878	SPECIAL MODULE IN MACHINE LEA.                     	X	""	1	1	0	0	60	27	2018	2
189	COV880	SPECIAL MODULE IN PARALLEL CO.                     	X	""	1	1	0	0	30	7	2018	2
190	COV883	SPL. MODULE IN THEO. COMP. SC.                     	P	""	1	1	0	0	60	7	2018	2
191	COV884	SPL. MODULE IN ARTIFICIAL INT.                     	X	""	1	1	0	0	30	7	2018	2
192	COV887	SPL. MODULE IN HIGH SPEED NET.                     	X	""	1	1	0	0	30	22	2018	2
193	COV888	SPL. MODULE IN DATABASE SYST.                      	X	""	1	1	0	0	30	8	2018	2
194	CRD802	MINOR PROJECT                                      	A	PC	3	0	0	6	60	25	2018	2
195	CRD811	MAJOR PROJECT PART I                               	Q	PC	6	0	0	12	60	1	2018	2
196	CRD812	MAJOR PROJECT PART 2                               	Q	PC	12	0	0	24	60	22	2018	2
197	CRD814	MAJOR PROJECT III                                  	Q	PC	6	0	0	12	60	1	2018	2
198	CRL702	ARCHITECTURES AND ALGORITHMS FOR DSP SYSTEMS       	E	PC	4	2	0	4	40	27	2018	2
199	CRL704	SENSOR ARRAY SIGNAL PROCESSING                     	H	""	3	3	0	0	60	15	2018	2
200	CRL706	SONARS                                             	J	PE	3	3	0	0	60	7	2018	2
201	CRL712	RF AND MICROWAVE ACTIVE CIRCUITS                   	A	PE	3	3	0	0	60	26	2018	2
202	CRL722	RF AND MICROWAVE SOLID STATE DEVICES               	H	PE	3	3	0	0	60	10	2018	2
203	CRL724	RF AND MICROWAVE MEASUREMENT SYSTEM TECHNIQUES     	B	PC	3	3	0	0	60	27	2018	2
204	CRL732	SELECTED TOPICS IN RFDT II                         	D	PE	3	3	0	0	60	8	2018	2
205	CRV742	SPECIAL MODULE IN RADIO FREQUENCY DESIGN & TECH. I 	X	""	1	1	0	0	20	20	2018	2
206	CSD411	MAJOR PROJECT PART 1 (CS)                          	P	""	4	0	0	8	40	0	2018	2
207	CSD853	MAJOR PROJECT PART 1 (CO)                          	P	""	4	0	0	8	40	0	2018	2
208	CVC772	SEMINAR IN CONSTRUCTION TECHNO                     	R	""	1	0	0	2	30	30	2018	2
209	CVD411	BTECH PROJECT PART 1                               	P	""	4	0	0	8	120	30	2018	2
210	CVD412	BTECH PROJECT PART 2                               	P	""	6	0	0	12	120	15	2018	2
211	CVD700	MINOR PROJECT                                      	P	""	3	0	0	6	5	0	2018	2
212	CVD710	MINOR PROJECT                                      	P	""	3	0	0	6	5	0	2018	2
213	CVD720	MAJOR THESIS PART I                                	M	""	6	0	0	12	24	0	2018	2
214	CVD721	MAJOR THESIS PART II                               	M	""	12	0	0	24	25	6	2018	2
215	CVD756	MINOR PROJECT IN STRUCTURAL ENGINEERING            	P	""	3	0	0	6	50	0	2018	2
216	CVD757	MAJOR PROJECT PART I (CES)                         	P	""	9	0	0	18	50	0	2018	2
217	CVD758	MAJOR PROJECT PART II (CES)                        	P	""	9	0	0	18	50	17	2018	2
218	CVD772	MAJOR PROJECT PART I (CEC)                         	P	""	9	0	0	18	50	0	2018	2
219	CVD773	MAJOR PROJECT PART II (CEC)                        	P	""	12	0	0	24	30	24	2018	2
220	CVD776	MINOR PROJECT (CET)                                	P	""	3	0	0	6	50	0	2018	2
221	CVD777	MAJOR PROJECT PART I (CET)                         	P	""	9	0	0	18	50	1	2018	2
222	CVD778	MAJOR PROJECT PART II (CET)                        	P	""	12	0	0	24	30	19	2018	2
223	CVD801	MAJOR THESIS PART II                               	P	""	12	0	0	24	25	8	2018	2
224	CVD810	MAJOR PROJECT PART I                               	P	""	6	0	0	12	30	2	2018	2
225	CVD811	MAJOR PROJECT PART II (CEU)                        	P	""	12	0	0	24	26	16	2018	2
226	CVD832	MAJOR PROJECT PART II                              	P	""	12	0	0	24	50	12	2018	2
227	CVD854	MAJOR PROJECT PART II                              	P	""	12	0	0	24	30	12	2018	2
228	CVD895	MSR MAJOR PROJECT                                  	P	""	36	0	0	72	30	2	2018	2
229	CVL100	ENVIRONMENTAL SCIENCE                              	C	""	2	2	0	0	500	550	2018	2
230	CVL212	ENVIRONMENTAL ENGINEERING                          	B	""	4	3	0	2	120	97	2018	2
231	CVL222	SOIL MECHANICS                                     	F	""	3	3	0	0	120	103	2018	2
232	CVL242	STRUCTURAL ANALYSIS I                              	D	""	3	3	0	0	120	103	2018	2
233	CVL244	CONSTRUCTION PRACTICES                             	C	""	2	2	0	0	120	95	2018	2
234	CVL261	INTRO. TO TRANSPORTATION ENGG.                     	B	""	3	3	0	0	120	100	2018	2
235	CVL281	HYDRAULICS                                         	E	""	4	3	1	0	120	101	2018	2
236	CVL313	AIR AND NOISE POLLUTION                            	F	""	3	3	0	0	40	41	2018	2
237	CVL342	STEEL DESIGN                                       	D	""	3	3	0	0	120	99	2018	2
238	CVL381	DESIGN OF HYDRAULIC STRUCTURES                     	E	""	4	3	0	2	120	94	2018	2
239	CVL382	GROUNDWATER                                        	H	""	2	2	0	0	30	43	2018	2
240	CVL422	ROCK ENGINEERING                                   	M	""	3	3	0	0	40	40	2018	2
241	CVL431	DESIGN OF FOUN. & RET. STRUCT.                     	J	""	3	3	0	0	59	42	2018	2
242	CVL443	PRESTRESSED CON. & IND. STRUC.                     	H	""	3	3	0	0	50	50	2018	2
243	CVL482	WATER POWER ENGINEERING                            	X	""	3	2	0	2	30	32	2018	2
244	CVL702	GROUND IMPROVEMENT AND GEOSYNTHETICS               	F	""	3	3	0	0	30	12	2018	2
245	CVL703	GEOENVIRONMENTAL ENGINEERING                       	J	""	3	3	0	0	30	14	2018	2
246	CVL705	SLOPES AND RETAINING STRUCTURES                    	E	""	3	3	0	0	30	15	2018	2
247	CVL706	SOIL DYNAMICS AND EARTHQUAKE GEOTECHNICAL ENGG.    	B	""	3	3	0	0	30	13	2018	2
248	CVL712	SLOPES AND FOUNDATIONS                             	C	""	3	3	0	0	30	15	2018	2
249	CVL713	ANALYSIS AND DESIGN OF UNDERGROUND STRUCTURES      	D	""	3	3	0	0	30	13	2018	2
250	CVL714	FIELD EXPLORATION AND GEOTECHNICAL PROCESSES       	E	""	3	3	0	0	30	16	2018	2
251	CVL715	EXCAVATION METHODS & UNDERGROUND SPACE TECHNOLOGY  	A	""	3	3	0	0	40	13	2018	2
252	CVL721	SOLID WASTE ENGINEERING                            	F	""	3	3	0	0	40	40	2018	2
253	CVL723	WASTE WATER ENGINEERING                            	D	""	3	3	0	0	40	24	2018	2
254	CVL724	ENVIRONMENTAL SYSTEMS ANALYSIS                     	C	""	3	3	0	0	40	41	2018	2
255	CVL727	ENVIROMENTAL RISK ASSESMENT 	M	""	3	2	1	0	40	10	2018	2
256	CVL728	ENVIRONMENTAL QUALITY MODELING                     	A	""	3	3	0	0	40	36	2018	2
257	CVL734	ADVANCED HYDRAULICS                                	D	""	3	3	0	0	50	15	2018	2
258	CVL735	FINITE ELEMENT IN WATER RESOU.                     	J	""	3	3	0	0	50	12	2018	2
259	CVL743	AIRPORT PLANNING AND DESIGN                        	K	""	3	3	0	0	30	10	2018	2
260	CVL746	PUBLIC TRANSPORTATION SYSTEMS                      	L	""	3	3	0	0	30	20	2018	2
261	CVL760	THEORY OF CONCRETE STRUCTURES                      	F	""	3	3	0	0	50	20	2018	2
262	CVL761	THEORY OF STEEL STRUCTURES                         	B	""	3	3	0	0	50	22	2018	2
263	CVL762	EARTHQUAKE ANALYSIS AND DESIGN                     	A	""	3	3	0	0	50	36	2018	2
264	CVL774	CONSTRUCTION CONTRACT MGMT.                        	J	""	3	3	0	0	75	41	2018	2
265	CVL775	CONSTRUCTION ECONOMICS AND FI                      	B	""	3	3	0	0	75	50	2018	2
266	CVL776	CONSTRUCTION PRACTICES AND EQ                      	D	""	3	3	0	0	75	48	2018	2
267	CVL778	BUILDING SERVICES AND MAINTENA                     	H	""	3	3	0	0	40	6	2018	2
268	CVL811	NUMERICAL AND COMPUTER METHODS IN GEOMECHANICS     	F	""	3	3	0	0	10	0	2018	2
269	CVL830	GROUNDWATER FLOW AND POLLUTION MODELING            	F	""	3	3	0	0	50	16	2018	2
270	CVL833	WATER RESOURCES SYSTEMS                            	A	""	3	3	0	0	50	8	2018	2
271	CVL838	GEOGRAPHIC INFORMATION SYSTEMS                     	H	""	3	2	0	2	50	18	2018	2
272	CVL841	ADVANCED TRANSPORTATION MODELLING                  	H	""	3	2	0	2	10	6	2018	2
273	CVL845	VISCOELASTIC BEHAVIOR OF BITUM                     	X	""	3	3	0	0	30	5	2018	2
274	CVL847	TRANSPORTATION ECONOMICS                           	A	""	3	3	0	0	30	23	2018	2
275	CVL849	TRAFFIC FLOW MODELLING                             	M	""	3	3	0	0	30	6	2018	2
276	CVL850	TRANSPORTATION LOGISTICS                           	B	""	3	3	0	0	30	12	2018	2
277	CVL861	ANALYSIS & DESIGN OF M/C FOU.                      	E	""	3	3	0	0	50	20	2018	2
278	CVL863	General Continuum Mechanics 	J	""	3	3	0	0	50	6	2018	2
279	CVL864	STRUCTURAL HEALTH MONITORING                       	C	""	3	3	0	0	50	18	2018	2
280	CVL865	Structural Vibration Control 	D	PC	3	3	0	0	50	6	2018	2
281	CVL871	DURABILITY AND REPAIR OF CONCR                     	C	""	3	3	0	0	40	8	2018	2
282	CVL874	QUALITY AND SAFETY IN CONSTRUC                     	E	""	3	3	0	0	40	11	2018	2
283	CVL875	SUSTAINABLE MATERIALS AND GREE                     	A	""	3	3	0	0	40	31	2018	2
284	CVP222	SOIL MECHANICS LABORATORY                          	E	""	1	0	0	2	120	101	2018	2
285	CVP242	STRUCTURAL ANALYSIS LABORATORY                     	P	""	1	0	0	2	100	102	2018	2
286	CVP261	TRANSPORTATION ENGG. LABORATOR                     	P	""	1	0	0	2	120	101	2018	2
287	CVP281	HYDRAULICS LABORATORY                              	P	""	1	0	0	2	120	101	2018	2
288	CVP342	STRUCTURES & MATERIAL LAB                          	P	""	1	0	0	2	120	94	2018	2
289	CVP730	SIMULATION LABORATORY I                            	P	""	1.5	0	0	3	50	11	2018	2
290	CVP731	SIMULATION LABORATORY II                           	P	""	1.5	0	0	3	50	11	2018	2
291	CVP756	STRUCTURAL ENGINEERING LAB                         	P	""	3	0	0	6	50	32	2018	2
292	CVP771	CONSTRUCTION TECHNOLOGY LABORA                     	P	""	1.5	0	0	3	40	17	2018	2
293	CVP800	GEOENVIRONMENTAL AND GEOTECHNICAL ENGINEERING LAB  	R	""	3	0	0	6	30	11	2018	2
294	CVP810	ROCK MECHANICS LABORATORY II                       	R	""	3	0	0	6	30	9	2018	2
295	CVQ301	CIVIL ENGINEERING SEMINAR                          	Q	""	1	0	0	2	120	137	2018	2
296	CVS810	INDEPENDENT STUDY (CEU)                            	P	""	3	0	0	6	10	1	2018	2
297	DSD792	DESIGN PROJECT 1                                   	P	PC	3	0	0	6	20	21	2018	2
298	DSD799	DESIGN PROJECT                                     	P	PC	4	1	0	6	20	17	2018	2
299	DSD802	MAJOR PROJECT PART II                              	P	PC	12	0	0	24	18	6	2018	2
300	DSD892	INDUSTRY/ RESEARCH DESIGN PRO.                     	P	PC	9	0	0	18	20	15	2018	2
301	DSL712	ELECTRONIC TECH. FOR SIGNAL CONDITIONING & INTERFA 	E	PC	3	3	0	0	80	37	2018	2
302	DSL714	INSTRUMENT DESIGN AND SIMULATIONS                  	J	PC	3	2	0	2	20	16	2018	2
303	DSL734	LASER BASED INSTRUMENTATION                        	H	PC	3	3	0	0	30	16	2018	2
304	DSL737	DISPLAY DEVICES & TECHNOLOGY                       	K	PE	3	3	0	0	20	12	2018	2
305	DSL782	DESIGN FOR USABILITY                               	E	PE	3	2	0	2	60	33	2018	2
306	DSL811	SELECTED TOPICS IN INSTRUMENTATION I               	F	PE	3	3	0	0	30	9	2018	2
307	DSP704	INSTRUMENT TECHNOLOGY LABORATORY II                	P	PC	3	0	0	6	20	16	2018	2
308	DSP711	COMP.  AIDED PRODUCT DETAILING                     	J	PC	3	1	0	4	40	22	2018	2
309	DSP722	APPLIED ERGONOMICS                                 	A	PC	2	1	0	2	40	33	2018	2
310	DSP741	PRODUCT INTERFACE & DESIGN                         	B	PC	2	1	0	2	40	23	2018	2
311	DSR772	TRANSPORTATION DESIGN                              	P	PE	3	2	0	2	20	13	2018	2
312	DSR812	MEDIA STUDIES                                      	D	PE	3	2	0	2	60	21	2018	2
313	DSS720	Independent Study 	P	""	3	0	3	0	30	1	2018	2
314	DTD899	DOCTORAL THESIS                                    	X	""	0	0	0	0	5000	2097	2018	2
315	EED854	MAJOR PROJECT PART 2 (EI)                          	P	""	16	0	0	32	30	2	2018	2
316	EED898	MAJOR PROJECT PART II                              	P	""	12	0	0	24	30	1	2018	2
317	EET410	PRACTICAL TRAINING                                 	P	""	0	0	0	0	10	2	2018	2
318	ELD411	B.TECH. PROJECT   I                                	P	""	3	0	0	6	100	14	2018	2
319	ELD431	B.TECH. PROJECT   I                                	P	""	3	0	0	6	100	11	2018	2
320	ELD450	BTP PART II                                        	P	""	8	0	0	16	100	11	2018	2
321	ELD451	BTP PART II                                        	P	""	8	0	0	16	100	0	2018	2
322	ELD452	BTP PART II                                        	P	""	8	0	0	16	100	0	2018	2
323	ELD453	BTP PART II                                        	P	""	8	0	0	16	100	0	2018	2
324	ELD454	BTP PART II                                        	P	""	8	0	0	16	100	0	2018	2
325	ELD455	BTP PART II                                        	P	""	8	0	0	16	100	0	2018	2
326	ELD456	BTP PART II                                        	P	""	8	0	0	16	100	0	2018	2
327	ELD457	BTP PART II                                        	P	""	8	0	0	16	100	1	2018	2
328	ELD458	BTP PART II                                        	P	""	8	0	0	16	100	0	2018	2
329	ELD459	BTP PART II                                        	P	""	8	0	0	16	100	0	2018	2
330	ELD780	MINOR PROJECT                                      	P	""	2	0	0	4	60	22	2018	2
331	ELD800	MINOR PROJECT (EEA)                                	P	""	3	0	0	6	60	0	2018	2
332	ELD802	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	4	2018	2
333	ELD810	MINOR PROJECT (COMMUNICATION E                     	P	""	3	0	0	6	60	1	2018	2
334	ELD811	MAJOR PROJECT PART I (COMMUNIC                     	P	""	6	0	0	12	60	0	2018	2
335	ELD812	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	11	2018	2
336	ELD831	MAJOR PROJECT PART I (INTEGRAT                     	P	""	6	0	0	12	60	1	2018	2
337	ELD832	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	10	2018	2
338	ELD851	MAJOR PROJECT PART I                               	P	""	6	0	0	12	60	0	2018	2
339	ELD852	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	9	2018	2
340	ELD871	MAJOR PROJECT PART I                               	P	""	6	0	0	12	60	3	2018	2
341	ELD872	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	3	2018	2
342	ELD880	MAJOR PROJECT PART I                               	P	""	6	0	0	12	60	15	2018	2
343	ELD881	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	8	2018	2
344	ELD895	MS RESEARCH PROJECT                                	P	""	36	0	0	72	60	20	2018	2
345	ELL100	INTRO. TO ELECTRICAL ENGG.                         	E	""	4	3	0	2	400	455	2018	2
346	ELL201	DIGITAL ELECTRONICS                                	B	""	4.5	3	0	3	350	276	2018	2
347	ELL205	SIGNALS AND SYSTEMS                                	D	""	4	3	1	0	150	115	2018	2
348	ELL212	ENGINEERING ELECROMAGNETICS                        	E	""	4	3	1	0	150	92	2018	2
349	ELL225	CONTROL ENGINEERING I                              	F	""	4	3	1	0	150	129	2018	2
350	ELL231	POWER ELECTR. & ENERGY DEVICES                     	A	""	3	3	0	0	150	46	2018	2
351	ELL301	ELECTRICAL & ELECTRONIC INSTR.                     	C	""	3	3	0	0	130	119	2018	2
352	ELL303	POWER ENGINEERING I                                	F	""	4	3	1	0	150	145	2018	2
353	ELL319	DIGITAL SIGNAL PROCESSING                          	M	""	4	3	0	2	70	33	2018	2
354	ELL332	ELECTRIC DRIVES                                    	B	""	3	3	0	0	100	67	2018	2
355	ELL365	EMBEDDED SYSTEMS                                   	A	""	3	3	0	0	160	123	2018	2
356	ELL400	POWER SYSTEMS PROTECTION                           	E	""	3	3	0	0	50	34	2018	2
357	ELL402	COMPUTER COMMUNICATION                             	K	""	3	3	0	0	100	12	2018	2
358	ELL409	MACHINE INTELLIGENCE& LEARNING                     	J	""	4	3	0	2	65	66	2018	2
359	ELL411	DIGITAL COMMUNICATIONS                             	F	""	4	3	0	2	120	4	2018	2
360	ELL457	SPECIAL TOPICS IN COGNITIVE & INTELLIGENT SYSTEMS  	M	""	3	3	0	0	50	4	2018	2
361	ELL703	OPTIMAL CONTROL THEORY                             	M	""	3	3	0	0	60	23	2018	2
362	ELL705	STOCHASTIC FILTERING AND IDENT                     	B	""	3	3	0	0	60	20	2018	2
363	ELL715	DIGITAL IMAGE PROCESSING                           	J	""	4	3	0	2	150	65	2018	2
364	ELL717	OPTICAL COMMUNICATION SYSTEMS                      	A	""	3	3	0	0	60	24	2018	2
365	ELL719	DETECTION & ESTIMATION THEORY                      	B	""	3	3	0	0	60	44	2018	2
366	ELL720	ADVANCED DIGITAL SIGNAL PROCES                     	H	""	3	3	0	0	60	14	2018	2
367	ELL723	BROADBAND COMMUNICATION SYSTEM                     	F	""	3	3	0	0	90	65	2018	2
368	ELL725	WIRELESS COMMUNICATIONS                            	M	""	3	3	0	0	60	12	2018	2
369	ELL726	NANOPHOTONICS AND PLASMONICS                       	X	""	3	3	0	0	60	17	2018	2
370	ELL730	I.C. TECHNOLOGY                                    	C	""	3	3	0	0	60	41	2018	2
371	ELL731	MIXED SIGNAL CIRCUIT DESIGN                        	X	""	3	3	0	0	60	27	2018	2
372	ELL742	INTRODUCTION TO MEMS DESIGN                        	X	""	3	3	0	0	60	10	2018	2
373	ELL752	ELECTRIC DRIVE SYSTEM                              	F	""	3	3	0	0	60	21	2018	2
374	ELL759	POWER ELECTRONIC CONVERTERS FO                     	X	""	3	3	0	0	60	12	2018	2
375	ELL760	SWITCHED MODE POWER CONVERSION                     	M	""	3	3	0	0	60	18	2018	2
376	ELL769	ELECTRICAL SYSTEMS FOR CONSTRUCTION INDUSTRIES     	E	""	4	3	0	2	60	23	2018	2
377	ELL776	ADVANCED POWER SYSTEM OPTIMIZA                     	D	""	3	3	0	0	60	17	2018	2
378	ELL778	DYNAMIC MODELLING AND CONTROL                      	H	""	3	3	0	0	60	28	2018	2
379	ELL783	OPERATING SYSTEMS                                  	A	""	4	3	0	2	60	29	2018	2
380	ELL784	INTRODUCTION TO MACHINE LEARNI                     	C	""	3	3	0	0	50	49	2018	2
381	ELL791	NEURAL SYSTEMS AND LEARNING MA                     	J	""	4	3	0	2	20	7	2018	2
382	ELL802	ADAPTIVE AND LEARNING CONTROL                      	AD	""	3	3	0	0	60	22	2018	2
383	ELL803	MODEL REDUCTION IN CONTROL                         	A	""	3	3	0	0	60	1	2018	2
384	ELL805	NETWORKED AND MULTI AGENT CONT                     	X	""	3	3	0	0	60	12	2018	2
385	ELL814	WIRELESS OPTICAL COMMUNICATION                     	H	""	3	3	0	0	60	28	2018	2
386	ELL815	MIMO WIRELESS COMMUNICATIONS                       	E	""	3	3	0	0	60	22	2018	2
387	ELL821	SELECTED TOPICS IN COMMUNICATI                     	X	""	3	3	0	0	60	8	2018	2
388	ELL822	SELECTED TOPICS IN COMMUNICATI                     	X	""	3	3	0	0	60	5	2018	2
389	ELL823	SELECTED TOPICS IN INFORMATION PROCESSING I        	X	""	3	3	0	0	60	26	2018	2
390	ELL824	SELECTED TOPICS ININFORMATION PROCESSING   II      	X	""	3	3	0	0	60	13	2018	2
391	ELL833	CMOS RF IC DESIGN                                  	X	""	3	3	0	0	70	63	2018	2
392	ELL850	DIGITAL CONTROL OF POWER ELECT                     	K	""	3	3	0	0	60	26	2018	2
393	ELL851	COMPUTER AIDED DESIGN OF ELECT                     	D	""	3	3	0	0	60	17	2018	2
394	ELL870	RESTRUCTURED POWER SYSTEM                          	M	""	3	3	0	0	60	14	2018	2
395	ELL880	SPECIAL TOPICS IN COMPUTERS 1                      	X	""	3	3	0	0	60	15	2018	2
396	ELL888	ADVANCED MACHINE LEARNING                          	X	""	3	3	0	0	70	69	2018	2
397	ELL896	Mobile Computing                                   	X	""	3	3	0	0	60	15	2018	2
398	ELP203	ELECTROMECHANICS LABORATORY                        	P	""	1.5	0	0	3	150	131	2018	2
399	ELP302	POWER ELECTRONICS LABORATORY                       	P	""	1.5	0	0	3	140	150	2018	2
400	ELP305	DESIGN AND SYSTEM LABORATORY                       	P	""	1.5	0	0	3	100	197	2018	2
401	ELP311	COMMUNICATION ENGINEERING LAB.                     	D	""	1	0	0	2	220	85	2018	2
402	ELP720	TELECOMMUNICATION NETWORKS LABORATORY              	P	""	3	0	1	4	60	12	2018	2
403	ELP725	WIRELESS COMMUNICATION LABORAT                     	P	""	3	0	1	4	60	30	2018	2
404	ELP736	PHYSICAL DESIGN LABORATORY                         	P	""	3	0	0	6	60	13	2018	2
405	ELP801	ADVANCED CONTROL LABORATORY                        	P	""	2	0	0	4	60	14	2018	2
406	ELP832	IEC LABORATORY II                                  	P	""	3	0	0	6	60	11	2018	2
407	ELP852	ELECTRICAL DRIVES LABORATORY                       	P	""	1.5	0	0	3	60	11	2018	2
408	ELP853	DSP BASED CONTROL OF POWER ELE                     	P	""	1.5	0	0	3	60	11	2018	2
409	ELP871	POWER SYSTEM LAB 2                                 	P	""	3	0	1	4	60	16	2018	2
410	ELQ301	SEMINAR COURSE   I                                 	P	""	1	0	0	2	100	101	2018	2
411	ELS310	INDEPENDENT STUDY (EE1)                            	P	""	3	0	3	0	100	15	2018	2
412	ELS330	INDEPENDENT STUDY (EE3)                            	P	""	3	0	3	0	100	8	2018	2
413	ELS880	Independent Study 	P	""	3	3	0	0	60	1	2018	2
414	ELV780	SPECIAL MODULE IN COMPUTERS                        	X	""	1	1	0	0	60	20	2018	2
415	ELV781	SPECIAL MODULE IN INFORMATIONPROCESSING  I         	X	""	1	1	0	0	25	21	2018	2
416	EPC410	COLLOQUIUM (PH)                                    	P	""	3	0	3	0	5	2	2018	2
417	ESL300	SELF ORGANIZING DYNAMICAL SYSTEMS                  	J	""	3	3	0	0	60	61	2018	2
418	ESL330	ENERGY, ECOLOGY AND ENVIRONMENT                    	D	""	4	3	1	0	60	61	2018	2
419	ESL340	NON CONVENTIONAL SOURCES OF ENERGY                 	E	""	4	3	0	2	60	15	2018	2
420	ESL350	ENERGY CONSERVATION MANAGEMENT                     	X	""	3	3	0	0	75	62	2018	2
421	ESL360	DIRECT ENERGY CONVERSION                           	F	""	4	3	1	0	60	16	2018	2
422	ESL710	ENERGY,ECOLOGY AND ENVIRONMENT                     	D	""	3	3	0	0	60	35	2018	2
423	ESL714	POWER PLANT ENGG.                                  	H	""	3	3	0	0	60	16	2018	2
424	ESL718	POWER GENERATION ,TRANSMISSION & DISTRIBUTION      	M	""	3	3	0	0	60	12	2018	2
425	ESL730	DIRECT ENERGY CONVERSION                           	B	""	3	3	0	0	60	24	2018	2
426	ESL734	NUCLEAR ENERGY                                     	E	""	3	3	0	0	60	12	2018	2
427	ESL750	ECONOMICS & PLANNING OF ENERGY SYSTEMS             	A	""	3	3	0	0	60	29	2018	2
428	ESL755	SOLAR PHOTOVOLTAIC DEVICES AND SYSTEMS             	F	""	3	3	0	0	60	14	2018	2
429	ESL796	OPERATION AND CONTROL OF ELECTRICAL ENERGY SYSTEMS 	AA	""	3	3	0	0	60	8	2018	2
430	ESL840	SOLAR ARCHITECTURE                                 	AA	""	3	3	0	0	60	7	2018	2
431	ESL871	ADVANCAED FUSION ENERGY                            	F	""	3	3	0	0	60	11	2018	2
432	ESL880	SOLAR THERMAL POWER GENERATION                     	M	""	3	3	0	0	60	11	2018	2
433	ESP713	ENERGY LABORATORY                                  	P	PC	3	0	0	6	35	23	2018	2
434	ESQ301	SEMINAR COURSE   I                                 	X	""	1	0	0	2	25	26	2018	2
435	ESQ303	SEMINAR COURSE III                                 	X	""	1	0	0	2	25	24	2018	2
436	ESQ304	SEMINAR COURSE IV                                  	X	""	1	0	0	2	25	24	2018	2
437	ESQ306	SEMINAR COURSE ON BIOENERGY                        	X	""	1	0	0	2	25	17	2018	2
438	ESQ307	SEMINAR COURSE ON NUCLEARENERGY AND FUTURISTIC USE 	X	""	1	0	0	2	25	25	2018	2
439	ESQ308	SEMINAR COURSE ONENERGY ENVIRONMENT INTERACTION    	X	""	1	0	0	2	25	22	2018	2
440	ESQ309	SEMINAR COURSE ON ALTERNATIVEFUELS FOR TRANSPORTAT 	X	""	1	0	0	2	25	23	2018	2
441	ESQ310	NGU: Seminar Course on Multiphase Flows in the Energy Sector 	X	""	1	0	0	2	25	4	2018	2
442	HSD700	SEMINAR (CASE MATERIAL BASED)MINOR PROJECT         	X	""	3	0	0	6	60	6	2018	2
443	HSL262	Social Psychological Approaches to Health and Wellbeing 	A	HU	4	3	1	0	46	53	2018	2
444	HSL701	INTRODUCTION TO SCIENCE ANDTECHNOLOGY POLICY STUDI 	X	""	1.5	1	0	1	30	12	2018	2
445	HSL702	Approaches to Science and Technology Policy Studies 	X	""	1.5	1.5	0	0	9	10	2018	2
446	HSL713	MACROECONOMICS                                     	B	""	3	3	0	0	60	12	2018	2
447	HSL719	ADVANCED ECONOMETRICS                              	X	""	3	3	0	0	30	5	2018	2
448	HSL731	WHAT IS A TEXT                                     	X	""	3	3	0	0	30	9	2018	2
449	HSL751	CRITICAL READING IN PHILOSOPHICAL                  	X	""	3	3	0	0	30	6	2018	2
450	HSL766	The Psychology of Leadership and Social Change 	M	PC	3	3	0	0	30	8	2018	2
451	HSL772	SOCIOLOGY OF INDIA                                 	X	""	3	3	0	0	30	7	2018	2
452	HSL800A	RESEARCH WRITING                                   	A	""	3	3	0	0	90	82	2018	2
453	HSL800B	RESEARCH WRITING                                   	M	""	3	3	0	0	90	144	2018	2
454	HSL841	MINIMALIST ARCHITECTURE OF GRAMMAR                 	X	""	3	3	0	0	60	3	2018	2
455	HSL852	POLITICAL PHILOSOPHY                               	AC	OE	3	3	0	0	30	18	2018	2
456	HSL860	ADVANCED TOPICS IN PHILOSOPHY                      	X	""	3	3	0	0	60	13	2018	2
457	HSV319	Global Political Economy 	X	""	1	1	0	0	100	0	2018	2
458	HSV748	DATA ANALYSIS FOR PSYCHOLINGUISTICS USING R        	X	""	2	2	0	0	60	14	2018	2
459	HSV781	Introduction to research methodology 	X	""	1.5	1.5	0	0	30	22	2018	2
460	HUL211A	INTRODUCTION TO ECONOMICS                          	A	HU	4	3	1	0	100	101	2018	2
461	HUL211B	INTRODUCTION TO ECONOMICS                          	M	HU	4	3	1	0	100	95	2018	2
462	HUL212	MICROECONOMICS                                     	M	HU	4	3	1	0	100	100	2018	2
463	HUL231	AN INTRODUCTION TO LITERATURE                      	J	HU	4	3	1	0	99	102	2018	2
464	HUL239	INDIAN FICTION IN ENGLISH                          	M	HU	4	3	1	0	100	101	2018	2
465	HUL242	FUNDAMENTALS OF LANGUAGE SCIENCES                  	A	HU	4	3	1	0	300	301	2018	2
466	HUL261	INTRODUCTION TO PSYCHOLOGY                         	A	HU	4	3	1	0	100	99	2018	2
467	HUL267	POSITIVE PSYCHOLOGY                                	A	HU	4	3	1	0	88	93	2018	2
468	HUL271	INTRODUCTION TO SOCIOLOGY                          	M	HU	4	3	1	0	100	97	2018	2
469	HUL274	RETHINKING THE INDIAN TRADITION                    	B	HU	4	3	1	0	100	104	2018	2
470	HUL286A	SOCIAL SCIENCE APPROACHES TO DEVELOPMENT           	M	HU	4	3	1	0	100	115	2018	2
471	HUL286B	SOCIAL SCIENCE APPROACHES TO DEVELOPMENT           	B	HU	4	3	1	0	100	101	2018	2
472	HUL307	FANTASY LITERATURE                                 	H	HU	3	3	0	0	34	32	2018	2
473	HUL315	ECONOMETRIC METHODS                                	M	HU	3	3	0	0	35	42	2018	2
474	HUL316	INDIAN ECONOMIC PROBLEMS AND POLICIES              	M	HU	3	3	0	0	35	44	2018	2
475	HUL320	SELECTED TOPICS IN ECONOMICS                       	M	HU	3	3	0	0	35	36	2018	2
476	HUL335	INDIAN THEATRE                                     	M	HU	3	3	0	0	29	28	2018	2
477	HUL356	BUDDHISM ACROSS TIME AND PLACE                     	M	""	3	3	0	0	35	35	2018	2
478	HUL360	SELECTED TOPICS IN PHILOSOPHY                      	A	HU	3	3	0	0	35	37	2018	2
479	HUL362	ORGANIZATIONAL BEHAVIOUR                           	M	HU	3	3	0	0	35	36	2018	2
480	HUL370	SELECTED TOPICS IN PSYCHOLOGY                      	B	HU	3	3	0	0	35	42	2018	2
481	HUL371A	SCIENCE, TECHNOLOGY AND SOCIETY                    	A	HU	3	3	0	0	34	37	2018	2
482	HUL371B	SCIENCE, TECHNOLOGY AND SOCIETY                    	M	HU	3	3	0	0	30	33	2018	2
483	HUL375	THE SOCIOLOGY OF RELIGION                          	J	HU	3	3	0	0	35	35	2018	2
484	HUL376	POLITICAL ECOLOGY OF WATER                         	M	HU	3	3	0	0	35	36	2018	2
485	HUL378	INDUSTRY AND WORK CULTURE UNDE                     	H	HU	3	3	0	0	35	35	2018	2
486	HUL380	SELECTED TOPICS IN SOCIOLOGY                       	J	HU	3	3	0	0	35	36	2018	2
487	HUL381A	MIND                                               	M	HU	3	3	0	0	33	32	2018	2
488	HUL381B	MIND                                               	A	HU	3	3	0	0	35	35	2018	2
489	HUL743	Language Acquisition, Teaching and Assessment 	B	""	3	3	0	0	30	3	2018	2
490	HUL763	Cognitive Psychology 	J	""	3	3	0	0	30	17	2018	2
491	HUL843	THE PHILOSOPHY OF LANGUAGE                         	X	""	3	3	0	0	30	7	2018	2
492	HUL861	Psychology of Decision Making 	AA	""	3	3	0	0	30	12	2018	2
493	HUL874	Civil Society and Democracy in India 	X	""	3	3	0	0	60	4	2018	2
494	HUL875	Ethnic Identity, Development and Democratization in North east India 	AA	""	3	3	0	0	30	3	2018	2
495	HUL888	APPLIED LINGUISTICS                                	X	""	3	3	0	0	30	3	2018	2
496	HUV705	Climate policy, politics and governance 	X	HU	1	1	0	0	29	28	2018	2
497	HUV751	CURRENT TRENDS IN PSYCHOLINGUISTICS                	X	""	1	1	0	0	60	34	2018	2
498	ITL702	DIAGNOSTIC MAINTENANCE AND MONITORING              	J	""	4	3	0	2	60	16	2018	2
499	ITL711	RELIABILITY AVAILABILITY AND MAINTAINABILITY(RAM)  	F	""	3	3	0	0	60	21	2018	2
500	ITL714	FAILURE ANALYSIS AND REPAIR                        	B	""	4	3	0	2	60	15	2018	2
501	ITL717	CORROSION AND ITS CONTROL                          	A	""	3	3	0	0	60	9	2018	2
502	JID802	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	12	2018	2
503	JOD802	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	8	2018	2
504	JOP792	FIBER OPTICS AND OPTICAL COMMUNICATION LAB.II      	P	""	3	0	0	6	60	22	2018	2
505	JPD802	MAJOR PROJECT PART II                              	A	""	12	0	0	24	60	14	2018	2
506	JRD301	MINI PROJECT IN ROBOTICS                           	P	""	7	0	0	14	20	7	2018	2
507	JSD801	MAJOR PROJECT PART I                               	P	PC	6	0	0	12	35	0	2018	2
508	JSD802	MAJOR PROJECT PART II                              	P	PE	12	0	0	24	35	6	2018	2
509	JTD792	MINOR PROJECT                                      	P	""	3	0	0	6	60	15	2018	2
510	JTD802	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	9	2018	2
511	JVD809	MINOR PROJECT                                      	P	""	6	0	0	12	60	0	2018	2
512	JVD811	MAJOR PROJECT PART I                               	P	""	12	0	0	24	60	1	2018	2
513	JVD812	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	7	2018	2
514	MAD852	MAJOR PROJECT PART 2 (MT)                          	P	""	14	0	0	28	30	2	2018	2
515	MCD310	MINI PROJECT                                       	P	""	3	0	0	6	100	19	2018	2
516	MCD411	B.TECH.PROJECT                                     	P	""	4	0	0	8	100	28	2018	2
517	MCD412	B.TECH.PROJECT   II                                	P	""	7	0	0	14	100	54	2018	2
518	MCD812	MAJOR PROJECT PART II (THERMALENGINEERING)         	P	""	12	0	0	24	60	18	2018	2
519	MCD832	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	14	2018	2
520	MCD862	MAJOR PROJECT PART II                              	Q	""	12	0	0	24	60	7	2018	2
521	MCD882	MAJOR PROJECT PART 2                               	X	""	12	0	0	24	60	8	2018	2
522	MCD895	MAJOR PROJECT                                      	P	""	40	0	0	80	60	2	2018	2
523	MCL131	MANUFACTURING PROCESSES I                          	F	""	3	3	0	0	100	72	2018	2
524	MCL132	METAL FORMING AND PRESS TOOLS                      	H	""	3	3	0	0	100	64	2018	2
525	MCL133	NEAR NET SHAPE MANUFACTURING                       	F	""	3	3	0	0	100	66	2018	2
526	MCL136	MATERIAL REMOVAL PROCESSES                         	H	""	3	3	0	0	100	68	2018	2
527	MCL142	THERMAL SC. FOR ELE. ENGINEERS                     	D	""	3	3	0	0	100	131	2018	2
528	MCL201	MECHANICAL ENGG. DRAWING                           	E	DC	3.5	2	0	3	100	133	2018	2
529	MCL212	CONTROL THEORY & APPLICATIONS                      	B	DC	4	3	0	2	100	151	2018	2
530	MCL241	ENERGY SYSTEMS AND TECH.                           	B	""	3.5	3	0	1	100	73	2018	2
531	MCL311	CAD & FINITE ELEMENT ANALYSIS                      	E	DC	4	3	0	2	100	146	2018	2
532	MCL321	AUTOMOTIVE SYSTEMS                                 	F	DE	4	3	0	2	60	32	2018	2
533	MCL331	MICRO AND NANO MANUFACTURING                       	A	""	3	3	0	0	100	55	2018	2
534	MCL343	INTRODUCTION TO COMBUSTION                         	J	""	3	3	0	0	100	31	2018	2
535	MCL347	INTERMEDIATE HEAT TRANSFER                         	H	""	3	3	0	0	60	37	2018	2
536	MCL361	MANUFACTURING SYSTEM DESIGN                        	D	""	3	3	0	0	100	141	2018	2
537	MCL380	SPL. TOPICS IN MECHANICAL ENGG                     	H	""	3	3	0	0	100	12	2018	2
538	MCL421	AUTOMOTIVE STRUCTURAL DESIGN                       	H	DE	3	2	0	2	60	7	2018	2
539	MCL443	ELECTROCHEMICAL ENERGY SYSTEMS                     	B	""	3	3	0	0	25	10	2018	2
540	MCL705	EXPERIMENTAL METHODS                               	C	PC	4	3	0	2	60	54	2018	2
541	MCL723	Vehicle Dynamics 	C	DE	3	3	0	0	30	12	2018	2
542	MCL730	DESIGNING WITH ADVANCE MATERIALS                   	B	""	4	3	0	2	40	24	2018	2
543	MCL733	VIBRATIONS AND NOISE ENGINEERING                   	A	DE,PE	4	3	0	2	50	30	2018	2
544	MCL736	AUTOMOTIVE DESIGN                                  	H	DE,PE	4	3	0	2	40	15	2018	2
545	MCL738	DYNAMICS OF MULTIBODY SYSTEMS                      	F	DE,PE	3	2	0	2	40	15	2018	2
546	MCL741	CONTROL ENGINEERING                                	C	PE	4	3	0	2	25	13	2018	2
547	MCL743	PLANT EQUIPMENT DESIGN                             	F	DE,PE	3	3	0	0	40	26	2018	2
548	MCL745	ROBOTICS                                           	H	DE,PE	4	3	0	2	40	21	2018	2
549	MCL747	DESIGN OF PRECISION MACHINES                       	F	DE,PE	3	2	0	2	40	20	2018	2
550	MCL754	OPERATIONS PLANNING AND CONTRO                     	B	PC	3	3	0	0	60	19	2018	2
551	MCL759	ENTREPRENEURSHIP                                   	K	PE	3	3	0	0	40	51	2018	2
552	MCL770	STOCHASTIC MODELING AND SIMULATION                 	A	PE	3	3	0	0	60	10	2018	2
553	MCL771	VALUE ENGINEERING AND LIFE CYC                     	H	PE	3	3	0	0	50	32	2018	2
554	MCL778	DESIGN AND METALLURGY OF WELDE                     	A	""	4	3	0	2	60	15	2018	2
555	MCL782	COMPUTATIONAL METHODS                              	B	""	2	2	0	0	60	37	2018	2
556	MCL784	COMPUTER AIDED MANUFACTURING                       	F	""	4	3	0	2	60	25	2018	2
557	MCL786	METROLOGY                                          	E	""	3	2	0	2	60	20	2018	2
558	MCL813	COMPUTATIONAL HEAT TRANSFER                        	E	""	4	3	0	2	25	27	2018	2
559	MCL814	CONVECTIVE HEAT TRANSFER                           	F	""	3	3	0	0	60	34	2018	2
560	MCL818	HEATING, VENTILATING AND AIR C                     	J	""	3	3	0	0	60	6	2018	2
561	MCL821	RADIATION HEAT TRANSFER                            	J	""	3	3	0	0	60	8	2018	2
562	MCL822	STEAM AND GAS TURBINES                             	B	""	4	3	0	2	60	2	2018	2
563	MCL823	THERMAL DESIGN                                     	B	""	4	3	0	2	60	12	2018	2
564	MCL825	DESIGN OF WIND POWER FARMS                         	D	""	4	3	0	2	60	22	2018	2
565	MCL826	INTRODUCTION TO MICROFLUIDICS                      	H	""	4	3	0	2	60	11	2018	2
566	MCL865	ADVANCED OPERATIONS RESEARCH                       	J	PE	3	3	0	0	60	43	2018	2
567	MCP100	ENGG. VISUALIZATION & COMM.                        	Q	""	1.5	0	0	3	100	471	2018	2
568	MCP101	PRODUCT REALIZATION BY MANF.                       	Q	""	2	0	0	4	500	455	2018	2
569	MCP261	INDUSTRIAL ENGINEERING LAB   I                     	Q	""	1	0	0	2	100	59	2018	2
570	MCP301	MECHANICAL ENGINEERING LAB   I                     	Q	""	1.5	0	0	3	100	76	2018	2
571	MCP331	MANUFACTURING LABORATORY II                        	Q	""	1	0	0	2	100	79	2018	2
572	MCP332	PRODUCTION ENGINEERING LAB  II                     	Q	""	1	0	0	2	100	63	2018	2
573	MCQ301	SEMINAR COURSE   I                                 	X	""	1	0	0	2	30	30	2018	2
574	MCQ302	SEMINAR COURSE   II                                	X	""	1	0	0	2	30	28	2018	2
575	MCQ303	SEMINAR COURSE   III                               	X	""	1	0	0	2	30	30	2018	2
576	MCV849	SPECIAL MODULE IN SYSTEM DESIGN                    	C	""	1	1	0	0	30	7	2018	2
577	MEC410	COLLOQUIUM (ME)                                    	P	""	3	0	3	0	10	1	2018	2
578	MED411	MAJOR PROJECT PART 1 (ME)                          	P	""	3	0	0	6	60	0	2018	2
579	MED412	MAJOR PROJECT PART 2 (ME)                          	P	""	7	0	0	14	100	2	2018	2
580	MSD792	MINOR PROJECT                                      	P	""	3	0	0	6	60	17	2018	2
581	MSD890	MAJOR PROJECT (UNIQUE CORE)                        	P	""	6	0	0	12	60	85	2018	2
582	MSD891	MAJOR PROJECT (UNIQUE CORE)                        	P	""	6	0	0	12	60	26	2018	2
583	MSD892	MAJOR PROJECT (UNIQUE CORE)                        	P	""	6	0	0	12	60	50	2018	2
584	MSL301	ORGANIZATION AND PEOPLE MANAGEMENT                 	M	""	3	3	0	0	80	91	2018	2
585	MSL303	MARKETING MANAGEMENT                               	A	""	3	3	0	0	80	84	2018	2
586	MSL700	FUNDAMENTALS OF MANAGEMENT OF TECHNOLOGY           	T	FE	3	3	0	0	60	55	2018	2
587	MSL705A	HRM SYSTEMS                                        	R1	PC	1.5	1.5	0	0	60	34	2018	2
588	MSL705B	HRM SYSTEMS                                        	AA	PC	1.5	1.5	0	0	60	37	2018	2
589	MSL705C	HRM SYSTEMS                                        	AB	PC	1.5	1.5	0	0	60	32	2018	2
590	MSL706	BUSINESS LAWS                                      	D	PC	3	3	0	0	60	113	2018	2
591	MSL708A	FINANCIAL MANAGEMENT                               	T	PC	3	3	0	0	60	39	2018	2
592	MSL708B	FINANCIAL MANAGEMENT                               	F	PC	3	3	0	0	60	74	2018	2
593	MSL711A	STRATEGIC MANAGEMENT                               	AC	PC	3	3	0	0	60	41	2018	2
594	MSL711B	STRATEGIC MANAGEMENT                               	D	PC	3	3	0	0	60	32	2018	2
595	MSL713A	INFORMATION SYSTEMS MANAGEMENT                     	S	PC	3	3	0	0	60	35	2018	2
596	MSL713B	INFORMATION SYSTEMS MANAGEMENT                     	A	PC	3	3	0	0	60	42	2018	2
597	MSL713C	INFORMATION SYSTEMS MANAGEMENT                     	B1	PC	3	3	0	0	60	32	2018	2
598	MSL720A	MACROECONOMIC ENV. OF BUSINESS                     	E	PC	3	3	0	0	60	48	2018	2
599	MSL720B	MACROECONOMIC ENV. OF BUSINESS                     	H	PC	3	3	0	0	60	37	2018	2
600	MSL721	ECONOMETRICS                                       	T	SE	3	3	0	0	60	69	2018	2
601	MSL723	TELECOM SYSTEMS MANAGEMENT                         	K	""	3	3	0	0	60	21	2018	2
602	MSL727A	INTERPERSONAL BEHAVIOR & TEAM DYNAMICS             	Q1	SE	1.5	1.5	0	0	60	70	2018	2
603	MSL727B	INTERPERSONAL BEHAVIOR & TEAM DYNAMICS             	B1	SE	1.5	1.5	0	0	60	42	2018	2
604	MSL727C	INTERPERSONAL BEHAVIOR & TEAM DYNAMICS             	AA	SE	1.5	1.5	0	0	60	35	2018	2
605	MSL733A	ORGANIZATION THEORY                                	Q2	SE	1.5	1.5	0	0	60	71	2018	2
606	MSL733B	ORGANIZATION THEORY                                	B2	SE	1.5	1.5	0	0	60	41	2018	2
607	MSL733C	ORGANIZATION THEORY                                	A2	SE	1.5	1.5	0	0	60	31	2018	2
608	MSL740	QUANTITATIVE METHODS IN MGMT.                      	Q	SE	3	3	0	0	60	39	2018	2
609	MSL745A	OPERATIONS MANAGEMENT                              	AB	PC	3	3	0	0	60	46	2018	2
610	MSL745B	OPERATIONS MANAGEMENT                              	E	PC	3	3	0	0	60	31	2018	2
611	MSL780	MANAGERIAL ECONOMICS                               	R2	PC	1.5	1.5	0	0	60	43	2018	2
612	MSL802	MGMT. OF INTELLECTUAL PR. RIG.                     	U	PE	3	3	0	0	60	31	2018	2
613	MSL806	MERGERS & ACQUISITIONS                             	J	PE	3	3	0	0	60	15	2018	2
614	MSL825	STRATEGIES IN FUNCTIONAL MGMT.                     	Q	PE	3	3	0	0	60	14	2018	2
615	MSL827	INTERNATIONAL COMPETITIVENESS                      	R	PE	3	3	0	0	60	20	2018	2
616	MSL849	CURRENT & EM. ISS. IN MA. MGMT                     	R	PE	3	3	0	0	60	26	2018	2
617	MSL859	Current and Emerging Issues in IT Management 	S	PE	3	3	0	0	60	90	2018	2
618	MSL863	ADVERTISING AND SALESPROMOTION MANAGEMENT          	U	PE	3	3	0	0	60	111	2018	2
619	MSL865	SALES MANAGEMENT                                   	T	""	3	3	0	0	60	93	2018	2
620	MSL870	CORPORATE GOVERNANCE                               	U1	PE	1.5	1.5	0	0	60	10	2018	2
621	MSL871	BANKING AND FINANCIAL SERVICES                     	R2	PE	1.5	1.5	0	0	60	26	2018	2
622	MSL873	SECURITY ANALYSIS & PORTFOLIOMANAGEMENT            	AB	PE	3	3	0	0	60	54	2018	2
623	MSL874	INDIAN FINANCIAL SYSTEM                            	R1	PE	1.5	1.5	0	0	60	31	2018	2
624	MSL875	INTERNATIONAL FINANCIAL MANAGEMENT                 	S	PE	3	3	0	0	60	14	2018	2
625	MSL878	ELECTRONIC PAYMENTS                                	T2	PE	1.5	1.5	0	0	60	14	2018	2
626	MSL879	CURRENT AND EMERGING ISSUES IN FINANCE             	U	PE	3	3	0	0	60	62	2018	2
627	MSL886	IT CONSULTING AND PRACTICE                         	U	PE	3	3	0	0	60	16	2018	2
628	MSL894	SOCIAL MEDIA AND BUSINESS PRACTICES                	R	PE	3	3	0	0	60	32	2018	2
629	MSL896	INTERNATIONAL ECONOMIC POLICY                      	Q	PE	3	3	0	0	60	20	2018	2
630	MST894	SOCIAL  SECTOR ATTACHMENT                          	P	NC	1	0	0	2	60	67	2018	2
631	MSV802	SELECTED TOPICS IN FINANCE                         	X	""	1	1	0	0	60	46	2018	2
632	MSV803	SELECTED TOPICS IN I T MANAGEMENT                  	X	""	1	1	0	0	60	11	2018	2
633	MSV805	SELECTED TOPICS IN ECONOMICS                       	X	""	1	1	0	0	60	28	2018	2
634	MTD350	MINI PROJECT                                       	P	""	3	0	0	6	30	12	2018	2
635	MTD421	B.TECH. PROJECT                                    	Q	""	4	0	0	8	100	43	2018	2
636	MTD702	PROJECT 2                                          	P	""	6	0	0	12	30	19	2018	2
637	MTD852	MAJOR PROJECT PARTII                               	Q	""	16	0	0	32	60	1	2018	2
638	MTD854	MAJOR PROJECT PART II                              	P	""	18	0	0	36	30	20	2018	2
639	MTL100	CALCULUS                                           	D	""	4	3	1	0	400	474	2018	2
640	MTL101	LINEAR ALGEBRA & DIFFE. EQUA.                      	C	""	4	3	1	0	400	471	2018	2
641	MTL102	DIFFERENTIAL EQUATIONS                             	E	""	3	3	0	0	100	160	2018	2
642	MTL103	OPTIMIZATION METHODS & APPL.                       	D	""	3	3	0	0	140	156	2018	2
643	MTL106	PROBABILITY & STOCHASTIC PRO.                      	D	""	4	3	1	0	200	226	2018	2
644	MTL108	INTRODUCTION TO STATISTICS                         	D	""	4	3	1	0	175	166	2018	2
645	MTL122	REAL AND COMPLEX ANALYSIS                          	F	""	4	3	1	0	100	76	2018	2
646	MTL145	NUMBER THEORY                                      	AA	""	3	3	0	0	100	100	2018	2
647	MTL390	STATISTICAL METHODS                                	J	""	4	3	1	0	100	77	2018	2
648	MTL411	FUNCTIONAL ANALYSIS                                	F	""	3	3	0	0	100	91	2018	2
649	MTL506	COMPLEX ANALYSIS                                   	B	""	4	3	1	0	60	57	2018	2
650	MTL507	TOPOLOGY                                           	D	""	4	3	1	0	60	54	2018	2
651	MTL508	MATHEMATICAL PROGRAMMING                           	AB	""	4	3	1	0	60	58	2018	2
652	MTL509	NUMERICAL  ANALYSIS                                	AA	""	4	3	1	0	60	51	2018	2
653	MTL510	MEASURE AND INTEGRATION                            	C	""	4	3	1	0	60	53	2018	2
654	MTL725	STOCHASTIC PROCESSES & ITS APP                     	H	""	3	3	0	0	60	50	2018	2
655	MTL730	CRYPTOGRAPHY                                       	A	""	3	3	0	0	150	136	2018	2
656	MTL732	FINANCIAL MATHEMATICS                              	A	""	3	3	0	0	60	52	2018	2
657	MTL742	OPERATOR THEORY                                    	AD	""	3	3	0	0	60	36	2018	2
658	MTL755	ALGEBRAIC GEOMETRY                                 	M	""	3	3	0	0	60	46	2018	2
659	MTL768	GRAPH THEORY                                       	AA	""	3	3	0	0	60	68	2018	2
660	MTL782	DATA MINING                                        	B	""	4	3	0	2	60	62	2018	2
661	MTL792	MODERN METH. IN PAR. DIFF. EQ.                     	AA	""	3	3	0	0	60	14	2018	2
662	MTP290	COMPUTING LABORATORY                               	Q	""	2	0	0	4	100	67	2018	2
663	NEN101	PROFE. ETHICS &SOCIAL RESP. 2                      	P	""	0.5	0	0	1	1000	910	2018	2
664	NLN101	LANGUAGE & WRITING SKILL 2                         	P	""	1	0	0	2	100	916	2018	2
665	PTL702	POLYMER PROCESSING                                 	B	""	3	3	0	0	60	18	2018	2
666	PTL706	POLYMER TESTING & PROPERTIES                       	M	""	3	3	0	0	60	18	2018	2
667	PTL709	POLYMER TECHNOLOGY                                 	D	""	3	3	0	0	60	19	2018	2
668	PTL712	POLYMER COMPOSITES                                 	E	""	3	3	0	0	60	23	2018	2
669	PTP720	POLYMER ENGINEERING LAB                            	AA	""	1	0	0	2	60	15	2018	2
670	PTV700	SPECIAL LECTURES IN POLYMERS:                      	X	""	1	1	0	0	30	17	2018	2
671	PYD411	PROJECT I                                          	Q	""	4	0	0	8	100	10	2018	2
672	PYD412	MAJOR PROJECT PART II                              	Q	""	8	0	0	16	100	13	2018	2
673	PYD414	PROJECT III                                        	Q	""	4	0	0	8	100	1	2018	2
674	PYD562	PROJECT II                                         	Q	""	6	0	0	12	60	44	2018	2
675	PYD658	MINI PROJECT                                       	Q	""	3	0	0	6	60	7	2018	2
676	PYD802	MAJOR PROJECT PART II                              	Q	""	12	0	0	24	60	16	2018	2
677	PYD852	MAJOR PROJECT PART II                              	Q	""	12	0	0	24	60	17	2018	2
678	PYL100	ELECTROMAGNETIC WAVES&QUA.MEC.                     	A	""	3	3	0	0	100	485	2018	2
679	PYL102	PRINCIPLES OF ELECT. MATERIALS                     	H	""	3	3	0	0	150	157	2018	2
680	PYL111	ELECTRODYNAMICS                                    	A	""	4	3	1	0	100	64	2018	2
681	PYL112	QUANTUM MECHANICS                                  	E	""	4	3	1	0	100	110	2018	2
682	PYL114	SOLID STATE PHYSICS                                	D	""	4	3	1	0	100	60	2018	2
683	PYL202	STATISTICAL PHYSICS                                	F	""	4	3	1	0	100	56	2018	2
684	PYL204	COMPUTATIONAL PHYSICS                              	J	""	4	3	1	0	100	57	2018	2
685	PYL302	NUCLEAR SCIENCE & ENGINEERING                      	E	""	3	3	0	0	100	16	2018	2
686	PYL304	SUPERCONDUCTIVITY & APPLICAT.                      	C	""	3	3	0	0	100	18	2018	2
687	PYL306	MICROELECTRONIC DEVICES                            	K	""	3	3	0	0	100	28	2018	2
688	PYL312	SEMICONDUCTOR OPTOELECTRONICS                      	D	""	3	3	0	0	100	25	2018	2
689	PYL331	APPLIED QUANTUM MECHANICS                          	H	""	3	3	0	0	50	10	2018	2
690	PYL552	ELECTRODYNAMICS                                    	E	""	4	3	1	0	60	52	2018	2
691	PYL555	QUANTUM MECHANICS I                                	E	""	4	3	1	0	60	8	2018	2
692	PYL556	QUANTUM MECHANICS II                               	B	""	3	3	0	0	60	50	2018	2
693	PYL558	STATISTICAL MECHANICS                              	F	""	4	3	1	0	60	54	2018	2
694	PYL560	APPLIED OPTICS                                     	H	""	4	3	1	0	60	53	2018	2
695	PYL563	SOLID STATE PHYSICS                                	D	""	4	3	1	0	60	53	2018	2
696	PYL651	ADVANCED SOLID STATE PHYSICS                       	C	""	3	3	0	0	35	6	2018	2
697	PYL659	LASER SPECTROSCOPY                                 	F	""	3	3	0	0	60	21	2018	2
698	PYL704	SC. & TECHNOLOGY OF THIN FILMS                     	J	""	3	3	0	0	60	43	2018	2
699	PYL705	NANOSTRUCTURED MATERIALS                           	E	""	3	3	0	0	60	36	2018	2
700	PYL707	CHARACTERISATION TEC. FOR MAT.                     	D	""	3	3	0	0	60	27	2018	2
701	PYL725	SURFACE PHYSICS AND ANALYSIS                       	H	""	3	3	0	0	60	30	2018	2
702	PYL726	SEMICONDUCTOR DEVICE TECHNOLOGY                    	K	""	3	3	0	0	60	16	2018	2
703	PYL727	ENERGY MATERIALS AND DEVICES                       	M	""	3	3	0	0	60	17	2018	2
704	PYL742	GEN. RELATIVITY & INTRO. ASTR.                     	M	""	3	3	0	0	75	38	2018	2
705	PYL743	GROUP THEORY & ITS APPLICATION                     	A	""	3	3	0	0	60	66	2018	2
706	PYL744	HIGH ENERGY PHYSICS                                	K	""	3	3	0	0	75	31	2018	2
707	PYL746	NON EQUILIBRIUM STATISTICAL ME                     	L	""	3	3	0	0	40	14	2018	2
708	PYL748	QUANTUM OPTICS                                     	B	""	3	3	0	0	60	26	2018	2
709	PYL752	LASER SYSTEMS AND APPLICATIONS                     	J	""	3	3	0	0	60	27	2018	2
710	PYL756	Fourier Optics and Holography 	L	PC	3	3	0	0	60	31	2018	2
711	PYL760	BIOMEDICAL OPTICS & BIO PHOTO.                     	H	""	3	3	0	0	60	35	2018	2
712	PYL762	STATISTICAL OPTICS                                 	A	""	3	3	0	0	60	20	2018	2
713	PYL770	ULTRA FAST OPTICS & APPLICATI.                     	F	""	3	3	0	0	60	24	2018	2
714	PYL772	PLASMONIC SENSORS                                  	K	""	3	3	0	0	60	9	2018	2
715	PYL780	DIFFRACTIVE AND MICRO OPTICS                       	M	""	3	3	0	0	60	17	2018	2
716	PYL792	OPTICAL ELECTRONICS                                	E	""	3	3	0	0	60	26	2018	2
717	PYL800	NUM. & COMP. METH. IN RESEARCH                     	B	""	3	3	0	0	65	61	2018	2
718	PYL879	SELECTED TOPICS IN APPLIED OPT                     	X	""	3	3	0	0	60	1	2018	2
719	PYL891	FIBER OPTIC COMPONENTS AND DEVICES                 	D	""	3	3	0	0	60	16	2018	2
720	PYP100	PHYSICS LABORATORY                                 	Q	""	2	0	0	4	100	459	2018	2
721	PYP212	ENGG. PHYSICS LABORATORY II                        	Q	""	3	0	0	6	100	47	2018	2
722	PYP222	ENGINEERING PHYSICS LAB.   IV                      	Q	""	4	0	0	8	100	56	2018	2
723	PYP562	LABORATORY II                                      	Q	""	4	0	0	8	60	51	2018	2
724	PYP702	SOLID STATE MATERIALS LABORATORY II                	Q	""	3	0	0	6	60	20	2018	2
725	PYP762	ADVANCED OPTICS LABORATORY                         	Q	""	3	0	0	6	60	17	2018	2
726	PYP764	ADVANCED OPTICAL WORKSHOP                          	Q	""	3	0	0	6	60	1	2018	2
727	PYQ303	SEMINAR COURSE   III                               	Q	""	1	0	0	2	100	76	2018	2
728	PYS300	INDEPENDENT STUDY                                  	X	""	3	0	3	0	100	2	2018	2
729	RDD750	MINOR PROJECT                                      	Q	OE	3	0	0	6	20	1	2018	2
730	RDL700	BIOMAS PRODUCTION                                  	J	OE	3	3	0	0	60	49	2018	2
731	RDL701	RURAL INDUSTRIALISATION POLICES PROGRAMMES & CASE  	E	OE	3	3	0	0	100	99	2018	2
732	RDL710	RURAL INDIA AND PLANNING FOR DEVELOPMENT           	J	OE	3	3	0	0	50	65	2018	2
733	RDL722	RURAL ENERGY SYSTEMS                               	F	OE	3	3	0	0	100	102	2018	2
734	RDL726	HERBAL,MEDICINAL ANDAROMATIC PRODUCTS              	M	OE	3	3	0	0	30	30	2018	2
735	RDL740	TECHNOLOGY OF UTILIZATION OF WASTELANDS & WEEDS    	AA	OE	3	3	0	0	50	44	2018	2
736	RDL760	FOOD QUALITY AND SAFETY                            	J	OE	3	3	0	0	50	55	2018	2
737	RDP750	BIOMASS LABORATORY                                 	Q	OE	3	0	0	6	20	13	2018	2
738	RDQ301	SEMINAR COURSE   I                                 	X	OE	1	0	0	2	30	32	2018	2
739	RDQ302	SEMINAR COURSE   II                                	X	OE	1	0	0	2	30	33	2018	2
740	RDQ303	SEMINAR COURSE   III                               	X	OE	1	0	0	2	30	34	2018	2
741	RDQ304	SEMINAR COURSE IV                                  	X	OE	1	0	0	2	30	31	2018	2
742	RDQ305	SEMINAR COURSE V                                   	X	OE	1	0	0	2	30	44	2018	2
743	SBC796	GRADUATE STUDENT SEMINAR II                        	P	""	0.5	0	0	1	60	13	2018	2
744	SBD301	MINI PROJECT                                       	Q	""	3	0	0	6	10	3	2018	2
745	SBD895	MS RESEARCH PROJECT                                	P	""	40	0	0	80	60	5	2018	2
746	SBL100	INTRO. TO BIOLOGY FOR ENGINEER                     	C	""	4	3	0	2	600	402	2018	2
747	SBL201	HIGH DIMENSIONAL BIOLOGY                           	F	""	3	3	0	0	60	14	2018	2
748	SBL701	BIOMETRY                                           	M	""	3	3	0	0	60	10	2018	2
749	SBL703	ADVANCED CELL BIOLOGY                              	H	""	3	3	0	0	50	14	2018	2
750	SBL704	HUMAN VIROLOGY                                     	E	""	3	3	0	0	60	12	2018	2
751	SBL705	BIOLOGY OF PROTEINS                                	B	""	3	3	0	0	60	19	2018	2
752	SBL714	PLANT BIOTECH. & HUMAN HEALTH                      	F	""	3	3	0	0	60	1	2018	2
753	SBL720	GENOME AND HEALTHCARE                              	B	""	3	3	0	0	60	5	2018	2
754	SBP200	INTRODUCTION TO PRACTICAL MODERN BIOLOGY           	Q	""	2	0	0	4	60	7	2018	2
755	SBS800	INDEPENDENT STUDY                                  	Q	""	3	0	3	0	10	1	2018	2
756	SBV750	BIOINSPIRATION AND BIOMIMETICS                     	K	""	1	1	0	0	60	21	2018	2
757	SBV884	ELEMENTS OF NEUROSCIENCE                           	J	""	1	1	0	0	60	8	2018	2
758	SID880	MINOR PROJECT IN INFORMATION TECHNOLOGY            	P	""	3	0	0	6	30	0	2018	2
759	SID890	MS RESEARCH PROJECT                                	P	""	40	0	0	80	30	4	2018	2
760	SIL765	NETWORKS & SYSTEM SECURITY                         	B	""	4	3	0	2	40	33	2018	2
761	SIV895	SPECIAL MODULE ON INTELLIGENT INFO. PROCESSING     	P	""	1	1	0	0	30	1	2018	2
762	TTC410	COLLOQUIUM (TT)                                    	P	""	3	0	3	0	30	2	2018	2
763	TTT410	PRACTICAL TRAINING                                 	P	""	0	0	0	0	10	2	2018	2
764	TXD357	MINOR DESIGN PROJECT   VII                         	P	""	2	0	0	4	120	1	2018	2
765	TXD358	MINOR DESIGN PROJECT VIII                          	P	""	2	0	0	4	120	1	2018	2
766	TXD401	MAJOR PROJECT PART I                               	P	DC	4	0	0	8	120	14	2018	2
767	TXD402	MAJOR PROJECT PART II                              	P	""	8	0	0	16	120	19	2018	2
768	TXD803	MAJOR PROJECT PART II                              	P	PC	12	0	0	24	30	22	2018	2
769	TXD804	MAJOR PROJECT PART II                              	P	PC	12	0	0	24	30	15	2018	2
770	TXD806	MAJOR PROJECT PART II (TCP) 	P	PC	12	0	0	24	30	10	2018	2
771	TXL211	STRUCTURE & PHYSICAL PROPERTIE                     	D	DC	3	3	0	0	120	125	2018	2
772	TXL221	YARN MANUFACTURE I                                 	E	DC	3	3	0	0	120	109	2018	2
773	TXL231	FABRIC MANUFACTURE I                               	B	DC	3	3	0	0	120	119	2018	2
774	TXL241	TECH. OF TEXT. PREPARATION & F                     	F	DC	3	3	0	0	120	129	2018	2
775	TXL361	EVALUATION OF TEXTILE MATERIAL                     	D	DC	3	3	0	0	120	92	2018	2
776	TXL371	THEORY OF TEXTILE STRUCTURES                       	C	DC	4	3	1	0	120	123	2018	2
777	TXL372	SPECIALITY YARNS AND FABRICS                       	J	DC	2	2	0	0	120	97	2018	2
778	TXL714	ADVANCED MATERIALS CHARACTERIZATION TECHNIQUES     	P	PC	1	1	0	0	75	40	2018	2
779	TXL715	TECHNOLOGY OF SOLUTION SPUN FIBRES                 	B	PC	3	3	0	0	75	17	2018	2
780	TXL725	MECHANICS OF SPINNING MACHINES                     	A	PC	3	3	0	0	40	18	2018	2
781	TXL740	SC. & APP. OF NANOTEC. IN TEX.                     	E	PE	3	3	0	0	65	77	2018	2
782	TXL748	ADVANCES IN FINISHING OF TEXTILES                  	F	PC	3	3	0	0	40	30	2018	2
783	TXL754	SUSTAINABLE CHEMICAL PROCESSING OF TEXTILES        	B	PC	2	2	0	0	40	11	2018	2
784	TXL756	TEXTILE AUXILIARIES                                	J	PE	3	3	0	0	65	13	2018	2
785	TXL766	DE. & MANUF. OF TEXT. STR. CO.                     	B	PE	3	3	0	0	65	69	2018	2
786	TXL771	ELECTRONICS AND CONTROLS FOR TEXTILEINDUSTRY       	J	PE	4	3	0	2	65	54	2018	2
787	TXL775	TECHNICAL TEXTILES                                 	D	""	3	3	0	0	65	57	2018	2
788	TXL777	PRODUCT DESIGN AND DEVELOPMENT                     	H	PE	3	3	0	0	65	27	2018	2
789	TXL782	PRODUCTION & OPERATIONS MGMT                       	F	PE	3	3	0	0	65	53	2018	2
790	TXL783	DESIGN OF EXPER. & STAT. TECH.                     	E	""	3	3	0	0	65	71	2018	2
791	TXP212	MANUFACTURED FIBRE TECHNO. LAB                     	C	DC	1	0	0	2	120	97	2018	2
792	TXP221	YARN MANUFACTURE LABORATORYI                       	E	DC	1	0	0	2	120	108	2018	2
793	TXP231	FABRIC MANUFACTURE LAB.   I                        	B	DC	1	0	0	2	120	112	2018	2
794	TXP241	TECH. OF TEX. PRE. & FIN. LAB.                     	F	DC	1.5	0	0	3	120	117	2018	2
795	TXP361	EVALUATION OF TEXTILES LAB                         	D	DC	1	0	0	2	120	92	2018	2
796	TXP716	Fibre Production and Post Spinning Operation Laboratory 	F	PE	2	0	0	4	65	17	2018	2
797	TXP725	MECHANICS OF SPINNING MACHINES LAB                 	P	PC	1	0	0	2	40	18	2018	2
798	TXP748	TEXTILE PREPARATION AND FINISHING LAB              	P	PC	1	0	0	2	25	17	2018	2
799	TXP761	EVALUATION OF TEXTILE MATERIALS                    	C	PC	2	0	0	4	75	19	2018	2
800	TXQ302	SEMINAR COURSE 2                                   	P	""	1	0	0	2	120	128	2018	2
801	VED750	MINOR PROJECT                                      	P	""	3	0	0	6	60	0	2018	2
802	VEL700	HUMAN VALUES AND TECHNOLOGY                        	M	""	3	2	1	0	60	54	2018	2
\.


--
-- Data for Name: coursesbyprof; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.coursesbyprof (profid, courseid) FROM stdin;
13687	1
1422	2
1422	3
1422	4
1422	5
892	6
12793	7
14407	8
7463	9
7426	10
10834	11
12793	12
2247	13
13532	14
9272	15
13469	16
9289	17
12348	18
872	19
892	20
12194	21
850	22
12728	23
1431	24
13613	25
11241	26
11195	27
13509	28
13576	29
12194	30
13530	31
12652	32
14441	33
12893	34
9428	35
917	36
863	37
13530	38
12580	39
5640	40
5692	41
12685	42
7089	43
7089	44
1473	45
1473	46
1473	47
1473	48
12564	49
12806	50
14625	51
13595	52
7089	53
13597	54
1473	55
7420	56
1291	57
1480	58
13497	59
12222	60
12717	61
12172	62
12564	63
7089	64
12806	65
12717	66
12564	67
8791	68
1337	69
1337	70
9032	71
12689	72
12689	73
5642	74
7451	75
13461	76
8791	77
8900	78
12777	79
12777	80
12777	81
12777	82
12777	83
9035	84
9035	85
9035	86
9035	87
9035	88
12777	89
12777	90
12777	91
12777	92
12777	93
12777	94
7419	95
5575	96
9035	97
9521	98
1408	99
1300	100
11191	101
12609	102
13498	103
919	104
1332	105
9198	106
14585	107
7443	108
12388	109
1481	110
13572	111
8794	112
14477	113
11340	114
12777	115
11191	116
12354	117
9209	118
12771	119
14477	120
7443	121
1481	122
12388	123
9174	124
12711	125
11267	126
12902	127
2059	128
12186	129
12369	130
5666	131
12858	132
5698	133
12751	134
11205	135
12778	136
9202	137
8769	138
11267	139
7090	140
12890	141
12394	142
7480	143
12205	144
12369	145
5698	146
8769	147
13501	148
12331	149
12331	150
13501	151
13512	152
13512	153
13501	154
13553	155
1085	156
1328	157
12702	158
13512	159
13536	160
12363	161
13624	162
12363	163
13512	164
12714	165
11210	166
12734	167
12744	168
11218	169
9431	170
11336	171
12160	172
12337	173
11324	174
12331	175
4217	176
12331	177
13512	178
12551	179
9518	180
12551	181
12716	182
1628	183
4217	184
12714	185
13501	186
13501	187
11336	188
12337	189
1628	190
12716	191
12714	192
13501	193
1320	194
1320	195
1320	196
1320	197
1452	198
12189	199
12397	200
4511	201
12672	202
1289	203
12242	204
1452	205
12331	206
13512	207
9207	208
932	209
932	210
1406	211
13641	212
7404	213
7404	214
13607	215
13607	216
13607	217
9207	218
9207	219
14363	220
9207	221
14363	222
1406	223
13641	224
13641	225
4134	226
11240	227
9165	228
7453	229
1453	230
12362	231
9222	232
14363	233
12618	234
12907	235
7453	236
13607	237
4134	238
4132	239
12362	240
1406	241
9268	242
4134	243
1406	244
9590	245
2159	246
12774	247
9185	248
9185	249
13641	250
12380	251
936	252
1459	253
916	254
1453	255
11189	256
9165	257
11275	258
932	259
9310	260
7440	261
5691	262
9430	263
9207	264
9173	265
910	266
3042	267
13641	268
901	269
12577	270
7421	271
9310	272
932	273
7410	274
12618	275
11240	276
12739	277
7440	278
12739	279
5691	280
2050	281
14363	282
2399	283
1406	284
9222	285
932	286
9165	287
13607	288
11275	289
5628	290
910	291
2050	292
2159	293
12380	294
936	295
12380	296
13504	297
13504	298
12721	299
9146	300
12773	301
12773	302
5111	303
12721	304
9146	305
949	306
7432	307
12311	308
13504	309
13588	310
13588	311
9146	312
7432	313
2049	314
9249	315
11297	316
12741	317
2160	318
2160	319
2160	320
2160	321
2160	322
2160	323
2160	324
2160	325
2160	326
2160	327
2160	328
2160	329
13586	330
5610	331
5610	332
9249	333
9249	334
9249	335
10844	336
10844	337
1083	338
1083	339
11297	340
11297	341
13586	342
13586	343
836	344
11198	345
860	346
12781	347
5604	348
5610	349
10844	350
12796	351
11297	352
9249	353
2041	354
12335	355
2062	356
13626	357
8789	358
12583	359
13586	360
10807	361
7738	362
9271	363
14456	364
12755	365
12763	366
834	367
13626	368
851	369
9290	370
10840	371
2160	372
1083	373
12582	374
13543	375
1287	376
12220	377
13580	378
13585	379
13585	380
8789	381
12741	382
8779	383
13554	384
14460	385
9294	386
12657	387
8797	388
2256	389
8900	390
12825	391
13493	392
2263	393
836	394
13586	395
12213	396
7485	397
1287	398
2041	399
12335	400
2256	401
13567	402
12763	403
12825	404
8779	405
8789	406
2263	407
11198	408
13580	409
8779	410
12825	411
12825	412
13567	413
13585	414
13585	415
12706	416
12637	417
13608	418
9227	419
14358	420
5682	421
13566	422
5634	423
13716	424
12375	425
5682	426
13645	427
13490	428
13589	429
14358	430
12637	431
9227	432
9168	433
13490	434
13589	435
12375	436
14358	437
12637	438
9227	439
13566	440
9168	441
12715	442
14613	443
14371	444
1460	445
5605	446
12742	447
1429	448
12694	449
14613	450
12544	451
10790	452
10790	453
12230	454
13534	455
10790	456
8790	457
12671	458
14371	459
8790	460
1321	461
5605	462
12888	463
12402	464
12671	465
14480	466
12852	467
12715	468
10790	469
14371	470
12571	471
1297	472
12742	473
8790	474
12712	475
13534	476
2251	477
12694	478
12249	479
12903	480
11307	481
1460	482
7336	483
1611	484
9279	485
12544	486
12903	487
1612	488
12245	489
14480	490
12402	491
12903	492
12715	493
1611	494
1612	495
1460	496
12671	497
11306	498
7334	499
5671	500
8796	501
5671	502
10839	503
14456	504
2025	505
12653	506
12375	507
12375	508
2256	509
8900	510
8789	511
8789	512
8789	513
12860	514
12174	515
900	516
900	517
13562	518
12896	519
14398	520
13600	521
9037	522
1410	523
5686	524
11212	525
7411	526
12393	527
8968	528
13622	529
12175	530
5667	531
12853	532
1410	533
9203	534
5603	535
14398	536
12697	537
841	538
883	539
12894	540
13573	541
5574	542
900	543
841	544
12653	545
12853	546
9186	547
12579	548
9037	549
11284	550
14400	551
11284	552
7436	553
13488	554
12174	555
12311	556
12312	557
13562	558
2254	559
9195	560
12396	561
12227	562
12187	563
12175	564
1629	565
9229	566
12896	567
13600	568
14398	569
12894	570
7411	571
13488	572
12653	573
12227	574
1410	575
13622	576
11212	577
900	578
900	579
12834	580
12834	581
12834	582
12834	583
7392	584
9277	585
13618	586
9159	587
9159	588
9159	589
10832	590
12834	591
12165	592
12696	593
12696	594
14428	595
1439	596
10832	597
12758	598
12758	599
1092	600
9277	601
12833	602
12833	603
12833	604
12833	605
7392	606
7392	607
13495	608
8971	609
8971	610
1092	611
12889	612
13068	613
13618	614
7486	615
12778	616
10832	617
7449	618
7449	619
12834	620
13068	621
13547	622
13068	623
13547	624
1439	625
13068	626
1439	627
14428	628
1092	629
12833	630
12834	631
14428	632
12758	633
14448	634
14439	635
13499	636
12860	637
12860	638
12826	639
12748	640
14589	641
14439	642
5630	643
1395	644
846	645
12812	646
11248	647
12860	648
12566	649
2048	650
10793	651
9158	652
12900	653
9281	654
12590	655
10806	656
12233	657
12566	658
2265	659
2265	660
13499	661
9158	662
2049	663
1429	664
903	665
2025	666
13529	667
9262	668
2025	669
2025	670
12622	671
12622	672
12622	673
929	674
12157	675
10839	676
10839	677
1057	678
11332	679
14479	680
9033	681
11185	682
12597	683
12719	684
7482	685
12906	686
11187	687
10839	688
13697	689
1079	690
9033	691
893	692
14395	693
12164	694
13578	695
12157	696
929	697
933	698
2259	699
12593	700
12622	701
7406	702
12706	703
14474	704
875	705
13695	706
9315	707
2060	708
943	709
12247	710
5696	711
9177	712
9237	713
11654	714
7432	715
12390	716
7457	717
8976	718
934	719
11278	720
9237	721
12395	722
12247	723
12157	724
8976	725
8976	726
8976	727
12706	728
11699	729
11699	730
9175	731
14454	732
14466	733
13468	734
1342	735
13533	736
11699	737
8970	738
13468	739
14454	740
12404	741
9175	742
5110	743
843	744
843	745
9519	746
1482	747
1091	748
2063	749
14472	750
13689	751
843	752
1482	753
1091	754
843	755
843	756
8897	757
11324	758
11324	759
2243	760
12160	761
9283	762
8732	763
12405	764
12405	765
8975	766
8975	767
9283	768
12352	769
2262	770
12352	771
5644	772
9283	773
9240	774
1398	775
8732	776
1925	777
1488	778
9304	779
12629	780
9297	781
5615	782
12681	783
2262	784
2047	785
1320	786
12381	787
12405	788
8732	789
1411	790
2024	791
12405	792
9283	793
14593	794
1398	795
9297	796
12629	797
8975	798
12381	799
9240	800
12393	801
12393	802
\.


--
-- Data for Name: curr_courses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.curr_courses (courseid, code, name, slot, type, credits, lec_dur, tut_dur, prac_dur, strength, registered, webpage) FROM stdin;
1	AMD310	MINI PROJECT (AM)                                  	P	""	3	0	0	6	30	7	\N
2	AMD811	MAJOR PROJECT PART I                               	P	""	6	0	0	12	30	0	\N
3	AMD812	MAJOR PROJECT PART II                              	P	""	12	0	0	24	30	31	\N
4	AMD813	MAJOR PROJECT PART I                               	P	""	6	0	0	12	30	1	\N
5	AMD814	MAJOR PROJECT PART II                              	P	""	12	0	0	24	30	4	\N
6	AMD895	MAJOR PROJECT                                      	P	""	40	0	0	80	30	2	\N
7	AMD897	MINOR PROJECT                                      	X	""	4	0	0	8	60	25	\N
8	AML702	APPLIED COMPUTATIONAL METHOD                       	F	""	4	3	0	2	100	36	\N
9	AML706	FINITE ELEMENT METHODS & ITS APPL.TO MARINE STRU.  	B	""	3	3	0	0	100	32	\N
10	AML731	APPLIED ELASTICITY                                 	X	""	4	3	1	0	60	9	\N
11	AML793	SHIP DYNAMICS                                      	X	""	3	3	0	0	60	25	\N
12	AML795	SUBMARINE DESIGN                                   	X	""	3	3	0	0	60	25	\N
13	AML831	THEORY OF PLATES AND SHELLS                        	A	""	3	3	0	0	50	21	\N
14	AML832	APPLICATIONS OF THEORY OF PLATES AND SHELLS        	A	""	2	2	0	0	50	29	\N
15	AML835	MECHANICS OF COMPOSITE MATERIALS                   	X	""	3	3	0	0	40	20	\N
16	AMP776	PRODUCT DESIGN PROJECT 1                           	F	""	4	2	0	4	60	20	\N
17	APL100	ENGINEERING MECHANICS                              	A	""	4	3	1	0	250	469	\N
18	APL102	INTR.TO MATERIAL SC. & ENGG.                       	E	""	4	3	0	2	300	131	\N
19	APL105	MECHANICS OF SOLIDS AND FLUIDS                     	A	""	4	3	1	0	150	122	\N
20	APL300	COMPUTATIONAL MECHANICS                            	A	""	4	3	0	2	100	31	\N
21	APL705	FINITE ELEMENT METHOD                              	B	""	4	3	0	2	100	53	\N
22	APL711	ADVANCED FLUID MECHANICS                           	C	""	3	3	0	0	50	12	\N
23	APL713	TURBULENCE AND ITS MODELING                        	D	""	3	3	0	0	50	20	\N
24	APL720	COMPUTATIONAL FLUID DYNAMICS                       	E	""	4	3	0	2	50	22	\N
25	APL750	MODERN ENGINEERING MATERIALS                       	A	""	3	3	0	0	50	13	\N
26	APL767	ENGG. FAILURE ANALYSIS & PREV.                     	AC	""	3	3	0	0	40	15	\N
27	APL774	MODELING AND ANALYSIS                              	AA	""	3	3	0	0	40	9	\N
28	APL796	ADVANCED SOLID MECHANICS                           	X	""	3	3	0	0	50	19	\N
29	APL871	PRODUCT RELIABILITY & MAINTENANCE                  	H	""	3	3	0	0	60	33	\N
30	APV707	Micromechanics of Fracture 	X	""	1	1	0	0	30	0	\N
31	ASD882	PROJECT II                                         	Q	""	12	0	0	24	12	12	\N
32	ASL340	Fundamentals of Weather and Climate 	F	PC	3	3	0	0	80	68	\N
33	ASL350	INTRODUCTION TOOCEANOGRAPHY                        	B	""	3	3	0	0	80	71	\N
34	ASL360	THE EARTH`S ATMOSPHERE:PHYSICAL PRINCIPLES         	M	""	3	3	0	0	80	80	\N
35	ASL734	DYNAMICS OF THE ATMOSPHERE                         	H	""	3	3	0	0	30	24	\N
36	ASL736	SCIENCE OF CLIMATE CHANGE                          	J	""	3	3	0	0	25	21	\N
37	ASL737	PHYSICAL AND DYNAMICAL OCEANOGRAPHY                	E	""	3	3	0	0	25	14	\N
38	ASL738	NUMERICAL MODELING OF THE ATMOSPHERE AND OCEAN     	AD	""	3	2	0	2	16	14	\N
39	ASL751	DISPERSION OF AIR POLLUTANTS                       	F	""	3	3	0	0	40	21	\N
40	ASL754	CLOUD PHYSICS                                      	B	""	3	3	0	0	50	7	\N
41	ASL760	RENEWABLE ENERGY METEOROLOGY                       	M	""	3	3	0	0	25	5	\N
42	ASP820	ADVANCED DATA ANALYSIS FOR WEATHER AND CLIMATE     	K	""	3	1	0	4	15	12	\N
43	BBD451	MAJOR PROJECT PART 1 (BB1)                         	P	""	3	0	0	6	30	4	\N
44	BBD452	MAJOR PROJECT PART 2 (BB1)                         	Q	""	8	0	0	16	100	0	\N
45	BBD851	MAJOR PROJECT PART 1 (BB5)                         	Q	""	6	0	0	12	60	0	\N
46	BBD852	MAJOR PROJECT PART 2 (BB5)                         	Q	""	14	0	0	28	60	5	\N
47	BBD853	MAJOR PROJECT PART 1 (BB5)                         	Q	""	4	0	0	8	60	0	\N
48	BBD854	MAJOR PROJECT PART 2 (BB5)                         	Q	""	16	0	0	32	60	11	\N
49	BBD895	MAJOR PROJECT                                      	Q	""	36	0	0	72	60	11	\N
50	BBL341	ENVIRONMENTAL BIOTECHNOLOGY                        	H	DE	3	3	0	0	100	13	\N
51	BBL431	BIOPROCESS TECHNOLOGY                              	J	DC	2	2	0	0	100	77	\N
52	BBL432	FLUID SOLID SYSTEMS                                	H	DC	2	2	0	0	100	56	\N
53	BBL433	ENZYME SCIENCE AND ENGINEERING                     	D	DC	4	3	0	2	100	55	\N
54	BBL434	BIOINFORMATICS                                     	C	DC	3	2	0	2	100	73	\N
55	BBL443	MODELING & SIMULATION OF BIO.                      	J	DE	4	3	0	2	100	13	\N
56	BBL445	MEMBRANE APPLICATIONS IN BIO.                      	E	DE	3	3	0	0	100	33	\N
57	BBL736	DYNAMICS OF MICROBIAL SYSTEMS                      	B	""	3	3	0	0	60	27	\N
58	BBL740	PLANT CELL TECHNOLOGY                              	K	""	3	2	0	2	60	19	\N
59	BBL742	BIOLOGICAL WASTE TREATMENT                         	D	""	4	3	0	2	60	32	\N
60	BBL745	COMBINATORIAL BIOTECHNOLOGY                        	J	""	3	3	0	0	60	25	\N
61	BBL746	CURRENT TOPICS IN BIOCHEMICALENGINEERING AND BIOTE 	H	""	3	3	0	0	60	15	\N
62	BBL747	BIONANOTECHNOLOGY                                  	E	""	3	3	0	0	60	22	\N
63	BBL749	CANCER CELL BIOLOGY                                	F	""	4.5	3	0	3	60	36	\N
64	BBQ301	SEMINAR COURSE   I                                 	Q	""	1	0	0	2	20	20	\N
65	BBQ302	SEMINAR COURSE   II                                	Q	""	1	0	0	2	20	16	\N
66	BBQ303	SEMINAR COURSE   III                               	Q	""	1	0	0	2	20	20	\N
67	BED800	MAJOR PROJECT                                      	P	""	40	0	0	80	10	1	\N
68	BMD802	Major Project 2 	X	PC	12	0	0	24	60	7	\N
69	BML735	BIOMEDICAL SIGNAL AND IMAGE PR                     	AD	PE	3	2	0	2	60	35	\N
70	BML737	APPLICATIONS OF MATHEMATICS IN BIOMEDICAL ENG.     	D	PC	2	2	0	0	60	16	\N
71	BML740	BIOMEDICAL INSTRUMENTATION                         	E	PC	3	3	0	0	60	17	\N
72	BML750	POINT OF CARE MEDICAL DIAG DEV                     	F	PE	3	3	0	0	60	5	\N
73	BML760	BIOMEDICAL ETHICS, SAFETY AND REGULATORY AFFAIRS   	B	PC	2	2	0	0	60	9	\N
74	BML771	Orthopaedic Device Design 	H	PE	2	2	0	0	60	8	\N
75	BML820	BIOMATERIALS                                       	J	PE	3	3	0	0	60	8	\N
76	BML860	NANOMEDICINE                                       	K	PE	3	3	0	0	60	9	\N
77	BMP743	BASIC BIOMEDICAL LABORATORY                        	X	PC	2	0	0	4	60	7	\N
78	BSD895	MAJOR PROJECT(MSR)                                 	P	""	40	0	0	80	60	4	\N
79	CHD771	MINOR PROJECT                                      	Q	PC	4	0	0	8	60	0	\N
80	CHD871	MAJOR PROJECT PART 1 (CM)                          	Q	PC	6	0	0	12	60	2	\N
81	CHD872	MAJOR PROJECT PART II (CM)                         	Q	PC	14	0	0	28	60	1	\N
82	CHD873	MAJOR PROJECT PART 1 (CM)                          	Q	PC	4	0	0	8	60	0	\N
83	CHD874	MAJOR PROJECT PART 2 (CM)                          	Q	PC	16	0	0	32	60	0	\N
84	CLD411	B. TECH. PROJECT                                   	Q	DC	4	0	0	8	100	13	\N
85	CLD412	MAJOR PROJECT IN ENERGY & ENV.                     	Q	DE	5	0	0	10	100	5	\N
86	CLD413	MAJOR PROJECT IN COMPLEX FLUID                     	Q	DE	5	0	0	10	100	0	\N
87	CLD414	MAJOR PROJ. IN P.E, MOD. & OP.                     	Q	DE	5	0	0	10	100	0	\N
88	CLD415	MAJOR PROJ IN BIOP. & FINE CH.                     	Q	DE	5	0	0	10	100	3	\N
89	CLD771	MINOR PROJECT                                      	Q	PC	3	0	0	6	60	32	\N
90	CLD781	MAJOR PROJECT   I                                  	Q	PC	8	0	0	16	60	1	\N
91	CLD782	MAJOR PROJECT   II                                 	Q	PC	12	0	0	24	60	15	\N
92	CLD880	MINOR PROJECT                                      	Q	PC	4	0	0	8	60	42	\N
93	CLD881	MAJOR PROJECT PARTI                                	Q	PC	8	0	0	16	60	2	\N
94	CLD882	MAJOR PROJECT PARTII                               	Q	PC	12	0	0	24	60	39	\N
95	CLL121	CHEMICAL ENGG. THERMODYNAMICS                      	A	DC	4	3	1	0	100	143	\N
96	CLL122	CHEMICAL REACTION ENGG I                           	D	DC	4	3	1	0	100	178	\N
97	CLL231	FLUID MECHS. FOR CHEM. ENGINEE                     	F	DC	4	3	1	0	100	194	\N
98	CLL251	HEAT TRANSFER FOR CHEMICAL ENG                     	B	DC	4	3	1	0	100	187	\N
99	CLL271	INTRO TO INDUSTRIAL BIOTECH.                       	D	DC	3	3	0	0	100	108	\N
100	CLL352	MASS TRANSFER II                                   	B	DC	4	3	1	0	100	118	\N
101	CLL361	INSTRUMENTATION AND AUTOMATION                     	C	DC	2.5	1	0	3	100	106	\N
102	CLL371	CHEM. PROCESS TECH.& ECONOMICS                     	E	DC	4	3	1	0	100	127	\N
103	CLL402	PROCESS PLANT DESIGN                               	D	DE	3	3	0	0	50	12	\N
104	CLL475	SAFETY & HAZARDS IN PROC. IND.                     	B	DE	3	3	0	0	50	25	\N
105	CLL722	ELECTROCHEM. CONV. & STO. DEV.                     	B	""	3	3	0	0	50	36	\N
106	CLL727	HETERO. CATALYSIS & CATA. REA.                     	E	""	3	3	0	0	50	41	\N
107	CLL731	ADVANCED TRANSPORT PHENOMENA                       	A	""	3	3	0	0	60	100	\N
108	CLL732	ADV. CHE. ENGG. THERMODYNAMICS                     	AA	""	3	3	0	0	60	20	\N
109	CLL733	INDUSTRIAL MULTIPHASE REACTORS                     	H	PC,DE,PE	3	3	0	0	110	115	\N
110	CLL766	INTERFACIAL ENGINEERING                            	F	""	3	3	0	0	50	61	\N
111	CLL767	STRUCTURES & PROP. OF POLYMERS                     	B	""	3	3	0	0	50	22	\N
112	CLL768	FUNDAMENTALS OF COMP. FLUID DY                     	F	""	3	2	0	2	30	12	\N
113	CLL771	INTRODUCTION TO COMPLEX FLUIDS                     	F	""	3	3	0	0	50	32	\N
114	CLL772	TRANS. PHEN. IN COMPLEX FLUIDS                     	E	""	3	3	0	0	50	12	\N
115	CLL779	MOL. BIOTECH. & IN VITRO DIAG.                     	D	""	3	3	0	0	50	12	\N
116	CLL782	PROCESS OPTIMIZATION                               	E	""	3	3	0	0	50	34	\N
117	CLL786	FINE CHEMICALS TECHNOLOGY                          	E	""	3	3	0	0	50	56	\N
118	CLL788	Process Data Analytics 	D	""	3	3	0	0	60	56	\N
119	CLL793	MEMBRANE SCIENCE & ENGINEERING                     	F	""	3	3	0	0	50	50	\N
120	CLP302	CHEMICAL ENGINEERING LAB   II                      	E	DC	1.5	0	0	3	100	159	\N
121	CLP704	TECHNICAL COMMUNICATION FOR CHEMICAL ENGINEERS     	Q	""	1	0	0	2	60	66	\N
122	CLQ301	SEMINAR COURSE   I                                 	P	""	1	0	0	2	35	43	\N
123	CLQ302	SEMINAR COURSE   II                                	Q	""	1	0	0	2	35	33	\N
124	CLV797	RECENT  ADV. IN CHEMICAL ENGG.                     	X	""	2	2	0	0	60	8	\N
125	CMD641	PROJECT PART II                                    	P	""	10	0	0	20	60	49	\N
126	CMD807	MAJOR  PROJECT PART   II                           	P	""	9	0	0	18	30	11	\N
127	CML100	INTRODUCTION TO CHEMISTRY                          	D	""	3	3	0	0	200	461	\N
128	CML521	MOLECULAR THERMODYNAMICS                           	C	""	3	3	0	0	60	55	\N
129	CML522	CHEMICAL DYNA. & SURFACE CHEM.                     	F	""	3	3	0	0	60	54	\N
130	CML523	ORGANIC SYNTHESIS                                  	D	""	3	3	0	0	60	55	\N
131	CML524	TRAN. & INNER TRAN. METAL CHE.                     	A	""	3	3	0	0	60	54	\N
132	CML525	BASIC ORGANOMETALIC CHEMISTRY                      	B	""	3	3	0	0	60	54	\N
133	CML526	STR. & FUNC. OF CELLULAR BIOM.                     	E	""	3	3	0	0	60	54	\N
134	CML665	BIOPHYSICAL CHEMISTRY                              	D	""	3	3	0	0	60	8	\N
135	CML673	Bio organic and Medicinal chemistry                	F	""	3	3	0	0	60	7	\N
136	CML682	Inorganic Polymers 	E	PC	3	3	0	0	60	30	\N
137	CML724	SYNTHESIS OF INDUSTRIALLY IMPO                     	H	""	3	3	0	0	60	30	\N
138	CML729	MATERIAL CHARACTERIZATION                          	C	""	3	3	0	0	60	28	\N
139	CML737	APPLIED SPECTROSCOPY                               	E	""	3	3	0	0	60	31	\N
140	CML738	APPLICATIONS OF P BLOCK ELEMEN                     	B	""	3	3	0	0	60	16	\N
141	CML739	APPLIED BIOCATALYSIS                               	K	""	3	3	0	0	60	28	\N
142	CML740	CHEMISTRY OF HETEROCYCLIC COMP                     	A	""	3	3	0	0	60	33	\N
143	CML801	MOLECULAR MODELLING AND SIMULA                     	B	""	3	3	0	0	60	21	\N
144	CMP100	CHEMISTRY LABORATORY                               	P	""	2	0	0	4	1000	458	\N
145	CMP521	LAB III                                            	P	""	2	0	0	4	240	53	\N
146	CMP522	LAB IV                                             	P	""	2	0	0	4	240	53	\N
147	CMP728	INSTRUMENTATION LABORATORY                         	P	""	3	0	0	6	60	8	\N
148	COD310	MINI PROJECT                                       	P	""	3	0	0	6	40	27	\N
149	COD492	B.TECH PROJECT PART 1                              	P	""	6	0	0	12	120	4	\N
150	COD494	B.TECH PROJECT PART 2                              	P	""	8	0	0	16	120	40	\N
151	COD891	MINOR PROJECT                                      	P	""	3	0	0	6	80	51	\N
152	COD892	M.TECH PROJECT PARTI                               	P	""	7	0	0	14	40	0	\N
153	COD893	M.TECH PROJECT PARTII                              	P	""	14	0	0	28	50	43	\N
154	COD895	MSR PROJECT                                        	P	""	36	0	0	72	30	5	\N
155	COL100	INTRO. TO COMPUTER SCIENCE                         	B	""	4	3	0	2	600	513	\N
156	COL106	DATA STRUCTURES AND ALGORITHMS                     	F	""	5	3	0	4	180	206	\N
157	COL216	COMPUTER ARCHITECTURE                              	B	""	4	3	0	2	125	113	\N
158	COL226	PROGRAMMING LANGUAGES                              	F	""	5	3	0	4	140	127	\N
159	COL331	OPERATING SYSTEMS                                  	E	""	5	3	0	4	120	121	\N
160	COL352	INTRO TO AUTOMATA & TH. OF CO.                     	H	""	3	3	0	0	125	120	\N
161	COL362	INTRO. TO DATABASE MGMT. SYST.                     	C	""	4	3	0	2	150	115	\N
162	COL380	INTRO. TO PARALLEL & DIS. PRO.                     	J	""	3	2	0	2	120	122	\N
163	COL632	INTRODUCTION TO DATA BASESYSTEMS                   	C	""	4	3	0	2	30	15	\N
164	COL633	RESOURCE MANAGEMENT IN COMPUTER SYSTEMS            	E	""	4	3	0	2	30	3	\N
165	COL724	ADVANCED COMPUTER NETWORKS                         	D	""	4	3	0	2	40	21	\N
166	COL726	NUMERICAL ALGORITHMS                               	M	""	4	3	0	2	70	53	\N
167	COL729	COMPILER OPTIMIZATION                              	A	""	4.5	3	0	3	45	11	\N
168	COL740	SOFTWARE ENGINEERING                               	H	""	4	3	0	2	95	64	\N
169	COL758	ADVANCED ALGORITHMS                                	B	""	4	3	0	2	50	32	\N
170	COL772	NATURAL LANGUAGE PROCESSING                        	AA	""	4	3	0	2	30	45	\N
171	COL774	MACHINE LEARNING                                   	F	""	4	3	0	2	130	137	\N
172	COL781	COMPUTER GRAPHICS                                  	K	""	4.5	3	0	3	90	53	\N
173	COL786	ADVANCED FUNCTIONAL BRAIN IMG.                     	AC	""	4	3	0	2	30	20	\N
174	COL812	SYSTEM LEVEL DESIGN& MODELLING                     	C	""	3	3	0	0	30	6	\N
175	COL863	SPL. TOPICS IN THEO. COMP. SC. 	AC	""	3	3	0	0	40	25	\N
176	COL864	SPL. TOPICS IN ARTIFICIAL INT.                     	AA	""	3	3	0	0	30	23	\N
177	COL872	SPL. TOPICS IN CRYPTOGRAPHY                        	AD	""	3	3	0	0	30	30	\N
178	COL886	Special Topics in Operating Systems 	AC	""	3	3	0	0	15	6	\N
179	COP290	DESIGN PRACTICES                                   	P	""	3	0	0	6	120	135	\N
180	COP315	EMBEDDED SYSTEM DESIGN PROJECT                     	P	""	4	0	1	6	100	56	\N
181	COP701	SOFTWARE SYSTEMS LABORATORY                        	P	""	3	0	0	6	40	2	\N
182	COQ301	SEMINAR COURSE   I                                 	P	""	1	0	0	2	60	22	\N
183	COQ302	SEMINAR COURSE   II                                	P	""	1	0	0	2	60	29	\N
184	COQ303	SEMINAR COURSE   III                               	P	""	1	0	0	2	60	19	\N
185	COQ304	SEMINAR COURSE   IV                                	P	""	1	0	0	2	60	24	\N
186	COS310	INDEPENDENT STUDY (CS)                             	P	""	3	0	3	0	30	13	\N
187	COS799	INDEPENDENT STUDY                                  	P	""	3	0	3	0	30	6	\N
188	COV878	SPECIAL MODULE IN MACHINE LEA.                     	X	""	1	1	0	0	60	27	\N
189	COV880	SPECIAL MODULE IN PARALLEL CO.                     	X	""	1	1	0	0	30	7	\N
190	COV883	SPL. MODULE IN THEO. COMP. SC.                     	P	""	1	1	0	0	60	7	\N
191	COV884	SPL. MODULE IN ARTIFICIAL INT.                     	X	""	1	1	0	0	30	7	\N
192	COV887	SPL. MODULE IN HIGH SPEED NET.                     	X	""	1	1	0	0	30	22	\N
193	COV888	SPL. MODULE IN DATABASE SYST.                      	X	""	1	1	0	0	30	8	\N
194	CRD802	MINOR PROJECT                                      	A	PC	3	0	0	6	60	25	\N
195	CRD811	MAJOR PROJECT PART I                               	Q	PC	6	0	0	12	60	1	\N
196	CRD812	MAJOR PROJECT PART 2                               	Q	PC	12	0	0	24	60	22	\N
197	CRD814	MAJOR PROJECT III                                  	Q	PC	6	0	0	12	60	1	\N
198	CRL702	ARCHITECTURES AND ALGORITHMS FOR DSP SYSTEMS       	E	PC	4	2	0	4	40	27	\N
199	CRL704	SENSOR ARRAY SIGNAL PROCESSING                     	H	""	3	3	0	0	60	15	\N
200	CRL706	SONARS                                             	J	PE	3	3	0	0	60	7	\N
201	CRL712	RF AND MICROWAVE ACTIVE CIRCUITS                   	A	PE	3	3	0	0	60	26	\N
202	CRL722	RF AND MICROWAVE SOLID STATE DEVICES               	H	PE	3	3	0	0	60	10	\N
203	CRL724	RF AND MICROWAVE MEASUREMENT SYSTEM TECHNIQUES     	B	PC	3	3	0	0	60	27	\N
204	CRL732	SELECTED TOPICS IN RFDT II                         	D	PE	3	3	0	0	60	8	\N
205	CRV742	SPECIAL MODULE IN RADIO FREQUENCY DESIGN & TECH. I 	X	""	1	1	0	0	20	20	\N
206	CSD411	MAJOR PROJECT PART 1 (CS)                          	P	""	4	0	0	8	40	0	\N
207	CSD853	MAJOR PROJECT PART 1 (CO)                          	P	""	4	0	0	8	40	0	\N
208	CVC772	SEMINAR IN CONSTRUCTION TECHNO                     	R	""	1	0	0	2	30	30	\N
209	CVD411	BTECH PROJECT PART 1                               	P	""	4	0	0	8	120	30	\N
210	CVD412	BTECH PROJECT PART 2                               	P	""	6	0	0	12	120	15	\N
211	CVD700	MINOR PROJECT                                      	P	""	3	0	0	6	5	0	\N
212	CVD710	MINOR PROJECT                                      	P	""	3	0	0	6	5	0	\N
213	CVD720	MAJOR THESIS PART I                                	M	""	6	0	0	12	24	0	\N
214	CVD721	MAJOR THESIS PART II                               	M	""	12	0	0	24	25	6	\N
215	CVD756	MINOR PROJECT IN STRUCTURAL ENGINEERING            	P	""	3	0	0	6	50	0	\N
216	CVD757	MAJOR PROJECT PART I (CES)                         	P	""	9	0	0	18	50	0	\N
217	CVD758	MAJOR PROJECT PART II (CES)                        	P	""	9	0	0	18	50	17	\N
218	CVD772	MAJOR PROJECT PART I (CEC)                         	P	""	9	0	0	18	50	0	\N
219	CVD773	MAJOR PROJECT PART II (CEC)                        	P	""	12	0	0	24	30	24	\N
220	CVD776	MINOR PROJECT (CET)                                	P	""	3	0	0	6	50	0	\N
221	CVD777	MAJOR PROJECT PART I (CET)                         	P	""	9	0	0	18	50	1	\N
222	CVD778	MAJOR PROJECT PART II (CET)                        	P	""	12	0	0	24	30	19	\N
223	CVD801	MAJOR THESIS PART II                               	P	""	12	0	0	24	25	8	\N
224	CVD810	MAJOR PROJECT PART I                               	P	""	6	0	0	12	30	2	\N
225	CVD811	MAJOR PROJECT PART II (CEU)                        	P	""	12	0	0	24	26	16	\N
226	CVD832	MAJOR PROJECT PART II                              	P	""	12	0	0	24	50	12	\N
227	CVD854	MAJOR PROJECT PART II                              	P	""	12	0	0	24	30	12	\N
228	CVD895	MSR MAJOR PROJECT                                  	P	""	36	0	0	72	30	2	\N
229	CVL100	ENVIRONMENTAL SCIENCE                              	C	""	2	2	0	0	500	550	\N
230	CVL212	ENVIRONMENTAL ENGINEERING                          	B	""	4	3	0	2	120	97	\N
231	CVL222	SOIL MECHANICS                                     	F	""	3	3	0	0	120	103	\N
232	CVL242	STRUCTURAL ANALYSIS I                              	D	""	3	3	0	0	120	103	\N
233	CVL244	CONSTRUCTION PRACTICES                             	C	""	2	2	0	0	120	95	\N
234	CVL261	INTRO. TO TRANSPORTATION ENGG.                     	B	""	3	3	0	0	120	100	\N
235	CVL281	HYDRAULICS                                         	E	""	4	3	1	0	120	101	\N
236	CVL313	AIR AND NOISE POLLUTION                            	F	""	3	3	0	0	40	41	\N
237	CVL342	STEEL DESIGN                                       	D	""	3	3	0	0	120	99	\N
238	CVL381	DESIGN OF HYDRAULIC STRUCTURES                     	E	""	4	3	0	2	120	94	\N
239	CVL382	GROUNDWATER                                        	H	""	2	2	0	0	30	43	\N
240	CVL422	ROCK ENGINEERING                                   	M	""	3	3	0	0	40	40	\N
241	CVL431	DESIGN OF FOUN. & RET. STRUCT.                     	J	""	3	3	0	0	59	42	\N
242	CVL443	PRESTRESSED CON. & IND. STRUC.                     	H	""	3	3	0	0	50	50	\N
243	CVL482	WATER POWER ENGINEERING                            	X	""	3	2	0	2	30	32	\N
244	CVL702	GROUND IMPROVEMENT AND GEOSYNTHETICS               	F	""	3	3	0	0	30	12	\N
245	CVL703	GEOENVIRONMENTAL ENGINEERING                       	J	""	3	3	0	0	30	14	\N
246	CVL705	SLOPES AND RETAINING STRUCTURES                    	E	""	3	3	0	0	30	15	\N
247	CVL706	SOIL DYNAMICS AND EARTHQUAKE GEOTECHNICAL ENGG.    	B	""	3	3	0	0	30	13	\N
248	CVL712	SLOPES AND FOUNDATIONS                             	C	""	3	3	0	0	30	15	\N
249	CVL713	ANALYSIS AND DESIGN OF UNDERGROUND STRUCTURES      	D	""	3	3	0	0	30	13	\N
250	CVL714	FIELD EXPLORATION AND GEOTECHNICAL PROCESSES       	E	""	3	3	0	0	30	16	\N
251	CVL715	EXCAVATION METHODS & UNDERGROUND SPACE TECHNOLOGY  	A	""	3	3	0	0	40	13	\N
252	CVL721	SOLID WASTE ENGINEERING                            	F	""	3	3	0	0	40	40	\N
253	CVL723	WASTE WATER ENGINEERING                            	D	""	3	3	0	0	40	24	\N
254	CVL724	ENVIRONMENTAL SYSTEMS ANALYSIS                     	C	""	3	3	0	0	40	41	\N
255	CVL727	ENVIROMENTAL RISK ASSESMENT 	M	""	3	2	1	0	40	10	\N
256	CVL728	ENVIRONMENTAL QUALITY MODELING                     	A	""	3	3	0	0	40	36	\N
257	CVL734	ADVANCED HYDRAULICS                                	D	""	3	3	0	0	50	15	\N
258	CVL735	FINITE ELEMENT IN WATER RESOU.                     	J	""	3	3	0	0	50	12	\N
259	CVL743	AIRPORT PLANNING AND DESIGN                        	K	""	3	3	0	0	30	10	\N
260	CVL746	PUBLIC TRANSPORTATION SYSTEMS                      	L	""	3	3	0	0	30	20	\N
261	CVL760	THEORY OF CONCRETE STRUCTURES                      	F	""	3	3	0	0	50	20	\N
262	CVL761	THEORY OF STEEL STRUCTURES                         	B	""	3	3	0	0	50	22	\N
263	CVL762	EARTHQUAKE ANALYSIS AND DESIGN                     	A	""	3	3	0	0	50	36	\N
264	CVL774	CONSTRUCTION CONTRACT MGMT.                        	J	""	3	3	0	0	75	41	\N
265	CVL775	CONSTRUCTION ECONOMICS AND FI                      	B	""	3	3	0	0	75	50	\N
266	CVL776	CONSTRUCTION PRACTICES AND EQ                      	D	""	3	3	0	0	75	48	\N
267	CVL778	BUILDING SERVICES AND MAINTENA                     	H	""	3	3	0	0	40	6	\N
268	CVL811	NUMERICAL AND COMPUTER METHODS IN GEOMECHANICS     	F	""	3	3	0	0	10	0	\N
269	CVL830	GROUNDWATER FLOW AND POLLUTION MODELING            	F	""	3	3	0	0	50	16	\N
270	CVL833	WATER RESOURCES SYSTEMS                            	A	""	3	3	0	0	50	8	\N
271	CVL838	GEOGRAPHIC INFORMATION SYSTEMS                     	H	""	3	2	0	2	50	18	\N
272	CVL841	ADVANCED TRANSPORTATION MODELLING                  	H	""	3	2	0	2	10	6	\N
273	CVL845	VISCOELASTIC BEHAVIOR OF BITUM                     	X	""	3	3	0	0	30	5	\N
274	CVL847	TRANSPORTATION ECONOMICS                           	A	""	3	3	0	0	30	23	\N
275	CVL849	TRAFFIC FLOW MODELLING                             	M	""	3	3	0	0	30	6	\N
276	CVL850	TRANSPORTATION LOGISTICS                           	B	""	3	3	0	0	30	12	\N
277	CVL861	ANALYSIS & DESIGN OF M/C FOU.                      	E	""	3	3	0	0	50	20	\N
278	CVL863	General Continuum Mechanics 	J	""	3	3	0	0	50	6	\N
279	CVL864	STRUCTURAL HEALTH MONITORING                       	C	""	3	3	0	0	50	18	\N
280	CVL865	Structural Vibration Control 	D	PC	3	3	0	0	50	6	\N
281	CVL871	DURABILITY AND REPAIR OF CONCR                     	C	""	3	3	0	0	40	8	\N
282	CVL874	QUALITY AND SAFETY IN CONSTRUC                     	E	""	3	3	0	0	40	11	\N
283	CVL875	SUSTAINABLE MATERIALS AND GREE                     	A	""	3	3	0	0	40	31	\N
284	CVP222	SOIL MECHANICS LABORATORY                          	E	""	1	0	0	2	120	101	\N
285	CVP242	STRUCTURAL ANALYSIS LABORATORY                     	P	""	1	0	0	2	100	102	\N
286	CVP261	TRANSPORTATION ENGG. LABORATOR                     	P	""	1	0	0	2	120	101	\N
287	CVP281	HYDRAULICS LABORATORY                              	P	""	1	0	0	2	120	101	\N
288	CVP342	STRUCTURES & MATERIAL LAB                          	P	""	1	0	0	2	120	94	\N
289	CVP730	SIMULATION LABORATORY I                            	P	""	1.5	0	0	3	50	11	\N
290	CVP731	SIMULATION LABORATORY II                           	P	""	1.5	0	0	3	50	11	\N
291	CVP756	STRUCTURAL ENGINEERING LAB                         	P	""	3	0	0	6	50	32	\N
292	CVP771	CONSTRUCTION TECHNOLOGY LABORA                     	P	""	1.5	0	0	3	40	17	\N
293	CVP800	GEOENVIRONMENTAL AND GEOTECHNICAL ENGINEERING LAB  	R	""	3	0	0	6	30	11	\N
294	CVP810	ROCK MECHANICS LABORATORY II                       	R	""	3	0	0	6	30	9	\N
295	CVQ301	CIVIL ENGINEERING SEMINAR                          	Q	""	1	0	0	2	120	137	\N
296	CVS810	INDEPENDENT STUDY (CEU)                            	P	""	3	0	0	6	10	1	\N
297	DSD792	DESIGN PROJECT 1                                   	P	PC	3	0	0	6	20	21	\N
298	DSD799	DESIGN PROJECT                                     	P	PC	4	1	0	6	20	17	\N
299	DSD802	MAJOR PROJECT PART II                              	P	PC	12	0	0	24	18	6	\N
300	DSD892	INDUSTRY/ RESEARCH DESIGN PRO.                     	P	PC	9	0	0	18	20	15	\N
301	DSL712	ELECTRONIC TECH. FOR SIGNAL CONDITIONING & INTERFA 	E	PC	3	3	0	0	80	37	\N
302	DSL714	INSTRUMENT DESIGN AND SIMULATIONS                  	J	PC	3	2	0	2	20	16	\N
303	DSL734	LASER BASED INSTRUMENTATION                        	H	PC	3	3	0	0	30	16	\N
304	DSL737	DISPLAY DEVICES & TECHNOLOGY                       	K	PE	3	3	0	0	20	12	\N
305	DSL782	DESIGN FOR USABILITY                               	E	PE	3	2	0	2	60	33	\N
306	DSL811	SELECTED TOPICS IN INSTRUMENTATION I               	F	PE	3	3	0	0	30	9	\N
307	DSP704	INSTRUMENT TECHNOLOGY LABORATORY II                	P	PC	3	0	0	6	20	16	\N
308	DSP711	COMP.  AIDED PRODUCT DETAILING                     	J	PC	3	1	0	4	40	22	\N
309	DSP722	APPLIED ERGONOMICS                                 	A	PC	2	1	0	2	40	33	\N
310	DSP741	PRODUCT INTERFACE & DESIGN                         	B	PC	2	1	0	2	40	23	\N
311	DSR772	TRANSPORTATION DESIGN                              	P	PE	3	2	0	2	20	13	\N
312	DSR812	MEDIA STUDIES                                      	D	PE	3	2	0	2	60	21	\N
313	DSS720	Independent Study 	P	""	3	0	3	0	30	1	\N
314	DTD899	DOCTORAL THESIS                                    	X	""	0	0	0	0	5000	2097	\N
315	EED854	MAJOR PROJECT PART 2 (EI)                          	P	""	16	0	0	32	30	2	\N
316	EED898	MAJOR PROJECT PART II                              	P	""	12	0	0	24	30	1	\N
317	EET410	PRACTICAL TRAINING                                 	P	""	0	0	0	0	10	2	\N
318	ELD411	B.TECH. PROJECT   I                                	P	""	3	0	0	6	100	14	\N
319	ELD431	B.TECH. PROJECT   I                                	P	""	3	0	0	6	100	11	\N
320	ELD450	BTP PART II                                        	P	""	8	0	0	16	100	11	\N
321	ELD451	BTP PART II                                        	P	""	8	0	0	16	100	0	\N
322	ELD452	BTP PART II                                        	P	""	8	0	0	16	100	0	\N
323	ELD453	BTP PART II                                        	P	""	8	0	0	16	100	0	\N
324	ELD454	BTP PART II                                        	P	""	8	0	0	16	100	0	\N
325	ELD455	BTP PART II                                        	P	""	8	0	0	16	100	0	\N
326	ELD456	BTP PART II                                        	P	""	8	0	0	16	100	0	\N
327	ELD457	BTP PART II                                        	P	""	8	0	0	16	100	1	\N
328	ELD458	BTP PART II                                        	P	""	8	0	0	16	100	0	\N
329	ELD459	BTP PART II                                        	P	""	8	0	0	16	100	0	\N
330	ELD780	MINOR PROJECT                                      	P	""	2	0	0	4	60	22	\N
331	ELD800	MINOR PROJECT (EEA)                                	P	""	3	0	0	6	60	0	\N
332	ELD802	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	4	\N
333	ELD810	MINOR PROJECT (COMMUNICATION E                     	P	""	3	0	0	6	60	1	\N
334	ELD811	MAJOR PROJECT PART I (COMMUNIC                     	P	""	6	0	0	12	60	0	\N
335	ELD812	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	11	\N
336	ELD831	MAJOR PROJECT PART I (INTEGRAT                     	P	""	6	0	0	12	60	1	\N
337	ELD832	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	10	\N
338	ELD851	MAJOR PROJECT PART I                               	P	""	6	0	0	12	60	0	\N
339	ELD852	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	9	\N
340	ELD871	MAJOR PROJECT PART I                               	P	""	6	0	0	12	60	3	\N
341	ELD872	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	3	\N
342	ELD880	MAJOR PROJECT PART I                               	P	""	6	0	0	12	60	15	\N
343	ELD881	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	8	\N
344	ELD895	MS RESEARCH PROJECT                                	P	""	36	0	0	72	60	20	\N
345	ELL100	INTRO. TO ELECTRICAL ENGG.                         	E	""	4	3	0	2	400	455	\N
346	ELL201	DIGITAL ELECTRONICS                                	B	""	4.5	3	0	3	350	276	\N
347	ELL205	SIGNALS AND SYSTEMS                                	D	""	4	3	1	0	150	115	\N
348	ELL212	ENGINEERING ELECROMAGNETICS                        	E	""	4	3	1	0	150	92	\N
349	ELL225	CONTROL ENGINEERING I                              	F	""	4	3	1	0	150	129	\N
350	ELL231	POWER ELECTR. & ENERGY DEVICES                     	A	""	3	3	0	0	150	46	\N
351	ELL301	ELECTRICAL & ELECTRONIC INSTR.                     	C	""	3	3	0	0	130	119	\N
352	ELL303	POWER ENGINEERING I                                	F	""	4	3	1	0	150	145	\N
353	ELL319	DIGITAL SIGNAL PROCESSING                          	M	""	4	3	0	2	70	33	\N
354	ELL332	ELECTRIC DRIVES                                    	B	""	3	3	0	0	100	67	\N
355	ELL365	EMBEDDED SYSTEMS                                   	A	""	3	3	0	0	160	123	\N
356	ELL400	POWER SYSTEMS PROTECTION                           	E	""	3	3	0	0	50	34	\N
357	ELL402	COMPUTER COMMUNICATION                             	K	""	3	3	0	0	100	12	\N
358	ELL409	MACHINE INTELLIGENCE& LEARNING                     	J	""	4	3	0	2	65	66	\N
359	ELL411	DIGITAL COMMUNICATIONS                             	F	""	4	3	0	2	120	4	\N
360	ELL457	SPECIAL TOPICS IN COGNITIVE & INTELLIGENT SYSTEMS  	M	""	3	3	0	0	50	4	\N
361	ELL703	OPTIMAL CONTROL THEORY                             	M	""	3	3	0	0	60	23	\N
362	ELL705	STOCHASTIC FILTERING AND IDENT                     	B	""	3	3	0	0	60	20	\N
363	ELL715	DIGITAL IMAGE PROCESSING                           	J	""	4	3	0	2	150	65	\N
364	ELL717	OPTICAL COMMUNICATION SYSTEMS                      	A	""	3	3	0	0	60	24	\N
365	ELL719	DETECTION & ESTIMATION THEORY                      	B	""	3	3	0	0	60	44	\N
366	ELL720	ADVANCED DIGITAL SIGNAL PROCES                     	H	""	3	3	0	0	60	14	\N
367	ELL723	BROADBAND COMMUNICATION SYSTEM                     	F	""	3	3	0	0	90	65	\N
368	ELL725	WIRELESS COMMUNICATIONS                            	M	""	3	3	0	0	60	12	\N
369	ELL726	NANOPHOTONICS AND PLASMONICS                       	X	""	3	3	0	0	60	17	\N
370	ELL730	I.C. TECHNOLOGY                                    	C	""	3	3	0	0	60	41	\N
371	ELL731	MIXED SIGNAL CIRCUIT DESIGN                        	X	""	3	3	0	0	60	27	\N
372	ELL742	INTRODUCTION TO MEMS DESIGN                        	X	""	3	3	0	0	60	10	\N
373	ELL752	ELECTRIC DRIVE SYSTEM                              	F	""	3	3	0	0	60	21	\N
374	ELL759	POWER ELECTRONIC CONVERTERS FO                     	X	""	3	3	0	0	60	12	\N
375	ELL760	SWITCHED MODE POWER CONVERSION                     	M	""	3	3	0	0	60	18	\N
376	ELL769	ELECTRICAL SYSTEMS FOR CONSTRUCTION INDUSTRIES     	E	""	4	3	0	2	60	23	\N
377	ELL776	ADVANCED POWER SYSTEM OPTIMIZA                     	D	""	3	3	0	0	60	17	\N
378	ELL778	DYNAMIC MODELLING AND CONTROL                      	H	""	3	3	0	0	60	28	\N
379	ELL783	OPERATING SYSTEMS                                  	A	""	4	3	0	2	60	29	\N
380	ELL784	INTRODUCTION TO MACHINE LEARNI                     	C	""	3	3	0	0	50	49	\N
381	ELL791	NEURAL SYSTEMS AND LEARNING MA                     	J	""	4	3	0	2	20	7	\N
382	ELL802	ADAPTIVE AND LEARNING CONTROL                      	AD	""	3	3	0	0	60	22	\N
383	ELL803	MODEL REDUCTION IN CONTROL                         	A	""	3	3	0	0	60	1	\N
384	ELL805	NETWORKED AND MULTI AGENT CONT                     	X	""	3	3	0	0	60	12	\N
385	ELL814	WIRELESS OPTICAL COMMUNICATION                     	H	""	3	3	0	0	60	28	\N
386	ELL815	MIMO WIRELESS COMMUNICATIONS                       	E	""	3	3	0	0	60	22	\N
387	ELL821	SELECTED TOPICS IN COMMUNICATI                     	X	""	3	3	0	0	60	8	\N
388	ELL822	SELECTED TOPICS IN COMMUNICATI                     	X	""	3	3	0	0	60	5	\N
389	ELL823	SELECTED TOPICS IN INFORMATION PROCESSING I        	X	""	3	3	0	0	60	26	\N
390	ELL824	SELECTED TOPICS ININFORMATION PROCESSING   II      	X	""	3	3	0	0	60	13	\N
391	ELL833	CMOS RF IC DESIGN                                  	X	""	3	3	0	0	70	63	\N
392	ELL850	DIGITAL CONTROL OF POWER ELECT                     	K	""	3	3	0	0	60	26	\N
393	ELL851	COMPUTER AIDED DESIGN OF ELECT                     	D	""	3	3	0	0	60	17	\N
394	ELL870	RESTRUCTURED POWER SYSTEM                          	M	""	3	3	0	0	60	14	\N
395	ELL880	SPECIAL TOPICS IN COMPUTERS 1                      	X	""	3	3	0	0	60	15	\N
396	ELL888	ADVANCED MACHINE LEARNING                          	X	""	3	3	0	0	70	69	\N
397	ELL896	Mobile Computing                                   	X	""	3	3	0	0	60	15	\N
398	ELP203	ELECTROMECHANICS LABORATORY                        	P	""	1.5	0	0	3	150	131	\N
399	ELP302	POWER ELECTRONICS LABORATORY                       	P	""	1.5	0	0	3	140	150	\N
400	ELP305	DESIGN AND SYSTEM LABORATORY                       	P	""	1.5	0	0	3	100	197	\N
401	ELP311	COMMUNICATION ENGINEERING LAB.                     	D	""	1	0	0	2	220	85	\N
402	ELP720	TELECOMMUNICATION NETWORKS LABORATORY              	P	""	3	0	1	4	60	12	\N
403	ELP725	WIRELESS COMMUNICATION LABORAT                     	P	""	3	0	1	4	60	30	\N
404	ELP736	PHYSICAL DESIGN LABORATORY                         	P	""	3	0	0	6	60	13	\N
405	ELP801	ADVANCED CONTROL LABORATORY                        	P	""	2	0	0	4	60	14	\N
406	ELP832	IEC LABORATORY II                                  	P	""	3	0	0	6	60	11	\N
407	ELP852	ELECTRICAL DRIVES LABORATORY                       	P	""	1.5	0	0	3	60	11	\N
408	ELP853	DSP BASED CONTROL OF POWER ELE                     	P	""	1.5	0	0	3	60	11	\N
409	ELP871	POWER SYSTEM LAB 2                                 	P	""	3	0	1	4	60	16	\N
410	ELQ301	SEMINAR COURSE   I                                 	P	""	1	0	0	2	100	101	\N
411	ELS310	INDEPENDENT STUDY (EE1)                            	P	""	3	0	3	0	100	15	\N
412	ELS330	INDEPENDENT STUDY (EE3)                            	P	""	3	0	3	0	100	8	\N
413	ELS880	Independent Study 	P	""	3	3	0	0	60	1	\N
414	ELV780	SPECIAL MODULE IN COMPUTERS                        	X	""	1	1	0	0	60	20	\N
415	ELV781	SPECIAL MODULE IN INFORMATIONPROCESSING  I         	X	""	1	1	0	0	25	21	\N
416	EPC410	COLLOQUIUM (PH)                                    	P	""	3	0	3	0	5	2	\N
417	ESL300	SELF ORGANIZING DYNAMICAL SYSTEMS                  	J	""	3	3	0	0	60	61	\N
418	ESL330	ENERGY, ECOLOGY AND ENVIRONMENT                    	D	""	4	3	1	0	60	61	\N
419	ESL340	NON CONVENTIONAL SOURCES OF ENERGY                 	E	""	4	3	0	2	60	15	\N
420	ESL350	ENERGY CONSERVATION MANAGEMENT                     	X	""	3	3	0	0	75	62	\N
421	ESL360	DIRECT ENERGY CONVERSION                           	F	""	4	3	1	0	60	16	\N
422	ESL710	ENERGY,ECOLOGY AND ENVIRONMENT                     	D	""	3	3	0	0	60	35	\N
423	ESL714	POWER PLANT ENGG.                                  	H	""	3	3	0	0	60	16	\N
424	ESL718	POWER GENERATION ,TRANSMISSION & DISTRIBUTION      	M	""	3	3	0	0	60	12	\N
425	ESL730	DIRECT ENERGY CONVERSION                           	B	""	3	3	0	0	60	24	\N
426	ESL734	NUCLEAR ENERGY                                     	E	""	3	3	0	0	60	12	\N
427	ESL750	ECONOMICS & PLANNING OF ENERGY SYSTEMS             	A	""	3	3	0	0	60	29	\N
428	ESL755	SOLAR PHOTOVOLTAIC DEVICES AND SYSTEMS             	F	""	3	3	0	0	60	14	\N
429	ESL796	OPERATION AND CONTROL OF ELECTRICAL ENERGY SYSTEMS 	AA	""	3	3	0	0	60	8	\N
430	ESL840	SOLAR ARCHITECTURE                                 	AA	""	3	3	0	0	60	7	\N
431	ESL871	ADVANCAED FUSION ENERGY                            	F	""	3	3	0	0	60	11	\N
432	ESL880	SOLAR THERMAL POWER GENERATION                     	M	""	3	3	0	0	60	11	\N
433	ESP713	ENERGY LABORATORY                                  	P	PC	3	0	0	6	35	23	\N
434	ESQ301	SEMINAR COURSE   I                                 	X	""	1	0	0	2	25	26	\N
435	ESQ303	SEMINAR COURSE III                                 	X	""	1	0	0	2	25	24	\N
436	ESQ304	SEMINAR COURSE IV                                  	X	""	1	0	0	2	25	24	\N
437	ESQ306	SEMINAR COURSE ON BIOENERGY                        	X	""	1	0	0	2	25	17	\N
438	ESQ307	SEMINAR COURSE ON NUCLEARENERGY AND FUTURISTIC USE 	X	""	1	0	0	2	25	25	\N
439	ESQ308	SEMINAR COURSE ONENERGY ENVIRONMENT INTERACTION    	X	""	1	0	0	2	25	22	\N
440	ESQ309	SEMINAR COURSE ON ALTERNATIVEFUELS FOR TRANSPORTAT 	X	""	1	0	0	2	25	23	\N
441	ESQ310	NGU: Seminar Course on Multiphase Flows in the Energy Sector 	X	""	1	0	0	2	25	4	\N
442	HSD700	SEMINAR (CASE MATERIAL BASED)MINOR PROJECT         	X	""	3	0	0	6	60	6	\N
443	HSL262	Social Psychological Approaches to Health and Wellbeing 	A	HU	4	3	1	0	46	53	\N
444	HSL701	INTRODUCTION TO SCIENCE ANDTECHNOLOGY POLICY STUDI 	X	""	1.5	1	0	1	30	12	\N
445	HSL702	Approaches to Science and Technology Policy Studies 	X	""	1.5	1.5	0	0	9	10	\N
446	HSL713	MACROECONOMICS                                     	B	""	3	3	0	0	60	12	\N
447	HSL719	ADVANCED ECONOMETRICS                              	X	""	3	3	0	0	30	5	\N
448	HSL731	WHAT IS A TEXT                                     	X	""	3	3	0	0	30	9	\N
449	HSL751	CRITICAL READING IN PHILOSOPHICAL                  	X	""	3	3	0	0	30	6	\N
450	HSL766	The Psychology of Leadership and Social Change 	M	PC	3	3	0	0	30	8	\N
451	HSL772	SOCIOLOGY OF INDIA                                 	X	""	3	3	0	0	30	7	\N
452	HSL800A	RESEARCH WRITING                                   	A	""	3	3	0	0	90	82	\N
453	HSL800B	RESEARCH WRITING                                   	M	""	3	3	0	0	90	144	\N
454	HSL841	MINIMALIST ARCHITECTURE OF GRAMMAR                 	X	""	3	3	0	0	60	3	\N
455	HSL852	POLITICAL PHILOSOPHY                               	AC	OE	3	3	0	0	30	18	\N
456	HSL860	ADVANCED TOPICS IN PHILOSOPHY                      	X	""	3	3	0	0	60	13	\N
457	HSV319	Global Political Economy 	X	""	1	1	0	0	100	0	\N
458	HSV748	DATA ANALYSIS FOR PSYCHOLINGUISTICS USING R        	X	""	2	2	0	0	60	14	\N
459	HSV781	Introduction to research methodology 	X	""	1.5	1.5	0	0	30	22	\N
460	HUL211A	INTRODUCTION TO ECONOMICS                          	A	HU	4	3	1	0	100	101	\N
461	HUL211B	INTRODUCTION TO ECONOMICS                          	M	HU	4	3	1	0	100	95	\N
462	HUL212	MICROECONOMICS                                     	M	HU	4	3	1	0	100	100	\N
463	HUL231	AN INTRODUCTION TO LITERATURE                      	J	HU	4	3	1	0	99	102	\N
464	HUL239	INDIAN FICTION IN ENGLISH                          	M	HU	4	3	1	0	100	101	\N
465	HUL242	FUNDAMENTALS OF LANGUAGE SCIENCES                  	A	HU	4	3	1	0	300	301	\N
466	HUL261	INTRODUCTION TO PSYCHOLOGY                         	A	HU	4	3	1	0	100	99	\N
467	HUL267	POSITIVE PSYCHOLOGY                                	A	HU	4	3	1	0	88	93	\N
468	HUL271	INTRODUCTION TO SOCIOLOGY                          	M	HU	4	3	1	0	100	97	\N
469	HUL274	RETHINKING THE INDIAN TRADITION                    	B	HU	4	3	1	0	100	104	\N
470	HUL286A	SOCIAL SCIENCE APPROACHES TO DEVELOPMENT           	M	HU	4	3	1	0	100	115	\N
471	HUL286B	SOCIAL SCIENCE APPROACHES TO DEVELOPMENT           	B	HU	4	3	1	0	100	101	\N
472	HUL307	FANTASY LITERATURE                                 	H	HU	3	3	0	0	34	32	\N
473	HUL315	ECONOMETRIC METHODS                                	M	HU	3	3	0	0	35	42	\N
474	HUL316	INDIAN ECONOMIC PROBLEMS AND POLICIES              	M	HU	3	3	0	0	35	44	\N
475	HUL320	SELECTED TOPICS IN ECONOMICS                       	M	HU	3	3	0	0	35	36	\N
476	HUL335	INDIAN THEATRE                                     	M	HU	3	3	0	0	29	28	\N
477	HUL356	BUDDHISM ACROSS TIME AND PLACE                     	M	""	3	3	0	0	35	35	\N
478	HUL360	SELECTED TOPICS IN PHILOSOPHY                      	A	HU	3	3	0	0	35	37	\N
479	HUL362	ORGANIZATIONAL BEHAVIOUR                           	M	HU	3	3	0	0	35	36	\N
480	HUL370	SELECTED TOPICS IN PSYCHOLOGY                      	B	HU	3	3	0	0	35	42	\N
481	HUL371A	SCIENCE, TECHNOLOGY AND SOCIETY                    	A	HU	3	3	0	0	34	37	\N
482	HUL371B	SCIENCE, TECHNOLOGY AND SOCIETY                    	M	HU	3	3	0	0	30	33	\N
483	HUL375	THE SOCIOLOGY OF RELIGION                          	J	HU	3	3	0	0	35	35	\N
484	HUL376	POLITICAL ECOLOGY OF WATER                         	M	HU	3	3	0	0	35	36	\N
485	HUL378	INDUSTRY AND WORK CULTURE UNDE                     	H	HU	3	3	0	0	35	35	\N
486	HUL380	SELECTED TOPICS IN SOCIOLOGY                       	J	HU	3	3	0	0	35	36	\N
487	HUL381A	MIND                                               	M	HU	3	3	0	0	33	32	\N
488	HUL381B	MIND                                               	A	HU	3	3	0	0	35	35	\N
489	HUL743	Language Acquisition, Teaching and Assessment 	B	""	3	3	0	0	30	3	\N
490	HUL763	Cognitive Psychology 	J	""	3	3	0	0	30	17	\N
491	HUL843	THE PHILOSOPHY OF LANGUAGE                         	X	""	3	3	0	0	30	7	\N
492	HUL861	Psychology of Decision Making 	AA	""	3	3	0	0	30	12	\N
493	HUL874	Civil Society and Democracy in India 	X	""	3	3	0	0	60	4	\N
494	HUL875	Ethnic Identity, Development and Democratization in North east India 	AA	""	3	3	0	0	30	3	\N
495	HUL888	APPLIED LINGUISTICS                                	X	""	3	3	0	0	30	3	\N
496	HUV705	Climate policy, politics and governance 	X	HU	1	1	0	0	29	28	\N
497	HUV751	CURRENT TRENDS IN PSYCHOLINGUISTICS                	X	""	1	1	0	0	60	34	\N
498	ITL702	DIAGNOSTIC MAINTENANCE AND MONITORING              	J	""	4	3	0	2	60	16	\N
499	ITL711	RELIABILITY AVAILABILITY AND MAINTAINABILITY(RAM)  	F	""	3	3	0	0	60	21	\N
500	ITL714	FAILURE ANALYSIS AND REPAIR                        	B	""	4	3	0	2	60	15	\N
501	ITL717	CORROSION AND ITS CONTROL                          	A	""	3	3	0	0	60	9	\N
502	JID802	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	12	\N
503	JOD802	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	8	\N
504	JOP792	FIBER OPTICS AND OPTICAL COMMUNICATION LAB.II      	P	""	3	0	0	6	60	22	\N
505	JPD802	MAJOR PROJECT PART II                              	A	""	12	0	0	24	60	14	\N
506	JRD301	MINI PROJECT IN ROBOTICS                           	P	""	7	0	0	14	20	7	\N
507	JSD801	MAJOR PROJECT PART I                               	P	PC	6	0	0	12	35	0	\N
508	JSD802	MAJOR PROJECT PART II                              	P	PE	12	0	0	24	35	6	\N
509	JTD792	MINOR PROJECT                                      	P	""	3	0	0	6	60	15	\N
510	JTD802	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	9	\N
511	JVD809	MINOR PROJECT                                      	P	""	6	0	0	12	60	0	\N
512	JVD811	MAJOR PROJECT PART I                               	P	""	12	0	0	24	60	1	\N
513	JVD812	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	7	\N
514	MAD852	MAJOR PROJECT PART 2 (MT)                          	P	""	14	0	0	28	30	2	\N
515	MCD310	MINI PROJECT                                       	P	""	3	0	0	6	100	19	\N
516	MCD411	B.TECH.PROJECT                                     	P	""	4	0	0	8	100	28	\N
517	MCD412	B.TECH.PROJECT   II                                	P	""	7	0	0	14	100	54	\N
518	MCD812	MAJOR PROJECT PART II (THERMALENGINEERING)         	P	""	12	0	0	24	60	18	\N
519	MCD832	MAJOR PROJECT PART II                              	P	""	12	0	0	24	60	14	\N
520	MCD862	MAJOR PROJECT PART II                              	Q	""	12	0	0	24	60	7	\N
521	MCD882	MAJOR PROJECT PART 2                               	X	""	12	0	0	24	60	8	\N
522	MCD895	MAJOR PROJECT                                      	P	""	40	0	0	80	60	2	\N
523	MCL131	MANUFACTURING PROCESSES I                          	F	""	3	3	0	0	100	72	\N
524	MCL132	METAL FORMING AND PRESS TOOLS                      	H	""	3	3	0	0	100	64	\N
525	MCL133	NEAR NET SHAPE MANUFACTURING                       	F	""	3	3	0	0	100	66	\N
526	MCL136	MATERIAL REMOVAL PROCESSES                         	H	""	3	3	0	0	100	68	\N
527	MCL142	THERMAL SC. FOR ELE. ENGINEERS                     	D	""	3	3	0	0	100	131	\N
528	MCL201	MECHANICAL ENGG. DRAWING                           	E	DC	3.5	2	0	3	100	133	\N
529	MCL212	CONTROL THEORY & APPLICATIONS                      	B	DC	4	3	0	2	100	151	\N
530	MCL241	ENERGY SYSTEMS AND TECH.                           	B	""	3.5	3	0	1	100	73	\N
531	MCL311	CAD & FINITE ELEMENT ANALYSIS                      	E	DC	4	3	0	2	100	146	\N
532	MCL321	AUTOMOTIVE SYSTEMS                                 	F	DE	4	3	0	2	60	32	\N
533	MCL331	MICRO AND NANO MANUFACTURING                       	A	""	3	3	0	0	100	55	\N
534	MCL343	INTRODUCTION TO COMBUSTION                         	J	""	3	3	0	0	100	31	\N
535	MCL347	INTERMEDIATE HEAT TRANSFER                         	H	""	3	3	0	0	60	37	\N
536	MCL361	MANUFACTURING SYSTEM DESIGN                        	D	""	3	3	0	0	100	141	\N
537	MCL380	SPL. TOPICS IN MECHANICAL ENGG                     	H	""	3	3	0	0	100	12	\N
538	MCL421	AUTOMOTIVE STRUCTURAL DESIGN                       	H	DE	3	2	0	2	60	7	\N
539	MCL443	ELECTROCHEMICAL ENERGY SYSTEMS                     	B	""	3	3	0	0	25	10	\N
540	MCL705	EXPERIMENTAL METHODS                               	C	PC	4	3	0	2	60	54	\N
541	MCL723	Vehicle Dynamics 	C	DE	3	3	0	0	30	12	\N
542	MCL730	DESIGNING WITH ADVANCE MATERIALS                   	B	""	4	3	0	2	40	24	\N
543	MCL733	VIBRATIONS AND NOISE ENGINEERING                   	A	DE,PE	4	3	0	2	50	30	\N
544	MCL736	AUTOMOTIVE DESIGN                                  	H	DE,PE	4	3	0	2	40	15	\N
545	MCL738	DYNAMICS OF MULTIBODY SYSTEMS                      	F	DE,PE	3	2	0	2	40	15	\N
546	MCL741	CONTROL ENGINEERING                                	C	PE	4	3	0	2	25	13	\N
547	MCL743	PLANT EQUIPMENT DESIGN                             	F	DE,PE	3	3	0	0	40	26	\N
548	MCL745	ROBOTICS                                           	H	DE,PE	4	3	0	2	40	21	\N
549	MCL747	DESIGN OF PRECISION MACHINES                       	F	DE,PE	3	2	0	2	40	20	\N
550	MCL754	OPERATIONS PLANNING AND CONTRO                     	B	PC	3	3	0	0	60	19	\N
551	MCL759	ENTREPRENEURSHIP                                   	K	PE	3	3	0	0	40	51	\N
552	MCL770	STOCHASTIC MODELING AND SIMULATION                 	A	PE	3	3	0	0	60	10	\N
553	MCL771	VALUE ENGINEERING AND LIFE CYC                     	H	PE	3	3	0	0	50	32	\N
554	MCL778	DESIGN AND METALLURGY OF WELDE                     	A	""	4	3	0	2	60	15	\N
555	MCL782	COMPUTATIONAL METHODS                              	B	""	2	2	0	0	60	37	\N
556	MCL784	COMPUTER AIDED MANUFACTURING                       	F	""	4	3	0	2	60	25	\N
557	MCL786	METROLOGY                                          	E	""	3	2	0	2	60	20	\N
558	MCL813	COMPUTATIONAL HEAT TRANSFER                        	E	""	4	3	0	2	25	27	\N
559	MCL814	CONVECTIVE HEAT TRANSFER                           	F	""	3	3	0	0	60	34	\N
560	MCL818	HEATING, VENTILATING AND AIR C                     	J	""	3	3	0	0	60	6	\N
561	MCL821	RADIATION HEAT TRANSFER                            	J	""	3	3	0	0	60	8	\N
562	MCL822	STEAM AND GAS TURBINES                             	B	""	4	3	0	2	60	2	\N
563	MCL823	THERMAL DESIGN                                     	B	""	4	3	0	2	60	12	\N
564	MCL825	DESIGN OF WIND POWER FARMS                         	D	""	4	3	0	2	60	22	\N
565	MCL826	INTRODUCTION TO MICROFLUIDICS                      	H	""	4	3	0	2	60	11	\N
566	MCL865	ADVANCED OPERATIONS RESEARCH                       	J	PE	3	3	0	0	60	43	\N
567	MCP100	ENGG. VISUALIZATION & COMM.                        	Q	""	1.5	0	0	3	100	471	\N
568	MCP101	PRODUCT REALIZATION BY MANF.                       	Q	""	2	0	0	4	500	455	\N
569	MCP261	INDUSTRIAL ENGINEERING LAB   I                     	Q	""	1	0	0	2	100	59	\N
570	MCP301	MECHANICAL ENGINEERING LAB   I                     	Q	""	1.5	0	0	3	100	76	\N
571	MCP331	MANUFACTURING LABORATORY II                        	Q	""	1	0	0	2	100	79	\N
572	MCP332	PRODUCTION ENGINEERING LAB  II                     	Q	""	1	0	0	2	100	63	\N
573	MCQ301	SEMINAR COURSE   I                                 	X	""	1	0	0	2	30	30	\N
574	MCQ302	SEMINAR COURSE   II                                	X	""	1	0	0	2	30	28	\N
575	MCQ303	SEMINAR COURSE   III                               	X	""	1	0	0	2	30	30	\N
576	MCV849	SPECIAL MODULE IN SYSTEM DESIGN                    	C	""	1	1	0	0	30	7	\N
577	MEC410	COLLOQUIUM (ME)                                    	P	""	3	0	3	0	10	1	\N
578	MED411	MAJOR PROJECT PART 1 (ME)                          	P	""	3	0	0	6	60	0	\N
579	MED412	MAJOR PROJECT PART 2 (ME)                          	P	""	7	0	0	14	100	2	\N
580	MSD792	MINOR PROJECT                                      	P	""	3	0	0	6	60	17	\N
581	MSD890	MAJOR PROJECT (UNIQUE CORE)                        	P	""	6	0	0	12	60	85	\N
582	MSD891	MAJOR PROJECT (UNIQUE CORE)                        	P	""	6	0	0	12	60	26	\N
583	MSD892	MAJOR PROJECT (UNIQUE CORE)                        	P	""	6	0	0	12	60	50	\N
584	MSL301	ORGANIZATION AND PEOPLE MANAGEMENT                 	M	""	3	3	0	0	80	91	\N
585	MSL303	MARKETING MANAGEMENT                               	A	""	3	3	0	0	80	84	\N
586	MSL700	FUNDAMENTALS OF MANAGEMENT OF TECHNOLOGY           	T	FE	3	3	0	0	60	55	\N
587	MSL705A	HRM SYSTEMS                                        	R1	PC	1.5	1.5	0	0	60	34	\N
588	MSL705B	HRM SYSTEMS                                        	AA	PC	1.5	1.5	0	0	60	37	\N
589	MSL705C	HRM SYSTEMS                                        	AB	PC	1.5	1.5	0	0	60	32	\N
590	MSL706	BUSINESS LAWS                                      	D	PC	3	3	0	0	60	113	\N
591	MSL708A	FINANCIAL MANAGEMENT                               	T	PC	3	3	0	0	60	39	\N
592	MSL708B	FINANCIAL MANAGEMENT                               	F	PC	3	3	0	0	60	74	\N
593	MSL711A	STRATEGIC MANAGEMENT                               	AC	PC	3	3	0	0	60	41	\N
594	MSL711B	STRATEGIC MANAGEMENT                               	D	PC	3	3	0	0	60	32	\N
595	MSL713A	INFORMATION SYSTEMS MANAGEMENT                     	S	PC	3	3	0	0	60	35	\N
596	MSL713B	INFORMATION SYSTEMS MANAGEMENT                     	A	PC	3	3	0	0	60	42	\N
597	MSL713C	INFORMATION SYSTEMS MANAGEMENT                     	B1	PC	3	3	0	0	60	32	\N
598	MSL720A	MACROECONOMIC ENV. OF BUSINESS                     	E	PC	3	3	0	0	60	48	\N
599	MSL720B	MACROECONOMIC ENV. OF BUSINESS                     	H	PC	3	3	0	0	60	37	\N
600	MSL721	ECONOMETRICS                                       	T	SE	3	3	0	0	60	69	\N
601	MSL723	TELECOM SYSTEMS MANAGEMENT                         	K	""	3	3	0	0	60	21	\N
602	MSL727A	INTERPERSONAL BEHAVIOR & TEAM DYNAMICS             	Q1	SE	1.5	1.5	0	0	60	70	\N
603	MSL727B	INTERPERSONAL BEHAVIOR & TEAM DYNAMICS             	B1	SE	1.5	1.5	0	0	60	42	\N
604	MSL727C	INTERPERSONAL BEHAVIOR & TEAM DYNAMICS             	AA	SE	1.5	1.5	0	0	60	35	\N
605	MSL733A	ORGANIZATION THEORY                                	Q2	SE	1.5	1.5	0	0	60	71	\N
606	MSL733B	ORGANIZATION THEORY                                	B2	SE	1.5	1.5	0	0	60	41	\N
607	MSL733C	ORGANIZATION THEORY                                	A2	SE	1.5	1.5	0	0	60	31	\N
608	MSL740	QUANTITATIVE METHODS IN MGMT.                      	Q	SE	3	3	0	0	60	39	\N
609	MSL745A	OPERATIONS MANAGEMENT                              	AB	PC	3	3	0	0	60	46	\N
610	MSL745B	OPERATIONS MANAGEMENT                              	E	PC	3	3	0	0	60	31	\N
611	MSL780	MANAGERIAL ECONOMICS                               	R2	PC	1.5	1.5	0	0	60	43	\N
612	MSL802	MGMT. OF INTELLECTUAL PR. RIG.                     	U	PE	3	3	0	0	60	31	\N
613	MSL806	MERGERS & ACQUISITIONS                             	J	PE	3	3	0	0	60	15	\N
614	MSL825	STRATEGIES IN FUNCTIONAL MGMT.                     	Q	PE	3	3	0	0	60	14	\N
615	MSL827	INTERNATIONAL COMPETITIVENESS                      	R	PE	3	3	0	0	60	20	\N
616	MSL849	CURRENT & EM. ISS. IN MA. MGMT                     	R	PE	3	3	0	0	60	26	\N
617	MSL859	Current and Emerging Issues in IT Management 	S	PE	3	3	0	0	60	90	\N
618	MSL863	ADVERTISING AND SALESPROMOTION MANAGEMENT          	U	PE	3	3	0	0	60	111	\N
619	MSL865	SALES MANAGEMENT                                   	T	""	3	3	0	0	60	93	\N
620	MSL870	CORPORATE GOVERNANCE                               	U1	PE	1.5	1.5	0	0	60	10	\N
621	MSL871	BANKING AND FINANCIAL SERVICES                     	R2	PE	1.5	1.5	0	0	60	26	\N
622	MSL873	SECURITY ANALYSIS & PORTFOLIOMANAGEMENT            	AB	PE	3	3	0	0	60	54	\N
623	MSL874	INDIAN FINANCIAL SYSTEM                            	R1	PE	1.5	1.5	0	0	60	31	\N
624	MSL875	INTERNATIONAL FINANCIAL MANAGEMENT                 	S	PE	3	3	0	0	60	14	\N
625	MSL878	ELECTRONIC PAYMENTS                                	T2	PE	1.5	1.5	0	0	60	14	\N
626	MSL879	CURRENT AND EMERGING ISSUES IN FINANCE             	U	PE	3	3	0	0	60	62	\N
627	MSL886	IT CONSULTING AND PRACTICE                         	U	PE	3	3	0	0	60	16	\N
628	MSL894	SOCIAL MEDIA AND BUSINESS PRACTICES                	R	PE	3	3	0	0	60	32	\N
629	MSL896	INTERNATIONAL ECONOMIC POLICY                      	Q	PE	3	3	0	0	60	20	\N
630	MST894	SOCIAL  SECTOR ATTACHMENT                          	P	NC	1	0	0	2	60	67	\N
631	MSV802	SELECTED TOPICS IN FINANCE                         	X	""	1	1	0	0	60	46	\N
632	MSV803	SELECTED TOPICS IN I T MANAGEMENT                  	X	""	1	1	0	0	60	11	\N
633	MSV805	SELECTED TOPICS IN ECONOMICS                       	X	""	1	1	0	0	60	28	\N
634	MTD350	MINI PROJECT                                       	P	""	3	0	0	6	30	12	\N
635	MTD421	B.TECH. PROJECT                                    	Q	""	4	0	0	8	100	43	\N
636	MTD702	PROJECT 2                                          	P	""	6	0	0	12	30	19	\N
637	MTD852	MAJOR PROJECT PARTII                               	Q	""	16	0	0	32	60	1	\N
638	MTD854	MAJOR PROJECT PART II                              	P	""	18	0	0	36	30	20	\N
639	MTL100	CALCULUS                                           	D	""	4	3	1	0	400	474	\N
640	MTL101	LINEAR ALGEBRA & DIFFE. EQUA.                      	C	""	4	3	1	0	400	471	\N
641	MTL102	DIFFERENTIAL EQUATIONS                             	E	""	3	3	0	0	100	160	\N
642	MTL103	OPTIMIZATION METHODS & APPL.                       	D	""	3	3	0	0	140	156	\N
643	MTL106	PROBABILITY & STOCHASTIC PRO.                      	D	""	4	3	1	0	200	226	\N
644	MTL108	INTRODUCTION TO STATISTICS                         	D	""	4	3	1	0	175	166	\N
645	MTL122	REAL AND COMPLEX ANALYSIS                          	F	""	4	3	1	0	100	76	\N
646	MTL145	NUMBER THEORY                                      	AA	""	3	3	0	0	100	100	\N
647	MTL390	STATISTICAL METHODS                                	J	""	4	3	1	0	100	77	\N
648	MTL411	FUNCTIONAL ANALYSIS                                	F	""	3	3	0	0	100	91	\N
649	MTL506	COMPLEX ANALYSIS                                   	B	""	4	3	1	0	60	57	\N
650	MTL507	TOPOLOGY                                           	D	""	4	3	1	0	60	54	\N
651	MTL508	MATHEMATICAL PROGRAMMING                           	AB	""	4	3	1	0	60	58	\N
652	MTL509	NUMERICAL  ANALYSIS                                	AA	""	4	3	1	0	60	51	\N
653	MTL510	MEASURE AND INTEGRATION                            	C	""	4	3	1	0	60	53	\N
654	MTL725	STOCHASTIC PROCESSES & ITS APP                     	H	""	3	3	0	0	60	50	\N
655	MTL730	CRYPTOGRAPHY                                       	A	""	3	3	0	0	150	136	\N
656	MTL732	FINANCIAL MATHEMATICS                              	A	""	3	3	0	0	60	52	\N
657	MTL742	OPERATOR THEORY                                    	AD	""	3	3	0	0	60	36	\N
658	MTL755	ALGEBRAIC GEOMETRY                                 	M	""	3	3	0	0	60	46	\N
659	MTL768	GRAPH THEORY                                       	AA	""	3	3	0	0	60	68	\N
660	MTL782	DATA MINING                                        	B	""	4	3	0	2	60	62	\N
661	MTL792	MODERN METH. IN PAR. DIFF. EQ.                     	AA	""	3	3	0	0	60	14	\N
662	MTP290	COMPUTING LABORATORY                               	Q	""	2	0	0	4	100	67	\N
663	NEN101	PROFE. ETHICS &SOCIAL RESP. 2                      	P	""	0.5	0	0	1	1000	910	\N
664	NLN101	LANGUAGE & WRITING SKILL 2                         	P	""	1	0	0	2	100	916	\N
665	PTL702	POLYMER PROCESSING                                 	B	""	3	3	0	0	60	18	\N
666	PTL706	POLYMER TESTING & PROPERTIES                       	M	""	3	3	0	0	60	18	\N
667	PTL709	POLYMER TECHNOLOGY                                 	D	""	3	3	0	0	60	19	\N
668	PTL712	POLYMER COMPOSITES                                 	E	""	3	3	0	0	60	23	\N
669	PTP720	POLYMER ENGINEERING LAB                            	AA	""	1	0	0	2	60	15	\N
670	PTV700	SPECIAL LECTURES IN POLYMERS:                      	X	""	1	1	0	0	30	17	\N
671	PYD411	PROJECT I                                          	Q	""	4	0	0	8	100	10	\N
672	PYD412	MAJOR PROJECT PART II                              	Q	""	8	0	0	16	100	13	\N
673	PYD414	PROJECT III                                        	Q	""	4	0	0	8	100	1	\N
674	PYD562	PROJECT II                                         	Q	""	6	0	0	12	60	44	\N
675	PYD658	MINI PROJECT                                       	Q	""	3	0	0	6	60	7	\N
676	PYD802	MAJOR PROJECT PART II                              	Q	""	12	0	0	24	60	16	\N
677	PYD852	MAJOR PROJECT PART II                              	Q	""	12	0	0	24	60	17	\N
678	PYL100	ELECTROMAGNETIC WAVES&QUA.MEC.                     	A	""	3	3	0	0	100	485	\N
679	PYL102	PRINCIPLES OF ELECT. MATERIALS                     	H	""	3	3	0	0	150	157	\N
680	PYL111	ELECTRODYNAMICS                                    	A	""	4	3	1	0	100	64	\N
681	PYL112	QUANTUM MECHANICS                                  	E	""	4	3	1	0	100	110	\N
682	PYL114	SOLID STATE PHYSICS                                	D	""	4	3	1	0	100	60	\N
683	PYL202	STATISTICAL PHYSICS                                	F	""	4	3	1	0	100	56	\N
684	PYL204	COMPUTATIONAL PHYSICS                              	J	""	4	3	1	0	100	57	\N
685	PYL302	NUCLEAR SCIENCE & ENGINEERING                      	E	""	3	3	0	0	100	16	\N
686	PYL304	SUPERCONDUCTIVITY & APPLICAT.                      	C	""	3	3	0	0	100	18	\N
687	PYL306	MICROELECTRONIC DEVICES                            	K	""	3	3	0	0	100	28	\N
688	PYL312	SEMICONDUCTOR OPTOELECTRONICS                      	D	""	3	3	0	0	100	25	\N
689	PYL331	APPLIED QUANTUM MECHANICS                          	H	""	3	3	0	0	50	10	\N
690	PYL552	ELECTRODYNAMICS                                    	E	""	4	3	1	0	60	52	\N
691	PYL555	QUANTUM MECHANICS I                                	E	""	4	3	1	0	60	8	\N
692	PYL556	QUANTUM MECHANICS II                               	B	""	3	3	0	0	60	50	\N
693	PYL558	STATISTICAL MECHANICS                              	F	""	4	3	1	0	60	54	\N
694	PYL560	APPLIED OPTICS                                     	H	""	4	3	1	0	60	53	\N
695	PYL563	SOLID STATE PHYSICS                                	D	""	4	3	1	0	60	53	\N
696	PYL651	ADVANCED SOLID STATE PHYSICS                       	C	""	3	3	0	0	35	6	\N
697	PYL659	LASER SPECTROSCOPY                                 	F	""	3	3	0	0	60	21	\N
698	PYL704	SC. & TECHNOLOGY OF THIN FILMS                     	J	""	3	3	0	0	60	43	\N
699	PYL705	NANOSTRUCTURED MATERIALS                           	E	""	3	3	0	0	60	36	\N
700	PYL707	CHARACTERISATION TEC. FOR MAT.                     	D	""	3	3	0	0	60	27	\N
701	PYL725	SURFACE PHYSICS AND ANALYSIS                       	H	""	3	3	0	0	60	30	\N
702	PYL726	SEMICONDUCTOR DEVICE TECHNOLOGY                    	K	""	3	3	0	0	60	16	\N
703	PYL727	ENERGY MATERIALS AND DEVICES                       	M	""	3	3	0	0	60	17	\N
704	PYL742	GEN. RELATIVITY & INTRO. ASTR.                     	M	""	3	3	0	0	75	38	\N
705	PYL743	GROUP THEORY & ITS APPLICATION                     	A	""	3	3	0	0	60	66	\N
706	PYL744	HIGH ENERGY PHYSICS                                	K	""	3	3	0	0	75	31	\N
707	PYL746	NON EQUILIBRIUM STATISTICAL ME                     	L	""	3	3	0	0	40	14	\N
708	PYL748	QUANTUM OPTICS                                     	B	""	3	3	0	0	60	26	\N
709	PYL752	LASER SYSTEMS AND APPLICATIONS                     	J	""	3	3	0	0	60	27	\N
710	PYL756	Fourier Optics and Holography 	L	PC	3	3	0	0	60	31	\N
711	PYL760	BIOMEDICAL OPTICS & BIO PHOTO.                     	H	""	3	3	0	0	60	35	\N
712	PYL762	STATISTICAL OPTICS                                 	A	""	3	3	0	0	60	20	\N
713	PYL770	ULTRA FAST OPTICS & APPLICATI.                     	F	""	3	3	0	0	60	24	\N
714	PYL772	PLASMONIC SENSORS                                  	K	""	3	3	0	0	60	9	\N
715	PYL780	DIFFRACTIVE AND MICRO OPTICS                       	M	""	3	3	0	0	60	17	\N
716	PYL792	OPTICAL ELECTRONICS                                	E	""	3	3	0	0	60	26	\N
717	PYL800	NUM. & COMP. METH. IN RESEARCH                     	B	""	3	3	0	0	65	61	\N
718	PYL879	SELECTED TOPICS IN APPLIED OPT                     	X	""	3	3	0	0	60	1	\N
719	PYL891	FIBER OPTIC COMPONENTS AND DEVICES                 	D	""	3	3	0	0	60	16	\N
720	PYP100	PHYSICS LABORATORY                                 	Q	""	2	0	0	4	100	459	\N
721	PYP212	ENGG. PHYSICS LABORATORY II                        	Q	""	3	0	0	6	100	47	\N
722	PYP222	ENGINEERING PHYSICS LAB.   IV                      	Q	""	4	0	0	8	100	56	\N
723	PYP562	LABORATORY II                                      	Q	""	4	0	0	8	60	51	\N
724	PYP702	SOLID STATE MATERIALS LABORATORY II                	Q	""	3	0	0	6	60	20	\N
725	PYP762	ADVANCED OPTICS LABORATORY                         	Q	""	3	0	0	6	60	17	\N
726	PYP764	ADVANCED OPTICAL WORKSHOP                          	Q	""	3	0	0	6	60	1	\N
727	PYQ303	SEMINAR COURSE   III                               	Q	""	1	0	0	2	100	76	\N
728	PYS300	INDEPENDENT STUDY                                  	X	""	3	0	3	0	100	2	\N
729	RDD750	MINOR PROJECT                                      	Q	OE	3	0	0	6	20	1	\N
730	RDL700	BIOMAS PRODUCTION                                  	J	OE	3	3	0	0	60	49	\N
731	RDL701	RURAL INDUSTRIALISATION POLICES PROGRAMMES & CASE  	E	OE	3	3	0	0	100	99	\N
732	RDL710	RURAL INDIA AND PLANNING FOR DEVELOPMENT           	J	OE	3	3	0	0	50	65	\N
733	RDL722	RURAL ENERGY SYSTEMS                               	F	OE	3	3	0	0	100	102	\N
734	RDL726	HERBAL,MEDICINAL ANDAROMATIC PRODUCTS              	M	OE	3	3	0	0	30	30	\N
735	RDL740	TECHNOLOGY OF UTILIZATION OF WASTELANDS & WEEDS    	AA	OE	3	3	0	0	50	44	\N
736	RDL760	FOOD QUALITY AND SAFETY                            	J	OE	3	3	0	0	50	55	\N
737	RDP750	BIOMASS LABORATORY                                 	Q	OE	3	0	0	6	20	13	\N
738	RDQ301	SEMINAR COURSE   I                                 	X	OE	1	0	0	2	30	32	\N
739	RDQ302	SEMINAR COURSE   II                                	X	OE	1	0	0	2	30	33	\N
740	RDQ303	SEMINAR COURSE   III                               	X	OE	1	0	0	2	30	34	\N
741	RDQ304	SEMINAR COURSE IV                                  	X	OE	1	0	0	2	30	31	\N
742	RDQ305	SEMINAR COURSE V                                   	X	OE	1	0	0	2	30	44	\N
743	SBC796	GRADUATE STUDENT SEMINAR II                        	P	""	0.5	0	0	1	60	13	\N
744	SBD301	MINI PROJECT                                       	Q	""	3	0	0	6	10	3	\N
745	SBD895	MS RESEARCH PROJECT                                	P	""	40	0	0	80	60	5	\N
746	SBL100	INTRO. TO BIOLOGY FOR ENGINEER                     	C	""	4	3	0	2	600	402	\N
747	SBL201	HIGH DIMENSIONAL BIOLOGY                           	F	""	3	3	0	0	60	14	\N
748	SBL701	BIOMETRY                                           	M	""	3	3	0	0	60	10	\N
749	SBL703	ADVANCED CELL BIOLOGY                              	H	""	3	3	0	0	50	14	\N
750	SBL704	HUMAN VIROLOGY                                     	E	""	3	3	0	0	60	12	\N
751	SBL705	BIOLOGY OF PROTEINS                                	B	""	3	3	0	0	60	19	\N
752	SBL714	PLANT BIOTECH. & HUMAN HEALTH                      	F	""	3	3	0	0	60	1	\N
753	SBL720	GENOME AND HEALTHCARE                              	B	""	3	3	0	0	60	5	\N
754	SBP200	INTRODUCTION TO PRACTICAL MODERN BIOLOGY           	Q	""	2	0	0	4	60	7	\N
755	SBS800	INDEPENDENT STUDY                                  	Q	""	3	0	3	0	10	1	\N
756	SBV750	BIOINSPIRATION AND BIOMIMETICS                     	K	""	1	1	0	0	60	21	\N
757	SBV884	ELEMENTS OF NEUROSCIENCE                           	J	""	1	1	0	0	60	8	\N
758	SID880	MINOR PROJECT IN INFORMATION TECHNOLOGY            	P	""	3	0	0	6	30	0	\N
759	SID890	MS RESEARCH PROJECT                                	P	""	40	0	0	80	30	4	\N
760	SIL765	NETWORKS & SYSTEM SECURITY                         	B	""	4	3	0	2	40	33	\N
761	SIV895	SPECIAL MODULE ON INTELLIGENT INFO. PROCESSING     	P	""	1	1	0	0	30	1	\N
762	TTC410	COLLOQUIUM (TT)                                    	P	""	3	0	3	0	30	2	\N
763	TTT410	PRACTICAL TRAINING                                 	P	""	0	0	0	0	10	2	\N
764	TXD357	MINOR DESIGN PROJECT   VII                         	P	""	2	0	0	4	120	1	\N
765	TXD358	MINOR DESIGN PROJECT VIII                          	P	""	2	0	0	4	120	1	\N
766	TXD401	MAJOR PROJECT PART I                               	P	DC	4	0	0	8	120	14	\N
767	TXD402	MAJOR PROJECT PART II                              	P	""	8	0	0	16	120	19	\N
768	TXD803	MAJOR PROJECT PART II                              	P	PC	12	0	0	24	30	22	\N
769	TXD804	MAJOR PROJECT PART II                              	P	PC	12	0	0	24	30	15	\N
770	TXD806	MAJOR PROJECT PART II (TCP) 	P	PC	12	0	0	24	30	10	\N
771	TXL211	STRUCTURE & PHYSICAL PROPERTIE                     	D	DC	3	3	0	0	120	125	\N
772	TXL221	YARN MANUFACTURE I                                 	E	DC	3	3	0	0	120	109	\N
773	TXL231	FABRIC MANUFACTURE I                               	B	DC	3	3	0	0	120	119	\N
774	TXL241	TECH. OF TEXT. PREPARATION & F                     	F	DC	3	3	0	0	120	129	\N
775	TXL361	EVALUATION OF TEXTILE MATERIAL                     	D	DC	3	3	0	0	120	92	\N
776	TXL371	THEORY OF TEXTILE STRUCTURES                       	C	DC	4	3	1	0	120	123	\N
777	TXL372	SPECIALITY YARNS AND FABRICS                       	J	DC	2	2	0	0	120	97	\N
778	TXL714	ADVANCED MATERIALS CHARACTERIZATION TECHNIQUES     	P	PC	1	1	0	0	75	40	\N
779	TXL715	TECHNOLOGY OF SOLUTION SPUN FIBRES                 	B	PC	3	3	0	0	75	17	\N
780	TXL725	MECHANICS OF SPINNING MACHINES                     	A	PC	3	3	0	0	40	18	\N
781	TXL740	SC. & APP. OF NANOTEC. IN TEX.                     	E	PE	3	3	0	0	65	77	\N
782	TXL748	ADVANCES IN FINISHING OF TEXTILES                  	F	PC	3	3	0	0	40	30	\N
783	TXL754	SUSTAINABLE CHEMICAL PROCESSING OF TEXTILES        	B	PC	2	2	0	0	40	11	\N
784	TXL756	TEXTILE AUXILIARIES                                	J	PE	3	3	0	0	65	13	\N
785	TXL766	DE. & MANUF. OF TEXT. STR. CO.                     	B	PE	3	3	0	0	65	69	\N
786	TXL771	ELECTRONICS AND CONTROLS FOR TEXTILEINDUSTRY       	J	PE	4	3	0	2	65	54	\N
787	TXL775	TECHNICAL TEXTILES                                 	D	""	3	3	0	0	65	57	\N
788	TXL777	PRODUCT DESIGN AND DEVELOPMENT                     	H	PE	3	3	0	0	65	27	\N
789	TXL782	PRODUCTION & OPERATIONS MGMT                       	F	PE	3	3	0	0	65	53	\N
790	TXL783	DESIGN OF EXPER. & STAT. TECH.                     	E	""	3	3	0	0	65	71	\N
791	TXP212	MANUFACTURED FIBRE TECHNO. LAB                     	C	DC	1	0	0	2	120	97	\N
792	TXP221	YARN MANUFACTURE LABORATORYI                       	E	DC	1	0	0	2	120	108	\N
793	TXP231	FABRIC MANUFACTURE LAB.   I                        	B	DC	1	0	0	2	120	112	\N
794	TXP241	TECH. OF TEX. PRE. & FIN. LAB.                     	F	DC	1.5	0	0	3	120	117	\N
795	TXP361	EVALUATION OF TEXTILES LAB                         	D	DC	1	0	0	2	120	92	\N
796	TXP716	Fibre Production and Post Spinning Operation Laboratory 	F	PE	2	0	0	4	65	17	\N
797	TXP725	MECHANICS OF SPINNING MACHINES LAB                 	P	PC	1	0	0	2	40	18	\N
798	TXP748	TEXTILE PREPARATION AND FINISHING LAB              	P	PC	1	0	0	2	25	17	\N
799	TXP761	EVALUATION OF TEXTILE MATERIALS                    	C	PC	2	0	0	4	75	19	\N
800	TXQ302	SEMINAR COURSE 2                                   	P	""	1	0	0	2	120	128	\N
801	VED750	MINOR PROJECT                                      	P	""	3	0	0	6	60	0	\N
802	VEL700	HUMAN VALUES AND TECHNOLOGY                        	M	""	3	2	1	0	60	54	\N
\.


--
-- Data for Name: curr_prof; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.curr_prof (profalias, profname) FROM stdin;
shahani	D T Shahani
nareshb	Naresh Bhatnagar
mukesh	Mukesh Chander
sns	S N Singh
svmodak	Subodh Vasant Modak
pankajs	Pankaj Srivastava
bjayaram	B Jayaram
ashoknb	A N Bhaskarwar
jpkhatait	Jitendra Prasad Khatait
adewan	Anupam Dewan
pritha	Pritha Chandra
jayadeva	Jayadeva
kcjha	Kshitij Chandra Jha
akjain	A K Jain
sagnik	Sagnik Dey
shuchi	Shuchi Sinha
smanna	Sujit Manna
madan	Alok Madan
rkk	Rama Krishna K
shravankumar	N Shravan Kumar
gufranskhan	Gufran Sayeed Khan
jayati	Jayati Sarkar
psenthil	P Senthilkumaran
ankush	Ankush Agrawal
ramesh	N G Ramesh
sks	Sujeet Kumar Sinha
sdjoshi	S D Joshi
sneetu	Neetu Singh
achugh	Archana Chugh
angelie	Angelie Multani
deepti	Deepti Gupta
mcramteke	Manojkumar Charandas Ramteke
dtanmay	Tanmay Dutta
tyagisk	S K Tyagi
shahu	Jagdish Telangrao Shahu
agupta	Amit Gupta
bmitra	Bhaskar Mitra
prabhubabu	Prabhu Babu
swadesd	Swades Kumar De
sanil	Sanil V 
pkjain	P K Jain
ssantapuri	Sushma Santapuri
joby	Joby Joseph
avaidya	Ashwini J Vaidya
gsingh	Gaurav Singh
muduli	Pranaba Kishor Muduli
joshid	Deepak Joshi
skohli	Sangeeta Kohli
supravat	Supravat Karak
ruma	Mrs R Uma
suhail	Suhail Ahmed
mpgupta	Manmohan Prasad Gupta
dkdubey	Devendra Kumar Dubey
skhanna	Stuti Khanna
kedark	Kedar Bhalchandra Khare
skundu	Subiman Kundu
wazed	Md S Wazed Ali
kushal	Kushal Sen
jbijwe	Jayashree Bijwe
msingh	Madhusudan Singh
crf182109	Ashish Tiwari
njain	Nidhi Jain
seshan	Seshan Srirangarajan
vashisthp	Priya Vashisth
deepakpatil	Deepak Umakant Patil
ragesh	Ragesh Jaiswal
spathak	Sandeep Kumar Pathak
dkbp	D K Bandyopadhyay
akt	A K Tyagi
sumit	Sumit Kumar Chattopadhyay
niladri	Niladri Chatterjee
umapaul	J Uma Maheswari
ritumoni	Ritumoni Sarma
geetamt	Geetam Tewari
sumeet	Sumeet Agarwal
subashish	Subashish Dutta
slgholap	Gholap Shivajirao Lahu
rchandra	Ram Chandra
shaunak	Shaunak Sen
bspanda	Bhawani Sankar Panda
csdey	Chinmoy Sankar Dey
saha	Subir Kumar Saha
ganuthula	Venkat Ram Reddy
elias	Anil Jacob Elias
upasna	Upasna Sharma
lnebhani	Leena Nebhani
suniljha	Sunil Jha
jphirani	Jyoti Phirani
debasis	Debasis Mondal
chetan	Chetan Arora
mangala	Mangala Joshi
harishc	Harish Chaudhry
samar	Samar Husain
mrshenoy	M R Shenoy
dbhatia	Divesh Bhatia
samareshdas	Samaresh Das
ravisoni	R K Soni
aravindan	Sivanandam Aravindan
haider	Mohammad Ali Haider
rbnair	Rukmini Bhaya Nair
naveen	Naveen Garg
ritu	Ritu Kulshrestha
mathilis	Maithili Sharan
mbanerjee	Manidipa Banerjee
saptarshi	Saptarshi Mukherjee
paresh	Paresh Pravinchandra Chokshi
vkjain	V K Jain
jharshan	Harshan Jagadeesh
chakma	Sumedha Chakma
mvchary	Mummadi Veerachary
anshul	Anshul Kumar
ratan	Ratan Mohan
vignes	P Vigneswara Ilavarasan
joyee	Joyee Ghosh
amartya	Amartya Sengupta
richa	Richa Kumar
arghya	Arghya Samanta
fibrahim	Farhana Ibrahim
pvmrao	P V Madhusudhan Rao
supratic	Supratic Gupta
krk	K Ravi Kumar
narain	Rahul Narain
santanu1	Santanu Ghosh
cshakher	Chandra Shakher
kaushiksaha	Kaushik Saha
anushree	Anushree Malik
saran	Huzur Saran
jaideo	Jai Deo Singh
anupam	Anupam Shukla
ntandon	Naresh Tandon
gupta	Anand Dev Gupta
sreedevi	Sreedevi Upadhyayula
sudip	Sudip Kumar Pattanayek
sujeetc	Sujeet Chaudhary
knjha	Kumar Neeraj Jha
dilipganguly	Dilip Ganguly
akumar	Arun Kumar
prem	B Premachandran
ppingole	Pravin Popinand Ingole
goelg	Gaurav Goel
nthayyil	Naveen Thayyil Kamaluddin
mmehra	Mani Mehra
vkvijay	Virendra Kumar Vijay
sandeepjha	Sandeep Kumar Jha
samrat	Samrat Mukhopadhyay
brmehta	Bodh Raj
sgupta	S K Gupta
shalinig	Shalini Gupta
sundar	D Sundar
anupsm	Anup Singh
shilpi	Shilpi Sharma
san81	Sandeep Sukumaran
skjain	Sudhir Kumar Jain
jnsheikh	Javed Nabibaksha Sheikh
kgsharma	K G Sharma
bkpanigrahi	Bijaya Ketan Panigrahi
rasamy	R Alagirusamy
bishalp.cstaff	Bishal Pujari
sprsingh	Surya Prakash Singh
apurba	Apurba Das
dineshk	Dinesh Kalyanasundaram
saifkm	Saif Khan Mohammed
anilverma	Anil Verma
chahar	Bhagu Ram Chahar
jgomes	James Gomes
araman	R Ayothiraman
dhanya	Dhanya C T 
ssatya	Santosh
dsmehta	Dalip Singh Mehta
ssawhney	Simona Sawhney
murali	Murali Raman Cholemari
kseth	Kiran Seth
akrishna	Krishna Mirle Achutarao
adasgupta	Aparajita Dasgupta
vvksrini	V V K Srinivas Kumar
dkumar	Deepak Kumar
pradyum	S Pradyumna
behera	B K Behera
hmgupta	H M Gupta
arunkm	Arun Kumar
sushil	Sushil
pvrao	P Venkateswara Rao
sarbeswar	Sarbeswar Sahoo
pmpandey	Pulak Mohan Pandey
raya	Anjan Ray
kaushal	Deo Raj Kaushal
cet172046	Hafizullah
dibakar	Dibakar Rakshit
saswata	Saswata Bhattacharya
ajeetk	Ajeet Kumar
jayanta	Jayanta Bhattacharyya
janas	S Janardhanan
amlendu	Amlendu Kumar Dubey
lalank	Lalan Kumar
adixit	Abhisek Dixit
sanjiva	Sanjiva Prasad
scsr	S Chandra Sekhara Rao
akdarpe	Ashish Kamalakar Darpe
matsagar	Vasant A Matsagar
aryav	Arya V
sbansal	Sorav Bansal
ashokks	A K Srivastava
scgupta	Suresh Chand Gupta
sbhalla	Suresh Bhalla
gurmail	Gurmail S Benipal
bgupta	Bhuvanesh Gupta
kdashora	Kavya Dashora
nsenroy	Nilanjan Senroy
amittal	Aditya Mittal
sanjaydhir	Sanjay Dhir
arathore	Anurag Singh Rathore
bkundu	Bishwajit Kundu
vravi	V Ravishankar
aloka	Aloka Sinha
pmishra	Prashant Mishra
mukeshk	Mukesh Khare
ssnag	Soumya Shubhra Nag
sbpaul	Sourabh Bikas Paul
shashankrv	Rv Shashank Shankar
jmadaan	Dr Jitendra Madaan
rchat	R Chattopadhyay
parags	Parag Singla
gbreddy	G B Reddy
mausam	Mausam
mnabi	Mashuq-Un-Nabi
milindw	Milind Wakankar
panda	Preeti Ranjan Panda
mbala	M Balakrishnan
achawla	Anoop Chawla
ashokpatel	Ashok Kumar Patel
abhyankar	Abhijit Ramchandra Abhyankar
akshukla	A K Shukla
kodamana	Hariprasad Kodamana
ravimr	M R Ravi
hcgupta	H C Gupta
shvetasingh	Shveta Singh
varsha	Varsha Banerjee
rmala	Ratanamala Chatterjee
rahman	S M K Rahman
manojm	Manoj M
saroj	Saroj Kaushik
abhishek.dixit	Abhishek Dixit
adhawan	Anuj Dhawan
ravips	Ravi P Singh
mahajan	Puneet Mahajan
vsingh	Varsha Singh
rrkalaga	Ramachandra Rao Kalaga
brejesh	Brejesh Lall
sreenadh	Konijeti Sreenadh
rbahl	Rajendra Bahl
kmanna	Kuntal Manna
ananjan	Ananjan Basu
sapra	Sameer Sapra
varunr	Varun Ramamohan
anarang	Atul Narang
arjunghosh	Arjun Ghosh
akswamy	Aravind Krishna Swamy
ajitk	Ajit Kumar
hkmalik	Hitendra Kumar Malik
smitak	Smita Kashiramka
arawal	Amit Rawal
sunath	Sunil Nath
vs225	Vikram Singh
kkpant	Kamal Kishore Pant
manjeet	Manjeet Jassal
mamidala	M Jagadesh Kumar
kumarsunil	Sunil Kumar
sudipto	Sudipto Mukherjee
majee	Ananta Kumar Majee
gopal	G P Agarwal
ssyadav	Surendra Singh Yadav
bipin	Bipin Kumar
apmehra	Aparna Mehra
shiv	Shiv Prakash Patel
dpsahu	Debaprasad Sahu
ashishmisra	Ashish Misra
snn	S N Naik
rkmahesh	Ramkrishan Maheshwari
jksahu	Jatindra Kumar Sahu
vsaxena	Vikrant Saxena
sm1	Sumitava Mukherjee
ankurgupta	Ankur Gupta
aknema	Arvind Kumar Nema
ag	Anurag Gupta
phari	Hariprasad P 
bray	Dr (Ms ) Bahni Ray
sanjeevj	Sanjeev Jain
bagchi	Amitabha Bagchi
tarak	T C Kandpal
gosain	A K Gosain
skkhare	Sunil Kumar Khare
amitjain	Amit Kumar Jain
tkchaudhuri	Tapan Kumar Chaudhuri
bkanseri	Bhaskar Kanseri
svs	Subodh Vishnu Sharma
ramanath	Maya Ramanath
smathur	Shashi Mathur
kamana	Kamana Porwal
rsr	R S Rengasamy
ce1140348	Mustyala Varun
prbijwe	P R Bijwe
bmanna	Bappaditya Manna
adrao	A D Rao
sureshn	Suresh Neelakantan
biplab	Biplab Basak
arunku	Arun Kumar
prathoshap	Prathosh A P 
nkhare	Neeraj Khare
aksaroha	Anil Kumar Saroha
sbhasin	Shubhendu Bhasin
debanjan	Debanjan Bhowmik
hkashyap	Hemant Kumar Kashyap
kgupta	Kshitij Gupta
bpuri	Bharati Puri
jayan	Jayan Jose Thomas
pkg	Pradeep Kumar Gupta
spandey	Sunil Pandey
vikassingh	Vikas Vikram Singh
harpal	Harpal Singh
skm	Saroj Kanta Mishra
spramanick	Sumit Kumar Pramanick
preeti	Preeti Srivastava
zia	Shaikh Ziauddin Ahammad
sumerid	Sumer Singh
kkant	Krishna Kant Agrawal
bsbutola	Bhupendra Singh Butola
maggarwal	Monika Aggarwal
hmishra	Harsh Vardhan Mishra
yaj	Yashpal Ashokrao Jogdand
ravi	R K Varshney
nomesh	Nomesh Bhojkumar Bolia
sarojm	Saroj Mishra
maratherahul	Rahul Suresh Marathe
akghosh	A K Ghosh
mahim	Mahim Sagar
ssen	Sandeep Sen
arpankar	Arpan Kumar Kar
srikanta	Srikanta Bedathur Jagannath
sawan	Sawan Suman Sinha
rkhosa	Rakesh Khosa
shouri	Shouribrata Chatterjee
dharmar	S Dharmaraja
minati	Minati De
prabal	Prabal Talukdar
alappat	Babu J Alappat
akeshari	A K Keshari
ngosvami	Nitya Nand Gosvami
shankar.prakriya	Shankar Prakriya
pkalra	Prem Kumar Kalra
kanika	Kanika Tandon Bhal
manav	Manav Bhatnagar
majumdar	Abhijit Mujumdar
anandarup	Anandarup Das
drsahoo	Dipti Ranjan Sahoo
ashwini	Ashwini K Agrawal
datla	Naresh Varma Datla
viswa	Viswanathan Puthan Veedu
satishdubey	Satish Kumar Dubey
bishnoi	Shashank Bishnoi
rnarula	Rohit Narula
rkkunchala	Ravi Kumar Kunchala
mpmathew	Mp Mathew
srinivasanv	Srinivasan Venkataraman
rahulgarg	Rahul Garg
bnj	B N Jain
nalinp	Nalin Pant
subra	K A Subramanian
vivekk	Vivek Kumar
bhabani	Bhabani Kumar Satapathy
drsbr	Somnath Baidya Roy
rajiv	Rajiv K Srivastava
psanyal	Paroma Sanyal
gazala	Gazala Habib
ghoshs	Sudarsan Ghosh
roys	Shantanu Roy
dravi	Digavalli Ravi Kumar
krishnan	Anoopkrishnan Naduvath Mana
jkdutt	Jayanta Kumar Dutt
vimlesh	Vimlesh Pant
nezam	Nezamuddin
fatima	Shahab Fatima
bhuvan	G Bhuvaneswari
aurora	Vibha Arora
bahga	Supreet Singh Bahga
sisn	S Nagendran
hegde	Sriram Hegde
munawar	Shaik Abdul Munawar
priyadarshi	Amit Priyadarshi
mdatta	Manoj Datta
prsingh	Pushpapraj Singh
ssaha	Sampa Saha
subhra.datta	Subhra Datta
pintu	Pintu Das
elangovan	Ravi Krishnan Elangovan
bppatel	Badri Prasad Patel
tiwariv	Vikrant Tiwari
tobiastoll	Folke Tobias Florus Toll
debabrata	Debabrata Dasgupta
arjunsharma	Arjun Sharma
shankar	Ravi Shankar
tanusree	Tanusree Chakraborty
singhk	Kamlesh Singh
sumantra	Sumantra Dutta Roy
srsarangi	Smruti Ranjan Sarangi
harshakota	Sri Harsha Kota
psingh	Purnima Singh
rksharma	Rajendra Kumar Sharma
rams	Ramesh Narayanan
rajkh	Rajesh Khanna
singhsp	Satinder Paul Singh
pha172189	Shantanu Sharan Agarwal
amitk	Amit Kumar
dipayan	Dipayan Das
subrat	Subrat Kar
maloy	Maloy Kumar Singha
kciyer	K C Iyer
suban	Subhashis Banerjee
sree	T R Sreekrishnan
ink	Indra Narayan Kar
siva	Sivananthan Sampath
seemash	Seema Sharma
tphyspg	Pradipta Ghosh
rkaur	Ravinder Kaur
vperumal	Vivekanandan Perumal
amita	Amita Das
jyoti	Jyoti Kumar
jbseo	Jun Bae Seo
pmvs	P M V Subbarao
rajesh	Rajesh Prasad
vivekv	Vivek Venkataraman
pramitc	Pramit Kumar Chowdhury
tsb	T S Bhatti
rsdhaka	Rajendra Singh Dhaka
rkmallik	Ranjan Kumar Mallik
kmayank	Mayank Kumar
riju	Rijurekha Sen
agnihotri	Aditya Narain Agnihotri
nkgarg	N K Garg
sdeep	Shashank Deep
vvbuwa	Vivek Vitthal Buwa
asagar	Ambuj D Sagar
mahuya	Mahuya Bandyopadhyay
raoks	K S Rao
vchalama	Vamsi Krishna Chalamalla
msarkar	Mukul Sarkar
sroy	Sitikantha Roy
bsingh	Bhim Singh
alvyas	A L Vyas
ishtiaque	S M Ishtiaque
sukumar	Sukumar Mishra
ssahany	Sandeep Sahany
ramana	Venkata Ramana Gunturi
\.


--
-- Data for Name: curr_prof_course; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.curr_prof_course (profalias, courseid) FROM stdin;
tiwariv	1
arghya	2
arghya	3
arghya	4
arghya	5
ajeetk	6
shashankrv	7
vchalama	8
hegde	9
gsingh	10
mpmathew	11
shashankrv	12
bppatel	13
ssantapuri	14
mahajan	15
sns	16
maloy	17
rajesh	18
ag	19
ajeetk	20
pradyum	21
adewan	22
sawan	23
arjunsharma	24
sureshn	25
ngosvami	26
murali	27
sroy	28
suhail	29
pradyum	30
ssahany	31
sagnik	32
vimlesh	33
skm	34
mathilis	35
akrishna	36
adrao	37
ssahany	38
rkkunchala	39
dilipganguly	40
drsbr	41
san81	42
elangovan	43
elangovan	44
ashishmisra	45
ashishmisra	46
ashishmisra	47
ashishmisra	48
ritu	49
shilpi	50
zia	51
sunath	52
elangovan	53
sundar	54
ashishmisra	55
gopal	56
anarang	57
ashokks	58
sree	59
preeti	60
sarojm	61
pmishra	62
ritu	63
elangovan	64
shilpi	65
sarojm	66
ritu	67
jayanta	68
anupsm	69
anupsm	70
joshid	71
sandeepjha	72
sandeepjha	73
dineshk	74
harpal	75
sneetu	76
jayanta	77
jharshan	78
shalinig	79
shalinig	80
shalinig	81
shalinig	82
shalinig	83
jphirani	84
jphirani	85
jphirani	86
jphirani	87
jphirani	88
shalinig	89
shalinig	90
shalinig	91
shalinig	92
shalinig	93
shalinig	94
goelg	95
dbhatia	96
jphirani	97
mcramteke	98
arathore	99
anilverma	100
munawar	101
roys	102
sreedevi	103
aksaroha	104
anupam	105
kkpant	106
vvbuwa	107
haider	108
ratan	109
ashoknb	110
sudip	111
jayati	112
vs225	113
paresh	114
shalinig	115
munawar	116
rajkh	117
kodamana	118
sgupta	119
vs225	120
haider	121
ashoknb	122
ratan	123
kcjha	124
sapra	125
njain	126
slgholap	127
bjayaram	128
ppingole	129
ramesh	130
dkbp	131
sisn	132
dtanmay	133
sdeep	134
nalinp	135
shankar	136
kmanna	137
jaideo	138
njain	139
elias	140
skkhare	141
ravips	142
hkashyap	143
pramitc	144
ramesh	145
dtanmay	146
jaideo	147
srikanta	148
ragesh	149
ragesh	150
srikanta	151
srsarangi	152
srsarangi	153
srikanta	154
suban	155
amitk	156
anshul	157
sanjiva	158
srsarangi	159
ssen	160
ramanath	161
svs	162
ramanath	163
srsarangi	164
saran	165
narain	166
sbansal	167
scgupta	168
naveen	169
mausam	170
parags	171
pkalra	172
rahulgarg	173
panda	174
ragesh	175
chetan	176
ragesh	177
srsarangi	178
riju	179
mbala	180
riju	181
saroj	182
bagchi	183
chetan	184
saran	185
srikanta	186
srikanta	187
parags	188
rahulgarg	189
bagchi	190
saroj	191
saran	192
srikanta	193
ankurgupta	194
ankurgupta	195
ankurgupta	196
ankurgupta	197
arunkm	198
prabhubabu	199
rbahl	200
crf182109	201
samareshdas	202
ananjan	203
prsingh	204
arunkm	205
ragesh	206
srsarangi	207
knjha	208
akswamy	209
akswamy	210
araman	211
tanusree	212
gazala	213
gazala	214
supratic	215
supratic	216
supratic	217
knjha	218
knjha	219
umapaul	220
knjha	221
umapaul	222
araman	223
tanusree	224
tanusree	225
chakma	226
nezam	227
kaushal	228
harshakota	229
arunku	230
ramana	231
krishnan	232
umapaul	233
rrkalaga	234
smathur	235
harshakota	236
supratic	237
chakma	238
chahar	239
ramana	240
araman	241
madan	242
chakma	243
araman	244
mdatta	245
bmanna	246
shahu	247
kgsharma	248
kgsharma	249
tanusree	250
raoks	251
alappat	252
aryav	253
aknema	254
arunku	255
mukeshk	256
kaushal	257
nkgarg	258
akswamy	259
manojm	260
gurmail	261
drsahoo	262
matsagar	263
knjha	264
kciyer	265
akjain	266
cet172046	267
tanusree	268
akeshari	269
rkhosa	270
gosain	271
manojm	272
akswamy	273
geetamt	274
rrkalaga	275
nezam	276
sbhalla	277
gurmail	278
sbhalla	279
drsahoo	280
bishnoi	281
umapaul	282
ce1140348	283
araman	284
krishnan	285
akswamy	286
kaushal	287
supratic	288
nkgarg	289
dhanya	290
akjain	291
bishnoi	292
bmanna	293
raoks	294
alappat	295
raoks	296
srinivasanv	297
srinivasanv	298
satishdubey	299
jyoti	300
shahani	301
shahani	302
cshakher	303
satishdubey	304
jyoti	305
alvyas	306
gufranskhan	307
pvmrao	308
srinivasanv	309
sumerid	310
sumerid	311
jyoti	312
gufranskhan	313
bishalp.cstaff	314
lalank	315
nsenroy	316
sbhasin	317
bmitra	318
bmitra	319
bmitra	320
bmitra	321
bmitra	322
bmitra	323
bmitra	324
bmitra	325
bmitra	326
bmitra	327
bmitra	328
bmitra	329
sumeet	330
deepakpatil	331
deepakpatil	332
lalank	333
lalank	334
lalank	335
msingh	336
msingh	337
amitjain	338
amitjain	339
nsenroy	340
nsenroy	341
sumeet	342
sumeet	343
abhyankar	344
mvchary	345
adixit	346
shankar.prakriya	347
debanjan	348
deepakpatil	349
msingh	350
shaunak	351
nsenroy	352
lalank	353
bhuvan	354
rahman	355
bkpanigrahi	356
swadesd	357
jayadeva	358
rkmallik	359
sumeet	360
mnabi	361
ink	362
maggarwal	363
vivekv	364
sdjoshi	365
seshan	366
abhishek.dixit	367
swadesd	368
adhawan	369
mamidala	370
msarkar	371
bmitra	372
amitjain	373
rkmahesh	374
ssnag	375
anandarup	376
prbijwe	377
sukumar	378
sumantra	379
sumantra	380
jayadeva	381
sbhasin	382
janas	383
subashish	384
vkjain	385
manav	386
saifkm	387
jbseo	388
brejesh	389
jharshan	390
shouri	391
spramanick	392
bsingh	393
abhyankar	394
sumeet	395
prathoshap	396
hmgupta	397
anandarup	398
bhuvan	399
rahman	400
brejesh	401
subrat	402
seshan	403
shouri	404
janas	405
jayadeva	406
bsingh	407
mvchary	408
sukumar	409
janas	410
shouri	411
shouri	412
subrat	413
sumantra	414
sumantra	415
santanu1	416
ruma	417
supravat	418
krk	419
tyagisk	420
dpsahu	421
subra	422
dibakar	423
tsb	424
rams	425
dpsahu	426
tarak	427
spathak	428
sumit	429
tyagisk	430
ruma	431
krk	432
kaushiksaha	433
spathak	434
sumit	435
rams	436
tyagisk	437
ruma	438
krk	439
subra	440
kaushiksaha	441
sarbeswar	442
yaj	443
upasna	444
asagar	445
debasis	446
sbpaul	447
arjunghosh	448
sanil	449
yaj	450
richa	451
milindw	452
milindw	453
pritha	454
ssawhney	455
milindw	456
jayan	457
samar	458
upasna	459
jayan	460
ankush	461
debasis	462
skhanna	463
rbnair	464
samar	465
vsingh	466
singhk	467
sarbeswar	468
milindw	469
upasna	470
rkaur	471
angelie	472
sbpaul	473
jayan	474
saptarshi	475
ssawhney	476
bpuri	477
sanil	478
psingh	479
sm1	480
nthayyil	481
asagar	482
fibrahim	483
aurora	484
mahuya	485
richa	486
sm1	487
avaidya	488
psanyal	489
vsingh	490
rbnair	491
sm1	492
sarbeswar	493
aurora	494
avaidya	495
asagar	496
samar	497
ntandon	498
fatima	499
dkumar	500
jbijwe	501
dkumar	502
mrshenoy	503
vivekv	504
bhabani	505
saha	506
rams	507
rams	508
brejesh	509
jharshan	510
jayadeva	511
jayadeva	512
jayadeva	513
siva	514
pmpandey	515
akdarpe	516
akdarpe	517
subhra.datta	518
sks	519
varunr	520
suniljha	521
jpkhatait	522
aravindan	523
dravi	524
nareshb	525
ghoshs	526
ravimr	527
jkdutt	528
svmodak	529
pmvs	530
dkdubey	531
singhsp	532
aravindan	533
kmayank	534
debabrata	535
varunr	536
sanjeevj	537
achawla	538
agupta	539
skohli	540
sudipto	541
datla	542
akdarpe	543
achawla	544
saha	545
singhsp	546
kgupta	547
rkk	548
jpkhatait	549
nomesh	550
vashisthp	551
nomesh	552
gupta	553
spandey	554
pmpandey	555
pvmrao	556
pvrao	557
subhra.datta	558
bray	559
kkant	560
raya	561
prem	562
prabal	563
pmvs	564
bahga	565
kseth	566
sks	567
suniljha	568
varunr	569
skohli	570
ghoshs	571
spandey	572
saha	573
prem	574
aravindan	575
svmodak	576
nareshb	577
akdarpe	578
akdarpe	579
shvetasingh	580
shvetasingh	581
shvetasingh	582
shvetasingh	583
ganuthula	584
mahim	585
sushil	586
kanika	587
kanika	588
kanika	589
mpgupta	590
shvetasingh	591
pkjain	592
sanjaydhir	593
sanjaydhir	594
vignes	595
arpankar	596
mpgupta	597
seemash	598
seemash	599
amlendu	600
mahim	601
shuchi	602
shuchi	603
shuchi	604
shuchi	605
ganuthula	606
ganuthula	607
sprsingh	608
jmadaan	609
jmadaan	610
amlendu	611
skjain	612
smitak	613
sushil	614
hmishra	615
shankar	616
mpgupta	617
harishc	618
harishc	619
shvetasingh	620
smitak	621
ssyadav	622
smitak	623
ssyadav	624
arpankar	625
smitak	626
arpankar	627
vignes	628
amlendu	629
shuchi	630
shvetasingh	631
vignes	632
seemash	633
viswa	634
vikassingh	635
sreenadh	636
siva	637
siva	638
shravankumar	639
scsr	640
vvksrini	641
vikassingh	642
dharmar	643
apmehra	644
adasgupta	645
shiv	646
niladri	647
siva	648
ritumoni	649
biplab	650
minati	651
kamana	652
skundu	653
majee	654
rksharma	655
mmehra	656
priyadarshi	657
ritumoni	658
bspanda	659
bspanda	660
sreenadh	661
kamana	662
bishalp.cstaff	663
arjunghosh	664
akghosh	665
bhabani	666
ssaha	667
lnebhani	668
bhabani	669
bhabani	670
rsdhaka	671
rsdhaka	672
rsdhaka	673
akshukla	674
pintu	675
mrshenoy	676
mrshenoy	677
amartya	678
pankajs	679
vsaxena	680
joyee	681
muduli	682
rnarula	683
saswata	684
hkmalik	685
smanna	686
mukesh	687
mrshenoy	688
tphyspg	689
amita	690
joyee	691
ajitk	692
varsha	693
pkg	694
sujeetc	695
pintu	696
akshukla	697
akt	698
brmehta	699
rmala	700
rsdhaka	701
gbreddy	702
santanu1	703
vravi	704
agnihotri	705
tobiastoll	706
maratherahul	707
bkanseri	708
aloka	709
psenthil	710
dsmehta	711
kedark	712
kumarsunil	713
pha172189	714
gufranskhan	715
ravi	716
hcgupta	717
joby	718
akumar	719
nkhare	720
kumarsunil	721
ravisoni	722
psenthil	723
pintu	724
joby	725
joby	726
joby	727
santanu1	728
phari	729
phari	730
kdashora	731
vivekk	732
vkvijay	733
snn	734
anushree	735
ssatya	736
phari	737
jksahu	738
snn	739
vivekk	740
rchandra	741
kdashora	742
csdey	743
achugh	744
achugh	745
mbanerjee	746
ashokpatel	747
amittal	748
bkundu	749
vperumal	750
tkchaudhuri	751
achugh	752
ashokpatel	753
amittal	754
achugh	755
achugh	756
jgomes	757
panda	758
panda	759
bnj	760
pkalra	761
majumdar	762
ishtiaque	763
rchat	764
rchat	765
jnsheikh	766
jnsheikh	767
majumdar	768
rajiv	769
bsbutola	770
rajiv	771
dipayan	772
majumdar	773
kushal	774
apurba	775
ishtiaque	776
behera	777
ashwini	778
manjeet	779
rsr	780
mangala	781
deepti	782
samrat	783
bsbutola	784
bipin	785
ankurgupta	786
rasamy	787
rchat	788
ishtiaque	789
arawal	790
bgupta	791
rchat	792
majumdar	793
wazed	794
apurba	795
mangala	796
rsr	797
jnsheikh	798
rasamy	799
kushal	800
ravimr	801
ravimr	802
\.


--
-- Data for Name: curr_stu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.curr_stu (entrynum, studentname) FROM stdin;
ama172317	Ruchitkumar Ishwarlal Patel
ama172318	Sujay Kumar
ama172319	Harshit Mourya
ama172320	Amarjeet Paswan
ama172321	Gaurav Kumar
ama172322	Anup Kumar Sharma
ama172324	Rajeev Kumar
ama172325	Srijan Singhal
ama172326	Mir Numan Ali
ama172327	Pandurang Shrirang Galande
ama172329	Vinay Kumar Gupta
ama172331	Sandeep
ama172332	Arjun Singh
ama172333	Varun
ama172335	Durgesh Kumar Meena
ama172336	Shekhar Sharma
ama172337	Kumud Burman
ama172338	Avinash Kumar Chaudhary
ama172339	Bhanu Prakash Agrawal
ama172636	Abhishek Sharma
ama172638	Anjali Dubey
ama172641	Krishnendu Chakraborty
ama172645	Ashish Singh
ama172647	Raghavendra Pratap Yadav
ama172648	Deepak Raj
ama172650	Sabeerali Koonari Thoombath
ama172653	Makwana Hitendra Raghubhai
ama172654	Ajay Dev Singh
ama172658	Santosh Alaghari
ama172659	K C Vyshnave
ama172661	Avhinay Lohagan
ama172771	Krishan Vallabh Sharma
ama172775	Nikhil Singhal
ama172779	Abhijit Kumar
ama172780	Kuldeep
ama182036	Siva Heramb Peddada
ama182730	Aravind N
ama182732	Apar Katta
ama182734	Shobhit Jain
ama182735	Bharat Choudhary
ama182736	Arpit Singhvi
ama182737	Digbijoy Mukherjee
ama182738	Syed Zaid Abdin
ama182739	Satish Kumar
ama182740	Amit Sharma
ama182742	Adil Eqbal
ama182743	Ankit Chaurha
ama182744	Shashank Kumar Srivastav
ama182745	Ashutosh Saraswat
ama182747	Chirag Gupta
ama182748	Deepak
ama182749	Sachin Kumar
ama182751	Shashwat Panda
ama182752	Krishan Kumar
ama182754	Kumar Sagar
ama182757	Ankit Kumar Verma
ama182758	Sreyansh Choudhury
ama182760	Kamlesh Kumar Vishwakarma
ama182763	Abhishek Shaw
ama182764	Hemant Kumar Nama
ama182765	Naresh Kumar
ama182767	Amit Kumar
ama182769	Satya Prakash Kanaujiya
ama182770	Samarth Charandas Dhengre
ama182771	Vivek Chaudhary
ama182821	Ashwani Kumar
ama182823	Kush Agarwal
ama182826	Amar Kumar
ama182827	Advait Sanjay Pohekar
ama182830	Mohammed Arif Mansoori
ama182831	Rajnish Kumar
ama182832	Rakesh Kumar
ama182835	Narendra Singh
ama182838	Ankit Singh
ama182872	Deepak
ama182873	Sachin Kumar
ama182879	Sahil Chawla
ame162266	Prabhjot Singh Sahi
amx185501	Abhay Singh Charan
amx185502	Akash Bhasin
amx185503	Ananth Kishore
amx185504	Arpit Trivedi
amx185506	Megha Rachel Kurian
amx185507	Mohammad Ziauddin Parvez
amx185508	Murali Krishna G
amx185509	Nitin Agrawal
amx185510	Oommen Roy
amx185511	Patil Akshay Hanmant
amx185512	Prabhu Dev Das
amx185513	Prerna Sharma
amx185514	Priyanka Gusain
amx185515	Rahul Pareek
amx185516	Rahul Pillania
amx185517	Rahul Thakur
amx185518	Rishav Raj
amx185519	Sai Sabarish M
amx185520	Santhosh Kumar S
amx185521	Saumya Singh
amx185522	Saurabh Sharma
amx185523	Srishti Tiwari
amx185524	Sumit Kiran Chavan
amx185525	Mandeep Singh
amx185526	Hitesh Singh Yadav
amy177543	Ashwani Kumar
amy187507	Jeevan Subrao Mane
amy187548	Amit Kumar
amy187549	Amit Kumar Sheoran
amy187550	Rishi Baadshah
amz128403	Amit Kumar
amz128405	Sudeep Verma
amz128406	Mehnaz Rasool
amz138001	Amit Kumar
amz138005	Dhanesh N
amz138007	Sakshi Chauhan
amz138008	Shanta Mohapatra
amz138289	Sanjay Kumar
amz138574	Adnan Ahmed
amz138575	Gargi Jaiswal
amz138577	Pankaj Srivastava
amz138592	Ishaq Sayed Makkar
amz148021	Aditya Ravindra Gokhale
amz148022	Anuj Kumar Shukla
amz148023	Bishweshwar Babu
amz148024	Hamid Hassan Khan
amz148025	Sagar Saroha
amz148232	Anurag Kumar Singh
amz148254	Chandrahas S Shet
amz148262	Lakhvinder Singh
amz148425	Pmg Bashir Asdaque
amz152044	Darius Diogo Barreto
amz158217	Haroon Ahmad
amz158219	Purnashis Chakraborty
amz158220	Sriram K
amz158346	Md Hasan
amz158347	Shrish Shukla
amz158348	Sartaj Tanweer
amz158349	M P Mathew
amz158488	Aravi Muzaffar
amz162259	Sandeep Yadav
amz168163	Prashant Mittal
amz168164	Vickey Nandal
amz168165	Deepak Kumar Singh
amz168166	Nishant Parashar
amz168168	Suvadeep Sen
amz168342	Anoop Kumar Pandouria
amz168347	K Vignesh Kumar
amz168463	Farooq Ahmad Bhat
amz168464	Deepak Kumar
amz168465	Shrikanth S
amz168466	Sajan Kumar
amz178117	Mohit Garg
amz178118	Ankita Gupta
amz178119	Kamal Tewari
amz178122	Kuldeep Yadav
amz178124	Nooruddin Ansari
amz178125	Yadwinder Singh Joshan
amz178127	Ranjeet Kumar
amz178128	Vivek Tripathi
amz178423	Arun E 
amz178547	Rishabh Shukla
amz178549	Obaidullah Khawar
amz178550	Amit Kumar Prasad
amz178551	Kasimuthumaniyan S
amz178554	Dharmraj Singh
amz188066	Sumit Kumar
amz188068	Mayank Jain
amz188069	Manish Kumar
amz188318	Sailendu Biswal
amz188631	Abhilash Awasthi
amz188632	Ashish Singh
amz188634	Nitin Kumar
amz188635	Saswath Ghosh
amz188636	Ujjwal Kumar Dey
amz188656	Prince Arora
anz128203	Piyush Chanana
anz138011	Ankit Singhal
anz138012	Shashank Sharma
anz138579	Kuntal Dey
anz148198	Britty Baby
anz148355	Danish Contractor
anz148356	Richa Gupta
anz157549	Geeta
anz157550	Himanshu Gandhi
anz158221	Aditi Bhateja
anz158222	Hameedah Sultan
anz158223	Harshvardhan Das
anz158482	Diksha Moolchandani
anz158497	Anupam Sobti
anz162112	Shikha Goel
anz168046	Shubhani
anz168048	Kunal Dahiya
anz168049	Akashdeep Bansal
anz178353	Sandeep Kumar
anz178419	Pranshu Jain
anz178422	Sidharth Ranjan
anz188001	Isaar Ahmad
anz188059	Vikas Upadhyay
anz188060	Chahat Bansal
anz188061	Vijay Kumar
anz188063	Sandeep Debnath
anz188064	Arun Singh
anz188379	Aruna Bansal
anz188380	Arnab Kumar Mondal
anz188387	Priyanka Singla
anz188503	Ayushi Agarwal
anz188521	Sunaina Srivastava
ast172001	Shruti Trivedi
ast172003	Rahul Singh
ast172006	Shivangi Pathak
ast172007	Diljit Kumar Nayak
ast172008	Kangari Narender Reddy
ast172009	Manish Kumar
ast172010	Modi Ria Prakashchandra
ast172012	Ravi Kumar
ast172015	Anuj Singh
ast172731	Ashutosh Kumar
ast172785	Pawan Parmar
ast172850	V S Srinivas
ast182713	Bhavesh Purohit
ast182714	Dwaipayan Chatterjee
ast182715	Sayali Ravindra Kulkarni
ast182717	Shivani Sharma
ast182718	Hari Kumar
ast182719	Kompella Siva Santhosh Saisrujan
ast182720	Nishil Tripathi
ast182721	Manish Gupta
ast182724	Isha Singh
ast182725	Parsundeep Singh
asz118399	Dileepkumar R
asz122525	Roshni Mathur
asz138014	Abhishek Kumar Upadhyay
asz138019	Sourangsu Chowdhury
asz138020	Tanuja Nigam
asz138508	Pawan
asz142298	Tanvi Gupta
asz148028	Kumar Ravi Prakash
asz148029	Popat Uttamrao Salunke
asz148030	Puneet Sharma
asz148031	Sarita Kumari
asz148032	Shilpa Gahlot
asz148033	Sofiya Rao
asz148357	Aditya Dhuria
asz148358	Sudipta Ghosh
asz158225	Raju Pathak
asz158226	Smita Pandey(Nee Mishra)
asz158227	Soumi Dutta
asz158228	Vivek Kumar Singh
asz158372	Jyoti Singh
asz168054	Rohit Kumar Choudhary
asz168055	Arulalan Thanigachalam
asz168368	Anushree Biswas
asz168369	Shashi Tiwari
asz178025	Navin Chandra
asz178026	Soumyadip Ganguly
asz178029	Rohit Kr Shukla
asz178466	Amit Kumar Sharma
asz178467	Jaishree Neelam
asz178468	Prabhakar Namdev
asz178469	Sweta Choubey
asz178470	Varunesh Chandra
asz178659	Badarvada Yadidya
asz188003	Saran Rajendran
asz188004	Anasuya Barik
asz188005	Jerin B Chalakkal
asz188006	Shoobhangi Tyagi
asz188007	Gregory George
asz188009	Jaswant
asz188511	Hemanth Sandeep Kumar Vepuri
asz188512	Kunal
asz188660	Sushovan Ghosh
bb1140024	Amit Kumar
bb1140036	Ganji Umesh Chandan
bb1140037	Gulshan Verma
bb1140039	J Shankar
bb1140053	Satyajeet Kumar
bb1140062	Udiyaman Shukla
bb1150021	Abhinav Arora
bb1150022	Abhishek Kumar Sahu
bb1150023	Adhhayan
bb1150024	Aishvi Jain
bb1150025	Akashi Negi
bb1150026	Amritanshu
bb1150028	Ankit Kumrawat
bb1150029	Arnav Karan
bb1150030	Ashwin Garg
bb1150031	Bharti Nakwal
bb1150032	Deepesh Nathani
bb1150033	Eash Sharma
bb1150034	Guddu Kumar
bb1150036	Himani Gautam Kambale
bb1150037	Himanshu Singh Sagar
bb1150038	Mihir Chandrashekhar Jain
bb1150040	Jeetu Singh
bb1150041	Kumar Komaleshwari Rani Naresh
bb1150042	Lamghare Aditya Raju
bb1150043	Mallika Singla
bb1150046	Pahade Asmita Kamalkumar
bb1150047	Pallavi Misra
bb1150048	Piyush Kumar
bb1150050	Prajjwal Sihag
bb1150051	Prince Agrawal
bb1150052	Puneet Lagoo
bb1150053	Rahul Khetan
bb1150054	Raj Kumar Ravidas
bb1150055	Rakesh Kumar Sukhani
bb1150056	Roshinee P
bb1150057	Samyak Jain
bb1150059	Shivam Sahu
bb1150060	Shradha Saini
bb1150061	Sushant Khare
bb1150062	Swapnil Sinha
bb1150063	Utsav Chawla
bb1150064	Vanisha
bb1150065	Vikrant Yadav
bb1160022	Nikhil Shenoy
bb1160023	Raghav Mishra
bb1160024	Ishank Pahwa
bb1160025	Jivesh Madan
bb1160026	Aditya Prasad
bb1160027	Anuja Trivedi
bb1160028	Sanyam Modi
bb1160029	Rohan Sanghi
bb1160030	Sannat Mengi
bb1160031	Nadiyadra Hemal Nileshbhai
bb1160032	Aishwarya Singh
bb1160033	Prateek Kumar Agnihotri
bb1160034	Anshul Mandawat
bb1160035	Varuni Sarwal
bb1160037	Nipun Gupta
bb1160039	Shreya Johri
bb1160041	Sonal Arora
bb1160043	Madhur Virli
bb1160044	Tanya Chaudhary
bb1160045	Sanjay Singh Poonia
bb1160046	Uddeshya Jaiswal
bb1160047	Abhishek Kumar Kushwaha
bb1160048	Saransh Kumar
bb1160049	Muskan Choudhary
bb1160051	Abhishek Kumar Singh
bb1160052	Kumar Shubham
bb1160053	Satyageet
bb1160054	Arunima Singh
bb1160055	Vikas Kumar
bb1160056	Pragya Mehra
bb1160057	Avlokit Kumar
bb1160058	Prakash Kumar Badal
bb1160059	Eeshwar Dutt Nirmal
bb1160060	Navdeep
bb1160061	Suyash Kumar Tak
bb1160062	Karan Birpali
bb1160063	Ghanshyam Meena
bb1160064	Tanvi Meena
bb1160065	Raj Kumar Meena
bb1170001	A Arunnishanth
bb1170002	Abheet Jain
bb1170003	Abhinav Garg
bb1170004	Abhinav Gupta
bb1170005	Abhishek Kumar
bb1170006	Anjali Arun Waghmare
bb1170007	Ankush Barman
bb1170008	Aryan Jain
bb1170009	Diyakshi Deora
bb1170011	Jae Hyun Kim
bb1170012	Mukund Poddar
bb1170013	Junior Chandan
bb1170014	Kirti Kumari Khandelwal
bb1170015	Raj Golhani
bb1170016	Kartike Bhardwaj
bb1170017	Lagan Bhatoa
bb1170018	Medha Agarwal
bb1170020	Mukhar Jain
bb1170022	Nikhil Kumar Saiyam
bb1170023	Palash Gupta
bb1170024	Paru Arora
bb1170025	Priyanka Choudhary
bb1170026	Priyanka Singh
bb1170027	Neha Arora
bb1170028	Rajendra Khalbadaniya
bb1170029	Ram Prabaharan T
bb1170030	Rathod Ruthik
bb1170031	Rupinder Kaur
bb1170032	Prakhar Joshi
bb1170033	Sanya Verma
bb1170034	Sarthak Mishra
bb1170035	Sarvesh Khimesra
bb1170036	Satish Kumar
bb1170037	Shaivee Malik
bb1170038	Shalaka Patil
bb1170039	Shubham Osari
bb1170040	Simran
bb1170041	Sparsh Negi
bb1170042	Sukhdev
bb1170045	Urvashi Dhar
bb1170046	Yash Bhatnagar
bb1170047	Jadhav Ashish Sunil
bb1180001	Abhay Kumar
bb1180002	Adarsh Vrindam
bb1180003	Agrima Deedwania
bb1180004	Omkar Shivajidoifode
bb1180005	Amit Kumar
bb1180006	Anahad Sharma
bb1180007	Anima Mandwariya
bb1180008	Animesh Parihar
bb1180009	Anish Singhrajawat
bb1180010	Anshul Rohilla
bb1180011	Barri Bhavya
bb1180012	D Payal
bb1180013	Deepanshu Goel
bb1180014	Esha Singh
bb1180015	Geeta Kolevishwanath
bb1180016	Harit Kumarkohli
bb1180017	Harsh Dutta
bb1180018	Harshit Gupta
bb1180019	Himanshubhargava
bb1180020	Himanshu Singh
bb1180021	Ishank Agrawal
bb1180022	Kavya Parnami
bb1180023	Mahesh Regar
bb1180024	Mayank Singh
bb1180025	Mohd Ali Mir
bb1180026	Naveen Saharan
bb1180027	Nehal Chachan
bb1180028	Pranjal Singh
bb1180029	Pratiyush Mishra
bb1180030	Prem Prakashmahar
bb1180031	Pushpitsrivastava
bb1180032	Rachit Jain
bb1180033	Rahul Sahu
bb1180034	Ravinder
bb1180036	Roopesh Dobwal
bb1180037	Ruchika Kumari
bb1180038	Harshit Kumarsingh
bb1180039	Sadanand Modak
bb1180040	Sanaz Agarwal
bb1180041	Sarthak Gupta
bb1180042	Sanidhya Jain
bb1180043	Shrey
bb1180044	Shubham Kumar
bb1180045	Suraj Joshi
bb1180046	Vikesh Saini
bb5070011	Bhaskar Singh
bb5090003	Akhil Kumar
bb5090033	Tanuj Kumar
bb5100042	Talabathula Ravali Kanaka Saran
bb5110007	Ashish Nain
bb5110029	Mohammed Shabeel P
bb5110049	Rathod,Abhishek
bb5120024	Maneesh Kumar Dhavan
bb5120033	Raghav Kumar
bb5120047	Vivek
bb5130002	Ajay Singh Dhayal
bb5130006	Bintu Kumar Meena
bb5130011	Dhritiraj Das
bb5130017	Kaluram Ninama
bb5130021	Malla Paramesh
bb5130023	Naresh Kumar Meena
bb5130029	Rishi Dayanand
bb5130033	Saqib Ansari
bb5140001	Abhinav Kumar Shukla
bb5140002	Akash Kakanwar
bb5140003	Ashim Garg
bb5140004	B M Revanth
bb5140005	Kanishk
bb5140008	Neha Meena
bb5140009	Nisha Bhatt
bb5140010	Paras Agrawal
bb5140011	S Kaushik Yadav
bb5140012	Samarth
bb5140013	Shubham Goel
bb5140015	Vineet Kumar
bb5150001	A R Shubham
bb5150003	Bharti Meena
bb5150004	Divya Garg
bb5150005	Indhana Divya Jayasree
bb5150006	Jashan Singh Suri
bb5150007	Kancharana Preeti Raj
bb5150009	Dhaval Rakesh Narwani
bb5150010	Nitesh Chaudhary
bb5150012	Prarthana Jain
bb5150013	Sashi Kalan
bb5150014	Sayak Banerjee
bb5150015	Yugesh Verma
bb5160001	Rathi Aditya Prashant
bb5160002	Parth Mittal
bb5160003	Harman Mehta
bb5160004	Saksham Sharma
bb5160005	Ayush Chachan
bb5160006	Surbhi Gupta
bb5160007	Parth Bhardwaj
bb5160008	G Prathibha Bharadwaj
bb5160009	Md Ahraz Zahir
bb5160010	Madishetty Saiteja
bb5160011	Sudhish P
bb5160012	Pradhumn Engle
bb5160013	Shubham Mehrol
bb5160014	Aman Kumar
bb5160015	Babu Lal Meena
bb5170051	Diwakar Kamal
bb5170052	Achintya Anant
bb5170053	Aniket Patel
bb5170054	Anuj Khandelwal
bb5170055	Anirudh Modi
bb5170056	Harsheet Chaudhary
bb5170057	Kartikey Karnatak
bb5170058	Mrigank Nehra
bb5170059	Narendra Kumar Meena
bb5170060	Kshitij Sahu
bb5170062	Priyanshi Rajput
bb5170064	Surendra Firoda
bb5170065	Vikas Singal
bb5180051	Ambekar Hrishikeshsanjay
bb5180052	Ankur Yadav
bb5180053	Apurva Singh
bb5180054	Ishika Verma
bb5180055	Lakshay Singh
bb5180056	Neeraj Soni
bb5180057	Nalin Shani
bb5180058	Rahul Verma
bb5180059	Ravindra Khoja
bb5180060	Samuel David Anandshadrach
bb5180061	Sarthak Chahal
bb5180063	Shrajay Dixit
bb5180064	Vicky Nautiyal
bb5180065	Yaman Garg
bb5180066	Yashasveechandra
bey167506	Vasu Goel
bey177501	Jagat Narayan Prajapati
bey177502	Anubha Shukla
bey177503	Amanpreet Kaur Nagpal
bey177505	Shruthi Lakshmi P
bey177533	Mansi Arora
bey177534	Shubham Dubey
bey187508	Nidhi Solanki
bey187509	Vipul Kumar
bey187511	Abhijit Singh
bey187512	Yogesh Kalakoti
bey187513	Praveen Kumar Singh
bey187514	Aditi Keshav
bez137510	Sanjay Singh
bez138510	Vidhu S
bez147503	Ashish K Lohar
bez148265	Pooja Murarka
bez148267	Vidhi Malik
bez158001	Deepak Kumar Prasad
bez158004	Upma Singh
bez158350	Jananee Jaishankar
bez158351	Rishabh Shukla
bez158355	Rohit Khandelwal
bez158357	Arun Thapa
bez158358	Shashi Kumar
bez158501	Divya Singhi
bez158503	Jyoti Sharma
bez167504	Arif Nissar Zargar
bez168007	Ritu Bhardwaj
bez168008	Ngangom Pravina Devi
bez168335	Biju Jacob
bez168558	Shefali Singh
bez168559	Deepak Sharma
bez178285	Priyanka Dubey
bez178286	Indranil Mondal
bez178287	Shivani Khatri
bez178289	Sneha Kumari
bez178290	Arti Tyagi
bez178291	Soumya Rajpal
bez178293	Dhvani Sandip Vora
bez178418	Rupsa Chatterjee
bez178438	Navaneethan Radhakrishnan
bez188239	Kritika Narula
bez188240	Deepchandra Joshi
bez188241	Garima Yadav
bez188243	Sakshi
bez188436	Avijeet Singh Jaswal
bez188437	Debashree Kar
bez188438	Partha Pratim Mondal
bez188439	Salina Tigga
bez188440	Seyad Shefrin N
bez188441	Shabnam Parwin
bez188442	Sidra Ghazali Rizvi
bly177509	Ashok David Jose
bly177510	Amit Tripathi
bly177511	Anandkumar M Changani
bly177512	Saiguru S
bly177541	Iswarya Srinivasan
bly187520	Siranjeevi Gurumani
bly187545	Prerna
blz128103	Priyanka Nair
blz128555	Kamalika Banerjee
blz138512	Kimi Azad
blz148192	Ashutosh Kumar Pandey
blz148193	Harsha Rohira
blz148196	Sabeeha
blz148197	Vivek Kumar
blz148200	Budhaditya Chatterjee
blz148271	Shivani Kumar
blz148272	Sukanya Ghosh
blz148359	Pankhuri Narula
blz158229	Aquib Ehtram
blz158230	Arti Kataria
blz158231	Bakul Piplani
blz158233	Nandhini Saranathan
blz158235	Shaantanu Singh
blz158236	Tarina Sharma
blz158440	S Kiruthika
blz167512	S Sujithra
blz168127	Devanshu Mehta
blz168129	Upma Dave
blz168130	Anjali Dixit
blz168133	Anshu Rani
blz168228	Anjali Priya
blz168229	Shivaksh Ahluwalia
blz168370	Akanksha Saini
blz168371	Ashish Kumar
blz168372	Chandra Shekhar Kumar
blz168373	Devanshi Mishra
blz168374	Firdos
blz168376	Ramesh Kumar
blz178279	Ankit Pal
blz178280	Dibyakanti Mishra
blz178281	Gagandeep Singh
blz178282	Pragya
blz178284	Uzma Salim
blz178574	Dipannita Ghosh
blz178575	Shubham Vashishtha
blz188277	Saurabh
blz188278	Shumayila Khan
blz188462	Aditi Arora
blz188463	Debashis Panda
blz188464	Elluri Seetharami Reddy
blz188465	Maryam Khursheed
blz188466	Nidhi Singh
blz188467	Pragati Vishwakarma
blz188468	Prasanjeet Kaur
blz188469	Rituparna Basak
blz188470	Vikas Dhar Dubey
bmt172114	Abhishek Thakkar
bmt172115	Dipul Chawla
bmt172116	Amit Kumar
bmt172117	Davinder Singh Lall
bmt172119	Jayant Kalra
bmt172120	Banasmita Kar
bmt172121	Kevin Antony Francis
bmt182308	Ramya V
bmt182309	Roshni Kedia
bmt182310	Manish Awasthi
bmt182311	Arijit Dey
bmt182312	Mridula Vij
bmt182313	Lata Kaushik
bmz128113	Sweeti
bmz128118	Satish
bmz128463	Marieswaran M
bmz128466	Amit Kumar Vimal
bmz128566	Rajpal Singh Mann
bmz138038	Anoop Kant Godiyal
bmz138042	Neha Singh
bmz138596	Amit Kumar Singh
bmz148225	Ayan Debnath
bmz148226	Dilpreet Singh
bmz148229	Snekha
bmz148273	Esha Baidyakayal
bmz158237	Pankaj
bmz158238	Tanu Bhardwaj
bmz158342	Sandeep Panwar Jogi
bmz168110	Neha Mehrotra
bmz168111	Dinil Sasi S
bmz168112	Rupsa Bhattacharjee
bmz168336	Rafeek T
bmz168398	Sachchidanand Tiwari
bmz178357	Aayushi Khajuria
bmz178358	Archana Vadiraj Malagi
bmz178359	Dharmesh Singh
bmz178360	Ahana Banerjee
bmz178361	Mohd Anees
bmz178413	K E Ch Vidyasagar
bmz178629	Shreemoyee De
bmz178630	Balakumaran V
bmz178631	Arnab Sikidar
bmz188298	Smriti Bala
bmz188307	Anjali
bmz188308	Anjali Barnwal
bmz188309	Subhodip Chatterjee
bmz188310	Virendra Kumar Yadav
bmz188509	Manjeet Singh
bmz188510	Namrata Tiwari
bsy167510	Sahil Jain
bsy167511	Rahul Gogia
bsy177507	Naveenta Gautam
bsy177508	Aditi Gupta
bsy187540	Gopal Kumar
bsz112222	Upendra Sunil Pathrikar
bsz128163	Archana Goyal Gulati
bsz128324	P Govind Raj
bsz138258	Rojalin Pradhan
bsz148360	Farheen Fauziya
bsz148419	Manoj Br
bsz158005	Alok Kumar Sinha
bsz158006	Bhawna Ahuja
bsz158315	Nilay Pandey
bsz158442	Kirti Kant Sharma
bsz168039	Pulkit
bsz168040	Bishal Dey Sarkar
bsz168041	Sukriti Garg
bsz168043	Praveer Sinha
bsz168044	Anvaya Rai
bsz168346	Jyoti Maheshwari
bsz168460	Sonali Shankar
bsz168461	Rama Kant Singh
bsz178035	Tripti
bsz178036	Archana
bsz178039	Ritesh Kumar
bsz178041	Sandeep Patel
bsz178366	Ambika Sharma
bsz178496	Laxmi Gupta
bsz178497	Jaya
bsz178498	Ruchita
bsz178499	Upendra Kumar
bsz178500	Anupam Malo
bsz178501	Chhavi Kumar Bharti
bsz188115	Ugrasen Singh
bsz188116	Ashish Kant Shukla
bsz188117	Mudasir Ahmad Bakshi
bsz188118	Nancy Varshney
bsz188119	Anushikha Singh
bsz188120	Adithya Nukala
bsz188121	Abhishek Grover
bsz188122	Sahil Anchal
bsz188123	Monica Bhutani
bsz188124	Neera Singh Parihar
bsz188291	Muskan Ahuja
bsz188522	Puja Dube
bsz188523	Karuna Yogesh Sunami
bsz188601	Chandra Bhushan Kumar
bsz188602	Magendran S
bsz188603	Mohina Gandhi
bsz188604	Nikhil Parashar
bsz188605	Sonal Arora
ce1120975	Tanmay Kumar Singh
ce1130323	Aman
ce1130348	Jitender Kumar
ce1130384	Ranveer Kumar Singh
ce1130386	Ritesh Kumar
ce1140243	Nethala Bilva Teja Bala Tataji Rao
ce1140303	Abhinav Kumar
ce1140315	Ankit Kumar
ce1140321	Arminder Singh
ce1140333	Brijvasi Meena
ce1140345	M Akhil
ce1140346	Manmohan Singh Dagar
ce1140348	Mustyala Varun
ce1140360	Rajesh Narravula
ce1140381	Shivam Rana
ce1140395	Suraj Kumar
ce1150302	Aakash Bansal
ce1150303	Abhinav Singh
ce1150304	Abhinav Kumar
ce1150305	Abhishek Mohan Mehra
ce1150306	Akshat Sharma
ce1150307	Akshit Garg
ce1150308	Aman Singh
ce1150309	Anand Raj
ce1150310	Aniket
ce1150311	Ankit Soni
ce1150312	Anubhuti Agarwal
ce1150313	Anup Pramod Totla
ce1150314	Anupma
ce1150315	Apurv Rochan
ce1150316	Ashish Kumar
ce1150317	Ashit Kumar
ce1150318	Ashwani Kumar
ce1150320	Bambhaniya Ashvinbhai Manubhai
ce1150321	Devendra Singh Meena
ce1150322	Devesh Kumar Dewangan
ce1150324	Gaurav Kumar Mittal
ce1150325	Harman Singh
ce1150326	Harsh Vardhan Singh
ce1150327	Harshit Gupta
ce1150328	Hemant Goyal
ce1150329	Ishant Gehi
ce1150330	Jain Himansh
ce1150331	Jay Prakash Patidar
ce1150332	Killi Sujit Kumar
ce1150333	Krishna Kumar Meena
ce1150334	Kritika Lila
ce1150335	Kuldeep Kumar Meena
ce1150336	Laxmikant
ce1150337	Lokesh Kumar Badyal
ce1150338	Mayank Bagaria
ce1150339	Medini Tolpadi
ce1150340	Mitul Mittal
ce1150342	Mohd Danish
ce1150343	Mohit Dayma
ce1150344	Nadeesh Bhardwaj
ce1150345	Narendra Kumar
ce1150346	Naveen Choudhary
ce1150347	Nazish Umar Ansari
ce1150348	Netram Meena
ce1150349	Nikhil Dadheech
ce1150350	Nikhil Chauhan
ce1150351	Nishant
ce1150352	Pankaj Jorwal
ce1150353	Paras Bhaisora
ce1150355	Parth
ce1150356	Pramod Kumar Mahich
ce1150357	Pukhraj Meena
ce1150359	Puneet Sindhu
ce1150360	Puneet Kumar
ce1150361	Puralasetti Gowtham
ce1150362	R V Pranay Kumar Reddy
ce1150363	Rahul Kumar Bairwa
ce1150364	Rahul Ashna
ce1150365	Rajat Kumar
ce1150366	Rajat Yadav
ce1150367	Rajesh Meena
ce1150368	Ram Pratap Singh Tomar
ce1150369	Riya Arora
ce1150370	Sagar Shukla
ce1150371	Samitinjoy Basak
ce1150372	Sanat Maheshwari
ce1150374	Sateesh Kumar Meena
ce1150376	Saurav Aggarwal
ce1150377	Saurav Raj
ce1150378	Shatrujeet Singh Rathore
ce1150381	Shobhit Jain
ce1150382	Shubham Kaushal Ahirwar
ce1150384	Shubham Kumar Sinha
ce1150386	Somesh Arya
ce1150387	Sourav Maity
ce1150388	Sudhir Kumar
ce1150389	Sudhir Kumar
ce1150392	Suraj Singhal
ce1150393	Tarun Yadav
ce1150394	Ujjwal Tarun
ce1150395	Utkarsh Shahi
ce1150397	Uttam Shukla
ce1150398	Vaishnav Kumar
ce1150399	Varun Gupta
ce1150400	Vikas Suman
ce1150401	Vinay Gupta
ce1150402	Vinod Singh Chaudhary
ce1150403	Vishal Kumar Maurya
ce1150404	Yash Agarwal
ce1150405	Yatin Kumar Singh
ce1160200	Harshad Shukla
ce1160201	Vidushi Toshniwal
ce1160202	Utkarsh Mishra
ce1160203	Himanshu Singh
ce1160204	Md Fasih Raghib
ce1160205	Ojaswi Dubey
ce1160206	Ketan Jain
ce1160207	Sanchit Sharma
ce1160208	Hargun Singh Grover
ce1160209	Abhinav Anand
ce1160210	Aditya Partap Singh
ce1160211	Ashutosh Raj
ce1160212	Keshav Prasoon
ce1160213	Adarsh Agrawal
ce1160214	Harsh Gupta
ce1160215	Suresh
ce1160216	Saurabh Sharma
ce1160217	Pankaj Joshi
ce1160218	Shanu Singhal
ce1160219	Kurapati Ruthwik Reddy
ce1160221	Pratik Bhaskar
ce1160222	Divyansh Gupta
ce1160223	Sourabh Kumar Singh
ce1160225	Sanjay Singh Tomar
ce1160226	Harsh Singla
ce1160227	Anoop Bishnoi
ce1160228	Madhav Kumar Jha
ce1160229	Akhil Kumar
ce1160230	Paras Arora
ce1160231	Adarsh Kumar Sonu
ce1160232	Achyutam Rai
ce1160233	Akarsh Shrivastava
ce1160234	Siddharth Tiwari
ce1160235	Prateet Garg
ce1160236	Anurag Goyal
ce1160237	Vikram Kumar
ce1160238	Ankit Goyal
ce1160239	Animesh Jain
ce1160241	Geetagya Dubey
ce1160242	Sanchit Bedi
ce1160243	Garima Gupta
ce1160244	Virok Sharma
ce1160245	Ayush Sharma
ce1160247	Bharti Singh Chauhan
ce1160248	Nikhil Agrawal
ce1160249	Vivek Kumar
ce1160251	Manoj Kumar Yadav
ce1160252	Vikas Verma
ce1160253	Vikas Faldoliya
ce1160254	Anjali Choudhary
ce1160255	Kushal Kumar
ce1160256	Gopathi Samba Shiva
ce1160257	Surya Prakash
ce1160258	Sanchit Singh
ce1160259	Sudhanshu Yadav
ce1160260	Rishabh Kumar Rewar
ce1160261	Sangam Raj
ce1160262	Basant Dudi
ce1160263	Sudhir Kumar
ce1160264	Arvind Kumar
ce1160265	Ashutosh Janu
ce1160266	Prashant Yadav
ce1160267	Suresh
ce1160269	Nilesh Kumar
ce1160270	Yashasvi Maurya
ce1160271	Mukul Anand
ce1160272	Satyam Kumar
ce1160273	Rohit Bidiyasar
ce1160274	Krishna Choudhary
ce1160275	Sandrana Sai Kumar
ce1160276	Damanjeet Singh
ce1160277	Anirudh Katiyar
ce1160278	Sunil Kumar Yogi
ce1160279	U Teja Vishnu
ce1160280	Devendra Sonkeware
ce1160281	Mithilesh Kumar Bhartiya
ce1160282	Lokesh Harioudh
ce1160283	Shivam Kartikeyan Atal
ce1160284	Varun Kumar Prashant
ce1160285	Tulsa Ram
ce1160286	Ranjan Kumar
ce1160287	Gaurav
ce1160288	Abhishek Verma
ce1160289	Pradeep Goyal
ce1160290	Vijay Kumar Meghwanshi
ce1160291	Himanshu Kumar
ce1160292	Tanmay Meghwal
ce1160293	Yogendra Kumar Singh
ce1160295	Gaurav
ce1160296	Uppadi Roshini Sai
ce1160297	Devanshu Jorwal
ce1160298	Rahul Meena
ce1160299	Karamtote Prashanth
ce1160302	Vinod Kumar Ghunavat
ce1160303	Rathod Sushanth
ce1160304	Prafullit Kumar Meena
ce1160305	Shivank Pratap Singh
ce1160856	Shivam Sachdeva
ce1170071	Abhee Desh
ce1170072	Abhishek Agrawal
ce1170073	Abhishek Anand
ce1170074	Abhishek Verma
ce1170075	Aditi Singh
ce1170076	Aditya
ce1170077	Ajay Agarwal
ce1170079	Amit Dubey
ce1170080	Aayush Sharma
ce1170081	Ankur Kapooria
ce1170082	Anoop Yadav
ce1170083	Anubhav
ce1170084	Anurag Dixit
ce1170085	Anurag Gautam
ce1170088	Ashish
ce1170089	Ashish Gupta
ce1170090	Ashish Kumar
ce1170091	Ashish Singh Bagri
ce1170092	Ashvini Kumar
ce1170094	Aviruddh Banvariya
ce1170095	Avish Jain
ce1170096	Ritik Kumar
ce1170097	Chethan A R
ce1170098	Deekshith N S
ce1170099	Deepak Kumar Dhaker
ce1170100	Ekant Yadav
ce1170101	Gajender Singh
ce1170102	Gaurav Brajesh Sharma
ce1170103	Gaurav Meena
ce1170104	Gautam Kunwar
ce1170105	Harashit Singhal
ce1170106	Hardik Ramkumar Agarwal
ce1170108	Harsh Agarwal
ce1170109	Hritik Tandon
ce1170110	Jatin Ahuja
ce1170111	Jayesh Satish Murarka
ce1170112	Jyamiti Maheshwari
ce1170113	Karishma Choudhary
ce1170115	Kshitij Bansal
ce1170116	Kshitiz Patel
ce1170117	Kunal Choudhary
ce1170118	Kylasa Maurya
ce1170119	Madhav Tiwari
ce1170121	Mandyam Yatish Sai
ce1170122	Mani Tyagi
ce1170123	Manoj Kumar
ce1170124	Manthati Akshitha
ce1170125	Maulik Aryan
ce1170126	Suryanshu Agrawal
ce1170127	Mayank Mehta
ce1170128	Mohit Anand
ce1170129	Mohit Kumar Goyal
ce1170130	Mritunjay Kumar Gupta
ce1170131	Naresh Meena
ce1170132	Nikhil Masoriya
ce1170133	Paritosh Charan
ce1170134	Piyush Kumar
ce1170135	Prashant Kumar
ce1170136	Prashant Ujjawal
ce1170137	Ayush Aman
ce1170138	Prince Raj
ce1170139	Pritam Kumar
ce1170140	Priyanshu Burark
ce1170141	Rahul Yadav
ce1170142	Ravi Sharma
ce1170143	Prakhar Gupta
ce1170144	Rishabh Sanjay Agrawal
ce1170145	Rishav Kumar
ce1170146	Riya
ce1170147	Rohit Kumar
ce1170148	Ruchit Warwade
ce1170150	Safalata
ce1170151	Sahil Meena
ce1170152	Samar Singla
ce1170153	Satvik Jain
ce1170154	Satyam Shivam Sundaram
ce1170155	Saurav Garg
ce1170156	Savi Modi
ce1170157	Shagun Kaushal
ce1170159	Shubham Patel
ce1170160	Shubhendu Kumar Metariya
ce1170162	Siddharth Singh
ce1170163	Siddharth Yadav
ce1170164	Sukhjeet Singh
ce1170165	Sukrati Goutam
ce1170166	Sumir Kumar
ce1170167	Suresh Choudhary
ce1170168	Prashant Limba
ce1170169	Tanvi Bamnawat
ce1170170	Ujjwal Mittal
ce1170171	Utkarsh Kumar Jorwal
ce1170172	Vedik Goyal
ce1170173	Viraj Chandra
ce1170174	Yash Gupta
ce1170175	Yogesh Kumar Maher
ce1180071	Aayush Jain
ce1180072	Abhimanyu
ce1180073	Abhimanyu Rewar
ce1180074	Abhishekjhajharia
ce1180075	Abhishek Parewa
ce1180076	Chiragmaheshwari
ce1180077	Aditya Singh
ce1180078	Aman Moharana
ce1180079	Sandeep Bishnoi
ce1180080	Amit Meena
ce1180081	Andukuri Rajivkoutilya
ce1180082	Aniket Jain
ce1180083	Ankit Kumar
ce1180084	Anshul Agarwal
ce1180085	Ankur Agrawal
ce1180086	Anup Yadav
ce1180087	Anushtha Bansal
ce1180088	Arpan Singh
ce1180089	Arunesh Singh
ce1180090	Avinashsiddhartha
ce1180091	Ayush Pandey
ce1180092	Balram Meena
ce1180093	Banothu Karthik
ce1180094	Achintya Eeshan
ce1180095	Bitra Rithvika
ce1180096	Dalip Kumar
ce1180097	Raman Kumar
ce1180098	Dipen Kumar
ce1180099	Harsh Pratapsingh
ce1180100	Himanshu Goyal
ce1180101	Isha Rankawat
ce1180102	Jatin Meena
ce1180103	Jhanvi Khosla
ce1180104	K Aishwaryareddy
ce1180105	Kartik Aloria
ce1180106	Sudheer Poonia
ce1180107	Kaushal Sharma
ce1180108	Kinjarapu Venkata Harshavardha
ce1180109	Kuldeep Meena
ce1180110	Kushagra Verma
ce1180111	Lochan Meena
ce1180112	Mahendra Kumar
ce1180113	Mahesh Patidar
ce1180114	Manas Yadav
ce1180115	Manish Choudhary
ce1180116	Manish Faroda
ce1180117	Manishkant Bose
ce1180118	Manpreet Singh
ce1180119	Mayank Meena
ce1180120	Mayur Udebhanrakhame
ce1180121	Megha Priya
ce1180122	Nikhil Bhola
ce1180123	Nishant Gupta
ce1180124	Nishu Meena
ce1180125	Nitish Kumar
ce1180126	Osim Abes
ce1180127	P Shreya Reddy
ce1180128	Pawan Kumarpandey
ce1180129	Prashant Katiyar
ce1180130	Prateek
ce1180131	Prateek Mishra
ce1180132	Prateek Singh
ce1180133	Pratham
ce1180134	Prem Kumar
ce1180135	Puneet Sethiya
ce1180137	Rahul Mishra
ce1180138	Ramindla Praneeth
ce1180139	Raunaq Saraswat
ce1180140	Richa Jain
ce1180141	Rinkush Kumarmeena
ce1180142	Ritik Rahul
ce1180143	Ritu Chaudhary
ce1180144	Ritu Yadav
ce1180145	Rohit Garga
ce1180146	Saanidhya Kumar
ce1180147	Sahil Meena
ce1180148	Sakshar Samirdesai
ce1180149	Sandeepchoudhary
ce1180150	Saranashika Sdhariwal
ce1180151	Sarthak Kumar
ce1180152	Saurabh Sharma
ce1180153	Shaganti Harshavardhan
ce1180154	Shivam Kumar
ce1180155	Shobhit Saxena
ce1180156	Shresth Gupta
ce1180157	Shubham Kumar
ce1180158	Shweta Kumari
ce1180159	Siddharth Singh
ce1180160	Snehal Sinha
ce1180161	Soumaysrivastava
ce1180162	Sparsh
ce1180163	Sunil Kumargurjar
ce1180164	Sunit Kumar
ce1180165	Surbhi Goel
ce1180166	Thatipellysathwik
ce1180167	Tushar Jethwani
ce1180168	Utkarsh Gupta
ce1180169	Vaibhav Bihani
ce1180170	Vaibhav Narayansingh
ce1180171	Vasu Goyal
ce1180172	Vidushi Meena
ce1180173	Vijay Pratapsingh
ce1180174	Vishnu Goyal
ce1180175	Vivek Kumawat
ce1180176	Yash Choudhary
ce1180177	Yogendra Gothwal
ce1189004	Gourmelon Thibaut
cec172577	Pooja Gura
cec172578	Prashant Kumar
cec172579	Rohit Raghwendra Tiwari
cec172580	V Kartik Ganesh
cec172581	Harshvardhan
cec172582	Pratik Anil Karwa
cec172583	Sreevathsav P
cec172585	Naveen Kumar
cec172586	Pulkit Rawlani
cec172587	Amrita Mishra
cec172588	Abhishek Mahajan
cec172589	Tarun Gaur
cec172590	Shivampratap Singh Chauhan
cec172591	Abhisek Pradhan
cec172592	Shubham Mittal
cec172593	Anikesh Paul
cec172594	Arnab Bhattacharyya
cec172595	Fatnani Chirag Raju
cec172597	Shreyansh Maloo
cec172599	Shaik Raheem
cec172601	Karan Arora
cec172619	Nishant Kumar
cec172620	Abhishek Kumar
cec172632	Sonu Kumar
cec182680	Aditya Shiv
cec182681	Akshay Kumar
cec182682	Amarjeet Singh
cec182683	Debasis Bandhu
cec182684	Dhurjuti Das
cec182685	Diwakar Mishra
cec182686	Gajavelli Venkatesh
cec182687	Kamal Krishna
cec182688	Manoj B
cec182689	Nihal Kumar
cec182690	Simranjeet Singh
cec182691	Vishnu Kant Pandey
cec182692	Siddharthram R
cec182693	Rahul Rathi
cec182694	Praveen Kumar
cec182695	Pankaj
cec182696	Shweta Thawait
cec182697	Nihar Ranjan Rai
cec182698	Nitin Kumar
cec182699	Madhur Goyal
cec182700	Gagandeep Kumar Garg
cec182701	Ajay Singh Jhala
cec182702	Shivani Dipak Joshi
cec182703	Shubham Gupta
cec182704	Shubham Singh
cec182705	Subir Kumar
cec182706	Guna Shekar Reddy Singireddy
cec182707	Mukul Saxena
cec182708	Mohd Raza Rizvi
cec182709	Kalidhas S
ceg162338	Abhilasha Bhukar
ceg172340	Lalit Kandpal
ceg172344	Rohit Sharma
ceg172352	Amir Tophel
ceg172353	Prem Kumar
ceg172510	Tejeshwini Singh
ceg172869	Gaurav Bangari
ceg172870	Vikas Kumar Srivastava
ceg182148	Aayush Garg
ceg182154	Praveen Oswal
ceg182156	Sourabh Mhaski
ceg182157	Angajala Sri Neelesh Kumar
ceg182628	Ashwani Kumar Chauhan
ceg182629	Satyam Dey
ceg182630	Ashutosh Dubey
ceg182631	Rahul Saini
ceg182632	Swati
ceg182633	Akash Verma
cep162293	Ajitesh Gupta
cep162295	Ashif Hussain
cep162296	Amber Gupta
cep162298	Rajeev Ranjan
cep162299	Vipul Mishra
cep172354	Sumit Shokeen
cep172355	Rizwan Husain
cep172356	Prabhash Abhishek
cep172358	Pathan Mansoor Alikhan
cep172359	Mohit Singla
cep172361	Narendra Kumar
cep172459	Sudeep Kumar Mishra
cep172461	Md Afroz Khan
cep172462	Harshit Gupta
cep172463	Kausik Pahari
cep172464	Anjali Tarar
cep172705	Manas Adhikari
cep182086	Mekuanint Getnet Hunegnaw
cep182124	Divyam Vinod
cep182125	Harpreet Sodhi
cep182126	Rahul Kumar Jha
cep182127	Saurabh Goyal
cep182158	Siddharth Kaushik
cep182160	Ashutosh Singh
cep182162	Gandham Sai Chandrika
cep182640	Sushant
ces162300	Bushra Rehman
ces162301	Divyarth Dikshit
ces162302	Mohammad Farhan Khan
ces172047	Prabhakar Roy
ces172369	Raushan Kumar Ravi
ces172378	Birbal Singh Khejer
ces172380	Juturu Ajay Reddy
ces172466	Varun Datta
ces172467	Abhishek Kumar Singh
ces172468	Ankit Khurana
ces172469	Anuj Gautam
ces172470	Rahul Kalra
ces172471	Vishal Seth
ces172472	Supriya Bharti
ces172512	Sushmita Baral
ces172707	Yogendra Singh Patel
ces172709	Vivek Bharti
ces172710	Mayank Gupta
ces172711	Lupesh
ces172865	Nitin Narula
ces172867	Borkar Daulat Sampatrao
ces172868	Kunal Srivastava
ces172874	Laxmisha Suvarna
ces182087	Rahul Panjiyar
ces182096	S Durga Prasad Dora
ces182097	Udit Negi
ces182098	Pushkar Kaushik
ces182128	Kapil Khandelwal
ces182129	Vaishali Bansal
ces182130	Mohd Atif Abedin
ces182131	Jayti Gupta
ces182132	Garvit Grover
ces182133	Pankaj Aswal
ces182173	Vishal Anand
ces182179	Rahul Chaudhary
ces182181	Rahul Meena
ces182182	Shipra Prakash
ces182183	Rohen Singh
ces182641	Shivam Srivastava
ces182643	Gautam Jindal
ces182644	Anil Saini
ces182645	V Rajesh Patro
ces182646	Gaurav Swami
ces182648	Hrishav
ces182649	Kumar Rajnish
ces182650	Ram Avtar Liler
cet172046	Hafizullah
cet172048	Imam Mahdi Burhani
cet172383	Arundhati Akhouri
cet172384	Qazi Saifur Rasool
cet172388	Arunima Sharma
cet172393	Vinayak Subhash Patil
cet172396	Suchita Sariyal
cet172398	Ritesh Singh
cet172399	Devanshi Sainia
cet172403	Sugam Bansal
cet172404	Vaibhav Handuja
cet172405	Ronak Jain
cet172407	Harsh Dangayach
cet172473	Rakesh Kumar Sharma
cet172474	Ved Prakash Sinha
cet172490	Tsegaye Arega Beyene
cet172531	Shamsudin Masoud
cet172532	Ahmad Shah Kakar
cet172713	Pawan Singh
cet182186	Rakeeb Khan
cet182187	Suryamani Kumar
cet182189	Vandnesh Shekhawat
cet182191	Anshul Mittal
cet182192	Prafful Singhal
cet182197	Ashish Saini
cet182198	Sourabh Kumar
cet182201	Lokender Kumar Singh
cet182204	Abhishek Goswami
cet182651	Akshay Rathi
cet182652	Venugopal Mahajan
cet182653	Avdhesh Singh Negi
cet182654	Abhimanyu
cet182656	Kartika Tanwar
cet182658	Bachan Singh Meena
ceu172411	Aakash Garg
ceu172412	Ram Singh
ceu172413	Abhijeet Singh
ceu172415	Shubham Bansal
ceu172416	Mohit Raj
ceu172417	Anurag Kumar
ceu172418	Sankarananda Rana
ceu172420	Mohammad Maaz
ceu172421	Tanvi
ceu172422	Abhishek Arun
ceu172423	Nishant
ceu172425	Anuj Jain
ceu172426	Abhishek Varshney
ceu172428	Shubham Yadav
ceu172861	Sameer Madan
ceu172862	Vinod Kumar Sharma
ceu172888	Megha Singh
ceu172889	Rohan Ramesh Dhamne
ceu182134	Rishi Nath
ceu182135	Subrata Biswas
ceu182136	Vijayakumar K
ceu182210	Mohd Sadiq Khan
ceu182211	Chuna Ram
ceu182215	Yarra Phaneendra
ceu182216	Anil Basak
ceu182659	Garvit Arora
ceu182660	Shahnawaz Ahmad
ceu182661	Shubham Chaudhary
ceu182662	Varsha Kushwaha
ceu182664	Brijesh Ashokbhai Wala
cev162311	Arjun Dange
cev172429	Susan George
cev172431	Jagadish Jotiram Patil
cev172436	Ashutosh Pratap Singh
cev172439	Pankaj Kumar
cev172475	Virat Chaudhary
cev172716	Siddharth Bapna
cev182085	Rojna Sharma
cev182137	Keshab Chandra Kumar
cev182138	Md Mustufa
cev182139	Eliza Vanlalpeka
cev182219	Shubhkarman Singh Randhawa
cev182221	Bhavya Parashar
cev182222	Radhika
cev182223	Himanshu Bansal
cev182226	Alankrita
cev182227	Sushant Kumar
cev182228	Deepak Swaroop
cev182230	Urman Ali
cev182231	Sujit Jibhau Nikam
cev182232	Sumit Yadav
cev182666	Sourav
cev182667	Sumit Suman
cev182668	Jigyashu
cew172444	Saurabh Gupta
cew172445	Sapam Raju Singh
cew172447	Manoj Kumar
cew172448	Avya Sukhlecha
cew172453	Sandeep Bhaskar
cew172718	Diksha Gupta
cew172719	Shivam Singh
cew172732	Sarvesh Kumar Yadav
cew172890	Abhijit Vikram Singh
cew172892	Shantanu Kumar
cew172893	Shreya Shekhar
cew172894	Pushpa Kudan
cew182083	Nazeer Ahmad Faizi
cew182084	Dereje Ayalew Sewagegnehu
cew182233	Jyotiranjan Barik
cew182235	Swetasmita Prusty
cew182238	Bilal Khan Yusufi
cew182669	Aman Gupta
cew182671	Rishabh Gupta
cew182673	Mohd Vasim
cew182674	Vimal Yadav
cew182675	Uppala Akhila Bharathi
cew182676	Arpan Kumar Sansari
cey167528	Akshat Jain
cey177535	Mohammad Elham Kohistani
cey187546	K Prakash Kumar Singh
cez118474	Shambhu Azad
cez127514	Kumar Supravin
cez128027	Elias Jemal Abdella
cez128029	Tewodros Tesfaye Woldemariam
cez128062	Naseef Ummer
cez128066	Ankesh Kumar
cez128069	Awadhesh Pratap Singh
cez128070	Dharmendra Lohar
cez128071	Sumeet Mahajan
cez128202	Ankit Bhardwaj
cez128305	Ajit Kumar Sinha
cez128535	Ashwani Jain
cez128545	Ranjan Alok
cez128547	Pardeep Kumar
cez138045	Abhishek Mittal
cez138048	Anil Kumar
cez138049	Arindom Chakraborty
cez138054	Gopinadh Rongali
cez138055	Himanshu Tyagi
cez138058	Jishnu R B
cez138059	Mainak Ghoshroy
cez138060	Mamata Mohanty
cez138063	Miss Meera
cez138066	
cez138073	Sameer Arora
cez138074	Sandeep Gandhi
cez138076	Satish Kumar
cez138077	Satishkumar V
cez138079	Shashank Pathak
cez138081	Sravan Kumar Gara
cez138082	Swapnil Mishra
cez138083	Tanwee Mazumder
cez138085	Vijai Kumar Kanaujia
cez138220	Ahmad Fayeq Ghowsi
cez138227	Rouzbeh Maddah
cez138421	Annada Padhi
cez138422	Anuj
cez138424	Chandan Kumar
cez138428	Gopi Kannan L
cez138429	Hari Krishna Gaddam
cez138430	Jatin Anand
cez138431	Khwairakpam Eliza
cez138432	Lakshmi Devi Vanumu
cez138434	Rajesh Kumar
cez138436	Shailendra Kumar Jain
cez138438	Vinnarasi Rajendran
cez142222	Ankur Bansal
cez148034	Anupriya Goyal
cez148036	Debdutta Ghosh
cez148039	Jashanjeet Randhawa
cez148040	Lohit Jain
cez148041	Mahesh Babu Addala
cez148042	Pankaj Goel
cez148043	Riya Bhowmik
cez148203	Gopinandan Dey
cez148237	Mahin Esmaeil Zaei
cez148260	Sreejith Krishnan
cez148361	Aali Pant
cez148362	Arun C Emmanuel
cez148364	Deepak Yadav
cez148365	Ghanshyam Agrawal
cez148366	Priyanka Bhartiya
cez148368	Rahul Bhartiya
cez148369	Ratnesh Kumar
cez148370	Ruban Sugumar
cez148371	Rudrabir Ghanti
cez148373	Sreenivas Sp Padala
cez148374	Sumit
cez148376	Swati
cez158008	Abhilasha Panwar
cez158010	Ananya Das
cez158012	Aswathy R
cez158013	Avijit Dey
cez158014	Bhamidipati Siri Aparna
cez158018	Kavita Tandon
cez158019	Mohit Kumar Singh
cez158022	Ravinder Singh
cez158023	Rohit Ralli
cez158026	Shushobhit Chaudhary
cez158028	Soumya Jain
cez158032	Tathagata Roy
cez158033	Yogita Mananbindal
cez158293	Teklay Gebreagziabhier Hagos
cez158304	Chaitanya K S 
cez158306	Sandeep Bhardwaj
cez158359	Aparna Sharma
cez158360	Mohammad Adil Dar
cez158361	Vandana Chithra Padmanabhan
cez158362	Abhary E
cez158363	Himanshu Pratap Singh
cez158364	Sandhya Birla
cez158365	Moulshree Tripathi
cez158368	Mrs Meenakshi Sharma
cez158369	Arvind Kumar Bairwa
cez158370	Tarapada Mandal
cez158371	Swati Rani
cez158487	Falak Zahoor
cez158493	Maneesh N
cez158494	Komal Shukla
cez158495	Nabeel Ahmed Khan
cez168135	Tanushree Parsai
cez168136	Sandhya Gupta
cez168137	Archana Chawla
cez168138	Mohit Somani
cez168139	Garima Gupta
cez168140	Arindam Deb Purkayastha
cez168141	Gautham A
cez168143	Durva Gupta
cez168144	Rahul Singh
cez168145	Gaurav Kalidas Pakhale
cez168146	Salman Beg
cez168147	Nishant Singh
cez168148	Shiv Priye
cez168150	Jayalakshmi Raju
cez168151	Fahimah Shad Sv
cez168152	Prasun Halder
cez168154	Venkata Padmasainihar Nanyam
cez168155	Maneesh Jaiswal
cez168156	Neeraj Jain
cez168160	Pratik Patra
cez168161	Harsha Yadav
cez168331	Lovleen Gupta
cez168333	Karanjeet Kaur
cez168334	Landage Amarsinh Babanrao
cez168419	Gummadivalli Shiva Kumar
cez168420	Nirbhay Narayan Singh
cez168422	Gopala Rao D
cez168423	Lav Singh
cez168424	Sparsh Johari
cez168426	Laxman Singh Bisht
cez168427	Deotima Mukherjee
cez168428	Manish Shukla
cez168429	Chetan Nagesh Doddamani
cez168430	Kavita Pradiprao Ganorkar
cez168431	Debasree Roy
cez168432	Sheelu Verghese
cez168433	Parvathi G S
cez168434	Amit Jain
cez168435	Manish Kapil
cez168437	Aritra Halder
cez168438	Anu Bala
cez168439	Ranadeep Basu
cez168440	Arun Singh
cez168574	Daniel Habtamu Zelleke
cez177518	Ravinder
cez177521	Abhishek Jain
cez178071	Venkatesh Madhukar Deshpande
cez178072	Apoorva Agarwal
cez178073	Santu Kar
cez178074	Nivea Thomas
cez178075	Syed Zaid Ahmad
cez178077	Punyabeet Sarangi
cez178078	Saloni Jain
cez178079	Sasi Kumar N
cez178080	Fulambarkar Sujata Jitendra
cez178081	Pranjal Mandhaniya
cez178082	Padala Suresh Kumar
cez178083	Shayesta Wajid
cez178085	Preeti Nain
cez178086	Sayantee Roy
cez178089	Sakshi Gupta
cez178091	Ravindranadh Chowdary Kamma
cez178093	Suman Kilania
cez178094	Adarsh M S
cez178367	Fikreyesus Demeke Cherkosz
cez178421	Oualihine Saddek
cez178522	Kashish Jain
cez178523	Anil Np Koushik
cez178524	Saurabh Sharma
cez178525	Archana Majhi
cez178526	Dinesh Kumar
cez178527	Ashwinth Raj R
cez178528	Rajesh Kumar
cez178529	Jyoti Kumari
cez178530	Mayuresh Dhanraj Bakare
cez178531	Rashmi
cez178532	Prerna Singh
cez178533	Abhishek Narayana Srivastava
cez178535	Dhanush S
cez178536	Om Prakash Tripathi
cez178537	Vikas Sharma
cez188026	Shubham Sharma
cez188027	Ashish Sengar
cez188028	Deepesh Bansal
cez188029	Debaprakash Parida
cez188030	Ankit Singh
cez188031	Vinay Kumar Singh
cez188032	Prashant Kumar Gupta
cez188033	Sourav Das
cez188034	Manoj K G
cez188035	Anjali Balan L
cez188036	Pranav Gairola
cez188037	Ishita Bhatnagar
cez188038	Dipto Deb
cez188039	Arpit Katiyar
cez188040	Shraddha Pravin Shahane
cez188041	Shipra Sinha
cez188042	Aishwarya Sanjay Jaiswal
cez188043	Anamika Yadav
cez188044	Venkateswarlu Polugari
cez188045	Priyanka Prashar
cez188047	Tanmay Gupta
cez188048	Venkateshwarlu Balla
cez188049	Arun Sekhar
cez188050	Pralayesh Guha
cez188052	Gauranshi Raj Singh
cez188053	Mayur Murlidhar Shindekar
cez188234	Biruk Gissila Gidday
cez188375	Arun N R
cez188388	Abhay
cez188389	Aasif Mujtaba Amir
cez188390	Ankur Chauhan
cez188391	Ansari Abdullah Momin Mohammed Amee
cez188392	Ashish Dobhal
cez188393	Ashish Yadav
cez188394	Baburao Muvvala
cez188395	Dattar Singh Aulakh
cez188396	Durga Prasad Tripathi
cez188397	Gayathri Vl
cez188398	Kusum Saini
cez188399	M V Mohammed Haneef
cez188400	Nishant Nilay
cez188401	Saba Rahman
cez188402	Sanjay Kumar Nirmal
cez188403	Susan N James
cez188405	Tanu Pittie
cez188406	Tribhuwan Singh Bisht
cez188407	Upasana Pandey
cez188408	Yatindra Kumar
ch1120067	Aman Tamta
ch1120078	Avinash Shishir Khalkho
ch1120088	Gurinder Singh
ch1130070	Aman Bhadu
ch1130071	Ankit Kumar Das
ch1130080	Hardeep Singh
ch1130119	Saurabh Dogra
ch1140071	Abhijeet Saherawat
ch1140121	Ratnesh Nath
ch1140126	Salumuri Lalith Sai Akhilesh
ch1140145	Vikas Meena
ch1140786	Arneish Prateek
ch1150002	Aditi Mahajan
ch1150071	Abhay Kumar Sarothia
ch1150072	Abhijeet R Ghodaki
ch1150073	Abhiprai Misra
ch1150074	Abhishek Garg
ch1150075	Abhishek Singh
ch1150076	Abhishree Arora
ch1150077	Adarsh Saini
ch1150078	Aditya Jagrat
ch1150079	Agambeer Singh Brar
ch1150081	Aman Verma
ch1150082	Amitesh Rathi
ch1150083	Aniket Kumar
ch1150084	Anish Kujur
ch1150085	Anshil Chandra
ch1150086	Anurag Deedwaniya
ch1150087	Arnab Mandal
ch1150088	Arsh Singh Chauhan
ch1150089	Aryaman Bansal
ch1150090	Atul Yadav
ch1150091	Bandish Parikh
ch1150092	Bhavya Dhuria
ch1150093	Chanchal Meena
ch1150094	Devandra Godara
ch1150095	Dhananjay Meena
ch1150096	Dharam Raj Meena
ch1150097	Dikshant Makhija
ch1150098	Divya Singh
ch1150100	Harneet Singh
ch1150103	Jatin Sharma
ch1150104	Kritika Sharma
ch1150105	Kshitij Goel
ch1150106	Kumar Utkarsh
ch1150107	Lalit Swami
ch1150109	Milind Dhanraj Zode
ch1150115	Neelanshu
ch1150116	Nikhil Kumar Meena
ch1150117	Nisha Singh
ch1150118	Paidi Krishna Pradeep
ch1150119	Parth Rajora
ch1150120	Prabhat Kumar
ch1150122	Pulkit Srivastava
ch1150123	Pulkit Langan
ch1150124	Ritik Chawla
ch1150125	Saksham Gupta
ch1150126	Shalini Gupta
ch1150127	Shashank Gupta
ch1150128	Shashwat Singh
ch1150129	Shraban Das
ch1150130	Shubham
ch1150131	Siddharth Sachan
ch1150132	Simran Malik
ch1150133	Smarth Veer Sidana
ch1150134	Soumya Prakash Behera
ch1150135	Subhankar Dash
ch1150136	Sunaje Bhushan
ch1150137	Sunint Singh Khurana
ch1150138	Sushree Jagriti Sahoo
ch1150139	Udaiveer
ch1150140	Ujjwal Narwal
ch1150141	Urvashi Gupta
ch1150142	Vatsal Sharma
ch1150143	Vikas Singh
ch1150144	Vinayak Gupta
ch1150145	Vishesh Goyal
ch1150190	Sukant Koul
ch1150385	Shubhika Jain
ch1150945	Surbhi Jain
ch1160070	Abhigya Parashar
ch1160072	Kshitiz Agrawal
ch1160074	Namrata Tripathi
ch1160075	Vanshika Jindal
ch1160076	Siddharth Singh
ch1160077	Amit Choudhary
ch1160079	Saryansh
ch1160081	Navish Goyal
ch1160082	Mehul Singhal
ch1160083	Pallewad Shivraj Prakashrao
ch1160085	Vishal Gupta
ch1160088	Nishtha Gupta
ch1160089	Shikhar Goel
ch1160090	Utsav Das
ch1160091	Ujjwal Nemchand Tater
ch1160092	Anisha Singrodia
ch1160093	Ishaan Gupta
ch1160094	Patel Vedant
ch1160095	Dhanesh Sethia
ch1160096	Akhil Kumar
ch1160097	Pratyush Dhasmana
ch1160098	Pranjal Kacholia
ch1160099	Rajeev Bhomia
ch1160100	Pratham Mehta
ch1160101	Aman Singhal
ch1160102	Surya Garg
ch1160103	Shubham Gupta
ch1160104	Prashant Jhalani
ch1160105	Patel Pranav
ch1160106	Adeesh Kolluru
ch1160108	Daksh Naruka
ch1160109	Piyush Verma
ch1160110	Aditya Rajan
ch1160111	Arpit Saraf
ch1160112	Divya Choudhary
ch1160113	Varun Poddar
ch1160114	Satyam Anand
ch1160115	Sahil
ch1160116	Bhuwnesh Chaudhary
ch1160117	Vikash Kumar
ch1160118	Vipin Yadav
ch1160119	Ms Aishwaryah
ch1160120	Akhtar Hussain
ch1160121	Vaidhyaprakash Choudhary
ch1160122	Yogesh Gupta
ch1160123	Abhishek Patel
ch1160124	Ambati Chandra Sekhar
ch1160125	Harsh Kanadi
ch1160126	Gaurav Singh Tanwar
ch1160127	Divyansh Mathur
ch1160128	Rakesh Kumar
ch1160129	Sanjeev
ch1160130	Jasleen Kaur
ch1160131	Tajasvi Kumar Singh
ch1160132	Sunil Kumar
ch1160133	Yash Madhurendra
ch1160134	Himanshu
ch1160135	Anant Rawatkar
ch1160136	Indra Kumar Rajak
ch1160137	Ravi Kant Singh
ch1160138	Rohan Verma
ch1160140	Dharmendra Kumar Meena
ch1160141	Sudip Besra
ch1160142	Naman Kumar
ch1160143	Aditi Gupta
ch1160144	Rahul Kumar Meena
ch1160166	Namya Agarwal
ch1160346	Mayank Shukla
ch1160675	Rahul Motwani
ch1170086	Arjun Singh
ch1170087	Aryaman Sinha
ch1170114	Khushi Sharma
ch1170120	Manavi Garg
ch1170161	Siddhant Goel
ch1170186	Abhinav Singh Yadav
ch1170187	Abhishesh Kumar
ch1170188	Aditi Singh
ch1170189	Aditya Gupta
ch1170190	Ahmad Nasir
ch1170191	Ajay Kumar
ch1170192	Ajay Meena
ch1170193	Akanksha Pradhan
ch1170194	Akshat Singh
ch1170195	Aman Gupta
ch1170196	Aman Kumar
ch1170197	Ankit Kumar
ch1170198	Anurag Holani
ch1170199	Arun Shelke
ch1170200	Atharva Rangnekar
ch1170201	Ayush Choubey
ch1170202	Ayush Purohit
ch1170203	Chaitanya Singh
ch1170204	Dialani Soham
ch1170205	Divyarth Prakash Saxena
ch1170206	Gargi Yaduvanshi
ch1170208	Hariom Yadav
ch1170209	Himanshu Thakur
ch1170210	Hridayesh Lal
ch1170211	Hrithik Agarwal
ch1170212	Kanishka
ch1170214	Koja Ram
ch1170215	Kshitij Kalla
ch1170216	Kumar Kirti Jain
ch1170218	Lalminlun Hangsing
ch1170222	Naveen Sharma
ch1170223	Neetan Kumar Lalotra
ch1170224	Nipun Garg
ch1170225	Nitesh Chilwal
ch1170226	Nitish Kumar Raikwar
ch1170227	Paritosh Raj
ch1170228	Patel Nikhil Hasmukhbhai
ch1170229	Payal Maru
ch1170230	Prabhat Kumar
ch1170231	Pranav Kumar
ch1170232	Vaibhav Jaiswal
ch1170233	Raghav Sharma
ch1170234	Rahul Mehta
ch1170235	Rahul Shah
ch1170236	Raj Sahani
ch1170237	Rakshit Chaudhary
ch1170238	Ranu Poonia
ch1170239	Ravi Nirala
ch1170240	Rohan
ch1170241	Rohit Rajendra Zope
ch1170242	Ronak Jain
ch1170243	Rounak Tikmani
ch1170244	Saksham Rawal
ch1170246	Samar Singh Rathore
ch1170247	Sanskar Agrawal
ch1170248	Sarthak Yadav
ch1170251	Shubham Kumar
ch1170252	Shwetangi
ch1170253	Shivam Rathi
ch1170254	Srinibas Nandi
ch1170255	Suman Kumar
ch1170256	Supriya Ranga
ch1170257	Swati
ch1170258	Tanish Singhal
ch1170259	Varsha Kumari
ch1170260	Vasu Agarwal
ch1170297	Nishank Goyal
ch1170309	Siddharth Aggarwal
ch1170311	Soumya Gupta
ch1170894	Divyansh Garg
ch1180186	Abhiroop Deepakagrawal
ch1180187	Abhishek Shringi
ch1180188	Abhishek Singh
ch1180189	Aditya Bansal
ch1180190	Adityakhandelwal
ch1180191	Adityavishwakarma
ch1180192	Ajay
ch1180193	Ajeet Kumar
ch1180194	Alex Prabhat Bara
ch1180195	Aman Agrawal
ch1180196	Anand Singh
ch1180197	Anitej Khare
ch1180198	Ankit Yadav
ch1180199	Anshul Tak
ch1180200	Arpan Mathur
ch1180201	Ashish Jaiswal
ch1180202	Ashish Krishnaprasad
ch1180203	Beg Mirza Asharabdullah
ch1180204	Atlanta Saikia
ch1180205	Ridhima Nain
ch1180206	Bhavya Prakash
ch1180207	Bhumika Ghosh
ch1180208	Chetan Goyal
ch1180209	Deepak Kumar
ch1180210	Deepender Kumar
ch1180211	Dev Bisht
ch1180213	Divit Gulati
ch1180214	Divyanshi Gupta
ch1180215	Franklin Gari
ch1180216	Aditya Anand
ch1180217	Ishan Maitreya
ch1180218	Jahanwi Singh
ch1180219	Jai Arora
ch1180220	Jarpulavath Swami
ch1180221	Kartikeya Badola
ch1180222	Lakshya Kumartangri
ch1180223	Levin Arora
ch1180224	Lushien
ch1180225	Madhulika Gautam
ch1180226	Mansi Sharma
ch1180227	Mihir Kedia
ch1180228	Moulie Singh
ch1180229	Nishant Sihag
ch1180230	Parth Jain
ch1180231	Parth Singhal
ch1180232	Parveen Kumar
ch1180233	Piyush Kashyap
ch1180234	Pranay Sinha
ch1180235	Pranshu Bhagat
ch1180236	Praveen
ch1180237	Priyanshu Sahoo
ch1180238	Puneet Malav
ch1180239	Samarth Goyal
ch1180241	Saroj Gangwar
ch1180242	Sarthak Pujari
ch1180243	Saurav Mittal
ch1180244	Shaurya Goyal
ch1180245	Shubham Mittal
ch1180246	Simran Jakhar
ch1180247	Sonam Wangmo
ch1180248	Spandan Dutta
ch1180249	Srijachakraborty
ch1180250	Subrata Mondal
ch1180251	Harshvardhanbothra
ch1180252	Umang Goel
ch1180253	Urvashi Panwar
ch1180254	Viditsinhchauhan
ch1180255	Vishal Kumar
ch1180256	Vishal Kushwah
ch1180257	Vivek Gaizwal
ch1180258	Vivek Kawat
ch1180259	Yugraj Painkra
ch1180260	Sehaj Virk
ch1180261	Amish Mohamedsaneen
ch7100145	Arnav Kansal
ch7120152	Chhail Singh
ch7120168	Prem Prakash
ch7120169	Rajesh Kumar Regar
ch7120189	Yash Kumawat
ch7130151	Ankit Jatav
ch7130156	Devesh Patel
ch7130159	Leema Laxman Atmaram
ch7130162	Mayank Deep Bansod
ch7130170	Rohan Khandelwal
ch7130179	Shubham Kumar Yadav
ch7140049	Pragya Gupta
ch7140151	Abhigyan Raman
ch7140153	Aditya Jain
ch7140154	Akanksha Puwar
ch7140155	Akash Ranjan
ch7140156	Aniket Saha
ch7140159	Anshu Kumar
ch7140161	Ayushi Chaudhary
ch7140162	Ayushi Agarwal
ch7140163	Bikash Gupta
ch7140164	Devesh Mahala
ch7140166	Harde Neeraj
ch7140170	Kashish Jalan
ch7140171	Mayank Tanwar
ch7140172	Milan Roy
ch7140173	Nahush Golait
ch7140174	Narendra Kumar Kaneriya
ch7140175	Neelotpal Nag
ch7140177	Niladri Sekhar Mandal
ch7140178	Prateek Kaleshwarwar
ch7140179	Priyanka Khoiwal
ch7140180	Priyanshu Anand
ch7140181	Raja Vishnu Hari
ch7140182	Sandeep Yadav
ch7140183	Santosh Kumar Gond
ch7140184	Shah Shreyans Shrenik
ch7140186	Shivam Saxena
ch7140187	Shrimali Jonit Bharatbhai
ch7140189	Souhardya Roy
ch7140190	Sumit Choudhary
ch7140191	Sumit
ch7140192	Sumit Kumar
ch7140193	Swapnil Sharma
ch7140194	Udit S Behl
ch7140195	Utkarsh Sinha
ch7140196	Vaibhav Srivastava
ch7140197	Yash Choudhary
ch7140198	Yogeshwari Chandrawat
ch7140834	V Balasaisubrahmanyeswara Reddy
ch7150151	Aditya Choudhary
ch7150153	Anuj Sahu
ch7150154	Anurag Rathore
ch7150155	Archit Aggarwal
ch7150156	Bansod Yash Raju
ch7150157	Devansh Agrawal
ch7150158	Devendra
ch7150159	Devendra Dewanda
ch7150160	Digvijay Das
ch7150161	Harilal Krishna
ch7150162	Herale Anushka Ananthraj
ch7150163	Jaya Meena
ch7150164	Kaustubh Saxena
ch7150165	Kiran Jain
ch7150166	Milan Goswami
ch7150167	Mohammad Areeb Afzal
ch7150168	Mukul Mittal
ch7150169	Nagesh Meena
ch7150170	Nazish Amber
ch7150171	Neha Kaswan
ch7150172	Onam Sinha
ch7150173	Pal Prakhar Singh
ch7150174	Paridhi Gupta
ch7150175	Parth Jindal
ch7150176	Prajval Kumar
ch7150177	Prakash Choudhary
ch7150178	Prashant Chohla
ch7150179	Pulkit Sharma
ch7150180	Rahul
ch7150183	Saransh Maheshwari
ch7150184	Sarthak Kala
ch7150185	Saurabh Subramaniam
ch7150186	Shivanshu Verma
ch7150187	Simar Kaur Mattewal
ch7150188	Sourabh Gole
ch7150189	Suhani Agarwal
ch7150191	Swapnil S Mavlikar
ch7150193	Vaibhav Sharma
ch7150194	Vashistha Anurag Maheshchandra
ch7150195	Y Nikhil Varma
ch7160150	Azmal Hussain
ch7160151	Anuj Aggarwal
ch7160152	Nikita Agrawal
ch7160153	Unnati Agrawal
ch7160154	Deepak Sonawat
ch7160155	Prabhat Sharma
ch7160156	Shikhar Makker
ch7160157	Yash Harshajit Sheth
ch7160158	Kritika Grover
ch7160159	Samit Dureja
ch7160162	Umesh Shahdadpuri
ch7160163	Pratham Baheti
ch7160164	Saurabh Singh
ch7160165	Yash Kabra
ch7160167	Mayuna Gupta
ch7160168	Parth Agarwal
ch7160169	Hardik Goyal
ch7160170	Aayush Goyal
ch7160171	Nishant Kakkar
ch7160172	Swapnil
ch7160173	Akash
ch7160174	Vikas Kumar Jat
ch7160175	Anukriti Yadav
ch7160176	Mahendra Singh Godara
ch7160177	Aman Patel
ch7160178	Siddharth Singh
ch7160179	Deepanshu Raj
ch7160180	Shubham Ranjan
ch7160181	Naitik
ch7160182	Hitesh Maan
ch7160183	Kirti Verma
ch7160184	Adwait Sudersan
ch7160185	Nishant
ch7160186	Rohan Bharti
ch7160187	Kartikeya Kumar
ch7160188	Sheetal Rasgon
ch7160189	Akash Chauhan
ch7160190	Rishabh Verma
ch7160191	Vaibhav Sunil Dawane
ch7160192	Amit Derwal
ch7160193	Sweeti Narzary
ch7160194	Saransh Ghunawat
ch7170271	Aditya Jaiswal
ch7170272	Mohit Anand
ch7170273	Alok Dayma
ch7170274	Aman Prasad
ch7170275	Aniket Munjal
ch7170276	Aniket Srivastava
ch7170277	Ankit Rathore
ch7170278	Anoop Gopal Singh
ch7170279	Apaar Mudgal
ch7170280	Ashay Rajesh Wanjarkar
ch7170281	Ashutosh Bhardwaj
ch7170282	Ayush Agrawal
ch7170283	Vaibhav Jain
ch7170284	Devashish Pardesi
ch7170285	Devdatt
ch7170286	Dheeraj Kumar Diwakar
ch7170288	Farooqui Masoom Shamim
ch7170289	Gaurav Singh
ch7170290	Ishan Mehta
ch7170291	Kamble Rajeshwari Chetan
ch7170292	Kamya Aggarwal
ch7170293	Kunal Blahatia
ch7170294	Madhuj Swarnkar
ch7170295	Mayank Agarwal
ch7170296	Neha
ch7170298	Rahul Mirdha
ch7170299	Rijul Jain
ch7170300	Rishabh Paliwal
ch7170301	Rohan Kumar Garg
ch7170302	Samay Dhanraj Pardhi
ch7170303	Santosh Meena
ch7170304	Santripti
ch7170305	Sarthak Lal Pushkar
ch7170307	Shiva Dagal
ch7170308	Shubham Gupta
ch7170310	Somendra Singh Jadon
ch7170312	Utkarsh Singh
ch7170314	Vikas Kumar Jha
ch7170315	Vikas Sehra
ch7180271	Aarti
ch7180272	Abdul Basit Abdul Salam Quresh
ch7180273	Abhinav Vitthal
ch7180274	Adityaraj Singhchouhan
ch7180275	Akshayshrivastava
ch7180276	Akshdeep Singhahluwalia
ch7180277	Ankur Singhthakur
ch7180278	Ayush Chaudhary
ch7180279	Ayush Venkateshbindlish
ch7180280	Ashwini Gautam
ch7180281	Jayesh Jawandhia
ch7180282	Yash Jain
ch7180283	Harsh Chaudhary
ch7180284	Jaykantchoudhary
ch7180285	Kanika
ch7180287	Tanay Johari
ch7180288	Manthan Jharwal
ch7180289	Martand Dubey
ch7180290	Mehul Garbyal
ch7180291	Mirge Sakshivilasrao
ch7180293	Prajwal Chandrabhankhobragade
ch7180294	Prateeksha Punia
ch7180295	Pratinav Hingonia
ch7180296	Praveen Soni
ch7180297	Raghav Goel
ch7180298	Rahul Bissa
ch7180299	Rahul Solanki
ch7180300	Rajat Kumar Jha
ch7180301	Gargi Sharma
ch7180302	Rishav Kumarrajak
ch7180303	Rohit Bhaskar
ch7180304	S R Kushal Gowda
ch7180305	Satyam Yadav
ch7180306	Saurabh Kumar
ch7180307	Shantanu Suryakantsontakke
ch7180308	Shikhar Anand
ch7180309	Shivang Lavania
ch7180310	Shritik Goyal
ch7180311	Shubham Kumar
ch7180312	Simarpreet Singhsethi
ch7180313	Smyan Jain
ch7180314	Somanshu Singla
ch7180315	Suvidhi Mehta
ch7180316	Uddipan Debnath
ch7180317	Utkarsh Kumarchoudhary
che172150	Akshay Chenna
che172152	Shubham Singh
che172164	Deepak Kumar Singh
che172549	Manvendra Singh
che172550	Shleshma Bhadoria
che172553	Sagar Kumar Pal
che172555	Sahil Vinayak Bhujbal
che172557	Sefali
che172565	Ilyas Yousuf Mir
che172724	Uttaran Basak
che172727	Kuldeep Singh
che172728	Pallavi Jha
che172729	Suraj Anil Bidwai
che172730	Naveen Kharb
che172770	Kamna Verma
che172834	Himakshi Barsiwal
che182089	Badege Abera Sanbi
che182404	Maregie Adugna Hailu
che182489	Abyansh Akarsh Roy
che182490	Akanksha Dhayal
che182491	Anju Sheba Mathew
che182492	Asha Devi
che182494	Avinash Raj
che182496	Bhagya Udya Bansal
che182497	Bhavishy Kumar Gupta
che182498	Charan S Salian
che182500	Jitendra Mandi
che182501	Kushal Kumar
che182503	Nishant Beriwal
che182506	Praveen Kumar
che182507	Ranjana Choudhary
che182509	Rohit Kumar
che182511	Satya Prakash Singh
che182512	Shiv Pratap
che182513	Shivam Gupta
che182515	Sudha Kumari
che182516	Sumit Kumar
che182517	Sunil Kumar Mahto
che182518	Surendra Pal Singh
che182519	Tanmaya Singhal
che182520	Vidit Tiwari
che182521	Vijay Kumar
che182522	Vikas Anand
che182523	Vivek Kumar
che182524	Yogendra Pal Singh
che182864	Ashok Kumar Meena
che182876	Puppala Harika
che182878	Sewale Kebede Alemayehu
chy187529	Bishnu Gupta
chy187552	Halima Sadiya
chz127523	Karthik G M
chz128215	Chaitanya Sk Narayanam
chz128225	Brajesh Kumar Singh
chz128230	Hemchandra Dutta
chz128412	Rohit Bansal
chz128414	Pranab Kumar Rakshit
chz138089	Kunche Babu Srinivas
chz138099	Sumit Kumar Singh
chz138290	Thameed Aijaz
chz138303	Ekta Jain
chz138439	Abhijeet Harikumar Thaker
chz138440	Deepak Sharma
chz138441	Ieeba Khan
chz138442	Kathiresan
chz138444	Kishore Kumar Sa
chz138447	Prashant Udaysinh Parihar
chz138448	Rajeev Kumar
chz138450	Shabina Ashraf
chz138452	Shipra Batra
chz138454	Vikas Pandey
chz138565	Rohit Kumar
chz148147	Shephali Singh
chz148148	Supriya Gupta
chz148164	Baijnath
chz148165	Iyman Abrar
chz148167	Kaisar Ahmad Hajam
chz148169	Neh Nupur
chz148170	Nikhil Kateja
chz148171	Rajbala
chz148172	Ravi Tejasvi
chz148174	Rupesh Mahendra Tamgadge
chz148178	Sonit Balyan
chz148179	Sunita
chz148206	Rohit Omar
chz148258	Jagtap Pramod Sambhaji Pushpa
chz148277	Debashish Panda
chz148279	Gul Afreen
chz148280	Iqra Reyaz Hamdani
chz148281	Jashwant Kumar
chz148282	Karan Malik
chz148283	Kaushal Rameshchandra Parmar
chz148284	Komal Kumar
chz148286	Sourabh Mishra
chz148287	Sudha Chauhan
chz148288	Surita Basu
chz148289	Vaibhav Kumar
chz148290	Vishwanath S Hebbi
chz158241	Mohamed Shahid
chz158248	Sangram Roy
chz158292	Edo Begna Jiru
chz158431	Syed Haider Abbas Rizvi
chz158432	Shalini Shikha
chz158433	Garima Vishal
chz158435	Sharandeep Singh
chz158436	Shashank Bahri
chz158490	Fatima Jalid
chz168283	Manga Ramya Durga
chz168284	Aniket Shrikant Ambekar
chz168285	Anamika Tiwari
chz168288	Aditya Singh
chz168289	Mohit Tiwari
chz168291	Prateek Khatri
chz168292	Rit Pratik Mishra
chz168294	Satirtha Kumar Sarma
chz168299	Pooja Jangir
chz168302	Prashant Ram Jadhao
chz168307	Lakshmignanabala Akilan
chz168308	Akshayy Garg
chz168309	Arvind Kumar
chz168310	Sanjeev Kumar
chz168348	Sirisha Parvathaneni
chz168517	Akshay Raju Mankar
chz168518	Misti Das
chz168523	Neelam Choudhary
chz168524	Amrish Kumar
chz168526	Bhawani Singh Solanki
chz168527	Avnish Kumar
chz168573	Sony
chz168576	T Nandakumar
chz172569	Minaz Ramjanali Makhania
chz178248	Abeer Mushtaq Mutto
chz178251	Deepak
chz178252	Manshu Kapoor
chz178255	Surbhi Gupta
chz178257	Rajan Singh
chz178258	Komal Tripathi
chz178260	Asad Abbas
chz178262	Pranav Vivekrao Kherdekar
chz178263	Rahul Raghuwanshi
chz178264	Abhishek Kumar Barnwal
chz178265	Kuldeep Singh
chz178266	Shailesh Pathak
chz178267	Ramdayal Panda
chz178268	Nituparna Dey
chz178269	Shravan Sreenivasan
chz178273	Sachin Chhagan Thorat
chz178275	Shantanu Banerjee
chz178277	Aashna Suneja
chz178278	Prateek Ranjan Yadav
chz178369	Tigist Tasew Dires
chz178503	Garima Thakur
chz178504	Anubha Agrawal
chz178505	Shalaka Bhargava
chz178506	Aman Mishra
chz178508	Rucha Suhas Patil
chz178509	Deepshikha Singh
chz178510	Nitin Kumar
chz178511	Geetanjali Basavaraj Hubli
chz178512	Yashwant
chz178515	Jai Prakash
chz178516	Bhupender Giri
chz178517	Sayantani Saha
chz178518	Aditya Pareek
chz178634	Sachin Tomar
chz178658	Julie Borah
chz188071	Akshata Vijay Ramteke
chz188074	Anjali Ramakrishna
chz188075	Anuj Shrivastava
chz188076	Bhukya Vishnu Naik
chz188077	Drishti Bhatia
chz188078	Dwijraj Prashant Mhatre
chz188079	Himanshu Malani
chz188080	Hitesh Babu
chz188081	Isha Atrey
chz188082	Ketan Mahawer
chz188083	Lalit Kumar
chz188084	Manoj Kumar Beriya
chz188085	Marvi Kaushik
chz188086	Nitika
chz188087	Nouduri Chandra Sekhara Abhinav
chz188090	Rajneesh Kumar Saini
chz188091	Reena Sharma
chz188096	Snigdha Mishra
chz188097	Som Dutt
chz188098	Supriya Rai
chz188099	Surya Chandra Tiwari
chz188100	Tanuja Joshi
chz188101	Vaibhav Pandey
chz188232	Belete Tessema Asfaw
chz188237	Tamirat Endale Geleta
chz188238	Yared Gebremichael Erenso
chz188297	Shreya Singh
chz188316	Rajat Punia
chz188386	Haseena K V
chz188486	Akshit Agarwal
chz188487	Ambereen Aziz Niaze
chz188488	Ankit Patidar
chz188489	Anurag Singh
chz188490	Isha Arora
chz188491	Madhumita Biswas
chz188492	Mohammad Muzaffar Ahsan
chz188493	Mohd Faisal
chz188494	Pooja Pandey
chz188496	Priyank Rajput
chz188497	Richa Agrawal
chz188499	Sandeep Challa
chz188500	Souvik Das
chz188501	Utsav Dalal
chz188502	Vicky Rahul Dhongde
chz188520	Anubha Agrawal
chz188547	Ataklti Kahsay Wolday
chz188663	Sayantan Biswas
chz188667	Ketan Mahawer
crf162862	Vandna Kumari Puspad
crf172108	Anjani Kumar Mishra
crf172109	Gokul Chandran
crf172110	Vaibhav Vaish
crf172111	Chandrakanth C
crf172112	Shimoli Rajendra Shinde
crf172113	Anurag Singh
crf172572	Apaar Kapoor
crf172573	Sidharth Singh
crf172574	Ashumani Kumar
crf172575	Randhir Singh
crf172576	Girish Bhardwaj
crf172631	Satish Shankarrao Yamagekar
crf172662	Abhijeet Seth
crf172694	Anil Ramesh Sarode
crf172695	Kunal Mahaseth
crf172696	Ayushi Agrawal
crf172697	Rutwik Shantanu Joshi
crf172698	Udit Jain
crf172699	Goverdhan M
crf172733	Sumit Singh Chauhan
crf172734	Akhilesh Sharma
crf172831	Kirti Bansal
crf172875	R S Rahul Pillai
crf182109	Ashish Tiwari
crf182110	Gaurav Singh
crf182111	Ullas Taneja
crf182112	Hardeep Kadian
crf182113	Sanjeev Kumar Sharma
crf182114	Adil Mehmood Siddiqui
crf182115	Saurabh Yadav
crf182116	Gourav Yadav
crf182117	Gauri Shankar Mishra
crf182118	Pranav Kumar
crf182119	Shweta Singh
crf182526	Shrikant Kumar
crf182527	Nitin Bhardwaj
crf182528	Manish Kumar Singh
crf182529	Yogesh Jangra
crf182530	Prashant Kumar
crf182531	Manu Kashyap
crf182532	Ishan Raj Sawla
crf182533	Manjari
crf182534	Shashank Mittal
crf182536	Suyash Narain Singh
crf182537	Ummang
crf182538	Rajat Srivastava
crf182539	Rishi Vij
crf182540	Vibhanshu Chaturvedi
crz138456	Anushruti Jaiswal
crz138458	Deepika Sipal
crz138463	Santosh Kumar Bhagat
crz148049	Arun Goel
crz148050	Ashish Malik
crz148052	Rakhi Kumari
crz148292	Bipin Kumar
crz148293	Harikesh
crz148294	Pranav Kumar Shrivastava
crz148295	Shakti Singh Chauhan
crz148296	Veerendra Dhyani
crz158034	Baiju M Nair
crz158036	Manish Jain
crz158038	Payal
crz158039	Sunil Kumar Sinha
crz158040	Wasi Uddin
crz158398	Swapna S
crz158428	Akshay Moudgil
crz158430	Nitesh Sahu
crz158437	Zamir Ahmad Wani
crz168012	Sriparna De
crz168013	Kamini Upadhyay
crz168561	Vaibhav Rana
crz168562	Karthikeya G S
crz168563	Aakanksha Mishra
crz168564	Pragyey Kumar Kaushik
crz168565	Jyothi R
crz168566	Sushil Kumar
crz168567	Shraddha Pali(Nee Pal)
crz168568	Avinash Kaur
crz168569	Sanjeev Kumar
crz168571	Surya Prakash Sankuru
crz178065	Dhairya Singh
crz178067	Alka Jakhar
crz178637	Nidhi Bisla
crz178638	Umesh
crz178639	John Wellington J
crz178640	Somia Sharma
crz178641	Ashish Jindal
crz188292	Priyansha Kaurav
crz188299	Iqram Haider
crz188300	Deepali Singh
crz188301	Anish Bhargav
crz188302	Anchal Yadav
crz188303	Niharika Narang
crz188653	Priya Pandey
crz188654	Suhas Rao
crz188655	Sumit Sharma
cs1110215	Gampala Naveen
cs1120236	Mukesh Kumar
cs1120265	Ratanlal
cs1130237	Mohit Choudhary
cs1140216	Chennamadhava Rohan Raju
cs1140227	Karan Dwivedi
cs1140249	Ranga Surendra
cs1140259	Tantati Avinash
cs1140260	Tuhinanksu Das
cs1140261	Ujjwal Kumar
cs1140262	Uppalam Venkata Mukesh Kumar
cs1140266	Vipparthy Sai Esvar
cs1150201	Aakash Agarwal
cs1150202	Aakash Sinha
cs1150203	Abhinav Choudhary
cs1150204	Abhishek Yadav
cs1150206	Aditya Shekhar
cs1150207	Aditya Sahdev
cs1150208	Akash Mittal
cs1150209	Akshay Gahlot
cs1150210	Aman Agrawal
cs1150211	Anoosh Kotak
cs1150212	Anshul T Dalal
cs1150213	Anuj Dhawan
cs1150214	Anuj Choudhury
cs1150215	Anupam Singh
cs1150216	Ashwani Kumar Verma
cs1150217	Ayush Ranjan
cs1150218	B Sourabh
cs1150219	Balla Revanth Babu
cs1150220	Bantupalli Sowmith
cs1150221	Chintha Ushaswini
cs1150223	Deepak Patankar
cs1150224	Dharmendra Kumar Shila
cs1150225	Dhole Shreyas Kiran
cs1150226	Divgian Singh Sidhu
cs1150227	Hire Vikram Umaji
cs1150229	J Roshan Naik
cs1150230	Jai Moondra
cs1150231	Kandukuri Karthik
cs1150232	Kanikaram Dwizotman
cs1150234	Kartikeya Sharma
cs1150235	Madhur Singhal
cs1150236	Manu Mitraan K
cs1150237	Mayank Aneja
cs1150238	Mehak Preet Dhaliwal
cs1150239	Mukund Mundhra
cs1150240	Muskaan
cs1150241	Om Patel
cs1150242	Parth Singh
cs1150244	Polakam Kamalnath
cs1150245	Prakhar Ganesh
cs1150246	Raghav Garg
cs1150247	Rahul Agarwal
cs1150248	Ravindra Singh Lohan
cs1150249	Ravuri Hema Chandar
cs1150250	Rohit Ohlan
cs1150251	Rohit Raj
cs1150252	Ronak Agarwal
cs1150253	Sagar Goyal
cs1150254	Saket Dingliwal
cs1150255	Sanket Sanjay Dhakate
cs1150256	Sarthak Mishra
cs1150257	Seelam Lakshmi Sai Krishna
cs1150258	Shiv Kumar Markam
cs1150259	Shobhit Gupta
cs1150260	Shubham Singh Tanwar
cs1150261	Suman Kumar
cs1150262	Suyash Agrawal
cs1150263	Swapnil Das
cs1150264	Tanmay Bansal
cs1150265	V Anoop
cs1150266	Vinnakota Sajit Gupta
cs1150267	Vipin Rao
cs1150268	Yash Gautam
cs1150291	Sangnie Bhardwaj
cs1150341	Mohammad Wasih
cs1150424	Abhishek Pathak
cs1150435	Ankesh Gupta
cs1150460	Manish Yadav
cs1150461	Manjeet Kumar
cs1150600	Kacham Praneeth
cs1150667	Prakhar Kumar
cs1160087	Ujjwal Gupta
cs1160294	Kartik Kumar
cs1160310	Shingi Siddhant Navin
cs1160311	Soumya Sharma
cs1160312	Deepanshu Jindal
cs1160313	Sarvagya Vinayak Sharma
cs1160314	Sunil Kumar
cs1160315	Akshat Khare
cs1160316	Divyanshu Saxena
cs1160317	Shubham Jain
cs1160318	Varada Pavan Sai
cs1160319	Harshit Goel
cs1160320	Rayala Harichandan
cs1160321	Arpan Mangal
cs1160322	Srijan Sinha
cs1160323	Akshay Neema
cs1160324	R Jayanth Reddy
cs1160325	Anugu Sai Kiran Reddy
cs1160326	Saransh Verma
cs1160327	Udit Jain
cs1160328	Shashwat Shivam
cs1160329	Rathi Sushant Shyam
cs1160330	Konuganti Sai Kumar Reddy
cs1160331	Aditya Jetha
cs1160332	Shashank Goel
cs1160333	Parth Shah
cs1160335	Aditya Jain
cs1160336	Sarthak R Vishnoi
cs1160337	Yash Raj Gupta
cs1160338	G S M Rishikesh Reddy
cs1160339	Donapati Hardhik
cs1160340	Kulkarni Nikhil Dilip
cs1160341	Pulkit Gaur
cs1160342	Ankit Akash Jha
cs1160343	Chetan Mittal
cs1160344	Rahul Bansal
cs1160345	Vinayak Rastogi
cs1160347	Pushpam Anand
cs1160348	Himanshu
cs1160349	Golla Venkata Sai Dheeraj
cs1160350	Shashwat Banchhor
cs1160351	Adigopula Sai Teja
cs1160352	Pranav Bhagat
cs1160353	Korakoppula Suresh
cs1160354	Minhaj Shakeel
cs1160355	Sachin Kumar Prajapati
cs1160356	Jay Kumar Modi
cs1160357	Abhinash Kumar
cs1160358	Kurmapu Venkata Vijaya Sai Prasanth
cs1160359	Tarun Kumar Yadav
cs1160360	Dangeti Bharadwaj
cs1160362	Khammampati Anirudh
cs1160363	Manish Tanwar
cs1160364	Danam Harshith Chandra
cs1160365	Vaddadi Sai Rohan
cs1160366	Sampat Khinchi
cs1160367	Ansh Prakash
cs1160368	Anubhav Palway
cs1160369	Pranav Baurasia
cs1160370	Rahul V
cs1160371	Shubham
cs1160372	Ravinder Singh
cs1160373	Shantanu Verma
cs1160374	Ayush Verma
cs1160375	Pradyumna Meena
cs1160376	Brajmohan
cs1160377	Adithya Anand
cs1160378	J Sri Harsha Vardhan Sai
cs1160379	Manas Meena
cs1160385	Rajas Bansal
cs1160395	Samarth Aggarwal
cs1160396	Ayush Patel
cs1160406	Animesh Singh
cs1160412	Pratyush Maini
cs1160513	Ankush Shaw
cs1160523	Manav Rao
cs1160680	Shreshth Tuli
cs1160701	Sankalan Pal Chowdhury
cs1170219	Mahak
cs1170321	Abhyuday Bhartiya
cs1170322	Aditya Panwar
cs1170323	Akhilesh
cs1170324	Amal Prasad
cs1170325	Anant Kashyap
cs1170326	Ananye Agarwal
cs1170327	Anil Kumar Uchadiya
cs1170328	Ankit Kumar Singh
cs1170329	Arsh Gautam
cs1170330	Ayyadevara Venkata Sai Nikhil Sriva
cs1170331	Banavathu Ajith Naik
cs1170332	Devendra Kumar Ahirwar
cs1170333	Divyanshu Mandowara
cs1170334	Harkanwar Singh
cs1170335	Hrithik Maheshwari
cs1170336	Jay Prakash Meena
cs1170337	Kaashika Prajaapat
cs1170338	Kailash Kumawat
cs1170339	Kaivalya Subhash Swami
cs1170340	Kaladi Lalith Satya Srinivas
cs1170341	Kamalesh Neerasa
cs1170342	Kartik Sharma
cs1170343	Kokku Chinmai Sai Nagendra
cs1170344	Kondeti Aashish
cs1170346	M Veeramakali Vignesh
cs1170347	Mayank Dubey
cs1170348	Mayank Kumar
cs1170349	Mayur Solanki
cs1170350	Medha Kant
cs1170351	Meenal Meena
cs1170352	Musunuru Saurav
cs1170353	Namrata Priyadarshani
cs1170354	Nisarg Bhatt
cs1170355	Paranjape Jay Nitin
cs1170356	Parth Porwal
cs1170357	Pendem Chanakya
cs1170358	Prakhar Mangal
cs1170359	Prashit Raj
cs1170360	Prateek Garg
cs1170361	Pratheek D Souza Rebello
cs1170362	Priyanshu Gautam
cs1170363	Putta Nikhila Reddy
cs1170364	Rachit Kumar
cs1170365	Rahul Choudhary
cs1170366	Raval Vedant Sanjay
cs1170367	Raviraj Singh Dhakad
cs1170368	Ravneesh Kumar
cs1170369	Ravuri M V S R Prafful
cs1170370	Saksham Dhull
cs1170371	Sameer Vivek Pande
cs1170372	Sanjay Meena
cs1170373	Sanskar Pareta
cs1170374	Shashank Shekhar
cs1170375	Shayan Aslam Saifi
cs1170376	Shivam Bansal
cs1170377	Shivam Goyal
cs1170378	Shivam Sheshrao Jadhav
cs1170379	Shourya Aggarwal
cs1170380	Shubh Jaroria
cs1170381	Shubham Sondhi
cs1170382	Tammireddi Venkata Sesha Sai Datta
cs1170383	Uddesh Katyayan
cs1170384	Vaibhav
cs1170385	Vankala Sai Vijay
cs1170386	Vardhan Jain
cs1170387	Vasu Jain
cs1170388	Vedant Vijay
cs1170389	Vidit Jain
cs1170390	Vusse Sravyasri
cs1170416	Rajbir Malik
cs1170481	Ritesh Saha
cs1170487	Rushil Gupta
cs1170489	Shailesh Yadav
cs1170503	Yaduraj Rao
cs1170540	Poorva Garg
cs1170589	Mohammad Kamal Ashraf
cs1170790	Vishwajeet Agrawal
cs1170836	Partha Dhar
cs1180321	Aarunish Sinha
cs1180322	Aayush Agarwal
cs1180323	Abhisek Maji
cs1180324	Adil Aggarwal
cs1180325	Aditya Verma
cs1180326	Aman Meena
cs1180327	Anmol Agarwal
cs1180328	Ayush Batra
cs1180329	Chimata Khagendrasai
cs1180330	Diwakar Prajapati
cs1180331	Dola Rahul
cs1180332	Galav Kapoor
cs1180333	Gautami Kandhare
cs1180334	Goalla Varsha
cs1180335	Gollu Leelaprasanthi
cs1180336	Hardik Agrawal
cs1180337	Harish Kumar Yadav
cs1180338	Hasavathu Ramnaik
cs1180339	Ishan Singh
cs1180340	Jai Javeria
cs1180341	Jatin Goel
cs1180342	Jatin Goyal
cs1180343	Jatin Munjal
cs1180344	Jatin Prakash
cs1180345	K Arun Prasad
cs1180346	Kalash Gupta
cs1180347	Kannekantisiddardha
cs1180348	Kapil Verma
cs1180349	Kartikeya Gupta
cs1180350	Kavya
cs1180351	Krishnakantdharekar
cs1180352	Lokesh Acharya
cs1180353	Manav Modi
cs1180354	Manish Kumar
cs1180355	Manupriya Gupta
cs1180356	Mayank Yadav
cs1180357	Methukumallijahnavi Rajeswari
cs1180358	Mukku Vishnumanogna
cs1180359	Muskan Himmatsinghka
cs1180360	Navneel Singhal
cs1180361	Otturu Tharunsiddhartha
cs1180362	Param Khakhar
cs1180363	Pavas Goyal
cs1180364	Pinnamreddy Lokeswarreddy
cs1180365	Piyush Gupta
cs1180366	Pragya Dechalwal
cs1180367	Prakam
cs1180368	Pratik Pranav
cs1180369	Pula Jaswanth Ram
cs1180370	Pushpa Raj I
cs1180371	Pushpendra Singhrana
cs1180372	Rathlavath Ravikanthnaik
cs1180373	Rathod Nikhil Naik
cs1180374	Rishabh Kumar
cs1180375	Ritika Hooda
cs1180376	Rudresh Raj Verma
cs1180377	S Shreya
cs1180378	Sagar Sharma
cs1180379	Sahil Sood
cs1180380	Sanyam Ahuja
cs1180381	Sarang Sunilchaudhari
cs1180382	Sarikonda Anandaramarao
cs1180383	Sarthak Agrawal
cs1180384	Sarthak Behera
cs1180385	Satwik Banchhor
cs1180386	Saurabh Kumar
cs1180387	Seshank Achyutuni
cs1180388	Sharique Shamim
cs1180389	Shrey Bansal
cs1180390	Shreyans J Nagori
cs1180391	Siddhant Choudhary
cs1180392	Siddharth Grover
cs1180393	Simarpreet Singhsaluja
cs1180394	Soham Vitthalgaikwad
cs1180395	Utkarsh Munjal
cs1180396	Utsav Deep
cs1180397	Valvai Aashrithkumar
cs5100286	Manoteja Boyapati
cs5110277	Athawale Pushpak Anil
cs5110290	Pawan Kumar Rajotiya
cs5110297	Shivani Sen
cs5120277	Amar Agnihotri
cs5120290	Kshitij Morodia
cs5120299	Shubham Kumar
cs5120300	Tarun Kota
cs5130280	Ayush Verma
cs5130286	Hirulkar Anket Prakash
cs5130288	Kandlikar Sujay Madhusudan
cs5130301	Sourabh Rana
cs5140276	Abhinav Yadav
cs5140277	Aditi Singla
cs5140278	Akshit Goyal
cs5140279	Ankush Phulia
cs5140280	Ashley Jain
cs5140281	Ayush Gupta
cs5140282	Bipul Kumar
cs5140283	Deepak Bhatt
cs5140284	Gollapalli Apoorva
cs5140285	Gulshan Kumar Jangid
cs5140286	Kartar Singh
cs5140287	Malothu Ravi Kiran
cs5140288	Momin Mahdihusain
cs5140289	Prachi Singh
cs5140291	Punit Tigga
cs5140292	Rachit Arora
cs5140293	Rishubh Singh
cs5140294	Shovan Paul
cs5140296	Udayin Biswas
cs5140297	Vaibhav Bhagee
cs5140435	Deepak Bansal
cs5140462	Nikhil Gupta
cs5140599	Praveen P Kulkarni
cs5140736	Kapil Kumar
cs5150102	Harsh Vardhan Jain
cs5150276	Abhishek Yadav
cs5150277	Amol Mukesh Bambode
cs5150279	Banoth Haswee
cs5150280	Chakshu Goyal
cs5150281	Chhajwani Anant Deepak
cs5150282	Dishant Singla
cs5150283	Gaurav Yadav
cs5150284	Harsimrat Singh
cs5150285	Kashish Bansal
cs5150286	Lovish Madaan
cs5150287	Nikhil Goyal
cs5150288	Palla Sai Bharath
cs5150289	Pankaj Saini
cs5150292	Saransh Goyal
cs5150293	Shreyas D Betal
cs5150294	Shubham Yadav
cs5150295	Sudeep Agarwal
cs5150296	Surya Chandra Kalia
cs5150297	Twinkal Meena
cs5150459	Makkunda Sharma
cs5160084	Sukriti Gupta
cs5160386	Jayant Jain
cs5160387	Prakhar Agrawal
cs5160388	Riya Singh
cs5160389	Avaljot Singh
cs5160390	Singamsetty Sanjeeva Krishna Sai Di
cs5160391	Mankaran Singh
cs5160392	Ansh Sapra
cs5160393	Atishya Jain
cs5160394	Mayank Singh Chauhan
cs5160397	Aniket Kumar
cs5160398	Aniket Kumar
cs5160399	Abhishek Maderana
cs5160400	Sumit Kumar Ghosh
cs5160401	Ankit Solanki
cs5160402	Hire Sanket Sanjaypant
cs5160403	Yash Malviya
cs5160404	Hardik Khichi
cs5160414	Vrittika Bagadia
cs5160433	Mohit Gupta
cs5160615	Chinmay Rai
cs5160625	Arshdeep Singh
cs5160789	Prabhat Kanaujia
cs5170401	Abhishek Burnwal
cs5170402	Adarsha Aman
cs5170403	Aditya Senthilnathan
cs5170404	Anshul Kumar Kurmi
cs5170405	Dhananjay Kajla
cs5170406	Divyanshu Sharma
cs5170407	Gohil Dwijeshkumar Navinbhai
cs5170408	Harkirat Singh Dhanoa
cs5170409	Harsh Yadav
cs5170410	Kabir Tomer
cs5170411	Karan Tanwar
cs5170412	Lakshay Saggi
cs5170413	Mayank Singh Kushwaha
cs5170414	Navneel Mandal
cs5170415	Rajat Jaiswal
cs5170417	Ritvik Vij
cs5170418	Sanjay P Lal
cs5170419	Siddhant Mago
cs5170420	Tanmay Kaushal Patel
cs5170421	Vijay Kumar Meena
cs5170422	Yash Jain
cs5170488	Sahil Vijay Dahake
cs5170493	Shreya Sharma
cs5170521	Ashish R Nair
cs5170602	Rahul Yadav
cs5180401	Ankit Yadav
cs5180402	Chirag Bansal
cs5180403	Chirag Mohapatra
cs5180404	Daman Arora
cs5180405	Dipanshu Patidar
cs5180406	Gaurav Chauhan
cs5180407	Harshavardhansushil Baheti
cs5180408	K Laxman
cs5180410	Manav Bansal
cs5180411	Manoj Kumar
cs5180412	Mridul Singh
cs5180413	Nikita Bhamu
cs5180414	Prashant Ranwa
cs5180415	Pratik Prawar
cs5180416	Rishabh Ranjan
cs5180417	Rohan Debbarma
cs5180418	Sachin
cs5180419	Sanjali Agrawal
cs5180420	Shruti Kumari
cs5180421	Sourav Bansal
cs5180422	Sparsh Gupta
cs5180423	Sushant Sondhi
cs5180424	Umesh Parmar
cs5180425	Vishal Bindal
cs5180426	Vishal Singh
csy157512	Subhajit Chatterjee
csy157533	Sudipta Roy
csy157535	Namrata Arora
csy167526	Siddhartha Sarkar
csy168515	Himani Raina
csy187551	Mehreen Jabbeen
csz128276	Chandrika Bhardwaj
csz128279	Madhulika Mohanty
csz138110	Prajna Devi Upadhyay
csz138294	Dinesh Khandelwal
csz148207	Aditya Ahuja
csz148208	Anirban Sen
csz148209	Neha Sengupta
csz148210	Nikhil Kumar
csz148241	Solomon Abera Bekele
csz148244	Hadi Brais
csz148382	Lokesh Siddhu
csz148383	Rajesh Kedia
csz148390	Samuel Wedaj Kibret
csz148417	Sakshi Tiwari
csz158041	Dilpreet Kaur
csz158042	Dinesh Raghu
csz158045	Ovia Seshadri
csz158046	Saurabh Tewari
csz158373	Ismi Abidi
csz158489	Janib Ul Bashir
csz158491	Iqra Altaf Gillani
csz168113	Shubhankar Suman Singh
csz168114	Arindam Bhattacharya
csz168117	Shailja Pandey
csz168119	Vishal Sharma
csz168121	Indu Joshi
csz168122	Sanjana Singh
csz168230	Rathnakar Madhukar Yerraguntla
csz168514	Omais Shafi Pandith
csz178057	Yatin Nandwani
csz178058	Keshav Sai Kolluru
csz178059	Divyanjali
csz178060	Dishant Goyal
csz178061	Divya Praneetha Ravipati
csz178063	Vinayak Gupta
csz178584	Abhishek Rose
csz188010	Garima Modi
csz188011	Prashant Agrawal
csz188012	Sachin Kumar Chauhan
csz188013	Raj Kamal
csz188014	Pawan Kumar
csz188295	Aritra Bagchi
csz188550	Ankita Raj
cym172136	Sunil Kumar
cym172139	Deepti Mishra
cym172141	Ekta Joshi
cym172142	Ravi
cym172143	Ankita Bora
cym172144	Shivam Pandey
cym172145	Geetika Pareek
cym172146	Ajay Kishor Kushawaha
cym172147	Naushad Ansari
cym172148	Arvind Kumar Jaiswal
cym172149	Dharmendra
cym182026	Thakur Rochak Kumar Rana
cym182028	Vijay Raj Tomar
cym182029	Greesh Kumar
cym182030	Komal Kumari Gupta
cym182031	Ravi Saini
cym182032	Rahul Yadav
cym182034	Neha Jain
cym182035	Toran Roy
cys177001	Abhishek Kumar
cys177002	Aditya Rana
cys177003	Akhil Paliwal
cys177004	Anil Saini
cys177005	Anju Bala
cys177006	Ankit
cys177007	Ankit Hooda
cys177008	Anushka Sain
cys177009	Apoorva Grewal
cys177010	Bhumika Singh
cys177012	Charu Sharma
cys177013	Deepak Yadav
cys177014	Deepali Dahiya
cys177016	Diksha
cys177017	Haridutt Sharma
cys177018	Harmanpreet Singh
cys177019	Harmeet Singh
cys177020	Jaideep Mor
cys177021	Jatin Verma
cys177022	Kaushal Kumar
cys177023	Kavita Choudhary
cys177024	Kavita Kumari
cys177025	Manisha
cys177026	Md Sajid
cys177027	Monika
cys177028	Mukul Madaan
cys177030	Naseeb Singh
cys177031	Naveen Kumar
cys177032	Nilesh Joshi
cys177033	Nitin Shukla
cys177034	Palak Manchanda
cys177035	Parthiv Barthakur
cys177036	Parul Sirohi
cys177037	Pratishtha
cys177038	Rahul
cys177039	Rajat Sharma
cys177040	Rashmi Jena
cys177041	Raveena
cys177042	Ritu
cys177043	Riya Halder
cys177044	Sagar
cys177045	Sayan Barua
cys177046	Shabnam
cys177047	Shubham Goel
cys177049	Sonali
cys177050	Sumit Mehta
cys177051	Surya Pratap
cys177052	Tanya
cys177053	Utkarsh Pathak
cys177054	Vikas Panwar
cys187002	Animesh Mishra
cys187003	Ankit Yadav
cys187004	Anshu
cys187005	Anuj Kumar
cys187006	Anurag Verma
cys187007	Arti Sharma
cys187008	Arvind Tiwari
cys187009	Asgar Ali
cys187010	Astha Tyagi
cys187011	Banwari Lal Meena
cys187012	Dambarudhar Samal
cys187013	Danish
cys187014	Deeksha Gopaliya
cys187015	Dharmendra Kumar Verma
cys187017	Divya
cys187018	Ekta
cys187019	Garima Satija
cys187020	Henadri Debbarma
cys187021	Jatin Grover
cys187022	Jitender Kumar
cys187023	Kajal
cys187024	Karan Doda
cys187025	Kartik Jain
cys187026	Koushik Makhal
cys187027	Mahipal
cys187028	Mansi Sharma
cys187029	Megha
cys187030	Navneet Kumar
cys187031	Nidhi Saini
cys187032	Nikunj Kumar
cys187033	Nisha
cys187034	Nishi Agarwal
cys187035	Nitin Kumar
cys187036	Priyanka Gogoi
cys187037	Rahul
cys187038	Rahul Kumar
cys187039	Raj Kumar
cys187040	Rajat Kumar
cys187041	Roopesh Kumar
cys187042	Ruchi Kumari
cys187043	Sagar Saini
cys187044	Sandeep Kumar
cys187045	Shiv Prashan
cys187046	Shivam
cys187047	Shivam Srivastav
cys187048	Shweta Tyagi
cys187049	Simran Arora
cys187050	Stanzin Lzaod
cys187051	Sunil Kumar
cys187052	Tushar Taneja
cys187053	Unik Arora
cys187054	Vanshita Garg
cys187055	Vikas Tiwari
cys187056	Vishal Kumar
cyz118207	Priyanka Singh
cyz128151	Poonam Sharma
cyz128155	Jasneet Grewal
cyz128159	Sandip Karmakar
cyz128510	Nitin Yadav
cyz138113	Balvinder Singh
cyz138114	Jagriti Singh
cyz138115	Krishna Kumar
cyz138123	Shubhrima Ghosh
cyz138124	Sonu Gupta
cyz138580	Amrita Dhawan
cyz138582	Jaya Lohani
cyz138585	Preeti Jha
cyz148053	Anita Yadav
cyz148054	Anu Kadyan
cyz148055	Kapil Sharma
cyz148056	Krishna Nand Tripathi
cyz148057	Md Samim Hassan
cyz148061	Pratibha Kumari
cyz148063	Sayani Das
cyz148216	Ruchika Bhat
cyz148393	Amit Kumar Gupta
cyz148394	Nusrat Rashid
cyz148395	Preeti Chaudhary
cyz158047	Aditya Gupta
cyz158049	Amjad Ali
cyz158050	Anju Bala
cyz158053	Bhawna
cyz158054	Dharmendra Singh
cyz158058	Manish Kumar Jaiswal
cyz158062	Renu Kumari
cyz158065	Supreet Kaur
cyz158480	Alankrita Garia
cyz158481	Sameer Dhawan
cyz168231	Anu Dalal
cyz168232	Vikas
cyz168236	Rachit Sapra
cyz168237	Deepa Bhardwaj
cyz168239	Priya Modi
cyz168241	Divya Dhingra
cyz168242	Ekta Jakhar
cyz168243	Syeda Warisul Fatima
cyz168245	Soumyadip Hore
cyz168248	Jyoti
cyz168252	Pritam Mahawar
cyz168253	Himanshu Singh
cyz168401	Shahenvaz Alam
cyz168402	Nivedita Roy
cyz168403	Sanjay Singh
cyz168404	Bharti Singh
cyz168405	Harshita Rastogi
cyz168407	Sonam Kumari
cyz168408	Archishmati Dubey
cyz168411	Nitika Patwa
cyz168412	Lokesh Kumar
cyz178098	Harender Singh Dhattarwal
cyz178099	Shilpa Sharma
cyz178100	Prabhakar Kumar Pandey
cyz178101	Ravneet Kaur
cyz178102	Ritu
cyz178105	Ajeet Singh
cyz178106	Shalini
cyz178107	Preeti Mishra
cyz178108	Aarti Manchanda
cyz178110	Upanshu Gangwar
cyz178111	Debashish Sahu
cyz178112	Rajashree Newar
cyz178113	Vivek Kumar Singh
cyz178431	Shobhna
cyz178486	Sakshi Shukla
cyz178487	Raman
cyz178488	Moumita Bera
cyz178489	Varsha Panwar
cyz178490	Isha Gupta
cyz178492	Priyanka Chauhan
cyz178493	Hanuman Singh
cyz178494	Nupur Tandon
cyz188193	Ashutosh Verma
cyz188194	Akshay Malik
cyz188196	Antara Sarkar
cyz188199	Kritika Keshari
cyz188200	Manjeet
cyz188201	Manju Devi
cyz188202	Monika Kumari
cyz188203	Namra Siddiqui
cyz188204	Neha Antil
cyz188205	Nikky Goel
cyz188206	Pooja
cyz188207	Pratima Shukla
cyz188210	Priyanka Yadav
cyz188211	Ragini Jain
cyz188213	Sagarika Taneja
cyz188214	Sahil Singh
cyz188215	Shailabh Tewari
cyz188216	Shreya Juneja
cyz188217	Vaishali Khokhar
cyz188218	Vishakha Goswami
cyz188219	Parul Saini
cyz188220	Priyesh
cyz188221	Shahzad Alam
cyz188279	Palak Middha
cyz188376	Kirandeep
cyz188378	Bhuvnesh Singh
cyz188472	Ankita Chandrashekher Maurya
cyz188473	Ekta
cyz188474	Jyoti Rohilla
cyz188475	Naved Akhtar
cyz188476	Naveen Kumar Maurya
cyz188477	Neha Dagar
cyz188478	Prakash Chandra Joshi
cyz188479	Rajat
cyz188480	Sameeksha Raizada
cyz188481	Sanjay Singh
cyz188482	Shashank Singh
cyz188483	Swati Khurana
cyz188484	Swati Singh
cyz188658	Vikas
ddz188311	Anchal Sharma
ddz188312	Ganesh S
ddz188313	Abhijeet Kujur
ddz188314	Naveen Kumar
ddz188504	Christy Vivek Gogu
ddz188659	Sanju Ahuja
ee1100479	Sawan Kumar
ee1120464	Mohamed Fasil C P
ee1120971	Saurabh Yadav
ee1130445	Bhawani Singh
ee1130447	Burra Vamsi Krishna Yadav
ee1130476	N S Bharath
ee1130483	Puppali Praneeth Goud
ee1130484	Pyatla Sharath Chandra
ee1130495	Shubham Meena
ee1130501	Siraboina Kshithesh
ee1130515	Vikas Bhaskar
ee1140421	Abhishek Bansal
ee1140426	Anant Kumar Singh
ee1140433	D Sai Tarun
ee1140437	Dilkhush Meena
ee1150045	Narayani Bhatia
ee1150080	Aman Kumar Singh
ee1150111	Mohit Goyal
ee1150114	Natasha Meena
ee1150379	Shivam Chandra
ee1150421	Aakash Agrawal
ee1150422	Abhilash Soni
ee1150423	Abhishek Bairwa
ee1150425	Abhishek Kumar
ee1150426	Aditya Kumar
ee1150427	Aditya Kumar
ee1150428	Adusumalli Lakshmi Himavanth
ee1150429	Akash Keshari
ee1150430	Akshay Verma
ee1150431	Alluri Bharath
ee1150432	Aman Mohapatra
ee1150433	Amitej Pangtey
ee1150434	Anil Bera
ee1150436	Anudeep Vibhuti
ee1150437	Anurag Rawat
ee1150438	Anvesh Gupta
ee1150439	Apoorv Pandey
ee1150440	Ashish Mehta
ee1150441	Ashray Gupta
ee1150442	Asif Anis
ee1150443	Bhavya Kalani
ee1150444	Boora Aasish
ee1150445	Dhananjay R Varma
ee1150446	Divyansh Gupta
ee1150447	Garvit Gupta
ee1150448	Gaurav Kumar Singh
ee1150449	Himanshu Singh
ee1150450	Himanshu Chandel
ee1150451	Himanshu Rohilla
ee1150452	Hitul Arora
ee1150454	Kartik Choudhary
ee1150455	Khushwant Khatri
ee1150456	Komarabathina Isaac Prasanth
ee1150457	Kuldeep Meena
ee1150458	Laxman Kumar Meena
ee1150462	Mudit Bansal
ee1150463	Nimish Goel
ee1150464	Peeyush Karnani
ee1150465	Rajan Goyal
ee1150466	Ramadev Sai Teja
ee1150467	Raunak Gautam
ee1150468	Rishabh Gupta
ee1150469	Rohit
ee1150470	Rupesh Kashyap
ee1150471	Sakshi Jain
ee1150472	Sarthak Jain
ee1150473	Sarvesh Khandelwal
ee1150474	Sathuluri Arun Chaithanya
ee1150475	Sawant Rohan Madhukarrao
ee1150476	Shah Krunal Tushar
ee1150477	Shridu Verma
ee1150478	Shubham Rao
ee1150479	Shweta Singh
ee1150481	Sonu Kumar Gupta
ee1150482	Sourabh Veerwal
ee1150483	Subrat Singh Balot
ee1150485	Sumit Kumar
ee1150486	Sushant Singh Sarote
ee1150487	Sushant Daga
ee1150488	Tarun Gupta
ee1150489	Tinish Bhattacharya
ee1150490	Udit Singla
ee1150491	Vinay Sangwan
ee1150492	Vineet Kumar
ee1150493	Vivek Arora
ee1150494	Vudala Sai Susrith
ee1150504	Aditi Jha
ee1150519	Krutika Jaiswal
ee1150534	Saksham Soni
ee1150641	Ayush Jain
ee1150691	Yash Garg
ee1150730	Bindal Ashutosh Arun
ee1150735	Ishan Tewari
ee1150781	Abhay Chandra
ee1150835	Varun Srivastava
ee1150908	Madhur Singal
ee1160040	Tanay Asija
ee1160050	Nitin Yadav
ee1160071	Hritik Bansal
ee1160107	Nishad Singhi
ee1160160	Shivam Jain
ee1160410	Vipul Anand
ee1160411	Piyush Mittal
ee1160415	Alla Upendher Reddy
ee1160416	Ankit Agarwal
ee1160417	Himanshu Garg
ee1160418	Akanshu Gupta
ee1160419	Vallamkondu Rushi Manoj
ee1160420	Santosh Kumar
ee1160421	Vivek Singal
ee1160422	Gandhi Siddhesh Atul
ee1160423	Sanyam Chhangani
ee1160424	Sajal Jain
ee1160425	Parimeya Ranadive
ee1160426	Hemant Kumar
ee1160427	Avinash Bhutani
ee1160428	Malay Jain
ee1160429	Ashwin Tunga
ee1160430	Vipul Vaibhav
ee1160431	Gajera Dev
ee1160432	Ritwik Chakravarti
ee1160434	Kashish Jain
ee1160435	Aditya Abhishek
ee1160436	Mayank Mishra
ee1160437	Devesh Joshi
ee1160438	N Tarun Sai Ganesh
ee1160439	Kunal Narayan
ee1160440	Sankalp Garg
ee1160441	Abhinav Kalra
ee1160442	Nalawade Sarvesh Bharat
ee1160443	Harshit Jain
ee1160444	Suramya Saxena
ee1160445	Siddhant Jindal
ee1160446	Kanish Garg
ee1160447	Chamakuri Vishnu Bharat
ee1160448	Pogu Rahul Raju
ee1160450	Jitender Singh
ee1160451	Tushar Chaudhary
ee1160452	Anuj Kumar Chaurasiya
ee1160453	Indr Raj Gurjar
ee1160454	Amit Yadav
ee1160455	Rahul Kumar Jhajharia
ee1160456	Amit Verma
ee1160457	Lakshya Pratap Rastogi
ee1160458	Marzooq Abdul Kareem
ee1160459	Anand Kumar Verma
ee1160460	Apoorv Dankar
ee1160461	Raman
ee1160462	Rohad Prajwal Karamchand
ee1160463	Gadhavi Yash
ee1160464	Rahil Choudhary
ee1160465	Chilukamari Shiva Sai Krishna
ee1160466	Gaurav Jhajharia
ee1160467	Ravi Singh
ee1160468	Shivansu Kumar
ee1160469	Udit Raj Singh
ee1160470	Sandesh Sen
ee1160471	Nishant Verma
ee1160472	Arpit Singh
ee1160473	Ankit Meghwanshi
ee1160474	Sarthak Sablania
ee1160475	Ankit Kumar Bunkar
ee1160476	Hitesh Baswal
ee1160477	Tarun
ee1160478	Mannam Akhil
ee1160479	Dhruv Kawat
ee1160480	Rahul Meena
ee1160481	Kargil Singh Solanki
ee1160482	Nikhil Meena
ee1160483	Rahul Meena
ee1160484	Namonarayan Meena
ee1160499	Vaibhav Porwal
ee1160545	Shikhar Tuli
ee1160556	Khushal Sethi
ee1160571	Shubham Priyadarshi
ee1160694	Gantavya Bhatt
ee1160825	Saurabh Kumar
ee1160835	Anubhav Bhatia
ee1170093	Devang Mahesh
ee1170249	Saumil Ratnakar
ee1170306	Sharma Dipanshu Dilipkumar
ee1170345	Lavi Choudhary
ee1170431	Abhishek Kumar
ee1170432	Abhishek Singh
ee1170433	Adarsh Shrivastava
ee1170434	Aditi Vikas
ee1170435	Akash Anand
ee1170436	Aman Tiwari
ee1170437	Anand Daswani
ee1170438	Aniket Gupta
ee1170439	Ankit Garg
ee1170440	Anurag Yadav
ee1170441	Ashwil Bhupesh
ee1170442	Ayan Jain
ee1170443	Brateesh Roy
ee1170444	Budhil Raj Patel
ee1170445	Deep Rajesh Gandhi
ee1170446	Deepak Meena
ee1170447	Devesh Kumar Meena
ee1170448	Dilkush Meena
ee1170449	Dondapati Venkata Naga Adithya
ee1170450	Fulesh Kumar Dahiya
ee1170451	Gaduputi Sumanth
ee1170452	Gayank Negi
ee1170453	Harshit Patidar
ee1170454	Janak Sharda
ee1170455	Jayesh Janardhan Karwande
ee1170456	Kemla Mukul
ee1170457	Kuriti Siva Sankar
ee1170458	Lakshya Bhatnagar
ee1170459	Lavish Chauhan
ee1170460	Menda Hemanth
ee1170461	Modi Nihar
ee1170462	Mohammad Atif
ee1170463	Mudit Soni
ee1170464	Narreddy Bhavani Sankar Reddy
ee1170465	Nilabjo Dey
ee1170466	Palli Pramod Vishnu
ee1170467	Pamarthi Mohan Harsha
ee1170468	Parv Agrawal
ee1170469	Pradyumna Jalan
ee1170470	Prafull Kumar Manav
ee1170471	Pranay Singh Azad
ee1170472	Prashmit Kumar Bose
ee1170473	Prateek Agrawal
ee1170474	Preet Malviya
ee1170475	Prem Parkash
ee1170476	Rahul Jain
ee1170477	Rakesh Kumar
ee1170478	Ramesh Kumar Chouhan
ee1170479	Ravi Gupta
ee1170480	Rishabh Ranjan
ee1170482	Ritik Agrawal
ee1170483	Ritik Rajendra Choudhary
ee1170484	Ritvik Kapila
ee1170485	Ritvik Sharma
ee1170486	Rushi Patel
ee1170490	Shashi Kumar Modi
ee1170491	Shitij Agrawal
ee1170492	Shivanshu Bohara
ee1170494	Shubham Kumar
ee1170495	Siddhant Haritwal
ee1170496	Siddhant Sagar
ee1170497	Siddharth Dangwal
ee1170498	Skyler Sharad Badge
ee1170500	V Shreyas
ee1170501	Vaibhav Kasotiya
ee1170502	Vyakaranam Venkata Sai Ganesh Chand
ee1170504	Yash Gupta
ee1170505	Yash Singla
ee1170536	Mainak Agrawal
ee1170544	Raghav Gupta
ee1170565	Anshul Yadav
ee1170584	Lokesh Patel
ee1170597	Nishant Singh Chouhan
ee1170599	Prabudh Jangra
ee1170608	Samarth Gupta
ee1170704	Vedang Karwa
ee1170809	Aman Prakash
ee1170937	Pratyush Garg
ee1170938	Pratyush Pandey
ee1180431	Abhimanyu Yadav
ee1180432	Abhishek Agrawal
ee1180433	Achint Kumaraggarwal
ee1180434	Aditi Khandelwal
ee1180435	Akarsh Sharma
ee1180436	Akash S
ee1180437	Akash Vardhan
ee1180438	Amarjeet Kumar
ee1180439	Ambuj Verma
ee1180440	Amenreet Singhsodhi
ee1180441	Amogh Agrawal
ee1180442	Aniket Modi
ee1180443	Aniket Ulhasshetty
ee1180444	Animesh Verma
ee1180445	Anireddy Aravindreddy
ee1180446	Anirudh Panigrahi
ee1180447	Ankish Kumarchandresh
ee1180448	Anurag Chaudhary
ee1180449	Arun Digra
ee1180450	Arvind Kumar
ee1180451	Ashish Kumar
ee1180452	Ashit Ranjan
ee1180453	Avinash Meena
ee1180454	Bhawna Kumari
ee1180455	Bhoopendra Uikey
ee1180456	Biruduraju Harahima Druthi
ee1180457	Chaitnyashrivastava
ee1180458	Chandrudu K
ee1180459	Chathur Gudesa
ee1180460	Garima Soni
ee1180461	Hardik Tanwar
ee1180462	Harit Jaiswal
ee1180463	Harsh Agarwal
ee1180464	Harsh Kumar Raj
ee1180465	Harshil Kandoi
ee1180466	Hemansh Khaneja
ee1180467	Himanshu Rajput
ee1180468	Ishita Chawla
ee1180469	Jay Kishan
ee1180470	Kamna Meena
ee1180471	Kanishk Goyal
ee1180472	Kartik Agrawal
ee1180473	Lakshay Gupta
ee1180474	Lingamguntapriyanka
ee1180475	Manish Lamba
ee1180476	Mayank Gautam
ee1180477	Mehtab Alam
ee1180478	Mrityunjay Gupta
ee1180479	Mukul Yadav
ee1180480	Naman Khandelwal
ee1180481	Neha Prajapat
ee1180482	Paritosh Singh
ee1180483	Penumudi Nagavenkata Saiabhina
ee1180484	Pranjal Rai
ee1180485	Pratik Deepakkedia
ee1180486	Preeti Saharan
ee1180487	Priyam Singh
ee1180488	Pulkit Jareda
ee1180489	Rahul Bhola
ee1180490	Rajveer
ee1180491	Ranajay Medya
ee1180492	Ritik Raj
ee1180493	Rocktim Jyoti Das
ee1180494	Rohit Agarwal
ee1180495	Sachin Jangir
ee1180496	Saksham Rastogi
ee1180497	Sanjeet Yadav
ee1180498	Satyam Bohra
ee1180499	Shashank Goyal
ee1180500	Shauryasikt Jena
ee1180501	Shivang Garde
ee1180502	Shuchi Singh
ee1180503	Siddharth Meghwal
ee1180504	Sourav Kumar
ee1180505	Spoorthi Kyasa
ee1180506	Subash Kumar
ee1180507	Suhani Jain
ee1180508	Tanvir Singh Bal
ee1180509	Tuhin Girinath
ee1180510	Tushar Bansal
ee1180511	Varun Bhavindesai
ee1180512	Venkata Siva Kiritigudimetla
ee1180513	Vijendra Kumarmeena
ee1180514	Vikas Kumar
ee1180515	Yash Garg
ee2110503	Abhishek
ee2110522	Ranabothu Rajashekar Reddy
ee2120515	Kshitiz Vijayvargiya
ee3130546	Akshay Karol
ee3130555	Kailash Chandra
ee3130571	Shivpal Chaudhary
ee3140503	Arun Kumar Meena
ee3140526	Pankaj Sanodiya
ee3150112	Moulik Choraria
ee3150121	Prakhar Agrawal
ee3150152	Akash Goyal
ee3150501	Aashish Bhorse
ee3150502	Abhay Singh
ee3150503	Abhishek Verma
ee3150505	Aditi Neema
ee3150506	Aditya Singhal
ee3150507	Aishwary Srivastava
ee3150508	Arpit Bankawat
ee3150509	Ayush Joshi
ee3150510	Ayushi Garg
ee3150511	Bir Singh
ee3150512	Chetan Kumar Harsoliya
ee3150513	Deepanshu Rathi
ee3150514	Digvijai Singh
ee3150515	Divya Charan
ee3150516	Divyansh Shukla
ee3150517	Harsh Maheshwari
ee3150518	Hunney Kotiya
ee3150520	Mahendra Meena
ee3150521	Mohammad Ali Khan
ee3150522	N Akash
ee3150523	Nimish Mangal
ee3150524	Nishant Kumar Sharma
ee3150525	Parikshit Payal
ee3150526	Piyush Barupal
ee3150528	Pranav Verma
ee3150529	Pranjal Gupta
ee3150530	Prashant Anand
ee3150531	Rakesh Kumar
ee3150532	Robin Bansal
ee3150533	Sachin Kumawat
ee3150535	Samarth Patil
ee3150536	Sangam Bharti
ee3150537	Sarthak Tyagi
ee3150538	Satish Kumar Gaurav
ee3150539	Shivam Shekhar Singh
ee3150540	Sughosh Modem
ee3150541	T Hoingaiching Haokip
ee3150542	Tanmay Thareja
ee3150543	Utkarsh Saxena
ee3150544	Vijay Shanker Dubey
ee3150649	Harsh Hemant Malara
ee3150750	Pradeep Kumar
ee3150761	Sanyam Gupta
ee3150898	Ishu Jain
ee3160042	Pragya Gupta
ee3160161	Aakriti Singh
ee3160220	Chinmaya Singh
ee3160240	Haneesh Aggarwal
ee3160246	Salil Chandra
ee3160490	Vaibhav Kalra
ee3160493	Mihir Kumar
ee3160494	Shivam Kumar
ee3160495	Kartik Mundra
ee3160496	Hardik Saluja
ee3160497	Vinayak Goyal
ee3160498	Akash Goyal
ee3160500	Geetika Mathur
ee3160501	Prafful Goyal
ee3160502	Naval Dubey
ee3160503	Rahul P Modpur
ee3160504	Piyush Nain
ee3160505	Harsh Jain
ee3160506	Mayank Mishra
ee3160507	Naman Upadhyaya
ee3160508	Chandrashekhar
ee3160509	Siddharth Kumar
ee3160510	Akhil Kajla
ee3160511	Akshat Agarwal
ee3160512	Shubham Jain
ee3160514	Koduru Sidharth
ee3160515	Aman Singh
ee3160516	Samarth Mohan
ee3160517	Jitendra Vishwakarma
ee3160518	Rachakonda Siddartha
ee3160519	Tarun Sahu
ee3160520	Burma Vaishnavi
ee3160521	Saujanya Chaudhary
ee3160522	Sonu Kumar
ee3160524	Rohit Krishnia
ee3160525	Aditya Varma
ee3160526	Milanjeet Singh Bhatti
ee3160527	Rahul Nimbal
ee3160528	Kundan Doiphode
ee3160529	Dalvi Snigdha Suresh
ee3160530	Kartik Hans
ee3160531	Harsh Jedia
ee3160532	Shweta Meena
ee3160533	Usman Hafiz
ee3160534	Vishnu Solanki
ee3160769	Mayank Khatri
ee3170010	Ishita Gupta
ee3170019	Rashi Pillania
ee3170149	Rushang Gupta
ee3170221	Naman Sitesh Maheshwari
ee3170245	Sakshi Gupta
ee3170511	Abhay Kumar
ee3170512	Abhinav Harsh
ee3170513	Aditya Gupta
ee3170514	Anshul Damesha
ee3170515	Anshul Gupta
ee3170516	Apurv Sankhyadhar
ee3170517	Arham Raees
ee3170518	Aseem Vidyadhar Patwardhan
ee3170519	Ashish Dharoba Gawale
ee3170522	Ashwani Choudhary
ee3170523	Bhavesh Tolia
ee3170524	Chapara Sagar
ee3170525	Dilkhush Sogan
ee3170526	Garvil Singhal
ee3170527	Gaurav Kumar
ee3170528	Hemant Kumar Jain
ee3170529	Himanshu Verma
ee3170531	Jatin Jain
ee3170532	Kajol Gehlot
ee3170533	Khandre Ramanand Kishanrao
ee3170534	Lakshya Agarwal
ee3170535	Lokesh Saini
ee3170537	Manish Kumar Yadav
ee3170538	Manisha Kuhar
ee3170539	Piyush
ee3170541	Prabhanshu Singh
ee3170542	Pradeep Choudhary
ee3170543	Prakhar Kanchan
ee3170545	Rishidev Prabhakar
ee3170546	Sarthak Garg
ee3170547	Sarthak Tomar
ee3170548	Ujjwal Agrawal
ee3170549	Umesh Meena
ee3170550	Utkarsh Tyagi
ee3170551	Varun Gupta
ee3170552	Vishal Kumar Dayma
ee3170553	Vishnu Saini
ee3170554	Vivek Meena
ee3170555	Yash Chandra
ee3170654	Apoorv Jain
ee3170872	Aagam Gupta
ee3180521	Aadarsh Kumarkyal
ee3180522	Aashish Choudhary
ee3180523	Abhinav Meena
ee3180524	Abhishek A Itagi
ee3180525	Adarsh Jain
ee3180526	Aditya Raj
ee3180527	Amokh Varma
ee3180528	Anjaria Dhruvnilang
ee3180529	Anubhav Dubey
ee3180530	Ashish Sharma
ee3180531	Asim Rajvanshi
ee3180532	Avi Sihag
ee3180533	Ayesha Kajol Rafi
ee3180534	Darpan Kumaryadav
ee3180535	Deepak Kumar
ee3180536	Deepankar Tiwari
ee3180537	Deepanshu Chawala
ee3180538	Dharmendra Seervi
ee3180539	Digvendra Singhtomar
ee3180540	Eashan Gupta
ee3180541	Grishma G
ee3180542	Harman Singh
ee3180543	Himanshu Gaud
ee3180544	Ishan Agrawal
ee3180545	Ishan Jain
ee3180546	Ishita Hans
ee3180547	Jayant Choudhary
ee3180548	Jeet Bansal
ee3180549	Kashish Arora
ee3180550	Koppula Avinash
ee3180551	Krishan Bansal
ee3180552	Kuldeep Bhardwaj
ee3180553	Kushagra Singhsaini
ee3180554	Mukul Singh
ee3180555	Pakhi Dahiya
ee3180556	Prashant Verma
ee3180557	Ravi Kumar
ee3180558	Reddy Cihir
ee3180559	Rithvik Iruganti
ee3180560	Rockson Th Rong
ee3180561	Sarthak Gupta
ee3180562	Saurabh Raj
ee3180563	Shivang Seth
ee3180564	Shresth Mehta
ee3180565	Siddhaant Priyam
ee3180566	Simran Rathore
ee3180567	Tanishq Gupta
ee3180568	Vineet Singhyadav
ee3180569	Yerukula Sravanasai
ee5110547	Gaurav Kalyan
ee5110550	Hemant Saharia
ee5110563	Siddharth Rajde
eea172232	Harshvardhan Siddharth
eea172233	Vinay Kumar Konanki
eea172664	Apeksha Tandon
eea172665	Surendra Pratap Yadav
eea182367	Shivam Kumar
eea182368	Rishabh Chauhan
eea182370	Shubham Thakur
eea182371	K S Santosh
eea182372	Jagdambika Prasad Srivastava
eea182375	Allu Sai Haneesh
eea182376	Satyam Singh
eea182377	Shatyajit Dutta
eea182378	Rahul Singh
eea182379	Neelesh Kumar Saini
eea182380	Rahul Yadav
eea182381	Kajol Bharti
eea182382	Rohit Rana
eea182726	Saurabh Kumar
eee172234	Mohammed Naveed Ashfaq
eee172235	Shubham Tewari
eee172236	Ayush Jain
eee172238	Snehal Shrikrushna Pagdhune
eee172239	Balakrishna Goud Ediga
eee172240	Reema Bharti
eee172241	Yashashvi Chand P
eee172246	Rakesh Goyal
eee172765	Ravinder Pratap Singh Rathore
eee172857	Dhiraj Bhandari
eee172871	Narendar Kumar
eee172872	Gurjant Singh
eee182106	Harshdeep Singh
eee182123	Manish Kumar
eee182386	Naga Jayanth P V
eee182388	Purbesh Mitra
eee182392	Sonali Rai
eee182393	Mohd Shamikh
eee182395	Amit Kumar Patel
eee182396	Prakash Singh
eee182398	Shubham Pramod Khedkar
eee182399	Ajay Bharti
eee182400	Deepak Meena
eee182401	Sunil Kumar
eee182402	Anirban Homroy
eee182403	Shivam Saxena
eee182870	Ashish Raheja
een172247	Ramyani Mukherjee
een172248	Vikash Kumar Garg
een172257	Vindeshvari Prasad Gupta
een172628	Anurag Nigam
een172668	Kaustubh Chandresh Dave
een172670	Gaurav Mittal
een172671	Gaurav Ganapati Kamalkar
een172672	Vishal Gangwar
een172687	Akash Gupta
een172838	Naga Rahul Yarramsetty
een172855	Divesh Meena
een182405	Sudeep Thakur
een182408	Chanchal Kumar
een182411	Viswesh
een182412	Srinu Katari
een182413	Sandeep Kaur
een182415	Katakam Krishna Vamsi
een182416	Mounika Kundurthi
een182418	Shishir Gautam
een182419	Divyank Kumar Singh
een182420	Pooja Agarwal
eep172258	Saurabh Shukla
eep172262	Himanshu Sharma
eep172265	Samiksha Rawat
eep172267	Meet Khandubhai Patel
eep172268	Gaurav Yadav
eep172674	Vishal Singh Gourav
eep172675	Peram Aditya Sai Suresh
eep172863	Ankit Gairola
eep172866	R V Pradish
eep182107	Shikhar Vinod Muley
eep182108	Narendra K Chaudhary
eep182488	Mohd Zameer
eep182542	Gaurav Kumar Singhal
eep182545	Shiva Upadhyay
eep182548	Siva Ramesh Vanapalli
eep182549	Shahrul
eep182551	Abhishek Ranjan
eep182552	Rajat Kumar Shit
eep182553	Kethavath Raju Naik
ees142858	Nishant Kukreti
ees162591	Kaushik Ramakant Panditrao
ees172281	Sayan Chakraborty
ees172287	Santosh Kumar
ees172288	Abhinav Srivastava
ees172289	Mohneesh Rastogi
ees172290	Gaurav Kumar
ees172677	Mudit Jain
ees182577	Ambuj Gupta
ees182579	Arup Anshuman
ees182580	Aayush Nautiyal
ees182582	Sirin Sanchay
ees182583	Karan Gupta
ees182584	Sangeetha B J
ees182585	Pulastya Pandey
ees182586	Abinash Sahoo
ees182587	Debanjan Dey
ees182589	Deepesh Yadav
ees182590	Satya Narayan Gunjal
ees182591	Ashish Kumar Yadav
ees182593	Anmol Deepak
ees182594	Aman Gautam
ees182596	Sandeep Yadav
ees182861	Arvind Kumar
eet162645	Sumeet Inani
eet162646	Shantanu
eet172291	Sakshi Agrawal
eet172292	Palakh Shangle
eet172294	Ishank Gupta
eet172295	Srijeet Chatterjee
eet172296	Ankit Gola
eet172297	Aravind J
eet172299	Anand Singh
eet172300	Ravi Shankar Singh
eet172302	Mansi Garg
eet172303	Harshit Gupta
eet172304	Hareesh Kumawat
eet172305	Priya Kumari
eet172306	Vishal Kumar
eet172307	Vinay Kyatham
eet172308	Wadood Ahmad Khan
eet172680	Pushpendra Singh Dahiya
eet172681	Prabhleen Kaur
eet172839	Varun Sood
eet172840	Ravi Singh Thakur
eet172841	Prateek Arora
eet172856	Vudathaneni Divya Narendra
eet172864	Zeel Patijkumar Shah
eet182554	Sah Swapnil Agrawal
eet182555	Abhay Gupta
eet182556	Devyani Agarwal
eet182557	Umang Agarwal
eet182559	Naina Mehta
eet182560	Asmita Nandkumar Patil
eet182561	Abhishek Bohra
eet182562	Churchill Hemraj Khangar
eet182563	Satyam Rohila
eet182564	Aditya Shubham
eet182565	Palash Baburao Dahiphale
eet182566	Deepak Kumar
eet182568	Nellimarla Hari Kiran
eet182569	Ajinkya Purushottam Wasnik
eet182570	Jeeban Kumar Sethi
eet182571	Lalith Kumar S
eet182572	Kshitij Dewanand Manwatkar
eet182574	Parveen Bajaj
eet182575	Ankit Sharma
eet182727	Siddharth Kumar
eet182865	Aghil Sabu
eey147524	Dipankar Ganguly
eey147536	Anmol Walia
eey147546	Komal Behl
eey157520	Abhishek Gupta
eey157538	Sushant Dave
eey157539	Ravi Kumar
eey157542	Arun Kumar Singh
eey157543	Muhammad Arif
eey157545	Parmeet Singh
eey167520	Manoj Singh Rathor
eey167521	Sakshi Arora
eey167523	Karthik M B
eey167538	Madhu Yadav
eey177527	Sidharth Kumar
eey177528	Jonaq Niveer Sarma
eey177529	Amit Patel
eey177531	Amit Kumar
eey177532	Ankita Saldhi
eey177537	Ayan Ray
eey177538	Md Ale Imran
eey177539	Vivek Kumar Mishra
eey177540	Bivin V B
eey177547	Saurabh Manglik
eey187523	Roopak Jain
eey187524	Chandan Kumar
eey187525	Shubham Negi
eey187526	Amit Kumar Kushwaha
eey187534	Vaibhav Nougain
eey187535	Shubham Choudhary
eey187536	Surisetti Naresh Ram
eey187537	Tanu Kanvar
eey187547	Niraj Kumar
eez118310	Pratibha Singh
eez118470	Shailesh Kumar
eez127508	Ramanjit Singh Ahuja
eez127509	Sumit Soman
eez127528	Gupta Ronak Purushottam
eez128127	Uttam Kumar Kumawat
eez128129	Kamal Kumar
eez128130	M Vetriselvi
eez128135	Khusro Khan
eez128137	Senthil Siva Subramanian
eez128139	Pramod Jhaldiyal
eez128142	Akhil Kumar Gupta
eez128292	Vargil Kumar Eate
eez128304	Geetanjali Srivastava
eez128307	B Amarendra Reddy
eez128355	Chandani Anand
eez128358	Satnesh Singh
eez128359	B Venkat
eez128361	Snigdha Rani Behera
eez128365	Kapil Jainwal
eez128367	Shyam Krishan Joshi
eez128368	Anurag Tripathi
eez128376	Neelima Singh
eez132812	Jaspreet Singh
eez132826	Vijit Gadi
eez132864	Shadab Murshid
eez137515	Dushyant Sharma
eez138241	Amandeep Kaur
eez138244	Deepak Mishra
eez138245	Joyjit Mukherjee
eez138261	B Bhuvan
eez138262	Deepika Vatsa
eez138285	Ashish Kumar Jain
eez138286	Farah Jamal Ansari
eez138522	Archit Joshi
eez138524	Himanshu Pant
eez138525	Indrani Bhattacherjee
eez138528	Nidhi Mishra
eez138529	Niraj Choudhary
eez138531	Poonam
eez138532	Rajinder Singh Deol
eez138534	Sharda Tripathi
eez138594	Rahul Pandey
eez138595	Sunil Kumar Pandey
eez142368	Mayank Sharma
eez147538	Nidhi Dua
eez148066	Amit Agarwal
eez148067	Aniket Anand
eez148068	Atul Thakur
eez148073	Kush Khanna
eez148074	Nitin K Lohar
eez148076	Priyadarshi Mukherjee
eez148077	Richa Sharma
eez148078	Sathiyanarayanan Thiruvazhmarbhan
eez148079	Shruti Sharma
eez148080	Sirin Duttachowdhury
eez148081	Soumya Prakash Dash
eez148083	Sreejith R
eez148084	Swatilekha Majumdar
eez148246	Siddharth Panwar
eez148297	Aakash Kumar Jain
eez148299	Anshul Varshney
eez148300	Anuradha Tomar
eez148305	Manohar Kumar Parvatini
eez148306	Nishant Kumar
eez148307	Nitika Batra
eez148309	Prasun Mishra
eez148310	Ramendra Singh
eez148312	Sanjoy Kumar Dey
eez148313	Saurabh Shukla
eez148314	Shatakshi
eez148316	Somnath Pal
eez148420	Ajay Kumar Agrawal
eez148421	Sandeep Joshi
eez152480	Snigdha Bhagat
eez152507	Priyank Mukeshkumar Shah
eez152511	Vedantham Lakshmi Srinivas
eez152675	Aashi Jindal
eez152691	Prashant Gupta
eez157540	Prakriti Saxena
eez157544	Piyush Kaul
eez158067	Abdul Saleem Mir
eez158068	Abhijit Kumar Das
eez158069	Abhishek Gagneja
eez158070	Abhishek Dhar
eez158071	Akshita Mishra
eez158073	Ananya Roy
eez158074	Anjanee Kumar Mishra
eez158075	Anshul Jaiswal
eez158076	Anshul Thakur
eez158078	Athul Thomas Tharakan
eez158079	Ayesha Firdaus
eez158080	Brijesh Chander Pandey
eez158081	Chetan Sudarshan Ralekar
eez158082	Jyoti Prakash
eez158083	Kapil Shukla
eez158086	Nikhil Kumar
eez158089	Piyush Kant
eez158090	Pradyumna Ranjan Ghosh
eez158091	Radha Kushwaha
eez158093	Rajib Ratan Ghosh
eez158094	Rajiv Jha
eez158095	Rishi Kant Sharma
eez158096	Saptarshi Ghosh
eez158097	Sasi Vinay Pechetti
eez158098	Sayari Das
eez158099	Seema
eez158100	Shailendra Kumar
eez158101	Shifali Kalra
eez158102	Shivraman Mudaliyar
eez158103	Shrikant Mohan Misal
eez158105	Sonam Jain
eez158108	Sudipta Saha
eez158110	Sweta Agarwal
eez158112	Tripurari Nath Gupta
eez158113	Usham Viviano Dias
eez158114	Vandana Jain
eez158115	Varun Chitransh
eez158116	Vasudha Agrawal
eez158117	Vinay Kaushik
eez158295	Maniar Mudassir Azizahmed
eez158307	Uzma Khan
eez158308	Bodhibrata Mukhopadhyay
eez158395	Abhilash Patel
eez158396	Soumyadip Banerjee
eez158397	Suraj Suman
eez158399	Rachit Mahendra
eez158400	Meenakshi
eez158401	Richa Priyadarshani
eez158402	Rakhi Sharma
eez158403	Deepu Vijay M
eez158404	Priyabrata Shaw
eez158406	Punit Kumar
eez158407	Gurmeet Singh
eez158408	Surya Prakash
eez158409	Subarni Pradhan
eez158410	Shruti Ranjan
eez158411	Priya Vinayak
eez158412	Athar Kamal
eez158414	Anjeet Kumar Verma
eez158415	Sidharth Gautam
eez158416	Kamal Biswas
eez158417	Ambuj Sharma
eez158418	Nitin Gupta
eez158419	Jobin Wilson
eez158420	Ranjan Dasgupta
eez158421	Debanjan Konar
eez158424	Arun Kumar Choudhary
eez158425	Merajus Salekin
eez158426	Balaji Mukkapati
eez158427	Pankaj Kumar Das
eez158458	Shiva Azimi
eez158485	Uferah Maqbool
eez158486	Tabish Nazir Mir
eez168057	Megha Gupta
eez168058	Farheen Chishti
eez168059	Shaziya Rasheed
eez168060	Rubi Rana
eez168062	Ankit Bharaj
eez168063	Debasish Mishra
eez168064	Utkarsh Sharma
eez168065	Khushboo Kumari
eez168066	Manishika Rawat
eez168067	Vini Gupta
eez168068	Mayukh Roychowdhury
eez168069	Rishu Raj
eez168070	Sandeep Kaur Kingra
eez168072	Arunava Banerjee
eez168073	Syed Muhammad Amrr
eez168075	Sonali
eez168076	Rijul Saurabh Soans
eez168077	T R Aashish
eez168078	Neha Priyadarshini
eez168079	Chimmula Kishore
eez168080	Tabia Ahmad
eez168081	Munesh Kumar Singh
eez168082	Dileep Bapatla
eez168084	Sambasivaiah Puchalapalli
eez168086	Kritika Aditya
eez168087	Pavitra Shukl
eez168088	Rahul Sharma
eez168089	Kaleem Ahmed
eez168090	Rahul Kumar Singh
eez168332	Shubhra
eez168337	Rohini Sharma
eez168338	Thoudam Viman Prakash Singh
eez168339	Charu Gupta
eez168340	Kshitiza Singh
eez168349	Anshul Gupta
eez168482	Bishshoy Das
eez168484	Keerthi Chacko
eez168485	Rajasree Sarkar
eez168486	Sujeet Kumar
eez168487	Ayan Kumar Dutta
eez168488	Ankit
eez168489	Himanshu Pramod Padole
eez168490	Dhiman Das
eez168491	Pankaj Dilip Achlerkar
eez168492	Martin Cheerangal J
eez168494	Vasudha Khubchandani
eez168495	Devesh Malviya
eez168496	Upasana Sahu
eez168497	Eswaravenkatakumar Dhulipala
eez168498	Milton Mondal
eez168501	Mohd Kashif
eez168502	Rashmi Rai
eez168503	Hina Parveen
eez168504	Yalavarthi Amarnath
eez168505	Aryadip Sen
eez168506	Amit Kadian
eez168510	Nishit Narang
eez168512	Digambar Singh
eez178153	Attoti Bharath Krishna
eez178154	Cheshta Jain
eez178155	Debargha Brahma
eez178156	Nidhi Bisht
eez178157	Yashi Singh
eez178159	Vibhuti Nougain
eez178163	Parul
eez178164	Astha Chawla
eez178165	Arpan Malkhandi
eez178166	Utsav Sharma
eez178167	Supriya Chakraborty
eez178168	Kritika Bhattacharya
eez178169	Sonam Jain
eez178170	Divya Kaushik
eez178171	Chandan Kumar Jha
eez178172	Deepika Kumari
eez178173	Venkatesh Khammammetti
eez178174	Jinu Jayachandran
eez178175	Midhun T Augustine
eez178177	Shipra Madan
eez178178	Jitendra Gupta
eez178179	Santosh Kumari
eez178180	Parvez Akhtar
eez178181	Imran Ahmad
eez178182	Md Samim Reza
eez178183	Amita Giri
eez178184	Prateek
eez178185	Sarita
eez178187	Himanshu Swami
eez178188	Souvik Das
eez178189	Sudip Bhattacharyya
eez178190	Sandeep Kumar Sahoo
eez178191	Syedbilal Qaiser Naqvi
eez178192	Gaurav Modi
eez178193	Shalvi Tyagi
eez178195	Rumysa Manzoor
eez178197	Kamal Agrawal
eez178198	Gaurav Musalgaonkar
eez178200	Ebin Cherian Mathew
eez178201	Abhishek Nayak
eez178203	Umesh Chandra Lohani
eez178204	Gaurav Saraswat
eez178206	Saurabh Inamdar
eez178207	Arihant Jain
eez178208	Sant Prasad Mishra
eez178370	Melaku Matewos Hailemariam
eez178416	Atul Katiyar
eez178555	Rajdip Debnath
eez178556	Pratiti Paul
eez178559	Pushpendra Yadav
eez178560	Shefali Gupta
eez178561	Manoj Kumar
eez178562	Apurba Das
eez178563	Manish Khanduri
eez178564	Dipta Chaudhuri
eez178565	Priyvrat Vats
eez178566	Suri Rama Naga Praneeth
eez178567	Vivek Narayanan
eez178568	Saran Chaurasiya
eez178569	Navneet Kaur
eez178570	Arpit Kumar Vijayvergia
eez178571	Subir Karmakar
eez178573	Manoj Sharma
eez178653	Sayandev Ghosh
eez178655	Mangesh Jaiswal
eez178656	Abhilash Garg
eez188126	Manas Ranjan Mishra
eez188127	Samridhi Sajwan
eez188128	Pushpa Kumari
eez188129	Aamir Rafiq
eez188130	Debi Prasad Nayak
eez188131	Apurva Verma
eez188132	Pranjali Shukla
eez188133	Bhabani Shankar Dey
eez188134	Soumen Manna
eez188135	Pritesh Patel
eez188137	Chanchal Goyal
eez188138	Shubham Saxena
eez188139	Vikram Maharshi
eez188140	Pranav Sharda
eez188141	Anand Jee
eez188142	Survi Kumari
eez188143	Sonal Gupta
eez188144	Sakshi Ahuja
eez188145	Manish Kumar
eez188146	Malay Ranjan Khuntia
eez188147	Shivam Kumar Yadav
eez188148	Deepak Saw
eez188149	Yakala Ravi Kumar
eez188150	Kousalya V
eez188151	Satish Kumar Verma
eez188152	Abhinay Kewalchand Pardeshi
eez188153	Vivek Chaudhary
eez188154	Sanjenbam Chandrakala Devi
eez188155	Nisha Parveen
eez188156	Partik Kumar
eez188157	Meenakshi Khandelwal
eez188158	Ajay Singh
eez188160	Sharankumar Shastri
eez188161	Vivek Kamalkant Parmar
eez188162	Maninder Kaur
eez188163	Ahmed Shaban
eez188164	Anjali Gupta
eez188165	Saikat Mukherjee
eez188166	Imran Ali Khan
eez188168	Mohammad Junaid
eez188169	Saurabh Mishra
eez188170	Manish Tikyani
eez188171	Amit Kumar Pathak
eez188172	Smriti Sachdev
eez188293	Diptak Pal
eez188377	Ankit Kumar Thalor
eez188384	Vivek Asthana
eez188552	A Devakumar
eez188553	Akash Kumar Mandal
eez188554	Aarti Rathi
eez188555	Afzal Amanullah
eez188556	Anurag Sharma
eez188557	Arkabrata Dattaroy
eez188558	Jaideep
eez188559	Kalyan Dash
eez188560	Kedar Dipak Mejari
eez188561	Kripa Tiwari
eez188562	Kritika Lohia
eez188563	Mayank Gupta
eez188564	Meera Patel
eez188565	Mohd Khalid
eez188566	Muhammad Zarkab Farooqi
eez188567	Nadeem Tariq Beigh
eez188569	Nitin Gupta
eez188570	Rajveer Dhawan
eez188571	Rohit Kumar
eez188572	Saurabh Prakash
eez188573	Suravi Thakur
eez188574	Suvom Roy
eez188575	Ubaid Bashir Qureshi
eez188576	Utkarsh Kumar
eez188577	Vaibhav Vijaykumar Fere
eez188578	Vipin Kumar Singh
esz118381	G P Sai Pranith
esz128088	Sunitha Anup
esz128092	Sunil Indora
esz128094	Jatinder Singh Chandok
esz128300	Jitendra Kumar
esz128338	Poonam Joshi
esz128428	Seema Behera
esz128434	Sukhwinderjeet Singh Bhatti
esz128563	Isha
esz138129	Arunkumar V
esz138136	Swati Bhamu
esz142643	S Sai Saran Yagnamurthy
esz148090	Kuldeep Kumar
esz148091	Neha Pathak
esz148094	Sapna Mudgal
esz148095	Soumya Das
esz148252	Heena Fatima Ali
esz148255	Gourav Kumar Mishra
esz148430	Sugandha Singh
esz158123	Vipin Dhyani
esz158390	Krishna Singh
esz158391	Rajat Saxena
esz158392	Neha Dimri
esz158393	Lokesh Kumar Panwar
esz158394	Tarun Kumar Aseri
esz158483	Hoor Fatima
esz168011	Rupinder Pal Singh
esz168097	Priyanka Chhillar
esz168098	Sumedha Sharma
esz168100	Bhanu Pratap Dhamaniya
esz168102	Mohd Alam
esz168103	Sakthivel P
esz168413	Mrutyunjay Nayak
esz168414	Sobia Waheed
esz168415	Himanshu Grover
esz168417	Kanwar Pal
esz168577	Gopal Krishan Taneja
esz178209	Shweta Sharma
esz178210	Mahreen
esz178211	Saurabh Pareek
esz178212	Anish Malan
esz178214	Pranaynil Saikia
esz178215	Himanshu
esz178216	Abhishek Verma
esz178217	Tulja Bhavani Korukonda
esz178218	Anilkumar Ramesh Shere
esz178538	Sana Fatima Ali
esz178539	Ashutosh Pandey
esz178540	Punit Sharma
esz178541	Sandeep Kumar Singh
esz178542	Bakul Kandpal
esz178543	Ram Kumar Pal
esz178544	Manish Kumar Yadav
esz178546	Rahul Virmani
esz178657	Himani
esz188054	Sumeet Kumar Dubey
esz188055	Amit Kumar
esz188056	Bevin K C
esz188513	A Akhil
esz188514	Akshey Marwaha
esz188515	Indraj Singh
esz188516	Kartiki Ganesh Chandratre
esz188517	Neha Tak
esz188518	Sanchayan Mahato
esz188661	Abhijeet Anand
huz128471	Robin Ej
huz128473	Jayesh Mp
huz128478	Ankur Betageri
huz138139	Amit Anurag
huz138140	Lalita
huz138143	Neha Gupta
huz138544	Saliha Shah
huz138593	Mahendra Shahare
huz148151	Kanhu Charan Pradhan
huz148152	Kushbeen Kaur Sohi
huz148155	Priyanka Verma
huz148156	Radha Raghavendra Ashrit
huz148157	Rituparna Sengupta
huz148160	Usha Rao
huz148161	Vandita Sahay
huz148322	Chavi Asrani
huz148323	Chinju Johny
huz148325	Manujata
huz148326	Mriganka Sekhar Sarma
huz148328	Siddharth Sahney
huz158124	Asmita Verma
huz158125	Deeksha Tayal
huz158126	Ekta Pandey
huz158128	Nitin Saluja
huz158129	R Ahalya
huz158130	Ravi Sekhar Chakraborty
huz158132	Ruhi Sonal
huz158133	Rupali Bansode
huz158134	Shambhovi Mitra
huz158283	Geeta Mishra
huz158286	Latheesh Mohan V
huz158287	Rajiv
huz158459	Swayamshree Mishra
huz158460	Aatina Nasir Malik
huz158461	Charumita Vasudev
huz158462	Shikha Vats
huz158463	Navjot Kaur Bedi
huz158464	Satheesha B
huz158465	Anand Prakash
huz158466	Nimisha Pandey
huz158467	Vishesh Pratap Gurjar
huz158468	Apurva
huz158470	Ruby Aikat (Nee Mitra)
huz158505	Aarushi Punia
huz168170	Diti Goswami
huz168171	Neha
huz168172	Angarika Rakshit
huz168173	Rituparna Kaushik
huz168174	Taniya Sah
huz168175	Neaketa Chawla
huz168176	Garima Rajan
huz168177	Nandini Kalita
huz168178	Sandip Debnath
huz168180	Satanik Pal
huz168181	Suchismita Das
huz168182	Benu Verma
huz168183	Muhamed Riyaz
huz168184	Sumita Sharma
huz168256	Prakriti Joshi
huz168257	Jatin Sharma
huz168258	Nazia Amin
huz168323	Alan Stanley
huz168528	Debottam Saha
huz168529	Nandan Sebastian Rosario
huz168531	Abhigya
huz168532	Neisetuonuo Tep
huz168533	Alok Tiwari
huz168534	Prasad Vsn Tallapragada
huz168535	Parul Gupta
huz178130	Sania Ismailee
huz178131	Rashmi Jayarajan
huz178134	Wasim Odud
huz178136	Fariya Yesmin
huz178138	Suryodaya Sharma
huz178142	Bharat Hun
huz178144	Jyotirmay Das
huz178145	Minakshee Jagannath Rode
huz178146	Vanlalhmangaiha
huz178147	Sumallya Mukhopadhyay
huz178150	Neha Singh
huz178151	Sneha Sharma
huz178585	Nishtha Bharti
huz178587	Priya Chetri
huz178588	Jose Jacob
huz178590	Susan R Haris
huz178591	Ankita Verma
huz178592	Smriti Parsheera
huz178593	Sidhartha Vermani
huz178661	Sayantani Banerjee
huz188103	Krishan Chaursiya
huz188104	Chandni Dutta
huz188106	Shubham Solanki
huz188107	Mohana Mukhopadhyay
huz188108	Pallavi Ramanathan
huz188109	Kirti Tyagi
huz188110	Saniya Bhutani
huz188112	Sanam Khanna
huz188113	Shyista Aamir Khan
huz188114	Maguipuinamei Rejoyson Thangal
huz188619	Abdullah A Rahman
huz188620	Ajay Thomas
huz188623	Ouroz Khan
huz188624	Prerna Khanna
huz188626	Shobhna Jha
huz188627	Sidharth Goyal
huz188628	Sneha John
huz188629	Vineeta
huz188630	Yamit Kashyap
idz128121	Dali Ramu Burada
idz138151	Jitesh K Khatri
idz138152	Kamal K Pant
idz148007	Vinod Mishra
idz148183	Jyotish Kumar
idz148184	Lalit Mohan Pant
idz148185	Sunny Bairisal
idz156003	Abhishek Dahiya
idz158477	Yuvaraj Tp
idz168476	Kanika Jolly
idz168478	Sachin Tanwar
idz168479	Surbhi Pratap
idz168480	Vivek Rastogi
idz178095	Deblina Sabui
idz178632	Md Amir
idz178633	Ritambhara Thakur
idz188306	Vimarsh Awasthi
itz128034	Swati Gautam
itz148189	Surojit Poddar
itz148404	Jitendra Narayan Panda
itz158140	Bansidhar Gouda
itz158141	Niharika Gupta
itz168318	Umesh Nivrutti Marathe
itz168319	Manish Raj
itz168560	Meghashree Padhan
itz178001	Vinay Saini
itz178002	Harprabhjot Singh
itz178003	Navnath Ramchandra Kalel
itz178004	Ajay Pratapsingh Lodhi
itz178429	Avi Gupta
itz188283	Bhaskaranand Bhatt
itz188373	Chauhan Vanvirsinh Jagatsinh
itz188548	Bharat Kumar
itz188549	Tauheed Mian
jds176001	Eesha Shyam Deshpande
jds176002	Sushant Mallikarjun Patil
jds176003	Soamyata Sharma
jds176004	Rituparna Guha
jds176006	Saajan Tikare
jds176008	Amya Rai
jds176009	Gauri Prashant Chincholkar
jds176010	Anal Ashok Bangre
jds176011	Kalpana Mukundraj Nagpure
jds176012	Amit Kumar
jds176013	Niraj Kumar
jds176014	Karan Mashta
jds176015	Kumari Nidhi
jds176016	Rahul Kunwar
jds176018	Prasenjit Boro
jds186001	Pauline Mariam John
jds186002	Deeksha Gupta
jds186003	Anoushka Saha
jds186004	Vipul Upadhyay
jds186005	Anantha Kashyap
jds186006	Priyanka Rai
jds186007	Vijeyata Ojha
jds186008	Yash Bohre
jds186009	Prankur Kataria
jds186010	Ganesh Ram Sundararaman
jds186011	Vishal Verma
jds186012	Vivekarasan Mutharasan
jds186013	Pankhil Shaileshbhai Rathod
jds186014	Prakhar Verma
jds186015	Kaushik
jds186016	Anand S
jds186017	Swati Katariya
jds186018	Iman Baidya
jds186019	Zothanzuala
jds186020	Kinshuk Anurag Kujur
jes162142	Abhishek Verma
jes172168	Subhash
jes172169	Prerna
jes172170	Diksha Kumari
jes172173	Anurag Chandelia
jes172174	Ashima Verma
jes172181	Evaneet Kaur
jes172183	Ashish Kumar
jes172184	Gurparsad Singh Bagga
jes172185	Ankur Mittal
jes172629	Jay Ojha
jes182597	Adwait Makarand Karkare
jes182599	Vishal Srivastava
jes182600	Sourabh Sanjeev Patil
jes182602	Aasheesh Jha
jes182604	Aditya Deonath Singh
jes182605	Sripathi Anirudh R
jes182606	Anshuman Singh
jes182607	Kirtankumar Bhaveshbhai Patel
jes182608	Anish Tuteja
jes182609	Rishikesh Badagaiyan
jes182613	Sushant Kumar
jes182614	Aquib Faiyaz
jes182615	Deepak Prasad
jes182616	Abhinav Prajapati
jes182617	Yogesh Vishwakarma
jes182618	Manish Kumar
jes182621	Priyam Guria
jes182622	Divya Das
jes182624	Anshika
jes182625	Samiksha Sen
jes182627	Shishir Srivastava
jes182679	Vaishali
jid172537	Sriji S
jid172539	Arvind Kumar Gupta
jid172542	Narendra Singh Yadav
jid172545	Rohit
jid172761	Prateek Mishra
jid172764	Seema Sheokand
jid182455	Preeti Kingrani
jid182456	Srishti
jid182457	Siddharth Vardhan Pratihast
jid182459	Kintali Kalyankumar
jid182460	Shubham
jid182461	Arju Shah
jid182462	Prateek Maheshwari
jid182463	Gurram Karthikeya Sarma
jid182464	Shweta Rani
jid182465	Chalapaka Raja Neehar
jid182466	Prashant Kumar
jid182467	V Ajeeth Suryash
jid182468	Ashish Kumar
jid182469	Dheeraj Kumar Bairwa
jid182470	Anuhya M
jid182471	Lokendra Singh Tomar
jit172122	Shubham Srivastava
jit172123	Pratik Rai
jit172127	Parvinder Kumar
jit172128	Sandeep Singh
jit172129	Neeraj Yadav
jit172131	Amol Kailas Shelke
jit172134	Deepesh Kumar Gautam
jit172135	Shijin S Varghese
jit172663	Savtanter Saini
jit172782	Shubham Saini
jit172783	Avinash Kumar Maddhesiya
jit172784	Ritesh Kumar
jit182103	Vikas Singh
jit182104	Raghavendra P Solanki
jit182315	Sarthak Mittal
jit182316	Akash Sharma
jit182317	Rishabh Srivastava
jit182318	Vikas Kumar Singh
jit182319	Priyansh Singh
jit182320	Aashish Kumar Patwari
jit182321	Diwakar Singh
jit182322	Suyash Ameta
jit182323	Ravi Shankar
jit182325	Rajat Gangadharan
jit182326	Arun Pratap Singh
jit182327	Prafulla Chaudhary
jop162446	Shaive Sharma
jop172313	Amritanjan Kumar
jop172314	Sonu Jaiswal
jop172622	Ankit Kumar Mishra
jop172623	Vaibhav Arora
jop172624	Pramod Kumar Mishra
jop172625	Shiwani
jop172626	Vivek Kumar
jop172627	Bhawani Singh Rathore
jop172679	Sumeet Bhardwaj
jop172833	Ravi Kant Pandey
jop172843	Priyanshu Mishra
jop172844	Sameeksha Varshney
jop172845	Arvind Kumar
jop172846	Vipul Kumar Yadav
jop172860	Deepti Jain
jop182037	Mandeep Singh Dilawri
jop182090	Rahul Tomar
jop182091	Kabir Kohli
jop182444	Souvaraj De
jop182445	Kumud Jindal
jop182448	Sandeepkumar C K
jop182449	Adarsh Chouhan
jop182450	Gajendra Singh Yadav
jop182451	Sudhanshu Ranjan
jop182452	Deepanshu Sagar
jop182453	Anoop Mohan Maurya
jop182454	Raj Kumar Meena
jop182710	Sachin Kumar
jop182711	Pooja Singh
jop182712	Animesh Raj
jop182819	Zaheer Hassan Siddiqui
jop182841	Arti Yadav
jop182842	Narender Lamba
jop182860	Radhakant Singh
jop182866	Priyabrata Mallick
jop182871	Atul Menon
jop182877	Syed Mohammad Sibtain Haider
jop182880	Vikas Goswami
jpt172603	Shubhendra Singh
jpt172604	Harshit Jain
jpt172606	Sumit Kumar Gupta
jpt172607	Omair Malik
jpt172609	Shushil Kumar Gope
jpt172610	Akanksha Patel
jpt172611	Laxmi
jpt172612	Gopal Kumar Gautam
jpt172613	Shasanka Sekhar Behera
jpt172615	Ankit Mishra
jpt172616	Pramit Dutta
jpt172617	Pratik Pradeep Rane
jpt172618	Divyanshu Mishra
jpt172684	Shelly Walia
jpt182472	Tanmay Kant Tiwari
jpt182473	Vinay Kumar Pandey
jpt182474	Souma Jyoti Ghosh
jpt182475	Chhavi Gupta
jpt182476	Desh Deepak Singh
jpt182477	Sushant
jpt182478	Varun Anandkumar Pande
jpt182479	Partha Chowdhury
jpt182480	Amit Patel
jpt182481	Priyanka Sukhdeorao Channe
jpt182482	Manjeeta
jpt182484	Rahul Singh
jpt182485	Sandeep Kumar
jpt182486	Shiva Naresh
jpt182487	Ajay Kumar
jtm162084	Mahendra Pratapsingh Bhadoria
jtm172019	Mohit Varshney
jtm172021	Ankita Gupta
jtm172022	Ghanendra Singh
jtm172023	Vaibhav Nigam
jtm172186	Sujeet Mandloi
jtm172187	Bhawna Kamra
jtm172767	Shefali Gupta
jtm172768	Induru Sunil Reddy
jtm172769	Ankit Dixit
jtm182002	Shivaji Roy
jtm182003	Pooja Jharwal
jtm182004	Anshuman Singh
jtm182243	Devendra Khatri
jtm182244	Putlur Hithesh Reddy
jtm182245	Neha Sharma
jtm182246	Rahul Girotra
jtm182247	Priyanshu Aggarwal
jtm182248	Pardhi Chandan Waman
jtm182249	Pulkit Arora
jtm182250	Kartik Gupta
jtm182251	Amit Ranjan
jtm182772	Shubham Garg
jtm182774	Shivam Gupta
jtm182775	Manas Ranjan Patro
jvl172502	Saurabh Mathur
jvl172503	Srishti Gupta
jvl172504	Sharij Kumar
jvl172505	Karan Goyal
jvl172507	Shashank Varshney
jvl172508	Vijay Sharma
jvl172509	Deep Narula
jvl172570	Akashdeep Singh
jvl182330	Manasi Pradip Keluskar
jvl182331	Shubham Paliwal
jvl182332	Prabaldeep Dhawan
jvl182333	Varun Upadhyaya
jvl182335	Swapnil Raj Srivastava
jvl182336	Ayushi Garg
jvl182337	Nitin Bisht
jvl182338	Manshu Bishnoi
jvl182339	Avee Kumar
jvl182340	Amit Kumar
jvl182341	Hemasai Kumar P
jvl182343	Shashi Shankar Thakur
jvl182344	Aditi Gupta
mas157092	Rajendra
mas167062	Sandeep Kumar Kaushik
mas167104	Mahenoor Ali
mas177061	Aayushi Chaudhary
mas177062	Abhinav Kumar
mas177063	Adarsh Anand
mas177064	Aishwarya Maheshwari
mas177065	Akhil Niranjan Singh
mas177067	Alka Singh
mas177068	Amit
mas177069	Amit
mas177070	Anshul Prajapati
mas177071	Arvind Kumar
mas177072	Ashish Kumar
mas177073	Avanish Kumar
mas177074	Chandu Hareshbhai Bhabhalubhai
mas177075	Debasish Pradhan
mas177076	Deepak Kumar
mas177077	Dhruv Goel
mas177078	Divya
mas177080	Gunjan Rani
mas177081	Harish Kumar Nagar
mas177082	Harshita Puri
mas177083	Himanshu Tiwari
mas177084	Jaya Sharma
mas177085	Kuldeep Singh
mas177086	Mahendra Yadav
mas177087	Manif Alam
mas177089	Monu Jangid
mas177090	Pankaj
mas177091	Parveen Kumar
mas177092	Parvind Kumar
mas177094	Pravesh Kumar
mas177095	Premraj Meena
mas177096	Priyanka Verma
mas177097	Rahul Meena
mas177098	Rajkumari Joshi
mas177099	Ram Kumar Dhaka
mas177100	Ritik Soni
mas177101	Ritika Singhal
mas177102	Sachin
mas177103	Sakshi Tiwari
mas177104	Sheena Kansal
mas177105	Sheena Saini
mas177106	Shobhit Gautam
mas177107	Shubham Kumar Meena
mas177108	Tarun Kumar
mas177109	Upendra Meena
mas177110	V Varagapriya
mas177111	Varshiki Jethwani
mas177113	Vikash Yadav
mas177114	Yash Arora
mas187057	Adesh Dahiya
mas187058	Ajeet Kumar Ram
mas187059	Anju Rani
mas187061	Anshul
mas187062	Aruna
mas187063	Ashwini Kumar
mas187064	Babu Lal Choudhary
mas187065	Baby Gill
mas187066	Badri Vishal Singh
mas187067	Bhawna
mas187068	Charan Kumar
mas187069	Dhameliya Avinash Vinubhai
mas187070	Diksha Gupta
mas187073	Govind Meena
mas187074	Gulashan Kumar
mas187075	Gurubachan
mas187076	Himanshu Yadav
mas187077	Hrit Roy
mas187078	Kanupriya
mas187079	Keshav
mas187080	Komal Lawat
mas187081	Krishna Gopal Yadav
mas187082	Lalit Mohan
mas187083	Manish Kadela
mas187084	Nasheed Jafri
mas187085	Naveen Gupta
mas187086	Nikhil Chanauria
mas187087	Nikke Chejara
mas187089	Nitish Kumar
mas187090	Omprakash Bairwa
mas187091	Pankaj Kumawat
mas187092	Paramhans Kushwaha
mas187093	Parimal Kumar Sah
mas187095	Priyanka
mas187096	Priyanka Gupta
mas187097	Pulkit Mandowara
mas187098	Santosh Kumar Sharma
mas187099	Sarda Amar Gopalkrushna
mas187100	Shanti Lal Suthar
mas187101	Sujata Singh
mas187102	Sunil Kumar Payal
mas187103	Taruna Garg
mas187104	Tushar Singh
mas187105	Utsav Kumar Singh
mas187106	Vanshika
mas187107	Ved Prakash Mishra
mas187109	Vikas Singh
mas187110	Vivek Meena
maz118459	Yogesh Kumar
maz128519	Anuj Kumar
maz138158	Pooja Punyani
maz138162	Srashti Dwivedi
maz138546	Abhay Kumar Chaturvedi
maz148096	Ankita Shukla
maz148099	Shaily Verma
maz148101	Vishvesh Kumar
maz148330	Abhilash Sahu
maz148331	Anubha Goel
maz148333	Nidhika Yadav
maz148334	Pooja Bansal
maz148335	Rajashekar Naraveni
maz148336	Suchismita Patra
maz158142	Dileep Kumar
maz158144	Kartikay Gupta
maz158146	Nitu Sharma
maz158149	Ruchika Sehgal
maz158374	Rattan Lal
maz158375	Manoj Kumar
maz168186	Divya Goel
maz168187	Lipsy
maz168189	Juhi Chaudhary
maz168190	Aman Rani
maz168351	Saurabh Verma
maz178295	Pooja Goyal
maz178296	Raksha Agarwal
maz178297	Deepak Kumar
maz178298	Vaibhav Mehandiratta
maz178300	Abhishek Kumar Singh
maz178301	Sandeep Malik
maz178303	Navnit Kumar Yadav
maz178304	Manoj Kumar
maz178305	Archna Kumari
maz178306	Surbhi
maz178307	Hariom
maz178310	Priyamvada
maz178311	Sanjay Kumar
maz178432	Abhishek Kumar Singh
maz178433	Pooja
maz178434	Dhiraj Patel
maz178436	Soniya Takshak
maz178437	Nitin Kumar
maz188235	Edgar Federico Elizeche Armoa
maz188253	Neha Arora
maz188254	Kshitij Kumar Pandey
maz188255	Ritesh Singla
maz188258	Abhinay Kumar Gupta
maz188259	Vidya Sagar
maz188260	Mohit Kumar Baghel
maz188315	Sakshi Gupta
maz188443	Aakash Choudhary
maz188444	Amit Arora
maz188445	Anisha
maz188446	Divay
maz188447	Himanshu Sharma
maz188448	Jyotsna Sharma
maz188449	Manisha Binjola
maz188450	Manuj Verma
maz188451	Santosh Kumar Nayak
maz188452	Tanvi
mcs172071	Deepak Sharma
mcs172072	Samir Vyas
mcs172074	Harish Chandra Thuwal
mcs172075	Drona Pratap Chandu
mcs172076	Shadab Zafar
mcs172077	Manikaran Kathuria
mcs172078	Sruti Goyal
mcs172079	Debanjan Ghatak
mcs172080	Sushant Sharad Gokhale
mcs172082	Jyoti
mcs172084	Khushboo Goel
mcs172085	Pratham Bhavikkumar Shah
mcs172087	Pratibha
mcs172089	Nichit Bodhak Goel
mcs172092	Rakesh Raushan
mcs172093	Mahima Manik
mcs172094	Sravan Verma
mcs172095	Priya Kumari
mcs172101	Tuhina Verma
mcs172102	Chrystle Myrna Lobo
mcs172103	Saurav Kumar
mcs172104	Gaurav Raghav
mcs172105	Shradha Holani
mcs172525	Chak Fai Yuen
mcs172678	Arundeep Gupta
mcs172693	Shubham Jain
mcs172758	Gurjeet Singh Khanuja
mcs172832	Shyam Bihari Tripathi
mcs172847	Sandeep Kumar Singh
mcs172851	Aashish Joon
mcs172858	Siddharth Chhikara
mcs172873	Dibyajyoti Goswami
mcs182007	Jasbir Singh
mcs182009	Aditya Mishra
mcs182011	Mayank Jain
mcs182012	Ruturaj Mohanty
mcs182013	Aditya Kumar
mcs182014	Phaneesh Barwaria
mcs182015	Prateek Gupta
mcs182016	Pushkar Singh
mcs182017	Garima
mcs182018	Chirag Manwani
mcs182019	Saurabh Milind Godse
mcs182020	Misha Mehra
mcs182021	Prashant Kumar
mcs182024	Suraj S
mcs182025	Konark Verma
mcs182092	Sriram S V
mcs182093	Hari Om Ahlawat
mcs182094	R Sharma
mcs182095	V Pareek
mcs182120	Mahendra Pratap Singh
mcs182140	Nitish Raj
mcs182141	Gaurav Shukla
mcs182142	Anshu Bansal
mcs182143	Mehak
mcs182144	Kumari Rekha
mcs182839	Prayas Sahni
mcs182840	Namrata Jain
me1070528	Shubhadeep Chakraborty
me1080519	Mukul Bansal
me1080528	Prateek Negi
me1100745	Nitesh Singh
me1110701	Neeraj Kumar
me1110735	T Abhilash
me1120651	Aman Sharma
me1120658	Borkar Shubham Gajanan
me1120739	Vikash Kumar Pal
me1130653	Banavath Roopesh
me1130654	Bandi Sri Rama Chandra Murthy
me1130671	Himanshu Seth
me1130679	Karan Goyal
me1130682	Khushal Soni
me1130698	Narendra Kumar Meena
me1130710	Raut Shrikant Madhukar
me1130721	Saurabhdeep Singh Deopuri
me1130727	Shubham Singh
me1130729	Subhasish Das
me1140633	Amit Kumar Munda
me1140651	Dasari Venkat Ramana
me1140656	Gaundar Aniket Deelip
me1140667	Mihik Agrawal
me1140685	Shivam Gupta
me1150044	Manan A Gandhi
me1150101	Harsh Vardhan Rai
me1150108	Manas Joshi
me1150110	Mohd Babar
me1150228	Indrajeet Singh
me1150354	Paras Gupta
me1150383	Shubham Singla
me1150390	Sumit Mahlawat
me1150396	Utkarsh Prabhakar
me1150626	Aakash Mangla
me1150627	Abhayraj Singh Meena
me1150628	Akash Kumar
me1150630	Akhilesh Verma
me1150631	Akshay Kumar Soni
me1150632	Alok Meena
me1150633	Amit Kumar Sahu
me1150634	Ankit Jaipuria
me1150635	Ankush Chopra
me1150636	Arth Jain
me1150637	Ata Ul Haque
me1150639	Ayush Singh
me1150640	Ayush Garg
me1150642	Bhadoria Aditya Akhilesh
me1150643	Brijesh Sanwariya
me1150644	Chokkaku Praveen Kumar
me1150645	Dhananjay Gupta
me1150646	Fatehdeep Singh Walla
me1150647	Gaurav Kumar
me1150648	Hardeep Singh
me1150650	Jatin Bansal
me1150651	Kanu Raj Anand
me1150652	Kartik Gupta
me1150653	Koneti Shivateja
me1150654	Kunal Indra
me1150655	Lochan Sharma
me1150656	Lokesh Kumar Chandoliya
me1150657	Lokraj Meena
me1150658	Mayank Mahawar
me1150659	Mehul Muradia
me1150660	Mohit Khinchi
me1150661	Mohit Singh
me1150662	Mohit Agarwal
me1150663	Neeraj Kumar
me1150664	Nikhil Garg
me1150665	Piyush Kumar Saini
me1150666	Prakhar Kumar Mahobia
me1150668	Pranjal Singh
me1150669	Prateek Bharti
me1150670	Pulkit Agarwal
me1150671	Pulkit Garg
me1150672	Raghu Kumar Yadav
me1150673	Ravi Choudhary
me1150674	Sahil Singh Malik
me1150675	Sanyam Agarwal
me1150676	Saurabh Gothwad
me1150677	Saurabh Agarwal
me1150678	Saurabh Kumar
me1150679	Saurav Kumar Gupta
me1150680	Shashank Saxena
me1150681	Shashwat Sinha
me1150682	Shubham Raj Tomar
me1150683	Shubham
me1150684	Shuvang Jandiyal
me1150685	Sonal Gautam
me1150686	Utkarsh N Singh
me1150687	Vaibhav Kejriwal
me1150688	Vinay Arora
me1150689	Vipul Kumar Baloda
me1150690	Vivek Chandra
me1150692	Yash Yadav
me1150693	Yogesh Kumar Kalawat
me1150899	Jasleen Kaur
me1160036	Tanmaye Soni
me1160073	Sushant Mendiratta
me1160080	Rohit Kumar Singh
me1160224	Diptangshu Sen
me1160670	Dhruv Talwar
me1160671	Nishant Jindal
me1160672	Chaitanya Sharma
me1160673	Devansh Jindal
me1160674	Vikram Baranwal
me1160676	Navneet Goyal
me1160678	Himanshu Singh Chauhan
me1160679	Shivang Rampriyan Dwivedi
me1160681	Adarsh Kumar Sahu
me1160682	Abhinav Upadhyay
me1160683	Anshshiv Garg
me1160684	Deepansu Kaushik
me1160685	Aditya Singla
me1160686	Pranav Chawla
me1160687	Sanidhya Jain
me1160688	Kushaal Singh
me1160689	Saumya Gupta
me1160690	Aniket Gupta
me1160691	Devanshu Agarwal
me1160692	Chandan Mittal
me1160693	Saksham Jain
me1160695	Akash Arun Gupta
me1160696	Hemang Shekhar
me1160697	Swapnesh Agrawal
me1160698	Patel Bilv
me1160699	Shashwat Jain
me1160700	Shubham Mishra
me1160702	Shashwat Maiti
me1160703	Kushaagra Goyal
me1160704	Bhuvesh Goyal
me1160705	Faraz Mazhar
me1160706	Vikash
me1160707	Manish Yadav
me1160708	Shubham Verma
me1160709	Neeraj Verma
me1160710	Priyadarshan
me1160711	Sudheer Kumar Bhalothia
me1160712	Vinod Kumar
me1160713	Rishabh Jangid
me1160714	Nandkishore
me1160715	Dhabu Saurabh Nemkumar
me1160716	Manish Baghel
me1160717	B Anirudh Krishna
me1160718	Shiba Narayan Biswal
me1160719	Harsh Kumar
me1160720	Satyam Rathore
me1160721	Shubham Kumar
me1160722	Shubham Satyarthi
me1160723	Avinash Bairwa
me1160724	Himanshu Lal
me1160725	Rishabh Verma
me1160726	Kumar Saurav
me1160727	Alok Kumar
me1160728	Ankit Beniwal
me1160729	Jawanjal Priyadarshan Prakash
me1160730	Karmvir Singh
me1160731	Abhishek Kumar
me1160732	Paikrao Saurav Atul
me1160733	Subhash Chand Meena
me1160734	Pritesh Meena
me1160735	Krishn Meena
me1160736	Abhishek Kumar Meena
me1160737	Akshmeet Meena
me1160747	Sahil Vaish
me1160754	Arjun Bhardwaj
me1160758	Aman Jain
me1160824	Arundhati Dixit
me1160829	Parth Chopra
me1160830	Ayush Srivastava
me1160901	Divyansh Rana
me1170021	Namita Dudeja
me1170061	Kshitij Jain
me1170158	Shanmukhi Sripada
me1170561	Abhijaat Singh
me1170562	Abhishek Dharmesh
me1170563	Adarsh S Menon
me1170564	Ajay Suthar
me1170566	Arpit Agrawal
me1170567	Arpit Jain
me1170568	Aryaman Gupta
me1170569	Ayush Jain
me1170570	Bhargav Varshney
me1170571	Bonu Mukesh
me1170572	Dammalapati Sai Shashank Chowdary
me1170573	Deepak Kumar
me1170574	Diptanshu Rajan
me1170575	Divyanshu Sharma
me1170576	Gulipalli Chaitanya Ram
me1170578	Harshit Maheshwari
me1170579	Jayaditya Gupta
me1170580	Kanishak Aggarwal
me1170581	Keshav Aniruddha
me1170582	Keshav Raj
me1170583	Kota Pavan Sai Teja
me1170585	Madhur Sigar
me1170586	Manan Brijesh Patel
me1170587	Manish Ranjan
me1170588	Manjeet Singh
me1170590	Mohit Bhandari
me1170591	Mohit Kumar Prajapat
me1170592	Namburi Yaswanth
me1170593	Naqueeb Ahmad
me1170594	Neeraj Kumar
me1170595	Nikhil Mishra
me1170596	Nipun Verma
me1170598	Prabhav Gupta
me1170600	Pratyush Srivastava
me1170601	Rade Chirag Dipak
me1170603	Rakesh Kumar Meena
me1170604	Ravi Shanker Meena
me1170605	Rohan Yuttham
me1170606	Rudraneel Roy
me1170607	Sahil Chadha
me1170609	Satvik Gupta
me1170610	Shah Jinay Hareshbhai
me1170611	Shivam Agrawal
me1170612	Shreyash Raj
me1170613	Siddhant Jain
me1170614	Solanki Rutvik Shailesh
me1170615	Sourav Chandran
me1170616	Sudip Maji
me1170617	Sukhbir Singh
me1170618	Sunav Kumar Vidhyarthi
me1170619	Sunil Kumar
me1170620	Suryansh Agarwal
me1170621	Tanya Prasad
me1170622	Tarandeep Singh Thukral
me1170623	Taransh Sindhwani
me1170624	Vijay Kumar Meena
me1170625	Vimal Kumar
me1170626	Vineet Kumar Singh
me1170627	Vishal
me1170628	Vivek Sudhir Mahindrakar
me1170651	Anmol Gupta
me1170698	Siddharth Sehgal
me1170702	Vaibhav Baldwa
me1170950	Rupsha Bhattacharyya
me1170960	Shobhit Singhal
me1170967	Sumedh S Mandhan
me1180581	Aditi Meena
me1180582	Aditya Mohanmishra
me1180583	Aditya Mudgal
me1180584	Aditya Raj
me1180585	Akhil Bajiya
me1180586	Aman Kumar Lohia
me1180587	Amar Kumar
me1180588	Amarjit
me1180589	Ankita Mandal
me1180590	Anoushka Gupta
me1180591	Anubhav Kaushik
me1180592	Anuj Dhillon
me1180593	Arunava Das
me1180594	Ashok
me1180595	Ashutosh Pandey
me1180596	Avinash Verma
me1180597	Ayush Kanodia
me1180598	Bharat Runwal
me1180599	Brahmbhatt Anand
me1180600	Chakshur Tyagi
me1180601	Chavan Kamal Roshannaik
me1180602	Chhavi Choudhary
me1180603	Dedeepyo Ray
me1180604	Devang Garg
me1180605	G Rohan
me1180606	Gauri Avinashninawe
me1180607	Goraka Nagajaswanth Reddy
me1180608	Hari Prasath R
me1180609	Harsh Sharma
me1180610	Harsh Wardhan
me1180611	Harshit Mangal
me1180612	Himanshu Verma
me1180613	Hrishabh Singh
me1180614	Isha Chaudhary
me1180615	Ishank Srivastava
me1180616	Ishvik Kumarsingh
me1180617	Khushi Jain
me1180618	Lavudiya Nageeshnaik
me1180619	Manish Janu
me1180620	Manish Rajendrasonar
me1180621	Manisha Verma
me1180622	Mayank Jha
me1180623	Medini Sharma
me1180624	Misha Mishra
me1180625	Mohit Dadarwal
me1180626	Mridul Ahuja
me1180627	Nachiketa Kumar
me1180628	Namit Chugh
me1180629	Narendra Pratapsingh
me1180630	Navaneeth K P
me1180631	Neeraj Kumarsingh
me1180632	Palak Bhagat
me1180633	Pintu Meena
me1180634	Prince Singh
me1180635	Rahul Choudhary
me1180636	Rahul Parmar
me1180637	Sahil Singh
me1180638	Shashi Bhushansingh
me1180639	Shivam Goyal
me1180640	Shivansh Garg
me1180641	Shubham
me1180642	Soumil Sahu
me1180643	Sujeet Yadav
me1180644	Sumit
me1180645	Sunil Devanda
me1180646	Suyash Singh
me1180647	Tarun Singh
me1180648	Tushar Bhartiya
me1180649	Varun Goyal
me1180650	Vasanth
me1180651	Vinay Sharma
me1180652	Vinit
me1180653	Vishal Dhukia
me1180654	Vydya Rahulkoutilya
me1180655	Vyomesh U Tewari
me1180656	Yash Choudhary
me1180657	Rudrakshchhangani
me1180658	Yash Umeshdeshmukh
me2110775	Jogender Kumar Devda
me2120768	Arun Kumar
me2120787	Niranjan Meena
me2120795	Rithik Singh
me2120803	Sirra Abhinav Prakash
me2130786	Mandali Sandeep
me2140721	Banoth Narender
me2140735	Kanav Garg
me2140755	Rishabh Nagpal
me2140759	S Pardhu Nihar
me2140761	Sangram Vuppala
me2140762	Sansiddh Kumar Jain
me2140772	Vineet Topno
me2150706	Aakash Verma
me2150707	Aakash Ahuja
me2150708	Abhijeet Saxena
me2150709	Abhishek Kumar
me2150710	Afshan Arif
me2150711	Ajayendra Singh
me2150712	Akhil Singla
me2150713	Akshay Kumar Pansari
me2150714	Aman Negi
me2150715	Amit Jonwal
me2150716	Amogh Gupta
me2150717	Andiboyina Sai Vamsi
me2150718	Animesh Jaiswal
me2150719	Animesh Jain
me2150720	Ansh Jain
me2150721	Anshit Kumar
me2150722	Antriksh Mathur
me2150723	Anubhav Ukil
me2150724	Archit Matta
me2150727	Ayush Kumar
me2150728	Bhagyam Choudhary
me2150729	Bhavya Kaushik
me2150731	Denish Sukhadiya
me2150732	Harshit Hemani
me2150733	Harshvardhan
me2150734	Honrao Ishvar Dhondiba
me2150736	Jaswant Meena
me2150737	Kamya Iyer
me2150738	Kartik Choudhary
me2150739	Krishaanu Syal
me2150740	Kudapa Milind Chowdary
me2150741	Kulkarni Indraneel Mukund
me2150742	Lakshay Bahl
me2150743	Lendegaonkar Samvidhan
me2150745	Mata Prasad
me2150746	Mohit Dalal
me2150747	Naman Goyal
me2150748	Nikhil Bansal
me2150749	Piyush Kumar
me2150751	Pranshu Zeesa
me2150752	Preetam Suresh Rathod
me2150753	Rajat Kharbanda
me2150754	Rishabh Mohan Sharma
me2150755	Rohit Kumar
me2150756	Rohit Kumar
me2150758	Sahil Khokhar
me2150759	Sanjay Singh Khadda
me2150760	Sankalp Katiyar
me2150763	Shobhit Mittal
me2150764	Shubham Verma
me2150765	Shubham Kumar
me2150766	Simranjit Singh
me2150768	Tanya Singh
me2150769	Tushar Sahebrao Kanhe
me2150770	Utkarsh Vardhan
me2150771	Yash Chordia
me2150772	Yashaswi Ratan
me2150773	Yugal Kishor Meena
me2160745	Anmol Bhardwaj
me2160746	Mohit Goyal
me2160748	Akash Mahajan
me2160749	Priyam Sodhiya
me2160750	Aditya Jain
me2160752	Shantam Sharma
me2160753	Tushar Bansal
me2160755	Utkarsh Agrawal
me2160756	Utkarsh Gupta
me2160757	Tanmay Goyal
me2160759	Sarthak Asati
me2160760	Kshitij Gupta
me2160761	Sanidhya Tiwari
me2160762	Vibhu Rawat
me2160763	Shagun Gupta
me2160764	Pranjal Agarwal
me2160765	Keshav Kumar
me2160766	Shivani Bansal
me2160767	Shantnav Agarwal
me2160768	Nishtha Saxena
me2160770	Nikunj Gupta
me2160771	Arsh Sidana
me2160772	Ayyangar Saket Shivkumar
me2160773	Manuj Trehan
me2160774	Praket Parth
me2160775	Anshul Agrawal
me2160776	Divyani Bhaiya
me2160777	Hitesh Agarwal
me2160778	Harshit Abrol
me2160779	Meesala Manohar
me2160780	Mihir Raj
me2160781	Nirmal Kumar
me2160782	Keshav Jangid
me2160783	Punit
me2160784	Himanshu Suthar
me2160786	Vinay Kayath
me2160787	Khushee
me2160788	Deepak Patel
me2160790	Arpit Kumar
me2160791	Sahil Bhadana
me2160792	Doddi Shyam Kumar Naidu
me2160793	Akshay Patel
me2160794	Rajan Gupta
me2160795	Fahad Jamal
me2160796	Utkarsh Prajapati
me2160797	Lokesh Dadoriya
me2160798	Nitin Shekhar
me2160799	Ankit Shilarkar
me2160800	Anshul Morwal
me2160801	Pramod Kumar Tanwar
me2160802	Kunal Kumar
me2160803	Mihir Gautam
me2160804	Vikas Mallick
me2160806	Abhishek Singh
me2160807	Abhishek Meena
me2160808	Param Jharwal
me2160809	Alok Meena
me2160810	Ashutosh Gamad
me2160811	Mayank Kumar
me2170641	Abhijeet Kumar Singh
me2170642	Abhishek Gangwar
me2170643	Abhishek Jakhiwal
me2170644	Aditya Amrit
me2170645	Aditya Raj Gupta
me2170646	Akshat Singh
me2170647	Aman Kumar
me2170648	Aman Kumar Gupta
me2170649	Amar Kumar
me2170650	Anirudha Dinesh Jaiswal
me2170652	Anshul Agrawal
me2170653	Anupam Singh
me2170655	Arnav Jain
me2170656	Atul Kumar
me2170657	Atul Saharan
me2170658	Bhavya Kumawat
me2170659	Chokkapu Mithun
me2170660	Dalavi Yogeshwar Ramdas
me2170661	Deepanshu Goyal
me2170662	Deepika Meena
me2170663	Devanshu Aggarwal
me2170664	Gaurav Agrawal
me2170665	Gulam Waris
me2170666	Gunjan Mathur
me2170667	Hariharan M
me2170668	Shubham Rustagi
me2170669	Jashandeep Singh
me2170670	Jayant Prasad Tarapure
me2170671	Karan Mittal
me2170672	Kshitij Gupta
me2170673	Kumar Ichchhit
me2170674	Lakshya Singhal
me2170675	Mahesh Sai M
me2170676	Md Osama
me2170677	Shantanu Prabhat Choudhary
me2170678	Nalla Thrisaran
me2170679	Nikhil
me2170680	Nikita Rana
me2170681	Palash Khandelwal
me2170683	Parth Samria
me2170684	Prabhat Kushwaha
me2170685	Pradeep Peter Murmu
me2170686	Priyansh Khandelwal
me2170687	Raj Vardhan
me2170688	Ritika Chaplot
me2170689	Rohan Balaji Kamble
me2170690	Sanket Beniwal
me2170691	Sarthak Jain
me2170692	Saswat Mishra
me2170693	Saurav
me2170694	Shivam Soni
me2170695	Shreyansh Chanani
me2170696	Rajas Salil Joshi
me2170697	Shubham Aggarwal
me2170699	Snigdh Singh
me2170700	Tushar Baijal
me2170701	Utsav Khandelwal
me2170703	Vankayalapati Roop Harshit
me2170705	Vipul Sattavan
me2170706	Yashvardhan Bansal
me2170707	Yogesh Kumar
me2170842	Ragul S
me2180661	Aastha Jain
me2180663	Abhishek Jain
me2180664	Aditya Aggarwal
me2180665	Aditya Sahu
me2180666	Adityasrivastava
me2180667	Akshay Mattoo
me2180668	Ankit Jarwal
me2180669	Ankit Kumar
me2180670	Ankit Sharma
me2180671	Arsalan Abbas
me2180672	Aryan Gupta
me2180673	Ashish Yadav
me2180674	Avinash Kumar
me2180675	Ayush Patel
me2180676	Ayushi Garg
me2180677	Bapodara Dharmikrambhai
me2180678	Bhanu Pratapasiwal
me2180679	Bhukya Swetha
me2180680	Chand Nileshbhaidelvadiya
me2180681	Deepak
me2180682	Divyanjali Singh
me2180684	Gedela Anurag
me2180685	Harshdeep Singh
me2180686	Hely Gupta
me2180687	Shiva Singh
me2180688	Kale Avinashvitthal
me2180689	Kanishk Jain
me2180690	Kartik Aggarwal
me2180691	Kuldeep Singh
me2180692	Manduva Amatyabharadwaj
me2180693	Muntaha Kamal
me2180694	Nagarjunnimmalwar
me2180695	Bipul Kumarchaudhary
me2180696	Naman Solanki
me2180697	Naveli Jaju
me2180698	Neelabh Madan
me2180699	Nilesh Gupta
me2180700	Nisha Saini
me2180701	Pankaj Meena
me2180702	Parth Wadhawan
me2180703	Piyush
me2180704	Prabhpreet Singhbhatia
me2180705	Prachi Bansal
me2180706	Prateek Singhsidhu
me2180707	Priyanshi Gupta
me2180708	Raghav Modi
me2180709	Rahul Narayanmehra
me2180710	Rajan Gupta
me2180711	Rishi Dubey
me2180712	Risshi Agrawal
me2180713	Ritik Sharma
me2180714	Prityush Bansal
me2180715	Saloni Mangal
me2180716	Samarpan Jain
me2180717	Sandeep Ganesh
me2180718	Sanyam Jain
me2180719	Sarthak Garg
me2180720	Saurabh
me2180721	Shadab Abbas
me2180722	Shitij Malik
me2180723	Shivalik Singh
me2180724	Shivam Acharya
me2180725	Utkarsh Rai
me2180726	Siddarth Goyal
me2180727	Siddharth Dixit
me2180728	Tanya Kumari
me2180729	Vasu Mishra
me2180730	Vikas Meena
me2180731	Vikash Kumarkumawat
me2180732	Vishal
me2180733	Yashendra Mohan
me2180734	Yuvraj Singh
me2180735	Yuvraj Siyag
me2180736	Tathagat Arya
mee172528	Mariam Nagah Rashwan Abdelhamid
mee172766	Rohit Bali
mee172786	Gaurav Agrawal
mee172787	Shashank Shekhar Singh
mee172788	Aman Meena
mee172789	Vinit Kumar Singh
mee172790	Virendra
mee172853	Kartik Natarajan
mee172859	Soham Das
mee182101	Ashutosh Singh
mee182809	Pokkunuri Saikrishna Chaitanya
mee182810	Purusharth Pathak
mee182811	Sambit Mohanty
mee182812	Sundarmohan Besra
mee182813	Kinshuk Agrawal
mee182816	Pankaj Prajapat
mem172478	Rojenkoshy John
mem172485	Pratyush Mishra
mem172488	Vivek Yadav
mem172515	Shaheen Mp
mem172526	Suman Kumar Sahu
mem172742	Nadeem Ahmad
mem172746	Suraj
mem172750	Sridhar Palani
mem172798	Bhaskar Singh
mem172799	Namit Mishra
mem172804	Ramit Kumar
mem172805	Mohit Aggarwal
mem172806	Arshad K A
mem182253	Paridhi Mishra
mem182255	Himanshu Gupta
mem182257	Mohit Tunwal
mem182260	Harsh
mem182263	Tushar Sharma
mem182264	Jayakrishnan N
mem182268	Atul Patel
mem182269	Govind Yadav
mem182270	Pyla Ramana Raju
mem182271	Deepanshu Singh
mem182314	Raunak Singh
mem182843	Dinesh Kumar S
mem182845	Mukul Gupta
mem182846	Narayanasetti Harish Kumar
mem182848	Harshit Kumar Jaiswal
mem182849	Sandeep Gehani
mem182850	Munna Kapoor
mem182851	Saurabh Sudhir Dharme
mem182853	Chandan Kumar
mem182854	Shubham Vasantrao Nikam
mem187518	Sivaragavi S A
mep172496	Deepak Tyagi
mep172498	Girish Kumar Yadav
mep172529	Semir Mohammedibrahim Negash
mep172791	Akash Tiwari
mep172794	Nitin Yadav
mep172795	Harshish Gupta
mep172796	Anubhav Gupta
mep182102	Ankur Sharma
mep182296	Vishnuprasad C G
mep182329	Anurag Yadav
mep182778	Himanshu Tiwari
mep182780	Kunal Kishor
mep182781	Ashish Kumar
mep182782	Shivam Sahu
mep182783	Dipender Meena
mep182784	Bharat Devidas Khandate
mep182786	Abhishek Singla
mep182787	Ankit Gupta
mep182788	Mohit Agarwal
mep182789	Abhishek Singh
mep182790	Pulkit Dhaundyal
mep182791	Shubham Garg
mep182792	Mayank Gupta
mep182793	Deepak Kumar
met172274	Shivam Verma
met172277	Arvind B
met172527	Kumar Prabhat
met172571	Madhukar Krishna
met172808	Jugal Saurin Shah
met172809	Manish Kumar Singh
met172810	Abhishek Soi
met172811	Purushottam Ranga
met172812	Mohit Pathak
met172813	Md Shahzad Hasan
met172814	Yogesh Nitin Mahajan
met172815	Prateek Malik
met172817	Akashdeep Gangrade
met172819	Pravanjan Padhihari
met172821	Rubal Prakash
met172822	Abhishek Kumar Singh
met172825	Anup Singh
met172830	Ajay
met182099	Pawan Kumar
met182100	Subhasish Sarkar
met182122	Gaurav Pratap
met182273	Gaurav Pundir
met182274	Arun Sindhu
met182275	Chaitanya Sunil Bhoir
met182278	Vivek M Mohan
met182285	Pankaj Singh
met182290	Ankit Kumar
met182291	H Thangsuankhup
met182794	Rohit Prajapati
met182795	Ayush Bhardwaj
met182797	Rahul Pandey
met182798	Nitish Bindal
met182799	Dasari Surya Bhagawan
met182800	Abhishek Gupta
met182802	Shalini Sonwani
met182803	Rohit Mohan Jiwane
met182804	Ayush Lamba
met182805	Ajoy U
met182806	Chandra Prakash
met182807	Shardul
met182856	Pulagam Ajay Bhaskar Bhavan
met182857	Naman Kumar Jain
met182859	Roshan Ramesh Nehe
met182869	Bondalapati Abhishek
mey167534	Pushpender Prasad Panday
mey167535	Devi Mutyala
mey177525	Rishi Gupta
mey177544	Venu Gopal Agarwal
mey187515	Jatin Garg
mey187516	Ashish Surendra Jha
mey187517	Saurabh Singh
mey187541	Rohit Sankrityayan
mey187543	Ajmera Sanketh Kumar
mez118359	Sourabh Kumar
mez128244	Vijayalakshmi Yerramalle
mez128247	Abdul Rahman Khan
mez128258	Gaurav Singh
mez128259	Anil Yadav
mez128310	Patel Ashwinkumar Virambhai
mez128384	Pooja Bhati
mez128385	Sachin Kansal
mez128388	Anvesh Reddy Nandyala
mez128393	Zeba Naaz
mez128397	Leeladhar Kala
mez138167	Ananda Srinivas V
mez138169	Devendra Kumar
mez138170	Jagtar Singh
mez138172	Kuldeep Singh
mez138179	Sanyam Sharma
mez138182	Vaibhav Chandra
mez138183	Vedabouriswaran Ganapathy
mez138470	Neha Bhadauria
mez138471	Nilesh Dadasaheb Pawar
mez138475	Tukesh Soni
mez142809	Saurav Chakraborty
mez148008	Amit Kumar
mez148010	Anil Kumar Sharma
mez148011	Anil Kumar
mez148012	Devershi Mourya
mez148013	Rakesh Kumar Bhardwaj
mez148014	Rattandeep Singh
mez148017	Siddharth Tamang
mez148247	Puneet Kumar
mez148337	Abhinava Chatterjee
mez148338	Akhilesh Dadaniya
mez148339	Aparna Pandharkar
mez148340	Hariom Saran Singh
mez148342	Rajeshkumar Devendra Madarkar
mez148343	Ved Prakash
mez148389	Habtamu Alemayehu Ameya
mez148426	Punit Singh
mez158151	Abhishek Kumar Pandey
mez158152	Abhishek Sit
mez158153	Dayanidhi Krishana Pathak
mez158154	Deepak Deelip Patil
mez158155	Digpal Kumar
mez158156	Dinesh Kochhar
mez158159	Kandarp Popatlal Changela
mez158160	Kaushlendra Kumar Dubey
mez158161	Kaveri Kala
mez158162	Mahendra Kumar Gupta
mez158163	Nikhil Sharma
mez158164	Pawan Sharma
mez158166	Rameshwar Chaudhary
mez158167	Sarvesh Kumar Mishra
mez158170	Sunil Kumar
mez158171	Vinod Kumar Singh
mez158298	Mrinal Patel
mez158444	Harish Kumar
mez158445	Abhishek Singh
mez158446	Abhishek Bhatnagar
mez158447	Pradeep Kundu
mez158448	Dharmender
mez158449	Anil Kumar Patidar
mez158451	Rajeevlochana C G 
mez158492	Ved Prakash Sharma
mez158499	Maansi Gupta
mez158500	Shobhit Raj Mathur
mez167515	S M Thamil Kumaran
mez168267	Sharaf U Nisa
mez168268	Jitin Malhotra
mez168269	Ankur Kumar Tiwari
mez168270	Vipul Vibhanshu
mez168271	Aditi Garg
mez168272	Nikhil Kumar Singh
mez168273	Chinmaya Mishra
mez168274	Anupam Bhattacharya
mez168275	Sasanka Sekhar Sinha
mez168276	Jeewan Chandra Atwal
mez168277	Aman Vikram
mez168278	Mayank Srivastava
mez168279	Gurminder Singh
mez168280	Vinayak Sudalai
mez168282	Wasim Akram
mez168329	Pirsab Rasulsab Attar
mez168352	Amit Jha
mez168538	Sufia Khatoon
mez168539	Rahul Sharma
mez168540	Anurag Mishra
mez168541	Aman Preet Singh
mez168542	Mohd Tauheed
mez168543	Ravinder Pal Singh
mez168544	Alok Srivastava
mez168545	Hardik Arvindbhai Patel
mez168547	Vikas Jangir
mez168548	Santosh Kushwaha
mez168550	Vishnu Sukumar
mez168551	Aisha Ahmed
mez168552	Jasvinder Singh
mez168553	Ashish Kumar Sahu
mez168554	Avinash Kumar
mez168555	Shital Kumar Garg
mez168556	Ravinder Kumar
mez168557	Suresh Babu Muttana
mez177523	Ramya Ahuja
mez178313	Parvez Ahmad
mez178314	Abhishek Kumar Singh
mez178316	Thirumoorthy M
mez178317	Rohit Mehta
mez178318	Neha Singh
mez178319	Amit Chanda
mez178320	Shambo Bhattacharya
mez178321	Sreejath S
mez178322	Mohd Shoaib
mez178323	Jyotsna Gupta
mez178324	Anagdha
mez178325	Usharani Rath
mez178326	Dipesh Kumar Mishra
mez178327	Kartikeya
mez178328	Nitesh Kumar Sahu
mez178331	Akash Yadav
mez178332	Kumari Neelam Verma
mez178333	Jayakrishna Pedduri
mez178336	Thochi Seb Rengma
mez178337	Veerendra Kumar
mez178339	Naveen Kumar Sahu
mez178341	Binoy B
mez178428	M Anbalagan
mez178594	Praveen Thakur
mez178595	Vishal Goyal
mez178596	Rohit Kumar
mez178597	Bhavna Rajput
mez178598	Govind Sharma
mez178600	Manish Gupta
mez178601	Dupade Vikrant Uday
mez178602	Gaurav Goyal
mez178604	Archit Shrivastava
mez178605	Ajit Kumar
mez178606	Onkar Chawla
mez178608	Rohit Kumar Sharma
mez178609	Srijan Prabhakar
mez178610	Rudranarayan Kandi
mez188261	Yogesh Maheshbhai Patel
mez188262	Sandeep
mez188263	Abhishek Kumar Shukla
mez188264	Hridin Pradeep
mez188265	Amit Prakash
mez188266	Mahesh Jagannath Yadav
mez188267	Mohit Tyagi
mez188268	Deepak Gautam
mez188270	Mahesh Nandyala
mez188271	Nagendra Kumar Mehta
mez188272	Tarun Verma
mez188273	Rakesh Moharana
mez188284	Dhruv Narayan
mez188285	Rajesh Kumar
mez188286	Manas Ranjan Pattnayak
mez188287	Najiya Fatma
mez188288	Alinjar Dan
mez188580	Abhishek Kandpal
mez188581	Adnan Jawed
mez188582	Arun Kumar
mez188583	Ayushi Mishra
mez188584	Bhagatsingh Ambarsingh Patil
mez188585	Debabrat Biswal
mez188586	Deepak Kumar Yadav
mez188587	Garima Dixit
mez188588	Gaurav Tripathi
mez188589	Khushi Ram
mez188590	Makhan Singh
mez188591	Manas Kumar Sahoo
mez188592	Naveen Kumar Verma
mez188594	Pratik Badgujar
mez188595	Pydi Yeswanth Sai
mez188596	Raghvendra Gupta
mez188597	Ritesh Kumar Chaurasiya
mez188598	Sandeep Gupta
mez188599	Shitanshu Arya
mez188600	Vinay Kumar
mez188662	Manish Dalal
mez188668	Vivek Kumar
msz188015	Amit Kumar
msz188016	Nidhi Gupta
msz188017	Abhishek Rastogi
msz188018	Supriya Maity
msz188019	Biswajit Mishra
msz188020	Pooja Vardhini Natesan
msz188021	Harshal Vinod Peshne
msz188022	Mayank Prakash
msz188023	Lukkumanul Hakkim N 
msz188024	Aiswarya T T
msz188289	Ujjawal Bairagi
msz188290	Chetan Singh
msz188505	Arun S
msz188506	Mahipal Meena
msz188507	Meenakshi Verma
msz188508	Prashant Mani Shandilya
msz188519	Himanshu Rai
mt1140045	Niharika
mt1140581	Abhishek Kumar
mt1140584	Akshay Kumar
mt1140593	Komal Ratan Shipe
mt1150182	Ribhav Gaur
mt1150319	Avinash Kumar
mt1150375	Saurabh Pal
mt1150560	Hullas Jindal
mt1150581	Aakash Varshney
mt1150582	Aasavari Dhananjay Kakne
mt1150583	Abhimanyu Swami
mt1150584	Abhishek Kumar Yadav
mt1150585	Abhishek Yadav
mt1150586	Aditi Narware
mt1150587	Amar Prakash
mt1150588	Amit Meena
mt1150589	Anubhav Garg
mt1150591	Aryan Digwal
mt1150592	Avaneep Gupta
mt1150593	Ayush Garg
mt1150594	Barinderpreet Singh
mt1150595	Charvi Nahar
mt1150596	Darshan Golghate
mt1150597	Devarakonda Manasa
mt1150598	Drashti Khatsuriya
mt1150599	Harshaan Dargan
mt1150601	Kotala Vineeth
mt1150602	Major Singh
mt1150603	Mayank Gupta
mt1150604	Meghna Choudhary
mt1150605	Pankaj
mt1150606	Prakhar Anand
mt1150607	Prakhar Singh
mt1150608	Pranav Gothwal
mt1150609	Rajat Panwar
mt1150610	Ridam Maheshwari
mt1150611	Sachin Malav
mt1150612	Saif Ali
mt1150613	Samvit Dammalapati
mt1150614	Shivangi Agrawal
mt1150615	Sumeet Khandelwal
mt1150616	Vangala Naveen Reddy
mt1150617	Vartika Bisht
mt1150725	Ashish Gupta
mt1150870	Animesh Choudhary
mt1160268	Kishan Kumar
mt1160413	Siddhant
mt1160491	Alankrit Garg
mt1160492	Chahat Chawla
mt1160546	Aajeya Mahendra Jajoo
mt1160582	Tejasva
mt1160605	Akshay Jain
mt1160606	Prateek Goyal
mt1160607	Nalin Gupta
mt1160608	Shagun Singh
mt1160609	Daanish Bansal
mt1160610	Naman Jain
mt1160611	Sparsh Garg
mt1160613	Siddhartha Shankar Kahali
mt1160614	Sambhav Khurana
mt1160616	Eshan Balachandar
mt1160617	Ayush Chaurasia
mt1160618	Kumar Prithvi Mishra
mt1160619	Shivam Singla
mt1160620	Anshuman Shrivastava
mt1160621	Saurabh Kumar M Shah
mt1160622	Kishan K Patel
mt1160623	Naman Singh Kanaujia
mt1160624	Mani Karan Soni
mt1160626	Rupesh Kumar Sankhala
mt1160627	Aila Mani Deepak Reddy
mt1160628	Priyank
mt1160629	Harsh Kumar
mt1160630	Parminder Singh
mt1160631	Deepak Chaurasia
mt1160632	Aditi Chaudhary
mt1160633	Arjya Das
mt1160634	Vadlana Surya Prakash
mt1160635	Kadam Ajit Balaji
mt1160636	Parikh Jay Mahendrakumar
mt1160637	Sudesh Sunil Wasnik
mt1160638	Girraj Godiya
mt1160639	Mude Lokesh Naik
mt1160640	Eslavath Midhil Naik
mt1160647	Kaustubh Prakash
mt1170213	Keshav Malpani
mt1170287	Divyam Gupta
mt1170520	Ashish Gupta
mt1170530	Jatin
mt1170721	Aakash Gaurav
mt1170722	Aayush Somani
mt1170723	Abhinav Sai Sri Ram Samala
mt1170724	Abhinava Sikdar
mt1170725	Abhishek Jangra
mt1170726	Ajay Baldev Sailopal
mt1170727	Ankit Kumar
mt1170728	Avanish Kumar Singh
mt1170729	Harsh Kumar
mt1170730	Harshvardhan Sushil Patni
mt1170731	Himanshu Singh Yadav
mt1170732	Kaligotla Sai Ashwal
mt1170733	Kamal Jain
mt1170734	Lokesh Raj
mt1170735	Manthan Kabra
mt1170736	Mrigank Raman
mt1170737	Naman Jhunjhunwala
mt1170738	Naman Kumar
mt1170739	Nikhil Kapoor
mt1170740	Nimesh Sangwan
mt1170741	Ojal Kumar
mt1170742	Palak Jain
mt1170743	Prajay Pramod Sapkale
mt1170744	Prithwish Maiti
mt1170745	Rishi Raj Singh
mt1170746	Rohan Meena
mt1170747	Saksham Jain
mt1170748	Sakshi Taparia
mt1170749	Sarat Varma Kallepalli
mt1170750	Shivam Garg
mt1170751	Shradha Nandkishor Rathod
mt1170752	T D M S S Pavan Srinivas
mt1170753	Utkarsh Gupta
mt1170754	Vipul Garg
mt1170755	Vivek Muskan
mt1170756	Yashank Singh
mt1170772	Anchit Tandon
mt1180736	Aditi Rai
mt1180737	Akshat Rao
mt1180738	Amit Shekhar
mt1180739	Anand Bhausahebnimbalkar
mt1180740	Anirudha Kumarakela
mt1180741	Anshul Singh
mt1180742	Arpit Saxena
mt1180743	Arshad Warsi
mt1180744	Aryan Agarwal
mt1180745	Aryan Gupta
mt1180746	Ayush Garg
mt1180747	Ayush Srivastava
mt1180748	Bhumika Chopra
mt1180749	Burada Priyanka
mt1180750	Chirag Bhatt
mt1180751	Chirag Singla
mt1180752	Dharmendraahirwar
mt1180753	Girjesh Singh
mt1180754	Hetvi Jethwani
mt1180755	Ichha Jayendrarathod
mt1180756	Ishant Bhaskar
mt1180757	Khushpreet Singh
mt1180758	Kunal Mitra
mt1180759	M Santosh
mt1180760	Mukul Kumar
mt1180761	P Vishnu Teja
mt1180762	Prem Narayandehariya
mt1180763	Punit Shyamsukha
mt1180764	Rachit Mittal
mt1180765	Rahul Kumar
mt1180766	Ritvik Ajaria
mt1180767	Sachin Meena
mt1180768	Shaurya Raj Singh
mt1180769	Silky Singh
mt1180770	Subhalingam D
mt1180771	Uddharshkotahwala
mt1180772	Vicky Nehra
mt1180773	Yash Gohel
mt1180774	Yash Jain
mt5100628	Vishnu P S
mt5100631	Trilok Chand Meena
mt5110585	Aman Arora
mt5110600	Gaurav Singh
mt5110605	Karan Singh Koli
mt5120584	Abhishek Mishra
mt5120593	Harsh Maan
mt5120605	Mohinder Pratap Singh Meena
mt5120616	Sanjay Karela
mt6130581	Adarsh Kumar
mt6130582	Aditya Narayan Singh
mt6130583	Akshay Royal
mt6130586	Ankit Kumar
mt6130602	Masa Akhil
mt6130608	Pankaj
mt6140362	Raunak Lohiya
mt6140502	Anshul Basia
mt6140551	Alankar Meshram
mt6140552	Amit Kumar
mt6140553	Darpan Gupta
mt6140555	Gautam Kumar
mt6140556	Guguloth Ajay Kumar
mt6140557	Kishan Sahu
mt6140558	Nitin Kumar
mt6140559	Paramkusham Sai Satvik
mt6140560	Preetham P
mt6140561	Rishabh Maheshwari
mt6140562	Rishabh Raj
mt6140563	Ruby
mt6140564	Sahil Bhatnagar
mt6140566	Shubham Paliwal
mt6140567	Siddhant Gupta
mt6140568	Tanya
mt6140569	Vaibhav Gupta
mt6140570	Vishavjeet Singh
mt6140571	Yash Tiwari
mt6140663	Kapil Ahuja
mt6150113	Nabeel Javed
mt6150358	Pulkit Goel
mt6150373	Sandeep Kumar
mt6150551	Ajay Yadav
mt6150552	Anurag Uikey
mt6150553	Aryaman Garg
mt6150554	Ayush Agarwal
mt6150555	Ayush Malpani
mt6150556	Ayush Singhal
mt6150557	Bhuvnesh Khandelwal
mt6150558	Chinmay Singh
mt6150559	Deependra Kumar Meena
mt6150561	Md Tausif Alam
mt6150562	Nikhil Kumar Agrawal
mt6150563	Pranav Kumar
mt6150564	Randheer Kumar Gautam
mt6150565	Ravi Khannawalia
mt6150566	Samarth Gulyani
mt6150567	Siddharth Khera
mt6150568	Tarun Gupta
mt6150569	Utsav Sen
mt6150570	Vishwash Tetarwal
mt6160078	Tanuj Garg
mt6160645	Siddhartha Biswas
mt6160646	Upadhyayula Sethu Madhav
mt6160648	Abhay Saxena
mt6160649	Masini Venu Madhav Reddy
mt6160650	Ashray Aman
mt6160651	Arushi Agrawal
mt6160652	Harsh Pare
mt6160653	Sajal Gupta
mt6160654	Mehak Aggarwal
mt6160655	Saurav Kumar Sharma
mt6160656	Gandharva Kumar
mt6160657	Omprakash Swami
mt6160658	Anish K K
mt6160659	Pulkit Shakya
mt6160660	Vasu Dev Singh
mt6160661	Praveen Barahdia
mt6160662	Aditya Singh
mt6160664	Kunjan Prasad
mt6160677	Pavani
mt6160751	Vaibhav Saxena
mt6170078	Alok Kumar
mt6170207	Gauri Gupta
mt6170250	Sharut Gupta
mt6170499	Tanishq Gupta
mt6170771	Aman Kumar Sahu
mt6170773	Arun Kumar K V
mt6170774	Harshit Khanna
mt6170775	Jashandeep Singh
mt6170776	Kiran Patbandhi
mt6170777	Konakandla R V Vamsi Krishna
mt6170778	Kunal Khetan
mt6170779	Mayank Vilas Bulkunde
mt6170780	Nihar Patel
mt6170781	Patel Neel Amitkumar
mt6170782	Patel Nehulbhai Hareshbhai
mt6170783	Prajwal Singh
mt6170784	Shaurya Goel
mt6170785	Shubh Gupta
mt6170786	Sri Krishna Sahoo
mt6170787	Sujay D
mt6170788	Utsav Singhal
mt6170789	Vinit Saini
mt6170855	Sumanth Varambally
mt6180776	Aakash Garg
mt6180777	Adwaith H Sivam
mt6180778	Ashwini Kumar
mt6180779	Bhupender Dhaka
mt6180780	Boorgu Anirudgoud
mt6180781	Gaddam Kaushiksanjeev
mt6180782	Hina Meghwal
mt6180783	Khushi Kalpeshpathak
mt6180784	Naimisha Koppala
mt6180785	Krishna Chaitanya Reddy Tamata
mt6180786	Pranaav
mt6180787	Prateek Singh
mt6180788	Ramneek Singhgambhir
mt6180789	Rashul Chutani
mt6180790	Ravi Pushkar
mt6180791	Rishu Raj
mt6180792	Sakshi Manojbhandari
mt6180793	Satendra Singhparashar
mt6180794	Shreyanshchoudhary
mt6180795	Snehil Grandhi
mt6180796	Varre Harshavardhan
mt6180797	Vishal Meena
mt6180798	Zuhaib Ul Zamann
nrz128500	Vijay Shankar Kanthan
nrz138184	Gopal Babu
nrz148222	Pooja Sahni
nrz188579	Ankit Gupta
ph1090715	Devendra Kumar Meshram
ph1100849	Khushwant Singh
ph1110846	Kshitiz Singh
ph1110855	Nirbhay Gupta
ph1120826	Amarkant
ph1120883	Vikas Damor
ph1130827	Akash
ph1130836	Annu Kumar Tigga
ph1130849	Kedam Venkateshwargoud
ph1130867	Satveer Gurjar
ph1140790	Chaitanya Arya
ph1140794	Eeshan Jindal
ph1140795	Gaurav Kumar
ph1140796	Goverdhan Singh Garasiya
ph1140800	Kaushtav Atri
ph1140805	Nikunj Verma
ph1140824	Shantanu Nigam
ph1140835	Velpuri Shiva Rama Krishna Chaitha
ph1140840	Yogesh S
ph1150782	Abhijeet Kishore
ph1150783	Abhishek Kumar Kamal
ph1150784	Aditya Tripathi
ph1150785	Agrawal Anurag Rajesh
ph1150786	Akanksha Sharma
ph1150787	Aman Singal
ph1150788	Aman Pawar
ph1150789	Amit Kumar
ph1150790	Amit Kumar
ph1150791	Anand Beniwal
ph1150792	Aneerendra
ph1150793	Ankesh Kumar
ph1150794	Ankit Idwani
ph1150795	Anshul Kumar
ph1150796	Cheena Agarwal
ph1150797	Deshmukh Aditya Pravin
ph1150798	Deshpande Ameya Uday
ph1150799	Divyansh Mandhani
ph1150800	Gaikwad Apurva Sanjay
ph1150801	Gotur Srinivas Venkatesh
ph1150802	Harsh Pitaliya
ph1150803	Himalik Singh
ph1150804	Indravath Ramkoti
ph1150805	Jitender Meena
ph1150806	Kartik Agarwal
ph1150807	Kartik Goyal
ph1150808	Kaustubh Singhi
ph1150809	Ketaki Wasnikar
ph1150810	Kowtharapu Sai Raghuram
ph1150811	Madhavaram Akshar
ph1150812	Nayantara Mudur
ph1150813	Nilaksh Agarwal
ph1150814	Pawar Gopal
ph1150815	Poorva Agrawal
ph1150816	Prajwal Umatiya
ph1150817	Raj Kumar Ajay
ph1150818	Rakesh Nath
ph1150819	Rishi Raj
ph1150820	Rudraksh Gupta
ph1150821	S Balaji
ph1150822	Sagare Chetan Basawaraj
ph1150823	Saharsh Sikaria
ph1150824	Sarvesh Agarwal
ph1150825	Seemant Tejasvi
ph1150826	Shashank Kumar
ph1150827	Shivam Goyal
ph1150828	Shivam Baghel
ph1150829	Siddharth Pandit
ph1150831	Sparsh Sharma
ph1150832	Sumit Kumar
ph1150833	Tapish Narwal
ph1150834	Tushar Maurya
ph1150836	Vikrant Singh
ph1150837	Vishnu Raghuraman
ph1150838	Yarlagadda Sankara Dinesh
ph1150839	Yashaswi Gangwar
ph1150840	Yashti Agrawal
ph1150841	Rahul Kumar
ph1160086	Swarnava Sanyal
ph1160540	Ashutosh Kumar Mishra
ph1160542	Hardik Sharma
ph1160543	Saurabh Gupta
ph1160544	Pradyumna P Belgaonkar
ph1160547	Suraj Bahuguna
ph1160548	Govind Nanda
ph1160549	Rudraksh Agarwal
ph1160550	Suraj Goel
ph1160551	Muhammad Mursaleen
ph1160552	O K Varun
ph1160553	Mudit Garg
ph1160554	Yash Badola
ph1160555	Ayush De
ph1160557	Pranav Jain
ph1160560	Prathamesh Pradeep Divekar
ph1160561	Majumdar Adhish Tapas
ph1160562	Harikrishnan C K
ph1160563	Animesh Naresh Deshmukh
ph1160564	Deepak Sharma
ph1160565	Raj Agarwal
ph1160566	Prashant Singh Chandel
ph1160567	Gobind Singh
ph1160568	Ritwik Sain
ph1160569	Anmol Ojha
ph1160570	Gohil Nath
ph1160572	Prince Sonu Mayank
ph1160573	Varunesh Kumar Vishwakarma
ph1160574	Akshansh Choudhary
ph1160575	Sumit Singh
ph1160577	Ashish Gautam
ph1160578	Yogesh Yadav
ph1160579	Sonal Kumari
ph1160580	Shubham Verma
ph1160581	Gundelli Poojith
ph1160583	Tanushrii Babu Ramesh
ph1160584	Nandam Yashwanth
ph1160585	Abhijeet Gurjar
ph1160586	Raghav Kumar
ph1160587	Soumyadeep Sarkar
ph1160588	Prajwal Singh
ph1160589	Aditya Verma
ph1160590	Deepanshu
ph1160591	Aman Verma
ph1160592	Dileep Paswan
ph1160593	Aryan Verma
ph1160594	Shivaiy Arora
ph1160595	Prashant Meena
ph1160596	Deepak Meena
ph1160597	Abhinandan Kumar Singh
ph1160599	Aman Mandia
ph1170801	Abhilash Golla
ph1170802	Abhinav Singh
ph1170803	Abhipray Devendra Dohane
ph1170804	Abhishek Rao
ph1170805	Aditya Hemantkumar Shete
ph1170806	Akshat Agarwal
ph1170807	Akshay Kumar Jaiswal
ph1170808	Akshit Katiyar
ph1170810	Aradh Bisarya
ph1170811	Arnav Gupta
ph1170812	Chirag Agarwal
ph1170813	Deepak Kumar
ph1170814	Dhanashree Mehar
ph1170815	Divyansh Verma
ph1170816	Hritik Khandelwal
ph1170818	Jayesh Patidar
ph1170819	Jheel Rathod
ph1170820	Kaavya Sahay
ph1170821	Saloni Baweja
ph1170822	Koduru Sudheer
ph1170823	Kokkirala Jwala Eswar Prasad
ph1170824	Koppala Sri Sai Ruthvik
ph1170826	Kunal Gupta
ph1170827	Lokesh Bankuru
ph1170828	Manmeet Kumar Kundal
ph1170829	Mansi Chauhan
ph1170830	Mitali Agrawal
ph1170831	Nandakrishna K S
ph1170832	Navneet Singh
ph1170833	Nilesh Goel
ph1170834	Nitesh Kumar Meena
ph1170835	Om Prakash Prajapati
ph1170838	Pratyay Pande
ph1170839	Prince Himadri Mayank
ph1170840	Priyamvad Tripathi
ph1170841	Purankar Sarvesh Shantanu
ph1170843	Raju Kumar
ph1170844	Raman Kumar
ph1170845	Ritika Malik
ph1170846	Ritvik Ranjan
ph1170847	Akash Sharma
ph1170848	Robin Kumar
ph1170849	S Chethus
ph1170850	Shubham Jain
ph1170851	Sakshi Gupta
ph1170852	Sonakshi Gupta
ph1170853	Spandan Mishra
ph1170854	Sri Vasudha Hemadri Bhotla
ph1170856	Surabhi Gupta
ph1170857	Suraj Punia
ph1170858	Vijay Chaurasiya
ph1170859	Vishal Verma
ph1170860	G Akshay
ph1170942	Raghav Chaturvedi
ph1180801	Amandeep
ph1180802	Amrita Priyam
ph1180803	Archit Gupta
ph1180804	Ayan Das
ph1180805	Ayantikasengupta
ph1180806	Bhaanu Ashok
ph1180808	Gaurav Meena
ph1180809	Harsh Vardhanchandrakar
ph1180810	Jayesh Anand
ph1180811	Kartikeya Rai
ph1180812	Kumar Vinjeet
ph1180813	Maibram Vasundharadevi
ph1180814	Manas Verma
ph1180815	Maulik Bansal
ph1180816	Mihir Gupta
ph1180817	Mohammad Shakib
ph1180818	Muskaan Jain
ph1180819	Nandan I P
ph1180820	Nicholas Francisalappat
ph1180821	Nishchaltripathi
ph1180822	Nitin Kumar
ph1180823	Parteek Kumar
ph1180824	Parth Raina
ph1180825	Parvathi Anil
ph1180826	Prakhar Bangaria
ph1180827	Praveenviswanathan
ph1180828	Priyanka
ph1180829	Punnapureddy Saikumar
ph1180830	Pushp Raj
ph1180831	Rahul Singh
ph1180832	Rajveer
ph1180833	Rakshit Rao
ph1180834	Ramit Singh
ph1180835	Raushan Kumar
ph1180836	Riaz Ahmad
ph1180837	Rishabhchoudhary
ph1180838	Rishu Kumar
ph1180839	Rithik Kukreja
ph1180840	Ruhanshi Barad
ph1180841	Sakshi Mittal
ph1180842	Samarpit Sahoo
ph1180843	Samarth Bhaskar
ph1180844	Sangye Choden
ph1180845	Kartikeya Patel
ph1180846	Satyaketu Meena
ph1180847	Shivaksh Rawat
ph1180848	Shreyank Janardhanbhat
ph1180849	Sibasish Mishra
ph1180850	Smipra Prashantjambhulkar
ph1180851	Subham Das
ph1180852	Sukanya Ghosal
ph1180853	Suyash Singh
ph1180854	T Kishore Kumar
ph1180855	Unik Anilwadhwani
ph1180856	Urvashi Garg
ph1180857	Yash Milindlokare
ph1180858	Yashasvisuryavansh
ph1180859	Shubham Kumar
ph1180860	Zulfikar Ali
pha172189	Shantanu Sharan Agarwal
pha172190	Mayank Mishra
pha172192	Hansha Pandey
pha172194	Noel Saji Paul
pha172196	Md Nayeem Akhter
pha172198	Jeetendra Gour
pha172200	Shital Devinder
pha172201	Nida Khan
pha172203	Anuj Saxena
pha172204	Arpit Gupta
pha172205	Prabhav Joshi
pha172206	Shalomin Sharma
pha172207	Shweta Sati
pha172208	Surya Kant Singh
pha172828	Anat Siddharth
pha172829	Sunita Bhatt
pha172852	Shruti Agrawal
pha182345	Pranav Wani
pha182347	Amol Deo
pha182348	Shakti Singh
pha182349	Muskan Kularia
pha182350	Aman Mishra
pha182352	Manish Kala
pha182353	Shreyansh Ratnam Khare
pha182354	Sakshi
pha182355	Rohit
pha182356	Surya Kanta Tarenia
pha182358	Shruti Jain
pha182359	Anjika Kumari
pha182360	Ashutosh Mishra
pha182362	Gaurav Kumar
pha182365	Shashank Shekhar
pha182366	Ritish Kamboj
pha182867	Dipti Ranjan Rana
phm172210	Vikas Chahar
phm172211	Anmol Shukla
phm172212	Gaurav Singh
phm172213	Swapnil Barthwal
phm172215	Keshav Kumar Sharma
phm172216	Hemanshu Dua
phm172218	Aman Sharma
phm172219	Arun Kumar Jaiswal
phm172220	Shubham Saini
phm172221	Amit Kumar
phm172224	Richa Mudgal
phm172225	Deeksha Gupta
phm172226	Nutan Negi
phm172688	Neha
phm172898	Anjali Jain
phm182421	Nitish Kumar Shrivastava
phm182422	Rajni
phm182423	Rishikesh
phm182424	Vivek Dey
phm182425	Shabbin Rahiman K
phm182426	Ashish Joshi
phm182427	Azminul Jaman
phm182428	Prabal Dweep Khanikar
phm182430	Gazal Gupta
phm182431	Hardeep Singh
phm182432	Namrata Bansal
phm182433	Sonika Singh
phm182434	Ashutosh Kumar
phm182435	Sumit Kumar
phm182436	Md Shahin Alam
phm182438	Vikas Jangra
phm182439	Savita Sahu
phm182441	Keshav Kumar
phm182442	Naina
phm182443	Sanjeev Kumar
phs167153	Kewal Anand
phs177121	Aditya Saxena
phs177122	Akashdeep
phs177123	Amar Pal
phs177127	Anuj Kumar Singh
phs177128	Anurag Saini
phs177129	Arun Mondal
phs177130	Basudev Mandal
phs177131	Bijaya Kumar Sahoo
phs177132	Chetna
phs177133	Deepak
phs177135	Harish Kumar
phs177137	Khushboo
phs177138	Krishan Kantiwal
phs177139	Kriti Jain
phs177140	Kunal Prajapati
phs177141	Mani Khurana
phs177142	Mathukmi Jajo
phs177143	Mohit Pal
phs177144	Mukesh
phs177145	Neeraj Singh Rawat
phs177146	Neha Upadhyay
phs177147	Nidhi Srivastava
phs177148	Nikita
phs177149	Pampa Dey
phs177150	Partha Sarathi Banerjee
phs177151	Piyush Yadav
phs177152	Prabhat Manna
phs177153	Prakash Kumar Pathak
phs177154	Prashant Pandey
phs177155	Pratik Aman
phs177156	Priya Singh
phs177158	Pulkit Gupta
phs177159	Rahul Patel
phs177160	Ramniwas Meena
phs177161	Riddhi Ghosh
phs177162	Ritu Rani
phs177163	Sachin Raturi
phs177164	Sanchit Jain
phs177165	Sandeep Kushawah
phs177166	Sanju Golui
phs177167	Satyam Kumar Gupta
phs177168	Shahjad Ali
phs177169	Shashank Shekhar Pandey
phs177170	Shashikant Saini
phs177172	Simmie Jaglan
phs177173	Vishvajeet Sinha
phs187111	Abhishek Kumar
phs187112	Abhishek Verma
phs187113	Aditya Anand
phs187114	Akash Mishra
phs187115	Akriti Singh
phs187116	Aniket Dwivedi
phs187117	Ankit Sharma
phs187118	Ankita Rawat
phs187119	Arnab Ghosh
phs187120	Ashish Raj
phs187121	Ashutosh Raj
phs187123	Avantika Gautam
phs187124	Ayan Halder
phs187126	Chandan
phs187127	Chandra Sen
phs187128	Debabrata Sahu
phs187129	Deepak
phs187130	Deepak Verma
phs187133	Dhalia Trishul
phs187134	Ishani De
phs187135	Jagannath Dash
phs187136	Khushbu Sharma
phs187137	Kiran
phs187138	Lalit Hari
phs187139	Manisha
phs187140	Manoj Gupta
phs187141	Mohit Verma
phs187142	Nakul Kumar
phs187143	Neha Dhanka
phs187144	Poshika Gandhi
phs187145	Puneet Pareek
phs187146	Rahul Aggarwal
phs187147	Rahul Puri
phs187148	Rajendra Singh Negi
phs187149	Ravi Kumar Meena
phs187150	Rohit Juneja
phs187151	Rohit Kumar
phs187152	Sakshee
phs187153	Sanjay Kumar Sinha
phs187154	Sarita Kumari
phs187155	Shelake Mukund Nanasaheb
phs187156	Shobha Ram Choudhary
phs187157	Shouvik Bhattacharjee
phs187158	Shouvik Sarkar
phs187159	Shubham Kumar Debadatta
phs187160	Shweta
phs187161	Soumyaranjan Khuntia
phs187162	Subham Naskar
phs187163	Sumit Sharma
phs187164	Suresh Kumar Bhambhu
phs187165	Suvam Kumar Behera
phz118312	Parul Jain
phz118318	Ashish Dwivedi
phz118319	Priyanka Sharma
phz128036	Divyanshu Bhatnagar
phz128046	Jitender
phz128054	Faiz Kp
phz128318	Brajesh Nandan
phz128323	Sreekanth Maddaka
phz128480	Manjari Garg
phz128482	Prabhat Kumar
phz128484	Parvinder Kaur
phz128490	Megha Singh
phz128493	Sunil Kumar
phz128494	Amit Kapoor
phz128495	Pradeep Kumar
phz138188	Babita Kumari
phz138190	Deepak Kumar
phz138193	Jasvendra Tyagi
phz138194	Manisha Arora
phz138195	Priyanka Lochab
phz138198	Ranjeet Dwivedi
phz138202	Sugeet Sunder
phz138478	Chandan Sharma
phz138479	Leeladhar
phz138481	Preeti Garg
phz138482	Ravi Pathak
phz138488	Vishesh Kumar Dubey
phz138569	Ramesh Kumar
phz138570	Sandeep Kumar
phz148019	Deshraj Meena
phz148103	Harsh Gupta
phz148104	Hemlata
phz148105	Inderpreet Kaur
phz148107	Lalita Devi
phz148108	Monika
phz148109	Nabarun Saha
phz148110	Naveen Sisodia
phz148112	Parswajit Kalita
phz148113	Parul Raturi
phz148115	Pragati Aashna
phz148116	Pratisha Gangwar
phz148118	Ravi Kant
phz148121	Rupali Das
phz148123	Sunil Kumar
phz148124	Surbhi Sharma
phz148125	Sushanta Kumar Pal
phz148126	Veena Singh
phz148127	Vinod Parmar
phz148223	Mukesh Kumari
phz148344	Akash Kumar
phz148345	Bhera Ram Tak
phz148347	Konark Bisht
phz148348	Mujeeb Ahmad
phz148349	Shashank Kumar Gahlaut
phz148350	Sonal Singhal
phz148351	Swagato Sarkar
phz148352	Vanjula Kataria
phz148353	Vineet Barwal
phz148354	Vivek Semwal
phz158173	Anisha Pathak
phz158176	Ankit Butola
phz158179	Huidrom Hemojit Singh
phz158182	Mohammad Adnan
phz158183	Nisha
phz158187	Poornima Shakya
phz158193	Sourav Patranabish
phz158196	Vishakha Kaushik
phz158197	Vishal Bhardwaj
phz158252	Abhishek
phz158255	Ruchi
phz158377	Kalpak Gupta
phz158378	Nithin V
phz158379	Pradeep Kumar
phz158380	Shahrukh Salim
phz158383	Munish
phz158385	Atul Kumar Dubey
phz158388	Mayank Gupta
phz162023	Gauri Arora
phz162024	Mansi Butola
phz162025	Sunaina
phz162039	Shilpa Tayal
phz168199	Vikas Kumar
phz168205	Aditya Singh
phz168206	Krishnendu Samanta
phz168207	Rajneesh Joshi
phz168210	Ekta
phz168220	Preetam Singh
phz168222	Ravi Kumar
phz168225	Moumita Naskar
phz168378	Gaytri Arya
phz168379	Rajni Bala
phz168380	Priyanka Sharma
phz168382	Hitesh Kumar
phz168384	Manish Dwivedi
phz168385	Govind
phz168388	Sheetal Punia
phz168389	Pinki Devi
phz168391	Debarshi Basu
phz168392	Mamta
phz168394	Gulshan Kumar
phz168396	Kapil Narang
phz178371	Soumyarup Hait
phz178374	Aditya
phz178375	Sooryansh Asthana
phz178378	Anand Nivedan
phz178381	Hemlata Rani
phz178382	Asha Kumari
phz178384	Rajat Dhawan
phz178385	Subhajit Karmakar
phz178387	Manish Kumar
phz178403	Dheeraj Kumar
phz178404	Kacho Imtiyaz Ali Khan
phz178405	Chandan Kumar Vishwakarma
phz178407	Sovinder Singh Rana
phz178408	Isha Yadav
phz178409	Abhilasha Chouksey
phz178411	Virendra Kumar
phz178612	Divya Prakash Dubey
phz178614	Narinder Kaur
phz178615	Preeti Sharma
phz178617	Madan Lal Sharma
phz178618	Abhishek Ghosh
phz178619	Aysha Rani
phz178620	Shivani Sharma
phz178622	Chandra Prakash Verma
phz178623	Nanhe Kumar Gupta
phz178625	Sandeep Kumar
phz178626	Ashwani Kumar Verma
phz178627	Khushboo Singh
phz178628	Waseem Ul Haq
phz178660	Mansi Agrawal
phz182357	Apoorv Pant
phz188319	Sunil Bhatt
phz188320	Rajni Bala
phz188321	Deepika
phz188322	Sheetal Raosaheb Kanade
phz188323	Lalit Pandey
phz188325	Ruchi Sharma
phz188326	Sourodeep De
phz188327	Pankhuri Gupta
phz188328	Nishant Kumar Pathak
phz188329	Hardhyan
phz188330	Pallavi Aggarwal
phz188331	Sarjana Yadav
phz188332	Shilpi Bose
phz188333	Manisha
phz188334	Jayashree Pati
phz188336	Jitendra Nath Acharyya
phz188337	Diksha Garg
phz188338	Rita Majumdar
phz188339	Manjari Jain
phz188340	Ankit Kumar
phz188341	Kshetra Mohan Dehury
phz188344	Durgesh Kumar Ojha
phz188345	Baby Komal
phz188346	Jay Deep Gupta
phz188347	Disha Arora
phz188348	Savita Rani
phz188350	Sarvesh Bansal
phz188352	Pallabi Parui
phz188353	Tamanna Punia
phz188355	Shivangi Srivastava
phz188356	Subhasish Bag
phz188357	Fauzia
phz188358	Vireshwar Mishra
phz188359	Ajay Kumar
phz188361	Rahul
phz188362	Vikki Anand Varma
phz188363	Omshankar
phz188364	Akash Anand Verma
phz188365	Pradeep Kumar
phz188367	Simranjot Kaur Sapra
phz188368	Neeraj Pandey
phz188369	Sanjay Kumar Kedia
phz188370	Priyanka Mann
phz188372	Sandeep
phz188409	Abhishek Sharma
phz188410	Amar Kumar
phz188411	Amish Kumar Gautam
phz188412	Arjun Kumar
phz188413	Basant Kumar
phz188414	Dhananjay Verma
phz188415	Himanshu
phz188416	Jagori Raychaudhuri
phz188417	Jamal Ahmad Khan
phz188418	Jyoti Yadav
phz188419	Kothapalli Srikanth
phz188420	Mahendra Pratap Singh
phz188421	Mohit
phz188422	Pariksha Malik
phz188423	Pooja Pal
phz188424	Pramila Thapa
phz188425	Pratiksha Choudhary
phz188426	Preeti Bhumla
phz188427	Prithu Pandey
phz188428	Rakesh Kumar
phz188429	Ram Singh Yadav
phz188430	Rekha Agarwal
phz188431	Rishikesh Kushawaha
phz188432	Saurabh Pandey
phz188433	Vaibhav Sharma
phz188434	Vikash Kumar Yadav
phz188435	Vipul Upadhyay
ptz118435	Savita Meena
ptz128195	Shilpi Sharma
ptz128348	Banpreet Kaur
ptz138207	Reshu Tyagi
ptz148397	Agni Kumar Biswal
ptz158200	Ifra
ptz158203	Smrutirekha Mishra
ptz158204	Sucharita Sethy
ptz158205	Sumbul Hafeez
ptz168104	Srijita Purkayastha
ptz168105	Shubhra Goel
ptz168108	Shikha
ptz168377	Deepika Sharma
ptz178042	B Ashok Kumar
ptz178045	Kalpana Pandey
ptz178046	Anubhav Kumar
ptz178049	Saroj Kumar Samantaray
ptz178050	Aanchal Jaisingh
ptz178051	Shivani Goyal
ptz178052	Tina Joshi
ptz178055	Debarghya Saha
ptz178056	Kanupriya Nayak
ptz178520	Ajit Babarao Bhagat
qiz188545	Sudeep Banad
qiz188607	Madhumita Ramakrishna
qiz188608	Mayuri Kashyap
qiz188609	Pooja Vardhini Natesan
qiz188613	Siddhant Varshney
qiz188614	Chourasia Vallari Ramesh Maneesha
qiz188615	Vikramsingh Karansingh Roday
qiz188617	Simran Agarwal
qiz188618	Alok Kumar Ray
rdz128213	Vinod Kotwal
rdz138209	Nalini Srinivasan
rdz148130	Ajay Patel
rdz148131	Bhaskar Jha
rdz148134	Niyati Raj
rdz148136	Supreet Kaur
rdz148137	Vandit Vijay
rdz148251	Suneet Anand
rdz148386	Mukesh Jain
rdz148398	Ashu Jain
rdz158257	Ayusman Swain
rdz158258	Farhat Bano
rdz158261	Shivali
rdz158452	Goldy Shah
rdz158453	Uma Ghanshyam Dwivedi
rdz158454	Sonal Yadav
rdz158455	P Duraivadivel
rdz158457	Nitin Kumar
rdz168033	Himanshu Kumar
rdz168034	Pratibha
rdz168035	Umesh Chandra Sharma
rdz168036	Bhushan Rajendra Dole
rdz168037	Lopa Pattanaik
rdz168038	Asutosh Mohapatra
rdz168343	Shreya Tripathi
rdz168344	Lalit Anjum
rdz168354	Monu Dinesh Ojha
rdz168355	Amruta Prabhakar Khairnar
rdz168356	Shweta Kalia
rdz168357	Garima Singh
rdz168358	Vidhi Hitesh Bhimjiyani
rdz168359	Priyanka
rdz168361	Mandira Kapri
rdz168363	Farah Naaz
rdz168364	Swapna Sagarika Sahoo
rdz168365	Anjali Gautam
rdz168366	Smriti Kala
rdz178220	Rahul Jain
rdz178221	Kapil Singh
rdz178222	Mansi Mishra
rdz178223	Sushree Titikshya
rdz178224	Partha Pratim Das
rdz178226	Fasake Vinayak Dattatray
rdz178227	Sameer Mittal
rdz178228	Ayushi Srivastava
rdz178230	Gourav Choudhir
rdz178231	Saptarshi Dey
rdz178233	Falguni Pattnaik
rdz178234	Dalvi Vivek Suresh
rdz178235	Harshita Nigam
rdz178236	Adya Isha
rdz178238	Sagarkumar Yogesh Dhanuskar
rdz178239	Saurabh Samuchiwal
rdz178240	Monalisa Sahoo
rdz178242	Nidhi Hans
rdz178243	Papiya Bandyopadhyay Raut
rdz178244	Kartik Sapre
rdz178246	Vijay Laxmi Shrivas
rdz178247	Vikram Kapali Porwal
rdz178412	Biju I K
rdz178425	Gaurav Tomar
rdz178426	Pooja
rdz178576	Anand Madhukar
rdz178577	Abhay Tiwari
rdz178579	Mohd Aamir Khan
rdz178580	Sumit Kumar
rdz178582	Ajay Kumar Agrawal
rdz178642	Ankur Kumar
rdz178643	Sumati Sharma
rdz188244	Komalkant Adlak
rdz188245	Lahur Mani Verma
rdz188246	Ramineni Harsha Nag
rdz188247	Shazia Shareef
rdz188248	Divya
rdz188249	Nagesh Vikram Singh
rdz188637	Abhijeet Anand
rdz188638	Anilkumar Vallabhbhai Sakhiya
rdz188639	Bhani Kongkham
rdz188640	Dushyant Kumar
rdz188641	Koushalya S
rdz188642	Leena
rdz188643	Nikita Sanwal
rdz188644	Nitin Kumar Agarwal
rdz188645	Sameer Ahmad Khan
rdz188646	Subodh Kumar
rdz188647	Sukirti Joshi
rdz188648	Umesh Singh
rdz188649	Zoya Javed
rdz188650	Anchala Patel
rdz188651	Anuradha Vipul Janbade
rdz188652	Himanshu Arora
siy167532	Srishti Kulshrestha
siy177545	Anshul Mittal
siy177546	Prateek Narang
siy187502	Nishant Gupta
siy187504	Anurag Aggarwal
siy187505	Samiksha Agarwal
siy187538	B Shanker Jaiswal
siy187542	Kushal Pal Singh
smf176556	Ziyauddin Khan
smf176558	S Ritesh Kumar
smf176559	Arjun Murali
smf176561	Rohit Kumar
smf176562	Anish Kumar Govil
smf176564	Rupal Ranjan
smf176565	Aditya Vikram Vaid
smf176567	Sharun Kasyap S
smf176568	Shobhit
smf176570	Susovan Mondal
smf176571	Bangi Naresh
smf176572	Vignesh Kumar S
smf176573	Antay Halder
smf176574	Sneha Dinker
smf176575	Rigzin Angmo
smf176577	Namrdeep Kumar Guria
smf176578	Rama Krishna Rao Nukala
smf176580	Kumar Saurabh
smf176581	Bhaanuj Sharma
smf176582	Rajat Narula
smf176584	Sheenum Attri
smf176585	Ankit Mittal
smf176586	Prabhanshu Sharma
smf176587	Riya Patni
smf176588	D Mahesh Kumar
smf176589	Sriraam M
smf176590	Balla Anurag
smf176591	Muhammeed Marzook Suhail Om
smf176592	Anshul Koli
smf176593	Deepak Kumar
smf176595	Nabin Kumar Banzara
smf176596	Deewan Sonam Thoklang
smf176597	Shyam
smf176598	Anubhav Sagar Tewatia
smf176599	Sandeep Pal Singh Mehrok
smf176600	Joshi Mohit Hitesh Kumar
smf176601	Avneesh Abbi
smf176603	Neha Agarwal
smf176604	Khushbu Dhingra
smf176605	Mittal Suruchi Sushil
smf176606	Mayank Mishra
smf176607	Arnab Ray
smf176608	Akanksha Galyan
smf176609	Sujoy Sengupta
smf176610	Rahul Kumar
smf176611	Poornima Balram
smf176612	Latika
smf176613	Abhishek Sagar
smf176614	Ritika Jindal
smf176615	Velamala Divya
smf176616	Subhradeep Sahana
smf176617	Debdeep Mallick
smf176618	Sajil P Sathyanathan
smf176619	Rajarshi Choudhury
smf176620	Surbhi Jawanpuria
smf176621	Karan Kalra
smf176622	Chakrapani Cheripally
smf176623	Joel Thomas Rathnesh
smf176624	Snehal Manindra Mendhe
smf176625	Nikunj Garg
smf176627	Akanksha Mukherjee
smf176628	S Priya Ranjini Iyer
smf176629	Piyush Kumar Singh
smf176630	Kewat Kiran Chedilal
smf176631	Prasad Nitin Dinesh Kumar
smf176650	Aman Agarwal
smf176651	Parina Shrestha
smf176653	Ritika Kumari Tulsyan
smf176654	Pratik Verma
smf176655	Neeraj Dhurve
smf176657	Payel Rudra
smf176658	Tanuj Gupta
smf176659	Vallakatla Srivardhan
smf176660	Ravijeet Kumar
smf176669	Akshay Kumar Jha
smf176670	Akshay Bhardwaj
smf176671	Siddharth Rawat
smf176672	Archan Das
smf176673	Avik Sen
smf176674	Sanya Paruthi
smf176675	Akanksha Sharma
smf176676	Meghdipa Dey
smf176677	Umrajkar Shardul Anantrao
smf176678	Gunjan Wadhwa
smf176679	M Joseph Kishore
smf176680	Nikhil Kumar Daya
smf176681	Vishal Gayakwar
smf176682	Aakash Dayal
smf176683	Nakka Muralidhar
smf176684	Rishabh Jain
smf176685	Ankit Ashok Agarwal
smf176686	Divyansh Jain
smf176687	Pratyaksh Arora
smf186545	Shrinkhal Gupta
smf186546	Akshay Choudhary
smf186547	Prateek Taneja
smf186549	Harshit Singh
smf186550	Meera Krishna S P
smf186553	Nishant Kishore
smf186555	Raman Kumar
smf186556	Rahul Bambha
smf186558	Anmol Bansal
smf186559	Hareesh Aluri
smf186560	Mohit Mishra
smf186561	Patel Ruchit Hareshbhai
smf186562	Prashanth G
smf186564	Mohit Mahendra
smf186566	Ankita Dhamija
smf186567	Vikram Gosain
smf186568	Shubham Dixit
smf186569	Aritra Mukherjee
smf186571	Navin L
smf186572	Viraj Amrutlal Patel
smf186573	Himanshu Bansal
smf186575	Kunal Nitin Agarwal
smf186576	Krushnakant Bhakre
smf186577	Deshini Varun Teja
smf186578	Sumit Tyagi
smf186579	Ankit Sharma
smf186580	Manjot Kaur
smf186581	Mayank Jain
smf186582	S Sachin
smf186583	Akshay
smf186584	Sai Chandra Nakka
smf186585	Saurabh Acharjee
smf186586	Garima Kumar
smf186587	Gurtej Singh
smf186588	Harald Harris
smf186589	Chitransh Saxena
smf186591	Vinay Birhman
smf186592	A Shiva Kumar
smf186594	Mohit Prabhakar
smf186595	Sonam Radheshyam Geeta Verma
smf186602	Siddharth Chaturvedi
smf186603	Soubhik Basu
smf186604	Shivam Khurana
smf186605	Anuj Talwar
smf186606	Gaurav Maheswari
smf186607	Huchche Mayuresh Ambadas
smf186608	Kasturi Durga Babu
smf186610	Bhavsar Tanmay Manoj
smf186611	Apte Manas Narendra
smf186612	Rishab Goyal
smf186613	Nikhil Aggarwal
smf186614	Daksh Pradeep Jain
smf186615	Arjun Kumar Garg
smf186616	Manav Garg
smf186618	Kunal Jain
smf186620	S Narayan
smf186621	Ashish Chauhan
smf186622	P Amareswar
smf186623	Honey Chawla
smf186624	Pankaj Bansal
smf186625	Nitish Singhal
smf186626	Aman Kumar
smf186627	V Alekhya
smf186628	Ankush Bagley
smn156547	Deepali Mamtani
smn166637	Shyam Kumar
smn166639	Akshay Chauhan
smn166640	Rohit Grover
smn166641	Kulbir Singh Lamba
smn166642	Naveen Kumar Solanki
smn166644	Amit Dewan
smn166646	Shrey Wason
smn166647	Sreeraj Pr
smn166648	Samir Gupta
smn166649	Tripti Pandey
smn166650	Honey Raza
smn166651	Ankit Singh
smn166652	Akash Goel
smn166653	Chanchal Banerjee
smn166654	Akshay Kumar Jha
smn166656	Naveen Kumar Mishra
smn166657	Simranjeet Singh Ahuja
smn166658	Vinay Joshi
smn166659	Rahul Arora
smn166660	Ankit Kumar
smn166662	K S V L Narayana
smn166663	Disha Saxena
smn166665	Hemant Tiwari
smn166666	Aviral Rajeev
smn166667	Maninder Singh
smn166668	Rajesh Kumar
smn166669	Rishabh Kumar
smn166670	Sachin Tanwar
smn166675	Rajesh Kumar
smn166677	Niraj Kumar
smn166679	Thanaraj S
smn166680	Deepak Kumar
smn166683	Ammi Ruhama Tirkey
smn166684	Garima Gaur
smn166685	Vivek Kumar Gupta
smn166687	Rakhi Arora
smn166688	Ankush Grover
smn166689	Sipi Shambhavi
smn166690	Puskar Ray
smn166691	Sharandeep Singh Baluja
smn166692	Aashish Bhatla
smn166693	Swanit Suman
smn166696	Nishant Singhal
smn166698	Rajinder Partap Singh
smn166699	Mayank Krishan
smn166700	Himanshi Chhibber
smn166701	Rabab Fatima
smn166702	Nitesh Pareek
smn176502	Lokesh Saini
smn176503	Nitika Pasricha
smn176504	Devanshu Bajaj
smn176505	Kiruthika T K
smn176506	Prachi Bhambani
smn176507	Shivani Gupta
smn176508	Ayush Bansal
smn176509	Rahul Kumar
smn176510	S Sneha Lall
smn176511	Prachi Sinha
smn176513	Meenakshi Sharma
smn176514	Apnavi Chaturvedi
smn176516	Akansha Chaturvedi
smn176517	Rahul Gupta
smn176518	Deepak Kumar
smn176519	Shantanu
smn176520	Vikram Malik
smn176522	Ishanee Bajpai
smn176524	Nishant Kumar Bhatnagar
smn176525	Simardeep Singh Mendhiratta
smn176527	Nidhi Verma
smn176529	Sujit Kumar Biswas
smn176530	Priyanka
smn176531	Rakesh Kumar
smn176533	Sangh Shekhar
smn176534	Arjun Sharma
smn176535	Ashish Pandey
smn176536	Varun Dixit
smn176537	Arpit Kumar Rai
smn176538	Hayat Singh Mehra
smn176539	Yogesh Sharma
smn176540	Kanika Sharma
smn176541	Shivam Bawa
smn176542	Shiv Kumar Malik
smn176543	Abhishek Chaudhary
smn176544	Gaurav Saraswat
smn176545	Hemaabh Sethi
smn176546	Sonia Jain
smn176547	Mohd Tayyab Rao
smn176548	Manish Katyal
smn176550	Deepali Singh Parmar
smn176551	Suhail
smn176553	Abhinav Sharma
smn176554	Soumil Arora
smn176555	Shreya Wadhwa
smn176665	Vikas Sharma
smn176666	Rohit Rana
smn176667	Mayanka Mishra
smn176668	Shranik Kumar Jain
smn186501	Sudip Chatterjee
smn186503	Mujahid Ali
smn186504	Hitesh Gupta
smn186507	Parul Kapoor
smn186508	Hitesh Luthra
smn186509	Ketan Sharma
smn186513	Mayank Verma
smn186515	Amit Chawla
smn186517	Kawaljit Kaur
smn186518	Anusha Bhatnagar
smn186519	Ritambra Kotwal
smn186520	Samarth Saxena
smn186521	Vibhor
smn186522	Mayank Bansal
smn186523	Siddhant Cally
smn186524	Bhavna Bhati
smn186525	Sanjay Sharma
smn186527	Gaurav Solanki
smn186528	Gaurav Kumar
smn186529	Deepak Kumar Singh
smn186530	Amit Singh
smn186531	Mohini Bhalla
smn186532	Vishwa Raj
smn186533	Sukhdeep Singh
smn186534	Kshitij Baweja
smn186535	Razi Ahmad
smn186536	Aarushi Rawat
smn186537	Gaurav Tiwari
smn186538	Harshit Garg
smn186539	Sumit Pathak
smn186540	Sumit Mishra
smn186541	Prateek Singh
smn186542	Harmeet Kaur
smn186543	Bishwajeet Kumar Sisodiya
smt176632	Abhilash Garikapadu
smt176633	Snigdha Sharan
smt176636	Karthik A
smt176637	Vaibhav Sagar
smt176639	Sarath Murali
smt176640	V S Sandeep Vasabathula
smt176641	Bijay Kumar Prasad
smt176642	Akul Goel
smt176645	Naushi Khare
smt176647	Shubham Verma
smt176648	Aditya Kerhalkar
smt176649	Vatsal Mehra
smt176661	Meraj Habib Ansari
smt176662	Farasul Nisan
smt176664	Ashish Kumar
smt176695	Arjun Chattaraj
smt176696	Praneeth Kumar Reddy Takkolu
smt176697	Sai Ruthvik Rachakonda
smt176698	Kishalaya Kumar Tiwary
smt176699	Prakhar Agarwal
smt186596	Ambika Prasad Chanda
smt186597	Gokulkrishnan S
smt186630	Aastha Gupta
smt186631	Vibhishek Chandar K
smz128183	Kamal Karnatak
smz128185	Prakash Kumar Kedia
smz128435	Chitra Khari
smz128438	Deep Shree
smz128441	Vaghela Darshna Kantilal
smz128443	Manish Bansal
smz128445	Sunil Gupta
smz128446	Somnath Mitra
smz138270	Angela Susan Mathew
smz138274	Divya Choudhary
smz138275	Gautam Pant
smz138283	Vijayta Tukaram Fulzele
smz138495	Abhishek Kumbhat
smz138499	Dindayal Agrawal
smz138501	Mahamaya Mohanty
smz138502	Manasi Gupta
smz138504	Monika Singla
smz138506	Swati Agarwal
smz138507	Vinaya Prakash Singh
smz148140	Nisha Mary Thomas
smz148142	Rajbir Singh
smz148143	Umesh Kumar Shukla
smz148224	Sudhir Kumaratreya
smz148231	Smita Gupta
smz148410	Anushruti Vagrani
smz148412	Kaushik Dey
smz148414	Shiksha Kushwah
smz148416	Syed Ziaul Mustafa
smz148418	Noor Ulain Rizvi
smz158207	Anil Srivastava
smz158208	Devendra Kumar Pathak
smz158209	Harjit Singh
smz158212	Mohammad Mujahid
smz158214	Samta Jain
smz158328	Ashish Dwivedi
smz158329	Aman Bhatnagar
smz158330	Sauvik Kr Batabyal
smz158332	Pallavi Sethi
smz158335	Ahmad Mohd Khalid
smz158336	Vishal Sehgal
smz158338	Nimish Joseph
smz168017	Akanksha Malik
smz168018	Shikha Sota
smz168019	Purva Grover
smz168020	Akanksha Mishra
smz168021	Vikas Gupta
smz168023	Payal Dey
smz168025	Rishi Kant Kumar
smz168026	Sushil Punia
smz168029	Sudatta Kar
smz168030	Abhishek Chander Chanda
smz168031	Sunil Kumar Gulati
smz168441	Yukti Bajaj
smz168442	Pankaj Singh Rawat
smz168444	Ishita Batra
smz168447	Amit Kumar Gupta
smz168450	Anchal Patil
smz168451	Veepan Kumar
smz168452	Veenu Shankar
smz168453	Anbarasan Periyasami
smz168455	Neeraj Yadav
smz168459	Apurva Chamaria
smz178005	Chetna Batra
smz178006	Juhi Lohani
smz178008	Aarathi K
smz178009	Ayush Gautam
smz178010	Aqueeb Sohail Shaik
smz178011	Pooja Sarin
smz178012	Swapnil Sharma
smz178013	Umar Bashir Mir
smz178014	Prashant Kumar Gupta
smz178015	Shubhangini Rajput
smz178016	Saroj Bijarnia
smz178017	Vishakha Chauhan
smz178019	Chandra Pal
smz178020	Isha Vgoel (Nee Vasan)
smz178021	Vinod Bhatia
smz178022	Vipin Jacob Joseph
smz178023	Manu Kohli
smz178024	Bratindra Narayan Chakravorty
smz178414	Manish Kumar Srivastava
smz178439	Yashika Sardana
smz178440	Prashant Kumar
smz178441	Swati Garg
smz178442	Gulshan Kumar Gaur
smz178443	Aisha Kakkar
smz178444	Shefali Khare
smz178445	Anshika Singh Tanwar
smz178446	Aakanksha Bhatia
smz178448	Monica Shukla
smz178449	Shamita Garg
smz178450	Surbhi Gupta
smz178451	Samridhi Suman
smz178452	Monika Dahiya
smz178453	Iram Hasan
smz178454	Shiwangi Singh
smz178456	Sachin Yadav
smz178458	Anjali Sain
smz178459	K Dinesh
smz178460	Shikha Garg
smz178461	Nidhi Yadav
smz178462	Madan Mohan
smz178463	Gopinath Ks Narayan
smz178464	Ashish Kumar
smz188173	Aishwarya
smz188175	Vrinda Gupta
smz188177	Harshal Dilip Kate
smz188178	Arkajyoti De
smz188179	Akash Sharma
smz188180	Mamta Mishra
smz188181	Hitesha Yadav
smz188182	Sagarika Chaudhary
smz188183	Abhilasha
smz188184	Harchitwan Kaur Lamba
smz188185	Neeraj Jain
smz188186	Juhi Gupta
smz188187	Navendu Prakash
smz188189	Kavita Pandey
smz188190	Sarita Pasricha
smz188191	Mugdh Rajit
smz188192	Anuj Batta
smz188524	Aakanksha Shrawan
smz188525	Anita Makhijani
smz188526	Anita Mendiratta
smz188527	Ankit Pal
smz188528	Apurva Jha
smz188529	Arun Kumar Gupta
smz188530	Ayushi Deb Roy
smz188531	Bhupendra Singh Rawat
smz188532	Dhulika Arora
smz188533	Harshita Gupta
smz188534	Jan E Alam
smz188535	Jayant Kumar
smz188536	Mahima Jain
smz188537	Mansi Singh
smz188538	Neha Gosain
smz188539	Rashmi Chaudhry
smz188540	Rishabh Rajan
smz188541	Sachin Kumar Sharma
smz188542	Shailendra Kumar Singh
smz188543	Sunil Kumar
smz188544	Vikrant Giri
smz188611	Meghna Sethi
smz188612	Unnati Kapoor
smz188657	Seema Raj
srz178645	Gaurav Dogra
srz178646	Sharang Vaman Totekar
srz178647	Hema Garg
srz178648	Jayashree Mohanty
srz178649	Harshada Sharma
srz178650	Rishi Raj
srz188304	Neelesh Gangwar
srz188305	Shashank Shekhar
srz188381	Abhilasha Pant
srz188382	Nishant Birdi
srz188383	Maliha Ashraf
srz188606	Aashish
trz128068	Amit Sharma
trz128479	Mukund Kumar Sinha
trz148409	Nilanjana De Bakshi
trz158263	Leeza Malik
trz158264	Saibaba Darbamulla
trz168321	Richa Ahuja
trz178636	Thanigaivel Raja T
trz188280	Ranjana Soni
trz188281	Sunny Tawar
trz188282	Manish Kumar
tt1100909	Arun Kumar
tt1100974	Viplav Singh
tt1120302	Vikash Kumar Prabhakar
tt1130911	Avtansh Thakur
tt1130937	Karan Yadav
tt1130975	Varun
tt1130979	Vishal
tt1130982	Yogesh Yadav
tt1140115	P Shiva Kumar
tt1140169	Jyoti Chhanwal
tt1140185	Shaila Karole
tt1140228	Kiran Kumar Metta
tt1140588	Bharothu Venkata Suresh Babu
tt1140863	Akshay Sudam Padghan
tt1140866	Ankit
tt1140870	Arijit Bhardwaj
tt1140887	Hrithik Chaurasia
tt1140890	Karan Singla
tt1140896	Kshitij Khandelwal
tt1140905	Mudadla Siva Sai Rahul
tt1140911	Patel Hemanshukumar Ganeshbhai
tt1140912	Prabhat Paliya
tt1140920	Rahul Poonia
tt1140932	Sandeep Kumar
tt1140934	Sarisht Wadhwa
tt1140937	Shailesh Pabaeri
tt1140944	Surya Prakash Shukla
tt1150851	Aaditya Bhawsar
tt1150852	Aashi Agarwal
tt1150853	Abhigyan Srivastav
tt1150854	Ayushi Narula
tt1150855	Abhijeet Singh Solanki
tt1150856	Abhishek Agrawal
tt1150857	Abhishek Meena
tt1150858	Achin Goyal
tt1150859	Adit Gupta
tt1150860	Aditya Gera
tt1150861	Aditya Kumar
tt1150862	Akanksha Pragya
tt1150863	Minaal Dembla
tt1150864	Alok Yadav
tt1150865	Aman Agrawal
tt1150866	Amit Kumar
tt1150867	Amit Raj
tt1150868	Amit Doodhwal
tt1150869	Anand Yadav
tt1150872	Ankit Kumar Meena
tt1150873	Ankit Kumar
tt1150874	Ankush Mangal
tt1150875	Anmol Kumar
tt1150876	Anubhav
tt1150877	Arshdeep Singh Goindi
tt1150878	Ashutosh Singh
tt1150879	Atharva Chandra Singh
tt1150880	Ayush Gupta
tt1150881	Ayush Agrawal
tt1150882	Chaitanya Phuloria
tt1150883	Chhering Phunchog
tt1150884	Daksh Chandra Bansal
tt1150886	Deepak Mandloi
tt1150887	Deepali Verma
tt1150888	Deepanshu Gupta
tt1150889	Devansh Sharma
tt1150890	Dhawal Parmar
tt1150891	Dheeraj Kumar
tt1150892	Dhruv Gupta
tt1150893	Gupta Harsh Sunil
tt1150894	Gurinder Singh Saini
tt1150895	Hardik Upadhyay
tt1150896	Harshdeep Singh
tt1150897	Harshvardhan Arora
tt1150900	Jessica
tt1150901	Kamal Kant
tt1150903	Khalid Safi
tt1150904	Kshitij Jain
tt1150905	Kundan Kumar
tt1150906	Lakhan Kumar Vijayvargiya
tt1150907	Madhav Ranka
tt1150909	Madhuri Gurjar
tt1150911	Mayank Mishra
tt1150912	Mayank Soni
tt1150913	Md Sharjeel Azhar
tt1150916	Navneet Kumar
tt1150917	Navreet Kaur
tt1150918	Navya Sood
tt1150919	Nitesh Amliyar
tt1150920	Parth Dixit
tt1150921	Piyush Gupta
tt1150922	Prachi Gupta
tt1150924	Prashant Verma
tt1150925	Raghav Jain
tt1150926	Raj Kumar
tt1150927	Rajneesh Kaswan
tt1150928	Rakesh Kumar
tt1150929	Ram Raj Saini
tt1150930	Ramesh Yadav
tt1150931	Ravindra Pindel
tt1150932	Reewa Gautam
tt1150933	Sahil Kumar Kargwal
tt1150934	Sajan Kumar
tt1150935	Shashank Nigam
tt1150936	Shashwat
tt1150937	Sheetal Shraisth
tt1150938	Shivam Sahu
tt1150939	Shivjeet
tt1150940	Shrenivass J K
tt1150941	Shubham Tambi
tt1150942	Siddharth Rao Gautam
tt1150943	Sophiya Khan
tt1150944	Sumit Saini
tt1150946	Surya Bhushan
tt1150947	Sushant Kumar
tt1150948	Tanuj Singh
tt1150951	Vipul Gupta
tt1150952	Vishal Chand Kasotia
tt1150953	Waghmare Aditya Pramod
tt1150954	Yogesh Kundalwal
tt1150955	Yuktisha Rajpoot
tt1160663	Pooja Kumari Meena
tt1160821	Achal Jain
tt1160822	Ashutosh Agrawal
tt1160823	Harsh Garg
tt1160826	Maitreya Wagh
tt1160827	Prakhar Gupta
tt1160831	Shivam Kumar Jha
tt1160832	Sumakesh Mishra
tt1160834	Yatish Bansal
tt1160836	Himanshu Garg
tt1160837	Neharika Singhal
tt1160838	Kaushal Kumar
tt1160839	Eashan Bajaj
tt1160840	Vishavjit Sharma
tt1160841	Harish Jhajharia
tt1160842	Nikunj Sangwan
tt1160843	Aman Jindal
tt1160844	Khushank Singhal
tt1160845	Manas Singh
tt1160846	Harry Sehrawat
tt1160847	Nikhil Sareen
tt1160848	Archit Agarwal
tt1160849	Prateek Kinra
tt1160850	Anuj Chopra
tt1160852	Shrenic Tejawat
tt1160853	Shaurya Baveja
tt1160854	Anmol Ratn
tt1160855	Vani Batra
tt1160857	Prabhat Ranjan
tt1160858	Priyanshi Agarwal
tt1160859	Deuskar Aditya Ashutosh
tt1160860	Aashi Agarwal
tt1160861	Rohan Jain
tt1160862	Sarthak Inani
tt1160863	Navendu Vats
tt1160864	Samir Gupta
tt1160865	Utkarsh Reniwal
tt1160866	Yerule Adityaraj Dhananjay
tt1160867	Sumanyu Vyas
tt1160868	Ridhi Jain
tt1160869	Chintan Somani
tt1160870	Rahul Kumar
tt1160871	Vaibhaw
tt1160872	Mitanshu Muchhal
tt1160873	Saurabh Verma
tt1160874	Pranav Vilas Nagpure
tt1160875	Mamta Jat
tt1160876	Vikas Dhayal
tt1160877	Sudhanshu Singh
tt1160878	Preeti Saini
tt1160879	Mukesh Kumar
tt1160880	Ashish Siyag
tt1160881	Vijay Laxmi Seervi
tt1160882	Vikash Kumar
tt1160883	Renu Kumari
tt1160884	Rishav Kumar
tt1160885	Aman Yadav
tt1160886	Pushpendra Pratap Maurya
tt1160887	Harsh Gupta
tt1160888	Ankit Shekhar
tt1160889	Manoj Kumar
tt1160890	Vikas Yadav
tt1160891	Udit
tt1160892	Sonal Jangir
tt1160893	Abhishek Yadav
tt1160894	Rajkumar Dhakad
tt1160895	Rajapantula Uma Maheswara Rao
tt1160896	Ravi Golechha
tt1160897	Mayank Raj Yogi
tt1160898	Aamna Afroz
tt1160899	Yewale Jayant Avinash
tt1160900	Sheetal Suwalka
tt1160902	Seema Garhwal
tt1160903	Nishchal Arya
tt1160904	Abhishek Rawat
tt1160905	Shendre Unnati Milind
tt1160906	Satendra Kumar
tt1160907	Hansraj Sagar
tt1160908	Shubham Choudhary
tt1160909	Kapil Dev
tt1160910	Akanksha Kanwal
tt1160911	Viraj Singh
tt1160912	Shashi Ranjan Kumar
tt1160913	Parshant Kumar
tt1160914	Jaswinder Singh
tt1160915	Harsh Lal
tt1160916	Sumit Kumar
tt1160917	Ankit Batham
tt1160918	Ashok Meena
tt1160919	Ashish Meena
tt1160921	Rahul Meena
tt1160922	Piyush Painkra
tt1160923	Manish Painkra
tt1160924	Boda Pavan Kalyan
tt1160925	Vini Meena
tt1160926	Pranay Piyush
tt1160927	Manohar Jamra
tt1170871	Aadish Sharma
tt1170873	Aayush Sharma
tt1170874	Abhay Kulshreshtha
tt1170875	Alugu Sadharma Shekar
tt1170876	Aman Godara
tt1170877	Amartya Bhargava
tt1170878	Amit Jatav
tt1170879	Amlan Tekam
tt1170880	Anubhav Saini
tt1170881	Anurag Sheth
tt1170882	Anurag Thakre
tt1170883	Arpit Kumar
tt1170884	Ashutosh Gupta
tt1170885	Ashutosh Tiwari
tt1170886	Atul Awadhiya
tt1170887	Ayush Arora
tt1170888	Bhaavan Mantri
tt1170889	Chanpreet Singh
tt1170890	Deepak Kumar
tt1170891	Devendra Khairwa
tt1170892	Divya Prakash Singh
tt1170893	Sachin Siddharth
tt1170895	Rama Sankar Karmakar
tt1170896	Gandhi Sanket Sanjaykumar
tt1170897	Gautam Harsolia
tt1170898	Gogulamudi Dhanalakshmi
tt1170899	Harneet Singh Chauhan
tt1170900	Harsh Kankaria
tt1170901	Sushant Ranjan
tt1170902	Harshit Panchbhai
tt1170903	Himanshu Mishra
tt1170904	Jatin Mandar
tt1170905	Jay Surana
tt1170906	Jigyansu Nanda
tt1170907	Jitesh Kumar Meena
tt1170908	Jyoti
tt1170909	Kartikayan Sharma
tt1170910	Kashish Pragya Ghosh
tt1170911	Kasukurthi Jeevan Bhargav
tt1170912	Khushvant Singh Chahar
tt1170913	Nirmit Bansal
tt1170914	Kishor Kunal
tt1170915	Kriten Gurunath Patil
tt1170916	Naman Gautam
tt1170917	Kshitiz Jain
tt1170918	Kumar Priyanshu
tt1170919	Lakshya
tt1170920	Anmol Jain
tt1170921	Manoviraj Singh
tt1170922	Md Asif Anwar
tt1170923	Meenakshi Khanve
tt1170924	Mohammad Sahib Saify
tt1170925	Mohammed Zia Kamran
tt1170926	Mohan Lal Kuldeep
tt1170927	Monu Meena
tt1170928	Mudavathu Jashwanth Sai Ram Chouhan
tt1170929	Dhananjay Mathur
tt1170930	Anurag Singla
tt1170931	Navdeep Saini
tt1170932	Nikhil Kumar
tt1170933	Nishant Kumar Devthia
tt1170934	Nitesh Gunjan Painkra
tt1170935	Prajyot Shendage
tt1170936	Pramit Dadaraoji Kale
tt1170939	Priyanshu Gupta
tt1170940	Priydarshni
tt1170941	Kedia Lansu Naresh
tt1170943	Raghvendra Singh Rawat
tt1170944	Rakesh Untwal
tt1170945	Rashi Satsangi
tt1170947	Ritesh Kumar
tt1170948	Rohan Yadav
tt1170949	Ronak Gupta
tt1170951	Sagar Vijay Dudhe
tt1170952	Saharsh Rathi
tt1170953	Saket Kumar
tt1170954	Saksham Saxena
tt1170955	Samarth Agrawal
tt1170956	Samyak Jain
tt1170957	Shashank
tt1170958	Shaurya Jindal
tt1170959	Shlok Gautam
tt1170961	Shorya Jain
tt1170962	Siddharth Choubay
tt1170963	Paresh Meel
tt1170964	Somya Mehra
tt1170965	Srijan Kumar
tt1170966	Sudhanshu Ranjan
tt1170968	Surbhi Agrawal
tt1170969	Tushar Bansal
tt1170970	Uddesh Ashok Teke
tt1170971	Utkarsh Kumar
tt1170972	Vicky Akash Waghmare
tt1170973	Vinayak Meena
tt1170974	Yash Singh Chouhan
tt1170975	Zeeshan Ahmad
tt1170976	Richa Bajpai
tt1180866	Aashish Kumar
tt1180867	Abhinav
tt1180868	Abhinav Gupta
tt1180869	Abhishek Marandi
tt1180871	Aditya Joshi
tt1180872	Adrit Chaturvedi
tt1180873	Akshat Benara
tt1180874	Akshay Kumar
tt1180875	Aman Kishorsingh
tt1180876	Anil Meena
tt1180877	Ankit Sharesth
tt1180878	Anweshan Bor
tt1180879	Arjun Bhaskar
tt1180880	Arvin Goyal
tt1180881	Aryan Garg
tt1180882	Garvit Mittal
tt1180883	Ashirwad Swain
tt1180884	Ashish Patel
tt1180885	Ayush Maurya
tt1180886	Ayush Pandey
tt1180887	Ayush Patel
tt1180888	Balpartap Singh
tt1180889	Bhanu Bharadwaj
tt1180890	Bhosale Bhushanmukund
tt1180892	Deepanshu Singh
tt1180894	Dharmanshu
tt1180895	Dhruva Mittal
tt1180896	Didla Salem Devdas
tt1180897	Durgesh Nandini
tt1180898	Entla Saiteja
tt1180899	Gaurav Kumar
tt1180900	Gracy Kureel
tt1180901	Gudala Kameshabhinav
tt1180903	Himanshuchaudhary
tt1180904	Himnish Mishra
tt1180905	Ishaan Garg
tt1180906	Jaipal Brahmani
tt1180907	Kanha Patidar
tt1180908	Karan Goyal
tt1180909	Rohan Sharma
tt1180910	Kashish Verma
tt1180911	Kaushal Sad
tt1180912	Kumari Akanksha
tt1180913	Madhav Saini
tt1180914	Mahendra Kumar
tt1180915	Maria Sandalwala
tt1180916	Mayank Vijay
tt1180917	Meenal Singh
tt1180918	Modhavadiya Yash
tt1180919	Mohit
tt1180920	Mohit Choudhary
tt1180921	Mrinal Thakar
tt1180922	Mudit Garg
tt1180923	Mukul Kumar
tt1180924	Archit Bansal
tt1180925	Manas
tt1180926	Nitesh Kumar
tt1180927	Saksham Garg
tt1180928	Pande Gauravgajanan
tt1180929	Prakhar Sharma
tt1180930	Pranjal Gupta
tt1180931	Prashant Kumaryadav
tt1180933	Praveen Gupta
tt1180934	Priyanshirohilla
tt1180935	Puru Arora
tt1180936	Raghav Ajitsaria
tt1180937	Raghav Sharma
tt1180938	Rajeev Bhati
tt1180939	Rakesh Meena
tt1180940	Ranjana
tt1180941	Ravindra Abhaykudchadkar
tt1180942	Reet Kaur
tt1180943	Rhythm
tt1180944	Rishi Bordia
tt1180945	Saksham Singla
tt1180946	Sarthak Agrawal
tt1180947	Sarthak Pratik
tt1180948	Satwik Pandey
tt1180949	Satyam Kesari
tt1180950	Shamik Barman
tt1180951	Shantanu Agarwal
tt1180952	Sharon Mathur
tt1180953	Shivam Saket
tt1180954	Devesh Kumartrivedi
tt1180955	Shubham Chawla
tt1180956	Shubham Dahiya
tt1180957	Shubham Mittal
tt1180958	Shubham Sarda
tt1180959	Siddhant Dubey
tt1180960	Tarun Saini
tt1180961	Sidhant Prasad
tt1180962	Sumit Kumar Paul
tt1180963	Tanya Agarwal
tt1180964	Tarun Rajora
tt1180965	Tejashwanikamlesh
tt1180966	Tushita Sharma
tt1180967	Utkarsh Bansal
tt1180968	Utkarsh Gupta
tt1180969	Balmukund Mani
tt1180970	Vaibhav Vibhor
tt1180971	Varad Kailashkabade
tt1180972	Vedanshimaheshwari
tt1180974	Vishal Charan
tt1180975	Yash Anil Arya
ttc172061	Ankit Sharma
ttc172062	Deepti Mishra
ttc172063	Nitish Sharma
ttc172064	Pankaj
ttc172066	Shashank Chauhan
ttc172067	Shivam Gupta
ttc172068	Subhadeep Paul
ttc172069	Ravi Raj
ttc172070	Utkarsh Nigam
ttc172830	Satish Arun Kadam
ttc182038	Ankit Kumar Singh
ttc182039	Anushree Budhauliya
ttc182040	Dewali Mallick
ttc182041	Mayank Goel
ttc182042	Mukul Gupta
ttc182043	Priyanka Tiwari
ttc182044	Vishal Vinod Vhanbatte
ttc182045	Vivek Yadav
ttc182046	Ayishe Sanyal
ttc182047	Abhishek Kumar Singh
ttc182088	Hayelom Belay Asefaw
tte162228	Bharathi D
tte172042	Akshay Sarveshwar Rathi
tte172043	Aman Katiyar
tte172044	Gaurav Nagar
tte172049	Himanshu Singh
tte172050	Mani Gupta
tte172051	Rahul Dubey
tte172052	Shashi Sony
tte172053	Sandeep Shukla
tte172054	Sayan Mukherjee
tte172055	Shivani Agrawal
tte172056	Siddharth Shukla
tte172057	Sockalingam A
tte172058	Subham
tte172059	Viraj Uttamrao Somkuwar
tte172516	Hermela Ejegu Feysa
tte172519	Solomon Addis Mitku
tte172520	Gosa Guta Dabi
tte172522	Mesay Dubale Tigabu
tte172523	Ayana Mengesha Negasa
tte172524	Wondwossen Mamuye Abebe
tte172691	Vishal Srivastava
tte182048	Amit Shukla
tte182049	Ankur Rai
tte182051	Ashish Rastogi
tte182052	Bharat Gupta
tte182053	Danvendra Singh
tte182054	Ganesh Annadurai
tte182055	Himanshu Pundir
tte182056	Nidhi Mittal
tte182057	Nitish Kumar
tte182058	Rasujit Chongder
tte182059	Ravikant Prasad Verma
tte182060	Riyajahamad Moulaali Mulla
tte182061	Sandeep Kumar Maurya
tte182062	Shivangi Shukla
tte182063	Sumona Chakrabarti
tte182064	Veerhi Vishnu K P
tte182065	Shreejit Sarkar
tte182066	Harmandeep
ttf172026	Advitiya Kumar
ttf172027	Ankit Shankar
ttf172028	Ankita Pramanick
ttf172029	Gopal Kumar Singh
ttf172031	Manish Kumar Shukl
ttf172032	Pilla Satya Rohit
ttf172033	Rahul Sahu
ttf172034	Ritika Saini
ttf172035	Saptaparni Chanda
ttf172036	Shubham Kumar
ttf172037	Smriti Mishra
ttf172038	Soumen Kundu
ttf172039	Vishav Rajput
ttf172040	Yogesh Kumar Swarnkar
ttf172690	Ramesh Kumar
ttf182067	Kanchan Doheray
ttf182068	Ramnath Kumar
ttf182069	Shankha Ghosh
ttf182070	Ashish Mishra
ttf182071	Abhishek Kumar
ttf182072	Rupesh Kumar
ttf182073	Sumit Kumar Singh
ttf182074	Amit Patel
ttf182075	Anil Kumar
ttf182076	Sagar Kumar
ttf182077	Meenal Agrawal
ttf182078	Dashrath Alodiya
ttf182079	Jogender
ttf182080	Meharchand
ttf182081	Sinchan Shit
ttf182082	Srishti Bajpai
ttz128341	Gaurav Singh
ttz138213	Md Samsu Alam
ttz138288	Vikas Kumar Singh
ttz138573	Ashwini Kumar Dash
ttz148145	Prakash Arun Khude
ttz148146	Sanchi Arora
ttz148400	Aranya Ghosh
ttz148402	Vijay Anil Goud
ttz148407	Amit Chatterjee
ttz158268	Bapan Adak
ttz158271	Rahul Rajkumar Gadkari
ttz158272	Rupayan Roy
ttz158274	Swati
ttz158471	Chandra Jeet Singh
ttz158473	Anilkumar Lalchand Yadav
ttz168259	Sanchayan Pal
ttz168260	Rashi Agarwal
ttz168261	Shivendra Yadav
ttz168265	Neeta Kumari
ttz168266	Hardeep Singh
ttz168468	Juhi Chakraborty
ttz168470	Prasun Mathur
ttz168472	Satya Ranjan Bairagi
ttz168473	Manisha Yadav
ttz168474	Unsanhame Mawkhlieng
ttz178342	Aarushi Sharma
ttz178343	Arunabh Agnihotri
ttz178344	Ashok Kumar Shriwastawa
ttz178345	Gurneet Kaur
ttz178346	Bramhecha Indrajit Chandrakant
ttz178347	Parna Nandi
ttz178348	Priyal Dixit
ttz178349	Priyanka Gupta
ttz178350	Mukesh Bajya
ttz178351	Rupali
ttz178352	Vikas Khatkar
ttz178473	Anupam Chowdhury
ttz178474	Ashraf Nawaz Khan
ttz178475	Ankita Sharma
ttz178476	Ankur Shukla
ttz178477	Nagender Singh
ttz178478	Pramod Manikant Gurave
ttz178479	Ganesh Jogur
ttz178480	Karan Chandrakar
ttz178482	Zunjarrao Bapuso Kamble
ttz178483	Mahesh Shaw
ttz178484	Subhash Mandal
ttz178485	Subhasish Pal
ttz188222	Sumana Bandyopadhyay
ttz188223	Amit Kumar Mandal
ttz188225	Manali Somani
ttz188226	Tuhin Nag
ttz188227	Pratibha Singh
ttz188228	Sanjay Kumar Bhikari Charan Panda
ttz188230	Vandana Kumari
ttz188231	Ranjna Kumari
ttz188453	Kiran Rana
ttz188454	Lekhani Tripathi
ttz188455	Meenakshi Ahirwar
ttz188456	Parasuram S
ttz188457	Rahul Ranjan
ttz188458	Rochak Rathour
ttz188459	Sandeep Olhan
ttz188461	Tathagata Das
vst189727	Zeray Khan
vst189728	Sreejoe Kaniyamparambil
vst189732	Insha Wani
vst189734	Harsh Vardhan Singh
vst189735	Surendra Tyagi
vst189736	Mohit Pal
vst189737	Rahul Kumar Kumawat
vst189738	Akshay Pathania
vst189739	Suhaib Ul Reyaz
vst189740	Aditi Magotra
vst189741	Hardeep Kumar Maurya
vst189742	Himanshu Kumar
vst189743	Abhishek Shrivastava
vst189744	Devashish Joshi
vst189745	Ashwani Koul
vst189746	Mehran Manzoor Zargar
vst189747	Deepesh Patidar
vst189748	Shreya Mudgil
vst189749	Gurdev Chand Anthal
vst189750	Pummy Sharma
vst189751	Ambreen Bashir
vst189757	Shekhar Madnani
vst189758	Gopal Mohan
vst189759	Shreyansh Dixit
vst189760	Bhakti Kapur
vst189761	Jasleen Kaur Ahuja
vst189762	Nagma Markan
vst189763	Chayan Majumder
vst189764	Deepak Narula
vst189765	Prince Prabhakar
vst189766	Gyanendra Kumar
vst189767	Dewansh Aditya Gupta
vst189768	Harshit Mehta
vst189769	Honey Gahlawat
vst189770	Smriti Kumari
vst189771	Abhishek Tomar
vst189772	Manish Minocha
vst189773	Vinayak Dalmia
vst189774	Sikandar Ali Khan
vst189775	Aditi
\.


--
-- Data for Name: curr_stu_course; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.curr_stu_course (entrynum, courseid, groupedin) FROM stdin;
me1170569	1	1
me1170571	1	1
me1170580	1	1
me1170582	1	1
me1170590	1	1
me1170592	1	1
me1170622	1	1
ama172317	3	1
ama172318	3	1
ama172319	3	1
ama172320	3	1
ama172321	3	1
ama172324	3	1
ama172325	3	1
ama172326	3	1
ama172327	3	1
ama172329	3	1
ama172331	3	1
ama172332	3	1
ama172333	3	1
ama172335	3	1
ama172336	3	1
ama172337	3	1
ama172339	3	1
ama172636	3	1
ama172638	3	1
ama172641	3	1
ama172648	3	1
ama172650	3	1
ama172653	3	1
ama172654	3	1
ama172658	3	1
ama172659	3	1
ama172661	3	1
ama172771	3	1
ama172775	3	1
ama172780	3	1
ame162266	3	1
ama172779	4	1
ama172322	5	1
ama172338	5	1
ama172645	5	1
ama172647	5	1
amy177543	6	1
amy187507	6	1
amx185501	7	1
amx185502	7	1
amx185503	7	1
amx185504	7	1
amx185506	7	1
amx185507	7	1
amx185508	7	1
amx185509	7	1
amx185510	7	1
amx185511	7	1
amx185512	7	1
amx185513	7	1
amx185514	7	1
amx185515	7	1
amx185516	7	1
amx185517	7	1
amx185518	7	1
amx185519	7	1
amx185520	7	1
amx185521	7	1
amx185522	7	1
amx185523	7	1
amx185524	7	1
amx185525	7	1
amx185526	7	1
amx185501	8	1
amx185502	8	1
amx185503	8	1
amx185504	8	1
amx185506	8	1
amx185507	8	1
amx185508	8	1
amx185509	8	1
amx185510	8	1
amx185511	8	1
amx185512	8	1
amx185513	8	1
amx185514	8	1
amx185515	8	1
amx185516	8	1
amx185517	8	1
amx185518	8	1
amx185519	8	1
amx185520	8	1
amx185521	8	1
amx185522	8	1
amx185523	8	1
amx185524	8	1
amx185525	8	1
amx185526	8	1
amy187550	8	1
amz188631	8	1
amz188635	8	1
amz188636	8	1
cez188397	8	1
cez188398	8	1
cez188400	8	1
mez188286	8	1
phz188337	8	1
qiz188608	8	1
tt1150860	8	1
ama172322	9	1
ama172338	9	1
ama172654	9	1
ama172775	9	1
ama182036	9	1
ama182745	9	1
ama182765	9	1
amx185501	9	1
amx185502	9	1
amx185503	9	1
amx185504	9	1
amx185506	9	1
amx185507	9	1
amx185508	9	1
amx185509	9	1
amx185510	9	1
amx185511	9	1
amx185512	9	1
amx185513	9	1
amx185514	9	1
amx185515	9	1
amx185516	9	1
amx185517	9	1
amx185518	9	1
amx185519	9	1
amx185520	9	1
amx185521	9	1
amx185522	9	1
amx185523	9	1
amx185524	9	1
amx185525	9	1
amx185526	9	1
ama182744	10	1
ama182754	10	1
amy187548	10	1
amy187549	10	1
amy187550	10	1
amz188632	10	1
amz188635	10	1
cez188393	10	1
cez188407	10	1
amx185501	11	1
amx185502	11	1
amx185503	11	1
amx185504	11	1
amx185506	11	1
amx185507	11	1
amx185508	11	1
amx185509	11	1
amx185510	11	1
amx185511	11	1
amx185512	11	1
amx185513	11	1
amx185514	11	1
amx185515	11	1
amx185516	11	1
amx185517	11	1
amx185518	11	1
amx185519	11	1
amx185520	11	1
amx185521	11	1
amx185522	11	1
amx185523	11	1
amx185524	11	1
amx185525	11	1
amx185526	11	1
amx185501	12	1
amx185502	12	1
amx185503	12	1
amx185504	12	1
amx185506	12	1
amx185507	12	1
amx185508	12	1
amx185509	12	1
amx185510	12	1
amx185511	12	1
amx185512	12	1
amx185513	12	1
amx185514	12	1
amx185515	12	1
amx185516	12	1
amx185517	12	1
amx185518	12	1
amx185519	12	1
amx185520	12	1
amx185521	12	1
amx185522	12	1
amx185523	12	1
amx185524	12	1
amx185525	12	1
amx185526	12	1
ama172658	13	1
ama172661	13	1
ama172771	13	1
ama182738	13	1
ama182740	13	1
ama182743	13	1
ama182744	13	1
ama182749	13	1
ama182754	13	1
ama182758	13	1
ama182763	13	1
ama182821	13	1
ama182826	13	1
ama182832	13	1
amy187507	13	1
amy187548	13	1
amy187549	13	1
amy187550	13	1
amz178128	13	1
amz188066	13	1
ttz188223	13	1
ama182747	14	1
ama182757	14	1
ama182879	14	1
amx185501	14	1
amx185502	14	1
amx185503	14	1
amx185504	14	1
amx185506	14	1
amx185507	14	1
amx185508	14	1
amx185509	14	1
amx185510	14	1
amx185511	14	1
amx185512	14	1
amx185513	14	1
amx185514	14	1
amx185515	14	1
amx185516	14	1
amx185517	14	1
amx185518	14	1
amx185519	14	1
amx185520	14	1
amx185521	14	1
amx185522	14	1
amx185523	14	1
amx185524	14	1
amx185525	14	1
amx185526	14	1
tt1140920	14	1
ama182730	15	1
ama182732	15	1
ama182743	15	1
ama182748	15	1
ama182830	15	1
ama182835	15	1
ama182873	15	1
amy187507	15	1
amy187549	15	1
amy187550	15	1
amz188318	15	1
amz188636	15	1
cez188398	15	1
me1160673	15	1
mez188284	15	1
mez188589	15	1
mez188590	15	1
trz188282	15	1
ttz188454	15	1
ttz188459	15	1
ama182730	16	1
ama182732	16	1
ama182734	16	1
ama182736	16	1
ama182742	16	1
ama182745	16	1
ama182748	16	1
ama182749	16	1
ama182751	16	1
ama182752	16	1
ama182757	16	1
ama182764	16	1
ama182765	16	1
ama182771	16	1
ama182823	16	1
ama182827	16	1
ama182831	16	1
ama182872	16	1
ama182873	16	1
ama182879	16	1
bb1160045	17	1
bb1160063	17	1
bb1170036	17	1
bb1180003	17	1
bb1180007	17	1
bb1180009	17	1
bb1180010	17	1
bb1180011	17	1
bb1180013	17	1
bb1180014	17	1
bb1180015	17	1
bb1180018	17	1
bb1180022	17	1
bb1180026	17	1
bb1180027	17	1
bb1180028	17	1
bb1180033	17	1
bb1180040	17	1
bb1180043	17	1
bb5180055	17	1
bb5180059	17	1
bb5180061	17	1
bb5180065	17	1
ce1140321	17	1
ce1180071	17	1
ce1180072	17	1
ce1180073	17	1
ce1180075	17	1
ce1180077	17	1
ce1180080	17	1
ce1180081	17	1
ce1180082	17	1
ce1180087	17	1
ce1180088	17	1
ce1180089	17	1
ce1180091	17	1
ce1180092	17	1
ce1180093	17	1
ce1180096	17	1
ce1180097	17	1
ce1180098	17	1
ce1180099	17	1
ce1180100	17	1
ce1180102	17	1
ce1180103	17	1
ce1180105	17	1
ce1180107	17	1
ce1180109	17	1
ce1180111	17	1
ce1180113	17	1
ce1180114	17	1
ce1180115	17	1
ce1180116	17	1
ce1180119	17	1
ce1180121	17	1
ce1180122	17	1
ce1180123	17	1
ce1180125	17	1
ce1180126	17	1
ce1180127	17	1
ce1180128	17	1
ce1180129	17	1
ce1180130	17	1
ce1180131	17	1
ce1180134	17	1
ce1180135	17	1
ce1180137	17	1
ce1180138	17	1
ce1180139	17	1
ce1180140	17	1
ce1180142	17	1
ce1180143	17	1
ce1180144	17	1
ce1180145	17	1
ce1180147	17	1
ce1180152	17	1
ce1180153	17	1
ce1180155	17	1
ce1180156	17	1
ce1180159	17	1
ce1180160	17	1
ce1180161	17	1
ce1180162	17	1
ce1180166	17	1
ce1180170	17	1
ce1180171	17	1
ce1180172	17	1
ce1180173	17	1
ce1180174	17	1
ce1180175	17	1
ce1180176	17	1
ch1160083	17	1
ch1170230	17	1
ch1180186	17	1
ch1180188	17	1
ch1180190	17	1
ch1180192	17	1
ch1180196	17	1
ch1180198	17	1
ch1180204	17	1
ch1180206	17	1
ch1180207	17	1
ch1180209	17	1
ch1180217	17	1
ch1180219	17	1
ch1180222	17	1
ch1180223	17	1
ch1180224	17	1
ch1180226	17	1
ch1180228	17	1
ch1180231	17	1
ch1180232	17	1
ch1180233	17	1
ch1180235	17	1
ch1180236	17	1
ch1180237	17	1
ch1180238	17	1
ch1180241	17	1
ch1180243	17	1
ch1180244	17	1
ch1180245	17	1
ch1180246	17	1
ch1180256	17	1
ch1180258	17	1
ch7140187	17	1
ch7170315	17	1
ch7180273	17	1
ch7180274	17	1
ch7180275	17	1
ch7180276	17	1
ch7180283	17	1
ch7180284	17	1
ch7180289	17	1
ch7180291	17	1
ch7180294	17	1
ch7180298	17	1
ch7180300	17	1
ch7180303	17	1
ch7180307	17	1
ch7180308	17	1
ch7180309	17	1
ch7180310	17	1
ch7180312	17	1
ch7180313	17	1
ch7180314	17	1
ch7180316	17	1
cs1180321	17	1
cs1180324	17	1
cs1180325	17	1
cs1180326	17	1
cs1180328	17	1
cs1180329	17	1
cs1180331	17	1
cs1180333	17	1
cs1180336	17	1
cs1180337	17	1
cs1180338	17	1
cs1180339	17	1
cs1180341	17	1
cs1180342	17	1
cs1180343	17	1
cs1180347	17	1
cs1180349	17	1
cs1180352	17	1
cs1180353	17	1
cs1180354	17	1
cs1180356	17	1
cs1180357	17	1
cs1180358	17	1
cs1180359	17	1
cs1180361	17	1
cs1180363	17	1
cs1180364	17	1
cs1180365	17	1
cs1180367	17	1
cs1180368	17	1
cs1180369	17	1
cs1180371	17	1
cs1180375	17	1
cs1180376	17	1
cs1180378	17	1
cs1180379	17	1
cs1180382	17	1
cs1180383	17	1
cs1180384	17	1
cs1180387	17	1
cs1180388	17	1
cs1180391	17	1
cs1180396	17	1
cs5180406	17	1
cs5180407	17	1
cs5180410	17	1
cs5180411	17	1
cs5180414	17	1
cs5180415	17	1
cs5180416	17	1
cs5180417	17	1
cs5180418	17	1
cs5180421	17	1
cs5180423	17	1
cs5180424	17	1
ee1120971	17	1
ee1180431	17	1
ee1180432	17	1
ee1180435	17	1
ee1180438	17	1
ee1180440	17	1
ee1180442	17	1
ee1180445	17	1
ee1180448	17	1
ee1180449	17	1
ee1180450	17	1
ee1180451	17	1
ee1180453	17	1
ee1180455	17	1
ee1180457	17	1
ee1180461	17	1
ee1180462	17	1
ee1180463	17	1
ee1180464	17	1
ee1180465	17	1
ee1180466	17	1
ee1180471	17	1
ee1180472	17	1
ee1180474	17	1
ee1180475	17	1
ee1180477	17	1
ee1180478	17	1
ee1180479	17	1
ee1180480	17	1
ee1180481	17	1
ee1180484	17	1
ee1180487	17	1
ee1180488	17	1
ee1180490	17	1
ee1180493	17	1
ee1180494	17	1
ee1180495	17	1
ee1180498	17	1
ee1180499	17	1
ee1180500	17	1
ee1180501	17	1
ee1180502	17	1
ee1180503	17	1
ee1180507	17	1
ee1180508	17	1
ee1180510	17	1
ee1180512	17	1
ee1180513	17	1
ee1180514	17	1
ee1180515	17	1
ee3150535	17	1
ee3180522	17	1
ee3180526	17	1
ee3180529	17	1
ee3180532	17	1
ee3180534	17	1
ee3180536	17	1
ee3180537	17	1
ee3180538	17	1
ee3180539	17	1
ee3180540	17	1
ee3180543	17	1
ee3180544	17	1
ee3180548	17	1
ee3180550	17	1
ee3180551	17	1
ee3180552	17	1
ee3180555	17	1
ee3180558	17	1
ee3180559	17	1
ee3180561	17	1
ee3180564	17	1
ee3180566	17	1
ee3180567	17	1
ee3180568	17	1
me1180583	17	1
me1180585	17	1
me1180586	17	1
me1180587	17	1
me1180591	17	1
me1180593	17	1
me1180594	17	1
me1180595	17	1
me1180596	17	1
me1180598	17	1
me1180601	17	1
me1180602	17	1
me1180605	17	1
me1180607	17	1
me1180609	17	1
me1180610	17	1
me1180613	17	1
me1180617	17	1
me1180618	17	1
me1180619	17	1
me1180620	17	1
me1180621	17	1
me1180623	17	1
me1180625	17	1
me1180629	17	1
me1180632	17	1
me1180635	17	1
me1180636	17	1
me1180637	17	1
me1180638	17	1
me1180639	17	1
me1180640	17	1
me1180642	17	1
me1180643	17	1
me1180646	17	1
me1180647	17	1
me1180648	17	1
me1180649	17	1
me1180652	17	1
me1180653	17	1
me1180655	17	1
me1180657	17	1
me2150723	17	1
me2170659	17	1
me2180665	17	1
me2180667	17	1
me2180669	17	1
me2180671	17	1
me2180673	17	1
me2180677	17	1
me2180680	17	1
me2180684	17	1
me2180685	17	1
me2180686	17	1
me2180689	17	1
me2180692	17	1
me2180693	17	1
me2180697	17	1
me2180702	17	1
me2180704	17	1
me2180705	17	1
me2180708	17	1
me2180710	17	1
me2180711	17	1
me2180714	17	1
me2180720	17	1
me2180721	17	1
me2180724	17	1
me2180727	17	1
me2180729	17	1
me2180731	17	1
me2180734	17	1
me2180735	17	1
mt1160639	17	1
mt1180736	17	1
mt1180737	17	1
mt1180740	17	1
mt1180741	17	1
mt1180743	17	1
mt1180745	17	1
mt1180747	17	1
mt1180749	17	1
mt1180750	17	1
mt1180751	17	1
mt1180752	17	1
mt1180753	17	1
mt1180754	17	1
mt1180756	17	1
mt1180759	17	1
mt1180761	17	1
mt1180763	17	1
mt1180764	17	1
mt1180765	17	1
mt1180766	17	1
mt1180767	17	1
mt1180768	17	1
mt1180769	17	1
mt1180771	17	1
mt1180772	17	1
mt1180773	17	1
mt1180774	17	1
mt6180776	17	1
mt6180778	17	1
mt6180779	17	1
mt6180780	17	1
mt6180781	17	1
mt6180782	17	1
mt6180784	17	1
mt6180786	17	1
mt6180787	17	1
mt6180788	17	1
mt6180789	17	1
mt6180791	17	1
mt6180792	17	1
mt6180796	17	1
mt6180798	17	1
ph1180804	17	1
ph1180805	17	1
ph1180806	17	1
ph1180808	17	1
ph1180809	17	1
ph1180811	17	1
ph1180815	17	1
ph1180816	17	1
ph1180818	17	1
ph1180819	17	1
ph1180823	17	1
ph1180824	17	1
ph1180829	17	1
ph1180834	17	1
ph1180835	17	1
ph1180837	17	1
ph1180840	17	1
ph1180841	17	1
ph1180842	17	1
ph1180847	17	1
ph1180849	17	1
ph1180853	17	1
ph1180855	17	1
ph1180856	17	1
ph1180857	17	1
tt1140863	17	1
tt1150886	17	1
tt1160914	17	1
tt1160918	17	1
tt1160921	17	1
tt1180867	17	1
tt1180868	17	1
tt1180869	17	1
tt1180871	17	1
tt1180873	17	1
tt1180878	17	1
tt1180880	17	1
tt1180883	17	1
tt1180884	17	1
tt1180885	17	1
tt1180886	17	1
tt1180895	17	1
tt1180898	17	1
tt1180899	17	1
tt1180904	17	1
tt1180907	17	1
tt1180908	17	1
tt1180909	17	1
tt1180913	17	1
tt1180914	17	1
tt1180916	17	1
tt1180917	17	1
tt1180918	17	1
tt1180919	17	1
tt1180924	17	1
tt1180926	17	1
tt1180929	17	1
tt1180931	17	1
tt1180935	17	1
tt1180937	17	1
tt1180938	17	1
tt1180941	17	1
tt1180942	17	1
tt1180943	17	1
tt1180944	17	1
tt1180945	17	1
tt1180948	17	1
tt1180949	17	1
tt1180953	17	1
tt1180957	17	1
tt1180958	17	1
tt1180959	17	1
tt1180961	17	1
tt1180966	17	1
tt1180970	17	1
tt1180971	17	1
tt1180972	17	1
tt1180974	17	1
ch1120088	18	1
ch1140121	18	1
ch1150078	18	1
ch1160104	18	1
ch1160128	18	1
ch1160141	18	1
ch1160142	18	1
ch1170086	18	1
ch1170087	18	1
ch1170114	18	1
ch1170120	18	1
ch1170161	18	1
ch1170186	18	1
ch1170187	18	1
ch1170188	18	1
ch1170189	18	1
ch1170190	18	1
ch1170191	18	1
ch1170192	18	1
ch1170193	18	1
ch1170194	18	1
ch1170195	18	1
ch1170196	18	1
ch1170197	18	1
ch1170198	18	1
ch1170199	18	1
ch1170200	18	1
ch1170201	18	1
ch1170202	18	1
ch1170203	18	1
ch1170204	18	1
ch1170205	18	1
ch1170206	18	1
ch1170208	18	1
ch1170209	18	1
ch1170210	18	1
ch1170211	18	1
ch1170212	18	1
ch1170214	18	1
ch1170215	18	1
ch1170216	18	1
ch1170218	18	1
ch1170222	18	1
ch1170223	18	1
ch1170224	18	1
ch1170225	18	1
ch1170226	18	1
ch1170227	18	1
ch1170228	18	1
ch1170229	18	1
ch1170231	18	1
ch1170232	18	1
ch1170233	18	1
ch1170234	18	1
ch1170235	18	1
ch1170236	18	1
ch1170237	18	1
ch1170238	18	1
ch1170239	18	1
ch1170240	18	1
ch1170241	18	1
ch1170242	18	1
ch1170243	18	1
ch1170244	18	1
ch1170246	18	1
ch1170247	18	1
ch1170248	18	1
ch1170251	18	1
ch1170252	18	1
ch1170253	18	1
ch1170254	18	1
ch1170255	18	1
ch1170256	18	1
ch1170257	18	1
ch1170258	18	1
ch1170259	18	1
ch1170260	18	1
ch1170297	18	1
ch1170309	18	1
ch1170311	18	1
ch1170894	18	1
ch7130156	18	1
ch7140166	18	1
ch7140190	18	1
ch7160191	18	1
ch7170271	18	1
ch7170272	18	1
ch7170273	18	1
ch7170274	18	1
ch7170275	18	1
ch7170276	18	1
ch7170277	18	1
ch7170278	18	1
ch7170279	18	1
ch7170280	18	1
ch7170282	18	1
ch7170283	18	1
ch7170284	18	1
ch7170285	18	1
ch7170286	18	1
ch7170288	18	1
ch7170289	18	1
ch7170290	18	1
ch7170291	18	1
ch7170292	18	1
ch7170293	18	1
ch7170294	18	1
ch7170295	18	1
ch7170296	18	1
ch7170298	18	1
ch7170299	18	1
ch7170300	18	1
ch7170301	18	1
ch7170302	18	1
ch7170303	18	1
ch7170304	18	1
ch7170305	18	1
ch7170307	18	1
ch7170308	18	1
ch7170310	18	1
ch7170312	18	1
ch7170314	18	1
cs1170323	18	1
tt1130982	18	1
tt1140588	18	1
tt1140887	18	1
tt1150858	18	1
tt1150867	18	1
tt1150934	18	1
tt1150937	18	1
tt1150939	18	1
tt1150941	18	1
tt1150942	18	1
me1150643	19	1
me2110775	19	1
ph1150785	19	1
tt1130937	19	1
tt1130979	19	1
tt1140115	19	1
tt1140169	19	1
tt1140185	19	1
tt1140228	19	1
tt1140588	19	1
tt1140887	19	1
tt1140905	19	1
tt1140932	19	1
tt1150862	19	1
tt1150867	19	1
tt1150878	19	1
tt1150882	19	1
tt1150905	19	1
tt1150924	19	1
tt1150934	19	1
tt1160821	19	1
tt1160845	19	1
tt1160865	19	1
tt1160867	19	1
tt1160882	19	1
tt1160890	19	1
tt1160891	19	1
tt1160893	19	1
tt1160909	19	1
tt1160917	19	1
tt1170873	19	1
tt1170875	19	1
tt1170876	19	1
tt1170878	19	1
tt1170879	19	1
tt1170880	19	1
tt1170881	19	1
tt1170882	19	1
tt1170883	19	1
tt1170884	19	1
tt1170885	19	1
tt1170886	19	1
tt1170887	19	1
tt1170888	19	1
tt1170889	19	1
tt1170890	19	1
tt1170891	19	1
tt1170892	19	1
tt1170893	19	1
tt1170896	19	1
tt1170897	19	1
tt1170898	19	1
tt1170899	19	1
tt1170900	19	1
tt1170901	19	1
tt1170902	19	1
tt1170903	19	1
tt1170905	19	1
tt1170906	19	1
tt1170907	19	1
tt1170908	19	1
tt1170909	19	1
tt1170910	19	1
tt1170911	19	1
tt1170912	19	1
tt1170913	19	1
tt1170914	19	1
tt1170915	19	1
tt1170916	19	1
tt1170917	19	1
tt1170918	19	1
tt1170919	19	1
tt1170920	19	1
tt1170921	19	1
tt1170922	19	1
tt1170923	19	1
tt1170924	19	1
tt1170925	19	1
tt1170926	19	1
tt1170927	19	1
tt1170928	19	1
tt1170929	19	1
tt1170930	19	1
tt1170931	19	1
tt1170932	19	1
tt1170933	19	1
tt1170934	19	1
tt1170935	19	1
tt1170936	19	1
tt1170939	19	1
tt1170940	19	1
tt1170941	19	1
tt1170943	19	1
tt1170944	19	1
tt1170945	19	1
tt1170947	19	1
tt1170948	19	1
tt1170949	19	1
tt1170951	19	1
tt1170952	19	1
tt1170953	19	1
tt1170954	19	1
tt1170955	19	1
tt1170956	19	1
tt1170957	19	1
tt1170958	19	1
tt1170959	19	1
tt1170961	19	1
tt1170962	19	1
tt1170963	19	1
tt1170964	19	1
tt1170965	19	1
tt1170966	19	1
tt1170968	19	1
tt1170969	19	1
tt1170970	19	1
tt1170971	19	1
tt1170972	19	1
tt1170973	19	1
tt1170974	19	1
tt1170975	19	1
tt1170976	19	1
ce1160238	20	1
ce1170102	20	1
ce1170104	20	1
ce1170119	20	1
me1160758	20	1
me1170158	20	1
me1170561	20	1
me1170562	20	1
me1170566	20	1
me1170569	20	1
me1170570	20	1
me1170585	20	1
me1170586	20	1
me1170588	20	1
me1170591	20	1
me1170600	20	1
me1170606	20	1
me1170607	20	1
me1170613	20	1
me1170614	20	1
me1170615	20	1
me1170621	20	1
me1170622	20	1
me1170626	20	1
me1170627	20	1
me1170651	20	1
me1170950	20	1
me1170960	20	1
me2170665	20	1
me2170668	20	1
me2170680	20	1
ama172317	21	1
ama172327	21	1
ama172332	21	1
ama172641	21	1
ama182730	21	1
ama182732	21	1
ama182734	21	1
ama182735	21	1
ama182736	21	1
ama182737	21	1
ama182738	21	1
ama182739	21	1
ama182740	21	1
ama182742	21	1
ama182743	21	1
ama182744	21	1
ama182747	21	1
ama182748	21	1
ama182749	21	1
ama182751	21	1
ama182754	21	1
ama182757	21	1
ama182758	21	1
ama182760	21	1
ama182763	21	1
ama182764	21	1
ama182769	21	1
ama182771	21	1
ama182826	21	1
ama182827	21	1
ama182830	21	1
ama182831	21	1
ama182832	21	1
ama182835	21	1
ama182838	21	1
ama182872	21	1
ama182873	21	1
ama182879	21	1
amy187507	21	1
amy187548	21	1
amy187549	21	1
amy187550	21	1
amz188632	21	1
amz188636	21	1
amz188656	21	1
cey187546	21	1
cez188398	21	1
cez188400	21	1
itz188283	21	1
me1150654	21	1
mez188264	21	1
mez188284	21	1
trz188282	21	1
ama182036	22	1
ama182735	22	1
ama182737	22	1
ama182739	22	1
ama182764	22	1
ama182767	22	1
ama182769	22	1
ama182770	22	1
ama182821	22	1
amz188634	22	1
mez188580	22	1
ph1150805	22	1
ama182036	23	1
ama182735	23	1
ama182737	23	1
ama182739	23	1
ama182767	23	1
ama182769	23	1
ama182770	23	1
ama182821	23	1
amz148025	23	1
amz168166	23	1
amz188069	23	1
amz188634	23	1
me1150663	23	1
me1150680	23	1
me2150739	23	1
met182278	23	1
mey177525	23	1
mez178331	23	1
mez188262	23	1
tt1150860	23	1
ama172322	24	1
ama182036	24	1
ama182735	24	1
ama182737	24	1
ama182739	24	1
ama182752	24	1
ama182765	24	1
ama182767	24	1
ama182769	24	1
ama182770	24	1
ama182821	24	1
ama182823	24	1
amz188634	24	1
chz188663	24	1
me1150680	24	1
mem182269	24	1
mez188270	24	1
mez188286	24	1
mez188580	24	1
ph1150832	24	1
ph1150837	24	1
phz188356	24	1
ama172320	25	1
ama172647	25	1
ama172653	25	1
ama172779	25	1
ama182745	25	1
me1150651	25	1
mez188273	25	1
msz188290	25	1
msz188519	25	1
vst189738	25	1
vst189742	25	1
vst189743	25	1
vst189747	25	1
ama172333	26	1
ama172335	26	1
ama182730	26	1
ama182732	26	1
ama182734	26	1
ama182736	26	1
ama182751	26	1
amy177543	26	1
mez188600	26	1
msz188290	26	1
msz188519	26	1
vst189738	26	1
vst189742	26	1
vst189743	26	1
vst189747	26	1
ama172638	27	1
ama182734	27	1
ama182742	27	1
ama182752	27	1
ama182765	27	1
ama182823	27	1
ama182827	27	1
ama182838	27	1
cez188407	27	1
ama182738	28	1
ama182740	28	1
ama182743	28	1
ama182744	28	1
ama182747	28	1
ama182754	28	1
ama182758	28	1
ama182760	28	1
ama182763	28	1
ama182821	28	1
ama182826	28	1
ama182830	28	1
ama182831	28	1
ama182832	28	1
ama182835	28	1
amz188631	28	1
amz188635	28	1
mez188595	28	1
mez188668	28	1
ama172779	29	1
ama182730	29	1
ama182736	29	1
ama182738	29	1
ama182742	29	1
ama182745	29	1
ama182747	29	1
ama182748	29	1
ama182749	29	1
ama182751	29	1
ama182752	29	1
ama182757	29	1
ama182758	29	1
ama182760	29	1
ama182763	29	1
ama182764	29	1
ama182765	29	1
ama182767	29	1
ama182770	29	1
ama182823	29	1
ama182826	29	1
ama182827	29	1
ama182830	29	1
ama182831	29	1
ama182832	29	1
ama182835	29	1
ama182838	29	1
ama182872	29	1
ama182873	29	1
ama182879	29	1
amz188656	29	1
cez188398	29	1
mt6150565	29	1
ast172001	31	1
ast172003	31	1
ast172006	31	1
ast172007	31	1
ast172008	31	1
ast172009	31	1
ast172010	31	1
ast172012	31	1
ast172015	31	1
ast172731	31	1
ast172785	31	1
ast172850	31	1
bb1150023	32	1
bb1150029	32	1
bb1160044	32	1
ce1130348	32	1
ce1150321	32	1
ce1150349	32	1
ce1160225	32	1
ce1160227	32	1
ce1160231	32	1
ce1160234	32	1
ce1160241	32	1
ce1160245	32	1
ce1160248	32	1
ce1160249	32	1
ce1160251	32	1
ce1160253	32	1
ce1160254	32	1
ce1160255	32	1
ce1160257	32	1
ce1160258	32	1
ce1160259	32	1
ce1160260	32	1
ce1160261	32	1
ce1160262	32	1
ce1160264	32	1
ce1160265	32	1
ce1160266	32	1
ce1160269	32	1
ce1160270	32	1
ce1160271	32	1
ce1160272	32	1
ce1160280	32	1
ce1160281	32	1
ce1160288	32	1
ce1160289	32	1
ce1160296	32	1
ce1160302	32	1
ce1160304	32	1
ch1160104	32	1
ch1160108	32	1
ch1160115	32	1
ch7160153	32	1
ch7160172	32	1
ch7160175	32	1
ch7160194	32	1
cs1150267	32	1
cs1160294	32	1
cs1160344	32	1
ee1150432	32	1
ee1150519	32	1
ee3150509	32	1
ee3150513	32	1
ee5110547	32	1
me1080528	32	1
me1150396	32	1
me1150635	32	1
me1160691	32	1
me1160705	32	1
me2150719	32	1
me2150745	32	1
me2160782	32	1
mt1150607	32	1
ph1160597	32	1
tt1150880	32	1
tt1160871	32	1
tt1160875	32	1
tt1160883	32	1
tt1160925	32	1
ce1150315	33	1
ce1150318	33	1
ce1150324	33	1
ce1150349	33	1
ce1150359	33	1
ce1150363	33	1
ce1150372	33	1
ce1160286	33	1
cs1150223	33	1
cs1150231	33	1
cs1150256	33	1
cs1150258	33	1
cs1150263	33	1
cs1150267	33	1
cs1160320	33	1
cs1160347	33	1
cs1160353	33	1
cs1160354	33	1
cs1160356	33	1
cs1160358	33	1
cs1160360	33	1
cs1160375	33	1
cs5160387	33	1
ee1130476	33	1
ee1150456	33	1
ee1150458	33	1
ee1150462	33	1
ee1150464	33	1
ee1150474	33	1
ee1150479	33	1
ee1150483	33	1
ee1150487	33	1
ee3150505	33	1
ee3150506	33	1
ee3150510	33	1
ee3150540	33	1
me1120651	33	1
me1150396	33	1
me1150628	33	1
me1150642	33	1
me1150646	33	1
me1150650	33	1
me1150652	33	1
me1150661	33	1
me1150670	33	1
me1150678	33	1
me1150684	33	1
me2110775	33	1
me2150731	33	1
me2150734	33	1
me2170647	33	1
me2170648	33	1
me2170649	33	1
me2170650	33	1
me2170653	33	1
me2170655	33	1
me2170656	33	1
me2170683	33	1
me2170707	33	1
mt1150582	33	1
mt1150583	33	1
mt1150614	33	1
mt6150373	33	1
ph1110855	33	1
ph1130849	33	1
ph1150792	33	1
ph1150795	33	1
ph1160572	33	1
tt1150855	33	1
tt1150880	33	1
tt1160867	33	1
bb1150032	34	1
bb1160030	34	1
bb1160044	34	1
bb1160054	34	1
bb1160064	34	1
bb1170013	34	1
bb1170016	34	1
bb1170022	34	1
bb1170028	34	1
bb1170042	34	1
bb5160009	34	1
bb5170051	34	1
bb5170059	34	1
ce1150321	34	1
ce1160276	34	1
ce1160284	34	1
ce1160285	34	1
ce1160290	34	1
ce1160293	34	1
ce1160304	34	1
ce1170094	34	1
ce1170097	34	1
ce1170099	34	1
ce1170101	34	1
ce1170108	34	1
ce1170111	34	1
ce1170113	34	1
ce1170116	34	1
ce1170117	34	1
ce1170138	34	1
ce1170139	34	1
ce1170145	34	1
ce1170147	34	1
ce1170150	34	1
ch1140145	34	1
ch1160116	34	1
ch1160120	34	1
ch1160144	34	1
ch1160346	34	1
ch1170199	34	1
ch1170229	34	1
cs1140216	34	1
cs1160369	34	1
cs1160376	34	1
cs5170401	34	1
ee1160479	34	1
ee3160507	34	1
me1140667	34	1
me1140685	34	1
me2110775	34	1
me2120795	34	1
me2170644	34	1
me2170647	34	1
me2170688	34	1
mt1150375	34	1
mt1160268	34	1
mt1160491	34	1
mt1160605	34	1
mt1160611	34	1
mt1160617	34	1
mt1160626	34	1
mt1160628	34	1
mt1160630	34	1
mt1160631	34	1
mt1160633	34	1
mt6160660	34	1
ph1160573	34	1
ph1160578	34	1
ph1160580	34	1
ph1170821	34	1
ph1170829	34	1
ph1170839	34	1
tt1150936	34	1
tt1160922	34	1
tt1170893	34	1
tt1170897	34	1
tt1170900	34	1
tt1170901	34	1
tt1170902	34	1
tt1170931	34	1
asz188006	35	1
asz188660	35	1
bb5150013	35	1
ce1160200	35	1
ce1160202	35	1
ce1160205	35	1
ch1140126	35	1
ch1150090	35	1
ch1150109	35	1
ch1150129	35	1
ch1160070	35	1
ch1160077	35	1
ch1160079	35	1
ch1160081	35	1
cs1150231	35	1
ee1150425	35	1
ee1150433	35	1
me1110701	35	1
mt1160627	35	1
mt6130602	35	1
tt1150855	35	1
tt1160865	35	1
tt1160891	35	1
tt1160893	35	1
ast182713	36	1
ast182714	36	1
ast182715	36	1
ast182717	36	1
ast182718	36	1
ast182719	36	1
ast182720	36	1
ast182721	36	1
ast182724	36	1
ast182725	36	1
asz188003	36	1
asz188007	36	1
asz188511	36	1
asz188660	36	1
ch7150169	36	1
ch7150170	36	1
ch7150172	36	1
ee1150519	36	1
ph1110855	36	1
qiz188545	36	1
tt1150936	36	1
ast182713	37	1
ast182714	37	1
ast182715	37	1
ast182717	37	1
ast182718	37	1
ast182719	37	1
ast182720	37	1
ast182721	37	1
ast182724	37	1
ast182725	37	1
asz178659	37	1
asz188007	37	1
ee1150446	37	1
me2150772	37	1
ast182713	38	1
ast182714	38	1
ast182715	38	1
ast182717	38	1
ast182718	38	1
ast182719	38	1
ast182720	38	1
ast182721	38	1
ast182724	38	1
ast182725	38	1
cs1140261	38	1
tt1140937	38	1
tt1140944	38	1
tt1150941	38	1
ast172001	39	1
ast172009	39	1
ast172012	39	1
ast172015	39	1
ast182713	39	1
ast182714	39	1
ast182715	39	1
ast182718	39	1
ast182719	39	1
ast182720	39	1
ast182724	39	1
ast182725	39	1
asz188009	39	1
asz188660	39	1
bb1160028	39	1
cez188399	39	1
tt1150942	39	1
tt1160853	39	1
tt1160865	39	1
tt1160869	39	1
tt1160891	39	1
asz188003	40	1
asz188009	40	1
asz188512	40	1
asz188660	40	1
bb5120033	40	1
cs1160341	40	1
tt1140920	40	1
ast172731	41	1
ast182717	41	1
ast182721	41	1
ph1110855	41	1
ph1160548	41	1
ast182713	42	1
ast182714	42	1
ast182715	42	1
ast182717	42	1
ast182718	42	1
ast182719	42	1
ast182720	42	1
ast182721	42	1
ast182724	42	1
ast182725	42	1
asz188003	42	1
asz188511	42	1
bb1140037	43	1
bb1140053	43	1
bb1150054	43	1
bb1150061	43	1
bb5110007	46	1
bb5130011	46	1
bb5140001	46	1
bb5140005	46	1
bb5140011	46	1
bb5090033	48	1
bb5100042	48	1
bb5130033	48	1
bb5140002	48	1
bb5140003	48	1
bb5140008	48	1
bb5140009	48	1
bb5140010	48	1
bb5140012	48	1
bb5140013	48	1
bb5140015	48	1
bey177501	49	1
bey177502	49	1
bey177503	49	1
bey177505	49	1
bey177533	49	1
bey187508	49	1
bey187509	49	1
bey187511	49	1
bey187512	49	1
bey187513	49	1
bey187514	49	1
bb1150022	50	1
bb1150056	50	1
bb1150061	50	1
bb1150062	50	1
bb5090003	50	1
bb5090033	50	1
bb5130002	50	1
bb5130011	50	1
bb5130017	50	1
bb5130021	50	1
bb5150001	50	1
bb5160010	50	1
mt1160634	50	1
bb1150031	51	1
bb1150052	51	1
bb1160022	51	1
bb1160023	51	1
bb1160024	51	1
bb1160025	51	1
bb1160027	51	1
bb1160028	51	1
bb1160029	51	1
bb1160031	51	1
bb1160032	51	1
bb1160034	51	1
bb1160037	51	1
bb1160043	51	1
bb1160044	51	1
bb1160048	51	1
bb1160049	51	1
bb1160054	51	1
bb1160056	51	1
bb1160059	51	1
bb1160060	51	1
bb1160061	51	1
bb1160062	51	1
bb1160063	51	1
bb1160064	51	1
bb1170001	51	1
bb1170003	51	1
bb1170004	51	1
bb1170008	51	1
bb1170011	51	1
bb1170012	51	1
bb1170013	51	1
bb1170015	51	1
bb1170017	51	1
bb1170020	51	1
bb1170022	51	1
bb1170023	51	1
bb1170028	51	1
bb1170029	51	1
bb1170032	51	1
bb1170035	51	1
bb1170038	51	1
bb1170040	51	1
bb1170041	51	1
bb1170045	51	1
bb1170046	51	1
bb1170047	51	1
bb5110049	51	1
bb5130002	51	1
bb5140013	51	1
bb5150014	51	1
bb5160001	51	1
bb5160002	51	1
bb5160003	51	1
bb5160004	51	1
bb5160005	51	1
bb5160006	51	1
bb5160007	51	1
bb5160008	51	1
bb5160009	51	1
bb5160010	51	1
bb5160011	51	1
bb5160013	51	1
bb5160015	51	1
bb5170053	51	1
bb5170056	51	1
bb5170057	51	1
bb5170058	51	1
bb5170059	51	1
bb5170060	51	1
bb5170064	51	1
bb5170065	51	1
ch1140126	51	1
ch1150088	51	1
ch1170209	51	1
ch1170211	51	1
me2150772	51	1
bb1140024	52	1
bb1140037	52	1
bb1150031	52	1
bb1150052	52	1
bb1150053	52	1
bb1160022	52	1
bb1160023	52	1
bb1160024	52	1
bb1160025	52	1
bb1160027	52	1
bb1160028	52	1
bb1160029	52	1
bb1160031	52	1
bb1160032	52	1
bb1160033	52	1
bb1160034	52	1
bb1160035	52	1
bb1160037	52	1
bb1160039	52	1
bb1160041	52	1
bb1160043	52	1
bb1160044	52	1
bb1160045	52	1
bb1160046	52	1
bb1160047	52	1
bb1160048	52	1
bb1160049	52	1
bb1160051	52	1
bb1160052	52	1
bb1160053	52	1
bb1160054	52	1
bb1160055	52	1
bb1160056	52	1
bb1160057	52	1
bb1160059	52	1
bb1160060	52	1
bb1160061	52	1
bb1160062	52	1
bb1160063	52	1
bb5150004	52	1
bb5150012	52	1
bb5150014	52	1
bb5160001	52	1
bb5160002	52	1
bb5160003	52	1
bb5160004	52	1
bb5160005	52	1
bb5160006	52	1
bb5160007	52	1
bb5160008	52	1
bb5160009	52	1
bb5160011	52	1
bb5160012	52	1
bb5160013	52	1
bb5160015	52	1
ch1150088	52	1
ch1150091	52	1
bb1140062	53	1
bb1150026	53	1
bb1150031	53	1
bb1150052	53	1
bb1150053	53	1
bb1160023	53	1
bb1160024	53	1
bb1160025	53	1
bb1160027	53	1
bb1160028	53	1
bb1160029	53	1
bb1160030	53	1
bb1160031	53	1
bb1160032	53	1
bb1160033	53	1
bb1160034	53	1
bb1160035	53	1
bb1160037	53	1
bb1160039	53	1
bb1160041	53	1
bb1160044	53	1
bb1160045	53	1
bb1160046	53	1
bb1160047	53	1
bb1160048	53	1
bb1160049	53	1
bb1160051	53	1
bb1160052	53	1
bb1160053	53	1
bb1160054	53	1
bb1160055	53	1
bb1160056	53	1
bb1160057	53	1
bb1160059	53	1
bb1160060	53	1
bb1160061	53	1
bb1160062	53	1
bb1160063	53	1
bb5110049	53	1
bb5140005	53	1
bb5150004	53	1
bb5150014	53	1
bb5160001	53	1
bb5160002	53	1
bb5160003	53	1
bb5160005	53	1
bb5160006	53	1
bb5160007	53	1
bb5160008	53	1
bb5160009	53	1
bb5160010	53	1
bb5160011	53	1
bb5160012	53	1
bb5160013	53	1
bb5160015	53	1
bb1140062	54	1
bb1150029	54	1
bb1150031	54	1
bb1150038	54	1
bb1150040	54	1
bb1150043	54	1
bb1150052	54	1
bb1150053	54	1
bb1150055	54	1
bb1150056	54	1
bb1150062	54	1
bb1160022	54	1
bb1160023	54	1
bb1160024	54	1
bb1160025	54	1
bb1160027	54	1
bb1160028	54	1
bb1160029	54	1
bb1160030	54	1
bb1160031	54	1
bb1160032	54	1
bb1160033	54	1
bb1160034	54	1
bb1160035	54	1
bb1160037	54	1
bb1160039	54	1
bb1160041	54	1
bb1160043	54	1
bb1160044	54	1
bb1160045	54	1
bb1160046	54	1
bb1160047	54	1
bb1160048	54	1
bb1160049	54	1
bb1160051	54	1
bb1160053	54	1
bb1160054	54	1
bb1160055	54	1
bb1160056	54	1
bb1160057	54	1
bb1160058	54	1
bb1160059	54	1
bb1160060	54	1
bb1160061	54	1
bb1160062	54	1
bb1160063	54	1
bb1170012	54	1
bb1170020	54	1
bb1170026	54	1
bb1170027	54	1
bb1170034	54	1
bb1170046	54	1
bb5130033	54	1
bb5150006	54	1
bb5150007	54	1
bb5150010	54	1
bb5150014	54	1
bb5160001	54	1
bb5160002	54	1
bb5160003	54	1
bb5160004	54	1
bb5160005	54	1
bb5160006	54	1
bb5160007	54	1
bb5160008	54	1
bb5160009	54	1
bb5160010	54	1
bb5160011	54	1
bb5160012	54	1
bb5160013	54	1
bb5160015	54	1
bb5170053	54	1
bb5170057	54	1
bb5170060	54	1
bb1140024	55	1
bb1140053	55	1
bb1150032	55	1
bb1150033	55	1
bb1150034	55	1
bb1150048	55	1
bb1150053	55	1
bb1150055	55	1
bb1160039	55	1
bb1160045	55	1
bb1160052	55	1
bb1160053	55	1
bb1160055	55	1
bb1140037	56	1
bb1150040	56	1
bb1150052	56	1
bb1150054	56	1
bb1160022	56	1
bb1160024	56	1
bb1160027	56	1
bb1160032	56	1
bb1160034	56	1
bb1160037	56	1
bb1160043	56	1
bb1160044	56	1
bb1160045	56	1
bb1160046	56	1
bb1160048	56	1
bb1160049	56	1
bb1160051	56	1
bb1160053	56	1
bb1160054	56	1
bb1160057	56	1
bb1160059	56	1
bb1160060	56	1
bb1160062	56	1
bb1160063	56	1
bb5150006	56	1
bb5160001	56	1
bb5160002	56	1
bb5160003	56	1
bb5160005	56	1
bb5160009	56	1
bb5160011	56	1
bb5160012	56	1
bb5160013	56	1
bb1150025	57	1
bb1150028	57	1
bb1160047	57	1
bb5130002	57	1
bb5130017	57	1
bb5130023	57	1
bb5130033	57	1
bb5140002	57	1
bb5140003	57	1
bb5140005	57	1
bb5140009	57	1
bb5140010	57	1
bb5140012	57	1
bb5140015	57	1
bb5150001	57	1
bb5150003	57	1
bb5150004	57	1
bb5150005	57	1
bb5150006	57	1
bb5150007	57	1
bb5150009	57	1
bb5150010	57	1
bb5150012	57	1
bb5150013	57	1
bb5150015	57	1
bez188438	57	1
bez188439	57	1
bb1140024	58	1
bb1140036	58	1
bb1140039	58	1
bb1150022	58	1
bb1150026	58	1
bb1150028	58	1
bb1150030	58	1
bb1150036	58	1
bb1150040	58	1
bb1150061	58	1
bb1160044	58	1
bb1160046	58	1
bb1160051	58	1
bb1160054	58	1
bb5130011	58	1
bb5130023	58	1
bb5140013	58	1
bb5150009	58	1
bb5160015	58	1
bb1140037	59	1
bb1140039	59	1
bb1150023	59	1
bb1150029	59	1
bb1150037	59	1
bb1150043	59	1
bb1150046	59	1
bb1150054	59	1
bb1150057	59	1
bb5130002	59	1
bb5130017	59	1
bb5130023	59	1
bb5130033	59	1
bb5140008	59	1
bb5140009	59	1
bb5150001	59	1
bb5150005	59	1
bb5150006	59	1
bb5150007	59	1
bb5150010	59	1
bb5150012	59	1
bb5150015	59	1
bez188240	59	1
bez188437	59	1
bez188438	59	1
bez188439	59	1
bez188441	59	1
bez188442	59	1
cez188403	59	1
chz188077	59	1
srz188381	59	1
srz188383	59	1
bb1140037	60	1
bb1150023	60	1
bb1150030	60	1
bb1150051	60	1
bb1150054	60	1
bb1150056	60	1
bb1150064	60	1
bb5140005	60	1
bb5140009	60	1
bb5150001	60	1
bb5150003	60	1
bb5150005	60	1
bb5150006	60	1
bb5150007	60	1
bb5150009	60	1
bb5150010	60	1
bb5150012	60	1
bb5150013	60	1
bb5150015	60	1
bez188436	60	1
bez188437	60	1
bez188438	60	1
bez188439	60	1
bez188441	60	1
bez188442	60	1
bb1140062	61	1
bb1150025	61	1
bb5100042	61	1
bb5130023	61	1
bb5130033	61	1
bb5140002	61	1
bb5140005	61	1
bb5140010	61	1
bb5140011	61	1
bb5140012	61	1
bb5140013	61	1
bb5150005	61	1
bb5150009	61	1
bb5150015	61	1
bez188436	61	1
bb1150059	62	1
bb1150062	62	1
bb5070011	62	1
bb5110007	62	1
bb5130017	62	1
bb5130023	62	1
bb5140005	62	1
bb5140009	62	1
bb5150001	62	1
bb5150003	62	1
bb5150004	62	1
bb5150005	62	1
bb5150007	62	1
bb5150010	62	1
bb5150012	62	1
bb5150013	62	1
bb5150015	62	1
bb5160008	62	1
bez188239	62	1
bez188437	62	1
chz188076	62	1
cyz188472	62	1
bb1150024	63	1
bb1150028	63	1
bb1150036	63	1
bb1150037	63	1
bb1150041	63	1
bb1150042	63	1
bb1150048	63	1
bb1150050	63	1
bb1150051	63	1
bb1150052	63	1
bb1150056	63	1
bb1150059	63	1
bb1150060	63	1
bb1150063	63	1
bb1150064	63	1
bb1150065	63	1
bb1160041	63	1
bb1160056	63	1
bb5130029	63	1
bb5150001	63	1
bb5150003	63	1
bb5150007	63	1
bb5150010	63	1
bb5150013	63	1
bb5150014	63	1
bb5150015	63	1
bb5160002	63	1
bb5160003	63	1
bb5160007	63	1
bb5160012	63	1
bez188241	63	1
bez188437	63	1
bez188440	63	1
bez188441	63	1
bez188442	63	1
chz188086	63	1
bb1140024	64	1
bb1150050	64	1
bb1150063	64	1
bb1160023	64	1
bb1160049	64	1
bb1160063	64	1
bb1170012	64	1
bb1170016	64	1
bb1170038	64	1
bb1170040	64	1
bb5100042	64	1
bb5140002	64	1
bb5150009	64	1
bb5160007	64	1
bb5170060	64	1
bb5170064	64	1
ch1160103	64	1
ee3160511	64	1
me1160686	64	1
ph1150814	64	1
bb1150031	65	1
bb1150050	65	1
bb1150051	65	1
bb1150061	65	1
bb1160029	65	1
bb1160032	65	1
bb1160037	65	1
bb1160049	65	1
bb1160051	65	1
bb1160052	65	1
bb1160053	65	1
bb1170013	65	1
bb1170020	65	1
bb1170026	65	1
bb1170027	65	1
bb5160006	65	1
bb5160008	65	1
bb5160012	65	1
bb5160013	65	1
cs1150261	65	1
bb1140024	66	1
bb1150030	66	1
bb1150031	66	1
bb1150032	66	1
bb1150050	66	1
bb1150051	66	1
bb1150063	66	1
bb1150065	66	1
bb1160022	66	1
bb1160024	66	1
bb1160027	66	1
bb1160030	66	1
bb5150001	66	1
bb5150015	66	1
ch1160085	66	1
ch1160105	66	1
ch1160117	66	1
ch7150172	66	1
cs5130280	66	1
tt1150865	66	1
bey167506	67	1
bmt172114	68	1
bmt172115	68	1
bmt172116	68	1
bmt172117	68	1
bmt172119	68	1
bmt172120	68	1
bmt172121	68	1
bb1150025	69	1
bmt182309	69	1
bmt182310	69	1
bmt182312	69	1
bmz188310	69	1
bsz188119	69	1
crz188292	69	1
crz188653	69	1
cyz188200	69	1
eet172292	69	1
eet172294	69	1
eet172299	69	1
eet172302	69	1
eet172304	69	1
eet172308	69	1
eet172681	69	1
eet172839	69	1
eet172841	69	1
eet182554	69	1
eet182555	69	1
eet182557	69	1
eet182562	69	1
eet182563	69	1
eet182566	69	1
eet182569	69	1
eet182570	69	1
eet182575	69	1
eez188144	69	1
eez188562	69	1
mey177544	69	1
mey187543	69	1
pha182366	69	1
phz182357	69	1
phz188337	69	1
qiz188608	69	1
bb1140053	70	1
bb1150021	70	1
bb1150022	70	1
bb1150025	70	1
bb5120033	70	1
bmt182308	70	1
bmt182309	70	1
bmt182310	70	1
bmt182311	70	1
bmt182312	70	1
bmt182313	70	1
bmz178631	70	1
bmz188298	70	1
mey187543	70	1
ph1150822	70	1
vst189745	70	1
bb1150021	71	1
bb1150023	71	1
bb1150025	71	1
bb5140012	71	1
bmt182308	71	1
bmt182309	71	1
bmt182310	71	1
bmt182311	71	1
bmt182312	71	1
bmt182313	71	1
bmz188298	71	1
ch7140164	71	1
ch7140194	71	1
cs1140216	71	1
cs1140261	71	1
cs1170344	71	1
mt6140556	71	1
bmt182308	72	1
bmt182311	72	1
bmz188298	72	1
mey177544	72	1
qiz188609	72	1
bmt182308	73	1
bmt182309	73	1
bmt182310	73	1
bmt182311	73	1
bmt182312	73	1
bmt182313	73	1
bmz188298	73	1
mez177523	73	1
ph1150809	73	1
bb1150040	74	1
bmt182309	74	1
bmt182311	74	1
bmt182313	74	1
bmz178413	74	1
bmz178630	74	1
bmz178631	74	1
bmz188309	74	1
bmz188509	75	1
cyz188480	75	1
me1170021	75	1
mez177523	75	1
mez188587	75	1
mez188588	75	1
mez188599	75	1
msz188507	75	1
bb5110029	76	1
bmt182310	76	1
bmt182312	76	1
bmz188510	76	1
ch1150103	76	1
jpt172615	76	1
jpt182480	76	1
mez188270	76	1
ph1140790	76	1
bb1150025	77	1
bmt182308	77	1
bmt182309	77	1
bmt182310	77	1
bmt182311	77	1
bmt182312	77	1
bmt182313	77	1
bsy167510	78	1
bsy167511	78	1
bsy177507	78	1
bsy177508	78	1
ch7100145	80	1
ch7120189	80	1
ch7120169	81	1
ch1120067	84	1
ch1130071	84	1
ch1140126	84	1
ch1150072	84	1
ch1150076	84	1
ch1150078	84	1
ch1150079	84	1
ch1150094	84	1
ch1150115	84	1
ch1150118	84	1
ch1150119	84	1
ch1150124	84	1
ch7130170	84	1
ch1150093	85	1
ch1150133	85	1
ch1150141	85	1
ch1150143	85	1
ch1150145	85	1
ch1150104	88	1
ch1150131	88	1
ch1150138	88	1
che182089	89	1
che182404	89	1
che182489	89	1
che182490	89	1
che182491	89	1
che182492	89	1
che182494	89	1
che182496	89	1
che182497	89	1
che182498	89	1
che182500	89	1
che182501	89	1
che182503	89	1
che182506	89	1
che182507	89	1
che182509	89	1
che182511	89	1
che182512	89	1
che182513	89	1
che182515	89	1
che182516	89	1
che182517	89	1
che182518	89	1
che182519	89	1
che182520	89	1
che182521	89	1
che182522	89	1
che182523	89	1
che182524	89	1
che182864	89	1
che182876	89	1
che182878	89	1
ch7130151	90	1
che172150	91	1
che172152	91	1
che172164	91	1
che172549	91	1
che172550	91	1
che172553	91	1
che172555	91	1
che172557	91	1
che172724	91	1
che172727	91	1
che172728	91	1
che172729	91	1
che172730	91	1
che172770	91	1
che172834	91	1
ch7130156	92	1
ch7140184	92	1
ch7150151	92	1
ch7150153	92	1
ch7150154	92	1
ch7150155	92	1
ch7150156	92	1
ch7150157	92	1
ch7150158	92	1
ch7150159	92	1
ch7150160	92	1
ch7150161	92	1
ch7150162	92	1
ch7150163	92	1
ch7150164	92	1
ch7150165	92	1
ch7150166	92	1
ch7150167	92	1
ch7150168	92	1
ch7150169	92	1
ch7150170	92	1
ch7150171	92	1
ch7150172	92	1
ch7150173	92	1
ch7150174	92	1
ch7150175	92	1
ch7150176	92	1
ch7150177	92	1
ch7150178	92	1
ch7150179	92	1
ch7150180	92	1
ch7150183	92	1
ch7150184	92	1
ch7150185	92	1
ch7150186	92	1
ch7150187	92	1
ch7150188	92	1
ch7150189	92	1
ch7150191	92	1
ch7150193	92	1
ch7150194	92	1
ch7150195	92	1
ch7130179	93	1
ch7140166	93	1
ch7130159	94	1
ch7130162	94	1
ch7140049	94	1
ch7140151	94	1
ch7140153	94	1
ch7140154	94	1
ch7140155	94	1
ch7140156	94	1
ch7140159	94	1
ch7140161	94	1
ch7140162	94	1
ch7140163	94	1
ch7140164	94	1
ch7140170	94	1
ch7140171	94	1
ch7140172	94	1
ch7140173	94	1
ch7140174	94	1
ch7140175	94	1
ch7140177	94	1
ch7140178	94	1
ch7140179	94	1
ch7140180	94	1
ch7140181	94	1
ch7140182	94	1
ch7140183	94	1
ch7140186	94	1
ch7140187	94	1
ch7140189	94	1
ch7140190	94	1
ch7140192	94	1
ch7140193	94	1
ch7140194	94	1
ch7140195	94	1
ch7140196	94	1
ch7140197	94	1
ch7140198	94	1
ch7140834	94	1
che172565	94	1
bb1150042	95	1
ch1130070	95	1
ch1130119	95	1
ch1140121	95	1
ch1140145	95	1
ch1150078	95	1
ch1150120	95	1
ch1150124	95	1
ch1160091	95	1
ch1160104	95	1
ch1160115	95	1
ch1160116	95	1
ch1160128	95	1
ch1160129	95	1
ch1160132	95	1
ch1160133	95	1
ch1160137	95	1
ch1160140	95	1
ch1160141	95	1
ch1160142	95	1
ch1160144	95	1
ch1160346	95	1
ch1170086	95	1
ch1170087	95	1
ch1170114	95	1
ch1170120	95	1
ch1170161	95	1
ch1170186	95	1
ch1170187	95	1
ch1170188	95	1
ch1170189	95	1
ch1170190	95	1
ch1170191	95	1
ch1170192	95	1
ch1170193	95	1
ch1170194	95	1
ch1170195	95	1
ch1170196	95	1
ch1170197	95	1
ch1170198	95	1
ch1170199	95	1
ch1170200	95	1
ch1170201	95	1
ch1170202	95	1
ch1170203	95	1
ch1170204	95	1
ch1170205	95	1
ch1170206	95	1
ch1170208	95	1
ch1170209	95	1
ch1170210	95	1
ch1170211	95	1
ch1170212	95	1
ch1170214	95	1
ch1170215	95	1
ch1170216	95	1
ch1170218	95	1
ch1170222	95	1
ch1170223	95	1
ch1170224	95	1
ch1170225	95	1
ch1170226	95	1
ch1170227	95	1
ch1170228	95	1
ch1170229	95	1
ch1170231	95	1
ch1170232	95	1
ch1170233	95	1
ch1170234	95	1
ch1170235	95	1
ch1170236	95	1
ch1170237	95	1
ch1170238	95	1
ch1170239	95	1
ch1170240	95	1
ch1170241	95	1
ch1170242	95	1
ch1170243	95	1
ch1170244	95	1
ch1170246	95	1
ch1170247	95	1
ch1170248	95	1
ch1170251	95	1
ch1170252	95	1
ch1170253	95	1
ch1170254	95	1
ch1170255	95	1
ch1170256	95	1
ch1170257	95	1
ch1170258	95	1
ch1170259	95	1
ch1170260	95	1
ch1170297	95	1
ch1170309	95	1
ch1170311	95	1
ch1170894	95	1
ch7140180	95	1
ch7140187	95	1
ch7160150	95	1
ch7160169	95	1
ch7160173	95	1
ch7160176	95	1
ch7160180	95	1
ch7160184	95	1
ch7160191	95	1
ch7170271	95	1
ch7170272	95	1
ch7170273	95	1
ch7170274	95	1
ch7170275	95	1
ch7170276	95	1
ch7170277	95	1
ch7170278	95	1
ch7170279	95	1
ch7170280	95	1
ch7170281	95	1
ch7170282	95	1
ch7170283	95	1
ch7170284	95	1
ch7170285	95	1
ch7170286	95	1
ch7170288	95	1
ch7170289	95	1
ch7170290	95	1
ch7170291	95	1
ch7170292	95	1
ch7170293	95	1
ch7170294	95	1
ch7170295	95	1
ch7170296	95	1
ch7170298	95	1
ch7170299	95	1
ch7170300	95	1
ch7170301	95	1
ch7170302	95	1
ch7170303	95	1
ch7170304	95	1
ch7170305	95	1
ch7170307	95	1
ch7170308	95	1
ch7170310	95	1
ch7170312	95	1
ch7170314	95	1
bb1150034	96	1
bb1160058	96	1
bb1160064	96	1
bb1170001	96	1
bb1170002	96	1
bb1170003	96	1
bb1170004	96	1
bb1170005	96	1
bb1170006	96	1
bb1170007	96	1
bb1170008	96	1
bb1170009	96	1
bb1170011	96	1
bb1170012	96	1
bb1170013	96	1
bb1170014	96	1
bb1170015	96	1
bb1170016	96	1
bb1170017	96	1
bb1170018	96	1
bb1170020	96	1
bb1170022	96	1
bb1170023	96	1
bb1170024	96	1
bb1170025	96	1
bb1170026	96	1
bb1170027	96	1
bb1170028	96	1
bb1170029	96	1
bb1170030	96	1
bb1170031	96	1
bb1170032	96	1
bb1170033	96	1
bb1170034	96	1
bb1170035	96	1
bb1170037	96	1
bb1170038	96	1
bb1170039	96	1
bb1170040	96	1
bb1170041	96	1
bb1170042	96	1
bb1170045	96	1
bb1170046	96	1
bb1170047	96	1
bb5150009	96	1
bb5160014	96	1
bb5170051	96	1
bb5170052	96	1
bb5170053	96	1
bb5170054	96	1
bb5170055	96	1
bb5170056	96	1
bb5170057	96	1
bb5170058	96	1
bb5170059	96	1
bb5170060	96	1
bb5170062	96	1
bb5170064	96	1
bb5170065	96	1
ch1160104	96	1
ch1160128	96	1
ch1160141	96	1
ch1160142	96	1
ch1160144	96	1
ch1170086	96	1
ch1170087	96	1
ch1170114	96	1
ch1170120	96	1
ch1170161	96	1
ch1170186	96	1
ch1170187	96	1
ch1170188	96	1
ch1170189	96	1
ch1170190	96	1
ch1170191	96	1
ch1170192	96	1
ch1170193	96	1
ch1170194	96	1
ch1170195	96	1
ch1170196	96	1
ch1170197	96	1
ch1170198	96	1
ch1170199	96	1
ch1170200	96	1
ch1170201	96	1
ch1170202	96	1
ch1170203	96	1
ch1170204	96	1
ch1170205	96	1
ch1170206	96	1
ch1170208	96	1
ch1170209	96	1
ch1170210	96	1
ch1170211	96	1
ch1170212	96	1
ch1170214	96	1
ch1170215	96	1
ch1170216	96	1
ch1170218	96	1
ch1170222	96	1
ch1170223	96	1
ch1170224	96	1
ch1170225	96	1
ch1170226	96	1
ch1170227	96	1
ch1170228	96	1
ch1170229	96	1
ch1170231	96	1
ch1170232	96	1
ch1170233	96	1
ch1170234	96	1
ch1170235	96	1
ch1170236	96	1
ch1170237	96	1
ch1170238	96	1
ch1170239	96	1
ch1170240	96	1
ch1170241	96	1
ch1170242	96	1
ch1170243	96	1
ch1170244	96	1
ch1170246	96	1
ch1170247	96	1
ch1170248	96	1
ch1170251	96	1
ch1170252	96	1
ch1170253	96	1
ch1170254	96	1
ch1170255	96	1
ch1170256	96	1
ch1170257	96	1
ch1170258	96	1
ch1170259	96	1
ch1170260	96	1
ch1170297	96	1
ch1170309	96	1
ch1170311	96	1
ch1170894	96	1
ch7160180	96	1
ch7160184	96	1
ch7160191	96	1
ch7170271	96	1
ch7170272	96	1
ch7170273	96	1
ch7170274	96	1
ch7170275	96	1
ch7170276	96	1
ch7170277	96	1
ch7170278	96	1
ch7170279	96	1
ch7170280	96	1
ch7170281	96	1
ch7170282	96	1
ch7170283	96	1
ch7170284	96	1
ch7170285	96	1
ch7170286	96	1
ch7170288	96	1
ch7170289	96	1
ch7170290	96	1
ch7170291	96	1
ch7170292	96	1
ch7170293	96	1
ch7170294	96	1
ch7170295	96	1
ch7170296	96	1
ch7170298	96	1
ch7170299	96	1
ch7170300	96	1
ch7170301	96	1
ch7170302	96	1
ch7170303	96	1
ch7170304	96	1
ch7170305	96	1
ch7170307	96	1
ch7170308	96	1
ch7170310	96	1
ch7170312	96	1
ch7170314	96	1
bb1140037	97	1
bb1140039	97	1
bb1140053	97	1
bb1140062	97	1
bb1150026	97	1
bb1150030	97	1
bb1160022	97	1
bb1160037	97	1
bb1160052	97	1
bb1160055	97	1
bb1160058	97	1
bb1160064	97	1
bb1160065	97	1
bb1170001	97	1
bb1170002	97	1
bb1170003	97	1
bb1170004	97	1
bb1170005	97	1
bb1170006	97	1
bb1170007	97	1
bb1170008	97	1
bb1170009	97	1
bb1170011	97	1
bb1170013	97	1
bb1170014	97	1
bb1170015	97	1
bb1170016	97	1
bb1170017	97	1
bb1170018	97	1
bb1170020	97	1
bb1170022	97	1
bb1170023	97	1
bb1170024	97	1
bb1170025	97	1
bb1170027	97	1
bb1170028	97	1
bb1170029	97	1
bb1170030	97	1
bb1170031	97	1
bb1170032	97	1
bb1170033	97	1
bb1170034	97	1
bb1170035	97	1
bb1170037	97	1
bb1170038	97	1
bb1170039	97	1
bb1170040	97	1
bb1170041	97	1
bb1170042	97	1
bb1170046	97	1
bb1170047	97	1
bb5130017	97	1
bb5130023	97	1
bb5170051	97	1
bb5170053	97	1
bb5170054	97	1
bb5170055	97	1
bb5170056	97	1
bb5170057	97	1
bb5170058	97	1
bb5170059	97	1
bb5170060	97	1
bb5170062	97	1
bb5170064	97	1
bb5170065	97	1
ch1130080	97	1
ch1130119	97	1
ch1150078	97	1
ch1150124	97	1
ch1160074	97	1
ch1160089	97	1
ch1160092	97	1
ch1160098	97	1
ch1160120	97	1
ch1160128	97	1
ch1160141	97	1
ch1160142	97	1
ch1160144	97	1
ch1170086	97	1
ch1170087	97	1
ch1170114	97	1
ch1170161	97	1
ch1170186	97	1
ch1170187	97	1
ch1170188	97	1
ch1170190	97	1
ch1170191	97	1
ch1170192	97	1
ch1170193	97	1
ch1170194	97	1
ch1170195	97	1
ch1170196	97	1
ch1170197	97	1
ch1170198	97	1
ch1170199	97	1
ch1170200	97	1
ch1170201	97	1
ch1170202	97	1
ch1170203	97	1
ch1170204	97	1
ch1170205	97	1
ch1170206	97	1
ch1170208	97	1
ch1170209	97	1
ch1170210	97	1
ch1170211	97	1
ch1170212	97	1
ch1170214	97	1
ch1170215	97	1
ch1170216	97	1
ch1170218	97	1
ch1170222	97	1
ch1170223	97	1
ch1170224	97	1
ch1170225	97	1
ch1170226	97	1
ch1170227	97	1
ch1170228	97	1
ch1170229	97	1
ch1170231	97	1
ch1170232	97	1
ch1170233	97	1
ch1170234	97	1
ch1170235	97	1
ch1170236	97	1
ch1170237	97	1
ch1170238	97	1
ch1170239	97	1
ch1170240	97	1
ch1170241	97	1
ch1170242	97	1
ch1170244	97	1
ch1170246	97	1
ch1170247	97	1
ch1170248	97	1
ch1170251	97	1
ch1170252	97	1
ch1170253	97	1
ch1170254	97	1
ch1170255	97	1
ch1170256	97	1
ch1170257	97	1
ch1170258	97	1
ch1170259	97	1
ch1170260	97	1
ch1170297	97	1
ch1170309	97	1
ch1170311	97	1
ch7130162	97	1
ch7140184	97	1
ch7140192	97	1
ch7160156	97	1
ch7160167	97	1
ch7160173	97	1
ch7160176	97	1
ch7160177	97	1
ch7160184	97	1
ch7170271	97	1
ch7170272	97	1
ch7170273	97	1
ch7170274	97	1
ch7170275	97	1
ch7170276	97	1
ch7170277	97	1
ch7170278	97	1
ch7170279	97	1
ch7170280	97	1
ch7170281	97	1
ch7170282	97	1
ch7170283	97	1
ch7170284	97	1
ch7170286	97	1
ch7170288	97	1
ch7170289	97	1
ch7170290	97	1
ch7170291	97	1
ch7170292	97	1
ch7170293	97	1
ch7170294	97	1
ch7170295	97	1
ch7170296	97	1
ch7170298	97	1
ch7170299	97	1
ch7170300	97	1
ch7170301	97	1
ch7170302	97	1
ch7170303	97	1
ch7170304	97	1
ch7170305	97	1
ch7170307	97	1
ch7170308	97	1
ch7170310	97	1
ch7170312	97	1
ch7170314	97	1
bb1140062	98	1
bb1150054	98	1
bb1160058	98	1
bb1160063	98	1
bb1160064	98	1
bb1160065	98	1
bb1170001	98	1
bb1170002	98	1
bb1170003	98	1
bb1170004	98	1
bb1170005	98	1
bb1170006	98	1
bb1170007	98	1
bb1170008	98	1
bb1170009	98	1
bb1170011	98	1
bb1170012	98	1
bb1170013	98	1
bb1170014	98	1
bb1170015	98	1
bb1170016	98	1
bb1170017	98	1
bb1170018	98	1
bb1170020	98	1
bb1170022	98	1
bb1170023	98	1
bb1170024	98	1
bb1170025	98	1
bb1170026	98	1
bb1170027	98	1
bb1170028	98	1
bb1170029	98	1
bb1170030	98	1
bb1170031	98	1
bb1170032	98	1
bb1170033	98	1
bb1170034	98	1
bb1170035	98	1
bb1170037	98	1
bb1170038	98	1
bb1170039	98	1
bb1170040	98	1
bb1170041	98	1
bb1170042	98	1
bb1170045	98	1
bb1170046	98	1
bb1170047	98	1
bb5160010	98	1
bb5170051	98	1
bb5170053	98	1
bb5170054	98	1
bb5170055	98	1
bb5170056	98	1
bb5170057	98	1
bb5170058	98	1
bb5170059	98	1
bb5170060	98	1
bb5170062	98	1
bb5170064	98	1
bb5170065	98	1
ch1130070	98	1
ch1140121	98	1
ch1150093	98	1
ch1150096	98	1
ch1150119	98	1
ch1160120	98	1
ch1160128	98	1
ch1160141	98	1
ch1160142	98	1
ch1160144	98	1
ch1170086	98	1
ch1170087	98	1
ch1170114	98	1
ch1170120	98	1
ch1170161	98	1
ch1170186	98	1
ch1170187	98	1
ch1170188	98	1
ch1170189	98	1
ch1170190	98	1
ch1170191	98	1
ch1170192	98	1
ch1170193	98	1
ch1170194	98	1
ch1170195	98	1
ch1170196	98	1
ch1170197	98	1
ch1170198	98	1
ch1170199	98	1
ch1170200	98	1
ch1170201	98	1
ch1170202	98	1
ch1170203	98	1
ch1170204	98	1
ch1170205	98	1
ch1170206	98	1
ch1170208	98	1
ch1170209	98	1
ch1170210	98	1
ch1170211	98	1
ch1170212	98	1
ch1170214	98	1
ch1170215	98	1
ch1170216	98	1
ch1170218	98	1
ch1170222	98	1
ch1170223	98	1
ch1170224	98	1
ch1170225	98	1
ch1170226	98	1
ch1170227	98	1
ch1170228	98	1
ch1170229	98	1
ch1170231	98	1
ch1170232	98	1
ch1170233	98	1
ch1170234	98	1
ch1170235	98	1
ch1170236	98	1
ch1170237	98	1
ch1170238	98	1
ch1170239	98	1
ch1170240	98	1
ch1170241	98	1
ch1170242	98	1
ch1170243	98	1
ch1170244	98	1
ch1170246	98	1
ch1170247	98	1
ch1170248	98	1
ch1170251	98	1
ch1170252	98	1
ch1170253	98	1
ch1170254	98	1
ch1170255	98	1
ch1170256	98	1
ch1170257	98	1
ch1170258	98	1
ch1170259	98	1
ch1170260	98	1
ch1170297	98	1
ch1170309	98	1
ch1170311	98	1
ch1170894	98	1
ch7130162	98	1
ch7140191	98	1
ch7150158	98	1
ch7150160	98	1
ch7150171	98	1
ch7150173	98	1
ch7170271	98	1
ch7170272	98	1
ch7170273	98	1
ch7170274	98	1
ch7170275	98	1
ch7170276	98	1
ch7170277	98	1
ch7170278	98	1
ch7170279	98	1
ch7170280	98	1
ch7170281	98	1
ch7170282	98	1
ch7170283	98	1
ch7170284	98	1
ch7170286	98	1
ch7170288	98	1
ch7170289	98	1
ch7170290	98	1
ch7170291	98	1
ch7170292	98	1
ch7170293	98	1
ch7170294	98	1
ch7170295	98	1
ch7170296	98	1
ch7170298	98	1
ch7170299	98	1
ch7170300	98	1
ch7170301	98	1
ch7170302	98	1
ch7170303	98	1
ch7170304	98	1
ch7170305	98	1
ch7170307	98	1
ch7170308	98	1
ch7170310	98	1
ch7170312	98	1
ch7170314	98	1
ch1140121	99	1
ch1140145	99	1
ch1150078	99	1
ch1150106	99	1
ch1150120	99	1
ch1150134	99	1
ch1150136	99	1
ch1150143	99	1
ch1160072	99	1
ch1160074	99	1
ch1160075	99	1
ch1160076	99	1
ch1160077	99	1
ch1160079	99	1
ch1160081	99	1
ch1160083	99	1
ch1160085	99	1
ch1160088	99	1
ch1160089	99	1
ch1160090	99	1
ch1160091	99	1
ch1160092	99	1
ch1160093	99	1
ch1160094	99	1
ch1160095	99	1
ch1160096	99	1
ch1160097	99	1
ch1160098	99	1
ch1160099	99	1
ch1160100	99	1
ch1160101	99	1
ch1160102	99	1
ch1160103	99	1
ch1160106	99	1
ch1160108	99	1
ch1160110	99	1
ch1160111	99	1
ch1160112	99	1
ch1160113	99	1
ch1160114	99	1
ch1160115	99	1
ch1160116	99	1
ch1160117	99	1
ch1160118	99	1
ch1160119	99	1
ch1160120	99	1
ch1160121	99	1
ch1160122	99	1
ch1160123	99	1
ch1160124	99	1
ch1160125	99	1
ch1160126	99	1
ch1160127	99	1
ch1160129	99	1
ch1160130	99	1
ch1160131	99	1
ch1160132	99	1
ch1160134	99	1
ch1160135	99	1
ch1160136	99	1
ch1160138	99	1
ch1160140	99	1
ch1160143	99	1
ch1160166	99	1
ch1160346	99	1
ch1160675	99	1
ch7130159	99	1
ch7140184	99	1
ch7150155	99	1
ch7150193	99	1
ch7150194	99	1
ch7150195	99	1
ch7160150	99	1
ch7160152	99	1
ch7160153	99	1
ch7160154	99	1
ch7160155	99	1
ch7160156	99	1
ch7160157	99	1
ch7160158	99	1
ch7160159	99	1
ch7160162	99	1
ch7160163	99	1
ch7160164	99	1
ch7160165	99	1
ch7160167	99	1
ch7160168	99	1
ch7160169	99	1
ch7160170	99	1
ch7160171	99	1
ch7160172	99	1
ch7160173	99	1
ch7160174	99	1
ch7160175	99	1
ch7160176	99	1
ch7160177	99	1
ch7160178	99	1
ch7160179	99	1
ch7160181	99	1
ch7160182	99	1
ch7160183	99	1
ch7160185	99	1
ch7160186	99	1
ch7160187	99	1
ch7160188	99	1
ch7160189	99	1
ch7160190	99	1
ch7160192	99	1
ch7160193	99	1
ch7160194	99	1
ch1140126	100	1
ch1140145	100	1
ch1150076	100	1
ch1150078	100	1
ch1150106	100	1
ch1150116	100	1
ch1150127	100	1
ch1150134	100	1
ch1150140	100	1
ch1150385	100	1
ch1160070	100	1
ch1160072	100	1
ch1160074	100	1
ch1160075	100	1
ch1160076	100	1
ch1160077	100	1
ch1160079	100	1
ch1160081	100	1
ch1160082	100	1
ch1160083	100	1
ch1160085	100	1
ch1160088	100	1
ch1160089	100	1
ch1160090	100	1
ch1160091	100	1
ch1160092	100	1
ch1160093	100	1
ch1160094	100	1
ch1160095	100	1
ch1160096	100	1
ch1160097	100	1
ch1160098	100	1
ch1160099	100	1
ch1160100	100	1
ch1160101	100	1
ch1160102	100	1
ch1160103	100	1
ch1160104	100	1
ch1160105	100	1
ch1160106	100	1
ch1160108	100	1
ch1160109	100	1
ch1160110	100	1
ch1160111	100	1
ch1160112	100	1
ch1160113	100	1
ch1160114	100	1
ch1160115	100	1
ch1160116	100	1
ch1160117	100	1
ch1160118	100	1
ch1160119	100	1
ch1160121	100	1
ch1160122	100	1
ch1160123	100	1
ch1160124	100	1
ch1160125	100	1
ch1160126	100	1
ch1160127	100	1
ch1160129	100	1
ch1160130	100	1
ch1160131	100	1
ch1160132	100	1
ch1160133	100	1
ch1160134	100	1
ch1160135	100	1
ch1160136	100	1
ch1160137	100	1
ch1160138	100	1
ch1160140	100	1
ch1160143	100	1
ch1160166	100	1
ch1160346	100	1
ch1160675	100	1
ch7120189	100	1
ch7150164	100	1
ch7150176	100	1
ch7150186	100	1
ch7160150	100	1
ch7160151	100	1
ch7160152	100	1
ch7160153	100	1
ch7160154	100	1
ch7160155	100	1
ch7160156	100	1
ch7160157	100	1
ch7160158	100	1
ch7160159	100	1
ch7160162	100	1
ch7160163	100	1
ch7160164	100	1
ch7160165	100	1
ch7160167	100	1
ch7160168	100	1
ch7160169	100	1
ch7160170	100	1
ch7160171	100	1
ch7160172	100	1
ch7160173	100	1
ch7160174	100	1
ch7160175	100	1
ch7160177	100	1
ch7160178	100	1
ch7160179	100	1
ch7160180	100	1
ch7160181	100	1
ch7160182	100	1
ch7160183	100	1
ch7160184	100	1
ch7160185	100	1
ch7160186	100	1
ch7160187	100	1
ch7160188	100	1
ch7160189	100	1
ch7160190	100	1
ch7160192	100	1
ch7160193	100	1
ch7160194	100	1
ch1130119	101	1
ch1140071	101	1
ch1150134	101	1
ch1160070	101	1
ch1160074	101	1
ch1160075	101	1
ch1160076	101	1
ch1160077	101	1
ch1160079	101	1
ch1160081	101	1
ch1160082	101	1
ch1160083	101	1
ch1160085	101	1
ch1160088	101	1
ch1160089	101	1
ch1160090	101	1
ch1160091	101	1
ch1160092	101	1
ch1160093	101	1
ch1160094	101	1
ch1160095	101	1
ch1160096	101	1
ch1160097	101	1
ch1160098	101	1
ch1160099	101	1
ch1160100	101	1
ch1160101	101	1
ch1160102	101	1
ch1160103	101	1
ch1160104	101	1
ch1160105	101	1
ch1160106	101	1
ch1160108	101	1
ch1160109	101	1
ch1160110	101	1
ch1160111	101	1
ch1160112	101	1
ch1160113	101	1
ch1160114	101	1
ch1160116	101	1
ch1160117	101	1
ch1160118	101	1
ch1160119	101	1
ch1160120	101	1
ch1160121	101	1
ch1160122	101	1
ch1160123	101	1
ch1160124	101	1
ch1160125	101	1
ch1160126	101	1
ch1160127	101	1
ch1160129	101	1
ch1160130	101	1
ch1160132	101	1
ch1160133	101	1
ch1160134	101	1
ch1160135	101	1
ch1160136	101	1
ch1160137	101	1
ch1160138	101	1
ch1160140	101	1
ch1160143	101	1
ch1160144	101	1
ch1160166	101	1
ch1160675	101	1
ch7100145	101	1
ch7160150	101	1
ch7160151	101	1
ch7160152	101	1
ch7160153	101	1
ch7160154	101	1
ch7160155	101	1
ch7160156	101	1
ch7160157	101	1
ch7160158	101	1
ch7160159	101	1
ch7160162	101	1
ch7160163	101	1
ch7160164	101	1
ch7160165	101	1
ch7160167	101	1
ch7160168	101	1
ch7160169	101	1
ch7160170	101	1
ch7160171	101	1
ch7160172	101	1
ch7160173	101	1
ch7160174	101	1
ch7160175	101	1
ch7160177	101	1
ch7160178	101	1
ch7160179	101	1
ch7160180	101	1
ch7160181	101	1
ch7160182	101	1
ch7160183	101	1
ch7160184	101	1
ch7160185	101	1
ch7160186	101	1
ch7160187	101	1
ch7160188	101	1
ch7160189	101	1
ch7160190	101	1
ch7160192	101	1
ch7160193	101	1
ch7160194	101	1
ch1140145	102	1
ch1150073	102	1
ch1150076	102	1
ch1150089	102	1
ch1150090	102	1
ch1150091	102	1
ch1150097	102	1
ch1150100	102	1
ch1150105	102	1
ch1150107	102	1
ch1150125	102	1
ch1150128	102	1
ch1150132	102	1
ch1150133	102	1
ch1150134	102	1
ch1150136	102	1
ch1150137	102	1
ch1150145	102	1
ch1150190	102	1
ch1160070	102	1
ch1160072	102	1
ch1160074	102	1
ch1160075	102	1
ch1160076	102	1
ch1160077	102	1
ch1160079	102	1
ch1160081	102	1
ch1160082	102	1
ch1160083	102	1
ch1160085	102	1
ch1160088	102	1
ch1160089	102	1
ch1160090	102	1
ch1160091	102	1
ch1160092	102	1
ch1160093	102	1
ch1160094	102	1
ch1160095	102	1
ch1160096	102	1
ch1160097	102	1
ch1160098	102	1
ch1160099	102	1
ch1160100	102	1
ch1160101	102	1
ch1160102	102	1
ch1160103	102	1
ch1160105	102	1
ch1160106	102	1
ch1160108	102	1
ch1160109	102	1
ch1160110	102	1
ch1160111	102	1
ch1160112	102	1
ch1160113	102	1
ch1160114	102	1
ch1160115	102	1
ch1160116	102	1
ch1160117	102	1
ch1160118	102	1
ch1160119	102	1
ch1160120	102	1
ch1160121	102	1
ch1160122	102	1
ch1160123	102	1
ch1160124	102	1
ch1160125	102	1
ch1160126	102	1
ch1160127	102	1
ch1160129	102	1
ch1160130	102	1
ch1160131	102	1
ch1160132	102	1
ch1160133	102	1
ch1160134	102	1
ch1160135	102	1
ch1160136	102	1
ch1160137	102	1
ch1160138	102	1
ch1160140	102	1
ch1160143	102	1
ch1160166	102	1
ch1160346	102	1
ch1160675	102	1
ch7100145	102	1
ch7140153	102	1
ch7140171	102	1
ch7160150	102	1
ch7160151	102	1
ch7160152	102	1
ch7160153	102	1
ch7160154	102	1
ch7160155	102	1
ch7160156	102	1
ch7160157	102	1
ch7160158	102	1
ch7160159	102	1
ch7160162	102	1
ch7160163	102	1
ch7160164	102	1
ch7160165	102	1
ch7160167	102	1
ch7160168	102	1
ch7160169	102	1
ch7160170	102	1
ch7160171	102	1
ch7160172	102	1
ch7160173	102	1
ch7160174	102	1
ch7160175	102	1
ch7160176	102	1
ch7160177	102	1
ch7160178	102	1
ch7160179	102	1
ch7160180	102	1
ch7160181	102	1
ch7160182	102	1
ch7160183	102	1
ch7160184	102	1
ch7160185	102	1
ch7160186	102	1
ch7160187	102	1
ch7160188	102	1
ch7160189	102	1
ch7160190	102	1
ch7160192	102	1
ch7160193	102	1
ch7160194	102	1
ch1150081	103	1
ch1150082	103	1
ch1150083	103	1
ch1150084	103	1
ch1150086	103	1
ch1150088	103	1
ch1150092	103	1
ch1150096	103	1
ch1150103	103	1
ch1150116	103	1
ch7120168	103	1
ch7120169	103	1
ch1150077	104	1
ch1150083	104	1
ch1150086	104	1
ch1150087	104	1
ch1150092	104	1
ch1150109	104	1
ch1150115	104	1
ch1150117	104	1
ch1150120	104	1
ch1150129	104	1
ch7120168	104	1
ch7130156	104	1
ch7130159	104	1
ch7130179	104	1
ch7140154	104	1
ch7140183	104	1
ch7140187	104	1
ch7140192	104	1
ch7150159	104	1
ch7150163	104	1
ch7150178	104	1
ch7150179	104	1
ch7150180	104	1
ch7150184	104	1
ch7150191	104	1
ch1130119	105	1
ch1140071	105	1
ch1150098	105	1
ch1150122	105	1
ch1150123	105	1
ch1150132	105	1
ch1150137	105	1
ch1150945	105	1
ch7140151	105	1
ch7140162	105	1
ch7140184	105	1
ch7140190	105	1
ch7140195	105	1
ch7140197	105	1
ch7140198	105	1
ch7150154	105	1
ch7150156	105	1
ch7150161	105	1
ch7150162	105	1
ch7150177	105	1
ch7150185	105	1
ch7150187	105	1
che182494	105	1
che182496	105	1
che182503	105	1
che182506	105	1
che182509	105	1
che182512	105	1
che182513	105	1
che182516	105	1
chz188081	105	1
chz188083	105	1
chz188232	105	1
chz188501	105	1
phz188334	105	1
srz188606	105	1
ch7130179	106	1
ch7140154	106	1
ch7140197	106	1
ch7140198	106	1
ch7150169	106	1
ch7150173	106	1
ch7150176	106	1
ch7150178	106	1
ch7150183	106	1
ch7150194	106	1
che172152	106	1
che172549	106	1
che172557	106	1
che172727	106	1
che172770	106	1
che182490	106	1
che182492	106	1
che182494	106	1
che182497	106	1
che182507	106	1
che182511	106	1
che182513	106	1
che182517	106	1
che182519	106	1
che182520	106	1
che182521	106	1
che182522	106	1
che182523	106	1
che182864	106	1
che182876	106	1
chz188071	106	1
chz188078	106	1
chz188085	106	1
chz188087	106	1
chz188096	106	1
chz188099	106	1
chz188101	106	1
chz188297	106	1
chz188487	106	1
chz188499	106	1
qiz188614	106	1
ch1150075	107	1
ch1150081	107	1
ch1150083	107	1
ch1150100	107	1
ch1150128	107	1
ch7100145	107	1
ch7130156	107	1
ch7130159	107	1
ch7130162	107	1
ch7130179	107	1
ch7140049	107	1
ch7140151	107	1
ch7140154	107	1
ch7140159	107	1
ch7140162	107	1
ch7140164	107	1
ch7140166	107	1
ch7140170	107	1
ch7140182	107	1
ch7140191	107	1
ch7140192	107	1
ch7140194	107	1
ch7140197	107	1
ch7140198	107	1
ch7150153	107	1
ch7150155	107	1
ch7150156	107	1
ch7150158	107	1
ch7150159	107	1
ch7150160	107	1
ch7150161	107	1
ch7150162	107	1
ch7150163	107	1
ch7150165	107	1
ch7150166	107	1
ch7150167	107	1
ch7150168	107	1
ch7150170	107	1
ch7150171	107	1
ch7150172	107	1
ch7150173	107	1
ch7150175	107	1
ch7150177	107	1
ch7150178	107	1
ch7150179	107	1
ch7150180	107	1
ch7150183	107	1
ch7150184	107	1
ch7150185	107	1
ch7150186	107	1
ch7150187	107	1
ch7150188	107	1
ch7150189	107	1
ch7150191	107	1
ch7150193	107	1
ch7150194	107	1
ch7150195	107	1
che182089	107	1
che182404	107	1
che182489	107	1
che182490	107	1
che182491	107	1
che182492	107	1
che182494	107	1
che182496	107	1
che182497	107	1
che182498	107	1
che182500	107	1
che182501	107	1
che182503	107	1
che182506	107	1
che182507	107	1
che182509	107	1
che182511	107	1
che182512	107	1
che182513	107	1
che182515	107	1
che182516	107	1
che182517	107	1
che182518	107	1
che182519	107	1
che182520	107	1
che182521	107	1
che182522	107	1
che182523	107	1
che182524	107	1
che182864	107	1
che182876	107	1
che182878	107	1
chy187529	107	1
chz188077	107	1
chz188078	107	1
chz188083	107	1
chz188085	107	1
chz188086	107	1
chz188090	107	1
chz188100	107	1
chz188237	107	1
chz188493	107	1
chz188663	107	1
ch7120152	108	1
ch7120168	108	1
ch7120169	108	1
ch7120189	108	1
che172150	108	1
che172164	108	1
chz178515	108	1
chz188071	108	1
chz188081	108	1
chz188297	108	1
chz188316	108	1
chz188386	108	1
chz188486	108	1
chz188487	108	1
chz188488	108	1
chz188490	108	1
chz188497	108	1
chz188499	108	1
chz188500	108	1
chz188502	108	1
ch1150078	109	1
ch1150100	109	1
ch1160166	109	1
ch7100145	109	1
ch7120168	109	1
ch7120189	109	1
ch7130156	109	1
ch7130159	109	1
ch7130162	109	1
ch7140153	109	1
ch7140154	109	1
ch7140166	109	1
ch7140180	109	1
ch7140184	109	1
ch7140834	109	1
ch7150151	109	1
ch7150153	109	1
ch7150154	109	1
ch7150155	109	1
ch7150156	109	1
ch7150157	109	1
ch7150158	109	1
ch7150159	109	1
ch7150160	109	1
ch7150161	109	1
ch7150162	109	1
ch7150163	109	1
ch7150164	109	1
ch7150165	109	1
ch7150166	109	1
ch7150167	109	1
ch7150168	109	1
ch7150169	109	1
ch7150170	109	1
ch7150171	109	1
ch7150172	109	1
ch7150173	109	1
ch7150174	109	1
ch7150175	109	1
ch7150176	109	1
ch7150177	109	1
ch7150178	109	1
ch7150179	109	1
ch7150180	109	1
ch7150183	109	1
ch7150184	109	1
ch7150185	109	1
ch7150187	109	1
ch7150188	109	1
ch7150189	109	1
ch7150191	109	1
ch7150193	109	1
ch7150194	109	1
ch7150195	109	1
che182089	109	1
che182404	109	1
che182489	109	1
che182490	109	1
che182491	109	1
che182492	109	1
che182494	109	1
che182496	109	1
che182497	109	1
che182498	109	1
che182500	109	1
che182501	109	1
che182503	109	1
che182506	109	1
che182507	109	1
che182509	109	1
che182511	109	1
che182512	109	1
che182513	109	1
che182515	109	1
che182516	109	1
che182517	109	1
che182518	109	1
che182519	109	1
che182520	109	1
che182521	109	1
che182522	109	1
che182523	109	1
che182524	109	1
che182864	109	1
che182876	109	1
che182878	109	1
chy187529	109	1
chy187552	109	1
chz188071	109	1
chz188075	109	1
chz188076	109	1
chz188080	109	1
chz188081	109	1
chz188082	109	1
chz188084	109	1
chz188086	109	1
chz188087	109	1
chz188091	109	1
chz188096	109	1
chz188097	109	1
chz188098	109	1
chz188099	109	1
chz188101	109	1
chz188232	109	1
chz188238	109	1
chz188297	109	1
chz188487	109	1
chz188490	109	1
chz188491	109	1
chz188494	109	1
chz188496	109	1
chz188500	109	1
chz188501	109	1
chz188547	109	1
chz188667	109	1
qiz188614	109	1
ch1130070	110	1
ch1150071	110	1
ch1150072	110	1
ch1150082	110	1
ch1150126	110	1
ch1150136	110	1
ch1150137	110	1
ch1150140	110	1
ch1160070	110	1
ch1160072	110	1
ch1160083	110	1
ch1160109	110	1
ch1160111	110	1
ch1160114	110	1
ch1160135	110	1
ch1160136	110	1
ch1160140	110	1
ch7130179	110	1
ch7140151	110	1
ch7140153	110	1
ch7140155	110	1
ch7140173	110	1
ch7140174	110	1
ch7140178	110	1
ch7140190	110	1
ch7150156	110	1
ch7150160	110	1
ch7150169	110	1
ch7150177	110	1
ch7150178	110	1
ch7150184	110	1
ch7150188	110	1
ch7150193	110	1
ch7160150	110	1
ch7160151	110	1
ch7160155	110	1
ch7160178	110	1
ch7160179	110	1
ch7160180	110	1
ch7160181	110	1
ch7160182	110	1
ch7160185	110	1
ch7160186	110	1
ch7160187	110	1
ch7160189	110	1
ch7160190	110	1
ch7160192	110	1
che182404	110	1
che182500	110	1
che182524	110	1
che182878	110	1
chy187552	110	1
chz188099	110	1
chz188232	110	1
chz188237	110	1
chz188486	110	1
chz188490	110	1
chz188491	110	1
chz188493	110	1
chz188494	110	1
chz188496	110	1
ch1150079	111	1
ch1150090	111	1
ch1150091	111	1
ch1150100	111	1
ch1150103	111	1
ch1150105	111	1
ch1150124	111	1
ch1150126	111	1
ch1150128	111	1
ch1150142	111	1
ch7140049	111	1
ch7140161	111	1
ch7140164	111	1
ch7140177	111	1
ch7140178	111	1
ch7140179	111	1
ch7140194	111	1
ch7150172	111	1
ch7150183	111	1
che182501	111	1
chz188488	111	1
chz188493	111	1
ch1150139	112	1
ch7150163	112	1
ch7160154	112	1
ch7160163	112	1
che182519	112	1
che182520	112	1
chy187529	112	1
chz188090	112	1
chz188097	112	1
chz188238	112	1
chz188499	112	1
chz188500	112	1
ch1120078	113	1
ch1120088	113	1
ch1150090	113	1
ch1150092	113	1
ch1150106	113	1
ch1150116	113	1
ch1150135	113	1
ch1150144	113	1
ch1160075	113	1
ch1160077	113	1
ch1160110	113	1
ch7100145	113	1
ch7120152	113	1
ch7120168	113	1
ch7140163	113	1
ch7140181	113	1
ch7150151	113	1
ch7150153	113	1
ch7150154	113	1
ch7150157	113	1
ch7150159	113	1
ch7150167	113	1
ch7150168	113	1
ch7150179	113	1
ch7150185	113	1
ch7160168	113	1
ch7160170	113	1
ch7160174	113	1
ch7160183	113	1
ch7160193	113	1
chz158431	113	1
chz178260	113	1
ch1150085	114	1
ch1150095	114	1
ch1150131	114	1
ch1150143	114	1
ch7140151	114	1
ch7140178	114	1
ch7140195	114	1
ch7150167	114	1
che182491	114	1
chz188488	114	1
mey177544	114	1
mez178314	114	1
ch1150128	115	1
ch1150132	115	1
ch7130179	115	1
ch7140190	115	1
ch7140197	115	1
ch7150156	115	1
ch7150161	115	1
ch7150162	115	1
ch7150171	115	1
ch7150173	115	1
ch7150188	115	1
ch7150191	115	1
bb1150029	116	1
bez188436	116	1
ch1120067	116	1
ch1150075	116	1
ch1150077	116	1
ch1150081	116	1
ch1150083	116	1
ch1150115	116	1
ch1150116	116	1
ch1150118	116	1
ch1150120	116	1
ch1150124	116	1
ch1150127	116	1
ch7150151	116	1
ch7150153	116	1
ch7150156	116	1
ch7150157	116	1
ch7150158	116	1
ch7150166	116	1
ch7150168	116	1
ch7150170	116	1
ch7150171	116	1
ch7150172	116	1
ch7150175	116	1
ch7150177	116	1
ch7150179	116	1
ch7150180	116	1
ch7150184	116	1
ch7150191	116	1
ch7150195	116	1
che172730	116	1
che182498	116	1
chz188520	116	1
chz188547	116	1
ch1130119	117	1
ch1150002	117	1
ch1150084	117	1
ch1150093	117	1
ch1150098	117	1
ch1150117	117	1
ch1150123	117	1
ch1150130	117	1
ch1150139	117	1
ch1150144	117	1
ch1150385	117	1
ch7120168	117	1
ch7130151	117	1
ch7140049	117	1
ch7140155	117	1
ch7140161	117	1
ch7140174	117	1
ch7140175	117	1
ch7140177	117	1
ch7140179	117	1
ch7140183	117	1
ch7140187	117	1
ch7150159	117	1
ch7150163	117	1
ch7150164	117	1
ch7150165	117	1
ch7150174	117	1
ch7150185	117	1
ch7150187	117	1
ch7150189	117	1
ch7150193	117	1
che182089	117	1
che182404	117	1
che182489	117	1
che182496	117	1
che182503	117	1
che182878	117	1
chy187552	117	1
chz158431	117	1
chz178506	117	1
chz188075	117	1
chz188080	117	1
chz188082	117	1
chz188084	117	1
chz188091	117	1
chz188097	117	1
chz188098	117	1
chz188100	117	1
chz188232	117	1
chz188237	117	1
chz188238	117	1
chz188489	117	1
chz188490	117	1
chz188493	117	1
chz188496	117	1
chz188667	117	1
ch1120067	118	1
ch1120078	118	1
ch1130070	118	1
ch1140126	118	1
ch1150071	118	1
ch1150072	118	1
ch1150074	118	1
ch1150076	118	1
ch1150077	118	1
ch1150090	118	1
ch1150091	118	1
ch1150095	118	1
ch1150097	118	1
ch1150100	118	1
ch1150118	118	1
ch1150122	118	1
ch1150123	118	1
ch1150124	118	1
ch1150125	118	1
ch1150127	118	1
ch1150130	118	1
ch1150131	118	1
ch1150139	118	1
ch1150140	118	1
ch1150144	118	1
ch1150145	118	1
ch1150190	118	1
ch1160070	118	1
ch1160082	118	1
ch7120189	118	1
ch7140153	118	1
ch7140163	118	1
ch7140175	118	1
ch7140189	118	1
ch7150157	118	1
ch7150163	118	1
ch7150165	118	1
ch7150166	118	1
ch7150167	118	1
ch7150168	118	1
ch7150170	118	1
ch7150172	118	1
ch7150176	118	1
ch7150177	118	1
ch7150179	118	1
ch7150183	118	1
ch7150184	118	1
ch7150186	118	1
ch7150189	118	1
ch7160151	118	1
che182489	118	1
che182491	118	1
che182511	118	1
che182876	118	1
chz188489	118	1
chz188520	118	1
ch1140121	119	1
ch1140126	119	1
ch1150002	119	1
ch1150074	119	1
ch1150075	119	1
ch1150084	119	1
ch1150085	119	1
ch1150086	119	1
ch1150091	119	1
ch1150095	119	1
ch1150100	119	1
ch1150103	119	1
ch1150105	119	1
ch1150107	119	1
ch1150115	119	1
ch1150117	119	1
ch1150120	119	1
ch1150125	119	1
ch1150127	119	1
ch1150128	119	1
ch1150129	119	1
ch1150132	119	1
ch1150142	119	1
ch1150190	119	1
ch1150945	119	1
ch1160100	119	1
ch1160106	119	1
ch1160166	119	1
ch7120189	119	1
ch7140164	119	1
ch7140179	119	1
ch7140191	119	1
ch7140195	119	1
ch7150158	119	1
ch7150166	119	1
ch7150173	119	1
ch7150175	119	1
ch7150176	119	1
ch7150180	119	1
ch7150189	119	1
ch7150191	119	1
ch7150195	119	1
ch7160162	119	1
ch7160164	119	1
ch7160171	119	1
che182089	119	1
che182518	119	1
chz188082	119	1
chz188489	119	1
chz188667	119	1
bb1140062	120	1
bb1150031	120	1
bb1150052	120	1
bb1150053	120	1
bb1150054	120	1
bb1160022	120	1
bb1160023	120	1
bb1160024	120	1
bb1160025	120	1
bb1160027	120	1
bb1160028	120	1
bb1160029	120	1
bb1160030	120	1
bb1160031	120	1
bb1160032	120	1
bb1160033	120	1
bb1160034	120	1
bb1160035	120	1
bb1160037	120	1
bb1160039	120	1
bb1160041	120	1
bb1160043	120	1
bb1160045	120	1
bb1160046	120	1
bb1160047	120	1
bb1160048	120	1
bb1160051	120	1
bb1160053	120	1
bb1160055	120	1
bb1160056	120	1
bb1160057	120	1
bb1160059	120	1
bb1160060	120	1
bb1160061	120	1
bb1160062	120	1
bb1160063	120	1
bb5150004	120	1
bb5150014	120	1
bb5160001	120	1
bb5160002	120	1
bb5160003	120	1
bb5160004	120	1
bb5160005	120	1
bb5160006	120	1
bb5160007	120	1
bb5160009	120	1
bb5160010	120	1
bb5160011	120	1
bb5160012	120	1
bb5160013	120	1
bb5160015	120	1
ch1140145	120	1
ch1150134	120	1
ch1160070	120	1
ch1160072	120	1
ch1160074	120	1
ch1160075	120	1
ch1160076	120	1
ch1160077	120	1
ch1160079	120	1
ch1160081	120	1
ch1160082	120	1
ch1160083	120	1
ch1160085	120	1
ch1160088	120	1
ch1160089	120	1
ch1160090	120	1
ch1160091	120	1
ch1160092	120	1
ch1160093	120	1
ch1160094	120	1
ch1160095	120	1
ch1160096	120	1
ch1160097	120	1
ch1160098	120	1
ch1160099	120	1
ch1160100	120	1
ch1160101	120	1
ch1160102	120	1
ch1160103	120	1
ch1160104	120	1
ch1160105	120	1
ch1160106	120	1
ch1160108	120	1
ch1160109	120	1
ch1160110	120	1
ch1160111	120	1
ch1160112	120	1
ch1160113	120	1
ch1160114	120	1
ch1160115	120	1
ch1160116	120	1
ch1160117	120	1
ch1160118	120	1
ch1160119	120	1
ch1160120	120	1
ch1160121	120	1
ch1160122	120	1
ch1160123	120	1
ch1160124	120	1
ch1160125	120	1
ch1160126	120	1
ch1160127	120	1
ch1160129	120	1
ch1160130	120	1
ch1160131	120	1
ch1160132	120	1
ch1160133	120	1
ch1160134	120	1
ch1160135	120	1
ch1160136	120	1
ch1160137	120	1
ch1160138	120	1
ch1160140	120	1
ch1160143	120	1
ch1160144	120	1
ch1160166	120	1
ch1160346	120	1
ch1160675	120	1
ch7130159	120	1
ch7160150	120	1
ch7160151	120	1
ch7160152	120	1
ch7160153	120	1
ch7160154	120	1
ch7160155	120	1
ch7160156	120	1
ch7160157	120	1
ch7160158	120	1
ch7160159	120	1
ch7160162	120	1
ch7160163	120	1
ch7160164	120	1
ch7160165	120	1
ch7160167	120	1
ch7160168	120	1
ch7160169	120	1
ch7160170	120	1
ch7160171	120	1
ch7160172	120	1
ch7160173	120	1
ch7160174	120	1
ch7160175	120	1
ch7160176	120	1
ch7160177	120	1
ch7160178	120	1
ch7160179	120	1
ch7160180	120	1
ch7160181	120	1
ch7160182	120	1
ch7160183	120	1
ch7160184	120	1
ch7160185	120	1
ch7160186	120	1
ch7160187	120	1
ch7160188	120	1
ch7160189	120	1
ch7160190	120	1
ch7160192	120	1
ch7160193	120	1
ch7160194	120	1
che172730	121	1
che182089	121	1
che182489	121	1
che182490	121	1
che182491	121	1
che182492	121	1
che182494	121	1
che182497	121	1
che182498	121	1
che182500	121	1
che182501	121	1
che182503	121	1
che182506	121	1
che182507	121	1
che182509	121	1
che182511	121	1
che182512	121	1
che182513	121	1
che182515	121	1
che182516	121	1
che182517	121	1
che182518	121	1
che182519	121	1
che182520	121	1
che182521	121	1
che182522	121	1
che182523	121	1
che182524	121	1
che182864	121	1
che182876	121	1
che182878	121	1
chy187529	121	1
chz188071	121	1
chz188075	121	1
chz188076	121	1
chz188077	121	1
chz188078	121	1
chz188080	121	1
chz188081	121	1
chz188082	121	1
chz188084	121	1
chz188085	121	1
chz188086	121	1
chz188087	121	1
chz188090	121	1
chz188091	121	1
chz188096	121	1
chz188097	121	1
chz188099	121	1
chz188100	121	1
chz188101	121	1
chz188297	121	1
chz188316	121	1
chz188386	121	1
chz188486	121	1
chz188487	121	1
chz188488	121	1
chz188490	121	1
chz188493	121	1
chz188494	121	1
chz188496	121	1
chz188497	121	1
chz188501	121	1
chz188502	121	1
chz188663	121	1
chz188667	121	1
ch1130070	122	1
ch1140145	122	1
ch1150075	122	1
ch1150078	122	1
ch1150095	122	1
ch1150096	122	1
ch1150116	122	1
ch1150127	122	1
ch1150128	122	1
ch1160072	122	1
ch1160082	122	1
ch1160083	122	1
ch1160088	122	1
ch1160104	122	1
ch1160106	122	1
ch1160108	122	1
ch1160110	122	1
ch1160116	122	1
ch1160141	122	1
ch1160144	122	1
ch1160166	122	1
ch1160346	122	1
ch7140166	122	1
ch7150151	122	1
ch7150156	122	1
ch7150161	122	1
ch7150165	122	1
ch7150176	122	1
ch7150178	122	1
ch7150179	122	1
ch7150186	122	1
ch7150188	122	1
ch7150193	122	1
ch7160154	122	1
ch7160155	122	1
ch7160163	122	1
ch7160170	122	1
ch7160174	122	1
ch7160180	122	1
ch7160184	122	1
cs1150460	122	1
tt1150865	122	1
tt1150911	122	1
bb1160043	123	1
ch1150075	123	1
ch1150091	123	1
ch1150100	123	1
ch1150116	123	1
ch1150124	123	1
ch1150127	123	1
ch1150132	123	1
ch1150139	123	1
ch1150140	123	1
ch1150145	123	1
ch1160091	123	1
ch1160118	123	1
ch1160119	123	1
ch1160121	123	1
ch1160122	123	1
ch1160132	123	1
ch1160133	123	1
ch1160135	123	1
ch1160137	123	1
ch1160138	123	1
ch7140190	123	1
ch7150163	123	1
ch7150169	123	1
ch7160171	123	1
cs1150246	123	1
cs1150255	123	1
me1160720	123	1
me2160745	123	1
mt6160078	123	1
mt6160660	123	1
tt1150904	123	1
tt1150911	123	1
ch1150133	124	1
ch1160099	124	1
ch1160131	124	1
ch7150176	124	1
chy187552	124	1
jpt172617	124	1
me1160697	124	1
mez177523	124	1
cys177001	125	1
cys177002	125	1
cys177003	125	1
cys177004	125	1
cys177005	125	1
cys177006	125	1
cys177007	125	1
cys177008	125	1
cys177009	125	1
cys177010	125	1
cys177012	125	1
cys177013	125	1
cys177014	125	1
cys177016	125	1
cys177018	125	1
cys177019	125	1
cys177020	125	1
cys177021	125	1
cys177022	125	1
cys177023	125	1
cys177024	125	1
cys177025	125	1
cys177026	125	1
cys177027	125	1
cys177028	125	1
cys177030	125	1
cys177031	125	1
cys177032	125	1
cys177033	125	1
cys177034	125	1
cys177035	125	1
cys177036	125	1
cys177037	125	1
cys177038	125	1
cys177039	125	1
cys177040	125	1
cys177041	125	1
cys177042	125	1
cys177043	125	1
cys177044	125	1
cys177045	125	1
cys177046	125	1
cys177047	125	1
cys177049	125	1
cys177050	125	1
cys177051	125	1
cys177052	125	1
cys177053	125	1
cys177054	125	1
cym172136	126	1
cym172139	126	1
cym172141	126	1
cym172142	126	1
cym172143	126	1
cym172144	126	1
cym172145	126	1
cym172146	126	1
cym172147	126	1
cym172148	126	1
cym172149	126	1
bb1150042	127	1
bb1170036	127	1
bb1180003	127	1
bb1180007	127	1
bb1180009	127	1
bb1180010	127	1
bb1180011	127	1
bb1180013	127	1
bb1180014	127	1
bb1180015	127	1
bb1180018	127	1
bb1180022	127	1
bb1180026	127	1
bb1180027	127	1
bb1180028	127	1
bb1180033	127	1
bb1180040	127	1
bb1180043	127	1
bb5180055	127	1
bb5180059	127	1
bb5180061	127	1
bb5180065	127	1
ce1180071	127	1
ce1180072	127	1
ce1180073	127	1
ce1180075	127	1
ce1180077	127	1
ce1180080	127	1
ce1180081	127	1
ce1180082	127	1
ce1180087	127	1
ce1180088	127	1
ce1180089	127	1
ce1180091	127	1
ce1180092	127	1
ce1180093	127	1
ce1180096	127	1
ce1180097	127	1
ce1180098	127	1
ce1180099	127	1
ce1180100	127	1
ce1180102	127	1
ce1180103	127	1
ce1180105	127	1
ce1180107	127	1
ce1180109	127	1
ce1180111	127	1
ce1180113	127	1
ce1180114	127	1
ce1180115	127	1
ce1180116	127	1
ce1180119	127	1
ce1180121	127	1
ce1180122	127	1
ce1180123	127	1
ce1180125	127	1
ce1180126	127	1
ce1180127	127	1
ce1180128	127	1
ce1180129	127	1
ce1180130	127	1
ce1180131	127	1
ce1180134	127	1
ce1180135	127	1
ce1180137	127	1
ce1180138	127	1
ce1180139	127	1
ce1180140	127	1
ce1180142	127	1
ce1180143	127	1
ce1180144	127	1
ce1180145	127	1
ce1180147	127	1
ce1180152	127	1
ce1180153	127	1
ce1180155	127	1
ce1180156	127	1
ce1180159	127	1
ce1180160	127	1
ce1180161	127	1
ce1180162	127	1
ce1180166	127	1
ce1180170	127	1
ce1180171	127	1
ce1180172	127	1
ce1180173	127	1
ce1180174	127	1
ce1180175	127	1
ce1180176	127	1
ch1170230	127	1
ch1180186	127	1
ch1180188	127	1
ch1180190	127	1
ch1180192	127	1
ch1180196	127	1
ch1180198	127	1
ch1180204	127	1
ch1180206	127	1
ch1180207	127	1
ch1180209	127	1
ch1180217	127	1
ch1180219	127	1
ch1180222	127	1
ch1180223	127	1
ch1180224	127	1
ch1180226	127	1
ch1180228	127	1
ch1180231	127	1
ch1180232	127	1
ch1180233	127	1
ch1180235	127	1
ch1180236	127	1
ch1180237	127	1
ch1180238	127	1
ch1180241	127	1
ch1180243	127	1
ch1180244	127	1
ch1180245	127	1
ch1180246	127	1
ch1180256	127	1
ch1180258	127	1
ch7150158	127	1
ch7150178	127	1
ch7170315	127	1
ch7180273	127	1
ch7180274	127	1
ch7180275	127	1
ch7180276	127	1
ch7180283	127	1
ch7180284	127	1
ch7180289	127	1
ch7180291	127	1
ch7180294	127	1
ch7180298	127	1
ch7180300	127	1
ch7180303	127	1
ch7180307	127	1
ch7180308	127	1
ch7180309	127	1
ch7180310	127	1
ch7180312	127	1
ch7180313	127	1
ch7180314	127	1
ch7180316	127	1
cs1180321	127	1
cs1180324	127	1
cs1180325	127	1
cs1180326	127	1
cs1180328	127	1
cs1180329	127	1
cs1180331	127	1
cs1180333	127	1
cs1180336	127	1
cs1180337	127	1
cs1180338	127	1
cs1180339	127	1
cs1180341	127	1
cs1180342	127	1
cs1180343	127	1
cs1180347	127	1
cs1180349	127	1
cs1180352	127	1
cs1180353	127	1
cs1180354	127	1
cs1180356	127	1
cs1180357	127	1
cs1180358	127	1
cs1180359	127	1
cs1180361	127	1
cs1180363	127	1
cs1180364	127	1
cs1180365	127	1
cs1180367	127	1
cs1180368	127	1
cs1180369	127	1
cs1180371	127	1
cs1180375	127	1
cs1180376	127	1
cs1180378	127	1
cs1180379	127	1
cs1180382	127	1
cs1180383	127	1
cs1180384	127	1
cs1180387	127	1
cs1180388	127	1
cs1180391	127	1
cs1180396	127	1
cs5180406	127	1
cs5180407	127	1
cs5180410	127	1
cs5180411	127	1
cs5180414	127	1
cs5180415	127	1
cs5180416	127	1
cs5180417	127	1
cs5180418	127	1
cs5180421	127	1
cs5180423	127	1
cs5180424	127	1
ee1180431	127	1
ee1180432	127	1
ee1180435	127	1
ee1180438	127	1
ee1180440	127	1
ee1180442	127	1
ee1180445	127	1
ee1180448	127	1
ee1180449	127	1
ee1180450	127	1
ee1180451	127	1
ee1180453	127	1
ee1180455	127	1
ee1180457	127	1
ee1180461	127	1
ee1180462	127	1
ee1180463	127	1
ee1180464	127	1
ee1180465	127	1
ee1180466	127	1
ee1180471	127	1
ee1180472	127	1
ee1180474	127	1
ee1180475	127	1
ee1180477	127	1
ee1180478	127	1
ee1180479	127	1
ee1180480	127	1
ee1180481	127	1
ee1180484	127	1
ee1180487	127	1
ee1180488	127	1
ee1180490	127	1
ee1180493	127	1
ee1180494	127	1
ee1180495	127	1
ee1180498	127	1
ee1180499	127	1
ee1180500	127	1
ee1180501	127	1
ee1180502	127	1
ee1180503	127	1
ee1180507	127	1
ee1180508	127	1
ee1180510	127	1
ee1180512	127	1
ee1180513	127	1
ee1180514	127	1
ee1180515	127	1
ee3180522	127	1
ee3180526	127	1
ee3180529	127	1
ee3180532	127	1
ee3180534	127	1
ee3180536	127	1
ee3180537	127	1
ee3180538	127	1
ee3180539	127	1
ee3180540	127	1
ee3180543	127	1
ee3180544	127	1
ee3180548	127	1
ee3180550	127	1
ee3180551	127	1
ee3180552	127	1
ee3180555	127	1
ee3180558	127	1
ee3180559	127	1
ee3180561	127	1
ee3180564	127	1
ee3180566	127	1
ee3180567	127	1
ee3180568	127	1
me1150228	127	1
me1150690	127	1
me1180583	127	1
me1180585	127	1
me1180586	127	1
me1180587	127	1
me1180591	127	1
me1180593	127	1
me1180594	127	1
me1180595	127	1
me1180596	127	1
me1180598	127	1
me1180601	127	1
me1180602	127	1
me1180605	127	1
me1180607	127	1
me1180609	127	1
me1180610	127	1
me1180613	127	1
me1180617	127	1
me1180618	127	1
me1180619	127	1
me1180620	127	1
me1180621	127	1
me1180623	127	1
me1180625	127	1
me1180629	127	1
me1180632	127	1
me1180635	127	1
me1180636	127	1
me1180637	127	1
me1180638	127	1
me1180639	127	1
me1180640	127	1
me1180642	127	1
me1180643	127	1
me1180646	127	1
me1180647	127	1
me1180648	127	1
me1180649	127	1
me1180652	127	1
me1180653	127	1
me1180655	127	1
me1180657	127	1
me2150723	127	1
me2170659	127	1
me2180665	127	1
me2180667	127	1
me2180669	127	1
me2180671	127	1
me2180673	127	1
me2180677	127	1
me2180680	127	1
me2180684	127	1
me2180685	127	1
me2180686	127	1
me2180689	127	1
me2180693	127	1
me2180697	127	1
me2180702	127	1
me2180704	127	1
me2180705	127	1
me2180708	127	1
me2180710	127	1
me2180711	127	1
me2180714	127	1
me2180720	127	1
me2180721	127	1
me2180724	127	1
me2180727	127	1
me2180729	127	1
me2180731	127	1
me2180734	127	1
me2180735	127	1
mt1180736	127	1
mt1180737	127	1
mt1180740	127	1
mt1180741	127	1
mt1180743	127	1
mt1180745	127	1
mt1180747	127	1
mt1180749	127	1
mt1180750	127	1
mt1180751	127	1
mt1180752	127	1
mt1180753	127	1
mt1180754	127	1
mt1180756	127	1
mt1180759	127	1
mt1180761	127	1
mt1180763	127	1
mt1180764	127	1
mt1180765	127	1
mt1180766	127	1
mt1180767	127	1
mt1180768	127	1
mt1180769	127	1
mt1180771	127	1
mt1180772	127	1
mt1180773	127	1
mt1180774	127	1
mt6180776	127	1
mt6180778	127	1
mt6180779	127	1
mt6180780	127	1
mt6180781	127	1
mt6180782	127	1
mt6180784	127	1
mt6180786	127	1
mt6180787	127	1
mt6180788	127	1
mt6180789	127	1
mt6180791	127	1
mt6180792	127	1
mt6180796	127	1
mt6180798	127	1
ph1180804	127	1
ph1180805	127	1
ph1180806	127	1
ph1180808	127	1
ph1180809	127	1
ph1180811	127	1
ph1180815	127	1
ph1180816	127	1
ph1180818	127	1
ph1180819	127	1
ph1180823	127	1
ph1180824	127	1
ph1180829	127	1
ph1180834	127	1
ph1180835	127	1
ph1180837	127	1
ph1180840	127	1
ph1180841	127	1
ph1180842	127	1
ph1180847	127	1
ph1180849	127	1
ph1180853	127	1
ph1180855	127	1
ph1180856	127	1
ph1180857	127	1
tt1180867	127	1
tt1180868	127	1
tt1180869	127	1
tt1180871	127	1
tt1180873	127	1
tt1180878	127	1
tt1180880	127	1
tt1180883	127	1
tt1180884	127	1
tt1180885	127	1
tt1180886	127	1
tt1180895	127	1
tt1180898	127	1
tt1180899	127	1
tt1180904	127	1
tt1180907	127	1
tt1180908	127	1
tt1180909	127	1
tt1180913	127	1
tt1180914	127	1
tt1180916	127	1
tt1180917	127	1
tt1180918	127	1
tt1180919	127	1
tt1180924	127	1
tt1180926	127	1
tt1180929	127	1
tt1180931	127	1
tt1180935	127	1
tt1180937	127	1
tt1180938	127	1
tt1180941	127	1
tt1180942	127	1
tt1180943	127	1
tt1180944	127	1
tt1180945	127	1
tt1180948	127	1
tt1180949	127	1
tt1180953	127	1
tt1180957	127	1
tt1180958	127	1
tt1180959	127	1
tt1180961	127	1
tt1180966	127	1
tt1180970	127	1
tt1180971	127	1
tt1180972	127	1
tt1180974	127	1
cys187002	128	1
cys187003	128	1
cys187004	128	1
cys187005	128	1
cys187006	128	1
cys187007	128	1
cys187008	128	1
cys187009	128	1
cys187010	128	1
cys187011	128	1
cys187012	128	1
cys187013	128	1
cys187014	128	1
cys187015	128	1
cys187017	128	1
cys187018	128	1
cys187019	128	1
cys187020	128	1
cys187021	128	1
cys187022	128	1
cys187023	128	1
cys187024	128	1
cys187025	128	1
cys187026	128	1
cys187027	128	1
cys187028	128	1
cys187029	128	1
cys187030	128	1
cys187031	128	1
cys187032	128	1
cys187033	128	1
cys187034	128	1
cys187035	128	1
cys187036	128	1
cys187037	128	1
cys187038	128	1
cys187039	128	1
cys187040	128	1
cys187041	128	1
cys187042	128	1
cys187043	128	1
cys187044	128	1
cys187045	128	1
cys187046	128	1
cys187047	128	1
cys187048	128	1
cys187049	128	1
cys187050	128	1
cys187051	128	1
cys187052	128	1
cys187053	128	1
cys187054	128	1
cys187055	128	1
cys187056	128	1
phs177160	128	1
cys187002	129	1
cys187003	129	1
cys187004	129	1
cys187005	129	1
cys187006	129	1
cys187007	129	1
cys187008	129	1
cys187009	129	1
cys187010	129	1
cys187011	129	1
cys187012	129	1
cys187013	129	1
cys187014	129	1
cys187015	129	1
cys187017	129	1
cys187018	129	1
cys187019	129	1
cys187020	129	1
cys187021	129	1
cys187022	129	1
cys187023	129	1
cys187024	129	1
cys187025	129	1
cys187026	129	1
cys187027	129	1
cys187028	129	1
cys187029	129	1
cys187030	129	1
cys187031	129	1
cys187032	129	1
cys187033	129	1
cys187034	129	1
cys187035	129	1
cys187036	129	1
cys187037	129	1
cys187038	129	1
cys187039	129	1
cys187040	129	1
cys187041	129	1
cys187042	129	1
cys187043	129	1
cys187044	129	1
cys187045	129	1
cys187046	129	1
cys187047	129	1
cys187048	129	1
cys187049	129	1
cys187050	129	1
cys187051	129	1
cys187052	129	1
cys187053	129	1
cys187054	129	1
cys187055	129	1
cys187056	129	1
cys177017	130	1
cys187002	130	1
cys187003	130	1
cys187004	130	1
cys187005	130	1
cys187006	130	1
cys187007	130	1
cys187008	130	1
cys187009	130	1
cys187010	130	1
cys187011	130	1
cys187012	130	1
cys187013	130	1
cys187014	130	1
cys187015	130	1
cys187017	130	1
cys187018	130	1
cys187019	130	1
cys187020	130	1
cys187021	130	1
cys187022	130	1
cys187023	130	1
cys187024	130	1
cys187025	130	1
cys187026	130	1
cys187027	130	1
cys187028	130	1
cys187029	130	1
cys187030	130	1
cys187031	130	1
cys187032	130	1
cys187033	130	1
cys187034	130	1
cys187035	130	1
cys187036	130	1
cys187037	130	1
cys187038	130	1
cys187039	130	1
cys187040	130	1
cys187041	130	1
cys187042	130	1
cys187043	130	1
cys187044	130	1
cys187045	130	1
cys187046	130	1
cys187047	130	1
cys187048	130	1
cys187049	130	1
cys187050	130	1
cys187051	130	1
cys187052	130	1
cys187053	130	1
cys187054	130	1
cys187055	130	1
cys187056	130	1
cys187002	131	1
cys187003	131	1
cys187004	131	1
cys187005	131	1
cys187006	131	1
cys187007	131	1
cys187008	131	1
cys187009	131	1
cys187010	131	1
cys187011	131	1
cys187012	131	1
cys187013	131	1
cys187014	131	1
cys187015	131	1
cys187017	131	1
cys187018	131	1
cys187019	131	1
cys187020	131	1
cys187021	131	1
cys187022	131	1
cys187023	131	1
cys187024	131	1
cys187025	131	1
cys187026	131	1
cys187027	131	1
cys187028	131	1
cys187029	131	1
cys187030	131	1
cys187031	131	1
cys187032	131	1
cys187033	131	1
cys187034	131	1
cys187035	131	1
cys187036	131	1
cys187037	131	1
cys187038	131	1
cys187039	131	1
cys187040	131	1
cys187041	131	1
cys187042	131	1
cys187043	131	1
cys187044	131	1
cys187045	131	1
cys187046	131	1
cys187047	131	1
cys187048	131	1
cys187049	131	1
cys187050	131	1
cys187051	131	1
cys187052	131	1
cys187053	131	1
cys187054	131	1
cys187055	131	1
cys187056	131	1
cys187002	132	1
cys187003	132	1
cys187004	132	1
cys187005	132	1
cys187006	132	1
cys187007	132	1
cys187008	132	1
cys187009	132	1
cys187010	132	1
cys187011	132	1
cys187012	132	1
cys187013	132	1
cys187014	132	1
cys187015	132	1
cys187017	132	1
cys187018	132	1
cys187019	132	1
cys187020	132	1
cys187021	132	1
cys187022	132	1
cys187023	132	1
cys187024	132	1
cys187025	132	1
cys187026	132	1
cys187027	132	1
cys187028	132	1
cys187029	132	1
cys187030	132	1
cys187031	132	1
cys187032	132	1
cys187033	132	1
cys187034	132	1
cys187035	132	1
cys187036	132	1
cys187037	132	1
cys187038	132	1
cys187039	132	1
cys187040	132	1
cys187041	132	1
cys187042	132	1
cys187043	132	1
cys187044	132	1
cys187045	132	1
cys187046	132	1
cys187047	132	1
cys187048	132	1
cys187049	132	1
cys187050	132	1
cys187051	132	1
cys187052	132	1
cys187053	132	1
cys187054	132	1
cys187055	132	1
cys187056	132	1
cys187002	133	1
cys187003	133	1
cys187004	133	1
cys187005	133	1
cys187006	133	1
cys187007	133	1
cys187008	133	1
cys187009	133	1
cys187010	133	1
cys187011	133	1
cys187012	133	1
cys187013	133	1
cys187014	133	1
cys187015	133	1
cys187017	133	1
cys187018	133	1
cys187019	133	1
cys187020	133	1
cys187021	133	1
cys187022	133	1
cys187023	133	1
cys187024	133	1
cys187025	133	1
cys187026	133	1
cys187027	133	1
cys187028	133	1
cys187029	133	1
cys187030	133	1
cys187031	133	1
cys187032	133	1
cys187033	133	1
cys187034	133	1
cys187035	133	1
cys187036	133	1
cys187037	133	1
cys187038	133	1
cys187039	133	1
cys187040	133	1
cys187041	133	1
cys187042	133	1
cys187043	133	1
cys187044	133	1
cys187045	133	1
cys187046	133	1
cys187047	133	1
cys187048	133	1
cys187049	133	1
cys187050	133	1
cys187051	133	1
cys187052	133	1
cys187053	133	1
cys187054	133	1
cys187055	133	1
cys187056	133	1
cys177009	134	1
cys177019	134	1
cys177020	134	1
cys177023	134	1
cys177034	134	1
cys177036	134	1
cys177045	134	1
cys177047	134	1
cys177009	135	1
cys177014	135	1
cys177019	135	1
cys177027	135	1
cys177034	135	1
cys177036	135	1
cys177052	135	1
cys177001	136	1
cys177004	136	1
cys177005	136	1
cys177006	136	1
cys177007	136	1
cys177008	136	1
cys177010	136	1
cys177016	136	1
cys177017	136	1
cys177018	136	1
cys177020	136	1
cys177021	136	1
cys177022	136	1
cys177023	136	1
cys177025	136	1
cys177026	136	1
cys177028	136	1
cys177030	136	1
cys177031	136	1
cys177032	136	1
cys177035	136	1
cys177038	136	1
cys177039	136	1
cys177042	136	1
cys177044	136	1
cys177046	136	1
cys177049	136	1
cys177050	136	1
cys177051	136	1
cys177053	136	1
cym182026	137	1
cym182028	137	1
cym182029	137	1
cym182030	137	1
cym182031	137	1
cym182032	137	1
cym182034	137	1
cym182035	137	1
cys177002	137	1
cys177003	137	1
cys177005	137	1
cys177006	137	1
cys177013	137	1
cys177014	137	1
cys177018	137	1
cys177021	137	1
cys177024	137	1
cys177030	137	1
cys177033	137	1
cys177040	137	1
cys177052	137	1
cyz188199	137	1
cyz188204	137	1
cyz188215	137	1
cyz188221	137	1
cyz188475	137	1
cyz188477	137	1
cyz188480	137	1
cyz188484	137	1
rdz188650	137	1
cez188044	138	1
chz188081	138	1
chz188297	138	1
cym182026	138	1
cym182028	138	1
cym182029	138	1
cym182030	138	1
cym182031	138	1
cym182032	138	1
cym182034	138	1
cym182035	138	1
cys177022	138	1
cys177031	138	1
cys177044	138	1
cys177049	138	1
cys177051	138	1
cys177053	138	1
cys177054	138	1
cyz188196	138	1
cyz188211	138	1
cyz188214	138	1
cyz188220	138	1
cyz188221	138	1
cyz188376	138	1
cyz188473	138	1
cyz188474	138	1
cyz188480	138	1
cyz188483	138	1
cym182026	139	1
cym182028	139	1
cym182029	139	1
cym182030	139	1
cym182031	139	1
cym182032	139	1
cym182034	139	1
cym182035	139	1
cys177012	139	1
cys177041	139	1
cys177043	139	1
cyz178494	139	1
cyz188193	139	1
cyz188201	139	1
cyz188204	139	1
cyz188207	139	1
cyz188216	139	1
cyz188217	139	1
cyz188219	139	1
cyz188378	139	1
cyz188473	139	1
cyz188475	139	1
cyz188476	139	1
cyz188477	139	1
cyz188478	139	1
cyz188479	139	1
cyz188481	139	1
cyz188482	139	1
cyz188483	139	1
cyz188484	139	1
cyz188658	139	1
cym172148	140	1
cym182028	140	1
cym182030	140	1
cys177002	140	1
cys177003	140	1
cys177013	140	1
cys177025	140	1
cys177033	140	1
cys177037	140	1
cys177040	140	1
cyz188193	140	1
cyz188199	140	1
cyz188207	140	1
cyz188219	140	1
cyz188475	140	1
cyz188478	140	1
bez188436	141	1
bly187545	141	1
blz188464	141	1
blz188469	141	1
blz188470	141	1
chz188074	141	1
cym172136	141	1
cym172144	141	1
cym172149	141	1
cym182035	141	1
cys177005	141	1
cys177008	141	1
cys177027	141	1
cys177030	141	1
cys177037	141	1
cys177038	141	1
cys177042	141	1
cys177045	141	1
cys177047	141	1
cys177052	141	1
cyz188203	141	1
cyz188211	141	1
cyz188216	141	1
cyz188218	141	1
cyz188279	141	1
cyz188472	141	1
cyz188476	141	1
cyz188481	141	1
cym182028	142	1
cym182030	142	1
cym182031	142	1
cym182032	142	1
cym182034	142	1
cys177004	142	1
cys177005	142	1
cys177007	142	1
cys177012	142	1
cys177017	142	1
cys177024	142	1
cys177026	142	1
cys177028	142	1
cys177030	142	1
cys177032	142	1
cys177039	142	1
cys177041	142	1
cys177043	142	1
cys177044	142	1
cys177049	142	1
cys177050	142	1
cys177054	142	1
cyz178494	142	1
cyz188201	142	1
cyz188378	142	1
cyz188476	142	1
cyz188477	142	1
cyz188479	142	1
cyz188480	142	1
cyz188481	142	1
cyz188482	142	1
cyz188484	142	1
cyz188658	142	1
bey187509	143	1
bey187512	143	1
bez188440	143	1
cez188044	143	1
cez188393	143	1
cez188405	143	1
chz188316	143	1
cys177010	143	1
cys177016	143	1
cys177035	143	1
cys177046	143	1
cyz188194	143	1
cyz188200	143	1
cyz188202	143	1
cyz188215	143	1
cyz188217	143	1
cyz188483	143	1
itz178002	143	1
itz178004	143	1
srz188305	143	1
srz188382	143	1
bb1170036	144	1
bb1180003	144	1
bb1180007	144	1
bb1180009	144	1
bb1180010	144	1
bb1180011	144	1
bb1180013	144	1
bb1180014	144	1
bb1180015	144	1
bb1180018	144	1
bb1180022	144	1
bb1180026	144	1
bb1180027	144	1
bb1180028	144	1
bb1180033	144	1
bb1180040	144	1
bb1180043	144	1
bb5180055	144	1
bb5180059	144	1
bb5180061	144	1
bb5180065	144	1
ce1150398	144	1
ce1180071	144	1
ce1180072	144	1
ce1180073	144	1
ce1180075	144	1
ce1180077	144	1
ce1180080	144	1
ce1180081	144	1
ce1180082	144	1
ce1180087	144	1
ce1180088	144	1
ce1180089	144	1
ce1180091	144	1
ce1180092	144	1
ce1180093	144	1
ce1180096	144	1
ce1180097	144	1
ce1180098	144	1
ce1180099	144	1
ce1180100	144	1
ce1180102	144	1
ce1180103	144	1
ce1180105	144	1
ce1180107	144	1
ce1180109	144	1
ce1180111	144	1
ce1180113	144	1
ce1180114	144	1
ce1180115	144	1
ce1180116	144	1
ce1180119	144	1
ce1180121	144	1
ce1180122	144	1
ce1180123	144	1
ce1180125	144	1
ce1180126	144	1
ce1180127	144	1
ce1180128	144	1
ce1180129	144	1
ce1180130	144	1
ce1180131	144	1
ce1180134	144	1
ce1180135	144	1
ce1180137	144	1
ce1180138	144	1
ce1180139	144	1
ce1180140	144	1
ce1180142	144	1
ce1180143	144	1
ce1180144	144	1
ce1180145	144	1
ce1180147	144	1
ce1180152	144	1
ce1180153	144	1
ce1180155	144	1
ce1180156	144	1
ce1180159	144	1
ce1180160	144	1
ce1180161	144	1
ce1180162	144	1
ce1180166	144	1
ce1180170	144	1
ce1180171	144	1
ce1180172	144	1
ce1180173	144	1
ce1180174	144	1
ce1180175	144	1
ce1180176	144	1
ch1170230	144	1
ch1180186	144	1
ch1180188	144	1
ch1180190	144	1
ch1180192	144	1
ch1180196	144	1
ch1180198	144	1
ch1180204	144	1
ch1180206	144	1
ch1180207	144	1
ch1180209	144	1
ch1180217	144	1
ch1180219	144	1
ch1180222	144	1
ch1180223	144	1
ch1180224	144	1
ch1180226	144	1
ch1180228	144	1
ch1180231	144	1
ch1180232	144	1
ch1180233	144	1
ch1180235	144	1
ch1180236	144	1
ch1180237	144	1
ch1180238	144	1
ch1180241	144	1
ch1180243	144	1
ch1180244	144	1
ch1180245	144	1
ch1180246	144	1
ch1180256	144	1
ch1180258	144	1
ch7170315	144	1
ch7180273	144	1
ch7180274	144	1
ch7180275	144	1
ch7180276	144	1
ch7180283	144	1
ch7180284	144	1
ch7180289	144	1
ch7180291	144	1
ch7180294	144	1
ch7180298	144	1
ch7180300	144	1
ch7180303	144	1
ch7180307	144	1
ch7180308	144	1
ch7180309	144	1
ch7180310	144	1
ch7180312	144	1
ch7180313	144	1
ch7180314	144	1
ch7180316	144	1
cs1180321	144	1
cs1180324	144	1
cs1180325	144	1
cs1180326	144	1
cs1180328	144	1
cs1180329	144	1
cs1180331	144	1
cs1180333	144	1
cs1180336	144	1
cs1180337	144	1
cs1180338	144	1
cs1180339	144	1
cs1180341	144	1
cs1180342	144	1
cs1180343	144	1
cs1180347	144	1
cs1180349	144	1
cs1180352	144	1
cs1180353	144	1
cs1180354	144	1
cs1180356	144	1
cs1180357	144	1
cs1180358	144	1
cs1180359	144	1
cs1180361	144	1
cs1180363	144	1
cs1180364	144	1
cs1180365	144	1
cs1180367	144	1
cs1180368	144	1
cs1180369	144	1
cs1180371	144	1
cs1180375	144	1
cs1180376	144	1
cs1180378	144	1
cs1180379	144	1
cs1180382	144	1
cs1180383	144	1
cs1180384	144	1
cs1180387	144	1
cs1180388	144	1
cs1180391	144	1
cs1180396	144	1
cs5180406	144	1
cs5180407	144	1
cs5180410	144	1
cs5180411	144	1
cs5180414	144	1
cs5180415	144	1
cs5180416	144	1
cs5180417	144	1
cs5180418	144	1
cs5180421	144	1
cs5180423	144	1
cs5180424	144	1
ee1130515	144	1
ee1180431	144	1
ee1180432	144	1
ee1180435	144	1
ee1180438	144	1
ee1180440	144	1
ee1180442	144	1
ee1180445	144	1
ee1180448	144	1
ee1180449	144	1
ee1180450	144	1
ee1180451	144	1
ee1180453	144	1
ee1180455	144	1
ee1180457	144	1
ee1180461	144	1
ee1180462	144	1
ee1180463	144	1
ee1180464	144	1
ee1180465	144	1
ee1180466	144	1
ee1180471	144	1
ee1180472	144	1
ee1180474	144	1
ee1180475	144	1
ee1180477	144	1
ee1180478	144	1
ee1180479	144	1
ee1180480	144	1
ee1180481	144	1
ee1180484	144	1
ee1180487	144	1
ee1180488	144	1
ee1180490	144	1
ee1180493	144	1
ee1180494	144	1
ee1180495	144	1
ee1180498	144	1
ee1180499	144	1
ee1180500	144	1
ee1180501	144	1
ee1180502	144	1
ee1180503	144	1
ee1180507	144	1
ee1180508	144	1
ee1180510	144	1
ee1180512	144	1
ee1180513	144	1
ee1180514	144	1
ee1180515	144	1
ee3180522	144	1
ee3180526	144	1
ee3180529	144	1
ee3180532	144	1
ee3180534	144	1
ee3180536	144	1
ee3180537	144	1
ee3180538	144	1
ee3180539	144	1
ee3180540	144	1
ee3180543	144	1
ee3180544	144	1
ee3180548	144	1
ee3180550	144	1
ee3180551	144	1
ee3180552	144	1
ee3180555	144	1
ee3180558	144	1
ee3180559	144	1
ee3180561	144	1
ee3180564	144	1
ee3180566	144	1
ee3180567	144	1
ee3180568	144	1
me1180583	144	1
me1180585	144	1
me1180586	144	1
me1180587	144	1
me1180591	144	1
me1180593	144	1
me1180594	144	1
me1180595	144	1
me1180596	144	1
me1180598	144	1
me1180601	144	1
me1180602	144	1
me1180605	144	1
me1180607	144	1
me1180609	144	1
me1180610	144	1
me1180613	144	1
me1180617	144	1
me1180618	144	1
me1180619	144	1
me1180620	144	1
me1180621	144	1
me1180623	144	1
me1180625	144	1
me1180629	144	1
me1180632	144	1
me1180635	144	1
me1180636	144	1
me1180637	144	1
me1180638	144	1
me1180639	144	1
me1180640	144	1
me1180642	144	1
me1180643	144	1
me1180646	144	1
me1180647	144	1
me1180648	144	1
me1180649	144	1
me1180652	144	1
me1180653	144	1
me1180655	144	1
me1180657	144	1
me2160798	144	1
me2170659	144	1
me2180665	144	1
me2180667	144	1
me2180669	144	1
me2180671	144	1
me2180673	144	1
me2180677	144	1
me2180680	144	1
me2180684	144	1
me2180685	144	1
me2180686	144	1
me2180689	144	1
me2180693	144	1
me2180697	144	1
me2180702	144	1
me2180704	144	1
me2180705	144	1
me2180708	144	1
me2180710	144	1
me2180711	144	1
me2180714	144	1
me2180720	144	1
me2180721	144	1
me2180724	144	1
me2180727	144	1
me2180729	144	1
me2180731	144	1
me2180734	144	1
me2180735	144	1
mt1180736	144	1
mt1180737	144	1
mt1180740	144	1
mt1180741	144	1
mt1180743	144	1
mt1180745	144	1
mt1180747	144	1
mt1180749	144	1
mt1180750	144	1
mt1180751	144	1
mt1180752	144	1
mt1180753	144	1
mt1180754	144	1
mt1180756	144	1
mt1180759	144	1
mt1180761	144	1
mt1180763	144	1
mt1180764	144	1
mt1180765	144	1
mt1180766	144	1
mt1180767	144	1
mt1180768	144	1
mt1180769	144	1
mt1180771	144	1
mt1180772	144	1
mt1180773	144	1
mt1180774	144	1
mt6180776	144	1
mt6180778	144	1
mt6180779	144	1
mt6180780	144	1
mt6180781	144	1
mt6180782	144	1
mt6180784	144	1
mt6180786	144	1
mt6180787	144	1
mt6180788	144	1
mt6180789	144	1
mt6180791	144	1
mt6180792	144	1
mt6180796	144	1
mt6180798	144	1
ph1180804	144	1
ph1180805	144	1
ph1180806	144	1
ph1180808	144	1
ph1180809	144	1
ph1180811	144	1
ph1180815	144	1
ph1180816	144	1
ph1180818	144	1
ph1180819	144	1
ph1180823	144	1
ph1180824	144	1
ph1180829	144	1
ph1180834	144	1
ph1180835	144	1
ph1180837	144	1
ph1180840	144	1
ph1180841	144	1
ph1180842	144	1
ph1180847	144	1
ph1180849	144	1
ph1180853	144	1
ph1180855	144	1
ph1180856	144	1
ph1180857	144	1
tt1180867	144	1
tt1180868	144	1
tt1180869	144	1
tt1180871	144	1
tt1180873	144	1
tt1180878	144	1
tt1180880	144	1
tt1180883	144	1
tt1180884	144	1
tt1180885	144	1
tt1180886	144	1
tt1180895	144	1
tt1180898	144	1
tt1180899	144	1
tt1180904	144	1
tt1180907	144	1
tt1180908	144	1
tt1180909	144	1
tt1180913	144	1
tt1180914	144	1
tt1180916	144	1
tt1180917	144	1
tt1180918	144	1
tt1180919	144	1
tt1180924	144	1
tt1180926	144	1
tt1180929	144	1
tt1180931	144	1
tt1180935	144	1
tt1180937	144	1
tt1180938	144	1
tt1180941	144	1
tt1180942	144	1
tt1180943	144	1
tt1180944	144	1
tt1180945	144	1
tt1180948	144	1
tt1180949	144	1
tt1180953	144	1
tt1180957	144	1
tt1180958	144	1
tt1180959	144	1
tt1180961	144	1
tt1180966	144	1
tt1180970	144	1
tt1180971	144	1
tt1180972	144	1
tt1180974	144	1
cys187002	145	1
cys187003	145	1
cys187004	145	1
cys187005	145	1
cys187006	145	1
cys187007	145	1
cys187008	145	1
cys187009	145	1
cys187010	145	1
cys187011	145	1
cys187012	145	1
cys187013	145	1
cys187014	145	1
cys187015	145	1
cys187017	145	1
cys187018	145	1
cys187019	145	1
cys187020	145	1
cys187021	145	1
cys187022	145	1
cys187023	145	1
cys187024	145	1
cys187025	145	1
cys187026	145	1
cys187027	145	1
cys187028	145	1
cys187029	145	1
cys187030	145	1
cys187031	145	1
cys187032	145	1
cys187033	145	1
cys187034	145	1
cys187035	145	1
cys187036	145	1
cys187037	145	1
cys187038	145	1
cys187039	145	1
cys187040	145	1
cys187041	145	1
cys187042	145	1
cys187044	145	1
cys187045	145	1
cys187046	145	1
cys187047	145	1
cys187048	145	1
cys187049	145	1
cys187050	145	1
cys187051	145	1
cys187052	145	1
cys187053	145	1
cys187054	145	1
cys187055	145	1
cys187056	145	1
cys187002	146	1
cys187003	146	1
cys187004	146	1
cys187005	146	1
cys187006	146	1
cys187007	146	1
cys187008	146	1
cys187009	146	1
cys187010	146	1
cys187011	146	1
cys187012	146	1
cys187013	146	1
cys187014	146	1
cys187015	146	1
cys187017	146	1
cys187018	146	1
cys187019	146	1
cys187020	146	1
cys187021	146	1
cys187022	146	1
cys187023	146	1
cys187024	146	1
cys187025	146	1
cys187026	146	1
cys187027	146	1
cys187028	146	1
cys187029	146	1
cys187030	146	1
cys187031	146	1
cys187032	146	1
cys187033	146	1
cys187034	146	1
cys187035	146	1
cys187036	146	1
cys187037	146	1
cys187038	146	1
cys187039	146	1
cys187040	146	1
cys187041	146	1
cys187042	146	1
cys187044	146	1
cys187045	146	1
cys187046	146	1
cys187047	146	1
cys187048	146	1
cys187049	146	1
cys187050	146	1
cys187051	146	1
cys187052	146	1
cys187053	146	1
cys187054	146	1
cys187055	146	1
cys187056	146	1
cym182026	147	1
cym182028	147	1
cym182029	147	1
cym182030	147	1
cym182031	147	1
cym182032	147	1
cym182034	147	1
cym182035	147	1
bb5140004	148	1
ch1150122	148	1
cs1150227	148	1
cs1150267	148	1
cs1160312	148	1
cs1160336	148	1
cs1160359	148	1
cs1160379	148	1
cs1160395	148	1
cs1160701	148	1
cs1170351	148	1
cs1170352	148	1
cs1170377	148	1
cs1170416	148	1
cs1170481	148	1
cs1170487	148	1
cs1170540	148	1
cs1170836	148	1
cs5140281	148	1
cs5160615	148	1
cs5170403	148	1
cs5170408	148	1
cs5170409	148	1
cs5170410	148	1
cs5170602	148	1
mt6170250	148	1
ph1150812	148	1
cs1140266	149	1
cs1150224	149	1
cs1150225	149	1
cs1150227	149	1
cs1120265	150	1
cs1130237	150	1
cs1140249	150	1
cs1140262	150	1
cs1150201	150	1
cs1150203	150	1
cs1150204	150	1
cs1150206	150	1
cs1150208	150	1
cs1150209	150	1
cs1150210	150	1
cs1150212	150	1
cs1150213	150	1
cs1150214	150	1
cs1150215	150	1
cs1150218	150	1
cs1150236	150	1
cs1150238	150	1
cs1150239	150	1
cs1150240	150	1
cs1150242	150	1
cs1150245	150	1
cs1150251	150	1
cs1150252	150	1
cs1150253	150	1
cs1150254	150	1
cs1150258	150	1
cs1150259	150	1
cs1150262	150	1
cs1150263	150	1
cs1150265	150	1
cs1150291	150	1
cs1150341	150	1
cs1150424	150	1
cs1150435	150	1
cs1150460	150	1
cs1150461	150	1
cs1150600	150	1
cs1150667	150	1
ee1150476	150	1
cs1160314	151	1
cs5120300	151	1
cs5150102	151	1
cs5150276	151	1
cs5150277	151	1
cs5150279	151	1
cs5150280	151	1
cs5150281	151	1
cs5150282	151	1
cs5150283	151	1
cs5150285	151	1
cs5150287	151	1
cs5150288	151	1
cs5150289	151	1
cs5150293	151	1
cs5150294	151	1
cs5150295	151	1
cs5150296	151	1
cs5150297	151	1
cs5160387	151	1
cs5160789	151	1
mcs182007	151	1
mcs182009	151	1
mcs182011	151	1
mcs182012	151	1
mcs182013	151	1
mcs182014	151	1
mcs182015	151	1
mcs182016	151	1
mcs182017	151	1
mcs182018	151	1
mcs182019	151	1
mcs182020	151	1
mcs182021	151	1
mcs182024	151	1
mcs182025	151	1
mcs182092	151	1
mcs182093	151	1
mcs182094	151	1
mcs182095	151	1
mcs182120	151	1
mcs182140	151	1
mcs182141	151	1
mcs182142	151	1
mcs182143	151	1
mcs182144	151	1
mcs182839	151	1
mcs182840	151	1
me2150713	151	1
ph1150813	151	1
tt1150917	151	1
cs5150459	152	1
ch1140786	153	1
cs5140276	153	1
cs5140277	153	1
cs5140278	153	1
cs5140279	153	1
cs5140280	153	1
cs5140281	153	1
cs5140282	153	1
cs5140283	153	1
cs5140284	153	1
cs5140286	153	1
cs5140288	153	1
cs5140289	153	1
cs5140292	153	1
cs5140293	153	1
cs5140296	153	1
cs5140297	153	1
cs5140435	153	1
cs5140462	153	1
cs5140599	153	1
cs5140736	153	1
mcs172071	153	1
mcs172074	153	1
mcs172076	153	1
mcs172077	153	1
mcs172078	153	1
mcs172079	153	1
mcs172080	153	1
mcs172092	153	1
mcs172093	153	1
mcs172101	153	1
mcs172102	153	1
mcs172103	153	1
mcs172525	153	1
mcs172678	153	1
mcs172758	153	1
mcs172832	153	1
mcs172847	153	1
mcs172851	153	1
mcs172858	153	1
mcs172873	153	1
me2140762	153	1
tt1140934	153	1
csy157512	154	1
csy157533	154	1
csy157535	154	1
csy167526	154	1
csy168515	154	1
bb1140037	155	1
bb1140039	155	1
bb1140053	155	1
bb1150031	155	1
bb1150036	155	1
bb1150037	155	1
bb1150059	155	1
bb1160028	155	1
bb1160031	155	1
bb1160043	155	1
bb1160060	155	1
bb1160061	155	1
bb1160062	155	1
bb1170036	155	1
bb1180001	155	1
bb1180002	155	1
bb1180004	155	1
bb1180005	155	1
bb1180006	155	1
bb1180008	155	1
bb1180012	155	1
bb1180016	155	1
bb1180017	155	1
bb1180019	155	1
bb1180020	155	1
bb1180021	155	1
bb1180023	155	1
bb1180024	155	1
bb1180025	155	1
bb1180029	155	1
bb1180030	155	1
bb1180031	155	1
bb1180032	155	1
bb1180034	155	1
bb1180036	155	1
bb1180037	155	1
bb1180038	155	1
bb1180039	155	1
bb1180041	155	1
bb1180042	155	1
bb1180044	155	1
bb1180045	155	1
bb1180046	155	1
bb5150014	155	1
bb5160015	155	1
bb5180051	155	1
bb5180052	155	1
bb5180053	155	1
bb5180054	155	1
bb5180056	155	1
bb5180057	155	1
bb5180058	155	1
bb5180060	155	1
bb5180063	155	1
bb5180064	155	1
bb5180066	155	1
ce1130386	155	1
ce1150321	155	1
ce1150393	155	1
ce1180074	155	1
ce1180076	155	1
ce1180078	155	1
ce1180079	155	1
ce1180083	155	1
ce1180084	155	1
ce1180085	155	1
ce1180086	155	1
ce1180090	155	1
ce1180094	155	1
ce1180095	155	1
ce1180101	155	1
ce1180104	155	1
ce1180106	155	1
ce1180108	155	1
ce1180110	155	1
ce1180112	155	1
ce1180117	155	1
ce1180118	155	1
ce1180120	155	1
ce1180124	155	1
ce1180132	155	1
ce1180133	155	1
ce1180141	155	1
ce1180146	155	1
ce1180148	155	1
ce1180149	155	1
ce1180150	155	1
ce1180151	155	1
ce1180154	155	1
ce1180157	155	1
ce1180158	155	1
ce1180163	155	1
ce1180164	155	1
ce1180165	155	1
ce1180167	155	1
ce1180168	155	1
ce1180169	155	1
ce1180172	155	1
ce1180177	155	1
ch1130080	155	1
ch1180187	155	1
ch1180189	155	1
ch1180191	155	1
ch1180193	155	1
ch1180194	155	1
ch1180195	155	1
ch1180197	155	1
ch1180199	155	1
ch1180200	155	1
ch1180201	155	1
ch1180202	155	1
ch1180203	155	1
ch1180205	155	1
ch1180208	155	1
ch1180210	155	1
ch1180211	155	1
ch1180213	155	1
ch1180214	155	1
ch1180215	155	1
ch1180216	155	1
ch1180218	155	1
ch1180220	155	1
ch1180221	155	1
ch1180225	155	1
ch1180227	155	1
ch1180229	155	1
ch1180230	155	1
ch1180234	155	1
ch1180239	155	1
ch1180242	155	1
ch1180247	155	1
ch1180248	155	1
ch1180249	155	1
ch1180250	155	1
ch1180251	155	1
ch1180252	155	1
ch1180253	155	1
ch1180254	155	1
ch1180255	155	1
ch1180257	155	1
ch1180259	155	1
ch1180260	155	1
ch1180261	155	1
ch7150151	155	1
ch7150169	155	1
ch7150170	155	1
ch7150175	155	1
ch7160176	155	1
ch7170285	155	1
ch7170315	155	1
ch7180271	155	1
ch7180272	155	1
ch7180277	155	1
ch7180278	155	1
ch7180279	155	1
ch7180280	155	1
ch7180281	155	1
ch7180282	155	1
ch7180285	155	1
ch7180287	155	1
ch7180288	155	1
ch7180290	155	1
ch7180293	155	1
ch7180295	155	1
ch7180296	155	1
ch7180297	155	1
ch7180299	155	1
ch7180301	155	1
ch7180302	155	1
ch7180304	155	1
ch7180305	155	1
ch7180306	155	1
ch7180311	155	1
ch7180315	155	1
ch7180317	155	1
cs1180322	155	1
cs1180323	155	1
cs1180327	155	1
cs1180330	155	1
cs1180331	155	1
cs1180332	155	1
cs1180334	155	1
cs1180335	155	1
cs1180340	155	1
cs1180344	155	1
cs1180345	155	1
cs1180346	155	1
cs1180348	155	1
cs1180350	155	1
cs1180351	155	1
cs1180355	155	1
cs1180360	155	1
cs1180362	155	1
cs1180366	155	1
cs1180370	155	1
cs1180372	155	1
cs1180373	155	1
cs1180374	155	1
cs1180377	155	1
cs1180380	155	1
cs1180381	155	1
cs1180385	155	1
cs1180386	155	1
cs1180389	155	1
cs1180390	155	1
cs1180392	155	1
cs1180393	155	1
cs1180394	155	1
cs1180395	155	1
cs1180397	155	1
cs5180401	155	1
cs5180402	155	1
cs5180403	155	1
cs5180404	155	1
cs5180405	155	1
cs5180408	155	1
cs5180412	155	1
cs5180413	155	1
cs5180419	155	1
cs5180420	155	1
cs5180422	155	1
cs5180425	155	1
cs5180426	155	1
ee1150440	155	1
ee1150475	155	1
ee1160452	155	1
ee1180433	155	1
ee1180434	155	1
ee1180436	155	1
ee1180437	155	1
ee1180439	155	1
ee1180441	155	1
ee1180443	155	1
ee1180444	155	1
ee1180446	155	1
ee1180447	155	1
ee1180452	155	1
ee1180454	155	1
ee1180456	155	1
ee1180458	155	1
ee1180459	155	1
ee1180460	155	1
ee1180467	155	1
ee1180468	155	1
ee1180469	155	1
ee1180470	155	1
ee1180473	155	1
ee1180476	155	1
ee1180482	155	1
ee1180483	155	1
ee1180485	155	1
ee1180486	155	1
ee1180489	155	1
ee1180491	155	1
ee1180492	155	1
ee1180496	155	1
ee1180497	155	1
ee1180504	155	1
ee1180505	155	1
ee1180506	155	1
ee1180509	155	1
ee1180511	155	1
ee3150538	155	1
ee3180521	155	1
ee3180523	155	1
ee3180524	155	1
ee3180525	155	1
ee3180527	155	1
ee3180528	155	1
ee3180530	155	1
ee3180531	155	1
ee3180533	155	1
ee3180535	155	1
ee3180541	155	1
ee3180542	155	1
ee3180545	155	1
ee3180546	155	1
ee3180547	155	1
ee3180549	155	1
ee3180553	155	1
ee3180554	155	1
ee3180556	155	1
ee3180557	155	1
ee3180560	155	1
ee3180562	155	1
ee3180563	155	1
ee3180565	155	1
ee3180569	155	1
me1080528	155	1
me1170563	155	1
me1180581	155	1
me1180582	155	1
me1180584	155	1
me1180588	155	1
me1180589	155	1
me1180590	155	1
me1180592	155	1
me1180597	155	1
me1180599	155	1
me1180600	155	1
me1180603	155	1
me1180604	155	1
me1180606	155	1
me1180608	155	1
me1180611	155	1
me1180612	155	1
me1180614	155	1
me1180615	155	1
me1180616	155	1
me1180622	155	1
me1180624	155	1
me1180626	155	1
me1180627	155	1
me1180628	155	1
me1180630	155	1
me1180631	155	1
me1180633	155	1
me1180634	155	1
me1180641	155	1
me1180644	155	1
me1180645	155	1
me1180650	155	1
me1180651	155	1
me1180654	155	1
me1180656	155	1
me1180658	155	1
me2160802	155	1
me2170642	155	1
me2170643	155	1
me2170646	155	1
me2170658	155	1
me2170662	155	1
me2170667	155	1
me2170678	155	1
me2170679	155	1
me2170687	155	1
me2170699	155	1
me2170701	155	1
me2170703	155	1
me2180661	155	1
me2180663	155	1
me2180664	155	1
me2180666	155	1
me2180668	155	1
me2180670	155	1
me2180672	155	1
me2180674	155	1
me2180675	155	1
me2180676	155	1
me2180678	155	1
me2180679	155	1
me2180681	155	1
me2180682	155	1
me2180687	155	1
me2180688	155	1
me2180690	155	1
me2180691	155	1
me2180692	155	1
me2180694	155	1
me2180695	155	1
me2180696	155	1
me2180698	155	1
me2180699	155	1
me2180700	155	1
me2180701	155	1
me2180703	155	1
me2180706	155	1
me2180707	155	1
me2180709	155	1
me2180712	155	1
me2180713	155	1
me2180715	155	1
me2180716	155	1
me2180717	155	1
me2180718	155	1
me2180719	155	1
me2180722	155	1
me2180723	155	1
me2180725	155	1
me2180726	155	1
me2180728	155	1
me2180730	155	1
me2180732	155	1
me2180733	155	1
me2180736	155	1
mt1160635	155	1
mt1180738	155	1
mt1180739	155	1
mt1180742	155	1
mt1180744	155	1
mt1180746	155	1
mt1180748	155	1
mt1180755	155	1
mt1180757	155	1
mt1180758	155	1
mt1180760	155	1
mt1180762	155	1
mt1180770	155	1
mt6180777	155	1
mt6180783	155	1
mt6180785	155	1
mt6180790	155	1
mt6180793	155	1
mt6180794	155	1
mt6180795	155	1
mt6180797	155	1
ph1130836	155	1
ph1150804	155	1
ph1150810	155	1
ph1150825	155	1
ph1150836	155	1
ph1160588	155	1
ph1160590	155	1
ph1160597	155	1
ph1170852	155	1
ph1170858	155	1
ph1180801	155	1
ph1180802	155	1
ph1180803	155	1
ph1180810	155	1
ph1180812	155	1
ph1180813	155	1
ph1180814	155	1
ph1180817	155	1
ph1180820	155	1
ph1180821	155	1
ph1180822	155	1
ph1180825	155	1
ph1180826	155	1
ph1180827	155	1
ph1180828	155	1
ph1180830	155	1
ph1180831	155	1
ph1180832	155	1
ph1180833	155	1
ph1180836	155	1
ph1180838	155	1
ph1180839	155	1
ph1180843	155	1
ph1180844	155	1
ph1180845	155	1
ph1180846	155	1
ph1180848	155	1
ph1180850	155	1
ph1180851	155	1
ph1180852	155	1
ph1180854	155	1
ph1180858	155	1
ph1180859	155	1
ph1180860	155	1
tt1140887	155	1
tt1140937	155	1
tt1140944	155	1
tt1150866	155	1
tt1150887	155	1
tt1160663	155	1
tt1160902	155	1
tt1160904	155	1
tt1160916	155	1
tt1160919	155	1
tt1160923	155	1
tt1160925	155	1
tt1170895	155	1
tt1180866	155	1
tt1180872	155	1
tt1180874	155	1
tt1180875	155	1
tt1180876	155	1
tt1180877	155	1
tt1180879	155	1
tt1180881	155	1
tt1180882	155	1
tt1180887	155	1
tt1180888	155	1
tt1180889	155	1
tt1180890	155	1
tt1180892	155	1
tt1180894	155	1
tt1180896	155	1
tt1180897	155	1
tt1180900	155	1
tt1180901	155	1
tt1180903	155	1
tt1180905	155	1
tt1180906	155	1
tt1180910	155	1
tt1180911	155	1
tt1180912	155	1
tt1180915	155	1
tt1180920	155	1
tt1180921	155	1
tt1180922	155	1
tt1180923	155	1
tt1180925	155	1
tt1180927	155	1
tt1180928	155	1
tt1180930	155	1
tt1180933	155	1
tt1180934	155	1
tt1180936	155	1
tt1180939	155	1
tt1180940	155	1
tt1180946	155	1
tt1180947	155	1
tt1180950	155	1
tt1180951	155	1
tt1180952	155	1
tt1180954	155	1
tt1180955	155	1
tt1180956	155	1
tt1180960	155	1
tt1180962	155	1
tt1180963	155	1
tt1180964	155	1
tt1180965	155	1
tt1180967	155	1
tt1180968	155	1
tt1180969	155	1
tt1180975	155	1
bb1150034	156	1
bb1150047	156	1
bb1150054	156	1
bb1150055	156	1
bb1160024	156	1
bb1160026	156	1
bb1160030	156	1
bb1160034	156	1
bb1160039	156	1
bb1160046	156	1
bb1160047	156	1
bb1160048	156	1
bb1160049	156	1
bb1160053	156	1
bb1160057	156	1
bb1170012	156	1
bb1170026	156	1
bb1170045	156	1
bb5150004	156	1
bb5150012	156	1
bb5160011	156	1
ce1160215	156	1
ce1160216	156	1
ce1160217	156	1
ce1160223	156	1
ce1160230	156	1
ce1160232	156	1
ce1160233	156	1
ce1160236	156	1
ce1160237	156	1
ce1160247	156	1
ce1160252	156	1
ce1160267	156	1
ce1160293	156	1
ce1160299	156	1
ce1170089	156	1
ce1170174	156	1
ch1150131	156	1
ch1150134	156	1
ch1160076	156	1
ch1160079	156	1
ch1160081	156	1
ch1160082	156	1
ch1160085	156	1
ch1160088	156	1
ch1160090	156	1
ch1160091	156	1
ch1160094	156	1
ch1160095	156	1
ch1160096	156	1
ch1160097	156	1
ch1160099	156	1
ch1160101	156	1
ch1160102	156	1
ch1160113	156	1
ch1160118	156	1
ch1160119	156	1
ch1160122	156	1
ch1160123	156	1
ch1160124	156	1
ch1160126	156	1
ch1160131	156	1
ch1160133	156	1
ch1160137	156	1
ch1160675	156	1
ch1170120	156	1
ch1170189	156	1
ch1170243	156	1
ch1170894	156	1
ch7160152	156	1
ch7160157	156	1
ch7160158	156	1
ch7160159	156	1
cs1170321	156	1
cs1170323	156	1
cs1170332	156	1
cs1170344	156	1
cs5170401	156	1
cs5170406	156	1
cs5170418	156	1
ee1130445	156	1
ee1130484	156	1
ee1130495	156	1
ee1130515	156	1
ee1160477	156	1
ee3130555	156	1
ee3140503	156	1
ee3140526	156	1
ee3150520	156	1
me1150633	156	1
me1150651	156	1
me1160036	156	1
me1160073	156	1
me1160080	156	1
me1160670	156	1
me1160672	156	1
me1160674	156	1
me1160678	156	1
me1160682	156	1
me1160683	156	1
me1160687	156	1
me1160689	156	1
me1160690	156	1
me1160692	156	1
me1160696	156	1
me1160697	156	1
me1160698	156	1
me1160699	156	1
me1160702	156	1
me1160704	156	1
me1160708	156	1
me1160709	156	1
me1160712	156	1
me1160713	156	1
me1160714	156	1
me1160715	156	1
me1160716	156	1
me1160718	156	1
me1160719	156	1
me1160721	156	1
me1160723	156	1
me1160724	156	1
me1160725	156	1
me1160726	156	1
me1160727	156	1
me1160730	156	1
me1160731	156	1
me1160754	156	1
me1160824	156	1
me1160829	156	1
me1160830	156	1
me1170061	156	1
me1170620	156	1
me1170967	156	1
me2150712	156	1
me2150740	156	1
me2150763	156	1
me2150765	156	1
me2160748	156	1
me2160755	156	1
me2160756	156	1
me2160757	156	1
me2160760	156	1
me2160761	156	1
me2160763	156	1
me2160768	156	1
me2160772	156	1
me2160773	156	1
me2160775	156	1
me2160777	156	1
me2160781	156	1
me2160786	156	1
me2160788	156	1
me2160790	156	1
me2160793	156	1
me2160800	156	1
me2160806	156	1
me2170695	156	1
me2170696	156	1
me2170697	156	1
me2170706	156	1
mt1160582	156	1
mt1160623	156	1
mt1160634	156	1
mt6140552	156	1
mt6160657	156	1
mt6160664	156	1
mt6170777	156	1
ph1150783	156	1
ph1150827	156	1
ph1160543	156	1
ph1160549	156	1
ph1160554	156	1
ph1160562	156	1
ph1160565	156	1
ph1160573	156	1
ph1160579	156	1
ph1160580	156	1
ph1160584	156	1
ph1170808	156	1
ph1170810	156	1
ph1170815	156	1
ph1170820	156	1
ph1170833	156	1
ph1170846	156	1
ph1170854	156	1
tt1150856	156	1
tt1150920	156	1
tt1150940	156	1
tt1160862	156	1
tt1160866	156	1
tt1160870	156	1
tt1160874	156	1
tt1160880	156	1
tt1160885	156	1
tt1160888	156	1
tt1160894	156	1
tt1160895	156	1
tt1160896	156	1
tt1160899	156	1
tt1160905	156	1
tt1160908	156	1
tt1160911	156	1
tt1170896	156	1
tt1170965	156	1
tt1170976	156	1
cs1120265	157	1
cs1140249	157	1
cs1140259	157	1
cs1140260	157	1
cs1150220	157	1
cs1150221	157	1
cs1150248	157	1
cs1150249	157	1
cs1150250	157	1
cs1160330	157	1
cs1160338	157	1
cs1170219	157	1
cs1170322	157	1
cs1170324	157	1
cs1170325	157	1
cs1170326	157	1
cs1170327	157	1
cs1170328	157	1
cs1170329	157	1
cs1170330	157	1
cs1170331	157	1
cs1170332	157	1
cs1170333	157	1
cs1170334	157	1
cs1170335	157	1
cs1170337	157	1
cs1170338	157	1
cs1170339	157	1
cs1170340	157	1
cs1170341	157	1
cs1170342	157	1
cs1170343	157	1
cs1170346	157	1
cs1170347	157	1
cs1170348	157	1
cs1170349	157	1
cs1170350	157	1
cs1170351	157	1
cs1170352	157	1
cs1170353	157	1
cs1170354	157	1
cs1170355	157	1
cs1170356	157	1
cs1170357	157	1
cs1170358	157	1
cs1170359	157	1
cs1170360	157	1
cs1170361	157	1
cs1170362	157	1
cs1170363	157	1
cs1170364	157	1
cs1170365	157	1
cs1170366	157	1
cs1170367	157	1
cs1170368	157	1
cs1170369	157	1
cs1170370	157	1
cs1170371	157	1
cs1170372	157	1
cs1170373	157	1
cs1170374	157	1
cs1170375	157	1
cs1170376	157	1
cs1170377	157	1
cs1170378	157	1
cs1170379	157	1
cs1170380	157	1
cs1170381	157	1
cs1170382	157	1
cs1170383	157	1
cs1170384	157	1
cs1170385	157	1
cs1170386	157	1
cs1170387	157	1
cs1170388	157	1
cs1170389	157	1
cs1170390	157	1
cs1170416	157	1
cs1170481	157	1
cs1170487	157	1
cs1170489	157	1
cs1170503	157	1
cs1170540	157	1
cs1170589	157	1
cs1170790	157	1
cs1170836	157	1
cs5140285	157	1
cs5140287	157	1
cs5160390	157	1
cs5170402	157	1
cs5170403	157	1
cs5170405	157	1
cs5170406	157	1
cs5170407	157	1
cs5170408	157	1
cs5170409	157	1
cs5170410	157	1
cs5170411	157	1
cs5170412	157	1
cs5170413	157	1
cs5170414	157	1
cs5170415	157	1
cs5170417	157	1
cs5170419	157	1
cs5170420	157	1
cs5170421	157	1
cs5170422	157	1
cs5170488	157	1
cs5170493	157	1
cs5170521	157	1
cs5170602	157	1
ph1150827	157	1
ph1160565	157	1
cs1140249	158	1
cs1140259	158	1
cs1140260	158	1
cs1150220	158	1
cs1150221	158	1
cs1150231	158	1
cs1150232	158	1
cs1150248	158	1
cs1150249	158	1
cs1150250	158	1
cs1150256	158	1
cs1150266	158	1
cs1160318	158	1
cs1160320	158	1
cs1160338	158	1
cs1160360	158	1
cs1160378	158	1
cs1170219	158	1
cs1170322	158	1
cs1170324	158	1
cs1170325	158	1
cs1170326	158	1
cs1170327	158	1
cs1170328	158	1
cs1170329	158	1
cs1170330	158	1
cs1170331	158	1
cs1170333	158	1
cs1170334	158	1
cs1170335	158	1
cs1170337	158	1
cs1170338	158	1
cs1170339	158	1
cs1170340	158	1
cs1170341	158	1
cs1170342	158	1
cs1170343	158	1
cs1170346	158	1
cs1170347	158	1
cs1170348	158	1
cs1170349	158	1
cs1170350	158	1
cs1170351	158	1
cs1170352	158	1
cs1170353	158	1
cs1170354	158	1
cs1170355	158	1
cs1170356	158	1
cs1170357	158	1
cs1170358	158	1
cs1170359	158	1
cs1170360	158	1
cs1170361	158	1
cs1170362	158	1
cs1170363	158	1
cs1170364	158	1
cs1170365	158	1
cs1170366	158	1
cs1170367	158	1
cs1170368	158	1
cs1170369	158	1
cs1170370	158	1
cs1170371	158	1
cs1170372	158	1
cs1170373	158	1
cs1170374	158	1
cs1170375	158	1
cs1170376	158	1
cs1170377	158	1
cs1170378	158	1
cs1170379	158	1
cs1170380	158	1
cs1170381	158	1
cs1170382	158	1
cs1170383	158	1
cs1170384	158	1
cs1170385	158	1
cs1170386	158	1
cs1170387	158	1
cs1170388	158	1
cs1170389	158	1
cs1170390	158	1
cs1170416	158	1
cs1170481	158	1
cs1170487	158	1
cs1170489	158	1
cs1170503	158	1
cs1170540	158	1
cs1170589	158	1
cs1170790	158	1
cs1170836	158	1
cs5120299	158	1
cs5120300	158	1
cs5150277	158	1
cs5160390	158	1
cs5160402	158	1
cs5170402	158	1
cs5170403	158	1
cs5170404	158	1
cs5170405	158	1
cs5170407	158	1
cs5170408	158	1
cs5170409	158	1
cs5170410	158	1
cs5170411	158	1
cs5170412	158	1
cs5170413	158	1
cs5170414	158	1
cs5170415	158	1
cs5170417	158	1
cs5170419	158	1
cs5170420	158	1
cs5170421	158	1
cs5170422	158	1
cs5170488	158	1
cs5170493	158	1
cs5170521	158	1
cs5170602	158	1
ee1140433	158	1
ee1150422	158	1
ee1150434	158	1
ee1150493	158	1
ee1150691	158	1
ee1150908	158	1
ee3150649	158	1
ph1150812	158	1
tt1160843	158	1
cs1120265	159	1
cs1130237	159	1
cs1150211	159	1
cs1150224	159	1
cs1150225	159	1
cs1150231	159	1
cs1150232	159	1
cs1150248	159	1
cs1160087	159	1
cs1160294	159	1
cs1160310	159	1
cs1160311	159	1
cs1160312	159	1
cs1160313	159	1
cs1160314	159	1
cs1160315	159	1
cs1160316	159	1
cs1160317	159	1
cs1160318	159	1
cs1160319	159	1
cs1160320	159	1
cs1160321	159	1
cs1160322	159	1
cs1160323	159	1
cs1160324	159	1
cs1160325	159	1
cs1160326	159	1
cs1160327	159	1
cs1160328	159	1
cs1160329	159	1
cs1160330	159	1
cs1160331	159	1
cs1160332	159	1
cs1160333	159	1
cs1160335	159	1
cs1160336	159	1
cs1160337	159	1
cs1160338	159	1
cs1160339	159	1
cs1160340	159	1
cs1160341	159	1
cs1160342	159	1
cs1160343	159	1
cs1160344	159	1
cs1160345	159	1
cs1160347	159	1
cs1160348	159	1
cs1160349	159	1
cs1160350	159	1
cs1160351	159	1
cs1160352	159	1
cs1160353	159	1
cs1160354	159	1
cs1160355	159	1
cs1160356	159	1
cs1160357	159	1
cs1160358	159	1
cs1160359	159	1
cs1160360	159	1
cs1160362	159	1
cs1160363	159	1
cs1160364	159	1
cs1160365	159	1
cs1160366	159	1
cs1160367	159	1
cs1160368	159	1
cs1160369	159	1
cs1160370	159	1
cs1160371	159	1
cs1160372	159	1
cs1160373	159	1
cs1160374	159	1
cs1160375	159	1
cs1160376	159	1
cs1160377	159	1
cs1160378	159	1
cs1160379	159	1
cs1160385	159	1
cs1160395	159	1
cs1160396	159	1
cs1160406	159	1
cs1160412	159	1
cs1160513	159	1
cs1160523	159	1
cs1160680	159	1
cs1160701	159	1
cs5120299	159	1
cs5130286	159	1
cs5140291	159	1
cs5140294	159	1
cs5150281	159	1
cs5150282	159	1
cs5150289	159	1
cs5160084	159	1
cs5160386	159	1
cs5160387	159	1
cs5160388	159	1
cs5160389	159	1
cs5160391	159	1
cs5160392	159	1
cs5160393	159	1
cs5160394	159	1
cs5160397	159	1
cs5160398	159	1
cs5160399	159	1
cs5160400	159	1
cs5160401	159	1
cs5160402	159	1
cs5160403	159	1
cs5160404	159	1
cs5160414	159	1
cs5160433	159	1
cs5160615	159	1
cs5160625	159	1
cs5160789	159	1
ee1160443	159	1
ee1160446	159	1
ph1150813	159	1
ph1150822	159	1
ph1150840	159	1
tt1160847	159	1
cs1130237	160	1
cs1140259	160	1
cs1140260	160	1
cs1150211	160	1
cs1150224	160	1
cs1150227	160	1
cs1150232	160	1
cs1150241	160	1
cs1150249	160	1
cs1150256	160	1
cs1150258	160	1
cs1150263	160	1
cs1150341	160	1
cs1160087	160	1
cs1160294	160	1
cs1160310	160	1
cs1160311	160	1
cs1160312	160	1
cs1160313	160	1
cs1160314	160	1
cs1160315	160	1
cs1160316	160	1
cs1160317	160	1
cs1160318	160	1
cs1160319	160	1
cs1160320	160	1
cs1160321	160	1
cs1160322	160	1
cs1160323	160	1
cs1160324	160	1
cs1160325	160	1
cs1160326	160	1
cs1160327	160	1
cs1160328	160	1
cs1160329	160	1
cs1160330	160	1
cs1160331	160	1
cs1160332	160	1
cs1160333	160	1
cs1160335	160	1
cs1160336	160	1
cs1160337	160	1
cs1160338	160	1
cs1160339	160	1
cs1160340	160	1
cs1160341	160	1
cs1160342	160	1
cs1160343	160	1
cs1160344	160	1
cs1160345	160	1
cs1160347	160	1
cs1160348	160	1
cs1160349	160	1
cs1160350	160	1
cs1160351	160	1
cs1160352	160	1
cs1160353	160	1
cs1160354	160	1
cs1160355	160	1
cs1160356	160	1
cs1160357	160	1
cs1160358	160	1
cs1160359	160	1
cs1160360	160	1
cs1160362	160	1
cs1160363	160	1
cs1160364	160	1
cs1160365	160	1
cs1160366	160	1
cs1160367	160	1
cs1160368	160	1
cs1160369	160	1
cs1160370	160	1
cs1160371	160	1
cs1160372	160	1
cs1160373	160	1
cs1160374	160	1
cs1160375	160	1
cs1160377	160	1
cs1160378	160	1
cs1160379	160	1
cs1160385	160	1
cs1160395	160	1
cs1160396	160	1
cs1160406	160	1
cs1160412	160	1
cs1160513	160	1
cs1160523	160	1
cs1160680	160	1
cs1160701	160	1
cs1170326	160	1
cs5120277	160	1
cs5140287	160	1
cs5140291	160	1
cs5140294	160	1
cs5150282	160	1
cs5150284	160	1
cs5150289	160	1
cs5150297	160	1
cs5160387	160	1
cs5160388	160	1
cs5160389	160	1
cs5160390	160	1
cs5160391	160	1
cs5160392	160	1
cs5160393	160	1
cs5160394	160	1
cs5160397	160	1
cs5160398	160	1
cs5160399	160	1
cs5160400	160	1
cs5160401	160	1
cs5160402	160	1
cs5160403	160	1
cs5160404	160	1
cs5160414	160	1
cs5160433	160	1
cs5160625	160	1
cs5160789	160	1
cs5170402	160	1
bb1160052	161	1
bb5100042	161	1
ce1160213	161	1
ce1160226	161	1
ce1160856	161	1
ch1150122	161	1
ch1150145	161	1
ch7140163	161	1
ch7150155	161	1
ch7150186	161	1
cs1130237	161	1
cs1140216	161	1
cs1150214	161	1
cs1150215	161	1
cs1150225	161	1
cs1150227	161	1
cs1150236	161	1
cs1150241	161	1
cs1150246	161	1
cs1150255	161	1
cs1150256	161	1
cs1150259	161	1
cs1150267	161	1
cs1160294	161	1
cs1160314	161	1
cs1160315	161	1
cs1160316	161	1
cs1160318	161	1
cs1160319	161	1
cs1160320	161	1
cs1160322	161	1
cs1160324	161	1
cs1160325	161	1
cs1160330	161	1
cs1160344	161	1
cs1160345	161	1
cs1160349	161	1
cs1160350	161	1
cs1160351	161	1
cs1160357	161	1
cs1160358	161	1
cs1160364	161	1
cs1160365	161	1
cs1160371	161	1
cs1160377	161	1
cs1160378	161	1
cs1160513	161	1
cs1170790	161	1
cs5140287	161	1
cs5140294	161	1
cs5150281	161	1
cs5150283	161	1
cs5150284	161	1
cs5150293	161	1
cs5150294	161	1
cs5150297	161	1
cs5150459	161	1
cs5160390	161	1
cs5160398	161	1
cs5170402	161	1
ee1140433	161	1
ee1150486	161	1
ee1160050	161	1
ee1160418	161	1
ee1160421	161	1
ee1160424	161	1
ee1160434	161	1
ee1160467	161	1
ee1170476	161	1
ee1170938	161	1
ee3160220	161	1
ee3160246	161	1
ee3160508	161	1
ee3160509	161	1
ee3160512	161	1
me1150108	161	1
me1150354	161	1
me2150755	161	1
me2160752	161	1
mt1150583	161	1
mt1150588	161	1
mt1150594	161	1
mt1160618	161	1
mt1170727	161	1
mt1170734	161	1
mt1170735	161	1
mt1170736	161	1
mt1170737	161	1
mt1170738	161	1
mt1170739	161	1
mt1170741	161	1
mt1170743	161	1
mt5120584	161	1
mt5120605	161	1
mt6150373	161	1
mt6150551	161	1
mt6150555	161	1
mt6150556	161	1
mt6150569	161	1
mt6170783	161	1
mt6170784	161	1
mt6170785	161	1
mt6170786	161	1
mt6170788	161	1
ph1150822	161	1
ph1150838	161	1
ph1150840	161	1
ph1160560	161	1
ph1160566	161	1
ph1160567	161	1
ph1160569	161	1
ph1160575	161	1
tt1150906	161	1
tt1160861	161	1
tt1160864	161	1
ch1140786	162	1
ch1150143	162	1
cs1130237	162	1
cs1140227	162	1
cs1140261	162	1
cs1140266	162	1
cs1150211	162	1
cs1150219	162	1
cs1150225	162	1
cs1150231	162	1
cs1150232	162	1
cs1150241	162	1
cs1150244	162	1
cs1150249	162	1
cs1150256	162	1
cs1160087	162	1
cs1160294	162	1
cs1160310	162	1
cs1160311	162	1
cs1160312	162	1
cs1160313	162	1
cs1160314	162	1
cs1160315	162	1
cs1160316	162	1
cs1160317	162	1
cs1160319	162	1
cs1160320	162	1
cs1160321	162	1
cs1160322	162	1
cs1160323	162	1
cs1160324	162	1
cs1160325	162	1
cs1160326	162	1
cs1160327	162	1
cs1160328	162	1
cs1160329	162	1
cs1160331	162	1
cs1160332	162	1
cs1160333	162	1
cs1160335	162	1
cs1160336	162	1
cs1160337	162	1
cs1160338	162	1
cs1160339	162	1
cs1160340	162	1
cs1160341	162	1
cs1160342	162	1
cs1160343	162	1
cs1160344	162	1
cs1160345	162	1
cs1160347	162	1
cs1160348	162	1
cs1160349	162	1
cs1160350	162	1
cs1160351	162	1
cs1160352	162	1
cs1160353	162	1
cs1160354	162	1
cs1160355	162	1
cs1160356	162	1
cs1160357	162	1
cs1160358	162	1
cs1160359	162	1
cs1160360	162	1
cs1160362	162	1
cs1160363	162	1
cs1160365	162	1
cs1160366	162	1
cs1160367	162	1
cs1160368	162	1
cs1160369	162	1
cs1160370	162	1
cs1160371	162	1
cs1160372	162	1
cs1160373	162	1
cs1160374	162	1
cs1160375	162	1
cs1160376	162	1
cs1160377	162	1
cs1160379	162	1
cs1160385	162	1
cs1160395	162	1
cs1160396	162	1
cs1160406	162	1
cs1160412	162	1
cs1160513	162	1
cs1160523	162	1
cs1160680	162	1
cs1160701	162	1
cs5130280	162	1
cs5140283	162	1
cs5140287	162	1
cs5140291	162	1
cs5140294	162	1
cs5150276	162	1
cs5150279	162	1
cs5150288	162	1
cs5150289	162	1
cs5160084	162	1
cs5160386	162	1
cs5160387	162	1
cs5160388	162	1
cs5160389	162	1
cs5160391	162	1
cs5160392	162	1
cs5160393	162	1
cs5160394	162	1
cs5160397	162	1
cs5160398	162	1
cs5160399	162	1
cs5160400	162	1
cs5160401	162	1
cs5160402	162	1
cs5160403	162	1
cs5160404	162	1
cs5160414	162	1
cs5160433	162	1
cs5160615	162	1
cs5160625	162	1
cs5160789	162	1
ee1150422	162	1
ee3150649	162	1
mcs182007	163	1
mcs182013	163	1
mcs182014	163	1
mcs182017	163	1
mcs182019	163	1
mcs182020	163	1
mcs182021	163	1
mcs182024	163	1
mcs182025	163	1
mcs182092	163	1
mcs182093	163	1
mcs182094	163	1
mcs182095	163	1
mcs182140	163	1
me2150713	163	1
csz178061	164	1
me2150713	164	1
tt1140934	164	1
cs5110277	165	1
cs5110290	165	1
cs5120277	165	1
cs5130288	165	1
cs5140282	165	1
cs5140291	165	1
csy187551	165	1
mcs172072	165	1
mcs172075	165	1
mcs172082	165	1
mcs172084	165	1
mcs172085	165	1
mcs172087	165	1
mcs172089	165	1
mcs172095	165	1
mcs172105	165	1
mcs172693	165	1
mcs182092	165	1
mcs182120	165	1
mcs182144	165	1
vst189735	165	1
cs1150229	166	1
cs1150235	166	1
cs1150240	166	1
cs1150242	166	1
cs1150244	166	1
cs1150256	166	1
cs1150265	166	1
cs1150424	166	1
cs1170364	166	1
cs5110277	166	1
cs5120277	166	1
cs5120300	166	1
cs5130280	166	1
cs5130288	166	1
cs5140276	166	1
cs5140280	166	1
cs5140281	166	1
cs5140282	166	1
cs5140284	166	1
cs5140285	166	1
cs5140288	166	1
cs5140296	166	1
cs5140435	166	1
cs5140736	166	1
cs5150102	166	1
cs5150276	166	1
cs5150277	166	1
cs5150280	166	1
cs5150281	166	1
cs5150282	166	1
cs5150283	166	1
cs5150284	166	1
cs5150285	166	1
cs5150286	166	1
cs5150287	166	1
cs5150288	166	1
cs5150289	166	1
cs5150292	166	1
cs5150293	166	1
cs5150294	166	1
cs5150295	166	1
cs5150296	166	1
cs5150297	166	1
ee1150421	166	1
ee3150516	166	1
mcs182012	166	1
mcs182015	166	1
mcs182016	166	1
mcs182018	166	1
mcs182141	166	1
tt1140866	166	1
vst189745	166	1
vst189770	166	1
anz188387	167	1
cs1150239	167	1
cs1150460	167	1
cs1150600	167	1
cs5120277	167	1
cs5140599	167	1
cs5150287	167	1
csz188011	167	1
csz188295	167	1
mcs182840	167	1
siy187504	167	1
anz188060	168	1
anz188387	168	1
ch1150143	168	1
ch1150145	168	1
cs1140266	168	1
cs1150214	168	1
cs1150215	168	1
cs1150244	168	1
cs1150251	168	1
cs1150254	168	1
cs1150257	168	1
cs1150259	168	1
cs1150261	168	1
cs1150264	168	1
cs1150266	168	1
cs1150435	168	1
cs1150460	168	1
cs1150667	168	1
cs5130280	168	1
cs5130286	168	1
cs5130288	168	1
cs5140280	168	1
cs5140282	168	1
cs5140285	168	1
cs5140286	168	1
cs5140289	168	1
cs5140296	168	1
cs5150102	168	1
cs5150276	168	1
cs5150277	168	1
cs5150279	168	1
cs5150280	168	1
cs5150285	168	1
cs5150288	168	1
cs5150292	168	1
cs5150459	168	1
csy187551	168	1
csz188012	168	1
csz188014	168	1
ee3150516	168	1
mcs172072	168	1
mcs172082	168	1
mcs172084	168	1
mcs172085	168	1
mcs172087	168	1
mcs172089	168	1
mcs172104	168	1
mcs172105	168	1
mcs172693	168	1
mcs182009	168	1
mcs182011	168	1
mcs182020	168	1
mcs182025	168	1
mcs182093	168	1
mcs182094	168	1
mcs182095	168	1
mcs182120	168	1
mcs182140	168	1
mcs182144	168	1
mt1150319	168	1
mt5100628	168	1
mt5120605	168	1
ph1150840	168	1
siy187502	168	1
cs1150201	169	1
cs1150202	169	1
cs1150203	169	1
cs1150204	169	1
cs1150209	169	1
cs1150217	169	1
cs1150218	169	1
cs1150230	169	1
cs1150242	169	1
cs1150246	169	1
cs1150255	169	1
cs1150600	169	1
cs1160370	169	1
cs5110290	169	1
cs5120290	169	1
cs5130280	169	1
cs5150281	169	1
cs5160084	169	1
csz188012	169	1
csz188013	169	1
csz188014	169	1
csz188550	169	1
ee1150434	169	1
mcs182007	169	1
me1150354	169	1
me2150713	169	1
mt1160610	169	1
mt6140564	169	1
mt6150358	169	1
mt6150553	169	1
mt6150568	169	1
vst189751	169	1
cs1140227	170	1
cs1150208	170	1
cs1150213	170	1
cs1150218	170	1
cs1150234	170	1
cs1150238	170	1
cs1150239	170	1
cs1150265	170	1
cs1150291	170	1
cs1150435	170	1
cs1160087	170	1
cs1160311	170	1
cs1160312	170	1
cs1160317	170	1
cs1160321	170	1
cs1160328	170	1
cs1160329	170	1
cs1160332	170	1
cs1160333	170	1
cs1160343	170	1
cs1160359	170	1
cs1160385	170	1
cs1160395	170	1
cs1160412	170	1
cs5140435	170	1
cs5150102	170	1
cs5150286	170	1
cs5150292	170	1
cs5160388	170	1
cs5160389	170	1
cs5160391	170	1
cs5160393	170	1
cs5160394	170	1
cs5160433	170	1
cs5160789	170	1
ee1150452	170	1
ee3150521	170	1
ee3150761	170	1
ee3160506	170	1
me1150108	170	1
me1150686	170	1
me2140762	170	1
me2150740	170	1
ph1150813	170	1
tt1150917	170	1
anz188060	171	1
anz188380	171	1
anz188503	171	1
bb1150043	171	1
bb1160035	171	1
bsz188121	171	1
bsz188523	171	1
ch1150098	171	1
ch1150122	171	1
ch7150186	171	1
cs1110215	171	1
cs1140262	171	1
cs1150211	171	1
cs1150225	171	1
cs1150230	171	1
cs1160087	171	1
cs1160310	171	1
cs1160312	171	1
cs1160315	171	1
cs1160316	171	1
cs1160317	171	1
cs1160319	171	1
cs1160321	171	1
cs1160322	171	1
cs1160323	171	1
cs1160324	171	1
cs1160325	171	1
cs1160327	171	1
cs1160329	171	1
cs1160331	171	1
cs1160337	171	1
cs1160339	171	1
cs1160340	171	1
cs1160341	171	1
cs1160342	171	1
cs1160343	171	1
cs1160347	171	1
cs1160348	171	1
cs1160349	171	1
cs1160350	171	1
cs1160351	171	1
cs1160352	171	1
cs1160353	171	1
cs1160354	171	1
cs1160355	171	1
cs1160356	171	1
cs1160357	171	1
cs1160362	171	1
cs1160363	171	1
cs1160364	171	1
cs1160366	171	1
cs1160367	171	1
cs1160368	171	1
cs1160369	171	1
cs1160370	171	1
cs1160371	171	1
cs1160372	171	1
cs1160373	171	1
cs1160374	171	1
cs1160375	171	1
cs1160385	171	1
cs1160395	171	1
cs1160396	171	1
cs1160513	171	1
cs1160523	171	1
cs1160680	171	1
cs1160701	171	1
cs5100286	171	1
cs5120290	171	1
cs5140285	171	1
cs5150276	171	1
cs5150288	171	1
cs5160084	171	1
cs5160386	171	1
cs5160387	171	1
cs5160388	171	1
cs5160389	171	1
cs5160391	171	1
cs5160392	171	1
cs5160393	171	1
cs5160394	171	1
cs5160397	171	1
cs5160399	171	1
cs5160401	171	1
cs5160403	171	1
cs5160414	171	1
cs5160433	171	1
cs5160615	171	1
cs5160625	171	1
csz188010	171	1
csz188012	171	1
csz188013	171	1
csz188014	171	1
csz188550	171	1
ee1150428	171	1
ee1150641	171	1
ee1160446	171	1
eey187537	171	1
mcs172094	171	1
mcs172095	171	1
mcs182007	171	1
mcs182009	171	1
mcs182011	171	1
mcs182012	171	1
mcs182013	171	1
mcs182014	171	1
mcs182015	171	1
mcs182016	171	1
mcs182017	171	1
mcs182018	171	1
mcs182019	171	1
mcs182021	171	1
mcs182024	171	1
mcs182025	171	1
mcs182141	171	1
mcs182142	171	1
mcs182143	171	1
mcs182839	171	1
mt1140045	171	1
mt1160647	171	1
mt6160651	171	1
mt6160652	171	1
mt6160653	171	1
mt6160654	171	1
ph1150807	171	1
ph1150813	171	1
ph1160567	171	1
ph1160569	171	1
qiz188615	171	1
siy187502	171	1
vst189735	171	1
vst189751	171	1
vst189764	171	1
vst189765	171	1
vst189766	171	1
vst189771	171	1
ch1150122	172	1
ch7160167	172	1
cs1110215	172	1
cs1150201	172	1
cs1150202	172	1
cs1150203	172	1
cs1150204	172	1
cs1150206	172	1
cs1150209	172	1
cs1150210	172	1
cs1150212	172	1
cs1150217	172	1
cs1150235	172	1
cs1150244	172	1
cs1150246	172	1
cs1150251	172	1
cs1150254	172	1
cs1150255	172	1
cs1150257	172	1
cs1150258	172	1
cs1150262	172	1
cs1150265	172	1
cs1150266	172	1
cs1150267	172	1
cs1150424	172	1
cs1160326	172	1
cs1160377	172	1
cs5100286	172	1
cs5110290	172	1
cs5130286	172	1
cs5130288	172	1
cs5140276	172	1
cs5140284	172	1
cs5160386	172	1
cs5160398	172	1
cs5160400	172	1
cs5160401	172	1
cs5160404	172	1
csz188013	172	1
ee1150421	172	1
ee1150469	172	1
ee1150473	172	1
ee1150492	172	1
mcs172094	172	1
mcs172104	172	1
me2150755	172	1
mt1150375	172	1
mt1150592	172	1
mt6150358	172	1
mt6150563	172	1
mt6150565	172	1
mt6150568	172	1
ph1150786	172	1
ch1150134	173	1
ch1150143	173	1
cs1150244	173	1
cs1170342	173	1
cs5110277	173	1
cs5120277	173	1
cs5150280	173	1
cs5150282	173	1
cs5150286	173	1
cs5150295	173	1
ee1150493	173	1
ee1150691	173	1
eez188562	173	1
mas177092	173	1
met172571	173	1
met172813	173	1
ph1170823	173	1
pha182366	173	1
qiz188615	173	1
anz188001	174	1
anz188387	174	1
anz188503	174	1
csz168230	174	1
csz188295	174	1
eey187547	174	1
cs1150201	175	1
cs1150203	175	1
cs1150204	175	1
cs1150206	175	1
cs1150209	175	1
cs1150212	175	1
cs1150225	175	1
cs1150237	175	1
cs1150252	175	1
cs1150266	175	1
cs1150600	175	1
cs5150283	175	1
cs5150287	175	1
cs5160084	175	1
cs5160386	175	1
cs5160389	175	1
cs5160392	175	1
cs5160397	175	1
ee1150641	175	1
me2140762	175	1
mt6150554	175	1
mt6150566	175	1
ph1150807	175	1
ph1150808	175	1
ph1150838	175	1
anz188059	176	1
anz188061	176	1
ch1140786	176	1
cs1150240	176	1
cs1150245	176	1
cs1150247	176	1
cs1150251	176	1
cs1150253	176	1
cs1150254	176	1
cs1150341	176	1
cs1150424	176	1
cs1150460	176	1
cs1160335	176	1
cs5140281	176	1
cs5150285	176	1
cs5150295	176	1
cs5150459	176	1
cs5160625	176	1
ee1150427	176	1
ee1150476	176	1
eey187536	176	1
qiz188615	176	1
siy177546	176	1
anz157550	177	1
anz188063	177	1
anz188064	177	1
ch1150122	177	1
cs1150240	177	1
cs1150261	177	1
cs1150264	177	1
cs1150268	177	1
cs1160338	177	1
cs5150277	177	1
cs5150279	177	1
cs5150280	177	1
cs5150283	177	1
cs5150285	177	1
cs5150297	177	1
cs5160084	177	1
cs5160386	177	1
cs5160392	177	1
cs5160397	177	1
mcs172072	177	1
mcs172077	177	1
mcs172085	177	1
mcs172087	177	1
mcs172095	177	1
mcs172105	177	1
mcs172693	177	1
mcs172847	177	1
mt1150585	177	1
mt1150592	177	1
mt1150604	177	1
cs1150234	178	1
cs1150235	178	1
cs1150268	178	1
cs1160327	178	1
cs1160680	178	1
cs5150284	178	1
ce1160213	179	1
ch1160089	179	1
ch1160090	179	1
cs1120265	179	1
cs1140216	179	1
cs1150220	179	1
cs1150221	179	1
cs1160339	179	1
cs1160354	179	1
cs1160356	179	1
cs1160360	179	1
cs1170219	179	1
cs1170321	179	1
cs1170322	179	1
cs1170323	179	1
cs1170324	179	1
cs1170325	179	1
cs1170326	179	1
cs1170327	179	1
cs1170328	179	1
cs1170329	179	1
cs1170330	179	1
cs1170331	179	1
cs1170332	179	1
cs1170333	179	1
cs1170334	179	1
cs1170335	179	1
cs1170336	179	1
cs1170337	179	1
cs1170338	179	1
cs1170339	179	1
cs1170340	179	1
cs1170341	179	1
cs1170342	179	1
cs1170343	179	1
cs1170346	179	1
cs1170347	179	1
cs1170348	179	1
cs1170349	179	1
cs1170350	179	1
cs1170351	179	1
cs1170352	179	1
cs1170353	179	1
cs1170354	179	1
cs1170355	179	1
cs1170356	179	1
cs1170357	179	1
cs1170358	179	1
cs1170359	179	1
cs1170360	179	1
cs1170361	179	1
cs1170362	179	1
cs1170363	179	1
cs1170364	179	1
cs1170365	179	1
cs1170366	179	1
cs1170367	179	1
cs1170368	179	1
cs1170369	179	1
cs1170370	179	1
cs1170371	179	1
cs1170372	179	1
cs1170373	179	1
cs1170374	179	1
cs1170375	179	1
cs1170376	179	1
cs1170377	179	1
cs1170378	179	1
cs1170379	179	1
cs1170380	179	1
cs1170381	179	1
cs1170382	179	1
cs1170383	179	1
cs1170384	179	1
cs1170385	179	1
cs1170386	179	1
cs1170387	179	1
cs1170388	179	1
cs1170389	179	1
cs1170390	179	1
cs1170416	179	1
cs1170481	179	1
cs1170487	179	1
cs1170489	179	1
cs1170503	179	1
cs1170540	179	1
cs1170589	179	1
cs1170790	179	1
cs1170836	179	1
cs5120299	179	1
cs5140287	179	1
cs5150283	179	1
cs5150289	179	1
cs5160390	179	1
cs5160397	179	1
cs5160403	179	1
cs5170401	179	1
cs5170402	179	1
cs5170403	179	1
cs5170404	179	1
cs5170405	179	1
cs5170406	179	1
cs5170407	179	1
cs5170408	179	1
cs5170409	179	1
cs5170410	179	1
cs5170411	179	1
cs5170412	179	1
cs5170413	179	1
cs5170414	179	1
cs5170415	179	1
cs5170417	179	1
cs5170418	179	1
cs5170419	179	1
cs5170420	179	1
cs5170421	179	1
cs5170422	179	1
cs5170488	179	1
cs5170493	179	1
cs5170521	179	1
cs5170602	179	1
ee1150730	179	1
ee1160418	179	1
ee1160421	179	1
ee1160424	179	1
ee1160443	179	1
ee1160446	179	1
ee3160507	179	1
ee3160512	179	1
me2160756	179	1
mt1160647	179	1
mt6160648	179	1
mt6160653	179	1
mt6160654	179	1
ph1150822	179	1
bb1150059	180	1
bb1150063	180	1
bb1160052	180	1
ce1160213	180	1
ch1160074	180	1
ch1160089	180	1
ch1160095	180	1
ch1160097	180	1
ch1160098	180	1
ch1160099	180	1
ch7160156	180	1
cs5140277	180	1
cs5140279	180	1
cs5140297	180	1
cs5140462	180	1
ee1160469	180	1
ee1160470	180	1
ee1160471	180	1
ee1160472	180	1
ee1160479	180	1
ee1160499	180	1
ee1170437	180	1
ee1170445	180	1
ee1170465	180	1
ee1170468	180	1
ee1170472	180	1
ee1170482	180	1
ee1170484	180	1
ee1170536	180	1
ee1170544	180	1
ee3170010	180	1
ee3170149	180	1
ee3170518	180	1
ee3170546	180	1
ee3170548	180	1
ee3170551	180	1
me1170567	180	1
me1170609	180	1
me1170610	180	1
me2160752	180	1
me2170671	180	1
me2170674	180	1
mt1160622	180	1
mt1160637	180	1
mt1160638	180	1
mt6160655	180	1
mt6160656	180	1
mt6160657	180	1
mt6160658	180	1
mt6160660	180	1
ph1160565	180	1
tt1160864	180	1
tt1160868	180	1
tt1160870	180	1
tt1160880	180	1
tt1170961	180	1
cs1150244	181	1
cs1160328	181	1
ch1150077	182	1
cs1140216	182	1
cs1150215	182	1
cs1150224	182	1
cs1160314	182	1
cs1160327	182	1
cs1160332	182	1
cs1160333	182	1
cs1160335	182	1
cs1160336	182	1
cs1160337	182	1
cs1160680	182	1
cs5140285	182	1
cs5140435	182	1
cs5150279	182	1
cs5160615	182	1
ee1150494	182	1
ee1160545	182	1
ee1160556	182	1
me2150772	182	1
mt1160491	182	1
tt1150872	182	1
cs1150207	183	1
cs1150226	183	1
cs1150245	183	1
cs1160310	183	1
cs1160313	183	1
cs1160315	183	1
cs1160316	183	1
cs1160320	183	1
cs1160322	183	1
cs1160323	183	1
cs1160344	183	1
cs1160345	183	1
cs1160360	183	1
cs1160362	183	1
cs1160364	183	1
cs1160523	183	1
cs5140294	183	1
cs5160388	183	1
cs5160404	183	1
ee1150421	183	1
ee1160420	183	1
ee1160499	183	1
me2160772	183	1
mt6160646	183	1
mt6160651	183	1
tt1160838	183	1
tt1160845	183	1
tt1160849	183	1
tt1160927	183	1
cs1140227	184	1
cs5130301	184	1
cs5160399	184	1
cs5160400	184	1
cs5160401	184	1
cs5160402	184	1
cs5160403	184	1
ee3160220	184	1
ee3160493	184	1
me2140735	184	1
me2160764	184	1
me2160767	184	1
me2160771	184	1
me2160774	184	1
mt1160620	184	1
mt1160629	184	1
mt1160630	184	1
mt1160631	184	1
mt1160633	184	1
cs1150218	185	1
cs1150249	185	1
cs1150266	185	1
cs1160294	185	1
cs1160354	185	1
cs1160363	185	1
cs1160366	185	1
cs1160369	185	1
cs1160373	185	1
cs1160374	185	1
cs1160376	185	1
cs1160385	185	1
cs5130280	185	1
cs5150276	185	1
cs5160084	185	1
cs5160386	185	1
cs5160392	185	1
cs5160400	185	1
cs5160414	185	1
ee3150522	185	1
ee3160769	185	1
mt1150606	185	1
mt1160546	185	1
mt1160647	185	1
cs1160311	186	1
cs1160319	186	1
cs1160332	186	1
cs1160333	186	1
cs1160366	186	1
cs1160396	186	1
cs1160406	186	1
cs1160412	186	1
cs5150286	186	1
cs5170493	186	1
mt1170753	186	1
mt6170207	186	1
cs1160412	187	1
cs5150292	187	1
cs5150459	187	1
mcs172095	187	1
mcs172104	187	1
anz178419	188	1
bb1150029	188	1
ch1140786	188	1
ch1150071	188	1
ch1150077	188	1
cs1150218	188	1
cs1150245	188	1
cs1150247	188	1
cs1150251	188	1
cs1150253	188	1
cs1150254	188	1
cs1150291	188	1
cs5140278	188	1
cs5140279	188	1
cs5140296	188	1
cs5140297	188	1
cs5140736	188	1
cs5150286	188	1
cs5150459	188	1
ee1150466	188	1
mcs172079	188	1
mcs182025	188	1
me2160764	188	1
me2160767	188	1
me2160771	188	1
me2160774	188	1
ph1150793	188	1
cs1140227	189	1
cs5140276	189	1
cs5140278	189	1
cs5140285	189	1
cs5140288	189	1
cs5140296	189	1
cs5140736	189	1
cs1150218	190	1
cs1160385	190	1
cs5140288	190	1
cs5140296	190	1
cs5160084	190	1
csz168114	190	1
mt6150568	190	1
anz188380	191	1
cs5140276	191	1
cs5140278	191	1
cs5140296	191	1
mcs172080	191	1
mcs172094	191	1
mcs172104	191	1
cs1150258	192	1
cs5140296	192	1
cs5140736	192	1
cs5150284	192	1
cs5150285	192	1
cs5150296	192	1
mcs172072	192	1
mcs172079	192	1
mcs172082	192	1
mcs172084	192	1
mcs172085	192	1
mcs172089	192	1
mcs172092	192	1
mcs172094	192	1
mcs172095	192	1
mcs172103	192	1
mcs172104	192	1
mcs172678	192	1
mcs172693	192	1
mcs172851	192	1
mcs172858	192	1
mcs172873	192	1
cs5140277	193	1
cs5140279	193	1
cs5140289	193	1
cs5140297	193	1
cs5150102	193	1
cs5150286	193	1
cs5150287	193	1
mcs182143	193	1
crf182109	194	1
crf182110	194	1
crf182111	194	1
crf182112	194	1
crf182113	194	1
crf182114	194	1
crf182115	194	1
crf182116	194	1
crf182117	194	1
crf182118	194	1
crf182119	194	1
crf182526	194	1
crf182527	194	1
crf182528	194	1
crf182529	194	1
crf182530	194	1
crf182531	194	1
crf182532	194	1
crf182533	194	1
crf182534	194	1
crf182536	194	1
crf182537	194	1
crf182538	194	1
crf182539	194	1
crf182540	194	1
crf162862	195	1
crf172108	196	1
crf172110	196	1
crf172111	196	1
crf172112	196	1
crf172113	196	1
crf172572	196	1
crf172573	196	1
crf172574	196	1
crf172575	196	1
crf172576	196	1
crf172631	196	1
crf172662	196	1
crf172694	196	1
crf172695	196	1
crf172696	196	1
crf172697	196	1
crf172698	196	1
crf172699	196	1
crf172733	196	1
crf172734	196	1
crf172831	196	1
crf172875	196	1
crf172109	197	1
crf182109	198	1
crf182110	198	1
crf182111	198	1
crf182112	198	1
crf182113	198	1
crf182114	198	1
crf182115	198	1
crf182116	198	1
crf182117	198	1
crf182118	198	1
crf182119	198	1
crf182526	198	1
crf182527	198	1
crf182528	198	1
crf182529	198	1
crf182530	198	1
crf182531	198	1
crf182532	198	1
crf182533	198	1
crf182534	198	1
crf182536	198	1
crf182537	198	1
crf182538	198	1
crf182539	198	1
crf182540	198	1
ee3160505	198	1
vst189769	198	1
bsz188122	199	1
crf182529	199	1
crf182530	199	1
crf182532	199	1
crf182533	199	1
crf182537	199	1
crf182538	199	1
crf182539	199	1
crf182540	199	1
crz178638	199	1
crz188300	199	1
crz188302	199	1
crz188653	199	1
crz188654	199	1
vst189745	199	1
crf182113	200	1
crf182114	200	1
crf182115	200	1
crf182116	200	1
crf182117	200	1
crf182118	200	1
crf182119	200	1
crf182110	201	1
crf182111	201	1
crf182112	201	1
crf182528	201	1
crf182531	201	1
crf182536	201	1
crz188299	201	1
eee172246	201	1
eee182106	201	1
eee182392	201	1
eee182395	201	1
eee182396	201	1
eee182870	201	1
een182405	201	1
een182415	201	1
eez178564	201	1
eez188151	201	1
eez188377	201	1
jvl182331	201	1
jvl182333	201	1
jvl182338	201	1
jvl182339	201	1
jvl182340	201	1
jvl182344	201	1
vst189746	201	1
crf172109	202	1
crf182526	202	1
crf182527	202	1
crf182534	202	1
crz178641	202	1
crz188655	202	1
eez178564	202	1
jvl182336	202	1
phz188416	202	1
vst189746	202	1
crf182109	203	1
crf182110	203	1
crf182111	203	1
crf182112	203	1
crf182113	203	1
crf182114	203	1
crf182115	203	1
crf182116	203	1
crf182117	203	1
crf182118	203	1
crf182119	203	1
crf182526	203	1
crf182527	203	1
crf182528	203	1
crf182529	203	1
crf182530	203	1
crf182531	203	1
crf182532	203	1
crf182533	203	1
crf182534	203	1
crf182536	203	1
crf182537	203	1
crf182538	203	1
crf182539	203	1
crf182540	203	1
eez188377	203	1
vst189746	203	1
crf182526	204	1
crf182527	204	1
crz178641	204	1
crz188303	204	1
eez188139	204	1
eez188151	204	1
eez188570	204	1
vst189746	204	1
crf182113	205	1
crf182114	205	1
crf182115	205	1
crf182116	205	1
crf182117	205	1
crf182118	205	1
crf182119	205	1
crf182529	205	1
crf182530	205	1
crf182532	205	1
crf182533	205	1
crf182537	205	1
crf182538	205	1
crf182539	205	1
crf182540	205	1
crz188300	205	1
crz188654	205	1
ee3160490	205	1
eea182368	205	1
eea182377	205	1
cec182680	208	1
cec182681	208	1
cec182682	208	1
cec182683	208	1
cec182684	208	1
cec182685	208	1
cec182686	208	1
cec182687	208	1
cec182688	208	1
cec182689	208	1
cec182690	208	1
cec182691	208	1
cec182692	208	1
cec182693	208	1
cec182694	208	1
cec182695	208	1
cec182696	208	1
cec182697	208	1
cec182698	208	1
cec182699	208	1
cec182700	208	1
cec182701	208	1
cec182702	208	1
cec182703	208	1
cec182704	208	1
cec182705	208	1
cec182706	208	1
cec182707	208	1
cec182708	208	1
cec182709	208	1
ce1130323	209	1
ce1140243	209	1
ce1140303	209	1
ce1140345	209	1
ce1140346	209	1
ce1140360	209	1
ce1150302	209	1
ce1150307	209	1
ce1150310	209	1
ce1150315	209	1
ce1150316	209	1
ce1150318	209	1
ce1150321	209	1
ce1150324	209	1
ce1150340	209	1
ce1150343	209	1
ce1150360	209	1
ce1150362	209	1
ce1150363	209	1
ce1150364	209	1
ce1150366	209	1
ce1150371	209	1
ce1150372	209	1
ce1150386	209	1
ce1150392	209	1
ce1150395	209	1
ce1150399	209	1
ce1150400	209	1
ce1150404	209	1
ce1150405	209	1
ce1150313	210	1
ce1150326	210	1
ce1150330	210	1
ce1150337	210	1
ce1150338	210	1
ce1150346	210	1
ce1150349	210	1
ce1150350	210	1
ce1150353	210	1
ce1150370	210	1
ce1150377	210	1
ce1150378	210	1
ce1150382	210	1
ce1150388	210	1
ce1150398	210	1
cev162311	214	1
cev172429	214	1
cev172431	214	1
cev172436	214	1
cev172439	214	1
cev172716	214	1
ce1140381	217	1
ces162300	217	1
ces162301	217	1
ces162302	217	1
ces172047	217	1
ces172369	217	1
ces172378	217	1
ces172380	217	1
ces172512	217	1
ces172707	217	1
ces172709	217	1
ces172710	217	1
ces172711	217	1
ces172865	217	1
ces172867	217	1
ces172868	217	1
ces172874	217	1
cec172577	219	1
cec172578	219	1
cec172579	219	1
cec172580	219	1
cec172581	219	1
cec172582	219	1
cec172583	219	1
cec172585	219	1
cec172586	219	1
cec172587	219	1
cec172588	219	1
cec172589	219	1
cec172590	219	1
cec172591	219	1
cec172592	219	1
cec172593	219	1
cec172594	219	1
cec172595	219	1
cec172597	219	1
cec172599	219	1
cec172601	219	1
cec172619	219	1
cec172620	219	1
cec172632	219	1
cet172474	221	1
ce1140315	222	1
ce1140348	222	1
cet172046	222	1
cet172048	222	1
cet172383	222	1
cet172384	222	1
cet172388	222	1
cet172393	222	1
cet172396	222	1
cet172398	222	1
cet172399	222	1
cet172403	222	1
cet172404	222	1
cet172405	222	1
cet172407	222	1
cet172490	222	1
cet172531	222	1
cet172532	222	1
cet172713	222	1
ceg162338	223	1
ceg172340	223	1
ceg172344	223	1
ceg172352	223	1
ceg172353	223	1
ceg172510	223	1
ceg172869	223	1
ceg172870	223	1
ceu172888	224	1
ceu172411	225	1
ceu172412	225	1
ceu172413	225	1
ceu172415	225	1
ceu172416	225	1
ceu172417	225	1
ceu172418	225	1
ceu172420	225	1
ceu172421	225	1
ceu172422	225	1
ceu172423	225	1
ceu172425	225	1
ceu172426	225	1
ceu172428	225	1
ceu172861	225	1
ceu172862	225	1
ceu172889	225	1
cew172444	226	1
cew172445	226	1
cew172447	226	1
cew172448	226	1
cew172453	226	1
cew172718	226	1
cew172719	226	1
cew172732	226	1
cew172890	226	1
cew172892	226	1
cew172893	226	1
cew172894	226	1
cep162293	227	1
cep162295	227	1
cep162296	227	1
cep162298	227	1
cep162299	227	1
cep172354	227	1
cep172355	227	1
cep172356	227	1
cep172358	227	1
cep172359	227	1
cep172361	227	1
cep172705	227	1
cey167528	228	1
cey177535	228	1
bb1160064	229	1
bb1160065	229	1
bb1170001	229	1
bb1170002	229	1
bb1170003	229	1
bb1170004	229	1
bb1170005	229	1
bb1170006	229	1
bb1170007	229	1
bb1170008	229	1
bb1170009	229	1
bb1170011	229	1
bb1170014	229	1
bb1170015	229	1
bb1170016	229	1
bb1170017	229	1
bb1170018	229	1
bb1170022	229	1
bb1170023	229	1
bb1170024	229	1
bb1170025	229	1
bb1170028	229	1
bb1170029	229	1
bb1170030	229	1
bb1170031	229	1
bb1170032	229	1
bb1170033	229	1
bb1170035	229	1
bb1170037	229	1
bb1170038	229	1
bb1170039	229	1
bb1170040	229	1
bb1170041	229	1
bb1170042	229	1
bb1170045	229	1
bb1170047	229	1
bb5160014	229	1
bb5170051	229	1
bb5170054	229	1
bb5170055	229	1
bb5170056	229	1
bb5170058	229	1
bb5170059	229	1
bb5170062	229	1
bb5170064	229	1
bb5170065	229	1
ce1160256	229	1
ce1160279	229	1
ce1160286	229	1
ce1160287	229	1
ce1160303	229	1
ce1170071	229	1
ce1170072	229	1
ce1170073	229	1
ce1170074	229	1
ce1170075	229	1
ce1170076	229	1
ce1170077	229	1
ce1170079	229	1
ce1170080	229	1
ce1170081	229	1
ce1170082	229	1
ce1170083	229	1
ce1170084	229	1
ce1170085	229	1
ce1170088	229	1
ce1170089	229	1
ce1170090	229	1
ce1170091	229	1
ce1170092	229	1
ce1170094	229	1
ce1170095	229	1
ce1170096	229	1
ce1170097	229	1
ce1170098	229	1
ce1170099	229	1
ce1170100	229	1
ce1170101	229	1
ce1170102	229	1
ce1170103	229	1
ce1170104	229	1
ce1170105	229	1
ce1170106	229	1
ce1170108	229	1
ce1170109	229	1
ce1170110	229	1
ce1170111	229	1
ce1170112	229	1
ce1170113	229	1
ce1170115	229	1
ce1170116	229	1
ce1170117	229	1
ce1170118	229	1
ce1170119	229	1
ce1170121	229	1
ce1170122	229	1
ce1170123	229	1
ce1170124	229	1
ce1170125	229	1
ce1170126	229	1
ce1170127	229	1
ce1170128	229	1
ce1170129	229	1
ce1170130	229	1
ce1170131	229	1
ce1170132	229	1
ce1170133	229	1
ce1170134	229	1
ce1170135	229	1
ce1170136	229	1
ce1170137	229	1
ce1170138	229	1
ce1170139	229	1
ce1170140	229	1
ce1170141	229	1
ce1170142	229	1
ce1170143	229	1
ce1170144	229	1
ce1170145	229	1
ce1170146	229	1
ce1170147	229	1
ce1170148	229	1
ce1170150	229	1
ce1170151	229	1
ce1170152	229	1
ce1170153	229	1
ce1170154	229	1
ce1170155	229	1
ce1170156	229	1
ce1170157	229	1
ce1170159	229	1
ce1170160	229	1
ce1170162	229	1
ce1170163	229	1
ce1170164	229	1
ce1170165	229	1
ce1170166	229	1
ce1170167	229	1
ce1170168	229	1
ce1170169	229	1
ce1170170	229	1
ce1170171	229	1
ce1170172	229	1
ce1170173	229	1
ce1170174	229	1
ce1170175	229	1
ch1150002	229	1
ch1150076	229	1
ch1150082	229	1
ch1150100	229	1
ch1150103	229	1
ch1150125	229	1
ch1150126	229	1
ch1150128	229	1
ch1150132	229	1
ch1150135	229	1
ch1150136	229	1
ch1150137	229	1
ch1150138	229	1
ch1150140	229	1
ch1150143	229	1
ch1150385	229	1
ch1150945	229	1
ch1160142	229	1
ch1170114	229	1
ch1170120	229	1
ch1170161	229	1
ch1170200	229	1
ch1170201	229	1
ch1170235	229	1
ch1170297	229	1
ch1170311	229	1
ch1170894	229	1
ch7150153	229	1
ch7150154	229	1
ch7150165	229	1
ch7150171	229	1
ch7150176	229	1
ch7150189	229	1
ch7160176	229	1
ch7160191	229	1
ch7170275	229	1
ch7170281	229	1
cs1150216	229	1
cs1170321	229	1
cs1170322	229	1
cs1170323	229	1
cs1170324	229	1
cs1170325	229	1
cs1170326	229	1
cs1170327	229	1
cs1170328	229	1
cs1170329	229	1
cs1170330	229	1
cs1170331	229	1
cs1170332	229	1
cs1170333	229	1
cs1170337	229	1
cs1170340	229	1
cs1170342	229	1
cs1170343	229	1
cs1170344	229	1
cs1170347	229	1
cs1170348	229	1
cs1170349	229	1
cs1170351	229	1
cs1170353	229	1
cs1170354	229	1
cs1170355	229	1
cs1170356	229	1
cs1170357	229	1
cs1170358	229	1
cs1170359	229	1
cs1170360	229	1
cs1170361	229	1
cs1170362	229	1
cs1170363	229	1
cs1170364	229	1
cs1170365	229	1
cs1170366	229	1
cs1170367	229	1
cs1170368	229	1
cs1170369	229	1
cs1170370	229	1
cs1170371	229	1
cs1170372	229	1
cs1170373	229	1
cs1170374	229	1
cs1170375	229	1
cs1170376	229	1
cs1170377	229	1
cs1170378	229	1
cs1170379	229	1
cs1170380	229	1
cs1170381	229	1
cs1170382	229	1
cs1170383	229	1
cs1170384	229	1
cs1170385	229	1
cs1170386	229	1
cs1170387	229	1
cs1170388	229	1
cs1170389	229	1
cs1170390	229	1
cs1170416	229	1
cs1170481	229	1
cs1170489	229	1
cs1170540	229	1
cs1170836	229	1
cs5170401	229	1
cs5170403	229	1
cs5170404	229	1
cs5170406	229	1
cs5170407	229	1
cs5170408	229	1
cs5170409	229	1
cs5170410	229	1
cs5170411	229	1
cs5170412	229	1
cs5170413	229	1
cs5170415	229	1
cs5170417	229	1
cs5170419	229	1
cs5170420	229	1
cs5170421	229	1
cs5170422	229	1
cs5170488	229	1
cs5170493	229	1
cs5170521	229	1
ee1150111	229	1
ee1150427	229	1
ee1150429	229	1
ee1150434	229	1
ee1150442	229	1
ee1150443	229	1
ee1150445	229	1
ee1150452	229	1
ee1150476	229	1
ee1150477	229	1
ee1150482	229	1
ee1150489	229	1
ee1150490	229	1
ee1150492	229	1
ee1150493	229	1
ee1150504	229	1
ee1150691	229	1
ee1150730	229	1
ee1150735	229	1
ee1170431	229	1
ee1170432	229	1
ee1170433	229	1
ee1170436	229	1
ee1170437	229	1
ee1170440	229	1
ee1170441	229	1
ee1170445	229	1
ee1170452	229	1
ee1170453	229	1
ee1170454	229	1
ee1170455	229	1
ee1170456	229	1
ee1170458	229	1
ee1170459	229	1
ee1170464	229	1
ee1170465	229	1
ee1170482	229	1
ee1170484	229	1
ee1170491	229	1
ee1170504	229	1
ee1170536	229	1
ee1170544	229	1
ee1170565	229	1
ee3150522	229	1
ee3150761	229	1
ee3170010	229	1
ee3170019	229	1
ee3170149	229	1
ee3170221	229	1
ee3170245	229	1
ee3170511	229	1
ee3170512	229	1
ee3170513	229	1
ee3170514	229	1
ee3170515	229	1
ee3170516	229	1
ee3170517	229	1
ee3170518	229	1
ee3170519	229	1
ee3170522	229	1
ee3170523	229	1
ee3170524	229	1
ee3170525	229	1
ee3170526	229	1
ee3170527	229	1
ee3170528	229	1
ee3170529	229	1
ee3170531	229	1
ee3170532	229	1
ee3170533	229	1
ee3170534	229	1
ee3170535	229	1
ee3170537	229	1
ee3170538	229	1
ee3170539	229	1
ee3170541	229	1
ee3170542	229	1
ee3170543	229	1
ee3170545	229	1
ee3170546	229	1
ee3170547	229	1
ee3170548	229	1
ee3170549	229	1
ee3170550	229	1
ee3170551	229	1
ee3170552	229	1
ee3170553	229	1
ee3170554	229	1
ee3170555	229	1
ee3170654	229	1
ee3170872	229	1
me1130654	229	1
me1130729	229	1
me1140656	229	1
me1150101	229	1
me1150383	229	1
me1150628	229	1
me1150662	229	1
me1150664	229	1
me1150685	229	1
me1150686	229	1
me1160036	229	1
me1160073	229	1
me1160080	229	1
me1160224	229	1
me1160670	229	1
me1160671	229	1
me1160672	229	1
me1160673	229	1
me1160674	229	1
me1160676	229	1
me1160679	229	1
me1160681	229	1
me1160682	229	1
me1160684	229	1
me1160685	229	1
me1160686	229	1
me1160687	229	1
me1160688	229	1
me1160690	229	1
me1160691	229	1
me1160692	229	1
me1160693	229	1
me1160696	229	1
me1160697	229	1
me1160699	229	1
me1160700	229	1
me1160702	229	1
me1160704	229	1
me1160706	229	1
me1160707	229	1
me1160708	229	1
me1160709	229	1
me1160710	229	1
me1160711	229	1
me1160712	229	1
me1160714	229	1
me1160715	229	1
me1160716	229	1
me1160717	229	1
me1160718	229	1
me1160720	229	1
me1160721	229	1
me1160722	229	1
me1160723	229	1
me1160724	229	1
me1160725	229	1
me1160726	229	1
me1160727	229	1
me1160729	229	1
me1160730	229	1
me1160731	229	1
me1160732	229	1
me1160733	229	1
me1160734	229	1
me1160735	229	1
me1160736	229	1
me1160737	229	1
me1160747	229	1
me1160754	229	1
me1160758	229	1
me1160824	229	1
me1160829	229	1
me1160830	229	1
me1160901	229	1
me1170564	229	1
me1170570	229	1
me2150722	229	1
me2150724	229	1
me2150727	229	1
me2150728	229	1
me2150729	229	1
me2150733	229	1
me2160745	229	1
me2160749	229	1
me2160759	229	1
me2160761	229	1
me2160762	229	1
me2160763	229	1
me2160765	229	1
me2160768	229	1
me2160772	229	1
me2160779	229	1
me2160780	229	1
me2160782	229	1
me2160783	229	1
me2160786	229	1
me2160788	229	1
me2160791	229	1
me2160797	229	1
me2160799	229	1
me2160806	229	1
me2160807	229	1
me2170648	229	1
me2170679	229	1
mt1160582	229	1
mt1160639	229	1
mt1160640	229	1
mt1170213	229	1
mt1170287	229	1
mt1170520	229	1
mt1170530	229	1
mt1170722	229	1
mt1170723	229	1
mt1170724	229	1
mt1170729	229	1
mt1170731	229	1
mt1170732	229	1
mt1170733	229	1
mt1170744	229	1
mt1170745	229	1
mt1170746	229	1
mt1170747	229	1
mt1170748	229	1
mt1170749	229	1
mt1170750	229	1
mt1170752	229	1
mt1170753	229	1
mt1170754	229	1
mt1170755	229	1
mt1170756	229	1
mt1170772	229	1
mt6150564	229	1
mt6150567	229	1
mt6160649	229	1
mt6170207	229	1
mt6170250	229	1
mt6170499	229	1
mt6170771	229	1
mt6170774	229	1
mt6170775	229	1
mt6170777	229	1
mt6170778	229	1
mt6170779	229	1
mt6170780	229	1
mt6170781	229	1
mt6170782	229	1
mt6170787	229	1
mt6170855	229	1
ph1130827	229	1
ph1140800	229	1
ph1150799	229	1
ph1150810	229	1
ph1150812	229	1
ph1160547	229	1
ph1160557	229	1
ph1160563	229	1
ph1160564	229	1
ph1160584	229	1
ph1170802	229	1
ph1170807	229	1
ph1170808	229	1
ph1170812	229	1
ph1170813	229	1
ph1170815	229	1
ph1170816	229	1
ph1170818	229	1
ph1170821	229	1
ph1170823	229	1
ph1170824	229	1
ph1170829	229	1
ph1170830	229	1
ph1170834	229	1
ph1170838	229	1
ph1170843	229	1
ph1170845	229	1
ph1170858	229	1
ph1170859	229	1
tt1140932	229	1
tt1150852	229	1
tt1150913	229	1
tt1160821	229	1
tt1160872	229	1
tt1160893	229	1
tt1160909	229	1
tt1160914	229	1
tt1170873	229	1
tt1170901	229	1
tt1170902	229	1
tt1170909	229	1
tt1170969	229	1
ce1130348	230	1
ce1140243	230	1
ce1140360	230	1
ce1150302	230	1
ce1150306	230	1
ce1150313	230	1
ce1150366	230	1
ce1160200	230	1
ce1160201	230	1
ce1160202	230	1
ce1160203	230	1
ce1160204	230	1
ce1160205	230	1
ce1160206	230	1
ce1160207	230	1
ce1160208	230	1
ce1160209	230	1
ce1160210	230	1
ce1160211	230	1
ce1160212	230	1
ce1160214	230	1
ce1160215	230	1
ce1160216	230	1
ce1160217	230	1
ce1160218	230	1
ce1160219	230	1
ce1160221	230	1
ce1160222	230	1
ce1160223	230	1
ce1160225	230	1
ce1160226	230	1
ce1160227	230	1
ce1160228	230	1
ce1160229	230	1
ce1160230	230	1
ce1160231	230	1
ce1160232	230	1
ce1160234	230	1
ce1160235	230	1
ce1160236	230	1
ce1160237	230	1
ce1160238	230	1
ce1160239	230	1
ce1160241	230	1
ce1160242	230	1
ce1160243	230	1
ce1160244	230	1
ce1160245	230	1
ce1160247	230	1
ce1160248	230	1
ce1160249	230	1
ce1160251	230	1
ce1160252	230	1
ce1160253	230	1
ce1160254	230	1
ce1160255	230	1
ce1160257	230	1
ce1160258	230	1
ce1160259	230	1
ce1160260	230	1
ce1160261	230	1
ce1160262	230	1
ce1160263	230	1
ce1160264	230	1
ce1160265	230	1
ce1160266	230	1
ce1160269	230	1
ce1160270	230	1
ce1160271	230	1
ce1160272	230	1
ce1160273	230	1
ce1160274	230	1
ce1160275	230	1
ce1160276	230	1
ce1160277	230	1
ce1160278	230	1
ce1160280	230	1
ce1160281	230	1
ce1160282	230	1
ce1160283	230	1
ce1160284	230	1
ce1160285	230	1
ce1160288	230	1
ce1160289	230	1
ce1160290	230	1
ce1160291	230	1
ce1160292	230	1
ce1160293	230	1
ce1160295	230	1
ce1160296	230	1
ce1160297	230	1
ce1160298	230	1
ce1160299	230	1
ce1160302	230	1
ce1160304	230	1
ce1160305	230	1
ce1160856	230	1
ce1160213	231	1
ce1160226	231	1
ce1160228	231	1
ce1160243	231	1
ce1160256	231	1
ce1160279	231	1
ce1160287	231	1
ce1160303	231	1
ce1160856	231	1
ce1170071	231	1
ce1170072	231	1
ce1170073	231	1
ce1170074	231	1
ce1170075	231	1
ce1170076	231	1
ce1170077	231	1
ce1170079	231	1
ce1170080	231	1
ce1170081	231	1
ce1170082	231	1
ce1170083	231	1
ce1170084	231	1
ce1170085	231	1
ce1170088	231	1
ce1170090	231	1
ce1170091	231	1
ce1170092	231	1
ce1170094	231	1
ce1170095	231	1
ce1170096	231	1
ce1170097	231	1
ce1170098	231	1
ce1170099	231	1
ce1170100	231	1
ce1170101	231	1
ce1170102	231	1
ce1170103	231	1
ce1170104	231	1
ce1170105	231	1
ce1170106	231	1
ce1170108	231	1
ce1170109	231	1
ce1170110	231	1
ce1170111	231	1
ce1170112	231	1
ce1170113	231	1
ce1170115	231	1
ce1170116	231	1
ce1170117	231	1
ce1170118	231	1
ce1170119	231	1
ce1170121	231	1
ce1170122	231	1
ce1170123	231	1
ce1170124	231	1
ce1170125	231	1
ce1170126	231	1
ce1170127	231	1
ce1170128	231	1
ce1170129	231	1
ce1170130	231	1
ce1170131	231	1
ce1170132	231	1
ce1170133	231	1
ce1170134	231	1
ce1170135	231	1
ce1170136	231	1
ce1170137	231	1
ce1170138	231	1
ce1170139	231	1
ce1170140	231	1
ce1170141	231	1
ce1170142	231	1
ce1170143	231	1
ce1170144	231	1
ce1170145	231	1
ce1170146	231	1
ce1170147	231	1
ce1170148	231	1
ce1170150	231	1
ce1170151	231	1
ce1170152	231	1
ce1170153	231	1
ce1170154	231	1
ce1170155	231	1
ce1170156	231	1
ce1170157	231	1
ce1170159	231	1
ce1170160	231	1
ce1170162	231	1
ce1170163	231	1
ce1170164	231	1
ce1170165	231	1
ce1170166	231	1
ce1170167	231	1
ce1170168	231	1
ce1170169	231	1
ce1170170	231	1
ce1170171	231	1
ce1170172	231	1
ce1170173	231	1
ce1170175	231	1
ch1150109	231	1
ce1150316	232	1
ce1160256	232	1
ce1160279	232	1
ce1160286	232	1
ce1160287	232	1
ce1160303	232	1
ce1160304	232	1
ce1170071	232	1
ce1170072	232	1
ce1170073	232	1
ce1170074	232	1
ce1170075	232	1
ce1170076	232	1
ce1170077	232	1
ce1170079	232	1
ce1170080	232	1
ce1170081	232	1
ce1170082	232	1
ce1170083	232	1
ce1170084	232	1
ce1170085	232	1
ce1170088	232	1
ce1170089	232	1
ce1170090	232	1
ce1170091	232	1
ce1170092	232	1
ce1170094	232	1
ce1170095	232	1
ce1170096	232	1
ce1170097	232	1
ce1170098	232	1
ce1170099	232	1
ce1170100	232	1
ce1170101	232	1
ce1170102	232	1
ce1170103	232	1
ce1170104	232	1
ce1170105	232	1
ce1170106	232	1
ce1170108	232	1
ce1170109	232	1
ce1170110	232	1
ce1170111	232	1
ce1170112	232	1
ce1170113	232	1
ce1170115	232	1
ce1170116	232	1
ce1170117	232	1
ce1170118	232	1
ce1170119	232	1
ce1170121	232	1
ce1170122	232	1
ce1170123	232	1
ce1170124	232	1
ce1170125	232	1
ce1170126	232	1
ce1170127	232	1
ce1170128	232	1
ce1170129	232	1
ce1170130	232	1
ce1170131	232	1
ce1170132	232	1
ce1170133	232	1
ce1170134	232	1
ce1170135	232	1
ce1170136	232	1
ce1170137	232	1
ce1170138	232	1
ce1170139	232	1
ce1170140	232	1
ce1170141	232	1
ce1170142	232	1
ce1170143	232	1
ce1170144	232	1
ce1170145	232	1
ce1170146	232	1
ce1170147	232	1
ce1170148	232	1
ce1170150	232	1
ce1170151	232	1
ce1170152	232	1
ce1170153	232	1
ce1170154	232	1
ce1170155	232	1
ce1170156	232	1
ce1170157	232	1
ce1170159	232	1
ce1170160	232	1
ce1170162	232	1
ce1170163	232	1
ce1170164	232	1
ce1170165	232	1
ce1170166	232	1
ce1170167	232	1
ce1170168	232	1
ce1170169	232	1
ce1170170	232	1
ce1170171	232	1
ce1170172	232	1
ce1170173	232	1
ce1170174	232	1
ce1170175	232	1
me1150679	232	1
ce1130323	233	1
ce1130348	233	1
ce1140360	233	1
ce1150325	233	1
ce1150326	233	1
ce1150359	233	1
ce1150363	233	1
ce1160200	233	1
ce1160201	233	1
ce1160202	233	1
ce1160203	233	1
ce1160204	233	1
ce1160205	233	1
ce1160208	233	1
ce1160209	233	1
ce1160210	233	1
ce1160211	233	1
ce1160212	233	1
ce1160214	233	1
ce1160215	233	1
ce1160216	233	1
ce1160217	233	1
ce1160218	233	1
ce1160219	233	1
ce1160221	233	1
ce1160222	233	1
ce1160223	233	1
ce1160225	233	1
ce1160227	233	1
ce1160228	233	1
ce1160229	233	1
ce1160230	233	1
ce1160231	233	1
ce1160232	233	1
ce1160233	233	1
ce1160234	233	1
ce1160235	233	1
ce1160236	233	1
ce1160237	233	1
ce1160238	233	1
ce1160239	233	1
ce1160241	233	1
ce1160242	233	1
ce1160243	233	1
ce1160244	233	1
ce1160245	233	1
ce1160247	233	1
ce1160248	233	1
ce1160249	233	1
ce1160251	233	1
ce1160252	233	1
ce1160253	233	1
ce1160254	233	1
ce1160255	233	1
ce1160257	233	1
ce1160258	233	1
ce1160259	233	1
ce1160260	233	1
ce1160261	233	1
ce1160262	233	1
ce1160263	233	1
ce1160264	233	1
ce1160265	233	1
ce1160266	233	1
ce1160267	233	1
ce1160269	233	1
ce1160270	233	1
ce1160271	233	1
ce1160272	233	1
ce1160273	233	1
ce1160274	233	1
ce1160275	233	1
ce1160276	233	1
ce1160277	233	1
ce1160278	233	1
ce1160280	233	1
ce1160281	233	1
ce1160282	233	1
ce1160283	233	1
ce1160284	233	1
ce1160285	233	1
ce1160288	233	1
ce1160289	233	1
ce1160290	233	1
ce1160291	233	1
ce1160292	233	1
ce1160293	233	1
ce1160295	233	1
ce1160296	233	1
ce1160297	233	1
ce1160298	233	1
ce1160299	233	1
ce1160302	233	1
ce1160304	233	1
ce1160305	233	1
me1080528	233	1
ce1130384	234	1
ce1150316	234	1
ce1160256	234	1
ce1160279	234	1
ce1160287	234	1
ce1160303	234	1
ce1170071	234	1
ce1170072	234	1
ce1170073	234	1
ce1170074	234	1
ce1170075	234	1
ce1170076	234	1
ce1170077	234	1
ce1170079	234	1
ce1170080	234	1
ce1170081	234	1
ce1170082	234	1
ce1170083	234	1
ce1170085	234	1
ce1170088	234	1
ce1170089	234	1
ce1170090	234	1
ce1170091	234	1
ce1170092	234	1
ce1170094	234	1
ce1170095	234	1
ce1170096	234	1
ce1170097	234	1
ce1170098	234	1
ce1170099	234	1
ce1170100	234	1
ce1170101	234	1
ce1170102	234	1
ce1170103	234	1
ce1170104	234	1
ce1170105	234	1
ce1170106	234	1
ce1170108	234	1
ce1170109	234	1
ce1170110	234	1
ce1170111	234	1
ce1170112	234	1
ce1170113	234	1
ce1170115	234	1
ce1170116	234	1
ce1170117	234	1
ce1170118	234	1
ce1170119	234	1
ce1170121	234	1
ce1170123	234	1
ce1170124	234	1
ce1170125	234	1
ce1170126	234	1
ce1170127	234	1
ce1170128	234	1
ce1170129	234	1
ce1170130	234	1
ce1170131	234	1
ce1170132	234	1
ce1170133	234	1
ce1170134	234	1
ce1170135	234	1
ce1170136	234	1
ce1170137	234	1
ce1170138	234	1
ce1170139	234	1
ce1170140	234	1
ce1170141	234	1
ce1170142	234	1
ce1170143	234	1
ce1170144	234	1
ce1170145	234	1
ce1170146	234	1
ce1170147	234	1
ce1170148	234	1
ce1170150	234	1
ce1170151	234	1
ce1170152	234	1
ce1170153	234	1
ce1170154	234	1
ce1170155	234	1
ce1170156	234	1
ce1170157	234	1
ce1170159	234	1
ce1170160	234	1
ce1170162	234	1
ce1170163	234	1
ce1170164	234	1
ce1170165	234	1
ce1170166	234	1
ce1170167	234	1
ce1170168	234	1
ce1170169	234	1
ce1170170	234	1
ce1170171	234	1
ce1170172	234	1
ce1170173	234	1
ce1170174	234	1
ce1170175	234	1
ce1130384	235	1
ce1150316	235	1
ce1150327	235	1
ce1150336	235	1
ce1160262	235	1
ce1160273	235	1
ce1160277	235	1
ce1160279	235	1
ce1160287	235	1
ce1170071	235	1
ce1170072	235	1
ce1170073	235	1
ce1170074	235	1
ce1170075	235	1
ce1170076	235	1
ce1170077	235	1
ce1170079	235	1
ce1170080	235	1
ce1170081	235	1
ce1170082	235	1
ce1170083	235	1
ce1170085	235	1
ce1170088	235	1
ce1170089	235	1
ce1170091	235	1
ce1170092	235	1
ce1170094	235	1
ce1170095	235	1
ce1170096	235	1
ce1170097	235	1
ce1170098	235	1
ce1170099	235	1
ce1170100	235	1
ce1170101	235	1
ce1170102	235	1
ce1170103	235	1
ce1170104	235	1
ce1170105	235	1
ce1170106	235	1
ce1170108	235	1
ce1170109	235	1
ce1170110	235	1
ce1170111	235	1
ce1170112	235	1
ce1170113	235	1
ce1170115	235	1
ce1170116	235	1
ce1170117	235	1
ce1170118	235	1
ce1170119	235	1
ce1170121	235	1
ce1170122	235	1
ce1170124	235	1
ce1170125	235	1
ce1170126	235	1
ce1170127	235	1
ce1170128	235	1
ce1170129	235	1
ce1170130	235	1
ce1170131	235	1
ce1170132	235	1
ce1170133	235	1
ce1170134	235	1
ce1170135	235	1
ce1170136	235	1
ce1170137	235	1
ce1170138	235	1
ce1170139	235	1
ce1170140	235	1
ce1170141	235	1
ce1170142	235	1
ce1170143	235	1
ce1170144	235	1
ce1170145	235	1
ce1170146	235	1
ce1170147	235	1
ce1170148	235	1
ce1170150	235	1
ce1170151	235	1
ce1170152	235	1
ce1170153	235	1
ce1170154	235	1
ce1170155	235	1
ce1170156	235	1
ce1170157	235	1
ce1170159	235	1
ce1170160	235	1
ce1170162	235	1
ce1170163	235	1
ce1170164	235	1
ce1170165	235	1
ce1170166	235	1
ce1170167	235	1
ce1170168	235	1
ce1170169	235	1
ce1170170	235	1
ce1170171	235	1
ce1170172	235	1
ce1170173	235	1
ce1170174	235	1
ce1170175	235	1
ce1120975	236	1
ce1130323	236	1
ce1140315	236	1
ce1140346	236	1
ce1150307	236	1
ce1150308	236	1
ce1150312	236	1
ce1150314	236	1
ce1150317	236	1
ce1150320	236	1
ce1150324	236	1
ce1150325	236	1
ce1150326	236	1
ce1150327	236	1
ce1150328	236	1
ce1150329	236	1
ce1150331	236	1
ce1150332	236	1
ce1150336	236	1
ce1150337	236	1
ce1150340	236	1
ce1150346	236	1
ce1150347	236	1
ce1150352	236	1
ce1150359	236	1
ce1150360	236	1
ce1150362	236	1
ce1150365	236	1
ce1150367	236	1
ce1150368	236	1
ce1150370	236	1
ce1150374	236	1
ce1150376	236	1
ce1150377	236	1
ce1150378	236	1
ce1150386	236	1
ce1150399	236	1
ce1150401	236	1
ce1150403	236	1
ce1150404	236	1
ce1189004	236	1
ce1130348	237	1
ce1140243	237	1
ce1150315	237	1
ce1150326	237	1
ce1150363	237	1
ce1150377	237	1
ce1150382	237	1
ce1150386	237	1
ce1150388	237	1
ce1150389	237	1
ce1160200	237	1
ce1160201	237	1
ce1160202	237	1
ce1160203	237	1
ce1160204	237	1
ce1160205	237	1
ce1160206	237	1
ce1160207	237	1
ce1160208	237	1
ce1160209	237	1
ce1160210	237	1
ce1160211	237	1
ce1160212	237	1
ce1160214	237	1
ce1160216	237	1
ce1160217	237	1
ce1160218	237	1
ce1160219	237	1
ce1160221	237	1
ce1160222	237	1
ce1160225	237	1
ce1160226	237	1
ce1160227	237	1
ce1160228	237	1
ce1160229	237	1
ce1160230	237	1
ce1160231	237	1
ce1160232	237	1
ce1160233	237	1
ce1160234	237	1
ce1160235	237	1
ce1160236	237	1
ce1160237	237	1
ce1160238	237	1
ce1160239	237	1
ce1160241	237	1
ce1160242	237	1
ce1160243	237	1
ce1160244	237	1
ce1160245	237	1
ce1160247	237	1
ce1160248	237	1
ce1160249	237	1
ce1160251	237	1
ce1160252	237	1
ce1160253	237	1
ce1160254	237	1
ce1160255	237	1
ce1160257	237	1
ce1160258	237	1
ce1160259	237	1
ce1160260	237	1
ce1160261	237	1
ce1160262	237	1
ce1160263	237	1
ce1160264	237	1
ce1160265	237	1
ce1160266	237	1
ce1160267	237	1
ce1160269	237	1
ce1160270	237	1
ce1160271	237	1
ce1160272	237	1
ce1160273	237	1
ce1160274	237	1
ce1160275	237	1
ce1160276	237	1
ce1160277	237	1
ce1160278	237	1
ce1160280	237	1
ce1160281	237	1
ce1160282	237	1
ce1160283	237	1
ce1160284	237	1
ce1160285	237	1
ce1160288	237	1
ce1160289	237	1
ce1160290	237	1
ce1160291	237	1
ce1160292	237	1
ce1160293	237	1
ce1160295	237	1
ce1160296	237	1
ce1160297	237	1
ce1160298	237	1
ce1160299	237	1
ce1160302	237	1
ce1160305	237	1
ce1160856	237	1
ce1130348	238	1
ce1140243	238	1
ce1150306	238	1
ce1150313	238	1
ce1150318	238	1
ce1150378	238	1
ce1150397	238	1
ce1160200	238	1
ce1160201	238	1
ce1160202	238	1
ce1160203	238	1
ce1160204	238	1
ce1160205	238	1
ce1160206	238	1
ce1160207	238	1
ce1160208	238	1
ce1160209	238	1
ce1160210	238	1
ce1160211	238	1
ce1160212	238	1
ce1160214	238	1
ce1160215	238	1
ce1160216	238	1
ce1160217	238	1
ce1160218	238	1
ce1160219	238	1
ce1160221	238	1
ce1160222	238	1
ce1160223	238	1
ce1160225	238	1
ce1160226	238	1
ce1160227	238	1
ce1160228	238	1
ce1160229	238	1
ce1160230	238	1
ce1160231	238	1
ce1160232	238	1
ce1160233	238	1
ce1160234	238	1
ce1160235	238	1
ce1160236	238	1
ce1160237	238	1
ce1160238	238	1
ce1160239	238	1
ce1160241	238	1
ce1160242	238	1
ce1160243	238	1
ce1160244	238	1
ce1160245	238	1
ce1160247	238	1
ce1160248	238	1
ce1160249	238	1
ce1160251	238	1
ce1160252	238	1
ce1160253	238	1
ce1160254	238	1
ce1160255	238	1
ce1160257	238	1
ce1160258	238	1
ce1160259	238	1
ce1160260	238	1
ce1160261	238	1
ce1160263	238	1
ce1160264	238	1
ce1160265	238	1
ce1160266	238	1
ce1160267	238	1
ce1160269	238	1
ce1160270	238	1
ce1160271	238	1
ce1160272	238	1
ce1160274	238	1
ce1160275	238	1
ce1160276	238	1
ce1160278	238	1
ce1160280	238	1
ce1160281	238	1
ce1160282	238	1
ce1160283	238	1
ce1160284	238	1
ce1160285	238	1
ce1160288	238	1
ce1160289	238	1
ce1160290	238	1
ce1160291	238	1
ce1160292	238	1
ce1160293	238	1
ce1160295	238	1
ce1160296	238	1
ce1160297	238	1
ce1160298	238	1
ce1160299	238	1
ce1160302	238	1
ce1160856	238	1
ce1120975	239	1
ce1130348	239	1
ce1140243	239	1
ce1140303	239	1
ce1140345	239	1
ce1150302	239	1
ce1150303	239	1
ce1150304	239	1
ce1150305	239	1
ce1150307	239	1
ce1150309	239	1
ce1150310	239	1
ce1150311	239	1
ce1150315	239	1
ce1150316	239	1
ce1150317	239	1
ce1150318	239	1
ce1150321	239	1
ce1150326	239	1
ce1150328	239	1
ce1150351	239	1
ce1150361	239	1
ce1150365	239	1
ce1150367	239	1
ce1150370	239	1
ce1150371	239	1
ce1150377	239	1
ce1150381	239	1
ce1150382	239	1
ce1150384	239	1
ce1150386	239	1
ce1150387	239	1
ce1150388	239	1
ce1150389	239	1
ce1160219	239	1
ce1160251	239	1
ce1160253	239	1
ce1160281	239	1
ce1160282	239	1
ce1160286	239	1
ce1160288	239	1
ce1160291	239	1
ce1160298	239	1
ce1130323	240	1
ce1140243	240	1
ce1140360	240	1
ce1150307	240	1
ce1150309	240	1
ce1150310	240	1
ce1150315	240	1
ce1150317	240	1
ce1150318	240	1
ce1150324	240	1
ce1150329	240	1
ce1150333	240	1
ce1150334	240	1
ce1150335	240	1
ce1150337	240	1
ce1150343	240	1
ce1150344	240	1
ce1150348	240	1
ce1150356	240	1
ce1150357	240	1
ce1150363	240	1
ce1150367	240	1
ce1150372	240	1
ce1150374	240	1
ce1150377	240	1
ce1150378	240	1
ce1150381	240	1
ce1150382	240	1
ce1150386	240	1
ce1150388	240	1
ce1150389	240	1
ce1150392	240	1
ce1150393	240	1
ce1150394	240	1
ce1150400	240	1
ce1150401	240	1
ce1150402	240	1
ce1150405	240	1
ce1160262	240	1
ce1160291	240	1
ce1140360	241	1
ce1150328	241	1
ce1150332	241	1
ce1150333	241	1
ce1150337	241	1
ce1150340	241	1
ce1150343	241	1
ce1150346	241	1
ce1150357	241	1
ce1150359	241	1
ce1150360	241	1
ce1150361	241	1
ce1150363	241	1
ce1150364	241	1
ce1150365	241	1
ce1150366	241	1
ce1150367	241	1
ce1150368	241	1
ce1150371	241	1
ce1150372	241	1
ce1150382	241	1
ce1150393	241	1
ce1160225	241	1
ce1160227	241	1
ce1160229	241	1
ce1160231	241	1
ce1160232	241	1
ce1160234	241	1
ce1160235	241	1
ce1160238	241	1
ce1160273	241	1
ce1160277	241	1
ce1160284	241	1
ce1160286	241	1
ce1160289	241	1
ce1160290	241	1
ce1160292	241	1
ce1160293	241	1
ce1160297	241	1
ce1160298	241	1
ce1160299	241	1
ce1160302	241	1
ce1150308	242	1
ce1150312	242	1
ce1150314	242	1
ce1150327	242	1
ce1150329	242	1
ce1150330	242	1
ce1150331	242	1
ce1150332	242	1
ce1150334	242	1
ce1150337	242	1
ce1150340	242	1
ce1150344	242	1
ce1150352	242	1
ce1150353	242	1
ce1150399	242	1
ce1150400	242	1
ce1150401	242	1
ce1150402	242	1
ce1150403	242	1
ce1160201	242	1
ce1160206	242	1
ce1160208	242	1
ce1160209	242	1
ce1160210	242	1
ce1160211	242	1
ce1160212	242	1
ce1160214	242	1
ce1160221	242	1
ce1160235	242	1
ce1160241	242	1
ce1160244	242	1
ce1160248	242	1
ce1160255	242	1
ce1160258	242	1
ce1160259	242	1
ce1160260	242	1
ce1160261	242	1
ce1160266	242	1
ce1160269	242	1
ce1160270	242	1
ce1160271	242	1
ce1160272	242	1
ce1160274	242	1
ce1160278	242	1
ce1160283	242	1
ce1160284	242	1
ce1160285	242	1
ce1160289	242	1
ce1160299	242	1
ce1189004	242	1
ce1120975	243	1
ce1130386	243	1
ce1140345	243	1
ce1150302	243	1
ce1150328	243	1
ce1150334	243	1
ce1150343	243	1
ce1150346	243	1
ce1150348	243	1
ce1150352	243	1
ce1150355	243	1
ce1150357	243	1
ce1150361	243	1
ce1150363	243	1
ce1150364	243	1
ce1150367	243	1
ce1150368	243	1
ce1150371	243	1
ce1150372	243	1
ce1150377	243	1
ce1150382	243	1
ce1150384	243	1
ce1150387	243	1
ce1150388	243	1
ce1150392	243	1
ce1150393	243	1
ce1150394	243	1
ce1150398	243	1
ce1150400	243	1
ce1150401	243	1
ce1150403	243	1
ce1150405	243	1
ceg182148	244	1
ceg182154	244	1
ceg182156	244	1
ceg182157	244	1
ceg182628	244	1
ceg182629	244	1
ceg182630	244	1
ceg182631	244	1
ceg182632	244	1
ceg182633	244	1
cez188031	244	1
cez188391	244	1
ce1189004	245	1
ceg182148	245	1
ceg182154	245	1
ceg182156	245	1
ceg182157	245	1
ceg182628	245	1
ceg182629	245	1
ceg182630	245	1
ceg182631	245	1
ceg182632	245	1
ceg182633	245	1
cez188028	245	1
cez188029	245	1
ch1150129	245	1
ce1150312	246	1
ce1150337	246	1
ce1150343	246	1
ceg182148	246	1
ceg182154	246	1
ceg182156	246	1
ceg182157	246	1
ceg182628	246	1
ceg182629	246	1
ceg182630	246	1
ceg182631	246	1
ceg182632	246	1
ceg182633	246	1
cez188391	246	1
cez188397	246	1
ceg182148	247	1
ceg182154	247	1
ceg182156	247	1
ceg182157	247	1
ceg182628	247	1
ceg182629	247	1
ceg182630	247	1
ceg182631	247	1
ceg182632	247	1
ceg182633	247	1
cez188390	247	1
cez188391	247	1
vst189739	247	1
ce1140345	248	1
ce1150321	248	1
ceu182134	248	1
ceu182135	248	1
ceu182136	248	1
ceu182210	248	1
ceu182211	248	1
ceu182215	248	1
ceu182216	248	1
ceu182659	248	1
ceu182660	248	1
ceu182661	248	1
ceu182662	248	1
ceu182664	248	1
vst189739	248	1
ceu182134	249	1
ceu182136	249	1
ceu182210	249	1
ceu182211	249	1
ceu182215	249	1
ceu182216	249	1
ceu182659	249	1
ceu182660	249	1
ceu182661	249	1
ceu182662	249	1
ceu182664	249	1
cez188390	249	1
vst189732	249	1
ceu172411	250	1
ceu172420	250	1
ceu172428	250	1
ceu182134	250	1
ceu182136	250	1
ceu182210	250	1
ceu182211	250	1
ceu182215	250	1
ceu182216	250	1
ceu182659	250	1
ceu182660	250	1
ceu182661	250	1
ceu182662	250	1
ceu182664	250	1
vst189732	250	1
vst189739	250	1
ceu182135	251	1
ceu182136	251	1
ceu182210	251	1
ceu182211	251	1
ceu182215	251	1
ceu182216	251	1
ceu182659	251	1
ceu182660	251	1
ceu182661	251	1
ceu182662	251	1
ceu182664	251	1
ph1150795	251	1
vst189732	251	1
ce1140243	252	1
ce1150302	252	1
ce1150306	252	1
ce1150309	252	1
ce1150310	252	1
ce1150315	252	1
ce1150318	252	1
ce1150357	252	1
ce1150361	252	1
ce1150392	252	1
ce1150393	252	1
ce1160200	252	1
ce1160202	252	1
ce1160203	252	1
ce1160204	252	1
ce1160205	252	1
ce1160206	252	1
ce1160209	252	1
ce1160212	252	1
ce1160221	252	1
cev172475	252	1
cev182085	252	1
cev182137	252	1
cev182138	252	1
cev182139	252	1
cev182219	252	1
cev182221	252	1
cev182222	252	1
cev182223	252	1
cev182226	252	1
cev182227	252	1
cev182228	252	1
cev182230	252	1
cev182231	252	1
cev182232	252	1
cev182666	252	1
cev182667	252	1
cev182668	252	1
cez188403	252	1
cez188406	252	1
ce1130323	253	1
ce1140346	253	1
ce1150335	253	1
ce1150337	253	1
ce1150357	253	1
cev182085	253	1
cev182137	253	1
cev182138	253	1
cev182139	253	1
cev182219	253	1
cev182221	253	1
cev182222	253	1
cev182223	253	1
cev182226	253	1
cev182227	253	1
cev182228	253	1
cev182230	253	1
cev182231	253	1
cev182232	253	1
cev182666	253	1
cev182667	253	1
cev182668	253	1
cez188027	253	1
che182864	253	1
ce1120975	254	1
ce1150302	254	1
ce1150303	254	1
ce1150304	254	1
ce1150305	254	1
ce1150306	254	1
ce1150307	254	1
ce1150309	254	1
ce1150310	254	1
ce1150311	254	1
ce1150313	254	1
ce1150327	254	1
ce1150343	254	1
ce1150348	254	1
ce1150351	254	1
ce1150352	254	1
ce1150353	254	1
ce1150366	254	1
ce1150394	254	1
ce1150399	254	1
ce1150404	254	1
cev182085	254	1
cev182137	254	1
cev182138	254	1
cev182139	254	1
cev182219	254	1
cev182221	254	1
cev182222	254	1
cev182223	254	1
cev182226	254	1
cev182227	254	1
cev182228	254	1
cev182230	254	1
cev182231	254	1
cev182232	254	1
cev182666	254	1
cev182667	254	1
cev182668	254	1
cez188396	254	1
cez188406	254	1
vst189741	254	1
ce1150338	255	1
cev182085	255	1
cev182137	255	1
cev182138	255	1
cev182139	255	1
cev182222	255	1
cev182230	255	1
cez188388	255	1
cez188389	255	1
cez188396	255	1
ce1150303	256	1
ce1150304	256	1
ce1150307	256	1
ce1150309	256	1
ce1150310	256	1
ce1150311	256	1
ce1150326	256	1
ce1150329	256	1
ce1150346	256	1
ce1150348	256	1
ce1150351	256	1
ce1150361	256	1
ce1150378	256	1
ce1160218	256	1
ce1160222	256	1
ce1160226	256	1
ce1160856	256	1
cev182085	256	1
cev182137	256	1
cev182138	256	1
cev182139	256	1
cev182219	256	1
cev182221	256	1
cev182223	256	1
cev182226	256	1
cev182227	256	1
cev182228	256	1
cev182230	256	1
cev182231	256	1
cev182232	256	1
cev182666	256	1
cev182667	256	1
cev182668	256	1
cez188399	256	1
mey187515	256	1
mez188586	256	1
ce1150405	257	1
cew182083	257	1
cew182084	257	1
cew182233	257	1
cew182235	257	1
cew182238	257	1
cew182669	257	1
cew182671	257	1
cew182673	257	1
cew182674	257	1
cew182675	257	1
cew182676	257	1
cez188408	257	1
vst189734	257	1
vst189741	257	1
cew182083	258	1
cew182084	258	1
cew182233	258	1
cew182235	258	1
cew182238	258	1
cew182669	258	1
cew182671	258	1
cew182673	258	1
cew182674	258	1
cew182675	258	1
cew182676	258	1
cez188408	258	1
cep172459	259	1
cep172461	259	1
cep172462	259	1
cep172464	259	1
cep182086	259	1
cep182127	259	1
cep182158	259	1
cep182160	259	1
cep182162	259	1
cep182640	259	1
ce1130386	260	1
ce1140345	260	1
ce1140346	260	1
ce1150309	260	1
ce1150331	260	1
ce1150364	260	1
ce1150368	260	1
ce1150370	260	1
ce1150371	260	1
ce1150372	260	1
ce1150394	260	1
ce1160201	260	1
ce1160216	260	1
ce1160217	260	1
ce1160296	260	1
cep172463	260	1
cez188033	260	1
cs1140227	260	1
trz188281	260	1
ce1150322	261	1
ce1150342	261	1
ces182087	261	1
ces182096	261	1
ces182097	261	1
ces182098	261	1
ces182173	261	1
ces182179	261	1
ces182181	261	1
ces182182	261	1
ces182183	261	1
ces182641	261	1
ces182643	261	1
ces182644	261	1
ces182645	261	1
ces182646	261	1
ces182648	261	1
ces182649	261	1
ces182650	261	1
cey187546	261	1
ce1150322	262	1
ce1150333	262	1
ce1150335	262	1
ce1150342	262	1
ce1189004	262	1
ces182087	262	1
ces182096	262	1
ces182097	262	1
ces182098	262	1
ces182173	262	1
ces182179	262	1
ces182181	262	1
ces182182	262	1
ces182183	262	1
ces182641	262	1
ces182643	262	1
ces182644	262	1
ces182645	262	1
ces182646	262	1
ces182648	262	1
ces182649	262	1
ces182650	262	1
ce1150322	263	1
ce1150333	263	1
ce1150335	263	1
ce1150342	263	1
ce1150356	263	1
ces172466	263	1
ces172467	263	1
ces172468	263	1
ces172469	263	1
ces172470	263	1
ces172471	263	1
ces172472	263	1
ces182087	263	1
ces182096	263	1
ces182097	263	1
ces182098	263	1
ces182128	263	1
ces182129	263	1
ces182130	263	1
ces182131	263	1
ces182132	263	1
ces182133	263	1
ces182173	263	1
ces182181	263	1
ces182182	263	1
ces182183	263	1
ces182641	263	1
ces182643	263	1
ces182644	263	1
ces182645	263	1
ces182646	263	1
ces182648	263	1
ces182649	263	1
ces182650	263	1
cez188401	263	1
vst189739	263	1
ce1150320	264	1
cec182680	264	1
cec182681	264	1
cec182682	264	1
cec182683	264	1
cec182684	264	1
cec182685	264	1
cec182686	264	1
cec182687	264	1
cec182688	264	1
cec182689	264	1
cec182690	264	1
cec182691	264	1
cec182692	264	1
cec182693	264	1
cec182694	264	1
cec182695	264	1
cec182696	264	1
cec182697	264	1
cec182698	264	1
cec182699	264	1
cec182700	264	1
cec182701	264	1
cec182702	264	1
cec182703	264	1
cec182704	264	1
cec182705	264	1
cec182706	264	1
cec182707	264	1
cec182708	264	1
cec182709	264	1
cet182186	264	1
cet182187	264	1
cet182197	264	1
cet182204	264	1
cet182651	264	1
cet182652	264	1
cet182653	264	1
cet182654	264	1
cet182656	264	1
ce1150320	265	1
ce1150369	265	1
ce1160213	265	1
cec182680	265	1
cec182681	265	1
cec182682	265	1
cec182683	265	1
cec182684	265	1
cec182685	265	1
cec182686	265	1
cec182687	265	1
cec182688	265	1
cec182689	265	1
cec182690	265	1
cec182691	265	1
cec182692	265	1
cec182693	265	1
cec182694	265	1
cec182695	265	1
cec182696	265	1
cec182697	265	1
cec182698	265	1
cec182699	265	1
cec182700	265	1
cec182701	265	1
cec182702	265	1
cec182703	265	1
cec182704	265	1
cec182705	265	1
cec182706	265	1
cec182707	265	1
cec182708	265	1
cec182709	265	1
cet182186	265	1
cet182187	265	1
cet182189	265	1
cet182191	265	1
cet182192	265	1
cet182197	265	1
cet182198	265	1
cet182201	265	1
cet182204	265	1
cet182651	265	1
cet182652	265	1
cet182653	265	1
cet182654	265	1
cet182656	265	1
cet182658	265	1
cez188050	265	1
cec182680	266	1
cec182681	266	1
cec182682	266	1
cec182683	266	1
cec182684	266	1
cec182685	266	1
cec182686	266	1
cec182687	266	1
cec182688	266	1
cec182689	266	1
cec182690	266	1
cec182691	266	1
cec182692	266	1
cec182693	266	1
cec182694	266	1
cec182695	266	1
cec182696	266	1
cec182697	266	1
cec182698	266	1
cec182699	266	1
cec182700	266	1
cec182701	266	1
cec182702	266	1
cec182703	266	1
cec182704	266	1
cec182705	266	1
cec182706	266	1
cec182707	266	1
cec182708	266	1
cec182709	266	1
cet172473	266	1
cet172474	266	1
cet182186	266	1
cet182187	266	1
cet182189	266	1
cet182191	266	1
cet182192	266	1
cet182197	266	1
cet182198	266	1
cet182201	266	1
cet182204	266	1
cet182651	266	1
cet182652	266	1
cet182653	266	1
cet182654	266	1
cet182656	266	1
cet182658	266	1
cet172048	267	1
cet172403	267	1
cet172404	267	1
cet172531	267	1
cey187546	267	1
cew182083	269	1
cew182084	269	1
cew182233	269	1
cew182235	269	1
cew182238	269	1
cew182669	269	1
cew182671	269	1
cew182673	269	1
cew182674	269	1
cew182675	269	1
cew182676	269	1
cez188038	269	1
cez188388	269	1
cez188392	269	1
vst189734	269	1
vst189741	269	1
cew172447	270	1
cew172453	270	1
cew172890	270	1
cew172892	270	1
cew172893	270	1
cew182083	270	1
cew182084	270	1
qiz188545	270	1
cew172444	271	1
cew172445	271	1
cew172719	271	1
cew182233	271	1
cew182235	271	1
cew182238	271	1
cew182671	271	1
cew182673	271	1
cew182674	271	1
cew182675	271	1
cew182676	271	1
cez188375	271	1
cez188392	271	1
qiz188545	271	1
srz188383	271	1
trz188281	271	1
vst189734	271	1
vst189741	271	1
cep182086	272	1
cep182127	272	1
cez188042	272	1
cez188394	272	1
cez188402	272	1
trz168321	272	1
cep172459	273	1
cep172461	273	1
cep172463	273	1
cez188034	273	1
cez188035	273	1
ce1120975	274	1
ce1130323	274	1
ce1150312	274	1
ce1150313	274	1
ce1150327	274	1
ce1150359	274	1
ce1150360	274	1
ce1150364	274	1
ce1150366	274	1
ce1150368	274	1
ce1150374	274	1
ce1160239	274	1
cep182086	274	1
cep182124	274	1
cep182125	274	1
cep182126	274	1
cep182127	274	1
cep182158	274	1
cep182160	274	1
cep182162	274	1
cep182640	274	1
cez188042	274	1
trz188280	274	1
cep172459	275	1
cep172461	275	1
cep172463	275	1
cep182086	275	1
cez188043	275	1
cez188394	275	1
cep182086	276	1
cep182124	276	1
cep182125	276	1
cep182126	276	1
cep182127	276	1
cep182158	276	1
cep182160	276	1
cep182162	276	1
cep182640	276	1
cez188033	276	1
cez188036	276	1
me1150671	276	1
ce1140303	277	1
ce1140381	277	1
ce1150322	277	1
ce1150342	277	1
ce1150369	277	1
ces182087	277	1
ces182129	277	1
ces182173	277	1
ces182179	277	1
ces182181	277	1
ces182182	277	1
ces182183	277	1
ces182641	277	1
ces182643	277	1
ces182644	277	1
ces182645	277	1
ces182646	277	1
ces182648	277	1
ces182649	277	1
ces182650	277	1
ces182096	278	1
ces182097	278	1
ces182098	278	1
cez188393	278	1
cez188405	278	1
cez188407	278	1
ce1150322	279	1
ce1150342	279	1
ces172466	279	1
ces172467	279	1
ces172468	279	1
ces172469	279	1
ces172470	279	1
ces172471	279	1
ces172472	279	1
ces172512	279	1
ces182128	279	1
ces182130	279	1
ces182131	279	1
ces182132	279	1
ces182133	279	1
cey177535	279	1
cez188395	279	1
cez188401	279	1
ce1140381	280	1
ce1150322	280	1
ce1150342	280	1
ces172047	280	1
ces172467	280	1
cez188401	280	1
cec172578	281	1
cet172046	281	1
cet172048	281	1
cet172531	281	1
cet172532	281	1
cet182189	281	1
cet182658	281	1
cey187546	281	1
ce1140315	282	1
ce1140348	282	1
ce1150320	282	1
ce1150382	282	1
cet172388	282	1
cet172713	282	1
cet182191	282	1
cet182204	282	1
cet182652	282	1
cev182222	282	1
ce1160242	283	1
ce1160245	283	1
ce1189004	283	1
cec172581	283	1
cec172586	283	1
cec172587	283	1
cec172590	283	1
cec172632	283	1
cep172459	283	1
cep172461	283	1
cep172462	283	1
cep172463	283	1
cep172464	283	1
cet172384	283	1
cet172388	283	1
cet172393	283	1
cet172398	283	1
cet172399	283	1
cet172403	283	1
cet172404	283	1
cet172405	283	1
cet172490	283	1
cet172532	283	1
cet182186	283	1
cet182187	283	1
cet182197	283	1
cet182198	283	1
cet182651	283	1
cet182653	283	1
cey187546	283	1
ce1140360	284	1
ce1160226	284	1
ce1160256	284	1
ce1160279	284	1
ce1160287	284	1
ce1160303	284	1
ce1160856	284	1
ce1170071	284	1
ce1170072	284	1
ce1170073	284	1
ce1170074	284	1
ce1170075	284	1
ce1170076	284	1
ce1170077	284	1
ce1170079	284	1
ce1170081	284	1
ce1170082	284	1
ce1170083	284	1
ce1170084	284	1
ce1170085	284	1
ce1170088	284	1
ce1170089	284	1
ce1170090	284	1
ce1170091	284	1
ce1170092	284	1
ce1170094	284	1
ce1170095	284	1
ce1170096	284	1
ce1170097	284	1
ce1170098	284	1
ce1170099	284	1
ce1170100	284	1
ce1170101	284	1
ce1170102	284	1
ce1170103	284	1
ce1170104	284	1
ce1170105	284	1
ce1170106	284	1
ce1170108	284	1
ce1170109	284	1
ce1170110	284	1
ce1170111	284	1
ce1170112	284	1
ce1170113	284	1
ce1170115	284	1
ce1170116	284	1
ce1170117	284	1
ce1170118	284	1
ce1170119	284	1
ce1170121	284	1
ce1170122	284	1
ce1170123	284	1
ce1170124	284	1
ce1170125	284	1
ce1170126	284	1
ce1170127	284	1
ce1170128	284	1
ce1170129	284	1
ce1170130	284	1
ce1170131	284	1
ce1170132	284	1
ce1170133	284	1
ce1170134	284	1
ce1170135	284	1
ce1170136	284	1
ce1170137	284	1
ce1170138	284	1
ce1170139	284	1
ce1170140	284	1
ce1170141	284	1
ce1170142	284	1
ce1170143	284	1
ce1170144	284	1
ce1170145	284	1
ce1170146	284	1
ce1170147	284	1
ce1170148	284	1
ce1170150	284	1
ce1170151	284	1
ce1170152	284	1
ce1170153	284	1
ce1170154	284	1
ce1170155	284	1
ce1170156	284	1
ce1170157	284	1
ce1170159	284	1
ce1170160	284	1
ce1170162	284	1
ce1170163	284	1
ce1170164	284	1
ce1170165	284	1
ce1170166	284	1
ce1170167	284	1
ce1170168	284	1
ce1170169	284	1
ce1170170	284	1
ce1170171	284	1
ce1170172	284	1
ce1170173	284	1
ce1170174	284	1
ce1170175	284	1
ce1140360	285	1
ce1160256	285	1
ce1160279	285	1
ce1160286	285	1
ce1160287	285	1
ce1160303	285	1
ce1160304	285	1
ce1170071	285	1
ce1170072	285	1
ce1170073	285	1
ce1170074	285	1
ce1170075	285	1
ce1170076	285	1
ce1170077	285	1
ce1170079	285	1
ce1170080	285	1
ce1170081	285	1
ce1170082	285	1
ce1170083	285	1
ce1170084	285	1
ce1170085	285	1
ce1170088	285	1
ce1170089	285	1
ce1170090	285	1
ce1170091	285	1
ce1170092	285	1
ce1170094	285	1
ce1170095	285	1
ce1170096	285	1
ce1170097	285	1
ce1170098	285	1
ce1170099	285	1
ce1170100	285	1
ce1170101	285	1
ce1170102	285	1
ce1170103	285	1
ce1170104	285	1
ce1170105	285	1
ce1170106	285	1
ce1170108	285	1
ce1170109	285	1
ce1170110	285	1
ce1170111	285	1
ce1170112	285	1
ce1170113	285	1
ce1170115	285	1
ce1170116	285	1
ce1170117	285	1
ce1170118	285	1
ce1170119	285	1
ce1170121	285	1
ce1170122	285	1
ce1170123	285	1
ce1170124	285	1
ce1170125	285	1
ce1170126	285	1
ce1170127	285	1
ce1170128	285	1
ce1170129	285	1
ce1170130	285	1
ce1170131	285	1
ce1170132	285	1
ce1170133	285	1
ce1170134	285	1
ce1170135	285	1
ce1170136	285	1
ce1170137	285	1
ce1170138	285	1
ce1170139	285	1
ce1170140	285	1
ce1170141	285	1
ce1170142	285	1
ce1170143	285	1
ce1170144	285	1
ce1170145	285	1
ce1170146	285	1
ce1170147	285	1
ce1170148	285	1
ce1170150	285	1
ce1170151	285	1
ce1170152	285	1
ce1170153	285	1
ce1170154	285	1
ce1170155	285	1
ce1170156	285	1
ce1170157	285	1
ce1170159	285	1
ce1170160	285	1
ce1170162	285	1
ce1170163	285	1
ce1170164	285	1
ce1170165	285	1
ce1170166	285	1
ce1170167	285	1
ce1170168	285	1
ce1170169	285	1
ce1170170	285	1
ce1170171	285	1
ce1170172	285	1
ce1170173	285	1
ce1170174	285	1
ce1170175	285	1
ce1140360	286	1
ce1160256	286	1
ce1160279	286	1
ce1160286	286	1
ce1160287	286	1
ce1160303	286	1
ce1170071	286	1
ce1170072	286	1
ce1170073	286	1
ce1170074	286	1
ce1170075	286	1
ce1170076	286	1
ce1170077	286	1
ce1170079	286	1
ce1170080	286	1
ce1170081	286	1
ce1170082	286	1
ce1170083	286	1
ce1170084	286	1
ce1170085	286	1
ce1170088	286	1
ce1170089	286	1
ce1170090	286	1
ce1170091	286	1
ce1170092	286	1
ce1170094	286	1
ce1170095	286	1
ce1170096	286	1
ce1170097	286	1
ce1170098	286	1
ce1170099	286	1
ce1170100	286	1
ce1170101	286	1
ce1170102	286	1
ce1170103	286	1
ce1170104	286	1
ce1170105	286	1
ce1170106	286	1
ce1170108	286	1
ce1170109	286	1
ce1170110	286	1
ce1170111	286	1
ce1170112	286	1
ce1170113	286	1
ce1170115	286	1
ce1170116	286	1
ce1170117	286	1
ce1170118	286	1
ce1170119	286	1
ce1170121	286	1
ce1170122	286	1
ce1170123	286	1
ce1170124	286	1
ce1170125	286	1
ce1170126	286	1
ce1170127	286	1
ce1170128	286	1
ce1170129	286	1
ce1170130	286	1
ce1170131	286	1
ce1170132	286	1
ce1170133	286	1
ce1170134	286	1
ce1170135	286	1
ce1170136	286	1
ce1170137	286	1
ce1170138	286	1
ce1170139	286	1
ce1170140	286	1
ce1170141	286	1
ce1170142	286	1
ce1170143	286	1
ce1170144	286	1
ce1170145	286	1
ce1170146	286	1
ce1170147	286	1
ce1170148	286	1
ce1170150	286	1
ce1170151	286	1
ce1170152	286	1
ce1170153	286	1
ce1170154	286	1
ce1170155	286	1
ce1170156	286	1
ce1170157	286	1
ce1170159	286	1
ce1170160	286	1
ce1170162	286	1
ce1170163	286	1
ce1170164	286	1
ce1170165	286	1
ce1170166	286	1
ce1170167	286	1
ce1170168	286	1
ce1170169	286	1
ce1170170	286	1
ce1170171	286	1
ce1170172	286	1
ce1170173	286	1
ce1170174	286	1
ce1170175	286	1
ce1140360	287	1
ce1160256	287	1
ce1160279	287	1
ce1160286	287	1
ce1160287	287	1
ce1160303	287	1
ce1170071	287	1
ce1170072	287	1
ce1170073	287	1
ce1170074	287	1
ce1170075	287	1
ce1170076	287	1
ce1170077	287	1
ce1170079	287	1
ce1170080	287	1
ce1170081	287	1
ce1170082	287	1
ce1170083	287	1
ce1170084	287	1
ce1170085	287	1
ce1170088	287	1
ce1170089	287	1
ce1170090	287	1
ce1170091	287	1
ce1170092	287	1
ce1170094	287	1
ce1170095	287	1
ce1170096	287	1
ce1170097	287	1
ce1170098	287	1
ce1170099	287	1
ce1170100	287	1
ce1170101	287	1
ce1170102	287	1
ce1170103	287	1
ce1170104	287	1
ce1170105	287	1
ce1170106	287	1
ce1170108	287	1
ce1170109	287	1
ce1170110	287	1
ce1170111	287	1
ce1170112	287	1
ce1170113	287	1
ce1170115	287	1
ce1170116	287	1
ce1170117	287	1
ce1170118	287	1
ce1170119	287	1
ce1170121	287	1
ce1170122	287	1
ce1170123	287	1
ce1170124	287	1
ce1170125	287	1
ce1170126	287	1
ce1170127	287	1
ce1170128	287	1
ce1170129	287	1
ce1170130	287	1
ce1170131	287	1
ce1170132	287	1
ce1170133	287	1
ce1170134	287	1
ce1170135	287	1
ce1170136	287	1
ce1170137	287	1
ce1170138	287	1
ce1170139	287	1
ce1170140	287	1
ce1170141	287	1
ce1170142	287	1
ce1170143	287	1
ce1170144	287	1
ce1170145	287	1
ce1170146	287	1
ce1170147	287	1
ce1170148	287	1
ce1170150	287	1
ce1170151	287	1
ce1170152	287	1
ce1170153	287	1
ce1170154	287	1
ce1170155	287	1
ce1170156	287	1
ce1170157	287	1
ce1170159	287	1
ce1170160	287	1
ce1170162	287	1
ce1170163	287	1
ce1170164	287	1
ce1170165	287	1
ce1170166	287	1
ce1170167	287	1
ce1170168	287	1
ce1170169	287	1
ce1170170	287	1
ce1170171	287	1
ce1170172	287	1
ce1170173	287	1
ce1170174	287	1
ce1170175	287	1
ce1130348	288	1
ce1140243	288	1
ce1140360	288	1
ce1150326	288	1
ce1160200	288	1
ce1160201	288	1
ce1160202	288	1
ce1160203	288	1
ce1160204	288	1
ce1160205	288	1
ce1160206	288	1
ce1160207	288	1
ce1160208	288	1
ce1160209	288	1
ce1160210	288	1
ce1160211	288	1
ce1160212	288	1
ce1160214	288	1
ce1160215	288	1
ce1160216	288	1
ce1160217	288	1
ce1160218	288	1
ce1160219	288	1
ce1160221	288	1
ce1160222	288	1
ce1160223	288	1
ce1160225	288	1
ce1160226	288	1
ce1160227	288	1
ce1160228	288	1
ce1160229	288	1
ce1160230	288	1
ce1160231	288	1
ce1160232	288	1
ce1160233	288	1
ce1160234	288	1
ce1160235	288	1
ce1160236	288	1
ce1160237	288	1
ce1160238	288	1
ce1160239	288	1
ce1160241	288	1
ce1160242	288	1
ce1160243	288	1
ce1160244	288	1
ce1160245	288	1
ce1160247	288	1
ce1160248	288	1
ce1160249	288	1
ce1160251	288	1
ce1160252	288	1
ce1160253	288	1
ce1160254	288	1
ce1160255	288	1
ce1160257	288	1
ce1160258	288	1
ce1160259	288	1
ce1160260	288	1
ce1160261	288	1
ce1160262	288	1
ce1160263	288	1
ce1160264	288	1
ce1160265	288	1
ce1160266	288	1
ce1160267	288	1
ce1160269	288	1
ce1160270	288	1
ce1160271	288	1
ce1160272	288	1
ce1160273	288	1
ce1160274	288	1
ce1160275	288	1
ce1160276	288	1
ce1160277	288	1
ce1160278	288	1
ce1160280	288	1
ce1160281	288	1
ce1160282	288	1
ce1160283	288	1
ce1160284	288	1
ce1160285	288	1
ce1160286	288	1
ce1160288	288	1
ce1160289	288	1
ce1160290	288	1
ce1160291	288	1
ce1160292	288	1
ce1160293	288	1
ce1160295	288	1
ce1160296	288	1
ce1160297	288	1
ce1160298	288	1
ce1160299	288	1
ce1160302	288	1
ce1160305	288	1
ce1160856	288	1
cew182083	289	1
cew182084	289	1
cew182233	289	1
cew182235	289	1
cew182238	289	1
cew182669	289	1
cew182671	289	1
cew182673	289	1
cew182674	289	1
cew182675	289	1
cew182676	289	1
cew182083	290	1
cew182084	290	1
cew182233	290	1
cew182235	290	1
cew182238	290	1
cew182669	290	1
cew182671	290	1
cew182673	290	1
cew182674	290	1
cew182675	290	1
cew182676	290	1
ce1150322	291	1
ce1150342	291	1
ces172466	291	1
ces172467	291	1
ces172468	291	1
ces172469	291	1
ces172470	291	1
ces172471	291	1
ces172472	291	1
ces182087	291	1
ces182096	291	1
ces182097	291	1
ces182098	291	1
ces182128	291	1
ces182129	291	1
ces182130	291	1
ces182131	291	1
ces182132	291	1
ces182133	291	1
ces182173	291	1
ces182181	291	1
ces182182	291	1
ces182183	291	1
ces182641	291	1
ces182643	291	1
ces182644	291	1
ces182645	291	1
ces182646	291	1
ces182648	291	1
ces182649	291	1
ces182650	291	1
cez188375	291	1
cet172474	292	1
cet182186	292	1
cet182187	292	1
cet182189	292	1
cet182191	292	1
cet182192	292	1
cet182197	292	1
cet182198	292	1
cet182201	292	1
cet182204	292	1
cet182651	292	1
cet182652	292	1
cet182653	292	1
cet182654	292	1
cet182656	292	1
cet182658	292	1
ceg182148	293	1
ceg182154	293	1
ceg182156	293	1
ceg182157	293	1
ceg182628	293	1
ceg182629	293	1
ceg182630	293	1
ceg182631	293	1
ceg182632	293	1
ceg182633	293	1
cez188044	293	1
ceu182210	294	1
ceu182211	294	1
ceu182215	294	1
ceu182216	294	1
ceu182659	294	1
ceu182660	294	1
ceu182661	294	1
ceu182662	294	1
ceu182664	294	1
ce1130323	295	1
ce1130384	295	1
ce1140303	295	1
ce1140315	295	1
ce1140345	295	1
ce1140346	295	1
ce1140360	295	1
ce1150309	295	1
ce1150315	295	1
ce1150316	295	1
ce1150318	295	1
ce1150320	295	1
ce1150321	295	1
ce1150322	295	1
ce1150324	295	1
ce1150326	295	1
ce1150327	295	1
ce1150328	295	1
ce1150336	295	1
ce1150342	295	1
ce1150343	295	1
ce1150345	295	1
ce1150348	295	1
ce1150356	295	1
ce1150359	295	1
ce1150360	295	1
ce1150363	295	1
ce1150364	295	1
ce1150366	295	1
ce1150367	295	1
ce1150368	295	1
ce1150372	295	1
ce1150377	295	1
ce1150386	295	1
ce1150387	295	1
ce1150388	295	1
ce1150389	295	1
ce1150392	295	1
ce1150394	295	1
ce1150405	295	1
ce1160200	295	1
ce1160201	295	1
ce1160202	295	1
ce1160203	295	1
ce1160204	295	1
ce1160205	295	1
ce1160206	295	1
ce1160207	295	1
ce1160208	295	1
ce1160209	295	1
ce1160210	295	1
ce1160211	295	1
ce1160212	295	1
ce1160213	295	1
ce1160214	295	1
ce1160215	295	1
ce1160216	295	1
ce1160217	295	1
ce1160218	295	1
ce1160219	295	1
ce1160221	295	1
ce1160222	295	1
ce1160223	295	1
ce1160225	295	1
ce1160226	295	1
ce1160227	295	1
ce1160228	295	1
ce1160229	295	1
ce1160230	295	1
ce1160231	295	1
ce1160232	295	1
ce1160233	295	1
ce1160234	295	1
ce1160235	295	1
ce1160236	295	1
ce1160237	295	1
ce1160238	295	1
ce1160239	295	1
ce1160241	295	1
ce1160242	295	1
ce1160243	295	1
ce1160244	295	1
ce1160245	295	1
ce1160247	295	1
ce1160248	295	1
ce1160249	295	1
ce1160251	295	1
ce1160252	295	1
ce1160253	295	1
ce1160254	295	1
ce1160255	295	1
ce1160256	295	1
ce1160257	295	1
ce1160258	295	1
ce1160259	295	1
ce1160260	295	1
ce1160261	295	1
ce1160262	295	1
ce1160263	295	1
ce1160264	295	1
ce1160265	295	1
ce1160266	295	1
ce1160267	295	1
ce1160269	295	1
ce1160270	295	1
ce1160271	295	1
ce1160272	295	1
ce1160273	295	1
ce1160274	295	1
ce1160275	295	1
ce1160276	295	1
ce1160277	295	1
ce1160278	295	1
ce1160279	295	1
ce1160280	295	1
ce1160281	295	1
ce1160282	295	1
ce1160283	295	1
ce1160284	295	1
ce1160285	295	1
ce1160286	295	1
ce1160287	295	1
ce1160288	295	1
ce1160289	295	1
ce1160290	295	1
ce1160291	295	1
ce1160292	295	1
ce1160293	295	1
ce1160295	295	1
ce1160296	295	1
ce1160297	295	1
ce1160298	295	1
ce1160299	295	1
ce1160302	295	1
ce1160303	295	1
ce1160304	295	1
ce1160856	295	1
vst189732	296	1
bb1150061	297	1
jds186001	297	1
jds186002	297	1
jds186003	297	1
jds186004	297	1
jds186005	297	1
jds186006	297	1
jds186007	297	1
jds186008	297	1
jds186009	297	1
jds186010	297	1
jds186011	297	1
jds186012	297	1
jds186013	297	1
jds186014	297	1
jds186015	297	1
jds186016	297	1
jds186017	297	1
jds186018	297	1
jds186019	297	1
jds186020	297	1
bb1150059	298	1
bb1150062	298	1
bb1160030	298	1
ce1150395	298	1
me1150626	298	1
me2150766	298	1
mt6140551	298	1
tt1150877	298	1
tt1150879	298	1
tt1150904	298	1
tt1150906	298	1
tt1150907	298	1
tt1150938	298	1
tt1160832	298	1
tt1160873	298	1
tt1160881	298	1
tt1160887	298	1
jid172537	299	1
jid172539	299	1
jid172542	299	1
jid172545	299	1
jid172761	299	1
jid172764	299	1
jds176001	300	1
jds176002	300	1
jds176003	300	1
jds176004	300	1
jds176006	300	1
jds176008	300	1
jds176009	300	1
jds176010	300	1
jds176011	300	1
jds176012	300	1
jds176013	300	1
jds176014	300	1
jds176015	300	1
jds176016	300	1
jds176018	300	1
eee172235	301	1
eee172236	301	1
eee172239	301	1
een172257	301	1
een182405	301	1
een182408	301	1
een182411	301	1
een182412	301	1
een182413	301	1
een182415	301	1
een182416	301	1
een182418	301	1
een182419	301	1
een182420	301	1
eep182552	301	1
eep182553	301	1
eet162646	301	1
eet182564	301	1
eet182565	301	1
eet182568	301	1
eet182571	301	1
jid182455	301	1
jid182456	301	1
jid182457	301	1
jid182459	301	1
jid182460	301	1
jid182461	301	1
jid182462	301	1
jid182463	301	1
jid182464	301	1
jid182465	301	1
jid182466	301	1
jid182467	301	1
jid182468	301	1
jid182469	301	1
jid182470	301	1
jid182471	301	1
jid182455	302	1
jid182456	302	1
jid182457	302	1
jid182459	302	1
jid182460	302	1
jid182461	302	1
jid182462	302	1
jid182463	302	1
jid182464	302	1
jid182465	302	1
jid182466	302	1
jid182467	302	1
jid182468	302	1
jid182469	302	1
jid182470	302	1
jid182471	302	1
jid182455	303	1
jid182456	303	1
jid182457	303	1
jid182459	303	1
jid182460	303	1
jid182461	303	1
jid182462	303	1
jid182463	303	1
jid182464	303	1
jid182465	303	1
jid182466	303	1
jid182467	303	1
jid182468	303	1
jid182469	303	1
jid182470	303	1
jid182471	303	1
cs1140227	304	1
idz188306	304	1
jid172542	304	1
jid172545	304	1
jid172761	304	1
jid182455	304	1
jid182456	304	1
jid182457	304	1
jid182463	304	1
jid182464	304	1
jid182466	304	1
tt1150920	304	1
bb1160030	305	1
ddz188504	305	1
ddz188659	305	1
jds186001	305	1
jds186002	305	1
jds186003	305	1
jds186004	305	1
jds186005	305	1
jds186006	305	1
jds186007	305	1
jds186008	305	1
jds186009	305	1
jds186011	305	1
jds186013	305	1
jds186017	305	1
me2150753	305	1
me2150756	305	1
me2150758	305	1
me2150759	305	1
me2150760	305	1
me2150766	305	1
mt1150581	305	1
mt1150617	305	1
mt6140551	305	1
mt6140559	305	1
mt6140560	305	1
mt6150553	305	1
qiz188608	305	1
tt1150919	305	1
tt1150920	305	1
tt1150933	305	1
tt1150954	305	1
tt1160832	305	1
jid182455	306	1
jid182456	306	1
jid182457	306	1
jid182459	306	1
jid182464	306	1
jid182465	306	1
jid182468	306	1
jid182469	306	1
jid182471	306	1
jid182455	307	1
jid182456	307	1
jid182457	307	1
jid182459	307	1
jid182460	307	1
jid182461	307	1
jid182462	307	1
jid182463	307	1
jid182464	307	1
jid182465	307	1
jid182466	307	1
jid182467	307	1
jid182468	307	1
jid182469	307	1
jid182470	307	1
jid182471	307	1
ddz188659	308	1
jds186001	308	1
jds186002	308	1
jds186003	308	1
jds186004	308	1
jds186005	308	1
jds186006	308	1
jds186007	308	1
jds186008	308	1
jds186009	308	1
jds186010	308	1
jds186011	308	1
jds186012	308	1
jds186013	308	1
jds186014	308	1
jds186015	308	1
jds186016	308	1
jds186017	308	1
jds186018	308	1
jds186019	308	1
jds186020	308	1
ph1140835	308	1
bb1150059	309	1
bb1150061	309	1
bb1160027	309	1
cs1160379	309	1
cs1160406	309	1
ddz188659	309	1
jds186001	309	1
jds186002	309	1
jds186003	309	1
jds186004	309	1
jds186005	309	1
jds186006	309	1
jds186007	309	1
jds186008	309	1
jds186009	309	1
jds186010	309	1
jds186011	309	1
jds186012	309	1
jds186013	309	1
jds186014	309	1
jds186015	309	1
jds186016	309	1
jds186017	309	1
jds186018	309	1
jds186019	309	1
jds186020	309	1
me1150626	309	1
tt1150920	309	1
tt1150933	309	1
tt1160832	309	1
tt1160873	309	1
tt1160877	309	1
tt1160887	309	1
bb1150050	310	1
jds186001	310	1
jds186002	310	1
jds186003	310	1
jds186004	310	1
jds186005	310	1
jds186006	310	1
jds186007	310	1
jds186008	310	1
jds186009	310	1
jds186010	310	1
jds186011	310	1
jds186012	310	1
jds186013	310	1
jds186014	310	1
jds186015	310	1
jds186016	310	1
jds186017	310	1
jds186018	310	1
jds186019	310	1
jds186020	310	1
me2150760	310	1
ph1140835	310	1
jds186009	311	1
jds186010	311	1
jds186011	311	1
jds186012	311	1
jds186013	311	1
jds186014	311	1
jds186015	311	1
jds186016	311	1
jds186018	311	1
jds186019	311	1
jds186020	311	1
me1150626	311	1
me1150654	311	1
cs1160379	312	1
cs1160406	312	1
ddz188659	312	1
jds186001	312	1
jds186002	312	1
jds186003	312	1
jds186004	312	1
jds186005	312	1
jds186006	312	1
jds186007	312	1
jds186008	312	1
jds186010	312	1
jds186012	312	1
jds186014	312	1
jds186015	312	1
jds186016	312	1
jds186017	312	1
jds186018	312	1
jds186019	312	1
jds186020	312	1
mt6140551	312	1
eey147546	313	1
amz128403	314	1
amz128405	314	1
amz128406	314	1
amz138001	314	1
amz138005	314	1
amz138007	314	1
amz138008	314	1
amz138289	314	1
amz138574	314	1
amz138575	314	1
amz138577	314	1
amz138592	314	1
amz148021	314	1
amz148022	314	1
amz148023	314	1
amz148024	314	1
amz148025	314	1
amz148232	314	1
amz148254	314	1
amz148262	314	1
amz148425	314	1
amz152044	314	1
amz158217	314	1
amz158219	314	1
amz158220	314	1
amz158346	314	1
amz158347	314	1
amz158348	314	1
amz158349	314	1
amz158488	314	1
amz162259	314	1
amz168163	314	1
amz168164	314	1
amz168165	314	1
amz168166	314	1
amz168168	314	1
amz168342	314	1
amz168347	314	1
amz168463	314	1
amz168464	314	1
amz168465	314	1
amz168466	314	1
amz178117	314	1
amz178118	314	1
amz178119	314	1
amz178122	314	1
amz178124	314	1
amz178125	314	1
amz178127	314	1
amz178128	314	1
amz178423	314	1
amz178547	314	1
amz178549	314	1
amz178550	314	1
amz178551	314	1
amz178554	314	1
amz188068	314	1
amz188069	314	1
amz188318	314	1
amz188631	314	1
amz188634	314	1
amz188635	314	1
anz128203	314	1
anz138011	314	1
anz138012	314	1
anz138579	314	1
anz148198	314	1
anz148355	314	1
anz148356	314	1
anz157549	314	1
anz157550	314	1
anz158221	314	1
anz158222	314	1
anz158223	314	1
anz158482	314	1
anz158497	314	1
anz162112	314	1
anz168046	314	1
anz168048	314	1
anz168049	314	1
anz178353	314	1
anz178419	314	1
anz178422	314	1
anz188060	314	1
anz188063	314	1
anz188064	314	1
anz188379	314	1
anz188380	314	1
anz188387	314	1
anz188503	314	1
asz118399	314	1
asz122525	314	1
asz138014	314	1
asz138019	314	1
asz138020	314	1
asz138508	314	1
asz142298	314	1
asz148028	314	1
asz148029	314	1
asz148030	314	1
asz148031	314	1
asz148032	314	1
asz148033	314	1
asz148357	314	1
asz148358	314	1
asz158225	314	1
asz158226	314	1
asz158227	314	1
asz158228	314	1
asz158372	314	1
asz168054	314	1
asz168055	314	1
asz168368	314	1
asz168369	314	1
asz178025	314	1
asz178026	314	1
asz178029	314	1
asz178466	314	1
asz178467	314	1
asz178468	314	1
asz178469	314	1
asz178470	314	1
asz188003	314	1
asz188004	314	1
asz188005	314	1
asz188006	314	1
asz188007	314	1
asz188009	314	1
asz188512	314	1
asz188660	314	1
bey177534	314	1
bez137510	314	1
bez138510	314	1
bez147503	314	1
bez148265	314	1
bez148267	314	1
bez158001	314	1
bez158004	314	1
bez158350	314	1
bez158351	314	1
bez158355	314	1
bez158357	314	1
bez158358	314	1
bez158501	314	1
bez158503	314	1
bez167504	314	1
bez168007	314	1
bez168008	314	1
bez168335	314	1
bez168558	314	1
bez168559	314	1
bez178285	314	1
bez178286	314	1
bez178287	314	1
bez178289	314	1
bez178290	314	1
bez178291	314	1
bez178293	314	1
bez178418	314	1
bez178438	314	1
bez188239	314	1
bez188240	314	1
bez188241	314	1
bez188243	314	1
bez188436	314	1
bez188437	314	1
bez188438	314	1
bez188439	314	1
bez188440	314	1
bez188441	314	1
bez188442	314	1
blz128103	314	1
blz128555	314	1
blz138512	314	1
blz148192	314	1
blz148193	314	1
blz148196	314	1
blz148197	314	1
blz148200	314	1
blz148271	314	1
blz148272	314	1
blz148359	314	1
blz158229	314	1
blz158230	314	1
blz158231	314	1
blz158233	314	1
blz158235	314	1
blz158236	314	1
blz158440	314	1
blz167512	314	1
blz168127	314	1
blz168129	314	1
blz168130	314	1
blz168133	314	1
blz168228	314	1
blz168229	314	1
blz168370	314	1
blz168371	314	1
blz168372	314	1
blz168373	314	1
blz168374	314	1
blz168376	314	1
blz178279	314	1
blz178280	314	1
blz178281	314	1
blz178282	314	1
blz178284	314	1
blz178574	314	1
blz178575	314	1
blz188277	314	1
blz188278	314	1
blz188462	314	1
blz188465	314	1
blz188466	314	1
blz188467	314	1
blz188468	314	1
blz188469	314	1
blz188470	314	1
bmz128113	314	1
bmz128118	314	1
bmz128463	314	1
bmz128466	314	1
bmz128566	314	1
bmz138038	314	1
bmz138042	314	1
bmz138596	314	1
bmz148225	314	1
bmz148226	314	1
bmz148229	314	1
bmz148273	314	1
bmz158237	314	1
bmz158238	314	1
bmz158342	314	1
bmz168110	314	1
bmz168111	314	1
bmz168112	314	1
bmz168336	314	1
bmz168398	314	1
bmz178357	314	1
bmz178358	314	1
bmz178359	314	1
bmz178360	314	1
bmz178361	314	1
bmz178413	314	1
bmz178629	314	1
bmz178630	314	1
bmz178631	314	1
bmz188298	314	1
bmz188307	314	1
bmz188308	314	1
bmz188309	314	1
bmz188310	314	1
bsz112222	314	1
bsz128163	314	1
bsz128324	314	1
bsz138258	314	1
bsz148360	314	1
bsz148419	314	1
bsz158005	314	1
bsz158006	314	1
bsz158315	314	1
bsz158442	314	1
bsz168039	314	1
bsz168040	314	1
bsz168041	314	1
bsz168043	314	1
bsz168044	314	1
bsz168346	314	1
bsz168460	314	1
bsz168461	314	1
bsz178035	314	1
bsz178036	314	1
bsz178039	314	1
bsz178041	314	1
bsz178366	314	1
bsz178496	314	1
bsz178497	314	1
bsz178498	314	1
bsz178499	314	1
bsz178500	314	1
bsz178501	314	1
bsz188118	314	1
bsz188119	314	1
bsz188120	314	1
bsz188121	314	1
bsz188122	314	1
bsz188123	314	1
bsz188291	314	1
bsz188601	314	1
cez118474	314	1
cez127514	314	1
cez128027	314	1
cez128029	314	1
cez128062	314	1
cez128066	314	1
cez128069	314	1
cez128070	314	1
cez128071	314	1
cez128202	314	1
cez128305	314	1
cez128535	314	1
cez128545	314	1
cez128547	314	1
cez138045	314	1
cez138048	314	1
cez138049	314	1
cez138054	314	1
cez138055	314	1
cez138058	314	1
cez138059	314	1
cez138060	314	1
cez138063	314	1
cez138066	314	1
cez138073	314	1
cez138074	314	1
cez138076	314	1
cez138077	314	1
cez138079	314	1
cez138081	314	1
cez138082	314	1
cez138083	314	1
cez138085	314	1
cez138220	314	1
cez138227	314	1
cez138421	314	1
cez138422	314	1
cez138424	314	1
cez138428	314	1
cez138429	314	1
cez138430	314	1
cez138431	314	1
cez138432	314	1
cez138434	314	1
cez138436	314	1
cez138438	314	1
cez142222	314	1
cez148034	314	1
cez148036	314	1
cez148039	314	1
cez148040	314	1
cez148041	314	1
cez148042	314	1
cez148043	314	1
cez148203	314	1
cez148237	314	1
cez148260	314	1
cez148361	314	1
cez148362	314	1
cez148364	314	1
cez148365	314	1
cez148366	314	1
cez148368	314	1
cez148369	314	1
cez148370	314	1
cez148371	314	1
cez148373	314	1
cez148374	314	1
cez148376	314	1
cez158008	314	1
cez158010	314	1
cez158012	314	1
cez158013	314	1
cez158014	314	1
cez158018	314	1
cez158019	314	1
cez158022	314	1
cez158023	314	1
cez158026	314	1
cez158028	314	1
cez158032	314	1
cez158033	314	1
cez158293	314	1
cez158304	314	1
cez158306	314	1
cez158359	314	1
cez158360	314	1
cez158361	314	1
cez158362	314	1
cez158363	314	1
cez158364	314	1
cez158365	314	1
cez158368	314	1
cez158369	314	1
cez158370	314	1
cez158371	314	1
cez158487	314	1
cez158493	314	1
cez158494	314	1
cez158495	314	1
cez168135	314	1
cez168136	314	1
cez168137	314	1
cez168138	314	1
cez168139	314	1
cez168140	314	1
cez168141	314	1
cez168143	314	1
cez168144	314	1
cez168145	314	1
cez168146	314	1
cez168147	314	1
cez168148	314	1
cez168150	314	1
cez168151	314	1
cez168152	314	1
cez168154	314	1
cez168155	314	1
cez168156	314	1
cez168160	314	1
cez168161	314	1
cez168331	314	1
cez168333	314	1
cez168334	314	1
cez168419	314	1
cez168420	314	1
cez168422	314	1
cez168423	314	1
cez168424	314	1
cez168426	314	1
cez168427	314	1
cez168428	314	1
cez168429	314	1
cez168430	314	1
cez168431	314	1
cez168432	314	1
cez168433	314	1
cez168434	314	1
cez168435	314	1
cez168437	314	1
cez168438	314	1
cez168439	314	1
cez168440	314	1
cez168574	314	1
cez177518	314	1
cez177521	314	1
cez178071	314	1
cez178072	314	1
cez178073	314	1
cez178074	314	1
cez178075	314	1
cez178077	314	1
cez178078	314	1
cez178079	314	1
cez178080	314	1
cez178081	314	1
cez178082	314	1
cez178083	314	1
cez178085	314	1
cez178086	314	1
cez178089	314	1
cez178091	314	1
cez178093	314	1
cez178094	314	1
cez178367	314	1
cez178421	314	1
cez178522	314	1
cez178523	314	1
cez178524	314	1
cez178525	314	1
cez178526	314	1
cez178527	314	1
cez178528	314	1
cez178529	314	1
cez178531	314	1
cez178532	314	1
cez178533	314	1
cez178535	314	1
cez178536	314	1
cez178537	314	1
cez188026	314	1
cez188027	314	1
cez188028	314	1
cez188029	314	1
cez188030	314	1
cez188031	314	1
cez188032	314	1
cez188033	314	1
cez188034	314	1
cez188035	314	1
cez188036	314	1
cez188037	314	1
cez188038	314	1
cez188039	314	1
cez188040	314	1
cez188041	314	1
cez188042	314	1
cez188044	314	1
cez188045	314	1
cez188047	314	1
cez188048	314	1
cez188049	314	1
cez188050	314	1
cez188052	314	1
cez188053	314	1
cez188234	314	1
cez188375	314	1
cez188388	314	1
cez188389	314	1
cez188391	314	1
cez188392	314	1
cez188393	314	1
cez188394	314	1
cez188395	314	1
cez188396	314	1
cez188397	314	1
cez188399	314	1
cez188400	314	1
cez188401	314	1
cez188405	314	1
cez188406	314	1
cez188407	314	1
cez188408	314	1
chz127523	314	1
chz128215	314	1
chz128225	314	1
chz128230	314	1
chz128412	314	1
chz128414	314	1
chz138089	314	1
chz138099	314	1
chz138290	314	1
chz138303	314	1
chz138439	314	1
chz138440	314	1
chz138441	314	1
chz138442	314	1
chz138444	314	1
chz138447	314	1
chz138448	314	1
chz138450	314	1
chz138452	314	1
chz138454	314	1
chz138565	314	1
chz148147	314	1
chz148148	314	1
chz148164	314	1
chz148165	314	1
chz148167	314	1
chz148169	314	1
chz148170	314	1
chz148171	314	1
chz148172	314	1
chz148174	314	1
chz148178	314	1
chz148179	314	1
chz148206	314	1
chz148258	314	1
chz148277	314	1
chz148279	314	1
chz148280	314	1
chz148281	314	1
chz148282	314	1
chz148283	314	1
chz148284	314	1
chz148286	314	1
chz148287	314	1
chz148288	314	1
chz148289	314	1
chz148290	314	1
chz158241	314	1
chz158248	314	1
chz158292	314	1
chz158431	314	1
chz158432	314	1
chz158433	314	1
chz158435	314	1
chz158436	314	1
chz158490	314	1
chz168283	314	1
chz168284	314	1
chz168285	314	1
chz168288	314	1
chz168289	314	1
chz168291	314	1
chz168292	314	1
chz168294	314	1
chz168299	314	1
chz168302	314	1
chz168307	314	1
chz168308	314	1
chz168309	314	1
chz168310	314	1
chz168348	314	1
chz168517	314	1
chz168518	314	1
chz168523	314	1
chz168524	314	1
chz168526	314	1
chz168527	314	1
chz168573	314	1
chz168576	314	1
chz172569	314	1
chz178248	314	1
chz178251	314	1
chz178252	314	1
chz178255	314	1
chz178257	314	1
chz178258	314	1
chz178260	314	1
chz178262	314	1
chz178263	314	1
chz178264	314	1
chz178265	314	1
chz178266	314	1
chz178267	314	1
chz178268	314	1
chz178269	314	1
chz178273	314	1
chz178275	314	1
chz178277	314	1
chz178278	314	1
chz178369	314	1
chz178503	314	1
chz178504	314	1
chz178505	314	1
chz178506	314	1
chz178508	314	1
chz178509	314	1
chz178510	314	1
chz178511	314	1
chz178512	314	1
chz178515	314	1
chz178516	314	1
chz178517	314	1
chz178518	314	1
chz178634	314	1
chz178658	314	1
chz188071	314	1
chz188074	314	1
chz188075	314	1
chz188076	314	1
chz188077	314	1
chz188078	314	1
chz188079	314	1
chz188080	314	1
chz188081	314	1
chz188082	314	1
chz188083	314	1
chz188084	314	1
chz188085	314	1
chz188086	314	1
chz188087	314	1
chz188090	314	1
chz188091	314	1
chz188096	314	1
chz188097	314	1
chz188098	314	1
chz188099	314	1
chz188100	314	1
chz188101	314	1
chz188232	314	1
chz188237	314	1
chz188297	314	1
chz188316	314	1
chz188386	314	1
chz188486	314	1
chz188487	314	1
chz188488	314	1
chz188489	314	1
chz188490	314	1
chz188492	314	1
chz188493	314	1
chz188494	314	1
chz188496	314	1
chz188497	314	1
chz188499	314	1
chz188500	314	1
chz188501	314	1
chz188502	314	1
chz188520	314	1
chz188547	314	1
chz188663	314	1
chz188667	314	1
crz138456	314	1
crz138458	314	1
crz138463	314	1
crz148049	314	1
crz148050	314	1
crz148052	314	1
crz148292	314	1
crz148293	314	1
crz148294	314	1
crz148295	314	1
crz148296	314	1
crz158034	314	1
crz158036	314	1
crz158038	314	1
crz158039	314	1
crz158040	314	1
crz158398	314	1
crz158428	314	1
crz158430	314	1
crz158437	314	1
crz168012	314	1
crz168013	314	1
crz168561	314	1
crz168562	314	1
crz168563	314	1
crz168564	314	1
crz168565	314	1
crz168566	314	1
crz168567	314	1
crz168568	314	1
crz168569	314	1
crz168571	314	1
crz178065	314	1
crz178067	314	1
crz178637	314	1
crz178638	314	1
crz178639	314	1
crz178640	314	1
crz178641	314	1
crz188292	314	1
crz188299	314	1
crz188300	314	1
crz188301	314	1
crz188302	314	1
crz188303	314	1
csz128276	314	1
csz128279	314	1
csz138110	314	1
csz138294	314	1
csz148207	314	1
csz148208	314	1
csz148209	314	1
csz148210	314	1
csz148241	314	1
csz148244	314	1
csz148382	314	1
csz148383	314	1
csz148390	314	1
csz148417	314	1
csz158041	314	1
csz158042	314	1
csz158045	314	1
csz158046	314	1
csz158373	314	1
csz158489	314	1
csz158491	314	1
csz168113	314	1
csz168114	314	1
csz168117	314	1
csz168119	314	1
csz168121	314	1
csz168122	314	1
csz168230	314	1
csz168514	314	1
csz178057	314	1
csz178058	314	1
csz178059	314	1
csz178060	314	1
csz178061	314	1
csz178063	314	1
csz178584	314	1
csz188010	314	1
csz188011	314	1
csz188550	314	1
cyz118207	314	1
cyz128151	314	1
cyz128155	314	1
cyz128159	314	1
cyz128510	314	1
cyz138113	314	1
cyz138114	314	1
cyz138115	314	1
cyz138123	314	1
cyz138124	314	1
cyz138580	314	1
cyz138582	314	1
cyz138585	314	1
cyz148053	314	1
cyz148054	314	1
cyz148055	314	1
cyz148056	314	1
cyz148057	314	1
cyz148061	314	1
cyz148063	314	1
cyz148216	314	1
cyz148393	314	1
cyz148394	314	1
cyz148395	314	1
cyz158047	314	1
cyz158049	314	1
cyz158050	314	1
cyz158053	314	1
cyz158054	314	1
cyz158058	314	1
cyz158062	314	1
cyz158065	314	1
cyz158480	314	1
cyz158481	314	1
cyz168231	314	1
cyz168232	314	1
cyz168236	314	1
cyz168237	314	1
cyz168239	314	1
cyz168241	314	1
cyz168242	314	1
cyz168243	314	1
cyz168245	314	1
cyz168248	314	1
cyz168252	314	1
cyz168253	314	1
cyz168401	314	1
cyz168402	314	1
cyz168403	314	1
cyz168404	314	1
cyz168405	314	1
cyz168407	314	1
cyz168408	314	1
cyz168411	314	1
cyz168412	314	1
cyz178098	314	1
cyz178099	314	1
cyz178100	314	1
cyz178101	314	1
cyz178102	314	1
cyz178105	314	1
cyz178106	314	1
cyz178107	314	1
cyz178108	314	1
cyz178110	314	1
cyz178111	314	1
cyz178112	314	1
cyz178113	314	1
cyz178431	314	1
cyz178486	314	1
cyz178487	314	1
cyz178488	314	1
cyz178489	314	1
cyz178490	314	1
cyz178492	314	1
cyz178493	314	1
cyz178494	314	1
cyz188193	314	1
cyz188194	314	1
cyz188196	314	1
cyz188199	314	1
cyz188200	314	1
cyz188201	314	1
cyz188202	314	1
cyz188203	314	1
cyz188204	314	1
cyz188205	314	1
cyz188206	314	1
cyz188207	314	1
cyz188210	314	1
cyz188211	314	1
cyz188213	314	1
cyz188214	314	1
cyz188215	314	1
cyz188216	314	1
cyz188217	314	1
cyz188218	314	1
cyz188219	314	1
cyz188220	314	1
cyz188221	314	1
cyz188279	314	1
cyz188376	314	1
cyz188378	314	1
cyz188473	314	1
cyz188474	314	1
cyz188477	314	1
cyz188479	314	1
cyz188480	314	1
cyz188482	314	1
cyz188483	314	1
cyz188484	314	1
cyz188658	314	1
ddz188311	314	1
ddz188312	314	1
ddz188313	314	1
ddz188314	314	1
ddz188659	314	1
eey177531	314	1
eey177532	314	1
eez118310	314	1
eez118470	314	1
eez127508	314	1
eez127509	314	1
eez127528	314	1
eez128127	314	1
eez128129	314	1
eez128130	314	1
eez128135	314	1
eez128137	314	1
eez128139	314	1
eez128142	314	1
eez128292	314	1
eez128304	314	1
eez128307	314	1
eez128355	314	1
eez128358	314	1
eez128359	314	1
eez128361	314	1
eez128365	314	1
eez128367	314	1
eez128368	314	1
eez128376	314	1
eez132812	314	1
eez132826	314	1
eez132864	314	1
eez137515	314	1
eez138241	314	1
eez138244	314	1
eez138245	314	1
eez138261	314	1
eez138262	314	1
eez138285	314	1
eez138286	314	1
eez138522	314	1
eez138524	314	1
eez138525	314	1
eez138528	314	1
eez138529	314	1
eez138531	314	1
eez138532	314	1
eez138534	314	1
eez138594	314	1
eez138595	314	1
eez142368	314	1
eez147538	314	1
eez148066	314	1
eez148067	314	1
eez148068	314	1
eez148073	314	1
eez148074	314	1
eez148076	314	1
eez148077	314	1
eez148078	314	1
eez148079	314	1
eez148080	314	1
eez148081	314	1
eez148083	314	1
eez148084	314	1
eez148246	314	1
eez148297	314	1
eez148299	314	1
eez148300	314	1
eez148305	314	1
eez148306	314	1
eez148307	314	1
eez148309	314	1
eez148310	314	1
eez148312	314	1
eez148313	314	1
eez148314	314	1
eez148316	314	1
eez148420	314	1
eez148421	314	1
eez152480	314	1
eez152507	314	1
eez152511	314	1
eez152675	314	1
eez152691	314	1
eez157540	314	1
eez157544	314	1
eez158067	314	1
eez158068	314	1
eez158069	314	1
eez158070	314	1
eez158071	314	1
eez158073	314	1
eez158074	314	1
eez158075	314	1
eez158076	314	1
eez158078	314	1
eez158079	314	1
eez158080	314	1
eez158081	314	1
eez158082	314	1
eez158083	314	1
eez158086	314	1
eez158089	314	1
eez158090	314	1
eez158091	314	1
eez158093	314	1
eez158094	314	1
eez158095	314	1
eez158096	314	1
eez158097	314	1
eez158098	314	1
eez158099	314	1
eez158100	314	1
eez158101	314	1
eez158102	314	1
eez158103	314	1
eez158105	314	1
eez158108	314	1
eez158110	314	1
eez158112	314	1
eez158113	314	1
eez158114	314	1
eez158115	314	1
eez158116	314	1
eez158117	314	1
eez158295	314	1
eez158307	314	1
eez158308	314	1
eez158395	314	1
eez158396	314	1
eez158397	314	1
eez158399	314	1
eez158400	314	1
eez158401	314	1
eez158402	314	1
eez158403	314	1
eez158404	314	1
eez158406	314	1
eez158407	314	1
eez158408	314	1
eez158409	314	1
eez158410	314	1
eez158411	314	1
eez158412	314	1
eez158414	314	1
eez158415	314	1
eez158416	314	1
eez158417	314	1
eez158418	314	1
eez158419	314	1
eez158420	314	1
eez158421	314	1
eez158424	314	1
eez158425	314	1
eez158426	314	1
eez158427	314	1
eez158458	314	1
eez158485	314	1
eez158486	314	1
eez168057	314	1
eez168058	314	1
eez168059	314	1
eez168060	314	1
eez168062	314	1
eez168063	314	1
eez168064	314	1
eez168065	314	1
eez168066	314	1
eez168067	314	1
eez168068	314	1
eez168069	314	1
eez168070	314	1
eez168072	314	1
eez168073	314	1
eez168075	314	1
eez168076	314	1
eez168077	314	1
eez168078	314	1
eez168079	314	1
eez168080	314	1
eez168081	314	1
eez168082	314	1
eez168084	314	1
eez168086	314	1
eez168087	314	1
eez168088	314	1
eez168089	314	1
eez168090	314	1
eez168332	314	1
eez168337	314	1
eez168338	314	1
eez168339	314	1
eez168340	314	1
eez168349	314	1
eez168482	314	1
eez168484	314	1
eez168485	314	1
eez168486	314	1
eez168487	314	1
eez168488	314	1
eez168489	314	1
eez168490	314	1
eez168491	314	1
eez168492	314	1
eez168494	314	1
eez168495	314	1
eez168496	314	1
eez168497	314	1
eez168498	314	1
eez168501	314	1
eez168502	314	1
eez168503	314	1
eez168504	314	1
eez168505	314	1
eez168506	314	1
eez168510	314	1
eez168512	314	1
eez178153	314	1
eez178154	314	1
eez178155	314	1
eez178156	314	1
eez178157	314	1
eez178159	314	1
eez178163	314	1
eez178164	314	1
eez178165	314	1
eez178166	314	1
eez178167	314	1
eez178168	314	1
eez178169	314	1
eez178170	314	1
eez178171	314	1
eez178172	314	1
eez178173	314	1
eez178174	314	1
eez178175	314	1
eez178177	314	1
eez178178	314	1
eez178179	314	1
eez178180	314	1
eez178181	314	1
eez178182	314	1
eez178183	314	1
eez178184	314	1
eez178185	314	1
eez178187	314	1
eez178188	314	1
eez178189	314	1
eez178190	314	1
eez178191	314	1
eez178192	314	1
eez178193	314	1
eez178195	314	1
eez178197	314	1
eez178198	314	1
eez178200	314	1
eez178201	314	1
eez178204	314	1
eez178206	314	1
eez178207	314	1
eez178208	314	1
eez178370	314	1
eez178416	314	1
eez178555	314	1
eez178556	314	1
eez178559	314	1
eez178560	314	1
eez178561	314	1
eez178562	314	1
eez178564	314	1
eez178565	314	1
eez178566	314	1
eez178567	314	1
eez178568	314	1
eez178569	314	1
eez178570	314	1
eez178571	314	1
eez178573	314	1
eez178653	314	1
eez178656	314	1
eez188126	314	1
eez188127	314	1
eez188128	314	1
eez188129	314	1
eez188130	314	1
eez188131	314	1
eez188132	314	1
eez188133	314	1
eez188134	314	1
eez188135	314	1
eez188137	314	1
eez188138	314	1
eez188139	314	1
eez188141	314	1
eez188142	314	1
eez188144	314	1
eez188145	314	1
eez188146	314	1
eez188147	314	1
eez188148	314	1
eez188149	314	1
eez188150	314	1
eez188151	314	1
eez188152	314	1
eez188153	314	1
eez188154	314	1
eez188155	314	1
eez188156	314	1
eez188157	314	1
eez188158	314	1
eez188160	314	1
eez188161	314	1
eez188162	314	1
eez188163	314	1
eez188164	314	1
eez188165	314	1
eez188166	314	1
eez188168	314	1
eez188170	314	1
eez188171	314	1
eez188172	314	1
eez188293	314	1
eez188384	314	1
eez188554	314	1
eez188562	314	1
eez188570	314	1
esz118381	314	1
esz128088	314	1
esz128092	314	1
esz128094	314	1
esz128300	314	1
esz128338	314	1
esz128428	314	1
esz128434	314	1
esz128563	314	1
esz138129	314	1
esz138136	314	1
esz142643	314	1
esz148090	314	1
esz148091	314	1
esz148094	314	1
esz148095	314	1
esz148252	314	1
esz148255	314	1
esz148430	314	1
esz158123	314	1
esz158390	314	1
esz158391	314	1
esz158392	314	1
esz158393	314	1
esz158394	314	1
esz158483	314	1
esz168011	314	1
esz168097	314	1
esz168098	314	1
esz168100	314	1
esz168102	314	1
esz168103	314	1
esz168413	314	1
esz168414	314	1
esz168415	314	1
esz168417	314	1
esz168577	314	1
esz178209	314	1
esz178210	314	1
esz178211	314	1
esz178212	314	1
esz178214	314	1
esz178215	314	1
esz178216	314	1
esz178217	314	1
esz178218	314	1
esz178538	314	1
esz178539	314	1
esz178540	314	1
esz178541	314	1
esz178542	314	1
esz178543	314	1
esz178544	314	1
esz178546	314	1
esz178657	314	1
esz188054	314	1
esz188055	314	1
esz188056	314	1
esz188513	314	1
esz188514	314	1
esz188515	314	1
esz188516	314	1
esz188517	314	1
esz188518	314	1
esz188661	314	1
huz128471	314	1
huz128473	314	1
huz128478	314	1
huz138139	314	1
huz138140	314	1
huz138143	314	1
huz138544	314	1
huz138593	314	1
huz148151	314	1
huz148152	314	1
huz148155	314	1
huz148156	314	1
huz148157	314	1
huz148160	314	1
huz148161	314	1
huz148322	314	1
huz148323	314	1
huz148325	314	1
huz148326	314	1
huz148328	314	1
huz158124	314	1
huz158125	314	1
huz158126	314	1
huz158128	314	1
huz158129	314	1
huz158130	314	1
huz158132	314	1
huz158133	314	1
huz158134	314	1
huz158283	314	1
huz158286	314	1
huz158287	314	1
huz158459	314	1
huz158460	314	1
huz158461	314	1
huz158462	314	1
huz158463	314	1
huz158464	314	1
huz158465	314	1
huz158466	314	1
huz158467	314	1
huz158468	314	1
huz158470	314	1
huz158505	314	1
huz168170	314	1
huz168171	314	1
huz168172	314	1
huz168173	314	1
huz168174	314	1
huz168175	314	1
huz168176	314	1
huz168177	314	1
huz168178	314	1
huz168180	314	1
huz168181	314	1
huz168182	314	1
huz168183	314	1
huz168184	314	1
huz168256	314	1
huz168257	314	1
huz168258	314	1
huz168323	314	1
huz168528	314	1
huz168529	314	1
huz168531	314	1
huz168532	314	1
huz168533	314	1
huz168534	314	1
huz168535	314	1
huz178130	314	1
huz178131	314	1
huz178134	314	1
huz178136	314	1
huz178138	314	1
huz178142	314	1
huz178144	314	1
huz178145	314	1
huz178146	314	1
huz178147	314	1
huz178150	314	1
huz178151	314	1
huz178585	314	1
huz178587	314	1
huz178588	314	1
huz178590	314	1
idz128121	314	1
idz138151	314	1
idz138152	314	1
idz148007	314	1
idz148183	314	1
idz148184	314	1
idz148185	314	1
idz156003	314	1
idz158477	314	1
idz168476	314	1
idz168478	314	1
idz168479	314	1
idz168480	314	1
idz178095	314	1
idz178632	314	1
idz178633	314	1
idz188306	314	1
itz128034	314	1
itz148189	314	1
itz148404	314	1
itz158140	314	1
itz158141	314	1
itz168318	314	1
itz168319	314	1
itz168560	314	1
itz178001	314	1
itz178002	314	1
itz178003	314	1
itz178004	314	1
itz178429	314	1
itz188283	314	1
itz188373	314	1
itz188549	314	1
maz118459	314	1
maz128519	314	1
maz138158	314	1
maz138162	314	1
maz138546	314	1
maz148096	314	1
maz148099	314	1
maz148101	314	1
maz148330	314	1
maz148331	314	1
maz148333	314	1
maz148334	314	1
maz148335	314	1
maz148336	314	1
maz158142	314	1
maz158144	314	1
maz158146	314	1
maz158149	314	1
maz158374	314	1
maz158375	314	1
maz168186	314	1
maz168187	314	1
maz168189	314	1
maz168190	314	1
maz168351	314	1
maz178295	314	1
maz178296	314	1
maz178297	314	1
maz178298	314	1
maz178300	314	1
maz178301	314	1
maz178303	314	1
maz178304	314	1
maz178305	314	1
maz178306	314	1
maz178307	314	1
maz178310	314	1
maz178311	314	1
maz178432	314	1
maz178434	314	1
maz178437	314	1
maz188235	314	1
maz188253	314	1
maz188254	314	1
maz188258	314	1
maz188259	314	1
maz188260	314	1
maz188315	314	1
maz188443	314	1
maz188444	314	1
maz188445	314	1
maz188446	314	1
maz188447	314	1
maz188448	314	1
maz188449	314	1
maz188450	314	1
maz188451	314	1
maz188452	314	1
mez118359	314	1
mez128244	314	1
mez128247	314	1
mez128258	314	1
mez128259	314	1
mez128310	314	1
mez128384	314	1
mez128385	314	1
mez128388	314	1
mez128393	314	1
mez128397	314	1
mez138167	314	1
mez138169	314	1
mez138170	314	1
mez138172	314	1
mez138179	314	1
mez138182	314	1
mez138183	314	1
mez138470	314	1
mez138471	314	1
mez138475	314	1
mez142809	314	1
mez148008	314	1
mez148010	314	1
mez148011	314	1
mez148012	314	1
mez148013	314	1
mez148014	314	1
mez148017	314	1
mez148247	314	1
mez148337	314	1
mez148338	314	1
mez148339	314	1
mez148340	314	1
mez148342	314	1
mez148343	314	1
mez148389	314	1
mez148426	314	1
mez158151	314	1
mez158152	314	1
mez158153	314	1
mez158154	314	1
mez158155	314	1
mez158156	314	1
mez158159	314	1
mez158160	314	1
mez158161	314	1
mez158162	314	1
mez158163	314	1
mez158164	314	1
mez158166	314	1
mez158167	314	1
mez158170	314	1
mez158171	314	1
mez158298	314	1
mez158444	314	1
mez158445	314	1
mez158446	314	1
mez158447	314	1
mez158448	314	1
mez158449	314	1
mez158451	314	1
mez158492	314	1
mez158499	314	1
mez158500	314	1
mez167515	314	1
mez168267	314	1
mez168268	314	1
mez168269	314	1
mez168270	314	1
mez168271	314	1
mez168272	314	1
mez168273	314	1
mez168274	314	1
mez168275	314	1
mez168276	314	1
mez168277	314	1
mez168278	314	1
mez168279	314	1
mez168280	314	1
mez168282	314	1
mez168329	314	1
mez168352	314	1
mez168538	314	1
mez168539	314	1
mez168540	314	1
mez168541	314	1
mez168542	314	1
mez168543	314	1
mez168544	314	1
mez168545	314	1
mez168547	314	1
mez168548	314	1
mez168550	314	1
mez168551	314	1
mez168552	314	1
mez168553	314	1
mez168554	314	1
mez168555	314	1
mez168556	314	1
mez168557	314	1
mez177523	314	1
mez178313	314	1
mez178316	314	1
mez178317	314	1
mez178318	314	1
mez178319	314	1
mez178320	314	1
mez178321	314	1
mez178322	314	1
mez178323	314	1
mez178324	314	1
mez178325	314	1
mez178326	314	1
mez178327	314	1
mez178328	314	1
mez178331	314	1
mez178332	314	1
mez178333	314	1
mez178336	314	1
mez178337	314	1
mez178339	314	1
mez178341	314	1
mez178428	314	1
mez178594	314	1
mez178595	314	1
mez178596	314	1
mez178597	314	1
mez178598	314	1
mez178600	314	1
mez178601	314	1
mez178602	314	1
mez178604	314	1
mez178605	314	1
mez178606	314	1
mez178608	314	1
mez178609	314	1
mez178610	314	1
mez188261	314	1
mez188262	314	1
mez188263	314	1
mez188264	314	1
mez188266	314	1
mez188270	314	1
mez188271	314	1
mez188272	314	1
mez188273	314	1
mez188284	314	1
mez188285	314	1
mez188286	314	1
mez188287	314	1
mez188288	314	1
mez188580	314	1
mez188581	314	1
mez188582	314	1
mez188583	314	1
mez188584	314	1
mez188585	314	1
mez188586	314	1
mez188587	314	1
mez188591	314	1
mez188596	314	1
mez188597	314	1
mez188598	314	1
mez188600	314	1
mez188662	314	1
msz188015	314	1
msz188016	314	1
msz188017	314	1
msz188018	314	1
msz188019	314	1
msz188020	314	1
msz188021	314	1
msz188022	314	1
msz188023	314	1
msz188024	314	1
msz188289	314	1
msz188290	314	1
msz188505	314	1
nrz128500	314	1
nrz138184	314	1
nrz148222	314	1
phz118312	314	1
phz118318	314	1
phz118319	314	1
phz128036	314	1
phz128046	314	1
phz128054	314	1
phz128318	314	1
phz128323	314	1
phz128480	314	1
phz128482	314	1
phz128484	314	1
phz128490	314	1
phz128493	314	1
phz128494	314	1
phz128495	314	1
phz138188	314	1
phz138190	314	1
phz138193	314	1
phz138194	314	1
phz138195	314	1
phz138198	314	1
phz138202	314	1
phz138478	314	1
phz138479	314	1
phz138481	314	1
phz138482	314	1
phz138488	314	1
phz138569	314	1
phz138570	314	1
phz148019	314	1
phz148103	314	1
phz148104	314	1
phz148105	314	1
phz148107	314	1
phz148108	314	1
phz148109	314	1
phz148110	314	1
phz148112	314	1
phz148113	314	1
phz148115	314	1
phz148116	314	1
phz148118	314	1
phz148121	314	1
phz148123	314	1
phz148124	314	1
phz148125	314	1
phz148126	314	1
phz148127	314	1
phz148223	314	1
phz148344	314	1
phz148345	314	1
phz148347	314	1
phz148348	314	1
phz148349	314	1
phz148350	314	1
phz148351	314	1
phz148352	314	1
phz148353	314	1
phz148354	314	1
phz158173	314	1
phz158176	314	1
phz158179	314	1
phz158182	314	1
phz158183	314	1
phz158187	314	1
phz158193	314	1
phz158196	314	1
phz158197	314	1
phz158252	314	1
phz158255	314	1
phz158377	314	1
phz158378	314	1
phz158379	314	1
phz158380	314	1
phz158383	314	1
phz158385	314	1
phz158388	314	1
phz162023	314	1
phz162024	314	1
phz162025	314	1
phz162039	314	1
phz168199	314	1
phz168205	314	1
phz168206	314	1
phz168207	314	1
phz168210	314	1
phz168220	314	1
phz168222	314	1
phz168225	314	1
phz168378	314	1
phz168379	314	1
phz168380	314	1
phz168382	314	1
phz168384	314	1
phz168385	314	1
phz168388	314	1
phz168389	314	1
phz168391	314	1
phz168392	314	1
phz168394	314	1
phz168396	314	1
phz178371	314	1
phz178374	314	1
phz178378	314	1
phz178381	314	1
phz178382	314	1
phz178384	314	1
phz178385	314	1
phz178387	314	1
phz178403	314	1
phz178404	314	1
phz178405	314	1
phz178407	314	1
phz178408	314	1
phz178409	314	1
phz178411	314	1
phz178612	314	1
phz178614	314	1
phz178615	314	1
phz178617	314	1
phz178618	314	1
phz178619	314	1
phz178620	314	1
phz178622	314	1
phz178623	314	1
phz178625	314	1
phz178626	314	1
phz178627	314	1
phz178628	314	1
phz178660	314	1
phz188320	314	1
phz188321	314	1
phz188322	314	1
phz188323	314	1
phz188325	314	1
phz188327	314	1
phz188328	314	1
phz188331	314	1
phz188332	314	1
phz188333	314	1
phz188334	314	1
phz188338	314	1
phz188339	314	1
phz188345	314	1
phz188346	314	1
phz188347	314	1
phz188350	314	1
phz188352	314	1
phz188353	314	1
phz188355	314	1
phz188356	314	1
phz188357	314	1
phz188358	314	1
phz188361	314	1
phz188362	314	1
phz188363	314	1
phz188364	314	1
phz188365	314	1
phz188367	314	1
phz188368	314	1
phz188369	314	1
phz188370	314	1
phz188411	314	1
phz188426	314	1
phz188431	314	1
phz188432	314	1
phz188433	314	1
phz188434	314	1
ptz118435	314	1
ptz128195	314	1
ptz128348	314	1
ptz138207	314	1
ptz148397	314	1
ptz158200	314	1
ptz158203	314	1
ptz158204	314	1
ptz158205	314	1
ptz168104	314	1
ptz168105	314	1
ptz168108	314	1
ptz168377	314	1
ptz178042	314	1
ptz178045	314	1
ptz178046	314	1
ptz178049	314	1
ptz178050	314	1
ptz178051	314	1
ptz178052	314	1
ptz178055	314	1
ptz178056	314	1
ptz178520	314	1
qiz188545	314	1
qiz188609	314	1
qiz188618	314	1
rdz128213	314	1
rdz138209	314	1
rdz148130	314	1
rdz148131	314	1
rdz148134	314	1
rdz148136	314	1
rdz148137	314	1
rdz148251	314	1
rdz148386	314	1
rdz148398	314	1
rdz158257	314	1
rdz158258	314	1
rdz158261	314	1
rdz158452	314	1
rdz158453	314	1
rdz158454	314	1
rdz158455	314	1
rdz158457	314	1
rdz168033	314	1
rdz168034	314	1
rdz168035	314	1
rdz168036	314	1
rdz168037	314	1
rdz168038	314	1
rdz168343	314	1
rdz168344	314	1
rdz168354	314	1
rdz168355	314	1
rdz168356	314	1
rdz168357	314	1
rdz168358	314	1
rdz168359	314	1
rdz168361	314	1
rdz168363	314	1
rdz168364	314	1
rdz168365	314	1
rdz168366	314	1
rdz178220	314	1
rdz178221	314	1
rdz178222	314	1
rdz178223	314	1
rdz178224	314	1
rdz178226	314	1
rdz178227	314	1
rdz178228	314	1
rdz178230	314	1
rdz178231	314	1
rdz178233	314	1
rdz178234	314	1
rdz178235	314	1
rdz178236	314	1
rdz178238	314	1
rdz178239	314	1
rdz178240	314	1
rdz178242	314	1
rdz178243	314	1
rdz178244	314	1
rdz178246	314	1
rdz178247	314	1
rdz178412	314	1
rdz178425	314	1
rdz178426	314	1
rdz178576	314	1
rdz178577	314	1
rdz178579	314	1
rdz178580	314	1
rdz178582	314	1
rdz178642	314	1
rdz178643	314	1
rdz188244	314	1
rdz188245	314	1
rdz188246	314	1
rdz188247	314	1
rdz188249	314	1
rdz188637	314	1
rdz188638	314	1
rdz188639	314	1
rdz188641	314	1
rdz188642	314	1
rdz188644	314	1
rdz188645	314	1
rdz188646	314	1
rdz188647	314	1
rdz188648	314	1
rdz188649	314	1
rdz188652	314	1
smz128183	314	1
smz128185	314	1
smz128435	314	1
smz128438	314	1
smz128441	314	1
smz128443	314	1
smz128445	314	1
smz128446	314	1
smz138270	314	1
smz138274	314	1
smz138275	314	1
smz138283	314	1
smz138495	314	1
smz138499	314	1
smz138501	314	1
smz138502	314	1
smz138504	314	1
smz138506	314	1
smz138507	314	1
smz148140	314	1
smz148142	314	1
smz148143	314	1
smz148224	314	1
smz148231	314	1
smz148410	314	1
smz148412	314	1
smz148414	314	1
smz148416	314	1
smz148418	314	1
smz158207	314	1
smz158208	314	1
smz158209	314	1
smz158212	314	1
smz158214	314	1
smz158328	314	1
smz158329	314	1
smz158330	314	1
smz158332	314	1
smz158335	314	1
smz158336	314	1
smz158338	314	1
smz168017	314	1
smz168018	314	1
smz168019	314	1
smz168020	314	1
smz168021	314	1
smz168023	314	1
smz168025	314	1
smz168026	314	1
smz168029	314	1
smz168031	314	1
smz168441	314	1
smz168442	314	1
smz168444	314	1
smz168447	314	1
smz168450	314	1
smz168451	314	1
smz168452	314	1
smz168453	314	1
smz168455	314	1
smz168459	314	1
smz178005	314	1
smz178006	314	1
smz178008	314	1
smz178009	314	1
smz178010	314	1
smz178011	314	1
smz178012	314	1
smz178013	314	1
smz178014	314	1
smz178015	314	1
smz178016	314	1
smz178017	314	1
smz178019	314	1
smz178020	314	1
smz178021	314	1
smz178022	314	1
smz178023	314	1
smz178024	314	1
smz178414	314	1
smz178440	314	1
smz178442	314	1
smz178443	314	1
smz178444	314	1
smz178445	314	1
smz178446	314	1
smz178448	314	1
smz178449	314	1
smz178450	314	1
smz178451	314	1
smz178452	314	1
smz178453	314	1
smz178454	314	1
smz178456	314	1
smz178458	314	1
smz178459	314	1
smz178460	314	1
smz178461	314	1
smz178462	314	1
smz178463	314	1
smz188177	314	1
smz188183	314	1
smz188186	314	1
smz188187	314	1
smz188189	314	1
smz188190	314	1
smz188191	314	1
smz188525	314	1
smz188531	314	1
smz188535	314	1
smz188539	314	1
smz188541	314	1
srz178645	314	1
srz178646	314	1
srz178647	314	1
srz178648	314	1
srz178649	314	1
srz178650	314	1
srz188304	314	1
srz188305	314	1
srz188381	314	1
srz188382	314	1
srz188383	314	1
trz128068	314	1
trz128479	314	1
trz148409	314	1
trz158263	314	1
trz158264	314	1
trz168321	314	1
trz178636	314	1
trz188280	314	1
trz188281	314	1
ttz128341	314	1
ttz138213	314	1
ttz138288	314	1
ttz138573	314	1
ttz148145	314	1
ttz148146	314	1
ttz148400	314	1
ttz148402	314	1
ttz148407	314	1
ttz158268	314	1
ttz158271	314	1
ttz158272	314	1
ttz158274	314	1
ttz158471	314	1
ttz158473	314	1
ttz168259	314	1
ttz168260	314	1
ttz168261	314	1
ttz168265	314	1
ttz168266	314	1
ttz168468	314	1
ttz168470	314	1
ttz168472	314	1
ttz168473	314	1
ttz168474	314	1
ttz178342	314	1
ttz178343	314	1
ttz178344	314	1
ttz178345	314	1
ttz178346	314	1
ttz178347	314	1
ttz178348	314	1
ttz178349	314	1
ttz178350	314	1
ttz178351	314	1
ttz178352	314	1
ttz178473	314	1
ttz178474	314	1
ttz178475	314	1
ttz178476	314	1
ttz178477	314	1
ttz178478	314	1
ttz178479	314	1
ttz178480	314	1
ttz178482	314	1
ttz178483	314	1
ttz178484	314	1
ttz178485	314	1
ttz188222	314	1
ttz188223	314	1
ttz188225	314	1
ttz188226	314	1
ttz188227	314	1
ttz188228	314	1
ttz188230	314	1
ttz188231	314	1
ttz188453	314	1
ttz188454	314	1
ttz188455	314	1
ttz188456	314	1
ttz188457	314	1
ttz188458	314	1
ttz188459	314	1
ttz188461	314	1
ee5110547	315	1
ee5110550	315	1
ees142858	316	1
ee1120971	317	1
ee2110522	317	1
ee1130447	318	1
ee1130484	318	1
ee1140421	318	1
ee1140426	318	1
ee1150432	318	1
ee1150436	318	1
ee1150450	318	1
ee1150451	318	1
ee1150488	318	1
ee1150490	318	1
ee1150493	318	1
ee1150494	318	1
ee1150691	318	1
ee3140526	318	1
ee1130484	319	1
ee1150429	319	1
ee1150439	319	1
ee3150511	319	1
ee3150513	319	1
ee3150518	319	1
ee3150520	319	1
ee3150523	319	1
ee3150524	319	1
ee3150525	319	1
ee3150526	319	1
ee3150529	319	1
ee3150531	319	1
ee1150045	320	1
ee1150111	320	1
ee1150427	320	1
ee1150448	320	1
ee1150465	320	1
ee1150468	320	1
ee1150730	320	1
ee3150506	320	1
ee3150507	320	1
ee3150509	320	1
ee3150543	320	1
ee1150504	327	1
eet172308	330	1
eet182554	330	1
eet182555	330	1
eet182556	330	1
eet182557	330	1
eet182559	330	1
eet182560	330	1
eet182561	330	1
eet182562	330	1
eet182563	330	1
eet182564	330	1
eet182565	330	1
eet182566	330	1
eet182568	330	1
eet182569	330	1
eet182570	330	1
eet182571	330	1
eet182572	330	1
eet182574	330	1
eet182575	330	1
eet182727	330	1
eet182865	330	1
eea172232	332	1
eea172233	332	1
eea172664	332	1
eea172665	332	1
eee182388	333	1
eee172234	335	1
eee172235	335	1
eee172236	335	1
eee172238	335	1
eee172239	335	1
eee172240	335	1
eee172241	335	1
eee172765	335	1
eee172857	335	1
eee172871	335	1
eee172872	335	1
een172257	336	1
een172247	337	1
een172248	337	1
een172628	337	1
een172668	337	1
een172670	337	1
een172671	337	1
een172672	337	1
een172687	337	1
een172838	337	1
een172855	337	1
eep172258	339	1
eep172262	339	1
eep172265	339	1
eep172267	339	1
eep172268	339	1
eep172674	339	1
eep172675	339	1
eep172863	339	1
eep172866	339	1
ees172287	340	1
ees172288	340	1
ees172289	340	1
ees162591	341	1
ees172281	341	1
ees172677	341	1
eet162646	342	1
eet172291	342	1
eet172292	342	1
eet172294	342	1
eet172295	342	1
eet172302	342	1
eet172304	342	1
eet172305	342	1
eet172306	342	1
eet172680	342	1
eet172681	342	1
eet172839	342	1
eet172840	342	1
eet172841	342	1
eet172864	342	1
eet162645	343	1
eet172296	343	1
eet172297	343	1
eet172299	343	1
eet172300	343	1
eet172303	343	1
eet172307	343	1
eet172856	343	1
eey147524	344	1
eey147536	344	1
eey157520	344	1
eey157538	344	1
eey157539	344	1
eey157542	344	1
eey157543	344	1
eey157545	344	1
eey167520	344	1
eey167521	344	1
eey167523	344	1
eey167538	344	1
eey177527	344	1
eey177528	344	1
eey177529	344	1
eey177531	344	1
eey177532	344	1
eey177540	344	1
eey177547	344	1
eey187535	344	1
bb1140053	345	1
bb1180001	345	1
bb1180002	345	1
bb1180004	345	1
bb1180005	345	1
bb1180006	345	1
bb1180008	345	1
bb1180012	345	1
bb1180016	345	1
bb1180017	345	1
bb1180019	345	1
bb1180020	345	1
bb1180021	345	1
bb1180023	345	1
bb1180024	345	1
bb1180025	345	1
bb1180029	345	1
bb1180030	345	1
bb1180031	345	1
bb1180032	345	1
bb1180034	345	1
bb1180036	345	1
bb1180037	345	1
bb1180038	345	1
bb1180039	345	1
bb1180041	345	1
bb1180042	345	1
bb1180044	345	1
bb1180045	345	1
bb1180046	345	1
bb5180051	345	1
bb5180052	345	1
bb5180053	345	1
bb5180054	345	1
bb5180056	345	1
bb5180057	345	1
bb5180058	345	1
bb5180060	345	1
bb5180063	345	1
bb5180064	345	1
bb5180066	345	1
ce1140395	345	1
ce1180074	345	1
ce1180076	345	1
ce1180078	345	1
ce1180079	345	1
ce1180083	345	1
ce1180084	345	1
ce1180085	345	1
ce1180086	345	1
ce1180090	345	1
ce1180094	345	1
ce1180095	345	1
ce1180101	345	1
ce1180104	345	1
ce1180106	345	1
ce1180108	345	1
ce1180110	345	1
ce1180112	345	1
ce1180117	345	1
ce1180118	345	1
ce1180120	345	1
ce1180124	345	1
ce1180132	345	1
ce1180133	345	1
ce1180141	345	1
ce1180146	345	1
ce1180148	345	1
ce1180149	345	1
ce1180150	345	1
ce1180151	345	1
ce1180154	345	1
ce1180157	345	1
ce1180158	345	1
ce1180163	345	1
ce1180164	345	1
ce1180165	345	1
ce1180167	345	1
ce1180168	345	1
ce1180169	345	1
ce1180177	345	1
ch1130080	345	1
ch1180187	345	1
ch1180189	345	1
ch1180191	345	1
ch1180193	345	1
ch1180194	345	1
ch1180195	345	1
ch1180197	345	1
ch1180199	345	1
ch1180200	345	1
ch1180201	345	1
ch1180202	345	1
ch1180203	345	1
ch1180205	345	1
ch1180208	345	1
ch1180210	345	1
ch1180211	345	1
ch1180213	345	1
ch1180214	345	1
ch1180215	345	1
ch1180216	345	1
ch1180218	345	1
ch1180220	345	1
ch1180221	345	1
ch1180225	345	1
ch1180227	345	1
ch1180229	345	1
ch1180230	345	1
ch1180234	345	1
ch1180239	345	1
ch1180242	345	1
ch1180247	345	1
ch1180248	345	1
ch1180249	345	1
ch1180250	345	1
ch1180251	345	1
ch1180252	345	1
ch1180253	345	1
ch1180254	345	1
ch1180255	345	1
ch1180257	345	1
ch1180259	345	1
ch1180260	345	1
ch1180261	345	1
ch7180271	345	1
ch7180272	345	1
ch7180277	345	1
ch7180278	345	1
ch7180279	345	1
ch7180280	345	1
ch7180281	345	1
ch7180282	345	1
ch7180285	345	1
ch7180287	345	1
ch7180288	345	1
ch7180290	345	1
ch7180293	345	1
ch7180295	345	1
ch7180296	345	1
ch7180297	345	1
ch7180299	345	1
ch7180301	345	1
ch7180302	345	1
ch7180304	345	1
ch7180305	345	1
ch7180306	345	1
ch7180311	345	1
ch7180315	345	1
ch7180317	345	1
cs1180322	345	1
cs1180323	345	1
cs1180327	345	1
cs1180330	345	1
cs1180332	345	1
cs1180334	345	1
cs1180335	345	1
cs1180340	345	1
cs1180344	345	1
cs1180345	345	1
cs1180346	345	1
cs1180348	345	1
cs1180350	345	1
cs1180351	345	1
cs1180355	345	1
cs1180360	345	1
cs1180362	345	1
cs1180366	345	1
cs1180370	345	1
cs1180372	345	1
cs1180373	345	1
cs1180374	345	1
cs1180377	345	1
cs1180380	345	1
cs1180381	345	1
cs1180385	345	1
cs1180386	345	1
cs1180389	345	1
cs1180390	345	1
cs1180392	345	1
cs1180393	345	1
cs1180394	345	1
cs1180395	345	1
cs1180397	345	1
cs5180401	345	1
cs5180402	345	1
cs5180403	345	1
cs5180404	345	1
cs5180405	345	1
cs5180408	345	1
cs5180412	345	1
cs5180413	345	1
cs5180419	345	1
cs5180420	345	1
cs5180422	345	1
cs5180425	345	1
cs5180426	345	1
ee1180433	345	1
ee1180434	345	1
ee1180436	345	1
ee1180437	345	1
ee1180439	345	1
ee1180441	345	1
ee1180443	345	1
ee1180444	345	1
ee1180446	345	1
ee1180447	345	1
ee1180452	345	1
ee1180454	345	1
ee1180456	345	1
ee1180458	345	1
ee1180459	345	1
ee1180460	345	1
ee1180467	345	1
ee1180468	345	1
ee1180469	345	1
ee1180470	345	1
ee1180473	345	1
ee1180476	345	1
ee1180482	345	1
ee1180483	345	1
ee1180485	345	1
ee1180486	345	1
ee1180489	345	1
ee1180491	345	1
ee1180492	345	1
ee1180496	345	1
ee1180497	345	1
ee1180504	345	1
ee1180505	345	1
ee1180506	345	1
ee1180509	345	1
ee1180511	345	1
ee3180521	345	1
ee3180523	345	1
ee3180524	345	1
ee3180525	345	1
ee3180527	345	1
ee3180528	345	1
ee3180530	345	1
ee3180531	345	1
ee3180533	345	1
ee3180535	345	1
ee3180541	345	1
ee3180542	345	1
ee3180545	345	1
ee3180546	345	1
ee3180547	345	1
ee3180549	345	1
ee3180553	345	1
ee3180554	345	1
ee3180556	345	1
ee3180557	345	1
ee3180560	345	1
ee3180562	345	1
ee3180563	345	1
ee3180565	345	1
ee3180569	345	1
me1130671	345	1
me1170563	345	1
me1180581	345	1
me1180582	345	1
me1180584	345	1
me1180588	345	1
me1180589	345	1
me1180590	345	1
me1180592	345	1
me1180597	345	1
me1180599	345	1
me1180600	345	1
me1180603	345	1
me1180604	345	1
me1180606	345	1
me1180608	345	1
me1180611	345	1
me1180612	345	1
me1180614	345	1
me1180615	345	1
me1180616	345	1
me1180622	345	1
me1180624	345	1
me1180626	345	1
me1180627	345	1
me1180628	345	1
me1180630	345	1
me1180631	345	1
me1180633	345	1
me1180634	345	1
me1180641	345	1
me1180644	345	1
me1180645	345	1
me1180650	345	1
me1180651	345	1
me1180654	345	1
me1180656	345	1
me1180658	345	1
me2180661	345	1
me2180663	345	1
me2180664	345	1
me2180666	345	1
me2180668	345	1
me2180670	345	1
me2180672	345	1
me2180674	345	1
me2180675	345	1
me2180676	345	1
me2180678	345	1
me2180679	345	1
me2180681	345	1
me2180682	345	1
me2180687	345	1
me2180688	345	1
me2180690	345	1
me2180691	345	1
me2180692	345	1
me2180694	345	1
me2180695	345	1
me2180696	345	1
me2180698	345	1
me2180699	345	1
me2180700	345	1
me2180701	345	1
me2180703	345	1
me2180706	345	1
me2180707	345	1
me2180709	345	1
me2180712	345	1
me2180713	345	1
me2180715	345	1
me2180716	345	1
me2180717	345	1
me2180718	345	1
me2180719	345	1
me2180722	345	1
me2180723	345	1
me2180725	345	1
me2180726	345	1
me2180728	345	1
me2180730	345	1
me2180732	345	1
me2180733	345	1
me2180736	345	1
mt1180738	345	1
mt1180739	345	1
mt1180742	345	1
mt1180744	345	1
mt1180746	345	1
mt1180748	345	1
mt1180755	345	1
mt1180757	345	1
mt1180758	345	1
mt1180760	345	1
mt1180762	345	1
mt1180770	345	1
mt6180777	345	1
mt6180783	345	1
mt6180785	345	1
mt6180790	345	1
mt6180793	345	1
mt6180794	345	1
mt6180795	345	1
mt6180797	345	1
ph1160597	345	1
ph1170852	345	1
ph1180801	345	1
ph1180802	345	1
ph1180803	345	1
ph1180810	345	1
ph1180812	345	1
ph1180813	345	1
ph1180814	345	1
ph1180817	345	1
ph1180820	345	1
ph1180821	345	1
ph1180822	345	1
ph1180825	345	1
ph1180826	345	1
ph1180827	345	1
ph1180828	345	1
ph1180830	345	1
ph1180831	345	1
ph1180832	345	1
ph1180833	345	1
ph1180836	345	1
ph1180838	345	1
ph1180839	345	1
ph1180843	345	1
ph1180844	345	1
ph1180845	345	1
ph1180846	345	1
ph1180848	345	1
ph1180850	345	1
ph1180851	345	1
ph1180852	345	1
ph1180854	345	1
ph1180858	345	1
ph1180859	345	1
ph1180860	345	1
tt1170895	345	1
tt1180866	345	1
tt1180872	345	1
tt1180874	345	1
tt1180875	345	1
tt1180876	345	1
tt1180877	345	1
tt1180879	345	1
tt1180881	345	1
tt1180882	345	1
tt1180887	345	1
tt1180888	345	1
tt1180889	345	1
tt1180890	345	1
tt1180892	345	1
tt1180894	345	1
tt1180896	345	1
tt1180897	345	1
tt1180900	345	1
tt1180901	345	1
tt1180903	345	1
tt1180905	345	1
tt1180906	345	1
tt1180910	345	1
tt1180911	345	1
tt1180912	345	1
tt1180915	345	1
tt1180920	345	1
tt1180921	345	1
tt1180922	345	1
tt1180923	345	1
tt1180925	345	1
tt1180927	345	1
tt1180928	345	1
tt1180930	345	1
tt1180933	345	1
tt1180934	345	1
tt1180936	345	1
tt1180939	345	1
tt1180940	345	1
tt1180946	345	1
tt1180947	345	1
tt1180950	345	1
tt1180951	345	1
tt1180952	345	1
tt1180954	345	1
tt1180955	345	1
tt1180956	345	1
tt1180960	345	1
tt1180962	345	1
tt1180963	345	1
tt1180964	345	1
tt1180965	345	1
tt1180967	345	1
tt1180968	345	1
tt1180969	345	1
tt1180975	345	1
ee1130515	346	1
ee1160410	346	1
ee1160477	346	1
ee1160482	346	1
ee1160483	346	1
ee1170093	346	1
ee1170249	346	1
ee1170306	346	1
ee1170345	346	1
ee1170431	346	1
ee1170432	346	1
ee1170433	346	1
ee1170434	346	1
ee1170435	346	1
ee1170436	346	1
ee1170437	346	1
ee1170438	346	1
ee1170439	346	1
ee1170440	346	1
ee1170441	346	1
ee1170442	346	1
ee1170443	346	1
ee1170444	346	1
ee1170445	346	1
ee1170446	346	1
ee1170447	346	1
ee1170448	346	1
ee1170449	346	1
ee1170450	346	1
ee1170451	346	1
ee1170452	346	1
ee1170453	346	1
ee1170454	346	1
ee1170455	346	1
ee1170456	346	1
ee1170457	346	1
ee1170458	346	1
ee1170459	346	1
ee1170460	346	1
ee1170461	346	1
ee1170462	346	1
ee1170463	346	1
ee1170464	346	1
ee1170465	346	1
ee1170466	346	1
ee1170467	346	1
ee1170468	346	1
ee1170469	346	1
ee1170470	346	1
ee1170471	346	1
ee1170472	346	1
ee1170473	346	1
ee1170474	346	1
ee1170475	346	1
ee1170476	346	1
ee1170477	346	1
ee1170478	346	1
ee1170479	346	1
ee1170480	346	1
ee1170482	346	1
ee1170483	346	1
ee1170484	346	1
ee1170485	346	1
ee1170486	346	1
ee1170490	346	1
ee1170491	346	1
ee1170492	346	1
ee1170494	346	1
ee1170495	346	1
ee1170496	346	1
ee1170497	346	1
ee1170498	346	1
ee1170500	346	1
ee1170501	346	1
ee1170502	346	1
ee1170504	346	1
ee1170505	346	1
ee1170536	346	1
ee1170544	346	1
ee1170565	346	1
ee1170584	346	1
ee1170597	346	1
ee1170599	346	1
ee1170608	346	1
ee1170704	346	1
ee1170809	346	1
ee1170937	346	1
ee1170938	346	1
ee3170010	346	1
ee3170019	346	1
ee3170149	346	1
ee3170221	346	1
ee3170245	346	1
ee3170511	346	1
ee3170512	346	1
ee3170513	346	1
ee3170514	346	1
ee3170515	346	1
ee3170516	346	1
ee3170517	346	1
ee3170518	346	1
ee3170519	346	1
ee3170522	346	1
ee3170523	346	1
ee3170524	346	1
ee3170525	346	1
ee3170526	346	1
ee3170527	346	1
ee3170528	346	1
ee3170529	346	1
ee3170531	346	1
ee3170532	346	1
ee3170533	346	1
ee3170534	346	1
ee3170535	346	1
ee3170537	346	1
ee3170538	346	1
ee3170539	346	1
ee3170541	346	1
ee3170542	346	1
ee3170543	346	1
ee3170545	346	1
ee3170546	346	1
ee3170547	346	1
ee3170548	346	1
ee3170549	346	1
ee3170550	346	1
ee3170551	346	1
ee3170552	346	1
ee3170553	346	1
ee3170554	346	1
ee3170555	346	1
ee3170654	346	1
ee3170872	346	1
me1170564	346	1
mt1140584	346	1
mt1160634	346	1
mt1160639	346	1
mt1160640	346	1
mt1170213	346	1
mt1170287	346	1
mt1170520	346	1
mt1170530	346	1
mt1170721	346	1
mt1170722	346	1
mt1170723	346	1
mt1170724	346	1
mt1170725	346	1
mt1170726	346	1
mt1170727	346	1
mt1170728	346	1
mt1170729	346	1
mt1170730	346	1
mt1170731	346	1
mt1170732	346	1
mt1170733	346	1
mt1170734	346	1
mt1170735	346	1
mt1170736	346	1
mt1170737	346	1
mt1170738	346	1
mt1170739	346	1
mt1170740	346	1
mt1170741	346	1
mt1170742	346	1
mt1170743	346	1
mt1170744	346	1
mt1170745	346	1
mt1170746	346	1
mt1170747	346	1
mt1170748	346	1
mt1170749	346	1
mt1170750	346	1
mt1170751	346	1
mt1170752	346	1
mt1170753	346	1
mt1170754	346	1
mt1170755	346	1
mt1170756	346	1
mt1170772	346	1
mt5120605	346	1
mt6150552	346	1
mt6150570	346	1
mt6170078	346	1
mt6170207	346	1
mt6170250	346	1
mt6170499	346	1
mt6170771	346	1
mt6170773	346	1
mt6170774	346	1
mt6170775	346	1
mt6170776	346	1
mt6170777	346	1
mt6170778	346	1
mt6170779	346	1
mt6170780	346	1
mt6170781	346	1
mt6170782	346	1
mt6170783	346	1
mt6170784	346	1
mt6170785	346	1
mt6170786	346	1
mt6170787	346	1
mt6170788	346	1
mt6170789	346	1
mt6170855	346	1
ph1140795	346	1
ph1140805	346	1
ph1150784	346	1
ph1150788	346	1
ph1150791	346	1
ph1150798	346	1
ph1150814	346	1
ph1160547	346	1
ph1160552	346	1
ph1160557	346	1
ph1160564	346	1
ph1160567	346	1
ph1160569	346	1
ph1160574	346	1
ph1160581	346	1
ph1160585	346	1
ph1160592	346	1
ph1160594	346	1
ph1160596	346	1
ph1160599	346	1
ph1170801	346	1
ph1170802	346	1
ph1170803	346	1
ph1170804	346	1
ph1170805	346	1
ph1170806	346	1
ph1170807	346	1
ph1170808	346	1
ph1170810	346	1
ph1170811	346	1
ph1170812	346	1
ph1170813	346	1
ph1170814	346	1
ph1170816	346	1
ph1170818	346	1
ph1170819	346	1
ph1170820	346	1
ph1170821	346	1
ph1170822	346	1
ph1170823	346	1
ph1170824	346	1
ph1170826	346	1
ph1170827	346	1
ph1170828	346	1
ph1170829	346	1
ph1170830	346	1
ph1170831	346	1
ph1170832	346	1
ph1170834	346	1
ph1170835	346	1
ph1170838	346	1
ph1170839	346	1
ph1170840	346	1
ph1170841	346	1
ph1170843	346	1
ph1170844	346	1
ph1170845	346	1
ph1170847	346	1
ph1170848	346	1
ph1170849	346	1
ph1170850	346	1
ph1170851	346	1
ph1170853	346	1
ph1170854	346	1
ph1170856	346	1
ph1170857	346	1
ph1170859	346	1
ph1170860	346	1
ph1170942	346	1
tt1170966	346	1
cs1130237	347	1
cs1150221	347	1
cs1160313	347	1
cs1170219	347	1
cs1170321	347	1
cs1170322	347	1
cs1170323	347	1
cs1170324	347	1
cs1170325	347	1
cs1170326	347	1
cs1170327	347	1
cs1170328	347	1
cs1170329	347	1
cs1170330	347	1
cs1170331	347	1
cs1170332	347	1
cs1170333	347	1
cs1170334	347	1
cs1170335	347	1
cs1170336	347	1
cs1170337	347	1
cs1170338	347	1
cs1170339	347	1
cs1170340	347	1
cs1170342	347	1
cs1170343	347	1
cs1170344	347	1
cs1170346	347	1
cs1170347	347	1
cs1170348	347	1
cs1170349	347	1
cs1170350	347	1
cs1170351	347	1
cs1170352	347	1
cs1170353	347	1
cs1170354	347	1
cs1170355	347	1
cs1170356	347	1
cs1170357	347	1
cs1170358	347	1
cs1170359	347	1
cs1170360	347	1
cs1170361	347	1
cs1170362	347	1
cs1170363	347	1
cs1170364	347	1
cs1170365	347	1
cs1170366	347	1
cs1170367	347	1
cs1170368	347	1
cs1170369	347	1
cs1170370	347	1
cs1170371	347	1
cs1170372	347	1
cs1170373	347	1
cs1170374	347	1
cs1170375	347	1
cs1170376	347	1
cs1170377	347	1
cs1170378	347	1
cs1170379	347	1
cs1170380	347	1
cs1170381	347	1
cs1170382	347	1
cs1170383	347	1
cs1170384	347	1
cs1170385	347	1
cs1170386	347	1
cs1170387	347	1
cs1170388	347	1
cs1170389	347	1
cs1170390	347	1
cs1170416	347	1
cs1170481	347	1
cs1170487	347	1
cs1170489	347	1
cs1170503	347	1
cs1170540	347	1
cs1170589	347	1
cs1170790	347	1
cs1170836	347	1
cs5160390	347	1
cs5170401	347	1
cs5170402	347	1
cs5170403	347	1
cs5170404	347	1
cs5170406	347	1
cs5170407	347	1
cs5170408	347	1
cs5170409	347	1
cs5170410	347	1
cs5170411	347	1
cs5170412	347	1
cs5170413	347	1
cs5170414	347	1
cs5170415	347	1
cs5170417	347	1
cs5170419	347	1
cs5170420	347	1
cs5170421	347	1
cs5170422	347	1
cs5170488	347	1
cs5170493	347	1
cs5170521	347	1
cs5170602	347	1
ee1160477	347	1
ee1170345	347	1
ee3170533	347	1
mt1160634	347	1
ph1140795	347	1
ph1150795	347	1
ph1150810	347	1
ph1150817	347	1
ph1150834	347	1
ph1160544	347	1
ee1120971	348	1
ee1160410	348	1
ee1160444	348	1
ee1160452	348	1
ee1160453	348	1
ee1160474	348	1
ee1160476	348	1
ee1160477	348	1
ee1160483	348	1
ee1170093	348	1
ee1170249	348	1
ee1170306	348	1
ee1170345	348	1
ee1170431	348	1
ee1170432	348	1
ee1170433	348	1
ee1170434	348	1
ee1170435	348	1
ee1170436	348	1
ee1170437	348	1
ee1170438	348	1
ee1170439	348	1
ee1170440	348	1
ee1170441	348	1
ee1170442	348	1
ee1170443	348	1
ee1170444	348	1
ee1170445	348	1
ee1170446	348	1
ee1170447	348	1
ee1170448	348	1
ee1170449	348	1
ee1170450	348	1
ee1170451	348	1
ee1170452	348	1
ee1170453	348	1
ee1170454	348	1
ee1170455	348	1
ee1170456	348	1
ee1170457	348	1
ee1170458	348	1
ee1170459	348	1
ee1170460	348	1
ee1170461	348	1
ee1170462	348	1
ee1170463	348	1
ee1170464	348	1
ee1170465	348	1
ee1170466	348	1
ee1170467	348	1
ee1170468	348	1
ee1170469	348	1
ee1170470	348	1
ee1170471	348	1
ee1170472	348	1
ee1170473	348	1
ee1170474	348	1
ee1170475	348	1
ee1170476	348	1
ee1170477	348	1
ee1170478	348	1
ee1170479	348	1
ee1170480	348	1
ee1170482	348	1
ee1170483	348	1
ee1170484	348	1
ee1170485	348	1
ee1170486	348	1
ee1170490	348	1
ee1170491	348	1
ee1170492	348	1
ee1170494	348	1
ee1170495	348	1
ee1170496	348	1
ee1170497	348	1
ee1170498	348	1
ee1170500	348	1
ee1170501	348	1
ee1170502	348	1
ee1170504	348	1
ee1170505	348	1
ee1170536	348	1
ee1170544	348	1
ee1170565	348	1
ee1170584	348	1
ee1170597	348	1
ee1170599	348	1
ee1170608	348	1
ee1170704	348	1
ee1170809	348	1
ee1170937	348	1
ee1170938	348	1
ee2110522	348	1
ee1150430	349	1
ee1160474	349	1
ee1170093	349	1
ee1170249	349	1
ee1170306	349	1
ee1170431	349	1
ee1170432	349	1
ee1170433	349	1
ee1170434	349	1
ee1170435	349	1
ee1170436	349	1
ee1170437	349	1
ee1170438	349	1
ee1170439	349	1
ee1170440	349	1
ee1170441	349	1
ee1170442	349	1
ee1170443	349	1
ee1170444	349	1
ee1170445	349	1
ee1170446	349	1
ee1170447	349	1
ee1170448	349	1
ee1170449	349	1
ee1170450	349	1
ee1170451	349	1
ee1170452	349	1
ee1170453	349	1
ee1170454	349	1
ee1170455	349	1
ee1170456	349	1
ee1170457	349	1
ee1170458	349	1
ee1170459	349	1
ee1170460	349	1
ee1170461	349	1
ee1170462	349	1
ee1170463	349	1
ee1170464	349	1
ee1170465	349	1
ee1170466	349	1
ee1170467	349	1
ee1170468	349	1
ee1170469	349	1
ee1170470	349	1
ee1170471	349	1
ee1170472	349	1
ee1170473	349	1
ee1170474	349	1
ee1170475	349	1
ee1170476	349	1
ee1170477	349	1
ee1170479	349	1
ee1170480	349	1
ee1170482	349	1
ee1170483	349	1
ee1170484	349	1
ee1170485	349	1
ee1170486	349	1
ee1170490	349	1
ee1170491	349	1
ee1170492	349	1
ee1170494	349	1
ee1170495	349	1
ee1170496	349	1
ee1170497	349	1
ee1170498	349	1
ee1170500	349	1
ee1170501	349	1
ee1170502	349	1
ee1170504	349	1
ee1170505	349	1
ee1170536	349	1
ee1170544	349	1
ee1170565	349	1
ee1170584	349	1
ee1170597	349	1
ee1170599	349	1
ee1170608	349	1
ee1170704	349	1
ee1170809	349	1
ee1170937	349	1
ee1170938	349	1
ee3170010	349	1
ee3170019	349	1
ee3170149	349	1
ee3170221	349	1
ee3170245	349	1
ee3170511	349	1
ee3170512	349	1
ee3170513	349	1
ee3170514	349	1
ee3170515	349	1
ee3170516	349	1
ee3170517	349	1
ee3170518	349	1
ee3170519	349	1
ee3170522	349	1
ee3170523	349	1
ee3170524	349	1
ee3170525	349	1
ee3170526	349	1
ee3170527	349	1
ee3170528	349	1
ee3170529	349	1
ee3170531	349	1
ee3170532	349	1
ee3170534	349	1
ee3170535	349	1
ee3170537	349	1
ee3170538	349	1
ee3170539	349	1
ee3170541	349	1
ee3170542	349	1
ee3170543	349	1
ee3170545	349	1
ee3170546	349	1
ee3170547	349	1
ee3170548	349	1
ee3170549	349	1
ee3170550	349	1
ee3170551	349	1
ee3170552	349	1
ee3170553	349	1
ee3170554	349	1
ee3170555	349	1
ee3170654	349	1
ee3170872	349	1
ee5110563	349	1
ee3170010	350	1
ee3170019	350	1
ee3170149	350	1
ee3170221	350	1
ee3170245	350	1
ee3170511	350	1
ee3170512	350	1
ee3170513	350	1
ee3170514	350	1
ee3170515	350	1
ee3170516	350	1
ee3170517	350	1
ee3170518	350	1
ee3170519	350	1
ee3170522	350	1
ee3170523	350	1
ee3170524	350	1
ee3170525	350	1
ee3170526	350	1
ee3170527	350	1
ee3170528	350	1
ee3170529	350	1
ee3170531	350	1
ee3170532	350	1
ee3170533	350	1
ee3170534	350	1
ee3170535	350	1
ee3170537	350	1
ee3170538	350	1
ee3170539	350	1
ee3170541	350	1
ee3170542	350	1
ee3170543	350	1
ee3170545	350	1
ee3170546	350	1
ee3170547	350	1
ee3170548	350	1
ee3170549	350	1
ee3170550	350	1
ee3170551	350	1
ee3170552	350	1
ee3170553	350	1
ee3170554	350	1
ee3170555	350	1
ee3170654	350	1
ee3170872	350	1
cs1150202	351	1
cs1150217	351	1
ee1120971	351	1
ee1130447	351	1
ee1130476	351	1
ee1130483	351	1
ee1130515	351	1
ee1150045	351	1
ee1150379	351	1
ee1150425	351	1
ee1150426	351	1
ee1150428	351	1
ee1150438	351	1
ee1150439	351	1
ee1150446	351	1
ee1150450	351	1
ee1150454	351	1
ee1150455	351	1
ee1150456	351	1
ee1150462	351	1
ee1150464	351	1
ee1150465	351	1
ee1150466	351	1
ee1150472	351	1
ee1150474	351	1
ee1150479	351	1
ee1150481	351	1
ee1150487	351	1
ee1150488	351	1
ee1150781	351	1
ee1160071	351	1
ee1160411	351	1
ee1160417	351	1
ee1160419	351	1
ee1160420	351	1
ee1160423	351	1
ee1160425	351	1
ee1160429	351	1
ee1160435	351	1
ee1160436	351	1
ee1160437	351	1
ee1160440	351	1
ee1160445	351	1
ee1160450	351	1
ee1160451	351	1
ee1160452	351	1
ee1160453	351	1
ee1160454	351	1
ee1160455	351	1
ee1160456	351	1
ee1160457	351	1
ee1160458	351	1
ee1160459	351	1
ee1160460	351	1
ee1160461	351	1
ee1160462	351	1
ee1160463	351	1
ee1160464	351	1
ee1160465	351	1
ee1160468	351	1
ee1160472	351	1
ee1160473	351	1
ee1160474	351	1
ee1160475	351	1
ee1160476	351	1
ee1160478	351	1
ee1160480	351	1
ee1160481	351	1
ee1160482	351	1
ee1160484	351	1
ee1160694	351	1
ee1160825	351	1
ee1160835	351	1
ee2110522	351	1
ee3140503	351	1
ee3150501	351	1
ee3150502	351	1
ee3150503	351	1
ee3150506	351	1
ee3150507	351	1
ee3150508	351	1
ee3150510	351	1
ee3150511	351	1
ee3150512	351	1
ee3150513	351	1
ee3150514	351	1
ee3150518	351	1
ee3150520	351	1
ee3150523	351	1
ee3150526	351	1
ee3150531	351	1
ee3150535	351	1
ee3150540	351	1
ee3160042	351	1
ee3160490	351	1
ee3160493	351	1
ee3160495	351	1
ee3160496	351	1
ee3160497	351	1
ee3160498	351	1
ee3160500	351	1
ee3160501	351	1
ee3160504	351	1
ee3160507	351	1
ee3160510	351	1
ee3160511	351	1
ee3160515	351	1
ee3160517	351	1
ee3160521	351	1
ee3160522	351	1
ee3160524	351	1
ee3160525	351	1
ee3160528	351	1
ee3160530	351	1
ee3160531	351	1
ee3160533	351	1
ee3160534	351	1
ee3160769	351	1
me1150668	351	1
ee1100479	352	1
ee1120971	352	1
ee1130447	352	1
ee1130476	352	1
ee1130483	352	1
ee1130501	352	1
ee1140421	352	1
ee1140437	352	1
ee1150446	352	1
ee1150450	352	1
ee1150451	352	1
ee1150456	352	1
ee1150475	352	1
ee1150481	352	1
ee1150487	352	1
ee1150494	352	1
ee1160040	352	1
ee1160050	352	1
ee1160071	352	1
ee1160107	352	1
ee1160160	352	1
ee1160410	352	1
ee1160411	352	1
ee1160415	352	1
ee1160416	352	1
ee1160417	352	1
ee1160418	352	1
ee1160419	352	1
ee1160420	352	1
ee1160421	352	1
ee1160422	352	1
ee1160423	352	1
ee1160424	352	1
ee1160425	352	1
ee1160426	352	1
ee1160427	352	1
ee1160428	352	1
ee1160429	352	1
ee1160430	352	1
ee1160431	352	1
ee1160432	352	1
ee1160434	352	1
ee1160435	352	1
ee1160436	352	1
ee1160437	352	1
ee1160438	352	1
ee1160439	352	1
ee1160440	352	1
ee1160441	352	1
ee1160442	352	1
ee1160443	352	1
ee1160444	352	1
ee1160445	352	1
ee1160447	352	1
ee1160448	352	1
ee1160450	352	1
ee1160451	352	1
ee1160452	352	1
ee1160453	352	1
ee1160454	352	1
ee1160455	352	1
ee1160456	352	1
ee1160457	352	1
ee1160458	352	1
ee1160459	352	1
ee1160460	352	1
ee1160461	352	1
ee1160462	352	1
ee1160463	352	1
ee1160464	352	1
ee1160465	352	1
ee1160466	352	1
ee1160467	352	1
ee1160468	352	1
ee1160469	352	1
ee1160470	352	1
ee1160471	352	1
ee1160472	352	1
ee1160473	352	1
ee1160475	352	1
ee1160476	352	1
ee1160478	352	1
ee1160479	352	1
ee1160480	352	1
ee1160481	352	1
ee1160482	352	1
ee1160483	352	1
ee1160484	352	1
ee1160499	352	1
ee1160545	352	1
ee1160556	352	1
ee1160571	352	1
ee1160694	352	1
ee1160825	352	1
ee1160835	352	1
ee2110503	352	1
ee3150522	352	1
ee3150536	352	1
ee3150541	352	1
ee3160042	352	1
ee3160161	352	1
ee3160220	352	1
ee3160240	352	1
ee3160246	352	1
ee3160490	352	1
ee3160493	352	1
ee3160494	352	1
ee3160495	352	1
ee3160496	352	1
ee3160497	352	1
ee3160498	352	1
ee3160500	352	1
ee3160501	352	1
ee3160502	352	1
ee3160503	352	1
ee3160504	352	1
ee3160505	352	1
ee3160506	352	1
ee3160507	352	1
ee3160508	352	1
ee3160509	352	1
ee3160510	352	1
ee3160511	352	1
ee3160512	352	1
ee3160514	352	1
ee3160515	352	1
ee3160516	352	1
ee3160517	352	1
ee3160518	352	1
ee3160519	352	1
ee3160520	352	1
ee3160521	352	1
ee3160522	352	1
ee3160524	352	1
ee3160525	352	1
ee3160526	352	1
ee3160527	352	1
ee3160528	352	1
ee3160529	352	1
ee3160530	352	1
ee3160531	352	1
ee3160532	352	1
ee3160533	352	1
ee3160534	352	1
ee3160769	352	1
bb1160026	353	1
ee1130447	353	1
ee1130501	353	1
ee1150429	353	1
ee1150449	353	1
ee1150534	353	1
ee1160419	353	1
ee1160431	353	1
ee1160435	353	1
ee1160439	353	1
ee1160478	353	1
ee1170093	353	1
ee1170458	353	1
ee1170459	353	1
ee1170462	353	1
ee1170469	353	1
ee1170497	353	1
ee1170704	353	1
ee1170938	353	1
ee2110503	353	1
ee3140503	353	1
ee3150520	353	1
ee3150524	353	1
ee3150525	353	1
ee3150529	353	1
ee3150531	353	1
ee3150536	353	1
ee3150761	353	1
ee3160514	353	1
ee3160520	353	1
ee3160769	353	1
ee3170524	353	1
ee3170538	353	1
ee1140421	354	1
ee1140437	354	1
ee1150437	354	1
ee1150494	354	1
ee1160160	354	1
ee1160426	354	1
ee1160450	354	1
ee1160451	354	1
ee1160453	354	1
ee1160454	354	1
ee1160455	354	1
ee1160457	354	1
ee1160465	354	1
ee1160466	354	1
ee1160468	354	1
ee1160480	354	1
ee3140503	354	1
ee3140526	354	1
ee3150511	354	1
ee3150518	354	1
ee3150536	354	1
ee3150541	354	1
ee3160042	354	1
ee3160161	354	1
ee3160220	354	1
ee3160240	354	1
ee3160246	354	1
ee3160490	354	1
ee3160493	354	1
ee3160494	354	1
ee3160495	354	1
ee3160496	354	1
ee3160497	354	1
ee3160498	354	1
ee3160500	354	1
ee3160501	354	1
ee3160502	354	1
ee3160503	354	1
ee3160504	354	1
ee3160505	354	1
ee3160506	354	1
ee3160507	354	1
ee3160508	354	1
ee3160509	354	1
ee3160510	354	1
ee3160511	354	1
ee3160512	354	1
ee3160514	354	1
ee3160515	354	1
ee3160516	354	1
ee3160517	354	1
ee3160518	354	1
ee3160519	354	1
ee3160520	354	1
ee3160521	354	1
ee3160522	354	1
ee3160524	354	1
ee3160525	354	1
ee3160526	354	1
ee3160527	354	1
ee3160528	354	1
ee3160529	354	1
ee3160531	354	1
ee3160532	354	1
ee3160533	354	1
ee3160534	354	1
ee3160769	354	1
bb1160026	355	1
ce1130384	355	1
cs5150293	355	1
cs5150294	355	1
ee1150080	355	1
ee1150428	355	1
ee1150429	355	1
ee1150439	355	1
ee1150442	355	1
ee1150443	355	1
ee1150446	355	1
ee1150454	355	1
ee1150455	355	1
ee1150457	355	1
ee1150470	355	1
ee1150474	355	1
ee1150735	355	1
ee1160050	355	1
ee1160415	355	1
ee1160416	355	1
ee1160417	355	1
ee1160430	355	1
ee1160432	355	1
ee1160436	355	1
ee1160444	355	1
ee1160470	355	1
ee1160471	355	1
ee1160472	355	1
ee1160473	355	1
ee1160476	355	1
ee1160481	355	1
ee1160483	355	1
ee1160484	355	1
ee1160835	355	1
ee1170345	355	1
ee3150501	355	1
ee3150502	355	1
ee3150503	355	1
ee3150506	355	1
ee3150511	355	1
ee3150512	355	1
ee3150514	355	1
ee3150521	355	1
ee3150522	355	1
ee3150523	355	1
ee3150525	355	1
ee3150528	355	1
ee3150530	355	1
ee3150532	355	1
ee3150533	355	1
ee3150536	355	1
ee3150541	355	1
ee3150543	355	1
ee3150761	355	1
ee3150898	355	1
ee3160042	355	1
ee3160240	355	1
ee3160246	355	1
ee3160490	355	1
ee3160493	355	1
ee3160494	355	1
ee3160495	355	1
ee3160496	355	1
ee3160497	355	1
ee3160498	355	1
ee3160500	355	1
ee3160501	355	1
ee3160502	355	1
ee3160503	355	1
ee3160504	355	1
ee3160505	355	1
ee3160506	355	1
ee3160507	355	1
ee3160508	355	1
ee3160509	355	1
ee3160510	355	1
ee3160511	355	1
ee3160512	355	1
ee3160514	355	1
ee3160515	355	1
ee3160516	355	1
ee3160517	355	1
ee3160518	355	1
ee3160519	355	1
ee3160520	355	1
ee3160521	355	1
ee3160522	355	1
ee3160524	355	1
ee3160525	355	1
ee3160526	355	1
ee3160527	355	1
ee3160528	355	1
ee3160529	355	1
ee3160530	355	1
ee3160531	355	1
ee3160532	355	1
ee3160533	355	1
ee3160534	355	1
ee3160769	355	1
me1150648	355	1
me1150668	355	1
me1170572	355	1
me1170583	355	1
me2130786	355	1
mt1140581	355	1
mt1150319	355	1
mt1150583	355	1
mt1150584	355	1
mt1150585	355	1
mt1150588	355	1
mt1150594	355	1
mt1150596	355	1
mt1150597	355	1
mt1150601	355	1
mt1150612	355	1
mt1150616	355	1
mt1150617	355	1
mt1160624	355	1
mt1160636	355	1
mt1160638	355	1
mt6150565	355	1
ph1150832	355	1
vst189768	355	1
ee1150045	356	1
ee1150080	356	1
ee1150379	356	1
ee1150428	356	1
ee1150430	356	1
ee1150442	356	1
ee1150455	356	1
ee1150457	356	1
ee1150458	356	1
ee1150464	356	1
ee1150465	356	1
ee1150470	356	1
ee1150471	356	1
ee1150472	356	1
ee1150474	356	1
ee1150488	356	1
ee1150490	356	1
ee1150493	356	1
ee2110503	356	1
ee3150152	356	1
ee3150501	356	1
ee3150506	356	1
ee3150508	356	1
ee3150511	356	1
ee3150512	356	1
ee3150513	356	1
ee3150514	356	1
ee3150522	356	1
ee3150524	356	1
ee3150525	356	1
ee3150526	356	1
ee3150539	356	1
ee3150543	356	1
ee3150761	356	1
ee1150437	357	1
ee1150481	357	1
ee1150494	357	1
ee1160430	357	1
ee1160432	357	1
ee1160434	357	1
ee1160438	357	1
ee1160442	357	1
ee3150112	357	1
ee3150524	357	1
ee3150525	357	1
ee3150531	357	1
bb1160026	358	1
bb1160047	358	1
bb5150004	358	1
ce1160226	358	1
ce1160856	358	1
ce1170089	358	1
ce1170122	358	1
ce1170174	358	1
ch1160106	358	1
ch1160114	358	1
ch1170258	358	1
cs1170370	358	1
cs5170412	358	1
ee1130476	358	1
ee1130501	358	1
ee1150482	358	1
ee1150485	358	1
ee1150486	358	1
ee1150491	358	1
ee1160040	358	1
ee1160160	358	1
ee1160415	358	1
ee1160416	358	1
ee1160423	358	1
ee1160431	358	1
ee1160438	358	1
ee1160439	358	1
ee1160440	358	1
ee1160441	358	1
ee1160443	358	1
ee1160447	358	1
ee1160448	358	1
ee1160467	358	1
ee1160499	358	1
ee1160545	358	1
ee1170453	358	1
ee1170454	358	1
ee1170461	358	1
ee1170491	358	1
ee3150514	358	1
ee3150543	358	1
ee3160518	358	1
ee3170524	358	1
ee3170539	358	1
me1150681	358	1
me2150765	358	1
me2160763	358	1
me2160764	358	1
me2160767	358	1
mt1160635	358	1
mt1170723	358	1
mt1170727	358	1
mt1170744	358	1
mt1170747	358	1
mt6150556	358	1
mt6160078	358	1
mt6170499	358	1
mt6170855	358	1
ph1140840	358	1
ph1150783	358	1
ph1150793	358	1
ph1160562	358	1
tt1160864	358	1
tt1160870	358	1
tt1160880	358	1
vst189763	358	1
ee1150045	359	1
ee1150466	359	1
ee1150491	359	1
ee1150534	359	1
ee1150473	360	1
mt1150613	360	1
ph1140840	360	1
tt1150921	360	1
eea182367	361	1
eea182368	361	1
eea182370	361	1
eea182371	361	1
eea182372	361	1
eea182375	361	1
eea182376	361	1
eea182377	361	1
eea182378	361	1
eea182379	361	1
eea182380	361	1
eea182381	361	1
eea182382	361	1
eea182726	361	1
eez188132	361	1
eez188146	361	1
eez188552	361	1
eez188555	361	1
eez188564	361	1
eez188575	361	1
eez188576	361	1
me1150640	361	1
mez188288	361	1
bsz188602	362	1
eea182367	362	1
eea182368	362	1
eea182370	362	1
eea182371	362	1
eea182372	362	1
eea182375	362	1
eea182376	362	1
eea182377	362	1
eea182378	362	1
eea182379	362	1
eea182380	362	1
eea182381	362	1
eea182382	362	1
eea182726	362	1
eez188132	362	1
eez188133	362	1
eez188152	362	1
eez188553	362	1
eez188555	362	1
ee1120971	363	1
ee1150111	363	1
ee1150114	363	1
ee1150421	363	1
ee1150428	363	1
ee1150430	363	1
ee1150432	363	1
ee1150434	363	1
ee1150436	363	1
ee1150439	363	1
ee1150447	363	1
ee1150450	363	1
ee1150466	363	1
ee1150467	363	1
ee1150468	363	1
ee1150470	363	1
ee1150472	363	1
ee1150475	363	1
ee1150476	363	1
ee1150489	363	1
ee1150908	363	1
ee1160426	363	1
ee1160450	363	1
ee1160461	363	1
ee1160462	363	1
ee1160466	363	1
ee1160571	363	1
ee2110522	363	1
ee3150517	363	1
ee3150521	363	1
ee3150539	363	1
ee3160529	363	1
ee3160532	363	1
ee5110547	363	1
eet182560	363	1
eet182561	363	1
eet182574	363	1
eet182727	363	1
me1150639	363	1
me2160784	363	1
mt1140045	363	1
mt1150589	363	1
mt1150597	363	1
mt1150605	363	1
mt5120605	363	1
mt5120616	363	1
mt6140362	363	1
mt6140561	363	1
mt6140562	363	1
mt6140564	363	1
mt6140569	363	1
mt6140570	363	1
mt6150113	363	1
mt6150551	363	1
mt6150554	363	1
mt6150555	363	1
mt6150557	363	1
mt6150558	363	1
mt6150562	363	1
mt6150563	363	1
mt6150565	363	1
mt6150566	363	1
mt6150569	363	1
mt6160652	363	1
qiz188608	363	1
bsz188123	364	1
eez188570	364	1
jop182037	364	1
jop182090	364	1
jop182091	364	1
jop182444	364	1
jop182445	364	1
jop182448	364	1
jop182449	364	1
jop182450	364	1
jop182451	364	1
jop182452	364	1
jop182453	364	1
jop182454	364	1
jop182710	364	1
jop182711	364	1
jop182712	364	1
jop182819	364	1
jop182841	364	1
jop182860	364	1
jop182866	364	1
jop182871	364	1
jop182877	364	1
jop182880	364	1
bsy187540	365	1
bsz188117	365	1
bsz188121	365	1
bsz188291	365	1
bsz188522	365	1
crf172110	365	1
crf172112	365	1
crz188300	365	1
crz188302	365	1
crz188653	365	1
crz188654	365	1
ee1150454	365	1
ee1150641	365	1
ee1150781	365	1
ee1160463	365	1
ee3150112	365	1
eee182106	365	1
eee182123	365	1
eee182386	365	1
eee182388	365	1
eee182392	365	1
eee182393	365	1
eee182395	365	1
eee182396	365	1
eee182398	365	1
eee182399	365	1
eee182400	365	1
eee182401	365	1
eee182402	365	1
eee182403	365	1
eee182870	365	1
eet172291	365	1
eey187535	365	1
eez188140	365	1
eez188141	365	1
eez188142	365	1
eez188165	365	1
eez188166	365	1
eez188171	365	1
eez188563	365	1
eez188572	365	1
jtm172186	365	1
jtm172187	365	1
vst189757	365	1
bsz188522	366	1
bsz188601	366	1
ee3150121	366	1
eee182123	366	1
eee182401	366	1
eee182402	366	1
ees182579	366	1
ees182586	366	1
ees182596	366	1
eet162646	366	1
eey187536	366	1
eez178560	366	1
eez188165	366	1
jtm172186	366	1
bsz178497	367	1
bsz188117	367	1
bsz188604	367	1
eee172234	367	1
eee172236	367	1
eee182106	367	1
eee182123	367	1
eee182386	367	1
eee182392	367	1
eee182393	367	1
eee182395	367	1
eee182396	367	1
eee182398	367	1
eee182400	367	1
eee182870	367	1
eet162646	367	1
eet172304	367	1
eet182554	367	1
eet182555	367	1
eet182556	367	1
eet182557	367	1
eet182560	367	1
eet182562	367	1
eet182564	367	1
eet182565	367	1
eet182566	367	1
eet182568	367	1
eet182569	367	1
eet182570	367	1
eet182571	367	1
eet182575	367	1
eet182727	367	1
eet182865	367	1
eez188165	367	1
jop172313	367	1
jop182037	367	1
jop182090	367	1
jop182091	367	1
jop182444	367	1
jop182445	367	1
jop182448	367	1
jop182449	367	1
jop182450	367	1
jop182451	367	1
jop182452	367	1
jop182453	367	1
jop182454	367	1
jop182710	367	1
jop182711	367	1
jop182712	367	1
jop182880	367	1
jtm172019	367	1
jtm172023	367	1
jtm172186	367	1
jtm172767	367	1
jtm182774	367	1
mcs172072	367	1
mcs172082	367	1
mcs172084	367	1
mcs172085	367	1
mcs172087	367	1
mcs172089	367	1
mcs172101	367	1
mcs172105	367	1
mcs172693	367	1
bsz178497	368	1
bsz188118	368	1
bsz188522	368	1
ee5110550	368	1
eee172246	368	1
eet172308	368	1
eez188142	368	1
eez188153	368	1
eez188172	368	1
jid182467	368	1
jtm172186	368	1
jtm182244	368	1
ee1150489	369	1
ee1160432	369	1
eez178655	369	1
eez188138	369	1
eez188570	369	1
jop172313	369	1
jop172314	369	1
jop172622	369	1
jop172679	369	1
jop172833	369	1
jop172844	369	1
jop172845	369	1
jop172846	369	1
jop182819	369	1
jop182860	369	1
jop182866	369	1
jop182871	369	1
crf172113	370	1
crf172695	370	1
crf172697	370	1
crz188655	370	1
ee1160040	370	1
ee1160160	370	1
ee1160422	370	1
ee1160428	370	1
ee1160545	370	1
ee1160556	370	1
ee3160494	370	1
een172247	370	1
een172668	370	1
een172671	370	1
een172672	370	1
een172687	370	1
een172855	370	1
een182411	370	1
een182412	370	1
een182416	370	1
een182420	370	1
eey177537	370	1
eey187524	370	1
eey187525	370	1
eez178203	370	1
eez178204	370	1
eez178563	370	1
eez178656	370	1
eez188138	370	1
eez188163	370	1
eez188554	370	1
eez188567	370	1
jvl182330	370	1
jvl182332	370	1
jvl182335	370	1
jvl182336	370	1
jvl182339	370	1
jvl182340	370	1
jvl182341	370	1
jvl182343	370	1
jvl182344	370	1
crf172697	371	1
ee1150444	371	1
ee1150468	371	1
ee1150489	371	1
ee3150542	371	1
eee182401	371	1
eee182402	371	1
een182405	371	1
een182411	371	1
een182412	371	1
een182413	371	1
een182415	371	1
een182416	371	1
een182419	371	1
eey187523	371	1
eez178563	371	1
eez188569	371	1
jvl182330	371	1
jvl182331	371	1
jvl182332	371	1
jvl182333	371	1
jvl182336	371	1
jvl182337	371	1
jvl182338	371	1
jvl182339	371	1
jvl182340	371	1
jvl182341	371	1
een172257	372	1
een172670	372	1
eez188137	372	1
eez188151	372	1
eez188162	372	1
eez188567	372	1
jid182459	372	1
jid182463	372	1
jid182465	372	1
vst189746	372	1
eep182107	373	1
eep182108	373	1
eep182488	373	1
eep182542	373	1
eep182545	373	1
eep182548	373	1
eep182549	373	1
eep182551	373	1
eep182552	373	1
eep182553	373	1
eez188131	373	1
eez188169	373	1
eez188557	373	1
eez188560	373	1
eez188561	373	1
eez188566	373	1
eez188571	373	1
eez188574	373	1
eez188577	373	1
eez188578	373	1
eep172258	374	1
eep182545	374	1
eep182548	374	1
eez152507	374	1
eez158414	374	1
eez188130	374	1
eez188131	374	1
eez188145	374	1
eez188149	374	1
eez188556	374	1
eez188557	374	1
eez188577	374	1
eep172268	375	1
eep182548	375	1
ees182583	375	1
ees182584	375	1
ees182585	375	1
eey187534	375	1
eez188130	375	1
eez188293	375	1
eez188556	375	1
eez188557	375	1
eez188559	375	1
eez188560	375	1
eez188561	375	1
eez188565	375	1
eez188566	375	1
eez188571	375	1
eez188577	375	1
eez188578	375	1
cec182680	376	1
cec182682	376	1
cec182683	376	1
cec182685	376	1
cec182687	376	1
cec182688	376	1
cec182689	376	1
cec182690	376	1
cec182691	376	1
cec182692	376	1
cec182693	376	1
cec182694	376	1
cec182695	376	1
cec182696	376	1
cec182698	376	1
cec182699	376	1
cec182700	376	1
cec182701	376	1
cec182702	376	1
cec182703	376	1
cec182706	376	1
cec182708	376	1
cec182709	376	1
ees182577	377	1
ees182579	377	1
ees182580	377	1
ees182582	377	1
ees182583	377	1
ees182584	377	1
ees182585	377	1
ees182586	377	1
ees182587	377	1
ees182589	377	1
ees182590	377	1
ees182591	377	1
ees182593	377	1
ees182596	377	1
ees182861	377	1
eez188157	377	1
eez188573	377	1
ees182577	378	1
ees182580	378	1
ees182582	378	1
ees182583	378	1
ees182584	378	1
ees182585	378	1
ees182587	378	1
ees182589	378	1
ees182590	378	1
ees182591	378	1
ees182594	378	1
ees182861	378	1
eey187534	378	1
eez188127	378	1
eez188130	378	1
eez188158	378	1
eez188293	378	1
eez188552	378	1
eez188559	378	1
eez188561	378	1
eez188566	378	1
eez188571	378	1
eez188573	378	1
eez188574	378	1
eez188575	378	1
eez188576	378	1
eez188577	378	1
eez188578	378	1
anz188521	379	1
bsy177508	379	1
eet182554	379	1
eet182555	379	1
eet182556	379	1
eet182557	379	1
eet182559	379	1
eet182560	379	1
eet182561	379	1
eet182562	379	1
eet182563	379	1
eet182564	379	1
eet182565	379	1
eet182566	379	1
eet182568	379	1
eet182569	379	1
eet182570	379	1
eet182571	379	1
eet182572	379	1
eet182574	379	1
eet182575	379	1
eet182727	379	1
eet182865	379	1
eey187525	379	1
eey187547	379	1
eez188172	379	1
mcs172075	379	1
siy187505	379	1
vst189767	379	1
anz188061	380	1
anz188521	380	1
bmz188310	380	1
bsz188602	380	1
bsz188604	380	1
chz158435	380	1
crf182529	380	1
crf182533	380	1
crf182537	380	1
crf182539	380	1
crf182540	380	1
eee182123	380	1
een182408	380	1
een182418	380	1
ees172288	380	1
ees182577	380	1
ees182585	380	1
ees182586	380	1
ees182587	380	1
eet182564	380	1
eet182574	380	1
eez188135	380	1
eez188172	380	1
eez188553	380	1
itz168319	380	1
jid182460	380	1
jid182462	380	1
jop182450	380	1
jop182710	380	1
jop182712	380	1
jtm172768	380	1
jtm182002	380	1
jtm182004	380	1
jtm182243	380	1
jtm182246	380	1
jtm182247	380	1
jtm182248	380	1
jtm182250	380	1
mt1160624	380	1
phs177161	380	1
phz162024	380	1
phz162025	380	1
siy187538	380	1
vst189745	380	1
vst189759	380	1
vst189760	380	1
vst189761	380	1
vst189762	380	1
vst189772	380	1
bsz188601	381	1
eea182368	381	1
eea182371	381	1
eea182375	381	1
jvl182335	381	1
jvl182336	381	1
me1160678	381	1
eea182367	382	1
eea182368	382	1
eea182370	382	1
eea182371	382	1
eea182372	382	1
eea182375	382	1
eea182376	382	1
eea182377	382	1
eea182378	382	1
eea182379	382	1
eea182380	382	1
eea182381	382	1
eea182382	382	1
eea182726	382	1
ees182584	382	1
ees182593	382	1
eey187534	382	1
eez188134	382	1
eez188152	382	1
eez188293	382	1
eez188555	382	1
eez188564	382	1
eez188558	383	1
eea172232	384	1
eea172233	384	1
eea172665	384	1
ees182579	384	1
ees182583	384	1
eey177539	384	1
eez188134	384	1
eez188135	384	1
eez188293	384	1
eez188552	384	1
eez188564	384	1
eez188565	384	1
bsz188116	385	1
bsz188117	385	1
bsz188123	385	1
ee3150514	385	1
eee172240	385	1
eee172241	385	1
eee182106	385	1
eee182396	385	1
eee182399	385	1
eee182400	385	1
eee182870	385	1
eez188140	385	1
jop172313	385	1
jop172627	385	1
jop172843	385	1
jop182037	385	1
jop182090	385	1
jop182091	385	1
jop182444	385	1
jop182445	385	1
jop182448	385	1
jop182449	385	1
jop182451	385	1
jop182452	385	1
jop182453	385	1
jop182454	385	1
jop182711	385	1
jop182880	385	1
bsz188115	386	1
bsz188116	386	1
bsz188117	386	1
bsz188118	386	1
bsz188291	386	1
eee172246	386	1
eee182386	386	1
eee182388	386	1
eee182392	386	1
eee182393	386	1
eee182395	386	1
eee182398	386	1
eee182399	386	1
eee182400	386	1
eee182403	386	1
eez188140	386	1
eez188165	386	1
eez188563	386	1
jtm182003	386	1
jtm182245	386	1
jtm182249	386	1
jtm182251	386	1
bsy187540	387	1
bsz178497	387	1
bsz188522	387	1
eez188141	387	1
eez188165	387	1
eez188166	387	1
eez188171	387	1
eez188572	387	1
bsz188118	388	1
bsz188602	388	1
eet172295	388	1
eez188142	388	1
eez188553	388	1
bsz178500	389	1
bsz188523	389	1
ee1120971	389	1
ee5110547	389	1
eet172292	389	1
eet172294	389	1
eet172295	389	1
eet172302	389	1
eet172303	389	1
eet172304	389	1
eet172305	389	1
eet172306	389	1
eet172307	389	1
eet172680	389	1
eet172681	389	1
eet172839	389	1
eet172840	389	1
eet172841	389	1
eet172864	389	1
eet182562	389	1
eet182563	389	1
eet182568	389	1
eet182571	389	1
eet182727	389	1
eet182865	389	1
eez188165	389	1
asz142298	390	1
bsz188291	390	1
bsz188523	390	1
ee3160530	390	1
eet172305	390	1
eet172306	390	1
eet172864	390	1
eez188153	390	1
jtm172186	390	1
jtm172769	390	1
mcs172094	390	1
mcs172104	390	1
crf172108	391	1
crf172109	391	1
crf172111	391	1
crf172113	391	1
crf172695	391	1
crf172698	391	1
crf182110	391	1
crf182526	391	1
crf182527	391	1
crf182528	391	1
crf182531	391	1
crf182532	391	1
crf182534	391	1
crf182536	391	1
crf182538	391	1
crz178641	391	1
ee1150444	391	1
ee1150468	391	1
ee1160040	391	1
ee1160422	391	1
ee1160545	391	1
ee3160494	391	1
eee182386	391	1
eee182399	391	1
eee182401	391	1
eee182402	391	1
een172248	391	1
een172628	391	1
een172838	391	1
een182405	391	1
een182408	391	1
een182411	391	1
een182412	391	1
een182413	391	1
een182415	391	1
een182416	391	1
een182418	391	1
een182419	391	1
een182420	391	1
eey177537	391	1
eey187523	391	1
eez158110	391	1
eez178203	391	1
eez178204	391	1
eez178563	391	1
eez178564	391	1
eez178570	391	1
eez188151	391	1
eez188377	391	1
eez188554	391	1
eez188569	391	1
jvl182330	391	1
jvl182331	391	1
jvl182332	391	1
jvl182333	391	1
jvl182335	391	1
jvl182336	391	1
jvl182337	391	1
jvl182338	391	1
jvl182339	391	1
jvl182340	391	1
jvl182341	391	1
vst189746	391	1
eep182107	392	1
eep182108	392	1
eep182488	392	1
eep182542	392	1
eep182545	392	1
eep182548	392	1
eep182549	392	1
eep182551	392	1
eep182552	392	1
eep182553	392	1
eez188130	392	1
eez188145	392	1
eez188146	392	1
eez188149	392	1
eez188168	392	1
eez188556	392	1
eez188557	392	1
eez188560	392	1
eez188561	392	1
eez188565	392	1
eez188566	392	1
eez188571	392	1
eez188574	392	1
eez188577	392	1
eez188578	392	1
ee2110522	393	1
eep182551	393	1
eez168501	393	1
eez168502	393	1
eez168503	393	1
eez168504	393	1
eez168505	393	1
eez178565	393	1
eez188168	393	1
eez188169	393	1
eez188558	393	1
eez188560	393	1
eez188561	393	1
eez188566	393	1
eez188571	393	1
eez188578	393	1
vst189774	393	1
ee3150512	394	1
ee3150514	394	1
ees172288	394	1
ees172289	394	1
ees182577	394	1
ees182579	394	1
ees182580	394	1
ees182589	394	1
ees182590	394	1
ees182591	394	1
ees182594	394	1
ees182596	394	1
eey187536	394	1
eez188157	394	1
cs1140227	395	1
cs1150213	395	1
ee1150111	395	1
ee1150466	395	1
ee1150504	395	1
ee1150835	395	1
ee3150112	395	1
ee3150517	395	1
ee3150761	395	1
eea172664	395	1
eet172297	395	1
eet182556	395	1
eet182559	395	1
mt6150554	395	1
mt6150566	395	1
anz188380	396	1
bb1160033	396	1
bsz188122	396	1
bsz188601	396	1
bsz188602	396	1
cs1150208	396	1
cs1150223	396	1
cs1150234	396	1
cs1150245	396	1
cs1150251	396	1
cs1150254	396	1
cs1160359	396	1
cs5140293	396	1
cs5150286	396	1
cs5160625	396	1
ee1150493	396	1
ee1160071	396	1
ee1160107	396	1
ee1160424	396	1
ee1160469	396	1
ee1160694	396	1
ee1160825	396	1
ee3160220	396	1
ee3160246	396	1
ee3160505	396	1
ee3160506	396	1
ee3160508	396	1
ee3160512	396	1
eet172680	396	1
eet182554	396	1
eet182555	396	1
eet182556	396	1
eet182557	396	1
eet182559	396	1
eet182560	396	1
eet182561	396	1
eet182563	396	1
eet182565	396	1
eet182566	396	1
eet182569	396	1
eet182570	396	1
eet182575	396	1
eet182865	396	1
eey187535	396	1
eey187536	396	1
eez188562	396	1
jvl182337	396	1
mcs172082	396	1
mcs172084	396	1
me2130786	396	1
me2150753	396	1
me2150765	396	1
me2160771	396	1
me2160774	396	1
mt1150182	396	1
mt1150319	396	1
mt1150585	396	1
mt1150599	396	1
mt1150725	396	1
mt1160413	396	1
mt1160492	396	1
mt1160616	396	1
mt1160619	396	1
mt6140555	396	1
mt6150358	396	1
mt6150567	396	1
siy187542	396	1
tt1150917	396	1
vst189773	396	1
ee5110550	397	1
eet172292	397	1
eet172294	397	1
eet172295	397	1
eet172296	397	1
eet172300	397	1
eet172302	397	1
eet172305	397	1
eet172306	397	1
eet172681	397	1
eet172839	397	1
eet172840	397	1
eet172841	397	1
eet172864	397	1
eet182572	397	1
ee1120971	398	1
ee1160477	398	1
ee1170093	398	1
ee1170249	398	1
ee1170306	398	1
ee1170345	398	1
ee1170431	398	1
ee1170432	398	1
ee1170433	398	1
ee1170434	398	1
ee1170435	398	1
ee1170436	398	1
ee1170437	398	1
ee1170438	398	1
ee1170439	398	1
ee1170440	398	1
ee1170441	398	1
ee1170442	398	1
ee1170443	398	1
ee1170444	398	1
ee1170445	398	1
ee1170446	398	1
ee1170447	398	1
ee1170448	398	1
ee1170449	398	1
ee1170450	398	1
ee1170451	398	1
ee1170452	398	1
ee1170453	398	1
ee1170454	398	1
ee1170455	398	1
ee1170456	398	1
ee1170457	398	1
ee1170458	398	1
ee1170459	398	1
ee1170460	398	1
ee1170461	398	1
ee1170462	398	1
ee1170463	398	1
ee1170464	398	1
ee1170465	398	1
ee1170466	398	1
ee1170467	398	1
ee1170468	398	1
ee1170469	398	1
ee1170470	398	1
ee1170471	398	1
ee1170472	398	1
ee1170473	398	1
ee1170474	398	1
ee1170475	398	1
ee1170476	398	1
ee1170477	398	1
ee1170478	398	1
ee1170479	398	1
ee1170480	398	1
ee1170482	398	1
ee1170483	398	1
ee1170484	398	1
ee1170485	398	1
ee1170486	398	1
ee1170490	398	1
ee1170491	398	1
ee1170492	398	1
ee1170494	398	1
ee1170495	398	1
ee1170496	398	1
ee1170497	398	1
ee1170498	398	1
ee1170500	398	1
ee1170501	398	1
ee1170502	398	1
ee1170504	398	1
ee1170505	398	1
ee1170536	398	1
ee1170544	398	1
ee1170565	398	1
ee1170584	398	1
ee1170597	398	1
ee1170599	398	1
ee1170608	398	1
ee1170704	398	1
ee1170809	398	1
ee1170937	398	1
ee1170938	398	1
ee3160527	398	1
ee3160528	398	1
ee3170010	398	1
ee3170019	398	1
ee3170149	398	1
ee3170221	398	1
ee3170245	398	1
ee3170511	398	1
ee3170512	398	1
ee3170513	398	1
ee3170514	398	1
ee3170515	398	1
ee3170516	398	1
ee3170517	398	1
ee3170518	398	1
ee3170519	398	1
ee3170522	398	1
ee3170523	398	1
ee3170524	398	1
ee3170525	398	1
ee3170526	398	1
ee3170527	398	1
ee3170528	398	1
ee3170529	398	1
ee3170531	398	1
ee3170532	398	1
ee3170533	398	1
ee3170534	398	1
ee3170535	398	1
ee3170537	398	1
ee3170538	398	1
ee3170539	398	1
ee3170541	398	1
ee3170542	398	1
ee3170543	398	1
ee3170545	398	1
ee3170546	398	1
ee3170547	398	1
ee3170548	398	1
ee3170549	398	1
ee3170550	398	1
ee3170551	398	1
ee3170552	398	1
ee3170553	398	1
ee3170554	398	1
ee3170555	398	1
ee3170654	398	1
ee3170872	398	1
ee1130483	399	1
ee1130515	399	1
ee1140437	399	1
ee1150426	399	1
ee1150427	399	1
ee1150430	399	1
ee1150432	399	1
ee1150437	399	1
ee1150438	399	1
ee1150441	399	1
ee1150445	399	1
ee1150446	399	1
ee1150447	399	1
ee1150450	399	1
ee1150462	399	1
ee1150471	399	1
ee1150476	399	1
ee1150481	399	1
ee1150504	399	1
ee1150735	399	1
ee1150835	399	1
ee1150908	399	1
ee1160040	399	1
ee1160050	399	1
ee1160071	399	1
ee1160107	399	1
ee1160160	399	1
ee1160410	399	1
ee1160411	399	1
ee1160415	399	1
ee1160416	399	1
ee1160417	399	1
ee1160418	399	1
ee1160419	399	1
ee1160421	399	1
ee1160422	399	1
ee1160423	399	1
ee1160424	399	1
ee1160425	399	1
ee1160426	399	1
ee1160427	399	1
ee1160428	399	1
ee1160429	399	1
ee1160430	399	1
ee1160431	399	1
ee1160432	399	1
ee1160434	399	1
ee1160435	399	1
ee1160436	399	1
ee1160437	399	1
ee1160438	399	1
ee1160439	399	1
ee1160440	399	1
ee1160441	399	1
ee1160442	399	1
ee1160443	399	1
ee1160444	399	1
ee1160445	399	1
ee1160446	399	1
ee1160447	399	1
ee1160448	399	1
ee1160451	399	1
ee1160453	399	1
ee1160454	399	1
ee1160455	399	1
ee1160456	399	1
ee1160457	399	1
ee1160458	399	1
ee1160459	399	1
ee1160460	399	1
ee1160462	399	1
ee1160463	399	1
ee1160464	399	1
ee1160465	399	1
ee1160466	399	1
ee1160467	399	1
ee1160468	399	1
ee1160469	399	1
ee1160470	399	1
ee1160471	399	1
ee1160472	399	1
ee1160473	399	1
ee1160474	399	1
ee1160475	399	1
ee1160478	399	1
ee1160479	399	1
ee1160480	399	1
ee1160481	399	1
ee1160482	399	1
ee1160483	399	1
ee1160484	399	1
ee1160545	399	1
ee1160556	399	1
ee1160571	399	1
ee1160694	399	1
ee1160825	399	1
ee1160835	399	1
ee3140526	399	1
ee3150152	399	1
ee3150508	399	1
ee3150511	399	1
ee3150521	399	1
ee3150524	399	1
ee3150525	399	1
ee3150531	399	1
ee3150544	399	1
ee3160042	399	1
ee3160161	399	1
ee3160220	399	1
ee3160240	399	1
ee3160246	399	1
ee3160490	399	1
ee3160493	399	1
ee3160494	399	1
ee3160495	399	1
ee3160496	399	1
ee3160497	399	1
ee3160498	399	1
ee3160500	399	1
ee3160501	399	1
ee3160502	399	1
ee3160503	399	1
ee3160504	399	1
ee3160505	399	1
ee3160506	399	1
ee3160507	399	1
ee3160508	399	1
ee3160509	399	1
ee3160511	399	1
ee3160512	399	1
ee3160514	399	1
ee3160515	399	1
ee3160516	399	1
ee3160517	399	1
ee3160518	399	1
ee3160519	399	1
ee3160520	399	1
ee3160521	399	1
ee3160522	399	1
ee3160524	399	1
ee3160525	399	1
ee3160526	399	1
ee3160527	399	1
ee3160528	399	1
ee3160529	399	1
ee3160531	399	1
ee3160533	399	1
ee3160534	399	1
ee3160769	399	1
ee1150446	400	1
ee1150475	400	1
ee1160040	400	1
ee1160050	400	1
ee1160071	400	1
ee1160107	400	1
ee1160160	400	1
ee1160410	400	1
ee1160411	400	1
ee1160415	400	1
ee1160416	400	1
ee1160417	400	1
ee1160418	400	1
ee1160419	400	1
ee1160420	400	1
ee1160421	400	1
ee1160422	400	1
ee1160423	400	1
ee1160424	400	1
ee1160425	400	1
ee1160426	400	1
ee1160427	400	1
ee1160428	400	1
ee1160429	400	1
ee1160430	400	1
ee1160431	400	1
ee1160432	400	1
ee1160434	400	1
ee1160435	400	1
ee1160436	400	1
ee1160437	400	1
ee1160439	400	1
ee1160440	400	1
ee1160441	400	1
ee1160442	400	1
ee1160443	400	1
ee1160444	400	1
ee1160445	400	1
ee1160446	400	1
ee1160447	400	1
ee1160448	400	1
ee1160450	400	1
ee1160451	400	1
ee1160452	400	1
ee1160453	400	1
ee1160454	400	1
ee1160455	400	1
ee1160456	400	1
ee1160457	400	1
ee1160458	400	1
ee1160459	400	1
ee1160460	400	1
ee1160461	400	1
ee1160462	400	1
ee1160463	400	1
ee1160464	400	1
ee1160465	400	1
ee1160466	400	1
ee1160467	400	1
ee1160468	400	1
ee1160469	400	1
ee1160470	400	1
ee1160471	400	1
ee1160472	400	1
ee1160473	400	1
ee1160474	400	1
ee1160475	400	1
ee1160476	400	1
ee1160478	400	1
ee1160479	400	1
ee1160480	400	1
ee1160481	400	1
ee1160482	400	1
ee1160483	400	1
ee1160484	400	1
ee1160499	400	1
ee1160545	400	1
ee1160556	400	1
ee1160571	400	1
ee1160694	400	1
ee1160825	400	1
ee1160835	400	1
ee3150541	400	1
ee3150544	400	1
ee3160042	400	1
ee3160161	400	1
ee3160220	400	1
ee3160240	400	1
ee3160246	400	1
ee3160490	400	1
ee3160493	400	1
ee3160494	400	1
ee3160495	400	1
ee3160496	400	1
ee3160497	400	1
ee3160498	400	1
ee3160500	400	1
ee3160501	400	1
ee3160502	400	1
ee3160503	400	1
ee3160504	400	1
ee3160505	400	1
ee3160506	400	1
ee3160507	400	1
ee3160508	400	1
ee3160509	400	1
ee3160510	400	1
ee3160511	400	1
ee3160512	400	1
ee3160514	400	1
ee3160515	400	1
ee3160516	400	1
ee3160517	400	1
ee3160518	400	1
ee3160519	400	1
ee3160520	400	1
ee3160521	400	1
ee3160522	400	1
ee3160524	400	1
ee3160525	400	1
ee3160526	400	1
ee3160527	400	1
ee3160528	400	1
ee3160529	400	1
ee3160530	400	1
ee3160531	400	1
ee3160532	400	1
ee3160533	400	1
ee3160534	400	1
ee3160769	400	1
ee5110563	400	1
me1170564	400	1
me2170679	400	1
mt1150560	400	1
mt1150587	400	1
mt1150592	400	1
mt1160268	400	1
mt1160413	400	1
mt1160491	400	1
mt1160492	400	1
mt1160546	400	1
mt1160582	400	1
mt1160605	400	1
mt1160606	400	1
mt1160607	400	1
mt1160608	400	1
mt1160609	400	1
mt1160610	400	1
mt1160611	400	1
mt1160613	400	1
mt1160614	400	1
mt1160616	400	1
mt1160617	400	1
mt1160618	400	1
mt1160619	400	1
mt1160620	400	1
mt1160621	400	1
mt1160622	400	1
mt1160623	400	1
mt1160624	400	1
mt1160626	400	1
mt1160627	400	1
mt1160628	400	1
mt1160629	400	1
mt1160630	400	1
mt1160631	400	1
mt1160632	400	1
mt1160633	400	1
mt1160634	400	1
mt1160635	400	1
mt1160636	400	1
mt1160637	400	1
mt1160638	400	1
mt1160647	400	1
mt6150552	400	1
mt6150561	400	1
mt6160078	400	1
mt6160645	400	1
mt6160646	400	1
mt6160648	400	1
mt6160649	400	1
mt6160650	400	1
mt6160651	400	1
mt6160652	400	1
mt6160653	400	1
mt6160654	400	1
mt6160655	400	1
mt6160656	400	1
mt6160657	400	1
mt6160658	400	1
mt6160659	400	1
mt6160660	400	1
mt6160661	400	1
mt6160662	400	1
mt6160664	400	1
mt6160677	400	1
mt6160751	400	1
ee1120971	401	1
ee1150439	401	1
ee1150445	401	1
ee1150446	401	1
ee1150449	401	1
ee1150450	401	1
ee1150451	401	1
ee1150456	401	1
ee1150463	401	1
ee1150735	401	1
ee1160040	401	1
ee1160050	401	1
ee1160071	401	1
ee1160107	401	1
ee1160160	401	1
ee1160410	401	1
ee1160411	401	1
ee1160415	401	1
ee1160416	401	1
ee1160417	401	1
ee1160418	401	1
ee1160419	401	1
ee1160420	401	1
ee1160422	401	1
ee1160423	401	1
ee1160424	401	1
ee1160425	401	1
ee1160426	401	1
ee1160427	401	1
ee1160428	401	1
ee1160429	401	1
ee1160430	401	1
ee1160431	401	1
ee1160432	401	1
ee1160434	401	1
ee1160435	401	1
ee1160436	401	1
ee1160437	401	1
ee1160438	401	1
ee1160439	401	1
ee1160440	401	1
ee1160441	401	1
ee1160442	401	1
ee1160443	401	1
ee1160444	401	1
ee1160445	401	1
ee1160447	401	1
ee1160448	401	1
ee1160450	401	1
ee1160451	401	1
ee1160454	401	1
ee1160455	401	1
ee1160456	401	1
ee1160457	401	1
ee1160458	401	1
ee1160459	401	1
ee1160460	401	1
ee1160461	401	1
ee1160462	401	1
ee1160463	401	1
ee1160464	401	1
ee1160465	401	1
ee1160466	401	1
ee1160467	401	1
ee1160468	401	1
ee1160469	401	1
ee1160470	401	1
ee1160471	401	1
ee1160472	401	1
ee1160473	401	1
ee1160474	401	1
ee1160475	401	1
ee1160478	401	1
ee1160479	401	1
ee1160480	401	1
ee1160481	401	1
ee1160482	401	1
ee1160483	401	1
ee1160484	401	1
ee1160545	401	1
ee1160556	401	1
ee1160571	401	1
ee1160694	401	1
ee1160825	401	1
ee1160835	401	1
jtm182002	402	1
jtm182003	402	1
jtm182004	402	1
jtm182243	402	1
jtm182244	402	1
jtm182246	402	1
jtm182247	402	1
jtm182248	402	1
jtm182250	402	1
jtm182772	402	1
jtm182774	402	1
jtm182775	402	1
eee182106	403	1
eee182123	403	1
eee182386	403	1
eee182388	403	1
eee182392	403	1
eee182393	403	1
eee182395	403	1
eee182396	403	1
eee182398	403	1
eee182399	403	1
eee182400	403	1
eee182401	403	1
eee182402	403	1
eee182403	403	1
eee182870	403	1
jtm182002	403	1
jtm182003	403	1
jtm182004	403	1
jtm182243	403	1
jtm182244	403	1
jtm182245	403	1
jtm182246	403	1
jtm182247	403	1
jtm182248	403	1
jtm182249	403	1
jtm182250	403	1
jtm182251	403	1
jtm182772	403	1
jtm182774	403	1
jtm182775	403	1
eey187537	404	1
jvl182330	404	1
jvl182331	404	1
jvl182332	404	1
jvl182333	404	1
jvl182335	404	1
jvl182336	404	1
jvl182337	404	1
jvl182338	404	1
jvl182339	404	1
jvl182340	404	1
jvl182341	404	1
jvl182343	404	1
eea182367	405	1
eea182368	405	1
eea182370	405	1
eea182371	405	1
eea182372	405	1
eea182375	405	1
eea182376	405	1
eea182377	405	1
eea182378	405	1
eea182379	405	1
eea182380	405	1
eea182381	405	1
eea182382	405	1
eea182726	405	1
een172257	406	1
een182405	406	1
een182408	406	1
een182411	406	1
een182412	406	1
een182413	406	1
een182415	406	1
een182416	406	1
een182418	406	1
een182419	406	1
eey187537	406	1
eep182107	407	1
eep182108	407	1
eep182488	407	1
eep182542	407	1
eep182545	407	1
eep182548	407	1
eep182549	407	1
eep182551	407	1
eep182552	407	1
eep182553	407	1
eep182107	408	1
eep182108	408	1
eep182488	408	1
eep182542	408	1
eep182545	408	1
eep182548	408	1
eep182549	408	1
eep182551	408	1
eep182552	408	1
eep182553	408	1
ees172290	409	1
ees182577	409	1
ees182579	409	1
ees182580	409	1
ees182582	409	1
ees182583	409	1
ees182584	409	1
ees182585	409	1
ees182586	409	1
ees182587	409	1
ees182589	409	1
ees182590	409	1
ees182591	409	1
ees182593	409	1
ees182594	409	1
ees182861	409	1
cs1150237	410	1
ee1120971	410	1
ee1130445	410	1
ee1130447	410	1
ee1130483	410	1
ee1130501	410	1
ee1130515	410	1
ee1150111	410	1
ee1150427	410	1
ee1150428	410	1
ee1150432	410	1
ee1150436	410	1
ee1150446	410	1
ee1150447	410	1
ee1150450	410	1
ee1150451	410	1
ee1150462	410	1
ee1150476	410	1
ee1150482	410	1
ee1150908	410	1
ee1160071	410	1
ee1160107	410	1
ee1160411	410	1
ee1160415	410	1
ee1160416	410	1
ee1160419	410	1
ee1160421	410	1
ee1160422	410	1
ee1160424	410	1
ee1160425	410	1
ee1160429	410	1
ee1160430	410	1
ee1160432	410	1
ee1160434	410	1
ee1160438	410	1
ee1160446	410	1
ee1160447	410	1
ee1160448	410	1
ee1160451	410	1
ee1160452	410	1
ee1160453	410	1
ee1160463	410	1
ee1160464	410	1
ee1160466	410	1
ee1160473	410	1
ee1160474	410	1
ee1160475	410	1
ee1160476	410	1
ee1160478	410	1
ee1160479	410	1
ee1160481	410	1
ee1160556	410	1
ee1160571	410	1
ee1160694	410	1
ee1160825	410	1
ee1170473	410	1
ee1170486	410	1
ee1170494	410	1
ee3130555	410	1
ee3140503	410	1
ee3140526	410	1
ee3150152	410	1
ee3150510	410	1
ee3150511	410	1
ee3150513	410	1
ee3150522	410	1
ee3150523	410	1
ee3150525	410	1
ee3150539	410	1
ee3150540	410	1
ee3150544	410	1
ee3150761	410	1
ee3160246	410	1
ee3160495	410	1
ee3160496	410	1
ee3160498	410	1
ee3160502	410	1
ee3160503	410	1
ee3160510	410	1
ee3160514	410	1
ee3160518	410	1
ee3160519	410	1
ee3160520	410	1
ee3160525	410	1
ee3160528	410	1
ee3160529	410	1
ee3160530	410	1
ee3160531	410	1
ee3160532	410	1
ee3160534	410	1
ee3160769	410	1
ee3170526	410	1
ee3170550	410	1
ee3170555	410	1
me1160686	410	1
me2150727	410	1
mt6160648	410	1
ph1140795	410	1
ph1150807	410	1
ph1150812	410	1
tt1150904	410	1
cs5170414	411	1
cs5170415	411	1
cs5170417	411	1
ee1120464	411	1
ee1150427	411	1
ee1150730	411	1
ee1160107	411	1
ee1160418	411	1
ee1160437	411	1
ee1160438	411	1
ee1160440	411	1
ee1160556	411	1
ee1170485	411	1
ee1170498	411	1
mt1160621	411	1
ee1150462	412	1
ee2120515	412	1
ee3150501	412	1
ee3150521	412	1
ee3150542	412	1
ee3160505	412	1
ee3160529	412	1
me1160703	412	1
eey147546	413	1
cs1150266	414	1
ee1130501	414	1
ee1150466	414	1
ee2110503	414	1
ee3150530	414	1
ee3150533	414	1
eet172297	414	1
eet172307	414	1
me2150717	414	1
me2150724	414	1
me2150728	414	1
me2150763	414	1
me2160748	414	1
me2160760	414	1
me2160763	414	1
mt1150375	414	1
mt1150560	414	1
mt1150581	414	1
mt1150604	414	1
siy187542	414	1
ch1150089	415	1
ee1130501	415	1
ee1150455	415	1
ee1150466	415	1
ee1150735	415	1
ee1160469	415	1
ee1160471	415	1
ee3150530	415	1
eet172297	415	1
eet172303	415	1
eet172304	415	1
eet172307	415	1
eet182568	415	1
eet182571	415	1
eet182865	415	1
me2150717	415	1
me2150724	415	1
me2150728	415	1
me2160793	415	1
mt1150582	415	1
mt6150553	415	1
ph1090715	416	1
ph1120883	416	1
ce1130348	417	1
ce1160208	417	1
ce1160241	417	1
ce1160248	417	1
ce1160249	417	1
ce1160251	417	1
ce1160253	417	1
ce1160255	417	1
ce1160257	417	1
ce1160258	417	1
ce1160259	417	1
ce1160260	417	1
ce1160261	417	1
ce1160262	417	1
ce1160264	417	1
ce1160265	417	1
ce1160267	417	1
ce1160269	417	1
ce1160270	417	1
ce1160272	417	1
ce1160274	417	1
ce1160276	417	1
ce1160278	417	1
ce1160280	417	1
ce1160282	417	1
ce1160283	417	1
ce1160296	417	1
ch1150071	417	1
ch1160105	417	1
ch1160108	417	1
ch1160132	417	1
ch1160134	417	1
ch7160172	417	1
ch7160175	417	1
ch7160181	417	1
ch7160182	417	1
ch7160184	417	1
ch7160187	417	1
ch7160189	417	1
ch7160194	417	1
ee1160410	417	1
me1130682	417	1
me1130727	417	1
me1160676	417	1
me1160723	417	1
me1160724	417	1
me1160726	417	1
me1160727	417	1
me1160729	417	1
me1160730	417	1
me1160731	417	1
me1160732	417	1
me1160737	417	1
mt1150583	417	1
ph1140824	417	1
ph1150826	417	1
tt1140937	417	1
tt1140944	417	1
tt1160853	417	1
tt1160869	417	1
tt1160893	417	1
bb1150024	418	1
bb1150030	418	1
bb1150032	418	1
bb1150033	418	1
bb1150051	418	1
bb1150064	418	1
ce1150309	418	1
ce1150314	418	1
ce1150321	418	1
ce1150336	418	1
ce1150350	418	1
ce1150361	418	1
ce1150374	418	1
ch1150075	418	1
ch1150089	418	1
ch1150094	418	1
cs1160375	418	1
ee1130447	418	1
ee1130483	418	1
ee1150080	418	1
ee1150425	418	1
ee1150433	418	1
ee1150478	418	1
ee1150482	418	1
ee1150485	418	1
ee1150487	418	1
ee1150492	418	1
ee1150519	418	1
ee3150535	418	1
ee3150750	418	1
ee3160161	418	1
me1150650	418	1
me1150660	418	1
me1150681	418	1
me1150687	418	1
me1150899	418	1
me2150717	418	1
me2150737	418	1
me2150747	418	1
me2150752	418	1
me2150755	418	1
me2150760	418	1
me2150768	418	1
me2150770	418	1
me2150771	418	1
mt1150588	418	1
mt1150591	418	1
mt1150595	418	1
mt1150598	418	1
mt1150870	418	1
mt6150113	418	1
mt6150373	418	1
ph1140805	418	1
ph1150818	418	1
ph1150832	418	1
ph1150839	418	1
ph1160570	418	1
ph1160578	418	1
tt1150876	418	1
tt1150877	418	1
tt1150938	418	1
bb1150046	419	1
bb1150064	419	1
ce1150309	419	1
ch1150072	419	1
ch1150094	419	1
ee1130445	419	1
ee1150482	419	1
me1150681	419	1
me1150689	419	1
mt1160608	419	1
mt1160632	419	1
mt5120584	419	1
mt6150113	419	1
ph1120883	419	1
vst189728	419	1
ch1140126	420	1
cs1160353	420	1
me1150681	420	1
mt1150870	420	1
ph1140795	420	1
ph1140796	420	1
ph1140800	420	1
ph1140805	420	1
ph1140824	420	1
ph1150783	420	1
ph1150786	420	1
ph1150791	420	1
ph1150795	420	1
ph1150796	420	1
ph1150801	420	1
ph1150803	420	1
ph1150804	420	1
ph1150807	420	1
ph1150810	420	1
ph1150814	420	1
ph1150815	420	1
ph1150817	420	1
ph1150818	420	1
ph1150820	420	1
ph1150823	420	1
ph1150824	420	1
ph1150829	420	1
ph1150831	420	1
ph1150833	420	1
ph1150840	420	1
ph1150841	420	1
ph1160086	420	1
ph1160542	420	1
ph1160548	420	1
ph1160549	420	1
ph1160553	420	1
ph1160554	420	1
ph1160560	420	1
ph1160562	420	1
ph1160566	420	1
ph1160570	420	1
ph1160572	420	1
ph1160573	420	1
ph1160574	420	1
ph1160575	420	1
ph1160578	420	1
ph1160580	420	1
ph1160581	420	1
ph1160583	420	1
ph1160589	420	1
ph1160590	420	1
ph1160592	420	1
ph1160593	420	1
ph1160594	420	1
ph1160595	420	1
ph1160596	420	1
tt1140890	420	1
ce1160210	421	1
ce1160275	421	1
ce1160276	421	1
ce1160305	421	1
ch1150081	421	1
ch1150083	421	1
cs1140261	421	1
ee1150439	421	1
ee1150443	421	1
ee1150454	421	1
ee1150462	421	1
ee1150478	421	1
me1150653	421	1
mt1150596	421	1
mt5120584	421	1
ph1140805	421	1
ce1150360	422	1
cez188389	422	1
che172565	422	1
chz188098	422	1
cs1150231	422	1
eep182107	422	1
eep182108	422	1
eep182552	422	1
esz188514	422	1
jes172184	422	1
jes182597	422	1
jes182599	422	1
jes182600	422	1
jes182602	422	1
jes182604	422	1
jes182605	422	1
jes182606	422	1
jes182607	422	1
jes182608	422	1
jes182609	422	1
jes182613	422	1
jes182614	422	1
jes182615	422	1
jes182616	422	1
jes182617	422	1
jes182618	422	1
jes182621	422	1
jes182622	422	1
jes182624	422	1
jes182625	422	1
jes182627	422	1
jes182679	422	1
ph1110855	422	1
tt1140920	422	1
vst189728	422	1
ee3150541	423	1
esz188513	423	1
jes182604	423	1
jes182608	423	1
jes182609	423	1
jes182613	423	1
jes182614	423	1
jes182615	423	1
jes182616	423	1
jes182617	423	1
jes182621	423	1
jes182622	423	1
jes182624	423	1
jit172127	423	1
me1150681	423	1
qiz188618	423	1
cec172597	424	1
cec182705	424	1
ees172287	424	1
ees172290	424	1
ees182861	424	1
eey177538	424	1
eez188127	424	1
eez188158	424	1
eez188573	424	1
esz188517	424	1
jes182679	424	1
mcs172075	424	1
cs5120277	425	1
esz188661	425	1
jes182597	425	1
jes182599	425	1
jes182600	425	1
jes182602	425	1
jes182604	425	1
jes182605	425	1
jes182606	425	1
jes182607	425	1
jes182608	425	1
jes182609	425	1
jes182613	425	1
jes182614	425	1
jes182615	425	1
jes182616	425	1
jes182617	425	1
jes182618	425	1
jes182621	425	1
jes182622	425	1
jes182624	425	1
jes182625	425	1
jes182627	425	1
jes182679	425	1
bb5120033	426	1
cec182681	426	1
cec182684	426	1
cec182686	426	1
cec182697	426	1
cec182704	426	1
cec182705	426	1
cec182707	426	1
cys177014	426	1
ee3160525	426	1
ee3160530	426	1
jes162142	426	1
bb1150060	427	1
ee1160456	427	1
eez188575	427	1
huz178593	427	1
jes182597	427	1
jes182599	427	1
jes182600	427	1
jes182602	427	1
jes182604	427	1
jes182605	427	1
jes182606	427	1
jes182607	427	1
jes182608	427	1
jes182609	427	1
jes182613	427	1
jes182614	427	1
jes182615	427	1
jes182616	427	1
jes182617	427	1
jes182618	427	1
jes182621	427	1
jes182622	427	1
jes182624	427	1
jes182625	427	1
jes182627	427	1
jes182679	427	1
me1150681	427	1
rdz188640	427	1
vst189728	427	1
chz188098	428	1
esz188516	428	1
esz188518	428	1
esz188661	428	1
jes162142	428	1
jes172168	428	1
jes172173	428	1
jes182597	428	1
jes182599	428	1
jes182600	428	1
jes182605	428	1
jes182618	428	1
ph1140795	428	1
vst189758	428	1
eey177538	429	1
eey187534	429	1
eez188573	429	1
eez188575	429	1
esz188517	429	1
jes182602	429	1
jes182606	429	1
jes182607	429	1
ees172287	430	1
ees172290	430	1
ees182861	430	1
jes162142	430	1
jes172168	430	1
jes172173	430	1
mt6140556	430	1
bb1160045	431	1
bb1160054	431	1
bb1160059	431	1
bb1160060	431	1
bb1160061	431	1
bb1160062	431	1
esz178657	431	1
esz188515	431	1
ph1110855	431	1
phz188372	431	1
phz188414	431	1
jes162142	432	1
jes172168	432	1
jes172173	432	1
jes172185	432	1
jit182315	432	1
jit182316	432	1
jit182317	432	1
jit182319	432	1
jit182323	432	1
jit182325	432	1
qiz188618	432	1
jes172184	433	1
jes172185	433	1
jes182597	433	1
jes182599	433	1
jes182600	433	1
jes182602	433	1
jes182604	433	1
jes182605	433	1
jes182606	433	1
jes182607	433	1
jes182608	433	1
jes182609	433	1
jes182613	433	1
jes182614	433	1
jes182615	433	1
jes182616	433	1
jes182617	433	1
jes182618	433	1
jes182621	433	1
jes182622	433	1
jes182624	433	1
jes182625	433	1
jes182679	433	1
ce1150395	434	1
ce1150399	434	1
ce1150403	434	1
ch1150083	434	1
ch7140186	434	1
cs1120265	434	1
cs1150219	434	1
cs1150237	434	1
cs1150260	434	1
cs1150268	434	1
ee1150423	434	1
ee1150429	434	1
ee1150433	434	1
ee1150456	434	1
ee3150530	434	1
me1150644	434	1
me1150664	434	1
me2150727	434	1
me2150739	434	1
me2160760	434	1
me2160765	434	1
mt1150596	434	1
ph1150816	434	1
ph1150825	434	1
ph1150836	434	1
tt1150874	434	1
bb5140012	435	1
ce1140360	435	1
ce1150395	435	1
ce1150399	435	1
ce1170167	435	1
ch1150084	435	1
ch1150118	435	1
ch7140164	435	1
ch7140189	435	1
ch7140194	435	1
ch7150175	435	1
cs1150246	435	1
ee3150507	435	1
me1150396	435	1
me1160686	435	1
me2150754	435	1
me2150768	435	1
mt6150551	435	1
ph1150786	435	1
ph1150795	435	1
ph1150808	435	1
ph1170843	435	1
tt1150891	435	1
tt1150937	435	1
bb1150042	436	1
bb5140015	436	1
ce1150307	436	1
ce1150363	436	1
ch7140156	436	1
ch7140170	436	1
cs1150229	436	1
cs1150238	436	1
cs1150261	436	1
cs1150435	436	1
ee1160420	436	1
ee1170451	436	1
me1130710	436	1
me1140656	436	1
me1160747	436	1
me2150717	436	1
me2150759	436	1
me2160775	436	1
mt1150587	436	1
mt6150561	436	1
ph1150808	436	1
ph1150812	436	1
tt1150948	436	1
tt1160872	436	1
bb5140009	437	1
ce1150321	437	1
ch7120152	437	1
ch7120168	437	1
ch7130159	437	1
ch7130170	437	1
cs1120265	437	1
cs1130237	437	1
cs5170401	437	1
ee1160423	437	1
ee1160468	437	1
ph1150793	437	1
ph1150804	437	1
ph1150810	437	1
ph1150811	437	1
tt1140185	437	1
tt1150874	437	1
bb5140015	438	1
ce1170094	438	1
ce1170106	438	1
ce1170108	438	1
ce1170110	438	1
ce1170115	438	1
ch1150124	438	1
ch1160093	438	1
ch1160096	438	1
ch1170226	438	1
ch1170228	438	1
ch7160192	438	1
ch7170280	438	1
cs1150218	438	1
cs1150244	438	1
me1130710	438	1
me1140656	438	1
me1150654	438	1
me1170061	438	1
me2150745	438	1
me2160770	438	1
mt1150616	438	1
mt1160636	438	1
mt6150555	438	1
tt1170917	438	1
ce1160218	439	1
ce1160230	439	1
ce1160285	439	1
ch1150087	439	1
ch1150092	439	1
ch1160076	439	1
ch1160090	439	1
ch7120152	439	1
cs1150257	439	1
ee3150520	439	1
ee3160490	439	1
me1130710	439	1
me1140656	439	1
mt1160608	439	1
mt6140557	439	1
mt6150113	439	1
ph1150796	439	1
ph1150812	439	1
ph1170834	439	1
tt1150893	439	1
tt1150951	439	1
tt1160855	439	1
bb5140015	440	1
ch1150131	440	1
ch1150134	440	1
ch1160120	440	1
ch7160192	440	1
cs1150207	440	1
cs1170336	440	1
cs5150280	440	1
cs5150282	440	1
ee1150439	440	1
me1140685	440	1
me1150660	440	1
me1150670	440	1
me2150766	440	1
mt1160636	440	1
ph1150785	440	1
ph1150806	440	1
ph1150812	440	1
tt1150893	440	1
tt1150903	440	1
tt1150912	440	1
tt1160855	440	1
vst189728	440	1
cs1150207	441	1
cs1170387	441	1
cs5150281	441	1
me1160747	441	1
huz178147	442	1
huz178661	442	1
huz188104	442	1
huz188108	442	1
huz188626	442	1
qiz188607	442	1
bb1150026	443	1
bb1160034	443	1
bb1160035	443	1
bb1160058	443	1
bb1160060	443	1
bb1160065	443	1
bb1170029	443	1
ce1150302	443	1
ce1150317	443	1
ce1150392	443	1
ce1150404	443	1
ce1160227	443	1
ce1170090	443	1
ce1170123	443	1
ch1150095	443	1
ch1150133	443	1
ch1150134	443	1
ch1150139	443	1
ch1150145	443	1
ch7140184	443	1
ch7140186	443	1
ch7150176	443	1
cs1150220	443	1
cs1160378	443	1
ee1100479	443	1
ee1130476	443	1
ee1140437	443	1
ee1150485	443	1
ee1150490	443	1
ee1150491	443	1
ee1150494	443	1
ee1170495	443	1
ee3140503	443	1
ee3150515	443	1
ee3150531	443	1
me1130727	443	1
me1150101	443	1
me1150670	443	1
me1160720	443	1
me2140759	443	1
me2150709	443	1
me2150717	443	1
me2150751	443	1
mt1150375	443	1
mt5110600	443	1
ph1140800	443	1
ph1150793	443	1
ph1150825	443	1
ph1160590	443	1
tt1140944	443	1
tt1150857	443	1
tt1150913	443	1
tt1160913	443	1
ce1150309	444	1
ce1150393	444	1
ee3150508	444	1
huz178587	444	1
huz178592	444	1
jds186007	444	1
me1150635	444	1
me1150673	444	1
qiz188617	444	1
smz158335	444	1
tt1150881	444	1
tt1150933	444	1
ee3150508	445	1
huz178587	445	1
huz178592	445	1
jds186007	445	1
me1150634	445	1
qiz188617	445	1
smz158335	445	1
tt1150881	445	1
tt1150920	445	1
tt1150933	445	1
ce1150330	446	1
ce1150365	446	1
ch7140172	446	1
ee1160420	446	1
ee5110563	446	1
huz188624	446	1
huz188626	446	1
huz188627	446	1
mt1150581	446	1
smz188175	446	1
smz188524	446	1
tt1160905	446	1
ch7150157	447	1
huz188624	447	1
me2150712	447	1
qiz188617	447	1
tt1150881	447	1
ch1120067	448	1
ee3150533	448	1
huz188106	448	1
huz188107	448	1
huz188112	448	1
huz188113	448	1
vst189740	448	1
vst189748	448	1
vst189750	448	1
huz178151	449	1
huz188106	449	1
huz188107	449	1
huz188112	449	1
huz188629	449	1
huz188630	449	1
cs5160387	450	1
ee3160500	450	1
huz188108	450	1
huz188114	450	1
huz188628	450	1
qiz188607	450	1
tt1100909	450	1
tt1150880	450	1
ce1160209	451	1
huz188619	451	1
huz188620	451	1
mas177061	451	1
mas177084	451	1
me2150741	451	1
ph1130849	451	1
amz188069	452	1
anz188059	452	1
asz188511	452	1
bey177534	452	1
blz188466	452	1
blz188467	452	1
bsz188115	452	1
bsz188116	452	1
bsz188122	452	1
cey167528	452	1
cez178527	452	1
cez178530	452	1
cez188035	452	1
cez188040	452	1
cez188043	452	1
cez188050	452	1
cez188396	452	1
chz178516	452	1
chz188087	452	1
chz188502	452	1
crz188302	452	1
csz178061	452	1
cyz188206	452	1
cyz188472	452	1
ddz188313	452	1
ddz188314	452	1
ddz188504	452	1
eez178556	452	1
eez178573	452	1
eez188146	452	1
eez188162	452	1
eez188567	452	1
esz178542	452	1
esz178544	452	1
esz178546	452	1
esz188056	452	1
esz188513	452	1
esz188515	452	1
esz188518	452	1
huz188114	452	1
huz188624	452	1
maz188448	452	1
me1160686	452	1
mez188288	452	1
mez188587	452	1
mez188588	452	1
mez188595	452	1
mez188596	452	1
mez188599	452	1
mez188600	452	1
phz178612	452	1
phz188329	452	1
phz188330	452	1
phz188336	452	1
phz188341	452	1
phz188364	452	1
phz188409	452	1
phz188414	452	1
phz188418	452	1
phz188419	452	1
phz188420	452	1
phz188421	452	1
phz188422	452	1
phz188425	452	1
phz188426	452	1
phz188428	452	1
phz188429	452	1
qiz188618	452	1
rdz178582	452	1
rdz188245	452	1
rdz188247	452	1
rdz188638	452	1
rdz188639	452	1
rdz188641	452	1
rdz188642	452	1
rdz188643	452	1
rdz188649	452	1
rdz188651	452	1
rdz188652	452	1
smz168030	452	1
smz188531	452	1
smz188535	452	1
smz188536	452	1
smz188544	452	1
ttz188231	452	1
amz188631	453	1
anz188001	453	1
anz188061	453	1
anz188387	453	1
anz188521	453	1
bez188436	453	1
bez188437	453	1
bez188438	453	1
bez188439	453	1
bez188440	453	1
bez188441	453	1
bez188442	453	1
blz188462	453	1
blz188463	453	1
blz188464	453	1
blz188465	453	1
blz188468	453	1
blz188469	453	1
blz188470	453	1
bsz188121	453	1
bsz188291	453	1
cez188028	453	1
cez188029	453	1
cez188031	453	1
cez188044	453	1
cez188391	453	1
cez188392	453	1
cez188393	453	1
cez188395	453	1
cez188398	453	1
cez188401	453	1
cez188405	453	1
cez188406	453	1
chz188085	453	1
chz188086	453	1
chz188386	453	1
chz188486	453	1
chz188488	453	1
chz188493	453	1
chz188496	453	1
chz188497	453	1
chz188500	453	1
chz188547	453	1
chz188663	453	1
csz188295	453	1
cyz188207	453	1
cyz188473	453	1
cyz188474	453	1
cyz188477	453	1
cyz188479	453	1
cyz188480	453	1
cyz188482	453	1
cyz188483	453	1
cyz188484	453	1
cyz188658	453	1
eez178187	453	1
eez188126	453	1
eez188129	453	1
eez188131	453	1
eez188140	453	1
eez188143	453	1
eez188150	453	1
eez188152	453	1
eez188154	453	1
eez188163	453	1
eez188570	453	1
esz188514	453	1
esz188516	453	1
itz188548	453	1
itz188549	453	1
maz188255	453	1
maz188444	453	1
maz188445	453	1
maz188452	453	1
mez168557	453	1
mez178602	453	1
mez188261	453	1
mez188262	453	1
mez188263	453	1
mez188264	453	1
mez188265	453	1
mez188267	453	1
mez188268	453	1
mez188270	453	1
mez188271	453	1
mez188286	453	1
mez188582	453	1
mez188589	453	1
mez188590	453	1
msz188015	453	1
msz188290	453	1
phz188319	453	1
phz188323	453	1
phz188325	453	1
phz188333	453	1
phz188357	453	1
phz188358	453	1
phz188362	453	1
phz188365	453	1
phz188369	453	1
phz188370	453	1
phz188372	453	1
phz188410	453	1
phz188412	453	1
phz188413	453	1
phz188415	453	1
phz188416	453	1
phz188417	453	1
phz188423	453	1
phz188424	453	1
phz188430	453	1
phz188432	453	1
rdz188248	453	1
rdz188645	453	1
rdz188646	453	1
rdz188648	453	1
smz178464	453	1
smz188173	453	1
smz188175	453	1
smz188179	453	1
smz188181	453	1
smz188182	453	1
smz188185	453	1
smz188187	453	1
smz188190	453	1
smz188192	453	1
smz188527	453	1
smz188532	453	1
smz188539	453	1
smz188541	453	1
smz188611	453	1
smz188612	453	1
srz188305	453	1
ttz178475	453	1
ttz188227	453	1
ttz188454	453	1
ttz188455	453	1
ttz188458	453	1
ttz188459	453	1
vst189740	453	1
vst189748	453	1
vst189750	453	1
huz178661	454	1
huz188103	454	1
huz188104	454	1
bb1150062	455	1
ch1150090	455	1
cs1140227	455	1
cs1150247	455	1
cs1150253	455	1
ee3150526	455	1
huz158505	455	1
huz188106	455	1
huz188113	455	1
huz188619	455	1
huz188629	455	1
huz188630	455	1
me2150741	455	1
mt6130581	455	1
ph1150811	455	1
vst189740	455	1
vst189748	455	1
vst189750	455	1
ce1140333	456	1
cev182232	456	1
ee3150533	456	1
ee3160516	456	1
huz168529	456	1
huz188107	456	1
huz188629	456	1
huz188630	456	1
mt1160635	456	1
mt1160636	456	1
tt1150879	456	1
tt1160884	456	1
vst189748	456	1
bb5110049	458	1
cs1160371	458	1
ee3160530	458	1
huz178150	458	1
huz178661	458	1
huz188103	458	1
huz188104	458	1
huz188108	458	1
huz188109	458	1
huz188110	458	1
huz188114	458	1
huz188623	458	1
mt5100631	458	1
qiz188617	458	1
anz168049	459	1
ce1150325	459	1
ch1150104	459	1
ddz188311	459	1
ddz188312	459	1
ee1150454	459	1
ee3150508	459	1
ee3150529	459	1
ee5110563	459	1
huz178592	459	1
huz188109	459	1
huz188110	459	1
huz188623	459	1
huz188624	459	1
huz188626	459	1
huz188628	459	1
me1150396	459	1
me2150712	459	1
qiz188607	459	1
qiz188617	459	1
smz178008	459	1
smz178441	459	1
bb1170002	460	1
bb1170004	460	1
bb1170005	460	1
bb1170015	460	1
bb1170026	460	1
bb1170027	460	1
bb1170037	460	1
bb1170038	460	1
ce1170071	460	1
ce1170072	460	1
ce1170080	460	1
ce1170094	460	1
ce1170095	460	1
ce1170097	460	1
ce1170099	460	1
ce1170105	460	1
ce1170106	460	1
ce1170108	460	1
ce1170110	460	1
ce1170111	460	1
ce1170112	460	1
ce1170115	460	1
ce1170116	460	1
ce1170117	460	1
ce1170155	460	1
ce1170163	460	1
ce1170171	460	1
ce1170174	460	1
ch7160154	460	1
cs1160336	460	1
cs1170219	460	1
cs1170323	460	1
cs1170324	460	1
cs1170326	460	1
cs1170329	460	1
cs1170340	460	1
cs1170353	460	1
cs1170359	460	1
cs1170360	460	1
cs1170387	460	1
cs1170481	460	1
cs1170540	460	1
cs5160615	460	1
cs5170408	460	1
cs5170602	460	1
ee1170434	460	1
ee1170438	460	1
ee1170443	460	1
ee1170444	460	1
ee1170445	460	1
ee1170446	460	1
ee1170475	460	1
ee1170480	460	1
ee1170490	460	1
ee1170497	460	1
ee1170704	460	1
ee1170937	460	1
ee3160161	460	1
me1170567	460	1
me1170573	460	1
me1170574	460	1
me1170578	460	1
me1170579	460	1
me1170587	460	1
me1170595	460	1
me1170598	460	1
me1170611	460	1
me1170612	460	1
me1170618	460	1
me1170628	460	1
me1170967	460	1
me2150753	460	1
me2170645	460	1
me2170670	460	1
me2170691	460	1
mt1150586	460	1
mt1170213	460	1
mt1170287	460	1
mt1170724	460	1
mt1170727	460	1
mt1170730	460	1
mt1170737	460	1
mt1170738	460	1
mt1170744	460	1
mt1170745	460	1
mt1170747	460	1
mt1170749	460	1
mt1170750	460	1
mt1170752	460	1
mt1170756	460	1
mt1170772	460	1
mt6170078	460	1
mt6170250	460	1
mt6170499	460	1
mt6170774	460	1
mt6170775	460	1
mt6170777	460	1
mt6170778	460	1
mt6170780	460	1
tt1170871	460	1
tt1170877	460	1
bb1170032	461	1
ce1170079	461	1
ce1170089	461	1
ce1170119	461	1
ce1170127	461	1
ch1160077	461	1
ch1170114	461	1
ch1170161	461	1
ch1170189	461	1
ch1170190	461	1
ch1170194	461	1
ch1170196	461	1
ch1170198	461	1
ch1170205	461	1
ch1170210	461	1
ch1170211	461	1
ch1170224	461	1
ch1170232	461	1
ch1170233	461	1
ch1170244	461	1
ch1170311	461	1
ch7160167	461	1
ch7170278	461	1
ch7170283	461	1
ch7170284	461	1
ch7170291	461	1
cs1160349	461	1
cs1160351	461	1
cs1170321	461	1
cs1170322	461	1
cs1170325	461	1
cs1170347	461	1
cs1170349	461	1
cs1170350	461	1
cs1170366	461	1
cs5160388	461	1
cs5160414	461	1
cs5170422	461	1
ee1150735	461	1
ee1170435	461	1
ee1170479	461	1
ee1170492	461	1
ee3150511	461	1
ee3150513	461	1
ee3170221	461	1
ee3170513	461	1
ee3170517	461	1
ee3170523	461	1
ee3170534	461	1
ee3170535	461	1
ee3170872	461	1
me1150396	461	1
me1160036	461	1
me1160824	461	1
me1170021	461	1
me1170158	461	1
me1170561	461	1
me1170562	461	1
me1170566	461	1
me1170575	461	1
me1170585	461	1
me1170586	461	1
me1170600	461	1
me1170605	461	1
me1170606	461	1
me1170621	461	1
me1170623	461	1
me1170950	461	1
me2150734	461	1
me2170650	461	1
me2170652	461	1
me2170663	461	1
me2170672	461	1
me2170677	461	1
mt1170726	461	1
mt1170735	461	1
mt1170736	461	1
mt1170739	461	1
mt1170743	461	1
mt6170779	461	1
mt6170784	461	1
mt6170786	461	1
ph1170803	461	1
ph1170806	461	1
ph1170819	461	1
ph1170845	461	1
tt1160843	461	1
tt1170873	461	1
tt1170896	461	1
tt1170918	461	1
tt1170919	461	1
tt1170920	461	1
tt1170921	461	1
tt1170929	461	1
tt1170930	461	1
bb1160031	462	1
bb1170008	462	1
bb1170014	462	1
bb1170029	462	1
bb5170057	462	1
bb5170060	462	1
bb5170065	462	1
ce1150398	462	1
ce1170077	462	1
ce1170081	462	1
ce1170121	462	1
ce1170122	462	1
ce1170144	462	1
ce1170154	462	1
ce1170156	462	1
ce1170157	462	1
ce1170159	462	1
ce1170164	462	1
ch1140786	462	1
ch1150135	462	1
ch1170087	462	1
ch1170188	462	1
ch1170195	462	1
ch1170212	462	1
ch1170223	462	1
ch7100145	462	1
ch7170281	462	1
ch7170285	462	1
ch7170292	462	1
ch7170294	462	1
ch7170299	462	1
cs1150218	462	1
cs1170334	462	1
cs1170335	462	1
cs1170341	462	1
cs1170343	462	1
cs1170346	462	1
cs1170355	462	1
cs1170358	462	1
cs1170361	462	1
cs1170363	462	1
cs1170369	462	1
cs1170380	462	1
cs1170487	462	1
cs1170790	462	1
cs1170836	462	1
cs5170405	462	1
cs5170412	462	1
cs5170419	462	1
cs5170488	462	1
cs5170493	462	1
ee1150438	462	1
ee1150439	462	1
ee1160434	462	1
ee1170345	462	1
ee1170453	462	1
ee1170454	462	1
ee1170456	462	1
ee1170460	462	1
ee1170461	462	1
ee1170476	462	1
ee3170019	462	1
ee3170543	462	1
ee3170545	462	1
ee3170547	462	1
ee3170550	462	1
me1170568	462	1
me1170581	462	1
me1170582	462	1
me1170607	462	1
me1170613	462	1
me1170620	462	1
me1170651	462	1
me1170960	462	1
me2150736	462	1
me2160791	462	1
me2170649	462	1
me2170666	462	1
me2170668	462	1
me2170671	462	1
me2170673	462	1
me2170681	462	1
me2170695	462	1
mt1150594	462	1
mt1170723	462	1
mt1170754	462	1
mt6170207	462	1
mt6170855	462	1
ph1160549	462	1
ph1170847	462	1
tt1160842	462	1
tt1160872	462	1
tt1170881	462	1
tt1170912	462	1
tt1170914	462	1
tt1170924	462	1
tt1170954	462	1
tt1170963	462	1
tt1170968	462	1
tt1170971	462	1
bb1150041	463	1
bb1150059	463	1
bb5140001	463	1
ce1130323	463	1
ce1150306	463	1
ce1150311	463	1
ce1150342	463	1
ce1150378	463	1
ce1160217	463	1
ce1160245	463	1
ce1160263	463	1
ce1160305	463	1
ce1170082	463	1
ce1170131	463	1
ce1170167	463	1
ch1120067	463	1
ch1130080	463	1
ch1130119	463	1
ch1140071	463	1
ch1150097	463	1
ch1150117	463	1
ch1150124	463	1
ch1150127	463	1
ch1150945	463	1
ch1160076	463	1
ch1160137	463	1
ch1160144	463	1
ch1170240	463	1
ch7140180	463	1
ch7150151	463	1
ch7150155	463	1
ch7150157	463	1
ch7150158	463	1
ch7160150	463	1
ch7160151	463	1
ch7160174	463	1
ch7170290	463	1
cs1150229	463	1
cs1150230	463	1
cs1150238	463	1
cs1150246	463	1
cs1150268	463	1
cs5140292	463	1
cs5170406	463	1
cs5170410	463	1
ee1150427	463	1
ee1150433	463	1
ee1150469	463	1
ee1150534	463	1
ee1150835	463	1
ee1160476	463	1
ee1170442	463	1
ee1170452	463	1
ee3150516	463	1
ee3150523	463	1
ee3150536	463	1
ee3150541	463	1
ee3160504	463	1
ee3160514	463	1
ee3160519	463	1
ee3160526	463	1
ee3170511	463	1
ee3170512	463	1
ee3170515	463	1
ee3170537	463	1
me1140667	463	1
me1150631	463	1
me1150648	463	1
me1150683	463	1
me1150689	463	1
me1160682	463	1
me1160704	463	1
me2150719	463	1
me2150721	463	1
me2150745	463	1
me2160762	463	1
me2160803	463	1
me2170685	463	1
mt1150319	463	1
mt1150582	463	1
mt1150599	463	1
mt1150607	463	1
mt1160639	463	1
mt1170721	463	1
mt6150567	463	1
ph1150792	463	1
ph1150795	463	1
ph1150814	463	1
ph1150823	463	1
ph1150836	463	1
ph1160560	463	1
ph1160587	463	1
ph1170828	463	1
ph1170832	463	1
ph1170849	463	1
tt1150853	463	1
tt1150881	463	1
tt1150921	463	1
tt1150938	463	1
tt1170932	463	1
tt1170944	463	1
tt1170962	463	1
bb1160027	464	1
bb1160035	464	1
bb1160039	464	1
bb1170018	464	1
bb1170024	464	1
bb1170045	464	1
ce1150395	464	1
ce1160232	464	1
ce1160235	464	1
ce1160236	464	1
ce1160243	464	1
ce1160296	464	1
ce1170129	464	1
ce1170130	464	1
ce1170134	464	1
ce1170152	464	1
ce1170160	464	1
ce1170162	464	1
ce1170165	464	1
ce1170166	464	1
ce1170168	464	1
ce1170169	464	1
ce1170170	464	1
ch1150123	464	1
ch7150187	464	1
ch7160157	464	1
ch7160159	464	1
ch7160175	464	1
cs1140227	464	1
cs1150216	464	1
cs1150234	464	1
cs1160311	464	1
cs1160315	464	1
cs1160316	464	1
cs1160321	464	1
cs1160322	464	1
cs1160327	464	1
cs1160329	464	1
cs1160379	464	1
cs1170348	464	1
cs1170357	464	1
cs1170367	464	1
cs5160625	464	1
cs5160789	464	1
cs5170404	464	1
ee1150445	464	1
ee1160448	464	1
ee1160472	464	1
ee1170455	464	1
ee3160522	464	1
ee3160532	464	1
ee3170527	464	1
ee3170528	464	1
ee3170529	464	1
ee3170531	464	1
ee3170541	464	1
ee3170549	464	1
me1160683	464	1
me1160698	464	1
me1160709	464	1
me1170570	464	1
me1170698	464	1
me1170702	464	1
me2160800	464	1
me2170643	464	1
me2170686	464	1
me2170696	464	1
me2170697	464	1
me2170699	464	1
me2170700	464	1
me2170701	464	1
me2170705	464	1
me2170706	464	1
mt1160619	464	1
mt1160624	464	1
mt1170733	464	1
mt1170734	464	1
mt1170740	464	1
mt1170741	464	1
mt1170753	464	1
mt6170783	464	1
mt6170785	464	1
mt6170788	464	1
ph1160584	464	1
ph1170811	464	1
ph1170812	464	1
ph1170818	464	1
ph1170841	464	1
ph1170846	464	1
ph1170942	464	1
tt1150922	464	1
tt1160877	464	1
tt1160887	464	1
tt1160900	464	1
tt1170887	464	1
tt1170910	464	1
tt1170943	464	1
tt1170948	464	1
tt1170956	464	1
tt1170958	464	1
tt1170969	464	1
bb1160028	465	1
bb1160046	465	1
bb1160051	465	1
bb1160053	465	1
bb1160057	465	1
bb1160061	465	1
bb1160062	465	1
bb1160064	465	1
bb1170001	465	1
bb1170003	465	1
bb1170007	465	1
bb1170012	465	1
bb1170016	465	1
bb1170020	465	1
bb1170023	465	1
bb1170025	465	1
bb1170028	465	1
bb1170030	465	1
bb1170031	465	1
bb1170033	465	1
bb1170034	465	1
bb1170035	465	1
bb1170039	465	1
bb1170040	465	1
bb1170041	465	1
bb1170046	465	1
bb5170051	465	1
bb5170053	465	1
bb5170055	465	1
bb5170056	465	1
bb5170058	465	1
bb5170059	465	1
bb5170064	465	1
ce1160200	465	1
ce1160202	465	1
ce1160204	465	1
ce1160206	465	1
ce1160207	465	1
ce1160209	465	1
ce1160210	465	1
ce1160211	465	1
ce1160212	465	1
ce1160213	465	1
ce1160221	465	1
ce1160223	465	1
ce1160237	465	1
ce1160247	465	1
ce1160258	465	1
ce1160262	465	1
ce1160266	465	1
ce1160272	465	1
ce1160278	465	1
ce1170073	465	1
ce1170075	465	1
ce1170092	465	1
ce1170100	465	1
ce1170113	465	1
ce1170138	465	1
ce1170139	465	1
ce1170145	465	1
ce1170147	465	1
ce1170151	465	1
ce1170153	465	1
ch1160070	465	1
ch1160075	465	1
ch1160079	465	1
ch1160081	465	1
ch1160092	465	1
ch1160105	465	1
ch1160112	465	1
ch1160118	465	1
ch1160120	465	1
ch1160122	465	1
ch1160126	465	1
ch1160675	465	1
ch7160152	465	1
ch7160158	465	1
ch7160162	465	1
ch7160165	465	1
ch7160178	465	1
ch7160182	465	1
ch7160183	465	1
ch7160187	465	1
ch7160193	465	1
cs1160310	465	1
cs1160317	465	1
cs1160323	465	1
cs1160333	465	1
cs1160335	465	1
cs1160341	465	1
cs1160356	465	1
cs1160358	465	1
cs1160360	465	1
cs1160362	465	1
cs1160364	465	1
cs1160369	465	1
cs1160370	465	1
cs1160372	465	1
cs1160374	465	1
cs1160376	465	1
cs1160396	465	1
cs1160412	465	1
cs1160513	465	1
cs1170327	465	1
cs1170328	465	1
cs1170330	465	1
cs1170332	465	1
cs1170336	465	1
cs1170338	465	1
cs1170339	465	1
cs1170342	465	1
cs1170344	465	1
cs1170351	465	1
cs1170352	465	1
cs1170356	465	1
cs1170362	465	1
cs1170364	465	1
cs1170365	465	1
cs1170370	465	1
cs1170371	465	1
cs1170372	465	1
cs1170373	465	1
cs1170374	465	1
cs1170375	465	1
cs1170376	465	1
cs1170377	465	1
cs1170378	465	1
cs1170379	465	1
cs1170381	465	1
cs1170382	465	1
cs1170383	465	1
cs1170384	465	1
cs1170385	465	1
cs1170386	465	1
cs1170388	465	1
cs1170389	465	1
cs1170390	465	1
cs1170416	465	1
cs1170489	465	1
cs5160397	465	1
cs5160398	465	1
cs5160402	465	1
cs5160404	465	1
cs5170401	465	1
cs5170402	465	1
cs5170403	465	1
cs5170407	465	1
cs5170411	465	1
cs5170414	465	1
cs5170415	465	1
cs5170417	465	1
cs5170420	465	1
cs5170421	465	1
cs5170521	465	1
ee1160071	465	1
ee1160160	465	1
ee1160410	465	1
ee1160429	465	1
ee1160431	465	1
ee1160435	465	1
ee1160438	465	1
ee1160440	465	1
ee1160446	465	1
ee1160453	465	1
ee1160457	465	1
ee1160458	465	1
ee1160460	465	1
ee1160462	465	1
ee1160463	465	1
ee1160464	465	1
ee1160465	465	1
ee1160466	465	1
ee1160480	465	1
ee1160482	465	1
ee1160556	465	1
ee1160571	465	1
ee1160694	465	1
ee1170306	465	1
ee1170431	465	1
ee1170432	465	1
ee1170433	465	1
ee1170436	465	1
ee1170440	465	1
ee1170441	465	1
ee1170447	465	1
ee1170450	465	1
ee1170451	465	1
ee1170455	465	1
ee1170457	465	1
ee1170463	465	1
ee1170464	465	1
ee1170466	465	1
ee1170471	465	1
ee1170478	465	1
ee1170485	465	1
ee1170486	465	1
ee1170491	465	1
ee1170494	465	1
ee1170496	465	1
ee1170502	465	1
ee1170504	465	1
ee1170505	465	1
ee1170565	465	1
ee1170599	465	1
me1160080	465	1
me1160670	465	1
me1160671	465	1
me1160672	465	1
me1160673	465	1
me1160676	465	1
me1160707	465	1
me1160711	465	1
me1160714	465	1
me1160715	465	1
me1160716	465	1
me1160723	465	1
me1160725	465	1
me1160727	465	1
me1160731	465	1
me1160732	465	1
me1160737	465	1
me1170061	465	1
me1170564	465	1
me1170571	465	1
me1170580	465	1
me1170590	465	1
me1170592	465	1
me1170594	465	1
me1170596	465	1
me1170601	465	1
me1170603	465	1
me1170604	465	1
me1170609	465	1
me1170610	465	1
me1170617	465	1
me2120795	465	1
me2170653	465	1
me2170655	465	1
me2170656	465	1
me2170662	465	1
me2170664	465	1
me2170667	465	1
me2170669	465	1
me2170674	465	1
me2170678	465	1
me2170679	465	1
me2170683	465	1
me2170685	465	1
me2170690	465	1
me2170703	465	1
mt1160607	465	1
mt1160617	465	1
mt1160620	465	1
mt1160623	465	1
mt1160629	465	1
mt1160630	465	1
mt1160633	465	1
mt1170520	465	1
mt1170530	465	1
mt1170722	465	1
mt1170725	465	1
mt1170728	465	1
mt1170729	465	1
mt1170731	465	1
mt1170732	465	1
mt1170746	465	1
mt1170748	465	1
mt1170751	465	1
mt1170755	465	1
mt6170771	465	1
mt6170781	465	1
mt6170782	465	1
mt6170787	465	1
ph1160542	465	1
ph1160554	465	1
ph1160567	465	1
ph1160569	465	1
ph1160573	465	1
ph1160575	465	1
ph1160580	465	1
ph1160585	465	1
ph1160591	465	1
ph1160592	465	1
ph1160594	465	1
ph1170859	465	1
tt1150904	465	1
tt1160663	465	1
tt1160831	465	1
tt1160840	465	1
tt1160846	465	1
tt1160848	465	1
tt1160868	465	1
tt1160878	465	1
tt1160881	465	1
tt1160895	465	1
tt1160902	465	1
tt1160906	465	1
tt1160907	465	1
tt1160908	465	1
tt1160912	465	1
tt1160923	465	1
bb1150053	466	1
bb1170013	466	1
bb5160001	466	1
bb5160009	466	1
ce1150397	466	1
ce1160205	466	1
ce1160219	466	1
ce1160265	466	1
ce1160269	466	1
ce1160273	466	1
ce1160275	466	1
ce1160277	466	1
ce1160284	466	1
ce1160298	466	1
ce1160304	466	1
ce1170074	466	1
ce1170076	466	1
ce1170083	466	1
ce1170098	466	1
ce1170125	466	1
ce1170126	466	1
ce1170128	466	1
ce1170132	466	1
ce1170133	466	1
ce1170135	466	1
ce1170136	466	1
ce1170137	466	1
ce1170140	466	1
ce1170141	466	1
ce1170142	466	1
ce1170143	466	1
ce1170150	466	1
ce1170172	466	1
ch1160102	466	1
ch1160131	466	1
ch7160155	466	1
ch7160163	466	1
ch7160164	466	1
ch7160168	466	1
ch7160171	466	1
ch7160179	466	1
ch7160186	466	1
ch7160188	466	1
ch7160190	466	1
cs1160294	466	1
cs1160330	466	1
cs1160332	466	1
cs1160337	466	1
cs1160353	466	1
cs1160365	466	1
cs1160367	466	1
cs1160373	466	1
cs1170331	466	1
cs1170333	466	1
cs1170337	466	1
cs1170354	466	1
cs1170368	466	1
cs1170503	466	1
cs5160399	466	1
cs5160403	466	1
cs5170413	466	1
ee1130447	466	1
ee1130483	466	1
ee1150111	466	1
ee1160452	466	1
ee1160825	466	1
ee1170500	466	1
ee3150112	466	1
me1150110	466	1
me1160678	466	1
me1160706	466	1
me1160717	466	1
me1160722	466	1
me1160729	466	1
me1160730	466	1
me1160734	466	1
me1160735	466	1
me1170616	466	1
me2170647	466	1
me2170648	466	1
me2170660	466	1
me2170692	466	1
me2170707	466	1
mt1160627	466	1
mt1160640	466	1
mt6170773	466	1
ph1150797	466	1
ph1150827	466	1
ph1160566	466	1
ph1160568	466	1
ph1160574	466	1
ph1160577	466	1
tt1150866	466	1
tt1150869	466	1
tt1150895	466	1
tt1160854	466	1
tt1160915	466	1
tt1160922	466	1
tt1170874	466	1
bb1150031	467	1
bb1150050	467	1
bb1150052	467	1
bb1150061	467	1
bb1150063	467	1
bb1150065	467	1
bb1170006	467	1
bb1170009	467	1
bb5070011	467	1
bb5140004	467	1
bb5150010	467	1
bb5150015	467	1
bb5170062	467	1
ce1150328	467	1
ce1150338	467	1
ce1150363	467	1
ce1150371	467	1
ce1150372	467	1
ce1150387	467	1
ce1150400	467	1
ce1160214	467	1
ce1160271	467	1
ce1170146	467	1
ce1170148	467	1
ch1150071	467	1
ch1150072	467	1
ch1150091	467	1
ch1150094	467	1
ch1150116	467	1
ch1160108	467	1
ch1160121	467	1
ch7130170	467	1
ch7140172	467	1
ch7140181	467	1
ch7140196	467	1
cs1140266	467	1
cs1150244	467	1
cs1150265	467	1
cs5120299	467	1
cs5140736	467	1
ee1140421	467	1
ee1150421	467	1
ee1150430	467	1
ee1150458	467	1
ee1150467	467	1
ee1150488	467	1
ee1150493	467	1
ee1150519	467	1
ee1160477	467	1
ee1170498	467	1
ee1170608	467	1
ee3150507	467	1
ee3150518	467	1
ee3150520	467	1
ee3150524	467	1
ee3150526	467	1
ee3150529	467	1
ee3150539	467	1
me1130671	467	1
me1150228	467	1
me1150654	467	1
me1160728	467	1
me2120768	467	1
me2150731	467	1
me2150732	467	1
me2150733	467	1
me2150738	467	1
me2150763	467	1
me2150768	467	1
me2170657	467	1
me2170658	467	1
me2170661	467	1
me2170675	467	1
me2170842	467	1
mt1140593	467	1
mt1150587	467	1
ph1140795	467	1
ph1140805	467	1
ph1140824	467	1
ph1150788	467	1
ph1150789	467	1
ph1150803	467	1
ph1150817	467	1
ph1150822	467	1
ph1150831	467	1
ph1150834	467	1
tt1100909	467	1
tt1130975	467	1
tt1150874	467	1
tt1150877	467	1
tt1150891	467	1
tt1150897	467	1
tt1150919	467	1
tt1160924	467	1
bb1170011	468	1
bb1170047	468	1
bb5150003	468	1
bb5170054	468	1
ce1150320	468	1
ce1150384	468	1
ce1160215	468	1
ce1160229	468	1
ce1160231	468	1
ce1160234	468	1
ce1160238	468	1
ce1160295	468	1
ce1170088	468	1
ce1170091	468	1
ce1170096	468	1
ce1170102	468	1
ce1170103	468	1
ce1170104	468	1
ce1170118	468	1
ce1170124	468	1
ch1150115	468	1
ch1150142	468	1
ch1160096	468	1
ch1160142	468	1
ch1170209	468	1
ch1170216	468	1
ch7150183	468	1
ch7150193	468	1
ch7160169	468	1
ch7160185	468	1
ch7160189	468	1
ch7160191	468	1
ch7170314	468	1
cs1150211	468	1
cs1150231	468	1
cs1160371	468	1
cs1170589	468	1
ee1150436	468	1
ee1150456	468	1
ee1150490	468	1
ee1160447	468	1
ee1170449	468	1
ee3150505	468	1
ee3150510	468	1
ee3150522	468	1
ee3150528	468	1
ee3160502	468	1
ee3160503	468	1
ee3170522	468	1
ee3170533	468	1
ee3170542	468	1
ee3170552	468	1
ee3170553	468	1
ee3170555	468	1
me1130729	468	1
me1150663	468	1
me1150679	468	1
me1150682	468	1
me1150684	468	1
me1150690	468	1
me1170572	468	1
me1170588	468	1
me1170624	468	1
me1170625	468	1
me1170626	468	1
me1170627	468	1
me2150743	468	1
me2150759	468	1
me2160784	468	1
me2170646	468	1
me2170680	468	1
me2170693	468	1
me2170694	468	1
mt1150585	468	1
mt1150616	468	1
mt1160632	468	1
mt6150113	468	1
mt6160078	468	1
ph1170813	468	1
ph1170834	468	1
ph1170835	468	1
ph1170844	468	1
ph1170853	468	1
tt1150875	468	1
tt1150889	468	1
tt1150893	468	1
tt1150918	468	1
tt1150932	468	1
tt1150955	468	1
tt1160867	468	1
tt1160882	468	1
tt1160886	468	1
tt1160914	468	1
tt1160925	468	1
tt1170925	468	1
tt1170933	468	1
tt1170972	468	1
bb1150047	469	1
bb1160023	469	1
bb1160024	469	1
bb1160025	469	1
bb1160029	469	1
bb1160032	469	1
bb1160037	469	1
bb1160041	469	1
bb1160044	469	1
bb1160049	469	1
bb1160054	469	1
bb1160055	469	1
bb1160056	469	1
bb5160002	469	1
bb5160003	469	1
bb5160005	469	1
bb5160006	469	1
bb5160007	469	1
bb5160012	469	1
bb5160013	469	1
ce1140333	469	1
ce1150350	469	1
ch1150133	469	1
ch7100145	469	1
ch7140159	469	1
cs1160087	469	1
cs1160331	469	1
cs1160348	469	1
cs1160352	469	1
cs1160355	469	1
cs1160357	469	1
cs1160359	469	1
cs1160363	469	1
cs1160406	469	1
cs5160389	469	1
cs5160391	469	1
cs5160392	469	1
cs5160393	469	1
cs5160394	469	1
cs5160433	469	1
ee1160411	469	1
ee1160419	469	1
ee1160425	469	1
ee1160427	469	1
ee1160428	469	1
ee1160430	469	1
ee1160432	469	1
ee1160436	469	1
ee1160437	469	1
ee1160445	469	1
ee1160456	469	1
ee1160469	469	1
ee1160470	469	1
ee1160471	469	1
ee1160473	469	1
ee1160474	469	1
ee1160478	469	1
ee1160479	469	1
ee1160484	469	1
ee1160835	469	1
ee3150503	469	1
ee3150512	469	1
ee3150898	469	1
me1110701	469	1
me1130679	469	1
me1150640	469	1
me2160748	469	1
me2160750	469	1
me2160753	469	1
me2170644	469	1
me2170688	469	1
me2170689	469	1
ph1150828	469	1
ph1160086	469	1
ph1160550	469	1
ph1160553	469	1
ph1160555	469	1
ph1160563	469	1
ph1160570	469	1
ph1160578	469	1
ph1160579	469	1
tt1160822	469	1
tt1160834	469	1
tt1160836	469	1
tt1160844	469	1
tt1160849	469	1
tt1160850	469	1
tt1160852	469	1
tt1160853	469	1
tt1160857	469	1
tt1160858	469	1
tt1160859	469	1
tt1160861	469	1
tt1160864	469	1
tt1160869	469	1
tt1160871	469	1
tt1160874	469	1
tt1160876	469	1
tt1160879	469	1
tt1160884	469	1
tt1160889	469	1
tt1160891	469	1
tt1160893	469	1
tt1160911	469	1
tt1160927	469	1
bb1150064	470	1
bb1160048	470	1
bb1170017	470	1
ce1150346	470	1
ce1150353	470	1
ce1160201	470	1
ce1160230	470	1
ce1160239	470	1
ce1160256	470	1
ce1160257	470	1
ce1160259	470	1
ce1160261	470	1
ce1160279	470	1
ce1160287	470	1
ce1160303	470	1
ce1170084	470	1
ce1170085	470	1
ce1170175	470	1
ch1150087	470	1
ch1150103	470	1
ch1150106	470	1
ch1150118	470	1
ch1150120	470	1
ch1150131	470	1
ch1160098	470	1
ch1160101	470	1
ch1160104	470	1
ch1160129	470	1
ch1160132	470	1
ch1160133	470	1
ch1160134	470	1
ch1160138	470	1
ch1160141	470	1
ch1170242	470	1
ch1170246	470	1
ch7160153	470	1
ch7160173	470	1
ch7160176	470	1
ch7170295	470	1
ch7170302	470	1
ch7170303	470	1
ch7170307	470	1
cs1150258	470	1
cs1160324	470	1
cs1160325	470	1
cs5170409	470	1
ee1150442	470	1
ee1150455	470	1
ee1150465	470	1
ee1150476	470	1
ee1160050	470	1
ee1160483	470	1
ee1170473	470	1
ee1170501	470	1
ee3150152	470	1
ee3160490	470	1
ee3160527	470	1
ee3170514	470	1
ee3170516	470	1
ee3170525	470	1
ee3170526	470	1
ee3170532	470	1
ee3170554	470	1
me1150383	470	1
me1150662	470	1
me1150675	470	1
me1160684	470	1
me1160705	470	1
me1160724	470	1
me1160726	470	1
me1160733	470	1
me1160736	470	1
me1170591	470	1
me1170614	470	1
me1170619	470	1
me2140761	470	1
me2150707	470	1
me2150708	470	1
me2150710	470	1
me2150714	470	1
me2150748	470	1
me2150758	470	1
me2160745	470	1
me2160797	470	1
me2170641	470	1
me2170642	470	1
mt1150591	470	1
mt1160608	470	1
mt1160638	470	1
mt5110600	470	1
mt6150554	470	1
mt6150556	470	1
mt6160656	470	1
mt6170789	470	1
ph1150794	470	1
ph1160557	470	1
ph1170801	470	1
ph1170816	470	1
ph1170822	470	1
ph1170827	470	1
ph1170848	470	1
tt1140905	470	1
tt1150867	470	1
tt1150901	470	1
tt1150924	470	1
tt1150937	470	1
tt1160873	470	1
tt1160917	470	1
tt1160918	470	1
tt1170891	470	1
tt1170892	470	1
tt1170903	470	1
tt1170904	470	1
tt1170928	470	1
tt1170947	470	1
bb1150032	471	1
bb1150033	471	1
bb1150034	471	1
bb1150046	471	1
bb1150048	471	1
bb1150055	471	1
ce1140348	471	1
ce1150328	471	1
ce1150340	471	1
ce1150343	471	1
ce1150345	471	1
ce1150347	471	1
ce1150364	471	1
ce1150377	471	1
ce1150381	471	1
ce1150382	471	1
ce1150386	471	1
ce1150398	471	1
ch1150002	471	1
ch1150075	471	1
ch1150081	471	1
ch1150085	471	1
ch1150095	471	1
ch1150125	471	1
ch7150153	471	1
ch7150166	471	1
ch7150167	471	1
ch7150168	471	1
ch7150188	471	1
ch7150189	471	1
ch7150193	471	1
ch7150194	471	1
ch7150195	471	1
cs1150247	471	1
cs1150252	471	1
cs1160313	471	1
cs5150102	471	1
cs5150280	471	1
cs5150282	471	1
cs5150284	471	1
cs5150292	471	1
cs5150295	471	1
cs5150296	471	1
ee1150080	471	1
ee1150432	471	1
ee1150443	471	1
ee1150446	471	1
ee1150450	471	1
ee1150452	471	1
ee1150457	471	1
ee1150463	471	1
ee1150466	471	1
ee1150470	471	1
ee1150472	471	1
ee1150473	471	1
ee1160418	471	1
ee1160421	471	1
ee1160423	471	1
ee1160424	471	1
ee1160459	471	1
ee1160481	471	1
ee3150501	471	1
ee3150502	471	1
ee3150514	471	1
ee3150515	471	1
ee3150526	471	1
ee3150530	471	1
me1150101	471	1
me1150668	471	1
me2150706	471	1
me2150718	471	1
me2150720	471	1
me2150724	471	1
me2150729	471	1
me2150756	471	1
me2170665	471	1
me2170676	471	1
me2170684	471	1
mt1150592	471	1
mt1150593	471	1
mt1150595	471	1
mt1150598	471	1
mt1150603	471	1
mt1150606	471	1
mt1150609	471	1
mt1150610	471	1
mt6150569	471	1
ph1150796	471	1
ph1150819	471	1
ph1170833	471	1
tt1150865	471	1
tt1150872	471	1
tt1150905	471	1
tt1150947	471	1
tt1150952	471	1
tt1160875	471	1
tt1160883	471	1
tt1160892	471	1
tt1160897	471	1
tt1160898	471	1
tt1160910	471	1
bb1150043	472	1
bb1150047	472	1
ce1150339	472	1
ch1150098	472	1
ch1150131	472	1
ch1160089	472	1
ch1160090	472	1
ch1160135	472	1
ch7140177	472	1
cs1150245	472	1
ee1150430	472	1
ee1150641	472	1
me1070528	472	1
me1160696	472	1
me1160697	472	1
me2150737	472	1
mt1150604	472	1
mt1160610	472	1
mt1160613	472	1
mt6140567	472	1
ph1150801	472	1
ph1150802	472	1
ph1150808	472	1
ph1150809	472	1
ph1150813	472	1
ph1160565	472	1
ph1160572	472	1
tt1140870	472	1
tt1150854	472	1
tt1160826	472	1
tt1160855	472	1
tt1160862	472	1
bb1160022	473	1
bb5160011	473	1
ch1150071	473	1
ch1150077	473	1
ch1150128	473	1
ch1160072	473	1
ch1160082	473	1
ch1160085	473	1
cs1150435	473	1
cs1160336	473	1
cs1160344	473	1
cs1160385	473	1
cs5150459	473	1
ee1160416	473	1
ee1160441	473	1
ee1160442	473	1
ee3150508	473	1
me1160674	473	1
me1160685	473	1
me1160692	473	1
me1160710	473	1
me1160719	473	1
me2160746	473	1
me2160759	473	1
me2160781	473	1
me2160795	473	1
me2160796	473	1
mt1150584	473	1
mt1160492	473	1
mt1160546	473	1
mt1160622	473	1
mt1160647	473	1
mt6150555	473	1
mt6160646	473	1
tt1150869	473	1
tt1150904	473	1
tt1150929	473	1
tt1160863	473	1
tt1160865	473	1
tt1160880	473	1
tt1160888	473	1
tt1160894	473	1
bb1150025	474	1
ce1150328	474	1
ce1150362	474	1
ce1160208	474	1
ce1160218	474	1
ce1160244	474	1
ce1160260	474	1
ce1160289	474	1
ch1160106	474	1
ch1160109	474	1
ch1160119	474	1
ch1160166	474	1
cs1160314	474	1
cs1160319	474	1
cs1160343	474	1
cs1160350	474	1
cs1160354	474	1
cs1160366	474	1
cs1160368	474	1
ee1150479	474	1
ee1160450	474	1
ee1160454	474	1
ee1160455	474	1
ee1160467	474	1
ee1160499	474	1
ee3160495	474	1
me1150685	474	1
me1160681	474	1
me1160686	474	1
me1160695	474	1
me2160757	474	1
me2160766	474	1
mt1160582	474	1
mt6130583	474	1
mt6150561	474	1
mt6160650	474	1
ph1160561	474	1
tt1150864	474	1
tt1160823	474	1
tt1160838	474	1
tt1160845	474	1
tt1160847	474	1
tt1160896	474	1
tt1160905	474	1
ce1150330	475	1
ce1150399	475	1
ce1150403	475	1
ch1150141	475	1
ch1150144	475	1
ch7150170	475	1
ch7150185	475	1
ch7160177	475	1
cs1150264	475	1
cs1150267	475	1
ee1150422	475	1
ee1150471	475	1
ee1150691	475	1
ee1150730	475	1
ee3150112	475	1
ee3150537	475	1
me1150108	475	1
me1150677	475	1
me1150686	475	1
me1150687	475	1
me1150688	475	1
me1150899	475	1
me2150742	475	1
me2150749	475	1
me2150764	475	1
me2150771	475	1
me2160782	475	1
mt1150586	475	1
mt1150614	475	1
mt1150725	475	1
mt1160616	475	1
mt6150562	475	1
ph1150815	475	1
tt1150881	475	1
tt1150894	475	1
tt1150925	475	1
bb1150056	476	1
bb5150014	476	1
bb5160004	476	1
ch1120088	476	1
ch1150002	476	1
ch1150140	476	1
ch7120189	476	1
ch7140170	476	1
ch7140198	476	1
cs1150221	476	1
cs1160340	476	1
cs5130286	476	1
cs5160084	476	1
ee1150454	476	1
ee1150481	476	1
me1130721	476	1
me1150630	476	1
me1150631	476	1
me1150678	476	1
me2140755	476	1
me2160810	476	1
mt1150592	476	1
mt1150611	476	1
mt6140571	476	1
mt6150564	476	1
ph1150836	476	1
tt1130982	476	1
tt1160916	476	1
ce1150304	477	1
ce1150305	477	1
ce1150351	477	1
ce1150360	477	1
ce1150364	477	1
ce1150368	477	1
cs1150215	477	1
cs1150223	477	1
cs1150224	477	1
ee3130546	477	1
me1150628	477	1
me1150632	477	1
me1150637	477	1
me1150689	477	1
me2140721	477	1
me2150766	477	1
mt6140556	477	1
mt6150551	477	1
mt6150559	477	1
ph1150788	477	1
ph1150797	477	1
tt1140115	477	1
tt1140185	477	1
tt1140228	477	1
tt1150866	477	1
tt1150868	477	1
tt1150878	477	1
tt1150882	477	1
tt1150887	477	1
tt1150919	477	1
tt1150928	477	1
tt1150931	477	1
tt1150934	477	1
tt1150944	477	1
tt1150954	477	1
bb5160010	478	1
bb5160015	478	1
ce1150306	478	1
ce1150395	478	1
ce1160248	478	1
ce1160249	478	1
ce1160251	478	1
ce1160253	478	1
ch1150093	478	1
cs1150245	478	1
cs1160338	478	1
cs1160342	478	1
cs1160345	478	1
cs1160347	478	1
cs1160680	478	1
cs5150279	478	1
cs5160400	478	1
ee1150114	478	1
ee1150426	478	1
ee1150444	478	1
ee1150448	478	1
ee1150468	478	1
ee1160040	478	1
ee1160545	478	1
ee3150121	478	1
me1110701	478	1
me1150390	478	1
me1150642	478	1
me1150692	478	1
me1160901	478	1
me2150728	478	1
me2150739	478	1
ph1150838	478	1
ph1160589	478	1
ph1160593	478	1
ph1160595	478	1
tt1150912	478	1
bb1150061	479	1
ce1150370	479	1
ce1150404	479	1
ce1160242	479	1
ce1160267	479	1
ce1160274	479	1
ce1160286	479	1
ch1150088	479	1
ch1150126	479	1
ch1160110	479	1
ch1160111	479	1
ch1160113	479	1
ch1160114	479	1
ch1160125	479	1
ch1160136	479	1
ch1160140	479	1
ch7140175	479	1
ch7160181	479	1
cs1150202	479	1
cs1150217	479	1
cs1160339	479	1
ee1150477	479	1
ee1150489	479	1
ee1160444	479	1
ee3160497	479	1
ee3160521	479	1
ee3160525	479	1
ee3160531	479	1
ee3160534	479	1
me1160702	479	1
me2130786	479	1
me2160798	479	1
mt6160649	479	1
ph1150807	479	1
ph1160547	479	1
tt1160904	479	1
bb5110029	480	1
ce1150307	480	1
ce1150329	480	1
ce1150331	480	1
ce1150336	480	1
ce1150356	480	1
ce1150387	480	1
ce1150388	480	1
ce1150389	480	1
ch1150072	480	1
ch7140155	480	1
cs5150288	480	1
ee1150429	480	1
ee1150431	480	1
ee1150436	480	1
ee1150449	480	1
ee1150478	480	1
ee1150482	480	1
ee1150485	480	1
ee1150486	480	1
ee1150491	480	1
ee3150535	480	1
me1150626	480	1
me2150728	480	1
me2150739	480	1
me2150746	480	1
me2150753	480	1
me2160760	480	1
mt1150591	480	1
mt1150602	480	1
mt1150612	480	1
mt1150613	480	1
mt5110600	480	1
ph1130827	480	1
ph1150789	480	1
ph1150841	480	1
ph1160562	480	1
tt1150863	480	1
tt1150883	480	1
tt1150888	480	1
tt1150939	480	1
bb1150040	481	1
bb5150005	481	1
ce1140243	481	1
ce1140315	481	1
ce1140345	481	1
ce1150325	481	1
ce1150345	481	1
ce1150352	481	1
ce1150394	481	1
ce1160225	481	1
ch1150079	481	1
ch1150097	481	1
ch1150119	481	1
ch1150129	481	1
ch1160124	481	1
cs5140291	481	1
cs5160387	481	1
ee1150434	481	1
ee1150464	481	1
ee1150483	481	1
ee1150487	481	1
ee1150781	481	1
ee3150538	481	1
me1150635	481	1
me1150657	481	1
me1150661	481	1
me1150679	481	1
me2150715	481	1
me2150745	481	1
me2150758	481	1
me2150759	481	1
me2150760	481	1
mt5100631	481	1
mt6140557	481	1
ph1150816	481	1
ph1160548	481	1
tt1140937	481	1
bb1150062	482	1
bb1160043	482	1
bb1160047	482	1
bb1160059	482	1
ch1150130	482	1
ch1150136	482	1
ch1150137	482	1
ch1150138	482	1
ch7140159	482	1
ch7140163	482	1
ch7150159	482	1
ch7150161	482	1
ch7150165	482	1
ch7160172	482	1
cs1150248	482	1
cs1150261	482	1
ee1150430	482	1
ee3150533	482	1
me1150633	482	1
me1150666	482	1
me1150681	482	1
me2150741	482	1
me2150770	482	1
mt1150581	482	1
mt5120616	482	1
mt6150565	482	1
ph1150811	482	1
ph1150813	482	1
ph1160540	482	1
ph1160552	482	1
tt1140887	482	1
tt1140896	482	1
tt1150886	482	1
ce1150308	483	1
ce1150312	483	1
ce1160216	483	1
ce1160222	483	1
ce1160228	483	1
ce1160285	483	1
ce1160288	483	1
ch1150085	483	1
ch1150095	483	1
ch1150096	483	1
ch1160346	483	1
ch7150161	483	1
ch7150186	483	1
cs1150207	483	1
cs1150212	483	1
cs1150253	483	1
ee1150425	483	1
ee1150451	483	1
ee1160451	483	1
ee3160501	483	1
ee3160533	483	1
me1150645	483	1
me1150672	483	1
me1160700	483	1
me2160783	483	1
mt1150182	483	1
mt6150561	483	1
mt6150568	483	1
ph1150784	483	1
ph1150787	483	1
ph1150800	483	1
ph1150839	483	1
ph1160583	483	1
ph1160586	483	1
tt1150873	483	1
bb1150028	484	1
bb1150051	484	1
bb1150065	484	1
ce1150314	484	1
ce1150327	484	1
ch7150154	484	1
ch7150160	484	1
ch7150162	484	1
cs1150203	484	1
cs1150204	484	1
cs1150206	484	1
cs1150209	484	1
cs1150237	484	1
cs1150257	484	1
cs1150266	484	1
cs1160377	484	1
ee1150462	484	1
ee1150492	484	1
ee1160461	484	1
ee3150509	484	1
ee3150750	484	1
me1150651	484	1
me1150660	484	1
me2150747	484	1
me2150752	484	1
me2150755	484	1
me2160770	484	1
mt1150583	484	1
mt1150608	484	1
mt1160636	484	1
ph1160564	484	1
tt1150859	484	1
tt1150861	484	1
tt1150935	484	1
tt1160841	484	1
tt1160919	484	1
bb1150024	485	1
bb1150037	485	1
bb1150042	485	1
ce1150376	485	1
ce1150392	485	1
ch1150074	485	1
ch1150076	485	1
ch1150107	485	1
ch1150127	485	1
ee1150438	485	1
ee3150513	485	1
ee3150521	485	1
ee3150539	485	1
ee3150540	485	1
ee3150542	485	1
ee3150543	485	1
ee3150544	485	1
ee3150649	485	1
me1150646	485	1
me1150650	485	1
me1150652	485	1
me1150653	485	1
me1150656	485	1
me1150658	485	1
me1150659	485	1
me1150693	485	1
me2150714	485	1
me2150763	485	1
mt1160626	485	1
mt1160631	485	1
ph1150790	485	1
ph1150792	485	1
tt1150896	485	1
tt1150903	485	1
tt1160827	485	1
bb1140062	486	1
ce1140381	486	1
ce1150317	486	1
ce1150321	486	1
ce1150322	486	1
ce1160291	486	1
ch1140145	486	1
ch1150083	486	1
ch1150139	486	1
ch1160116	486	1
ch1160117	486	1
ch7140164	486	1
ch7140190	486	1
ch7150169	486	1
ch7150179	486	1
ch7150184	486	1
ch7160192	486	1
cs1150263	486	1
ee1140426	486	1
ee1150423	486	1
ee3150518	486	1
ee3150524	486	1
ee3150525	486	1
ee3150529	486	1
ee3150531	486	1
ee3150532	486	1
ee3160769	486	1
me1130671	486	1
me1140656	486	1
me1150647	486	1
me1150664	486	1
me1150676	486	1
me2150716	486	1
mt1140581	486	1
mt1150601	486	1
tt1150941	486	1
bb1150030	487	1
bb1150038	487	1
ce1150332	487	1
ce1160292	487	1
ch1150086	487	1
ch1150104	487	1
ch7120152	487	1
ch7120168	487	1
ch7130162	487	1
cs1150219	487	1
cs1150460	487	1
cs1160523	487	1
cs1160701	487	1
ee1120464	487	1
ee1150428	487	1
ee1150474	487	1
ee1150504	487	1
ee1160107	487	1
ee3150517	487	1
me1150644	487	1
me2150717	487	1
me2160779	487	1
mt1140584	487	1
mt1150596	487	1
mt1160413	487	1
mt1160606	487	1
mt1160609	487	1
mt1160614	487	1
mt1160618	487	1
mt5120593	487	1
ph1150804	487	1
tt1150853	487	1
bb1150034	488	1
ce1150365	488	1
ce1150369	488	1
ce1160203	488	1
ce1160280	488	1
ce1160290	488	1
ce1160302	488	1
ch1150106	488	1
cs1150255	488	1
cs1150341	488	1
cs5130280	488	1
cs5150286	488	1
ee1150445	488	1
ee1150475	488	1
ee1160422	488	1
ee1160439	488	1
ee1160479	488	1
me1130654	488	1
me1140651	488	1
me1160708	488	1
me1160713	488	1
me1160721	488	1
me1160829	488	1
mt6150563	488	1
mt6150570	488	1
ph1110855	488	1
ph1150791	488	1
ph1150810	488	1
tt1120302	488	1
tt1130911	488	1
tt1150875	488	1
tt1150894	488	1
tt1150911	488	1
tt1150929	488	1
tt1150937	488	1
huz178661	489	1
huz188103	489	1
huz188104	489	1
ch1150091	490	1
ch1150115	490	1
ch7150195	490	1
ee3150526	490	1
huz178591	490	1
huz188108	490	1
huz188109	490	1
huz188110	490	1
huz188623	490	1
huz188628	490	1
me2150766	490	1
mt6160664	490	1
nrz188579	490	1
ph1130827	490	1
ph1130849	490	1
qiz188607	490	1
tt1150920	490	1
cs5130286	491	1
ee1150473	491	1
me2150724	491	1
ph1150809	491	1
tt1150884	491	1
vst189748	491	1
vst189750	491	1
bb5110029	492	1
ce1150378	492	1
huz188623	492	1
huz188624	492	1
nrz188579	492	1
phs177146	492	1
smz178441	492	1
smz188173	492	1
smz188530	492	1
smz188611	492	1
smz188612	492	1
huz188114	493	1
huz188619	493	1
huz188620	493	1
tt1160871	493	1
cs1160377	494	1
huz168532	494	1
huz188620	494	1
huz178661	495	1
huz188103	495	1
huz188104	495	1
bb1150062	496	1
bb5150015	496	1
ce1150325	496	1
ch1150089	496	1
ch1150098	496	1
ch1150116	496	1
ch1150125	496	1
ch1150136	496	1
ch1150137	496	1
ch1170257	496	1
cs1150235	496	1
cs1150253	496	1
ee1160160	496	1
een172628	496	1
me1150354	496	1
me1150634	496	1
me1150645	496	1
me1150655	496	1
me1150656	496	1
me1150658	496	1
me2140762	496	1
me2150739	496	1
me2150741	496	1
ph1150792	496	1
ph1150811	496	1
ph1150820	496	1
tt1150892	496	1
ttf172039	496	1
bb1150022	497	1
bb1150028	497	1
bb1150037	497	1
ce1130323	497	1
ce1150315	497	1
ce1150388	497	1
ch1150089	497	1
ch1150098	497	1
ch1150139	497	1
cs5140278	497	1
ee3150524	497	1
ee3150525	497	1
ee3150529	497	1
huz178150	497	1
huz178661	497	1
huz188103	497	1
huz188104	497	1
huz188108	497	1
huz188109	497	1
huz188110	497	1
huz188114	497	1
huz188623	497	1
me1130710	497	1
me1140656	497	1
me1150656	497	1
me1150685	497	1
me1150693	497	1
me2150732	497	1
me2150738	497	1
ph1150823	497	1
ph1150829	497	1
tt1130975	497	1
tt1150892	497	1
ttf172039	497	1
itz188549	498	1
jit182103	498	1
jit182104	498	1
jit182315	498	1
jit182316	498	1
jit182317	498	1
jit182318	498	1
jit182319	498	1
jit182320	498	1
jit182321	498	1
jit182322	498	1
jit182323	498	1
jit182325	498	1
jit182326	498	1
jit182327	498	1
mez188264	498	1
bmt172115	499	1
itz188549	499	1
jit172783	499	1
jit182315	499	1
jit182316	499	1
jit182317	499	1
jit182318	499	1
jit182319	499	1
jit182320	499	1
jit182321	499	1
jit182322	499	1
jit182323	499	1
jit182325	499	1
jit182326	499	1
jit182327	499	1
mee172787	499	1
mee172789	499	1
mee172790	499	1
mee182101	499	1
mez188264	499	1
mez188594	499	1
itz188548	500	1
jit182103	500	1
jit182104	500	1
jit182315	500	1
jit182316	500	1
jit182317	500	1
jit182318	500	1
jit182319	500	1
jit182320	500	1
jit182321	500	1
jit182322	500	1
jit182323	500	1
jit182325	500	1
jit182326	500	1
jit182327	500	1
itz188373	501	1
jit182103	501	1
jit182104	501	1
jit182315	501	1
jit182318	501	1
jit182320	501	1
jit182321	501	1
jit182326	501	1
jit182327	501	1
jit172122	502	1
jit172123	502	1
jit172127	502	1
jit172128	502	1
jit172129	502	1
jit172131	502	1
jit172134	502	1
jit172135	502	1
jit172663	502	1
jit172782	502	1
jit172783	502	1
jit172784	502	1
jop162446	503	1
jop172314	503	1
jop172623	503	1
jop172624	503	1
jop172625	503	1
jop172626	503	1
jop172843	503	1
jop172860	503	1
jop182037	504	1
jop182090	504	1
jop182091	504	1
jop182444	504	1
jop182445	504	1
jop182448	504	1
jop182449	504	1
jop182450	504	1
jop182451	504	1
jop182452	504	1
jop182453	504	1
jop182454	504	1
jop182710	504	1
jop182711	504	1
jop182712	504	1
jop182819	504	1
jop182841	504	1
jop182860	504	1
jop182866	504	1
jop182871	504	1
jop182877	504	1
jop182880	504	1
jpt172603	505	1
jpt172604	505	1
jpt172606	505	1
jpt172607	505	1
jpt172609	505	1
jpt172610	505	1
jpt172611	505	1
jpt172612	505	1
jpt172613	505	1
jpt172615	505	1
jpt172616	505	1
jpt172617	505	1
jpt172618	505	1
jpt172684	505	1
ch1150130	506	1
ch1160092	506	1
me1150639	506	1
me1150648	506	1
me1160690	506	1
me1160754	506	1
me2160773	506	1
jes172169	508	1
jes172170	508	1
jes172174	508	1
jes172181	508	1
jes172183	508	1
jes172629	508	1
jtm182002	509	1
jtm182003	509	1
jtm182004	509	1
jtm182243	509	1
jtm182244	509	1
jtm182245	509	1
jtm182246	509	1
jtm182247	509	1
jtm182248	509	1
jtm182249	509	1
jtm182250	509	1
jtm182251	509	1
jtm182772	509	1
jtm182774	509	1
jtm182775	509	1
jtm162084	510	1
jtm172019	510	1
jtm172021	510	1
jtm172022	510	1
jtm172023	510	1
jtm172187	510	1
jtm172767	510	1
jtm172768	510	1
jtm172769	510	1
jvl172509	512	1
jvl172502	513	1
jvl172503	513	1
jvl172504	513	1
jvl172505	513	1
jvl172507	513	1
jvl172508	513	1
jvl172570	513	1
mt5100631	514	1
mt5110585	514	1
ch7160169	515	1
me1150675	515	1
me1150680	515	1
me1160224	515	1
me1160670	515	1
me1160679	515	1
me1160684	515	1
me1160685	515	1
me1160687	515	1
me1160688	515	1
me2150733	515	1
me2150747	515	1
me2150754	515	1
me2150756	515	1
me2150758	515	1
me2150759	515	1
me2150764	515	1
me2150770	515	1
me2150771	515	1
me1120651	516	1
me1120739	516	1
me1130654	516	1
me1130727	516	1
me1150228	516	1
me1150627	516	1
me1150630	516	1
me1150631	516	1
me1150637	516	1
me1150639	516	1
me1150642	516	1
me1150654	516	1
me1150662	516	1
me1150668	516	1
me1150670	516	1
me1150678	516	1
me1150687	516	1
me1150690	516	1
me1150692	516	1
me2120768	516	1
me2150709	516	1
me2150711	516	1
me2150715	516	1
me2150716	516	1
me2150736	516	1
me2150748	516	1
me2150769	516	1
me2150773	516	1
me1130671	517	1
me1140651	517	1
me1150044	517	1
me1150101	517	1
me1150108	517	1
me1150110	517	1
me1150354	517	1
me1150383	517	1
me1150390	517	1
me1150396	517	1
me1150628	517	1
me1150633	517	1
me1150640	517	1
me1150646	517	1
me1150647	517	1
me1150648	517	1
me1150651	517	1
me1150652	517	1
me1150653	517	1
me1150655	517	1
me1150658	517	1
me1150659	517	1
me1150661	517	1
me1150663	517	1
me1150666	517	1
me1150672	517	1
me1150674	517	1
me1150675	517	1
me1150677	517	1
me1150686	517	1
me2120795	517	1
me2150708	517	1
me2150712	517	1
me2150713	517	1
me2150718	517	1
me2150720	517	1
me2150722	517	1
me2150724	517	1
me2150727	517	1
me2150728	517	1
me2150729	517	1
me2150731	517	1
me2150734	517	1
me2150738	517	1
me2150739	517	1
me2150743	517	1
me2150746	517	1
me2150758	517	1
me2150760	517	1
me2150763	517	1
me2150765	517	1
me2150766	517	1
me2150768	517	1
me2150770	517	1
met172274	518	1
met172277	518	1
met172527	518	1
met172571	518	1
met172808	518	1
met172809	518	1
met172810	518	1
met172811	518	1
met172812	518	1
met172813	518	1
met172814	518	1
met172815	518	1
met172817	518	1
met172819	518	1
met172821	518	1
met172822	518	1
met172825	518	1
met172830	518	1
me1130679	519	1
mem172478	519	1
mem172485	519	1
mem172488	519	1
mem172515	519	1
mem172526	519	1
mem172742	519	1
mem172746	519	1
mem172750	519	1
mem172798	519	1
mem172799	519	1
mem172804	519	1
mem172805	519	1
mem172806	519	1
mee172528	520	1
mee172766	520	1
mee172786	520	1
mee172787	520	1
mee172788	520	1
mee172853	520	1
mee172859	520	1
me2140755	521	1
mep172496	521	1
mep172498	521	1
mep172529	521	1
mep172791	521	1
mep172794	521	1
mep172795	521	1
mep172796	521	1
mey167534	522	1
mey167535	522	1
me1100745	523	1
me1130654	523	1
me1130698	523	1
me1140633	523	1
me1150643	523	1
me1160671	523	1
me1170021	523	1
me1170158	523	1
me1170561	523	1
me1170562	523	1
me1170564	523	1
me1170566	523	1
me1170567	523	1
me1170568	523	1
me1170569	523	1
me1170570	523	1
me1170571	523	1
me1170572	523	1
me1170573	523	1
me1170574	523	1
me1170575	523	1
me1170576	523	1
me1170578	523	1
me1170579	523	1
me1170580	523	1
me1170581	523	1
me1170582	523	1
me1170583	523	1
me1170585	523	1
me1170586	523	1
me1170587	523	1
me1170588	523	1
me1170590	523	1
me1170591	523	1
me1170592	523	1
me1170593	523	1
me1170594	523	1
me1170595	523	1
me1170596	523	1
me1170598	523	1
me1170600	523	1
me1170601	523	1
me1170603	523	1
me1170604	523	1
me1170605	523	1
me1170606	523	1
me1170607	523	1
me1170609	523	1
me1170610	523	1
me1170611	523	1
me1170612	523	1
me1170613	523	1
me1170614	523	1
me1170615	523	1
me1170616	523	1
me1170617	523	1
me1170618	523	1
me1170619	523	1
me1170621	523	1
me1170622	523	1
me1170623	523	1
me1170624	523	1
me1170625	523	1
me1170626	523	1
me1170627	523	1
me1170628	523	1
me1170651	523	1
me1170698	523	1
me1170702	523	1
me1170950	523	1
me1170960	523	1
ph1150803	523	1
me2120803	524	1
me2140721	524	1
me2140761	524	1
me2170641	524	1
me2170642	524	1
me2170643	524	1
me2170644	524	1
me2170645	524	1
me2170646	524	1
me2170647	524	1
me2170648	524	1
me2170649	524	1
me2170650	524	1
me2170652	524	1
me2170653	524	1
me2170655	524	1
me2170656	524	1
me2170657	524	1
me2170658	524	1
me2170660	524	1
me2170661	524	1
me2170662	524	1
me2170663	524	1
me2170664	524	1
me2170665	524	1
me2170666	524	1
me2170667	524	1
me2170668	524	1
me2170669	524	1
me2170670	524	1
me2170671	524	1
me2170672	524	1
me2170673	524	1
me2170674	524	1
me2170675	524	1
me2170676	524	1
me2170677	524	1
me2170678	524	1
me2170679	524	1
me2170680	524	1
me2170681	524	1
me2170683	524	1
me2170684	524	1
me2170685	524	1
me2170686	524	1
me2170687	524	1
me2170688	524	1
me2170689	524	1
me2170690	524	1
me2170691	524	1
me2170692	524	1
me2170693	524	1
me2170694	524	1
me2170695	524	1
me2170696	524	1
me2170697	524	1
me2170699	524	1
me2170700	524	1
me2170701	524	1
me2170703	524	1
me2170705	524	1
me2170706	524	1
me2170707	524	1
me2170842	524	1
me2120803	525	1
me2130786	525	1
me2140735	525	1
me2150749	525	1
me2150755	525	1
me2160752	525	1
me2160770	525	1
me2160787	525	1
me2160804	525	1
me2160808	525	1
me2170641	525	1
me2170642	525	1
me2170643	525	1
me2170644	525	1
me2170645	525	1
me2170646	525	1
me2170647	525	1
me2170648	525	1
me2170649	525	1
me2170650	525	1
me2170652	525	1
me2170653	525	1
me2170655	525	1
me2170656	525	1
me2170657	525	1
me2170658	525	1
me2170660	525	1
me2170661	525	1
me2170662	525	1
me2170663	525	1
me2170664	525	1
me2170665	525	1
me2170666	525	1
me2170667	525	1
me2170668	525	1
me2170669	525	1
me2170670	525	1
me2170671	525	1
me2170672	525	1
me2170673	525	1
me2170674	525	1
me2170675	525	1
me2170676	525	1
me2170677	525	1
me2170678	525	1
me2170679	525	1
me2170680	525	1
me2170681	525	1
me2170683	525	1
me2170684	525	1
me2170685	525	1
me2170686	525	1
me2170687	525	1
me2170688	525	1
me2170689	525	1
me2170690	525	1
me2170691	525	1
me2170692	525	1
me2170693	525	1
me2170694	525	1
me2170699	525	1
me2170700	525	1
me2170701	525	1
me2170703	525	1
me2170705	525	1
me2170707	525	1
me2170842	525	1
me2150711	526	1
me2150715	526	1
me2150720	526	1
me2150721	526	1
me2150736	526	1
me2150740	526	1
me2150751	526	1
me2150754	526	1
me2150772	526	1
me2160745	526	1
me2160746	526	1
me2160748	526	1
me2160749	526	1
me2160750	526	1
me2160752	526	1
me2160753	526	1
me2160755	526	1
me2160757	526	1
me2160759	526	1
me2160760	526	1
me2160761	526	1
me2160762	526	1
me2160763	526	1
me2160764	526	1
me2160765	526	1
me2160766	526	1
me2160767	526	1
me2160768	526	1
me2160770	526	1
me2160771	526	1
me2160772	526	1
me2160773	526	1
me2160774	526	1
me2160775	526	1
me2160776	526	1
me2160777	526	1
me2160778	526	1
me2160779	526	1
me2160780	526	1
me2160781	526	1
me2160782	526	1
me2160783	526	1
me2160784	526	1
me2160786	526	1
me2160787	526	1
me2160788	526	1
me2160790	526	1
me2160791	526	1
me2160792	526	1
me2160793	526	1
me2160794	526	1
me2160795	526	1
me2160796	526	1
me2160797	526	1
me2160798	526	1
me2160800	526	1
me2160801	526	1
me2160802	526	1
me2160803	526	1
me2160804	526	1
me2160806	526	1
me2160807	526	1
me2160808	526	1
me2160809	526	1
me2160810	526	1
me2160811	526	1
tt1170893	526	1
tt1170906	526	1
tt1170943	526	1
ee1120464	527	1
ee1140421	527	1
ee1150430	527	1
ee1150439	527	1
ee1150441	527	1
ee1150442	527	1
ee1150445	527	1
ee1150446	527	1
ee1150449	527	1
ee1150452	527	1
ee1150456	527	1
ee1150471	527	1
ee1150475	527	1
ee1150476	527	1
ee1150534	527	1
ee1150735	527	1
ee1160040	527	1
ee1160050	527	1
ee1160071	527	1
ee1160107	527	1
ee1160160	527	1
ee1160410	527	1
ee1160411	527	1
ee1160415	527	1
ee1160416	527	1
ee1160417	527	1
ee1160418	527	1
ee1160419	527	1
ee1160420	527	1
ee1160421	527	1
ee1160422	527	1
ee1160423	527	1
ee1160424	527	1
ee1160425	527	1
ee1160426	527	1
ee1160427	527	1
ee1160428	527	1
ee1160429	527	1
ee1160430	527	1
ee1160431	527	1
ee1160432	527	1
ee1160434	527	1
ee1160435	527	1
ee1160436	527	1
ee1160437	527	1
ee1160439	527	1
ee1160440	527	1
ee1160441	527	1
ee1160442	527	1
ee1160443	527	1
ee1160444	527	1
ee1160445	527	1
ee1160446	527	1
ee1160447	527	1
ee1160448	527	1
ee1160450	527	1
ee1160451	527	1
ee1160452	527	1
ee1160453	527	1
ee1160454	527	1
ee1160455	527	1
ee1160456	527	1
ee1160457	527	1
ee1160458	527	1
ee1160459	527	1
ee1160460	527	1
ee1160461	527	1
ee1160462	527	1
ee1160463	527	1
ee1160464	527	1
ee1160465	527	1
ee1160466	527	1
ee1160467	527	1
ee1160468	527	1
ee1160473	527	1
ee1160474	527	1
ee1160475	527	1
ee1160476	527	1
ee1160478	527	1
ee1160480	527	1
ee1160481	527	1
ee1160482	527	1
ee1160484	527	1
ee1160499	527	1
ee1160545	527	1
ee1160556	527	1
ee1160571	527	1
ee1160694	527	1
ee1160835	527	1
ee3130555	527	1
ee3140503	527	1
ee3150112	527	1
ee3150152	527	1
ee3150522	527	1
ee3150541	527	1
ee3150543	527	1
ee3150544	527	1
ee3160042	527	1
ee3160220	527	1
ee3160240	527	1
ee3160246	527	1
ee3160490	527	1
ee3160493	527	1
ee3160494	527	1
ee3160495	527	1
ee3160497	527	1
ee3160498	527	1
ee3160500	527	1
ee3160502	527	1
ee3160503	527	1
ee3160504	527	1
ee3160505	527	1
ee3160506	527	1
ee3160507	527	1
ee3160508	527	1
ee3160509	527	1
ee3160510	527	1
ee3160511	527	1
ee3160514	527	1
ee3160516	527	1
ee3160517	527	1
ee3160518	527	1
ee3160519	527	1
ee3160520	527	1
ee3160522	527	1
ee3160524	527	1
ee3160527	527	1
ee3160529	527	1
ee3160532	527	1
ee3160534	527	1
ee3160769	527	1
me1130698	528	1
me1150643	528	1
me1170021	528	1
me1170061	528	1
me1170158	528	1
me1170561	528	1
me1170562	528	1
me1170564	528	1
me1170566	528	1
me1170567	528	1
me1170568	528	1
me1170569	528	1
me1170570	528	1
me1170571	528	1
me1170572	528	1
me1170573	528	1
me1170574	528	1
me1170575	528	1
me1170576	528	1
me1170578	528	1
me1170579	528	1
me1170580	528	1
me1170581	528	1
me1170582	528	1
me1170583	528	1
me1170585	528	1
me1170586	528	1
me1170587	528	1
me1170588	528	1
me1170590	528	1
me1170591	528	1
me1170592	528	1
me1170593	528	1
me1170594	528	1
me1170595	528	1
me1170596	528	1
me1170598	528	1
me1170600	528	1
me1170601	528	1
me1170603	528	1
me1170604	528	1
me1170605	528	1
me1170606	528	1
me1170607	528	1
me1170609	528	1
me1170610	528	1
me1170611	528	1
me1170612	528	1
me1170613	528	1
me1170614	528	1
me1170615	528	1
me1170616	528	1
me1170617	528	1
me1170618	528	1
me1170619	528	1
me1170620	528	1
me1170621	528	1
me1170622	528	1
me1170623	528	1
me1170624	528	1
me1170625	528	1
me1170626	528	1
me1170627	528	1
me1170628	528	1
me1170651	528	1
me1170698	528	1
me1170702	528	1
me1170950	528	1
me1170960	528	1
me1170967	528	1
me2140759	528	1
me2160802	528	1
me2160804	528	1
me2170641	528	1
me2170642	528	1
me2170643	528	1
me2170644	528	1
me2170645	528	1
me2170646	528	1
me2170647	528	1
me2170648	528	1
me2170649	528	1
me2170650	528	1
me2170652	528	1
me2170653	528	1
me2170655	528	1
me2170656	528	1
me2170657	528	1
me2170658	528	1
me2170660	528	1
me2170661	528	1
me2170662	528	1
me2170663	528	1
me2170664	528	1
me2170665	528	1
me2170666	528	1
me2170667	528	1
me2170668	528	1
me2170669	528	1
me2170670	528	1
me2170671	528	1
me2170672	528	1
me2170673	528	1
me2170674	528	1
me2170675	528	1
me2170676	528	1
me2170677	528	1
me2170679	528	1
me2170680	528	1
me2170681	528	1
me2170683	528	1
me2170684	528	1
me2170685	528	1
me2170686	528	1
me2170687	528	1
me2170688	528	1
me2170689	528	1
me2170690	528	1
me2170691	528	1
me2170692	528	1
me2170693	528	1
me2170694	528	1
me2170695	528	1
me2170696	528	1
me2170697	528	1
me2170699	528	1
me2170700	528	1
me2170701	528	1
me2170703	528	1
me2170705	528	1
me2170706	528	1
me2170707	528	1
me2170842	528	1
cs1160340	529	1
me1100745	529	1
me1130671	529	1
me1130721	529	1
me1130729	529	1
me1140667	529	1
me1150228	529	1
me1150643	529	1
me1150662	529	1
me1150666	529	1
me1150673	529	1
me1160036	529	1
me1160073	529	1
me1160080	529	1
me1160224	529	1
me1160670	529	1
me1160671	529	1
me1160672	529	1
me1160673	529	1
me1160674	529	1
me1160676	529	1
me1160678	529	1
me1160679	529	1
me1160681	529	1
me1160682	529	1
me1160683	529	1
me1160684	529	1
me1160685	529	1
me1160686	529	1
me1160687	529	1
me1160688	529	1
me1160689	529	1
me1160690	529	1
me1160691	529	1
me1160692	529	1
me1160693	529	1
me1160695	529	1
me1160696	529	1
me1160697	529	1
me1160698	529	1
me1160699	529	1
me1160700	529	1
me1160702	529	1
me1160703	529	1
me1160704	529	1
me1160705	529	1
me1160706	529	1
me1160707	529	1
me1160708	529	1
me1160709	529	1
me1160710	529	1
me1160711	529	1
me1160712	529	1
me1160713	529	1
me1160714	529	1
me1160715	529	1
me1160716	529	1
me1160717	529	1
me1160718	529	1
me1160719	529	1
me1160720	529	1
me1160721	529	1
me1160722	529	1
me1160723	529	1
me1160724	529	1
me1160725	529	1
me1160726	529	1
me1160727	529	1
me1160728	529	1
me1160729	529	1
me1160730	529	1
me1160731	529	1
me1160732	529	1
me1160733	529	1
me1160734	529	1
me1160735	529	1
me1160736	529	1
me1160737	529	1
me1160747	529	1
me1160754	529	1
me1160758	529	1
me1160824	529	1
me1160829	529	1
me1160830	529	1
me1160901	529	1
me2120787	529	1
me2120795	529	1
me2120803	529	1
me2130786	529	1
me2140721	529	1
me2140772	529	1
me2150711	529	1
me2150715	529	1
me2150716	529	1
me2150722	529	1
me2150733	529	1
me2150740	529	1
me2150743	529	1
me2150745	529	1
me2150751	529	1
me2150754	529	1
me2150769	529	1
me2150772	529	1
me2160745	529	1
me2160746	529	1
me2160749	529	1
me2160755	529	1
me2160757	529	1
me2160759	529	1
me2160761	529	1
me2160762	529	1
me2160764	529	1
me2160765	529	1
me2160766	529	1
me2160767	529	1
me2160768	529	1
me2160770	529	1
me2160771	529	1
me2160773	529	1
me2160774	529	1
me2160775	529	1
me2160776	529	1
me2160777	529	1
me2160778	529	1
me2160779	529	1
me2160780	529	1
me2160781	529	1
me2160782	529	1
me2160783	529	1
me2160784	529	1
me2160786	529	1
me2160787	529	1
me2160788	529	1
me2160791	529	1
me2160792	529	1
me2160793	529	1
me2160794	529	1
me2160795	529	1
me2160796	529	1
me2160797	529	1
me2160798	529	1
me2160800	529	1
me2160801	529	1
me2160803	529	1
me2160806	529	1
me2160807	529	1
me2160808	529	1
me2160809	529	1
me2160810	529	1
me2160811	529	1
me2170652	529	1
tt1150860	529	1
me1130653	530	1
me1130654	530	1
me1130698	530	1
me1130710	530	1
me1140633	530	1
me1140651	530	1
me1150689	530	1
me1170021	530	1
me1170061	530	1
me1170158	530	1
me1170561	530	1
me1170562	530	1
me1170566	530	1
me1170567	530	1
me1170568	530	1
me1170569	530	1
me1170570	530	1
me1170571	530	1
me1170572	530	1
me1170573	530	1
me1170574	530	1
me1170575	530	1
me1170576	530	1
me1170578	530	1
me1170579	530	1
me1170580	530	1
me1170581	530	1
me1170582	530	1
me1170583	530	1
me1170585	530	1
me1170586	530	1
me1170587	530	1
me1170588	530	1
me1170590	530	1
me1170591	530	1
me1170592	530	1
me1170594	530	1
me1170595	530	1
me1170596	530	1
me1170598	530	1
me1170600	530	1
me1170601	530	1
me1170603	530	1
me1170604	530	1
me1170605	530	1
me1170606	530	1
me1170607	530	1
me1170609	530	1
me1170610	530	1
me1170611	530	1
me1170612	530	1
me1170613	530	1
me1170614	530	1
me1170615	530	1
me1170616	530	1
me1170617	530	1
me1170618	530	1
me1170619	530	1
me1170620	530	1
me1170621	530	1
me1170622	530	1
me1170623	530	1
me1170624	530	1
me1170625	530	1
me1170626	530	1
me1170627	530	1
me1170628	530	1
me1170651	530	1
me1170698	530	1
me1170702	530	1
me1170950	530	1
me1170960	530	1
me1170967	530	1
me1130654	531	1
me1130710	531	1
me1130727	531	1
me1130729	531	1
me1140685	531	1
me1150044	531	1
me1150108	531	1
me1150383	531	1
me1150686	531	1
me1160036	531	1
me1160073	531	1
me1160080	531	1
me1160224	531	1
me1160670	531	1
me1160671	531	1
me1160672	531	1
me1160673	531	1
me1160674	531	1
me1160676	531	1
me1160678	531	1
me1160679	531	1
me1160681	531	1
me1160682	531	1
me1160683	531	1
me1160684	531	1
me1160685	531	1
me1160686	531	1
me1160687	531	1
me1160688	531	1
me1160689	531	1
me1160690	531	1
me1160691	531	1
me1160692	531	1
me1160693	531	1
me1160695	531	1
me1160696	531	1
me1160697	531	1
me1160698	531	1
me1160699	531	1
me1160700	531	1
me1160702	531	1
me1160703	531	1
me1160704	531	1
me1160705	531	1
me1160706	531	1
me1160707	531	1
me1160708	531	1
me1160709	531	1
me1160710	531	1
me1160711	531	1
me1160712	531	1
me1160713	531	1
me1160714	531	1
me1160715	531	1
me1160716	531	1
me1160717	531	1
me1160718	531	1
me1160719	531	1
me1160720	531	1
me1160721	531	1
me1160722	531	1
me1160723	531	1
me1160724	531	1
me1160725	531	1
me1160726	531	1
me1160727	531	1
me1160729	531	1
me1160730	531	1
me1160731	531	1
me1160732	531	1
me1160733	531	1
me1160734	531	1
me1160735	531	1
me1160736	531	1
me1160737	531	1
me1160747	531	1
me1160754	531	1
me1160758	531	1
me1160824	531	1
me1160829	531	1
me1160830	531	1
me1160901	531	1
me2120803	531	1
me2140721	531	1
me2140735	531	1
me2150711	531	1
me2150736	531	1
me2150740	531	1
me2150751	531	1
me2150754	531	1
me2150769	531	1
me2160745	531	1
me2160746	531	1
me2160748	531	1
me2160749	531	1
me2160750	531	1
me2160752	531	1
me2160753	531	1
me2160755	531	1
me2160756	531	1
me2160757	531	1
me2160759	531	1
me2160760	531	1
me2160761	531	1
me2160762	531	1
me2160763	531	1
me2160764	531	1
me2160765	531	1
me2160766	531	1
me2160767	531	1
me2160768	531	1
me2160770	531	1
me2160771	531	1
me2160772	531	1
me2160773	531	1
me2160774	531	1
me2160775	531	1
me2160776	531	1
me2160777	531	1
me2160778	531	1
me2160779	531	1
me2160780	531	1
me2160781	531	1
me2160782	531	1
me2160783	531	1
me2160784	531	1
me2160786	531	1
me2160787	531	1
me2160788	531	1
me2160790	531	1
me2160791	531	1
me2160792	531	1
me2160793	531	1
me2160794	531	1
me2160795	531	1
me2160796	531	1
me2160797	531	1
me2160800	531	1
me2160801	531	1
me2160803	531	1
me2160806	531	1
me2160807	531	1
me2160808	531	1
me2160809	531	1
me2160810	531	1
me2160811	531	1
tt1150860	531	1
me1080519	532	1
me1110735	532	1
me1120651	532	1
me1130721	532	1
me1130727	532	1
me1140667	532	1
me1140685	532	1
me1150228	532	1
me1150628	532	1
me1150632	532	1
me1150647	532	1
me1150660	532	1
me1150665	532	1
me1160676	532	1
me1160688	532	1
me1160728	532	1
me2150708	532	1
me2150714	532	1
me2150715	532	1
me2150716	532	1
me2150721	532	1
me2150731	532	1
me2150736	532	1
me2150737	532	1
me2150738	532	1
me2150772	532	1
me2160779	532	1
me2160780	532	1
me2160801	532	1
me2160807	532	1
me2160809	532	1
me2160811	532	1
me1150639	533	1
me2120803	533	1
me2140721	533	1
me2140735	533	1
me2150711	533	1
me2150716	533	1
me2150736	533	1
me2150740	533	1
me2150746	533	1
me2150754	533	1
me2150764	533	1
me2150769	533	1
me2160745	533	1
me2160746	533	1
me2160755	533	1
me2160757	533	1
me2160759	533	1
me2160760	533	1
me2160761	533	1
me2160764	533	1
me2160765	533	1
me2160768	533	1
me2160770	533	1
me2160771	533	1
me2160772	533	1
me2160774	533	1
me2160775	533	1
me2160779	533	1
me2160780	533	1
me2160781	533	1
me2160782	533	1
me2160783	533	1
me2160784	533	1
me2160786	533	1
me2160788	533	1
me2160791	533	1
me2160792	533	1
me2160793	533	1
me2160794	533	1
me2160795	533	1
me2160796	533	1
me2160797	533	1
me2160798	533	1
me2160800	533	1
me2160801	533	1
me2160802	533	1
me2160803	533	1
me2160804	533	1
me2160806	533	1
me2160807	533	1
me2160808	533	1
me2160809	533	1
me2160810	533	1
me2160811	533	1
ph1150804	533	1
me1110735	534	1
me1120658	534	1
me1130698	534	1
me1130721	534	1
me1150354	534	1
me1150642	534	1
me1150644	534	1
me1150650	534	1
me1150652	534	1
me1150654	534	1
me1150660	534	1
me1150662	534	1
me1150668	534	1
me1150670	534	1
me1150673	534	1
me1150686	534	1
me1150692	534	1
me1150899	534	1
me1160681	534	1
me1160686	534	1
me1160722	534	1
me1160734	534	1
me1160735	534	1
me1160747	534	1
me2130786	534	1
me2150715	534	1
me2150755	534	1
me2150769	534	1
me2160791	534	1
me2170664	534	1
me2170681	534	1
me1100745	535	1
me1120651	535	1
me1120658	535	1
me1140685	535	1
me1150627	535	1
me1150637	535	1
me1150639	535	1
me1150642	535	1
me1150644	535	1
me1150647	535	1
me1150654	535	1
me1150662	535	1
me1150663	535	1
me1150664	535	1
me1150668	535	1
me1150670	535	1
me1150672	535	1
me1150674	535	1
me1150679	535	1
me1150685	535	1
me1150687	535	1
me1150692	535	1
me1160691	535	1
me1160700	535	1
me1160706	535	1
me1160710	535	1
me1160713	535	1
me1160719	535	1
me2130786	535	1
me2150707	535	1
me2150708	535	1
me2150717	535	1
me2150727	535	1
me2150731	535	1
me2150734	535	1
me2150769	535	1
me2150773	535	1
me1100745	536	1
me1110701	536	1
me1120658	536	1
me1130698	536	1
me1130729	536	1
me1140656	536	1
me1140685	536	1
me1150110	536	1
me1150390	536	1
me1150396	536	1
me1150647	536	1
me1150682	536	1
me1160036	536	1
me1160073	536	1
me1160080	536	1
me1160224	536	1
me1160670	536	1
me1160671	536	1
me1160672	536	1
me1160673	536	1
me1160674	536	1
me1160676	536	1
me1160679	536	1
me1160681	536	1
me1160682	536	1
me1160683	536	1
me1160684	536	1
me1160685	536	1
me1160686	536	1
me1160687	536	1
me1160688	536	1
me1160689	536	1
me1160690	536	1
me1160691	536	1
me1160692	536	1
me1160693	536	1
me1160695	536	1
me1160696	536	1
me1160697	536	1
me1160698	536	1
me1160699	536	1
me1160700	536	1
me1160702	536	1
me1160703	536	1
me1160704	536	1
me1160705	536	1
me1160706	536	1
me1160707	536	1
me1160708	536	1
me1160709	536	1
me1160710	536	1
me1160711	536	1
me1160712	536	1
me1160713	536	1
me1160714	536	1
me1160715	536	1
me1160716	536	1
me1160717	536	1
me1160718	536	1
me1160719	536	1
me1160720	536	1
me1160721	536	1
me1160722	536	1
me1160723	536	1
me1160724	536	1
me1160725	536	1
me1160726	536	1
me1160727	536	1
me1160729	536	1
me1160730	536	1
me1160731	536	1
me1160732	536	1
me1160733	536	1
me1160734	536	1
me1160735	536	1
me1160736	536	1
me1160737	536	1
me1160747	536	1
me1160754	536	1
me1160758	536	1
me1160824	536	1
me1160829	536	1
me1160830	536	1
me1160901	536	1
me2120795	536	1
me2120803	536	1
me2150711	536	1
me2150736	536	1
me2150740	536	1
me2150754	536	1
me2160745	536	1
me2160746	536	1
me2160748	536	1
me2160749	536	1
me2160750	536	1
me2160752	536	1
me2160753	536	1
me2160755	536	1
me2160756	536	1
me2160757	536	1
me2160759	536	1
me2160760	536	1
me2160761	536	1
me2160762	536	1
me2160763	536	1
me2160764	536	1
me2160765	536	1
me2160766	536	1
me2160767	536	1
me2160768	536	1
me2160770	536	1
me2160771	536	1
me2160772	536	1
me2160773	536	1
me2160774	536	1
me2160775	536	1
me2160776	536	1
me2160777	536	1
me2160778	536	1
me2160780	536	1
me2160781	536	1
me2160782	536	1
me2160783	536	1
me2160784	536	1
me2160786	536	1
me2160787	536	1
me2160788	536	1
me2160790	536	1
me2160792	536	1
me2160793	536	1
me2160794	536	1
me2160795	536	1
me2160796	536	1
me2160797	536	1
me2160800	536	1
me2160801	536	1
me2160803	536	1
me2160806	536	1
me2160807	536	1
me2160809	536	1
me2160810	536	1
me2160811	536	1
me1080528	537	1
me1110735	537	1
me1150657	537	1
me1150678	537	1
me1150690	537	1
me1160671	537	1
me1160679	537	1
me1160685	537	1
me1160728	537	1
me1160747	537	1
me1160758	537	1
me2150742	537	1
me1130727	538	1
me1130729	538	1
me1150651	538	1
me1150666	538	1
me1160709	538	1
me1160722	538	1
me2140772	538	1
me1140685	539	1
me1150627	539	1
me1150639	539	1
me1150645	539	1
me1150657	539	1
me1150659	539	1
me1150693	539	1
me2140761	539	1
me2150736	539	1
me2150773	539	1
chz172569	540	1
me1130710	540	1
me1140667	540	1
me1150682	540	1
me2140755	540	1
me2150709	540	1
me2150716	540	1
mep182102	540	1
mep182296	540	1
mep182329	540	1
mep182778	540	1
mep182780	540	1
mep182781	540	1
mep182782	540	1
mep182783	540	1
mep182784	540	1
mep182786	540	1
mep182787	540	1
mep182788	540	1
mep182789	540	1
mep182790	540	1
mep182791	540	1
mep182792	540	1
mep182793	540	1
met182099	540	1
met182100	540	1
met182122	540	1
met182273	540	1
met182274	540	1
met182275	540	1
met182278	540	1
met182285	540	1
met182290	540	1
met182291	540	1
met182794	540	1
met182795	540	1
met182797	540	1
met182798	540	1
met182799	540	1
met182800	540	1
met182802	540	1
met182803	540	1
met182804	540	1
met182805	540	1
met182806	540	1
met182807	540	1
met182856	540	1
met182857	540	1
met182859	540	1
met182869	540	1
mey187516	540	1
mey187517	540	1
mez188261	540	1
mez188596	540	1
me1130679	541	1
me1150675	541	1
me1150683	541	1
me1160678	541	1
me1170606	541	1
me2130786	541	1
me2150745	541	1
me2150753	541	1
me2150754	541	1
me2160767	541	1
mez188285	541	1
vst189728	541	1
me1150683	542	1
me1150688	542	1
me2150763	542	1
mem182253	542	1
mem182255	542	1
mem182257	542	1
mem182260	542	1
mem182268	542	1
mem182269	542	1
mem182270	542	1
mem182271	542	1
mem182314	542	1
mem182845	542	1
mem182846	542	1
mem182848	542	1
mem182850	542	1
mem182851	542	1
mem182853	542	1
mem187518	542	1
mey187541	542	1
mez188271	542	1
mez188595	542	1
mez188662	542	1
mez188668	542	1
jit172123	543	1
me1080519	543	1
me1120658	543	1
me1130679	543	1
me1150683	543	1
me1150688	543	1
me1150689	543	1
me2150721	543	1
mem182253	543	1
mem182255	543	1
mem182257	543	1
mem182260	543	1
mem182263	543	1
mem182264	543	1
mem182268	543	1
mem182269	543	1
mem182270	543	1
mem182271	543	1
mem182314	543	1
mem182843	543	1
mem182845	543	1
mem182846	543	1
mem182848	543	1
mem182849	543	1
mem182850	543	1
mem182851	543	1
mem182853	543	1
mem182854	543	1
mem187518	543	1
mez188286	543	1
me1150689	544	1
me1160673	544	1
me1160717	544	1
mem182253	544	1
mem182257	544	1
mem182260	544	1
mem182263	544	1
mem182268	544	1
mem182269	544	1
mem182270	544	1
mem182314	544	1
mem182848	544	1
mem182851	544	1
mem187518	544	1
mey187541	544	1
ama172319	545	1
ama172329	545	1
ama172336	545	1
me1130679	545	1
me1150683	545	1
mem182264	545	1
mem182271	545	1
mem182843	545	1
mem182846	545	1
mem182849	545	1
mem182853	545	1
mez188265	545	1
mez188285	545	1
mez188288	545	1
mez188581	545	1
ama182740	546	1
ama182771	546	1
ama182872	546	1
me1120658	546	1
mem182255	546	1
mem182263	546	1
mem182264	546	1
mem182843	546	1
mem182849	546	1
mem182853	546	1
mem182854	546	1
mez188288	546	1
mez188581	546	1
me1150627	547	1
me1150637	547	1
me1150648	547	1
me1150650	547	1
me1150652	547	1
me1150658	547	1
me1150662	547	1
me1150664	547	1
me1150668	547	1
me1150670	547	1
me1150673	547	1
me1150678	547	1
me1150681	547	1
me1150684	547	1
me1150687	547	1
me1150690	547	1
me1150692	547	1
me1150693	547	1
me1160693	547	1
me2140761	547	1
me2150742	547	1
me2150773	547	1
mem182253	547	1
mem182270	547	1
mem182850	547	1
mem182851	547	1
ch1150130	548	1
me1150660	548	1
me1150683	548	1
me1150688	548	1
me1160699	548	1
me1160703	548	1
me1160711	548	1
me2150709	548	1
mem182264	548	1
mem182271	548	1
mem182843	548	1
mem182845	548	1
mem182846	548	1
mem182849	548	1
mem182850	548	1
mem182854	548	1
mez188265	548	1
mez188285	548	1
mez188288	548	1
mez188591	548	1
mez188662	548	1
me1120658	549	1
me1150666	549	1
me1150688	549	1
me1160711	549	1
me2140759	549	1
me2150754	549	1
mem172526	549	1
mem182255	549	1
mem182257	549	1
mem182260	549	1
mem182263	549	1
mem182268	549	1
mem182314	549	1
mem182845	549	1
mem182848	549	1
mem182854	549	1
mem187518	549	1
mez188271	549	1
mez188591	549	1
mez188662	549	1
cec172577	550	1
cec172579	550	1
cec172582	550	1
cec172583	550	1
cec172585	550	1
cec172588	550	1
cec172589	550	1
cec172593	550	1
cec172595	550	1
mee182101	550	1
mee182809	550	1
mee182810	550	1
mee182811	550	1
mee182812	550	1
mee182813	550	1
mee182816	550	1
mez188267	550	1
mez188287	550	1
mez188594	550	1
cs1150214	551	1
cs1150223	551	1
ee5110563	551	1
me1080519	551	1
me1100745	551	1
me1130710	551	1
me1140656	551	1
me1150228	551	1
me1150628	551	1
me1150645	551	1
me1150662	551	1
me1150664	551	1
me1150673	551	1
me1150686	551	1
me1160747	551	1
me2120768	551	1
me2120803	551	1
me2150707	551	1
me2150710	551	1
me2150712	551	1
me2150713	551	1
me2150715	551	1
me2150719	551	1
me2150727	551	1
me2150733	551	1
me2150737	551	1
me2150745	551	1
me2150747	551	1
me2150748	551	1
me2150749	551	1
me2150752	551	1
me2150756	551	1
me2150758	551	1
me2150759	551	1
me2150764	551	1
me2150770	551	1
me2150771	551	1
me2150773	551	1
mee172528	551	1
mee172766	551	1
mee172788	551	1
mee172789	551	1
mee172790	551	1
mee172853	551	1
met172808	551	1
met172821	551	1
mez177523	551	1
tt1150869	551	1
tt1150875	551	1
tt1150929	551	1
tt1150954	551	1
mee182101	552	1
mee182809	552	1
mee182810	552	1
mee182811	552	1
mee182812	552	1
mee182813	552	1
mee182816	552	1
mez188267	552	1
mez188287	552	1
mez188594	552	1
me1150669	553	1
me2120787	553	1
me2140759	553	1
me2150706	553	1
me2150710	553	1
me2150712	553	1
me2150713	553	1
me2150719	553	1
me2150732	553	1
me2150741	553	1
me2150745	553	1
me2150747	553	1
me2150748	553	1
me2150749	553	1
me2150755	553	1
me2150756	553	1
me2150759	553	1
me2150760	553	1
me2150764	553	1
me2150765	553	1
me2150766	553	1
me2150768	553	1
me2150770	553	1
me2150771	553	1
mee172859	553	1
mee182101	553	1
mee182809	553	1
mee182810	553	1
mee182811	553	1
mee182812	553	1
mee182813	553	1
mee182816	553	1
cec182680	554	1
cec182694	554	1
cec182695	554	1
cec182709	554	1
me2140755	554	1
me2150734	554	1
me2150743	554	1
mep172496	554	1
mep182296	554	1
mep182783	554	1
mep182786	554	1
mep182788	554	1
mep182793	554	1
mez188582	554	1
mez188592	554	1
jid182459	555	1
jid182463	555	1
jid182465	555	1
jid182467	555	1
me1150644	555	1
me1150669	555	1
me1150681	555	1
me1150692	555	1
me2150717	555	1
mep172529	555	1
mep182102	555	1
mep182296	555	1
mep182329	555	1
mep182778	555	1
mep182780	555	1
mep182781	555	1
mep182782	555	1
mep182783	555	1
mep182784	555	1
mep182786	555	1
mep182787	555	1
mep182788	555	1
mep182789	555	1
mep182790	555	1
mep182791	555	1
mep182792	555	1
mep182793	555	1
mez188582	555	1
mez188587	555	1
mez188588	555	1
mez188592	555	1
mez188599	555	1
mez188600	555	1
vst189738	555	1
vst189742	555	1
vst189743	555	1
vst189747	555	1
bmt182313	556	1
jid182461	556	1
jid182470	556	1
me2150748	556	1
mep182102	556	1
mep182296	556	1
mep182329	556	1
mep182778	556	1
mep182780	556	1
mep182781	556	1
mep182782	556	1
mep182783	556	1
mep182784	556	1
mep182786	556	1
mep182787	556	1
mep182788	556	1
mep182789	556	1
mep182790	556	1
mep182791	556	1
mep182792	556	1
mep182793	556	1
mez188272	556	1
mez188284	556	1
mez188589	556	1
mez188590	556	1
mep182102	557	1
mep182296	557	1
mep182329	557	1
mep182778	557	1
mep182780	557	1
mep182781	557	1
mep182782	557	1
mep182783	557	1
mep182784	557	1
mep182786	557	1
mep182787	557	1
mep182788	557	1
mep182789	557	1
mep182790	557	1
mep182791	557	1
mep182792	557	1
mep182793	557	1
mez188266	557	1
mez188272	557	1
mez188273	557	1
me1150682	558	1
me2150709	558	1
met182273	558	1
met182274	558	1
met182275	558	1
met182278	558	1
met182285	558	1
met182290	558	1
met182794	558	1
met182795	558	1
met182797	558	1
met182798	558	1
met182799	558	1
met182800	558	1
met182803	558	1
met182804	558	1
met182806	558	1
met182807	558	1
met182857	558	1
met182859	558	1
met182869	558	1
mey187516	558	1
mey187543	558	1
mez188262	558	1
mez188263	558	1
mez188583	558	1
mez188596	558	1
ama182735	559	1
esz188513	559	1
me1110701	559	1
me1150101	559	1
me1150108	559	1
me1150354	559	1
me1150899	559	1
me1160679	559	1
me1160685	559	1
me2110775	559	1
me2120795	559	1
me2150733	559	1
met182099	559	1
met182100	559	1
met182122	559	1
met182291	559	1
met182794	559	1
met182799	559	1
met182800	559	1
met182802	559	1
met182803	559	1
met182805	559	1
met182807	559	1
met182856	559	1
met182859	559	1
met182869	559	1
mey187516	559	1
mey187517	559	1
mey187543	559	1
mez188262	559	1
mez188583	559	1
mez188585	559	1
mez188586	559	1
mez188597	559	1
me2140759	560	1
met182798	560	1
met182800	560	1
met182803	560	1
met182807	560	1
mez188586	560	1
met182273	561	1
met182291	561	1
met182802	561	1
mez168545	561	1
mez178597	561	1
mez188270	561	1
mez188585	561	1
mez188597	561	1
met182291	562	1
mez178428	562	1
cez188407	563	1
me1150682	563	1
met182100	563	1
met182122	563	1
met182274	563	1
met182275	563	1
met182278	563	1
met182290	563	1
met182794	563	1
met182795	563	1
met182805	563	1
met182857	563	1
me2110775	564	1
met182099	564	1
met182100	564	1
met182122	564	1
met182273	564	1
met182274	564	1
met182275	564	1
met182285	564	1
met182290	564	1
met182797	564	1
met182798	564	1
met182799	564	1
met182802	564	1
met182804	564	1
met182805	564	1
met182806	564	1
met182856	564	1
met182857	564	1
met182859	564	1
met182869	564	1
mez188585	564	1
mez188597	564	1
eez188137	565	1
me1150110	565	1
me1150354	565	1
me1150682	565	1
me1160693	565	1
met182099	565	1
met182278	565	1
met182797	565	1
mey187543	565	1
mez188261	565	1
mez188263	565	1
eez188143	566	1
me1150101	566	1
me1150383	566	1
me1150390	566	1
me1160073	566	1
me1160224	566	1
me1160672	566	1
me1160674	566	1
me1160689	566	1
me1160692	566	1
me1160695	566	1
me1160696	566	1
me1160698	566	1
me1160699	566	1
me1160703	566	1
me1160718	566	1
me1160829	566	1
me1160830	566	1
me1160901	566	1
me2150732	566	1
me2150741	566	1
me2150759	566	1
me2150764	566	1
me2150771	566	1
me2160748	566	1
me2160753	566	1
me2160759	566	1
me2160760	566	1
me2160770	566	1
me2160772	566	1
me2160790	566	1
me2160794	566	1
me2160796	566	1
mee172786	566	1
mee172789	566	1
mee172790	566	1
mee182809	566	1
mee182810	566	1
mee182811	566	1
mee182812	566	1
mee182813	566	1
mee182816	566	1
mez188287	566	1
bb1140024	567	1
bb1170036	567	1
bb1180003	567	1
bb1180007	567	1
bb1180009	567	1
bb1180010	567	1
bb1180011	567	1
bb1180013	567	1
bb1180014	567	1
bb1180015	567	1
bb1180018	567	1
bb1180022	567	1
bb1180026	567	1
bb1180027	567	1
bb1180028	567	1
bb1180033	567	1
bb1180040	567	1
bb1180043	567	1
bb5180055	567	1
bb5180059	567	1
bb5180061	567	1
bb5180065	567	1
ce1130384	567	1
ce1130386	567	1
ce1150345	567	1
ce1150356	567	1
ce1150398	567	1
ce1180071	567	1
ce1180072	567	1
ce1180073	567	1
ce1180075	567	1
ce1180077	567	1
ce1180080	567	1
ce1180081	567	1
ce1180082	567	1
ce1180087	567	1
ce1180088	567	1
ce1180089	567	1
ce1180091	567	1
ce1180092	567	1
ce1180093	567	1
ce1180096	567	1
ce1180097	567	1
ce1180098	567	1
ce1180099	567	1
ce1180100	567	1
ce1180102	567	1
ce1180103	567	1
ce1180105	567	1
ce1180107	567	1
ce1180109	567	1
ce1180111	567	1
ce1180113	567	1
ce1180114	567	1
ce1180115	567	1
ce1180116	567	1
ce1180119	567	1
ce1180121	567	1
ce1180122	567	1
ce1180123	567	1
ce1180125	567	1
ce1180126	567	1
ce1180127	567	1
ce1180128	567	1
ce1180129	567	1
ce1180130	567	1
ce1180131	567	1
ce1180134	567	1
ce1180135	567	1
ce1180137	567	1
ce1180138	567	1
ce1180139	567	1
ce1180140	567	1
ce1180142	567	1
ce1180143	567	1
ce1180144	567	1
ce1180145	567	1
ce1180147	567	1
ce1180152	567	1
ce1180153	567	1
ce1180155	567	1
ce1180156	567	1
ce1180159	567	1
ce1180160	567	1
ce1180161	567	1
ce1180162	567	1
ce1180166	567	1
ce1180170	567	1
ce1180171	567	1
ce1180172	567	1
ce1180173	567	1
ce1180174	567	1
ce1180175	567	1
ce1180176	567	1
ch1170230	567	1
ch1180186	567	1
ch1180188	567	1
ch1180190	567	1
ch1180192	567	1
ch1180196	567	1
ch1180198	567	1
ch1180204	567	1
ch1180206	567	1
ch1180207	567	1
ch1180209	567	1
ch1180217	567	1
ch1180219	567	1
ch1180222	567	1
ch1180223	567	1
ch1180224	567	1
ch1180226	567	1
ch1180228	567	1
ch1180231	567	1
ch1180232	567	1
ch1180233	567	1
ch1180235	567	1
ch1180236	567	1
ch1180237	567	1
ch1180238	567	1
ch1180241	567	1
ch1180243	567	1
ch1180244	567	1
ch1180245	567	1
ch1180246	567	1
ch1180256	567	1
ch1180258	567	1
ch7140183	567	1
ch7170315	567	1
ch7180273	567	1
ch7180274	567	1
ch7180275	567	1
ch7180276	567	1
ch7180283	567	1
ch7180284	567	1
ch7180289	567	1
ch7180291	567	1
ch7180294	567	1
ch7180298	567	1
ch7180300	567	1
ch7180303	567	1
ch7180307	567	1
ch7180308	567	1
ch7180309	567	1
ch7180310	567	1
ch7180312	567	1
ch7180313	567	1
ch7180314	567	1
ch7180316	567	1
cs1180321	567	1
cs1180324	567	1
cs1180325	567	1
cs1180326	567	1
cs1180328	567	1
cs1180329	567	1
cs1180331	567	1
cs1180333	567	1
cs1180336	567	1
cs1180337	567	1
cs1180338	567	1
cs1180339	567	1
cs1180341	567	1
cs1180342	567	1
cs1180343	567	1
cs1180347	567	1
cs1180349	567	1
cs1180352	567	1
cs1180353	567	1
cs1180354	567	1
cs1180356	567	1
cs1180357	567	1
cs1180358	567	1
cs1180359	567	1
cs1180361	567	1
cs1180363	567	1
cs1180364	567	1
cs1180365	567	1
cs1180367	567	1
cs1180368	567	1
cs1180369	567	1
cs1180371	567	1
cs1180375	567	1
cs1180376	567	1
cs1180378	567	1
cs1180379	567	1
cs1180382	567	1
cs1180383	567	1
cs1180384	567	1
cs1180387	567	1
cs1180388	567	1
cs1180391	567	1
cs1180396	567	1
cs5180406	567	1
cs5180407	567	1
cs5180410	567	1
cs5180411	567	1
cs5180414	567	1
cs5180415	567	1
cs5180416	567	1
cs5180417	567	1
cs5180418	567	1
cs5180421	567	1
cs5180423	567	1
cs5180424	567	1
ee1140437	567	1
ee1180431	567	1
ee1180432	567	1
ee1180435	567	1
ee1180438	567	1
ee1180440	567	1
ee1180442	567	1
ee1180445	567	1
ee1180448	567	1
ee1180449	567	1
ee1180450	567	1
ee1180451	567	1
ee1180453	567	1
ee1180455	567	1
ee1180457	567	1
ee1180461	567	1
ee1180462	567	1
ee1180463	567	1
ee1180464	567	1
ee1180465	567	1
ee1180466	567	1
ee1180471	567	1
ee1180472	567	1
ee1180474	567	1
ee1180475	567	1
ee1180477	567	1
ee1180478	567	1
ee1180479	567	1
ee1180480	567	1
ee1180481	567	1
ee1180484	567	1
ee1180487	567	1
ee1180488	567	1
ee1180490	567	1
ee1180493	567	1
ee1180494	567	1
ee1180495	567	1
ee1180498	567	1
ee1180499	567	1
ee1180500	567	1
ee1180501	567	1
ee1180502	567	1
ee1180503	567	1
ee1180507	567	1
ee1180508	567	1
ee1180510	567	1
ee1180512	567	1
ee1180513	567	1
ee1180514	567	1
ee1180515	567	1
ee3160509	567	1
ee3180522	567	1
ee3180526	567	1
ee3180529	567	1
ee3180532	567	1
ee3180534	567	1
ee3180536	567	1
ee3180537	567	1
ee3180538	567	1
ee3180539	567	1
ee3180540	567	1
ee3180543	567	1
ee3180544	567	1
ee3180548	567	1
ee3180550	567	1
ee3180551	567	1
ee3180552	567	1
ee3180555	567	1
ee3180558	567	1
ee3180559	567	1
ee3180561	567	1
ee3180564	567	1
ee3180566	567	1
ee3180567	567	1
ee3180568	567	1
me1180583	567	1
me1180585	567	1
me1180586	567	1
me1180587	567	1
me1180591	567	1
me1180593	567	1
me1180594	567	1
me1180595	567	1
me1180596	567	1
me1180598	567	1
me1180601	567	1
me1180602	567	1
me1180605	567	1
me1180607	567	1
me1180609	567	1
me1180610	567	1
me1180613	567	1
me1180617	567	1
me1180618	567	1
me1180619	567	1
me1180620	567	1
me1180621	567	1
me1180623	567	1
me1180625	567	1
me1180629	567	1
me1180632	567	1
me1180635	567	1
me1180636	567	1
me1180637	567	1
me1180638	567	1
me1180639	567	1
me1180640	567	1
me1180642	567	1
me1180643	567	1
me1180646	567	1
me1180647	567	1
me1180648	567	1
me1180649	567	1
me1180652	567	1
me1180653	567	1
me1180655	567	1
me1180657	567	1
me2170659	567	1
me2170705	567	1
me2180665	567	1
me2180667	567	1
me2180669	567	1
me2180671	567	1
me2180673	567	1
me2180677	567	1
me2180680	567	1
me2180684	567	1
me2180685	567	1
me2180686	567	1
me2180689	567	1
me2180693	567	1
me2180697	567	1
me2180702	567	1
me2180704	567	1
me2180705	567	1
me2180708	567	1
me2180710	567	1
me2180711	567	1
me2180714	567	1
me2180720	567	1
me2180721	567	1
me2180724	567	1
me2180727	567	1
me2180729	567	1
me2180731	567	1
me2180734	567	1
me2180735	567	1
mt1160639	567	1
mt1170725	567	1
mt1180736	567	1
mt1180737	567	1
mt1180740	567	1
mt1180741	567	1
mt1180743	567	1
mt1180745	567	1
mt1180747	567	1
mt1180749	567	1
mt1180750	567	1
mt1180751	567	1
mt1180752	567	1
mt1180753	567	1
mt1180754	567	1
mt1180756	567	1
mt1180759	567	1
mt1180761	567	1
mt1180763	567	1
mt1180764	567	1
mt1180765	567	1
mt1180766	567	1
mt1180767	567	1
mt1180768	567	1
mt1180769	567	1
mt1180771	567	1
mt1180772	567	1
mt1180773	567	1
mt1180774	567	1
mt6130583	567	1
mt6180776	567	1
mt6180778	567	1
mt6180779	567	1
mt6180780	567	1
mt6180781	567	1
mt6180782	567	1
mt6180784	567	1
mt6180786	567	1
mt6180787	567	1
mt6180788	567	1
mt6180789	567	1
mt6180791	567	1
mt6180792	567	1
mt6180796	567	1
mt6180798	567	1
ph1120826	567	1
ph1150788	567	1
ph1180804	567	1
ph1180805	567	1
ph1180806	567	1
ph1180808	567	1
ph1180809	567	1
ph1180811	567	1
ph1180815	567	1
ph1180816	567	1
ph1180818	567	1
ph1180819	567	1
ph1180823	567	1
ph1180824	567	1
ph1180829	567	1
ph1180834	567	1
ph1180835	567	1
ph1180837	567	1
ph1180840	567	1
ph1180841	567	1
ph1180842	567	1
ph1180847	567	1
ph1180849	567	1
ph1180853	567	1
ph1180855	567	1
ph1180856	567	1
ph1180857	567	1
tt1140887	567	1
tt1150858	567	1
tt1150941	567	1
tt1180867	567	1
tt1180868	567	1
tt1180869	567	1
tt1180871	567	1
tt1180873	567	1
tt1180878	567	1
tt1180880	567	1
tt1180883	567	1
tt1180884	567	1
tt1180885	567	1
tt1180886	567	1
tt1180895	567	1
tt1180898	567	1
tt1180899	567	1
tt1180904	567	1
tt1180907	567	1
tt1180908	567	1
tt1180909	567	1
tt1180913	567	1
tt1180914	567	1
tt1180916	567	1
tt1180917	567	1
tt1180918	567	1
tt1180919	567	1
tt1180924	567	1
tt1180926	567	1
tt1180929	567	1
tt1180931	567	1
tt1180935	567	1
tt1180937	567	1
tt1180938	567	1
tt1180941	567	1
tt1180942	567	1
tt1180943	567	1
tt1180944	567	1
tt1180945	567	1
tt1180948	567	1
tt1180949	567	1
tt1180953	567	1
tt1180957	567	1
tt1180958	567	1
tt1180959	567	1
tt1180961	567	1
tt1180966	567	1
tt1180970	567	1
tt1180971	567	1
tt1180972	567	1
tt1180974	567	1
bb1170036	568	1
bb1180003	568	1
bb1180007	568	1
bb1180009	568	1
bb1180010	568	1
bb1180011	568	1
bb1180013	568	1
bb1180014	568	1
bb1180015	568	1
bb1180018	568	1
bb1180022	568	1
bb1180026	568	1
bb1180027	568	1
bb1180028	568	1
bb1180033	568	1
bb1180040	568	1
bb1180043	568	1
bb5180055	568	1
bb5180059	568	1
bb5180061	568	1
bb5180065	568	1
ce1180071	568	1
ce1180072	568	1
ce1180073	568	1
ce1180075	568	1
ce1180077	568	1
ce1180080	568	1
ce1180081	568	1
ce1180082	568	1
ce1180087	568	1
ce1180088	568	1
ce1180089	568	1
ce1180091	568	1
ce1180092	568	1
ce1180093	568	1
ce1180096	568	1
ce1180097	568	1
ce1180098	568	1
ce1180099	568	1
ce1180100	568	1
ce1180102	568	1
ce1180103	568	1
ce1180105	568	1
ce1180107	568	1
ce1180109	568	1
ce1180111	568	1
ce1180113	568	1
ce1180114	568	1
ce1180115	568	1
ce1180116	568	1
ce1180119	568	1
ce1180121	568	1
ce1180122	568	1
ce1180123	568	1
ce1180125	568	1
ce1180126	568	1
ce1180127	568	1
ce1180128	568	1
ce1180129	568	1
ce1180130	568	1
ce1180131	568	1
ce1180134	568	1
ce1180135	568	1
ce1180137	568	1
ce1180138	568	1
ce1180139	568	1
ce1180140	568	1
ce1180142	568	1
ce1180143	568	1
ce1180144	568	1
ce1180145	568	1
ce1180147	568	1
ce1180152	568	1
ce1180153	568	1
ce1180155	568	1
ce1180156	568	1
ce1180159	568	1
ce1180160	568	1
ce1180161	568	1
ce1180162	568	1
ce1180166	568	1
ce1180170	568	1
ce1180171	568	1
ce1180172	568	1
ce1180173	568	1
ce1180174	568	1
ce1180175	568	1
ce1180176	568	1
ch1170230	568	1
ch1180186	568	1
ch1180188	568	1
ch1180190	568	1
ch1180192	568	1
ch1180196	568	1
ch1180198	568	1
ch1180204	568	1
ch1180206	568	1
ch1180207	568	1
ch1180209	568	1
ch1180217	568	1
ch1180219	568	1
ch1180222	568	1
ch1180223	568	1
ch1180224	568	1
ch1180226	568	1
ch1180228	568	1
ch1180231	568	1
ch1180232	568	1
ch1180233	568	1
ch1180235	568	1
ch1180236	568	1
ch1180237	568	1
ch1180238	568	1
ch1180241	568	1
ch1180243	568	1
ch1180244	568	1
ch1180245	568	1
ch1180246	568	1
ch1180256	568	1
ch1180258	568	1
ch7170315	568	1
ch7180273	568	1
ch7180274	568	1
ch7180275	568	1
ch7180276	568	1
ch7180283	568	1
ch7180284	568	1
ch7180289	568	1
ch7180291	568	1
ch7180294	568	1
ch7180298	568	1
ch7180300	568	1
ch7180303	568	1
ch7180307	568	1
ch7180308	568	1
ch7180309	568	1
ch7180310	568	1
ch7180312	568	1
ch7180313	568	1
ch7180314	568	1
ch7180316	568	1
cs1180321	568	1
cs1180324	568	1
cs1180325	568	1
cs1180326	568	1
cs1180328	568	1
cs1180329	568	1
cs1180331	568	1
cs1180333	568	1
cs1180336	568	1
cs1180337	568	1
cs1180338	568	1
cs1180339	568	1
cs1180341	568	1
cs1180342	568	1
cs1180343	568	1
cs1180347	568	1
cs1180349	568	1
cs1180352	568	1
cs1180353	568	1
cs1180354	568	1
cs1180356	568	1
cs1180357	568	1
cs1180358	568	1
cs1180359	568	1
cs1180361	568	1
cs1180363	568	1
cs1180364	568	1
cs1180365	568	1
cs1180367	568	1
cs1180368	568	1
cs1180369	568	1
cs1180371	568	1
cs1180375	568	1
cs1180376	568	1
cs1180378	568	1
cs1180379	568	1
cs1180382	568	1
cs1180383	568	1
cs1180384	568	1
cs1180387	568	1
cs1180388	568	1
cs1180391	568	1
cs1180396	568	1
cs5180406	568	1
cs5180407	568	1
cs5180410	568	1
cs5180411	568	1
cs5180414	568	1
cs5180415	568	1
cs5180416	568	1
cs5180417	568	1
cs5180418	568	1
cs5180421	568	1
cs5180423	568	1
cs5180424	568	1
ee1180431	568	1
ee1180432	568	1
ee1180435	568	1
ee1180438	568	1
ee1180440	568	1
ee1180442	568	1
ee1180445	568	1
ee1180448	568	1
ee1180449	568	1
ee1180450	568	1
ee1180451	568	1
ee1180453	568	1
ee1180455	568	1
ee1180457	568	1
ee1180461	568	1
ee1180462	568	1
ee1180463	568	1
ee1180464	568	1
ee1180465	568	1
ee1180466	568	1
ee1180471	568	1
ee1180472	568	1
ee1180474	568	1
ee1180475	568	1
ee1180477	568	1
ee1180478	568	1
ee1180479	568	1
ee1180480	568	1
ee1180481	568	1
ee1180484	568	1
ee1180487	568	1
ee1180488	568	1
ee1180490	568	1
ee1180493	568	1
ee1180494	568	1
ee1180495	568	1
ee1180498	568	1
ee1180499	568	1
ee1180500	568	1
ee1180501	568	1
ee1180502	568	1
ee1180503	568	1
ee1180507	568	1
ee1180508	568	1
ee1180510	568	1
ee1180512	568	1
ee1180513	568	1
ee1180514	568	1
ee1180515	568	1
ee3180522	568	1
ee3180526	568	1
ee3180529	568	1
ee3180532	568	1
ee3180534	568	1
ee3180536	568	1
ee3180537	568	1
ee3180538	568	1
ee3180539	568	1
ee3180540	568	1
ee3180543	568	1
ee3180544	568	1
ee3180548	568	1
ee3180550	568	1
ee3180551	568	1
ee3180552	568	1
ee3180555	568	1
ee3180558	568	1
ee3180559	568	1
ee3180561	568	1
ee3180564	568	1
ee3180566	568	1
ee3180567	568	1
ee3180568	568	1
me1180583	568	1
me1180585	568	1
me1180586	568	1
me1180587	568	1
me1180591	568	1
me1180593	568	1
me1180594	568	1
me1180595	568	1
me1180596	568	1
me1180598	568	1
me1180601	568	1
me1180602	568	1
me1180605	568	1
me1180607	568	1
me1180609	568	1
me1180610	568	1
me1180613	568	1
me1180617	568	1
me1180618	568	1
me1180619	568	1
me1180620	568	1
me1180621	568	1
me1180623	568	1
me1180625	568	1
me1180629	568	1
me1180632	568	1
me1180635	568	1
me1180636	568	1
me1180637	568	1
me1180638	568	1
me1180639	568	1
me1180640	568	1
me1180642	568	1
me1180643	568	1
me1180646	568	1
me1180647	568	1
me1180648	568	1
me1180649	568	1
me1180652	568	1
me1180653	568	1
me1180655	568	1
me1180657	568	1
me2170659	568	1
me2180665	568	1
me2180667	568	1
me2180669	568	1
me2180671	568	1
me2180673	568	1
me2180677	568	1
me2180680	568	1
me2180684	568	1
me2180685	568	1
me2180686	568	1
me2180689	568	1
me2180693	568	1
me2180697	568	1
me2180702	568	1
me2180704	568	1
me2180705	568	1
me2180708	568	1
me2180710	568	1
me2180711	568	1
me2180714	568	1
me2180720	568	1
me2180721	568	1
me2180724	568	1
me2180727	568	1
me2180729	568	1
me2180731	568	1
me2180734	568	1
me2180735	568	1
mt1180736	568	1
mt1180737	568	1
mt1180740	568	1
mt1180741	568	1
mt1180743	568	1
mt1180745	568	1
mt1180747	568	1
mt1180749	568	1
mt1180750	568	1
mt1180751	568	1
mt1180752	568	1
mt1180753	568	1
mt1180754	568	1
mt1180756	568	1
mt1180759	568	1
mt1180761	568	1
mt1180763	568	1
mt1180764	568	1
mt1180765	568	1
mt1180766	568	1
mt1180767	568	1
mt1180768	568	1
mt1180769	568	1
mt1180771	568	1
mt1180772	568	1
mt1180773	568	1
mt1180774	568	1
mt6180776	568	1
mt6180778	568	1
mt6180779	568	1
mt6180780	568	1
mt6180781	568	1
mt6180782	568	1
mt6180784	568	1
mt6180786	568	1
mt6180787	568	1
mt6180788	568	1
mt6180789	568	1
mt6180791	568	1
mt6180792	568	1
mt6180796	568	1
mt6180798	568	1
ph1180804	568	1
ph1180805	568	1
ph1180806	568	1
ph1180808	568	1
ph1180809	568	1
ph1180811	568	1
ph1180815	568	1
ph1180816	568	1
ph1180818	568	1
ph1180819	568	1
ph1180823	568	1
ph1180824	568	1
ph1180829	568	1
ph1180834	568	1
ph1180835	568	1
ph1180837	568	1
ph1180840	568	1
ph1180841	568	1
ph1180842	568	1
ph1180847	568	1
ph1180849	568	1
ph1180853	568	1
ph1180855	568	1
ph1180856	568	1
ph1180857	568	1
tt1180867	568	1
tt1180868	568	1
tt1180869	568	1
tt1180871	568	1
tt1180873	568	1
tt1180878	568	1
tt1180880	568	1
tt1180883	568	1
tt1180884	568	1
tt1180885	568	1
tt1180886	568	1
tt1180895	568	1
tt1180898	568	1
tt1180899	568	1
tt1180904	568	1
tt1180907	568	1
tt1180908	568	1
tt1180909	568	1
tt1180913	568	1
tt1180914	568	1
tt1180916	568	1
tt1180917	568	1
tt1180918	568	1
tt1180919	568	1
tt1180924	568	1
tt1180926	568	1
tt1180929	568	1
tt1180931	568	1
tt1180935	568	1
tt1180937	568	1
tt1180938	568	1
tt1180941	568	1
tt1180942	568	1
tt1180943	568	1
tt1180944	568	1
tt1180945	568	1
tt1180948	568	1
tt1180949	568	1
tt1180953	568	1
tt1180957	568	1
tt1180958	568	1
tt1180959	568	1
tt1180961	568	1
tt1180966	568	1
tt1180970	568	1
tt1180971	568	1
tt1180972	568	1
tt1180974	568	1
me2120803	569	1
me2140735	569	1
me2140759	569	1
me2150711	569	1
me2150736	569	1
me2150740	569	1
me2150754	569	1
me2160745	569	1
me2160746	569	1
me2160748	569	1
me2160749	569	1
me2160750	569	1
me2160752	569	1
me2160753	569	1
me2160755	569	1
me2160756	569	1
me2160757	569	1
me2160759	569	1
me2160760	569	1
me2160761	569	1
me2160762	569	1
me2160763	569	1
me2160764	569	1
me2160765	569	1
me2160766	569	1
me2160767	569	1
me2160768	569	1
me2160770	569	1
me2160771	569	1
me2160772	569	1
me2160773	569	1
me2160774	569	1
me2160775	569	1
me2160776	569	1
me2160777	569	1
me2160778	569	1
me2160780	569	1
me2160781	569	1
me2160782	569	1
me2160783	569	1
me2160784	569	1
me2160786	569	1
me2160787	569	1
me2160788	569	1
me2160790	569	1
me2160792	569	1
me2160793	569	1
me2160794	569	1
me2160795	569	1
me2160796	569	1
me2160797	569	1
me2160800	569	1
me2160801	569	1
me2160803	569	1
me2160806	569	1
me2160807	569	1
me2160808	569	1
me2160809	569	1
me2160810	569	1
me2160811	569	1
me1080519	570	1
me1120651	570	1
me1130698	570	1
me1160036	570	1
me1160073	570	1
me1160080	570	1
me1160224	570	1
me1160670	570	1
me1160671	570	1
me1160672	570	1
me1160673	570	1
me1160674	570	1
me1160676	570	1
me1160678	570	1
me1160679	570	1
me1160681	570	1
me1160682	570	1
me1160683	570	1
me1160684	570	1
me1160685	570	1
me1160686	570	1
me1160687	570	1
me1160688	570	1
me1160689	570	1
me1160690	570	1
me1160691	570	1
me1160692	570	1
me1160693	570	1
me1160695	570	1
me1160696	570	1
me1160697	570	1
me1160698	570	1
me1160699	570	1
me1160700	570	1
me1160702	570	1
me1160703	570	1
me1160704	570	1
me1160705	570	1
me1160706	570	1
me1160707	570	1
me1160708	570	1
me1160709	570	1
me1160710	570	1
me1160711	570	1
me1160712	570	1
me1160713	570	1
me1160714	570	1
me1160715	570	1
me1160717	570	1
me1160718	570	1
me1160719	570	1
me1160720	570	1
me1160721	570	1
me1160722	570	1
me1160723	570	1
me1160724	570	1
me1160725	570	1
me1160726	570	1
me1160727	570	1
me1160728	570	1
me1160729	570	1
me1160730	570	1
me1160731	570	1
me1160732	570	1
me1160733	570	1
me1160734	570	1
me1160735	570	1
me1160736	570	1
me1160737	570	1
me1160747	570	1
me1160754	570	1
me1160758	570	1
me1160824	570	1
me1160829	570	1
me1160830	570	1
me1160901	570	1
me1170620	570	1
me1170623	570	1
me1130727	571	1
me1140667	571	1
me1150044	571	1
me1150228	571	1
me1150383	571	1
me1150673	571	1
me1150686	571	1
me1160036	571	1
me1160073	571	1
me1160080	571	1
me1160224	571	1
me1160670	571	1
me1160672	571	1
me1160673	571	1
me1160674	571	1
me1160676	571	1
me1160678	571	1
me1160679	571	1
me1160681	571	1
me1160682	571	1
me1160683	571	1
me1160684	571	1
me1160685	571	1
me1160686	571	1
me1160687	571	1
me1160688	571	1
me1160689	571	1
me1160690	571	1
me1160691	571	1
me1160692	571	1
me1160693	571	1
me1160695	571	1
me1160696	571	1
me1160697	571	1
me1160698	571	1
me1160699	571	1
me1160700	571	1
me1160702	571	1
me1160703	571	1
me1160704	571	1
me1160705	571	1
me1160706	571	1
me1160707	571	1
me1160708	571	1
me1160709	571	1
me1160710	571	1
me1160711	571	1
me1160712	571	1
me1160713	571	1
me1160714	571	1
me1160715	571	1
me1160716	571	1
me1160717	571	1
me1160718	571	1
me1160719	571	1
me1160720	571	1
me1160721	571	1
me1160722	571	1
me1160723	571	1
me1160724	571	1
me1160725	571	1
me1160726	571	1
me1160727	571	1
me1160728	571	1
me1160729	571	1
me1160730	571	1
me1160731	571	1
me1160732	571	1
me1160733	571	1
me1160734	571	1
me1160735	571	1
me1160736	571	1
me1160737	571	1
me1160747	571	1
me1160754	571	1
me1160758	571	1
me1160824	571	1
me1160829	571	1
me1160830	571	1
me1160901	571	1
me2120803	572	1
me2140721	572	1
me2150711	572	1
me2150736	572	1
me2150740	572	1
me2150754	572	1
me2160745	572	1
me2160746	572	1
me2160748	572	1
me2160749	572	1
me2160750	572	1
me2160752	572	1
me2160753	572	1
me2160755	572	1
me2160756	572	1
me2160757	572	1
me2160759	572	1
me2160760	572	1
me2160761	572	1
me2160762	572	1
me2160763	572	1
me2160764	572	1
me2160765	572	1
me2160766	572	1
me2160767	572	1
me2160768	572	1
me2160770	572	1
me2160771	572	1
me2160772	572	1
me2160773	572	1
me2160774	572	1
me2160775	572	1
me2160776	572	1
me2160777	572	1
me2160778	572	1
me2160779	572	1
me2160780	572	1
me2160781	572	1
me2160782	572	1
me2160783	572	1
me2160784	572	1
me2160786	572	1
me2160787	572	1
me2160788	572	1
me2160790	572	1
me2160792	572	1
me2160793	572	1
me2160794	572	1
me2160795	572	1
me2160796	572	1
me2160797	572	1
me2160798	572	1
me2160800	572	1
me2160801	572	1
me2160802	572	1
me2160803	572	1
me2160804	572	1
me2160806	572	1
me2160807	572	1
me2160808	572	1
me2160809	572	1
me2160810	572	1
me2160811	572	1
ch7140159	573	1
cs1150238	573	1
cs1150435	573	1
ee3140526	573	1
ee3160533	573	1
me1130654	573	1
me1150643	573	1
me1150655	573	1
me1150662	573	1
me1150682	573	1
me1150683	573	1
me1150692	573	1
me2140721	573	1
me2140735	573	1
me2150709	573	1
me2170668	573	1
me2170670	573	1
me2170671	573	1
me2170672	573	1
me2170673	573	1
me2170674	573	1
me2170681	573	1
me2170688	573	1
mt1150611	573	1
mt6140556	573	1
ph1140824	573	1
tt1140115	573	1
tt1140228	573	1
tt1150903	573	1
tt1150916	573	1
ee3170552	574	1
ee3170554	574	1
me1150044	574	1
me1150228	574	1
me1150647	574	1
me1150654	574	1
me1150655	574	1
me1150660	574	1
me1150680	574	1
me1150685	574	1
me1150686	574	1
me1150687	574	1
me1160073	574	1
me1160676	574	1
me1160687	574	1
me1160693	574	1
me1160704	574	1
me1160706	574	1
me1160710	574	1
me1160717	574	1
me1160729	574	1
me1160733	574	1
me1160901	574	1
me1170698	574	1
me2150715	574	1
me2160795	574	1
me2170696	574	1
me2170699	574	1
ee1150464	575	1
ee1150473	575	1
me1150390	575	1
me1150630	575	1
me1150655	575	1
me1150658	575	1
me1150679	575	1
me1160729	575	1
me1160734	575	1
me1170582	575	1
me2140759	575	1
me2150731	575	1
me2150732	575	1
me2150734	575	1
me2150738	575	1
me2150741	575	1
me2150743	575	1
me2150746	575	1
me2150759	575	1
me2160761	575	1
me2160763	575	1
me2160764	575	1
me2160765	575	1
me2160772	575	1
me2160784	575	1
me2160793	575	1
me2160797	575	1
me2160800	575	1
me2160810	575	1
ph1150808	575	1
mem172478	576	1
mem172488	576	1
mem172526	576	1
mem172746	576	1
mem172750	576	1
mem172798	576	1
mem172804	576	1
me1100745	577	1
me1080519	579	1
me1080528	579	1
bsz188120	580	1
bsz188605	580	1
ch1140071	580	1
mt5120605	580	1
smz188177	580	1
smz188178	580	1
smz188180	580	1
smz188181	580	1
smz188186	580	1
smz188187	580	1
smz188190	580	1
smz188192	580	1
smz188530	580	1
smz188540	580	1
smz188542	580	1
smz188543	580	1
smz188657	580	1
smf176558	581	1
smf176559	581	1
smf176561	581	1
smf176562	581	1
smf176564	581	1
smf176565	581	1
smf176567	581	1
smf176568	581	1
smf176570	581	1
smf176571	581	1
smf176572	581	1
smf176573	581	1
smf176574	581	1
smf176575	581	1
smf176578	581	1
smf176580	581	1
smf176581	581	1
smf176582	581	1
smf176584	581	1
smf176585	581	1
smf176586	581	1
smf176587	581	1
smf176588	581	1
smf176589	581	1
smf176590	581	1
smf176591	581	1
smf176592	581	1
smf176593	581	1
smf176595	581	1
smf176596	581	1
smf176597	581	1
smf176598	581	1
smf176599	581	1
smf176600	581	1
smf176601	581	1
smf176603	581	1
smf176604	581	1
smf176605	581	1
smf176606	581	1
smf176607	581	1
smf176609	581	1
smf176610	581	1
smf176611	581	1
smf176612	581	1
smf176613	581	1
smf176614	581	1
smf176615	581	1
smf176616	581	1
smf176617	581	1
smf176618	581	1
smf176619	581	1
smf176620	581	1
smf176621	581	1
smf176624	581	1
smf176628	581	1
smf176629	581	1
smf176630	581	1
smf176631	581	1
smf176650	581	1
smf176651	581	1
smf176654	581	1
smf176655	581	1
smf176657	581	1
smf176658	581	1
smf176659	581	1
smf176660	581	1
smf176669	581	1
smf176670	581	1
smf176671	581	1
smf176672	581	1
smf176673	581	1
smf176674	581	1
smf176675	581	1
smf176676	581	1
smf176677	581	1
smf176678	581	1
smf176680	581	1
smf176681	581	1
smf176682	581	1
smf176683	581	1
smf176684	581	1
smf176685	581	1
smf176686	581	1
smf176687	581	1
smt176695	581	1
smf176577	582	1
smf176608	582	1
smf176623	582	1
smf176625	582	1
smf176627	582	1
smf176653	582	1
smf176679	582	1
smt176632	582	1
smt176633	582	1
smt176636	582	1
smt176637	582	1
smt176639	582	1
smt176640	582	1
smt176641	582	1
smt176642	582	1
smt176645	582	1
smt176647	582	1
smt176648	582	1
smt176649	582	1
smt176661	582	1
smt176662	582	1
smt176664	582	1
smt176696	582	1
smt176697	582	1
smt176698	582	1
smt176699	582	1
smf176622	583	1
smn156547	583	1
smn166637	583	1
smn166639	583	1
smn166640	583	1
smn166641	583	1
smn166642	583	1
smn166644	583	1
smn166646	583	1
smn166647	583	1
smn166648	583	1
smn166649	583	1
smn166650	583	1
smn166651	583	1
smn166652	583	1
smn166653	583	1
smn166654	583	1
smn166656	583	1
smn166657	583	1
smn166658	583	1
smn166659	583	1
smn166660	583	1
smn166662	583	1
smn166663	583	1
smn166665	583	1
smn166666	583	1
smn166667	583	1
smn166668	583	1
smn166669	583	1
smn166670	583	1
smn166675	583	1
smn166677	583	1
smn166679	583	1
smn166680	583	1
smn166683	583	1
smn166684	583	1
smn166685	583	1
smn166687	583	1
smn166688	583	1
smn166689	583	1
smn166690	583	1
smn166691	583	1
smn166692	583	1
smn166693	583	1
smn166696	583	1
smn166698	583	1
smn166699	583	1
smn166700	583	1
smn166701	583	1
smn166702	583	1
bb1150033	584	1
bb1160023	584	1
bb1160025	584	1
bb1160029	584	1
bb1160032	584	1
bb1160041	584	1
bb1170027	584	1
bb5160001	584	1
bb5160006	584	1
bb5160008	584	1
bb5160013	584	1
ce1150371	584	1
ce1160204	584	1
ce1160213	584	1
ce1160223	584	1
ce1160233	584	1
ce1160252	584	1
ce1170080	584	1
ce1170106	584	1
ce1170125	584	1
ce1170126	584	1
ch1160093	584	1
ch1160100	584	1
ch1160103	584	1
ch1160124	584	1
ch1160127	584	1
ch1160130	584	1
ch1160143	584	1
ch1170235	584	1
ch7140195	584	1
ch7150174	584	1
ch7150184	584	1
ch7150194	584	1
ch7160151	584	1
ch7160165	584	1
ch7160178	584	1
ch7160179	584	1
ch7160186	584	1
cs1160331	584	1
cs1160362	584	1
cs1160365	584	1
cs1160396	584	1
ee3160504	584	1
ee3160511	584	1
ee3160526	584	1
ee3160528	584	1
ee5110563	584	1
me1160691	584	1
me1170576	584	1
me2160749	584	1
me2160750	584	1
me2160753	584	1
me2160762	584	1
me2160765	584	1
me2160776	584	1
me2160777	584	1
me2160778	584	1
me2160787	584	1
me2160790	584	1
me2160794	584	1
me2170645	584	1
me2170648	584	1
me2170687	584	1
mt6160651	584	1
mt6160677	584	1
ph1160579	584	1
tt1150916	584	1
tt1160822	584	1
tt1160839	584	1
tt1160849	584	1
tt1160850	584	1
tt1160852	584	1
tt1160855	584	1
tt1160860	584	1
tt1160861	584	1
tt1160862	584	1
tt1160866	584	1
tt1160876	584	1
tt1160878	584	1
tt1160879	584	1
tt1160884	584	1
tt1160885	584	1
tt1160889	584	1
tt1160892	584	1
tt1160898	584	1
tt1160902	584	1
tt1160903	584	1
tt1160910	584	1
tt1160926	584	1
tt1160927	584	1
tt1170905	584	1
bb1150033	585	1
bb1160023	585	1
bb1160025	585	1
bb1160029	585	1
bb1160032	585	1
bb1160041	585	1
bb5150012	585	1
bb5160006	585	1
bb5160008	585	1
ce1150362	585	1
ce1160208	585	1
ce1160215	585	1
ce1160228	585	1
ce1160229	585	1
ce1160231	585	1
ce1160233	585	1
ce1160234	585	1
ce1160236	585	1
ce1160244	585	1
ce1160252	585	1
ce1160254	585	1
ce1160263	585	1
ce1170122	585	1
ch1150076	585	1
ch1160088	585	1
ch1160093	585	1
ch1160094	585	1
ch1160100	585	1
ch1160101	585	1
ch1160103	585	1
ch1160109	585	1
ch1160127	585	1
ch1160130	585	1
ch1160143	585	1
ch7140177	585	1
ch7140834	585	1
ch7150174	585	1
ch7160151	585	1
cs1160331	585	1
ee1150438	585	1
ee1160441	585	1
ee5110563	585	1
me1160688	585	1
me1160691	585	1
me1160695	585	1
me1160700	585	1
me2160749	585	1
me2160750	585	1
me2160753	585	1
me2160756	585	1
me2160762	585	1
me2160766	585	1
me2160776	585	1
me2160777	585	1
me2160778	585	1
me2160787	585	1
me2160790	585	1
me2170672	585	1
tt1150953	585	1
tt1160822	585	1
tt1160836	585	1
tt1160837	585	1
tt1160839	585	1
tt1160849	585	1
tt1160850	585	1
tt1160852	585	1
tt1160853	585	1
tt1160860	585	1
tt1160861	585	1
tt1160862	585	1
tt1160863	585	1
tt1160866	585	1
tt1160872	585	1
tt1160876	585	1
tt1160879	585	1
tt1160885	585	1
tt1160889	585	1
tt1160892	585	1
tt1160896	585	1
tt1160898	585	1
tt1160903	585	1
tt1160910	585	1
tt1160926	585	1
tt1160927	585	1
smn176502	586	1
smn176503	586	1
smn176504	586	1
smn176505	586	1
smn176506	586	1
smn176507	586	1
smn176508	586	1
smn176509	586	1
smn176510	586	1
smn176511	586	1
smn176513	586	1
smn176514	586	1
smn176516	586	1
smn176517	586	1
smn176518	586	1
smn176519	586	1
smn176520	586	1
smn176522	586	1
smn176524	586	1
smn176525	586	1
smn176527	586	1
smn176529	586	1
smn176530	586	1
smn176531	586	1
smn176533	586	1
smn176534	586	1
smn176535	586	1
smn176536	586	1
smn176537	586	1
smn176538	586	1
smn176539	586	1
smn176540	586	1
smn176541	586	1
smn176542	586	1
smn176543	586	1
smn176544	586	1
smn176545	586	1
smn176546	586	1
smn176547	586	1
smn176548	586	1
smn176550	586	1
smn176551	586	1
smn176553	586	1
smn176554	586	1
smn176555	586	1
smn176665	586	1
smn176666	586	1
smn176667	586	1
smn176668	586	1
smz188527	586	1
smz188529	586	1
smz188531	586	1
smz188534	586	1
smz188536	586	1
smz188540	586	1
smn186501	587	1
smn186503	587	1
smn186504	587	1
smn186507	587	1
smn186508	587	1
smn186509	587	1
smn186513	587	1
smn186515	587	1
smn186517	587	1
smn186518	587	1
smn186519	587	1
smn186520	587	1
smn186521	587	1
smn186522	587	1
smn186523	587	1
smn186525	587	1
smn186527	587	1
smn186528	587	1
smn186529	587	1
smn186530	587	1
smn186531	587	1
smn186532	587	1
smn186533	587	1
smn186534	587	1
smn186535	587	1
smn186536	587	1
smn186538	587	1
smn186539	587	1
smn186540	587	1
smn186541	587	1
smn186542	587	1
smn186543	587	1
smz188530	587	1
tte172054	587	1
smf186546	588	1
smf186549	588	1
smf186553	588	1
smf186556	588	1
smf186558	588	1
smf186559	588	1
smf186561	588	1
smf186567	588	1
smf186569	588	1
smf186571	588	1
smf186576	588	1
smf186578	588	1
smf186581	588	1
smf186584	588	1
smf186587	588	1
smf186589	588	1
smf186591	588	1
smf186592	588	1
smf186595	588	1
smf186603	588	1
smf186604	588	1
smf186605	588	1
smf186606	588	1
smf186608	588	1
smf186610	588	1
smf186612	588	1
smf186614	588	1
smf186616	588	1
smf186618	588	1
smf186621	588	1
smf186623	588	1
smf186625	588	1
smf186626	588	1
smf186628	588	1
smt186597	588	1
smt186630	588	1
smt186631	588	1
smf186545	589	1
smf186547	589	1
smf186550	589	1
smf186555	589	1
smf186560	589	1
smf186562	589	1
smf186564	589	1
smf186566	589	1
smf186568	589	1
smf186572	589	1
smf186573	589	1
smf186575	589	1
smf186577	589	1
smf186579	589	1
smf186580	589	1
smf186582	589	1
smf186583	589	1
smf186585	589	1
smf186586	589	1
smf186588	589	1
smf186594	589	1
smf186602	589	1
smf186607	589	1
smf186611	589	1
smf186613	589	1
smf186620	589	1
smf186622	589	1
smf186624	589	1
smf186627	589	1
smt186596	589	1
smz188612	589	1
smf176556	590	1
smf176559	590	1
smf176561	590	1
smf176562	590	1
smf176564	590	1
smf176565	590	1
smf176567	590	1
smf176568	590	1
smf176570	590	1
smf176571	590	1
smf176572	590	1
smf176573	590	1
smf176574	590	1
smf176575	590	1
smf176577	590	1
smf176578	590	1
smf176580	590	1
smf176581	590	1
smf176582	590	1
smf176584	590	1
smf176585	590	1
smf176586	590	1
smf176587	590	1
smf176588	590	1
smf176589	590	1
smf176590	590	1
smf176591	590	1
smf176593	590	1
smf176595	590	1
smf176596	590	1
smf176597	590	1
smf176598	590	1
smf176599	590	1
smf176600	590	1
smf176601	590	1
smf176603	590	1
smf176604	590	1
smf176605	590	1
smf176606	590	1
smf176607	590	1
smf176609	590	1
smf176610	590	1
smf176611	590	1
smf176612	590	1
smf176613	590	1
smf176614	590	1
smf176615	590	1
smf176616	590	1
smf176617	590	1
smf176618	590	1
smf176619	590	1
smf176620	590	1
smf176621	590	1
smf176622	590	1
smf176623	590	1
smf176624	590	1
smf176625	590	1
smf176627	590	1
smf176628	590	1
smf176629	590	1
smf176630	590	1
smf176631	590	1
smf176651	590	1
smf176653	590	1
smf176654	590	1
smf176655	590	1
smf176657	590	1
smf176658	590	1
smf176659	590	1
smf176660	590	1
smf176669	590	1
smf176670	590	1
smf176671	590	1
smf176672	590	1
smf176673	590	1
smf176674	590	1
smf176675	590	1
smf176676	590	1
smf176678	590	1
smf176679	590	1
smf176680	590	1
smf176681	590	1
smf176682	590	1
smf176683	590	1
smf176685	590	1
smf176686	590	1
smf176687	590	1
smt176632	590	1
smt176633	590	1
smt176636	590	1
smt176637	590	1
smt176639	590	1
smt176640	590	1
smt176641	590	1
smt176642	590	1
smt176645	590	1
smt176647	590	1
smt176648	590	1
smt176649	590	1
smt176661	590	1
smt176662	590	1
smt176664	590	1
smt176695	590	1
smt176696	590	1
smt176697	590	1
smt176698	590	1
smt176699	590	1
cez188050	591	1
ch1150076	591	1
ch1150128	591	1
crf172574	591	1
smn186501	591	1
smn186503	591	1
smn186504	591	1
smn186507	591	1
smn186508	591	1
smn186509	591	1
smn186513	591	1
smn186515	591	1
smn186517	591	1
smn186518	591	1
smn186519	591	1
smn186520	591	1
smn186521	591	1
smn186522	591	1
smn186523	591	1
smn186524	591	1
smn186525	591	1
smn186527	591	1
smn186528	591	1
smn186529	591	1
smn186530	591	1
smn186531	591	1
smn186532	591	1
smn186533	591	1
smn186534	591	1
smn186535	591	1
smn186536	591	1
smn186537	591	1
smn186538	591	1
smn186539	591	1
smn186540	591	1
smn186541	591	1
smn186542	591	1
smn186543	591	1
smz188526	591	1
smf186545	592	1
smf186546	592	1
smf186547	592	1
smf186549	592	1
smf186550	592	1
smf186553	592	1
smf186555	592	1
smf186556	592	1
smf186558	592	1
smf186559	592	1
smf186560	592	1
smf186561	592	1
smf186562	592	1
smf186564	592	1
smf186566	592	1
smf186567	592	1
smf186568	592	1
smf186569	592	1
smf186571	592	1
smf186572	592	1
smf186573	592	1
smf186575	592	1
smf186576	592	1
smf186577	592	1
smf186578	592	1
smf186579	592	1
smf186580	592	1
smf186581	592	1
smf186582	592	1
smf186583	592	1
smf186584	592	1
smf186585	592	1
smf186586	592	1
smf186587	592	1
smf186588	592	1
smf186589	592	1
smf186591	592	1
smf186592	592	1
smf186594	592	1
smf186595	592	1
smf186602	592	1
smf186603	592	1
smf186604	592	1
smf186605	592	1
smf186606	592	1
smf186607	592	1
smf186608	592	1
smf186610	592	1
smf186611	592	1
smf186612	592	1
smf186613	592	1
smf186614	592	1
smf186615	592	1
smf186616	592	1
smf186618	592	1
smf186620	592	1
smf186621	592	1
smf186622	592	1
smf186623	592	1
smf186624	592	1
smf186625	592	1
smf186626	592	1
smf186627	592	1
smf186628	592	1
smt186596	592	1
smt186597	592	1
smt186630	592	1
smt186631	592	1
smz188186	592	1
smz188187	592	1
smz188189	592	1
smz188532	592	1
smz188533	592	1
smz188538	592	1
smf186546	593	1
smf186549	593	1
smf186553	593	1
smf186556	593	1
smf186558	593	1
smf186559	593	1
smf186561	593	1
smf186567	593	1
smf186569	593	1
smf186571	593	1
smf186576	593	1
smf186578	593	1
smf186581	593	1
smf186584	593	1
smf186587	593	1
smf186589	593	1
smf186591	593	1
smf186592	593	1
smf186595	593	1
smf186603	593	1
smf186604	593	1
smf186605	593	1
smf186606	593	1
smf186608	593	1
smf186610	593	1
smf186612	593	1
smf186614	593	1
smf186616	593	1
smf186618	593	1
smf186621	593	1
smf186623	593	1
smf186625	593	1
smf186626	593	1
smf186628	593	1
smt186597	593	1
smt186630	593	1
smt186631	593	1
smz188540	593	1
tt1150940	593	1
vst189727	593	1
vst189775	593	1
smf186545	594	1
smf186547	594	1
smf186550	594	1
smf186555	594	1
smf186560	594	1
smf186562	594	1
smf186564	594	1
smf186566	594	1
smf186568	594	1
smf186572	594	1
smf186573	594	1
smf186575	594	1
smf186577	594	1
smf186579	594	1
smf186580	594	1
smf186582	594	1
smf186583	594	1
smf186585	594	1
smf186586	594	1
smf186588	594	1
smf186594	594	1
smf186602	594	1
smf186607	594	1
smf186611	594	1
smf186613	594	1
smf186615	594	1
smf186620	594	1
smf186622	594	1
smf186624	594	1
smf186627	594	1
smt186596	594	1
smz188537	594	1
jtm182775	595	1
smn186501	595	1
smn186503	595	1
smn186504	595	1
smn186507	595	1
smn186508	595	1
smn186509	595	1
smn186513	595	1
smn186515	595	1
smn186517	595	1
smn186518	595	1
smn186519	595	1
smn186520	595	1
smn186521	595	1
smn186522	595	1
smn186523	595	1
smn186524	595	1
smn186525	595	1
smn186527	595	1
smn186528	595	1
smn186529	595	1
smn186530	595	1
smn186531	595	1
smn186532	595	1
smn186533	595	1
smn186534	595	1
smn186535	595	1
smn186536	595	1
smn186537	595	1
smn186538	595	1
smn186539	595	1
smn186540	595	1
smn186541	595	1
smn186542	595	1
smn186543	595	1
bsz188603	596	1
smf186546	596	1
smf186549	596	1
smf186553	596	1
smf186556	596	1
smf186558	596	1
smf186559	596	1
smf186561	596	1
smf186567	596	1
smf186569	596	1
smf186571	596	1
smf186576	596	1
smf186578	596	1
smf186581	596	1
smf186584	596	1
smf186587	596	1
smf186589	596	1
smf186591	596	1
smf186592	596	1
smf186595	596	1
smf186603	596	1
smf186604	596	1
smf186605	596	1
smf186606	596	1
smf186608	596	1
smf186610	596	1
smf186612	596	1
smf186614	596	1
smf186616	596	1
smf186618	596	1
smf186621	596	1
smf186623	596	1
smf186625	596	1
smf186626	596	1
smf186628	596	1
smt186597	596	1
smt186630	596	1
smt186631	596	1
smz188181	596	1
smz188192	596	1
smz188528	596	1
smz188541	596	1
smf186545	597	1
smf186547	597	1
smf186550	597	1
smf186555	597	1
smf186560	597	1
smf186562	597	1
smf186564	597	1
smf186566	597	1
smf186568	597	1
smf186572	597	1
smf186573	597	1
smf186575	597	1
smf186577	597	1
smf186579	597	1
smf186580	597	1
smf186582	597	1
smf186583	597	1
smf186585	597	1
smf186586	597	1
smf186588	597	1
smf186594	597	1
smf186602	597	1
smf186607	597	1
smf186611	597	1
smf186613	597	1
smf186615	597	1
smf186620	597	1
smf186622	597	1
smf186624	597	1
smf186627	597	1
smt186596	597	1
vst189727	597	1
ce1150368	598	1
ce1150370	598	1
ee1150486	598	1
me1150673	598	1
me2150719	598	1
mt6140567	598	1
smf186546	598	1
smf186549	598	1
smf186553	598	1
smf186556	598	1
smf186558	598	1
smf186559	598	1
smf186561	598	1
smf186567	598	1
smf186569	598	1
smf186571	598	1
smf186576	598	1
smf186578	598	1
smf186581	598	1
smf186584	598	1
smf186587	598	1
smf186589	598	1
smf186591	598	1
smf186592	598	1
smf186595	598	1
smf186603	598	1
smf186604	598	1
smf186605	598	1
smf186606	598	1
smf186608	598	1
smf186610	598	1
smf186612	598	1
smf186614	598	1
smf186616	598	1
smf186618	598	1
smf186621	598	1
smf186623	598	1
smf186625	598	1
smf186626	598	1
smf186628	598	1
smt186597	598	1
smt186630	598	1
smt186631	598	1
smz188177	598	1
smz188542	598	1
smz188543	598	1
tt1150891	598	1
tt1150894	598	1
ce1130323	599	1
ch7160179	599	1
ch7160186	599	1
me1150677	599	1
smf186545	599	1
smf186547	599	1
smf186550	599	1
smf186555	599	1
smf186560	599	1
smf186562	599	1
smf186564	599	1
smf186566	599	1
smf186568	599	1
smf186572	599	1
smf186573	599	1
smf186575	599	1
smf186577	599	1
smf186579	599	1
smf186580	599	1
smf186582	599	1
smf186583	599	1
smf186585	599	1
smf186586	599	1
smf186588	599	1
smf186594	599	1
smf186602	599	1
smf186607	599	1
smf186611	599	1
smf186613	599	1
smf186620	599	1
smf186622	599	1
smf186624	599	1
smf186627	599	1
smt186596	599	1
tt1160846	599	1
vst189727	599	1
asz188006	600	1
bb1160023	600	1
bb1160025	600	1
bb5160006	600	1
ce1150371	600	1
ce1160225	600	1
ce1160227	600	1
ce1160228	600	1
ce1160233	600	1
ch1150077	600	1
ch1150132	600	1
ch1160093	600	1
ch7140177	600	1
ch7160165	600	1
ch7160178	600	1
ch7160192	600	1
ee1150438	600	1
ee1150441	600	1
ee1150486	600	1
ee3160497	600	1
ee3160510	600	1
huz188626	600	1
huz188627	600	1
mas177067	600	1
mas177077	600	1
me2160778	600	1
me2160790	600	1
me2160801	600	1
mt1150601	600	1
mt1150607	600	1
mt1160628	600	1
mt6130583	600	1
mt6140558	600	1
mt6140563	600	1
mt6150554	600	1
mt6150555	600	1
mt6150557	600	1
mt6150558	600	1
mt6150562	600	1
smf176558	600	1
smz148143	600	1
smz188173	600	1
smz188175	600	1
smz188181	600	1
smz188182	600	1
smz188184	600	1
smz188185	600	1
smz188186	600	1
smz188187	600	1
smz188192	600	1
smz188524	600	1
smz188532	600	1
smz188533	600	1
smz188537	600	1
smz188538	600	1
smz188541	600	1
tt1150890	600	1
tt1150891	600	1
tt1150894	600	1
tt1150940	600	1
tt1150953	600	1
tt1160857	600	1
tt1160859	600	1
tt1160876	600	1
tt1160879	600	1
tt1160885	600	1
tt1160889	600	1
tt1160900	600	1
tt1160902	600	1
bsz188120	601	1
bsz188605	601	1
jtm182002	601	1
jtm182003	601	1
jtm182004	601	1
jtm182243	601	1
jtm182244	601	1
jtm182245	601	1
jtm182246	601	1
jtm182247	601	1
jtm182248	601	1
jtm182249	601	1
jtm182250	601	1
jtm182251	601	1
jtm182772	601	1
jtm182774	601	1
jtm182775	601	1
smt186596	601	1
smt186597	601	1
smt186630	601	1
smt186631	601	1
smf176574	602	1
smn176502	602	1
smn176503	602	1
smn176504	602	1
smn176505	602	1
smn176506	602	1
smn176507	602	1
smn176508	602	1
smn176509	602	1
smn176510	602	1
smn176511	602	1
smn176513	602	1
smn176514	602	1
smn176516	602	1
smn176517	602	1
smn176518	602	1
smn176519	602	1
smn176520	602	1
smn176522	602	1
smn176524	602	1
smn176525	602	1
smn176527	602	1
smn176529	602	1
smn176530	602	1
smn176531	602	1
smn176533	602	1
smn176534	602	1
smn176535	602	1
smn176536	602	1
smn176537	602	1
smn176538	602	1
smn176539	602	1
smn176540	602	1
smn176541	602	1
smn176542	602	1
smn176543	602	1
smn176544	602	1
smn176545	602	1
smn176546	602	1
smn176547	602	1
smn176548	602	1
smn176550	602	1
smn176551	602	1
smn176553	602	1
smn176554	602	1
smn176555	602	1
smn176665	602	1
smn176666	602	1
smn176667	602	1
smn176668	602	1
smt176632	602	1
smt176633	602	1
smt176636	602	1
smt176637	602	1
smt176639	602	1
smt176640	602	1
smt176641	602	1
smt176642	602	1
smt176645	602	1
smt176647	602	1
smt176648	602	1
smt176649	602	1
smt176661	602	1
smt176662	602	1
smt176664	602	1
smt176695	602	1
smt176696	602	1
smt176697	602	1
smt176698	602	1
smt176699	602	1
bsz188603	603	1
smf186546	603	1
smf186549	603	1
smf186553	603	1
smf186556	603	1
smf186558	603	1
smf186559	603	1
smf186561	603	1
smf186567	603	1
smf186569	603	1
smf186571	603	1
smf186576	603	1
smf186578	603	1
smf186581	603	1
smf186584	603	1
smf186587	603	1
smf186589	603	1
smf186591	603	1
smf186592	603	1
smf186595	603	1
smf186603	603	1
smf186604	603	1
smf186605	603	1
smf186606	603	1
smf186608	603	1
smf186610	603	1
smf186612	603	1
smf186614	603	1
smf186616	603	1
smf186618	603	1
smf186621	603	1
smf186623	603	1
smf186625	603	1
smf186626	603	1
smf186628	603	1
smt186597	603	1
smt186630	603	1
smt186631	603	1
smz188182	603	1
smz188528	603	1
smz188530	603	1
smz188611	603	1
huz188109	604	1
huz188110	604	1
huz188628	604	1
qiz188607	604	1
smf186545	604	1
smf186547	604	1
smf186550	604	1
smf186555	604	1
smf186560	604	1
smf186562	604	1
smf186564	604	1
smf186566	604	1
smf186568	604	1
smf186572	604	1
smf186573	604	1
smf186575	604	1
smf186577	604	1
smf186579	604	1
smf186580	604	1
smf186582	604	1
smf186583	604	1
smf186585	604	1
smf186586	604	1
smf186588	604	1
smf186594	604	1
smf186602	604	1
smf186607	604	1
smf186611	604	1
smf186613	604	1
smf186615	604	1
smf186620	604	1
smf186622	604	1
smf186624	604	1
smf186627	604	1
smt186596	604	1
smf176574	605	1
smn176502	605	1
smn176503	605	1
smn176504	605	1
smn176505	605	1
smn176506	605	1
smn176507	605	1
smn176508	605	1
smn176510	605	1
smn176511	605	1
smn176513	605	1
smn176514	605	1
smn176516	605	1
smn176517	605	1
smn176518	605	1
smn176519	605	1
smn176520	605	1
smn176522	605	1
smn176524	605	1
smn176525	605	1
smn176527	605	1
smn176529	605	1
smn176530	605	1
smn176531	605	1
smn176533	605	1
smn176534	605	1
smn176535	605	1
smn176536	605	1
smn176537	605	1
smn176538	605	1
smn176539	605	1
smn176540	605	1
smn176541	605	1
smn176542	605	1
smn176543	605	1
smn176544	605	1
smn176545	605	1
smn176546	605	1
smn176547	605	1
smn176548	605	1
smn176550	605	1
smn176551	605	1
smn176553	605	1
smn176554	605	1
smn176555	605	1
smn176665	605	1
smn176666	605	1
smn176667	605	1
smn176668	605	1
smt176632	605	1
smt176633	605	1
smt176636	605	1
smt176637	605	1
smt176639	605	1
smt176640	605	1
smt176641	605	1
smt176642	605	1
smt176645	605	1
smt176647	605	1
smt176648	605	1
smt176649	605	1
smt176661	605	1
smt176662	605	1
smt176664	605	1
smt176695	605	1
smt176696	605	1
smt176697	605	1
smt176698	605	1
smt176699	605	1
smz188182	605	1
smf186546	606	1
smf186549	606	1
smf186553	606	1
smf186556	606	1
smf186558	606	1
smf186559	606	1
smf186561	606	1
smf186567	606	1
smf186569	606	1
smf186571	606	1
smf186576	606	1
smf186578	606	1
smf186581	606	1
smf186584	606	1
smf186587	606	1
smf186589	606	1
smf186591	606	1
smf186592	606	1
smf186595	606	1
smf186603	606	1
smf186604	606	1
smf186605	606	1
smf186606	606	1
smf186608	606	1
smf186610	606	1
smf186612	606	1
smf186614	606	1
smf186616	606	1
smf186618	606	1
smf186621	606	1
smf186623	606	1
smf186625	606	1
smf186626	606	1
smf186628	606	1
smt186597	606	1
smt186630	606	1
smt186631	606	1
smz178441	606	1
smz188530	606	1
smz188611	606	1
smz188612	606	1
smf186545	607	1
smf186547	607	1
smf186550	607	1
smf186555	607	1
smf186560	607	1
smf186562	607	1
smf186564	607	1
smf186566	607	1
smf186568	607	1
smf186572	607	1
smf186573	607	1
smf186575	607	1
smf186577	607	1
smf186579	607	1
smf186580	607	1
smf186582	607	1
smf186583	607	1
smf186585	607	1
smf186586	607	1
smf186588	607	1
smf186594	607	1
smf186602	607	1
smf186607	607	1
smf186611	607	1
smf186613	607	1
smf186615	607	1
smf186620	607	1
smf186622	607	1
smf186624	607	1
smf186627	607	1
smt186596	607	1
ch1150128	608	1
smn186501	608	1
smn186503	608	1
smn186504	608	1
smn186507	608	1
smn186508	608	1
smn186509	608	1
smn186513	608	1
smn186515	608	1
smn186517	608	1
smn186518	608	1
smn186519	608	1
smn186520	608	1
smn186521	608	1
smn186522	608	1
smn186523	608	1
smn186524	608	1
smn186525	608	1
smn186527	608	1
smn186528	608	1
smn186529	608	1
smn186530	608	1
smn186531	608	1
smn186532	608	1
smn186533	608	1
smn186534	608	1
smn186535	608	1
smn186536	608	1
smn186537	608	1
smn186538	608	1
smn186539	608	1
smn186540	608	1
smn186541	608	1
smn186542	608	1
smn186543	608	1
smz188535	608	1
smz188541	608	1
smz188544	608	1
tt1150890	608	1
smf186546	609	1
smf186549	609	1
smf186553	609	1
smf186556	609	1
smf186558	609	1
smf186559	609	1
smf186561	609	1
smf186567	609	1
smf186569	609	1
smf186571	609	1
smf186576	609	1
smf186578	609	1
smf186581	609	1
smf186584	609	1
smf186587	609	1
smf186589	609	1
smf186591	609	1
smf186592	609	1
smf186595	609	1
smf186603	609	1
smf186604	609	1
smf186605	609	1
smf186606	609	1
smf186608	609	1
smf186610	609	1
smf186612	609	1
smf186614	609	1
smf186616	609	1
smf186618	609	1
smf186621	609	1
smf186623	609	1
smf186625	609	1
smf186626	609	1
smf186628	609	1
smt186597	609	1
smt186630	609	1
smt186631	609	1
smz188535	609	1
smz188544	609	1
tt1150869	609	1
ttf172029	609	1
ttf172032	609	1
ttf172034	609	1
ttf172037	609	1
ttf172039	609	1
vst189727	609	1
smf186545	610	1
smf186547	610	1
smf186550	610	1
smf186555	610	1
smf186560	610	1
smf186562	610	1
smf186564	610	1
smf186566	610	1
smf186568	610	1
smf186572	610	1
smf186573	610	1
smf186575	610	1
smf186577	610	1
smf186579	610	1
smf186580	610	1
smf186582	610	1
smf186583	610	1
smf186585	610	1
smf186586	610	1
smf186588	610	1
smf186594	610	1
smf186602	610	1
smf186607	610	1
smf186611	610	1
smf186613	610	1
smf186615	610	1
smf186620	610	1
smf186622	610	1
smf186624	610	1
smf186627	610	1
smt186596	610	1
asz188006	611	1
ch1150076	611	1
ch1160103	611	1
ch1160127	611	1
ch7150164	611	1
me2160749	611	1
smn186501	611	1
smn186503	611	1
smn186504	611	1
smn186507	611	1
smn186508	611	1
smn186509	611	1
smn186513	611	1
smn186515	611	1
smn186517	611	1
smn186518	611	1
smn186519	611	1
smn186520	611	1
smn186521	611	1
smn186522	611	1
smn186523	611	1
smn186525	611	1
smn186527	611	1
smn186528	611	1
smn186529	611	1
smn186530	611	1
smn186531	611	1
smn186532	611	1
smn186533	611	1
smn186534	611	1
smn186535	611	1
smn186536	611	1
smn186538	611	1
smn186539	611	1
smn186540	611	1
smn186541	611	1
smn186542	611	1
smn186543	611	1
smz188185	611	1
smz188189	611	1
smz188541	611	1
tt1160837	611	1
bb1150033	612	1
bez188241	612	1
ce1150311	612	1
ce1150317	612	1
ch1150117	612	1
ch1160127	612	1
chz188075	612	1
chz188076	612	1
chz188096	612	1
chz188099	612	1
chz188101	612	1
cs1150256	612	1
ee1150432	612	1
ee1150446	612	1
jit182103	612	1
jit182104	612	1
me1150642	612	1
mez188592	612	1
mt1160616	612	1
mt6150113	612	1
ph1150798	612	1
smn156547	612	1
smn166639	612	1
smn166648	612	1
smn166658	612	1
smn166665	612	1
smn166683	612	1
smz188529	612	1
tt1150865	612	1
tt1150939	612	1
ttf172036	612	1
smf176572	613	1
smf176598	613	1
smf176601	613	1
smf176610	613	1
smf176620	613	1
smf176674	613	1
smf176678	613	1
smf176684	613	1
smf176685	613	1
smz188189	613	1
smz188532	613	1
smz188538	613	1
tt1150858	613	1
tt1150890	613	1
vst189727	613	1
smf176598	614	1
smf176615	614	1
smf176684	614	1
smn166644	614	1
smn166653	614	1
smn166689	614	1
smn166690	614	1
smz188184	614	1
smz188527	614	1
smz188531	614	1
smz188534	614	1
smz188536	614	1
smz188537	614	1
smz188540	614	1
srz188305	614	1
smf176573	615	1
smf176575	615	1
smf176578	615	1
smf176580	615	1
smf176593	615	1
smf176596	615	1
smf176600	615	1
smf176612	615	1
smf176617	615	1
smf176619	615	1
smf176621	615	1
smf176631	615	1
smf176655	615	1
smf176660	615	1
smf176669	615	1
smf176672	615	1
smf176680	615	1
smf176687	615	1
smn166657	615	1
smn166658	615	1
smn176510	615	1
smn176529	615	1
smt176695	615	1
smz188537	615	1
bsz188124	616	1
smf176559	616	1
smf176562	616	1
smf176565	616	1
smf176581	616	1
smf176582	616	1
smf176597	616	1
smf176599	616	1
smf176616	616	1
smf176624	616	1
smf176625	616	1
smf176628	616	1
smf176630	616	1
smf176657	616	1
smn166640	616	1
smn166647	616	1
smn166663	616	1
smt176639	616	1
smt176640	616	1
smt176645	616	1
smt176698	616	1
smz188178	616	1
smz188179	616	1
smz188180	616	1
smz188544	616	1
mt1170530	617	1
siy187538	617	1
smf176573	617	1
smf176575	617	1
smf176580	617	1
smf176584	617	1
smf176585	617	1
smf176586	617	1
smf176590	617	1
smf176595	617	1
smf176596	617	1
smf176597	617	1
smf176599	617	1
smf176600	617	1
smf176603	617	1
smf176604	617	1
smf176606	617	1
smf176609	617	1
smf176611	617	1
smf176613	617	1
smf176615	617	1
smf176618	617	1
smf176621	617	1
smf176622	617	1
smf176623	617	1
smf176627	617	1
smf176630	617	1
smf176653	617	1
smf176654	617	1
smf176655	617	1
smf176669	617	1
smf176670	617	1
smf176671	617	1
smf176672	617	1
smf176673	617	1
smf176676	617	1
smf176680	617	1
smf176681	617	1
smf176682	617	1
smf176683	617	1
smf176684	617	1
smf176687	617	1
smn166642	617	1
smn166646	617	1
smn166680	617	1
smn166685	617	1
smn166689	617	1
smn176503	617	1
smn176504	617	1
smn176505	617	1
smn176506	617	1
smn176507	617	1
smn176510	617	1
smn176511	617	1
smn176513	617	1
smn176514	617	1
smn176518	617	1
smn176519	617	1
smn176522	617	1
smn176524	617	1
smn176525	617	1
smn176527	617	1
smn176529	617	1
smn176530	617	1
smn176531	617	1
smn176533	617	1
smn176535	617	1
smn176537	617	1
smn176538	617	1
smn176539	617	1
smn176540	617	1
smn176541	617	1
smn176543	617	1
smn176544	617	1
smn176545	617	1
smn176546	617	1
smn176547	617	1
smn176548	617	1
smn176550	617	1
smn176551	617	1
smn176554	617	1
smn176555	617	1
smn176665	617	1
smn176667	617	1
smn176668	617	1
smt176632	617	1
smt176647	617	1
smt176648	617	1
smt176649	617	1
smt176697	617	1
smz178441	617	1
smz188528	617	1
tt1150856	617	1
tt1170945	617	1
bb1150057	618	1
ce1140333	618	1
ce1150353	618	1
ce1150362	618	1
ch1150137	618	1
ch1160130	618	1
ch1160143	618	1
ch7150164	618	1
ch7150174	618	1
ee1160417	618	1
ee1160420	618	1
ee3150513	618	1
me1150664	618	1
me2150748	618	1
me2150764	618	1
me2160750	618	1
me2160756	618	1
me2160776	618	1
mt6160677	618	1
smf176556	618	1
smf176561	618	1
smf176564	618	1
smf176567	618	1
smf176568	618	1
smf176570	618	1
smf176572	618	1
smf176574	618	1
smf176577	618	1
smf176589	618	1
smf176591	618	1
smf176592	618	1
smf176605	618	1
smf176607	618	1
smf176608	618	1
smf176612	618	1
smf176614	618	1
smf176624	618	1
smf176631	618	1
smf176650	618	1
smf176659	618	1
smf176671	618	1
smf176675	618	1
smf176677	618	1
smf176679	618	1
smf176681	618	1
smf176682	618	1
smf176684	618	1
smn166649	618	1
smn166650	618	1
smn166659	618	1
smn166684	618	1
smn166692	618	1
smn166696	618	1
smn166698	618	1
smn166701	618	1
smn176503	618	1
smn176505	618	1
smn176506	618	1
smn176508	618	1
smn176510	618	1
smn176513	618	1
smn176514	618	1
smn176516	618	1
smn176517	618	1
smn176518	618	1
smn176519	618	1
smn176522	618	1
smn176524	618	1
smn176525	618	1
smn176527	618	1
smn176529	618	1
smn176530	618	1
smn176531	618	1
smn176533	618	1
smn176538	618	1
smn176539	618	1
smn176540	618	1
smn176543	618	1
smn176544	618	1
smn176546	618	1
smn176547	618	1
smn176550	618	1
smn176551	618	1
smn176554	618	1
smn176555	618	1
smn176667	618	1
smn176668	618	1
smz188191	618	1
smz188539	618	1
tt1150854	618	1
tt1150856	618	1
tt1160822	618	1
tt1160838	618	1
tt1160839	618	1
tt1160840	618	1
tt1160841	618	1
tt1160849	618	1
tt1160860	618	1
tt1160861	618	1
tt1160862	618	1
tt1160872	618	1
tt1160876	618	1
tt1160898	618	1
tt1160910	618	1
tt1160927	618	1
bb1150057	619	1
ce1150362	619	1
ch1150132	619	1
ch7150164	619	1
me1150664	619	1
me2160756	619	1
smf176561	619	1
smf176564	619	1
smf176567	619	1
smf176568	619	1
smf176574	619	1
smf176575	619	1
smf176577	619	1
smf176581	619	1
smf176582	619	1
smf176584	619	1
smf176585	619	1
smf176586	619	1
smf176587	619	1
smf176588	619	1
smf176589	619	1
smf176590	619	1
smf176591	619	1
smf176592	619	1
smf176595	619	1
smf176596	619	1
smf176597	619	1
smf176599	619	1
smf176600	619	1
smf176603	619	1
smf176605	619	1
smf176607	619	1
smf176608	619	1
smf176611	619	1
smf176613	619	1
smf176614	619	1
smf176619	619	1
smf176620	619	1
smf176621	619	1
smf176624	619	1
smf176625	619	1
smf176627	619	1
smf176628	619	1
smf176650	619	1
smf176651	619	1
smf176653	619	1
smf176654	619	1
smf176658	619	1
smf176659	619	1
smf176670	619	1
smf176671	619	1
smf176675	619	1
smf176677	619	1
smf176678	619	1
smf176679	619	1
smf176681	619	1
smf176682	619	1
smf176683	619	1
smf176684	619	1
smf176686	619	1
smn166644	619	1
smn166649	619	1
smn166650	619	1
smn166657	619	1
smn166659	619	1
smn166662	619	1
smn166667	619	1
smn166669	619	1
smn166684	619	1
smn166692	619	1
smn166696	619	1
smn166698	619	1
smn166701	619	1
smt176637	619	1
smt176639	619	1
smt176696	619	1
smz188539	619	1
tt1150854	619	1
tt1150922	619	1
tt1160837	619	1
tt1160839	619	1
smn166637	620	1
smn166644	620	1
smn166654	620	1
smn166657	620	1
smn166666	620	1
smn166669	620	1
smn166689	620	1
smn166699	620	1
smz178441	620	1
ch7150194	621	1
me1150670	621	1
mt6140563	621	1
smn176502	621	1
smn176505	621	1
smn176508	621	1
smn176509	621	1
smn176516	621	1
smn176517	621	1
smn176520	621	1
smn176525	621	1
smn176527	621	1
smn176534	621	1
smn176536	621	1
smn176538	621	1
smn176542	621	1
smn176545	621	1
smn176548	621	1
smn176553	621	1
smn176554	621	1
smn176665	621	1
smn176666	621	1
tt1150890	621	1
tt1150894	621	1
tt1160878	621	1
tt1160892	621	1
bb1150057	622	1
ce1150353	622	1
ce1150362	622	1
ce1160213	622	1
ch1150132	622	1
ch7140049	622	1
ch7150164	622	1
ee1150463	622	1
ee1150486	622	1
me1150677	622	1
me2150732	622	1
me2150733	622	1
me2150763	622	1
me2150771	622	1
mt1150601	622	1
mt6150358	622	1
mt6150555	622	1
ph1150793	622	1
smf176556	622	1
smf176559	622	1
smf176562	622	1
smf176565	622	1
smf176570	622	1
smf176587	622	1
smf176588	622	1
smf176598	622	1
smf176601	622	1
smf176607	622	1
smf176609	622	1
smf176610	622	1
smf176617	622	1
smf176619	622	1
smf176621	622	1
smf176622	622	1
smf176629	622	1
smf176630	622	1
smf176651	622	1
smf176655	622	1
smf176657	622	1
smf176658	622	1
smf176660	622	1
smf176674	622	1
smf176676	622	1
smf176678	622	1
smf176685	622	1
smf176686	622	1
smf176687	622	1
smt176664	622	1
smt176696	622	1
smt176699	622	1
smz188185	622	1
smz188532	622	1
smz188533	622	1
smz188538	622	1
tt1150854	622	1
tt1150911	622	1
ch1160130	623	1
ch1160143	623	1
ch7160165	623	1
huz178592	623	1
me1150670	623	1
mt6140563	623	1
smn176502	623	1
smn176505	623	1
smn176508	623	1
smn176509	623	1
smn176513	623	1
smn176516	623	1
smn176517	623	1
smn176520	623	1
smn176525	623	1
smn176527	623	1
smn176533	623	1
smn176534	623	1
smn176536	623	1
smn176538	623	1
smn176542	623	1
smn176545	623	1
smn176548	623	1
smn176553	623	1
smn176554	623	1
smn176665	623	1
smn176666	623	1
tt1150890	623	1
tt1150894	623	1
tt1160878	623	1
tt1160892	623	1
bb5150009	624	1
ce1150353	624	1
me1150677	624	1
mt6140563	624	1
mt6150555	624	1
ph1150783	624	1
smn166654	624	1
smn166658	624	1
smn166668	624	1
smn166690	624	1
smn166691	624	1
smn166699	624	1
smz188185	624	1
smz188526	624	1
bb1150033	625	1
bb1160041	625	1
bb5160008	625	1
bb5170051	625	1
bsz188603	625	1
ch7150174	625	1
ee3160504	625	1
ee3160511	625	1
smf176660	625	1
smz188528	625	1
tt1160898	625	1
tt1170893	625	1
tt1170901	625	1
tt1170902	625	1
bb1170004	626	1
bb1170005	626	1
bb1170007	626	1
bb1170008	626	1
bb1170014	626	1
bb1170015	626	1
bb1170023	626	1
bb1170024	626	1
bb1170025	626	1
bb1170031	626	1
bb1170047	626	1
bb5150009	626	1
bb5160008	626	1
ce1160252	626	1
ce1170080	626	1
ce1170092	626	1
ce1170100	626	1
ce1170110	626	1
ce1170115	626	1
ch1160125	626	1
ch7170275	626	1
ch7170281	626	1
cs1160365	626	1
cs1170321	626	1
cs5170401	626	1
ee1170345	626	1
ee3160526	626	1
huz188627	626	1
me1160695	626	1
me2170644	626	1
me2170645	626	1
me2170670	626	1
me2170688	626	1
me2170691	626	1
smn176502	626	1
smn176509	626	1
smn176520	626	1
smn176534	626	1
smn176536	626	1
smn176542	626	1
smn176548	626	1
smn176553	626	1
smn176665	626	1
smn176666	626	1
tt1150890	626	1
tt1150935	626	1
tt1160853	626	1
tt1170871	626	1
tt1170874	626	1
tt1170877	626	1
tt1170885	626	1
tt1170888	626	1
tt1170899	626	1
tt1170900	626	1
tt1170902	626	1
tt1170908	626	1
tt1170909	626	1
tt1170920	626	1
tt1170929	626	1
tt1170941	626	1
tt1170962	626	1
tt1170971	626	1
bsz188603	627	1
smf176559	627	1
smf176603	627	1
smf176616	627	1
smf176673	627	1
smf176674	627	1
smf176683	627	1
smf176687	627	1
smn166700	627	1
smn176504	627	1
smn176507	627	1
smn176535	627	1
smn176537	627	1
smn176541	627	1
smn186517	627	1
smn186519	627	1
smt176632	627	1
smt176641	627	1
smt176642	627	1
smt176648	627	1
bsz188603	628	1
smf176586	628	1
smf176624	628	1
smn166641	628	1
smn166646	628	1
smn166649	628	1
smn166684	628	1
smn166692	628	1
smn166699	628	1
smn166700	628	1
smn176503	628	1
smn176504	628	1
smn176506	628	1
smn176507	628	1
smn176511	628	1
smn176518	628	1
smn176519	628	1
smn176522	628	1
smn176524	628	1
smn176539	628	1
smn176540	628	1
smn176543	628	1
smn176544	628	1
smn176546	628	1
smn176550	628	1
smn176551	628	1
smn176555	628	1
smn176668	628	1
smz188181	628	1
smz188182	628	1
smz188192	628	1
smz188528	628	1
smz188611	628	1
smz188612	628	1
ce1150371	629	1
ch7140834	629	1
ch7150194	629	1
ee1150438	629	1
ph1150783	629	1
smf176558	629	1
smf176629	629	1
smz158335	629	1
smz168442	629	1
smz168447	629	1
smz178439	629	1
smz178464	629	1
smz188175	629	1
smz188189	629	1
smz188524	629	1
tt1150890	629	1
tt1150894	629	1
tt1150935	629	1
tt1150939	629	1
tt1150953	629	1
tt1160892	629	1
smf186545	630	1
smf186546	630	1
smf186547	630	1
smf186549	630	1
smf186550	630	1
smf186553	630	1
smf186555	630	1
smf186556	630	1
smf186558	630	1
smf186559	630	1
smf186560	630	1
smf186561	630	1
smf186562	630	1
smf186564	630	1
smf186566	630	1
smf186568	630	1
smf186569	630	1
smf186571	630	1
smf186572	630	1
smf186573	630	1
smf186575	630	1
smf186576	630	1
smf186577	630	1
smf186578	630	1
smf186579	630	1
smf186580	630	1
smf186581	630	1
smf186582	630	1
smf186583	630	1
smf186584	630	1
smf186585	630	1
smf186586	630	1
smf186587	630	1
smf186588	630	1
smf186589	630	1
smf186591	630	1
smf186592	630	1
smf186594	630	1
smf186595	630	1
smf186602	630	1
smf186603	630	1
smf186604	630	1
smf186605	630	1
smf186606	630	1
smf186607	630	1
smf186608	630	1
smf186610	630	1
smf186611	630	1
smf186612	630	1
smf186613	630	1
smf186614	630	1
smf186615	630	1
smf186616	630	1
smf186618	630	1
smf186620	630	1
smf186621	630	1
smf186622	630	1
smf186623	630	1
smf186624	630	1
smf186625	630	1
smf186626	630	1
smf186627	630	1
smf186628	630	1
smt186596	630	1
smt186597	630	1
smt186630	630	1
smt186631	630	1
bb5140009	631	1
ce1150313	631	1
ce1150394	631	1
ch1150089	631	1
ch1150139	631	1
cs5140278	631	1
ee3150524	631	1
ee3150525	631	1
ee3150531	631	1
me1150652	631	1
me1150670	631	1
me2150748	631	1
mt5110585	631	1
smf176567	631	1
smf176575	631	1
smf176584	631	1
smf176596	631	1
smf186545	631	1
smf186546	631	1
smf186550	631	1
smf186555	631	1
smf186559	631	1
smf186560	631	1
smf186561	631	1
smf186566	631	1
smf186567	631	1
smf186568	631	1
smf186575	631	1
smf186577	631	1
smf186578	631	1
smf186579	631	1
smf186581	631	1
smf186582	631	1
smf186588	631	1
smf186591	631	1
smf186592	631	1
smf186604	631	1
smf186608	631	1
smf186612	631	1
smf186615	631	1
smf186616	631	1
smf186622	631	1
smf186624	631	1
smf186626	631	1
smf186628	631	1
smt186597	631	1
smz158212	631	1
tt1150892	631	1
tt1160854	631	1
ch1150089	632	1
cs5140286	632	1
cs5140288	632	1
me2150724	632	1
mt5110585	632	1
smf176571	632	1
smf176578	632	1
smf176584	632	1
smf176592	632	1
smf176603	632	1
smf176608	632	1
smf176681	632	1
ch1150089	633	1
cs5140286	633	1
ee1150432	633	1
ee3150524	633	1
ee3150525	633	1
ee3150531	633	1
ee3150544	633	1
me1150642	633	1
me1150652	633	1
me2150724	633	1
me2150748	633	1
me2150763	633	1
mt5110585	633	1
smf176571	633	1
smf176575	633	1
smf176578	633	1
smf176581	633	1
smf176582	633	1
smf176584	633	1
smf176596	633	1
smf176597	633	1
smf176599	633	1
smf176601	633	1
smf176603	633	1
smf176625	633	1
smf176654	633	1
smf176670	633	1
smf176681	633	1
ee3160161	634	1
mt1150319	634	1
mt1150586	634	1
mt1150616	634	1
mt1160633	634	1
mt6150358	634	1
mt6150555	634	1
mt6150567	634	1
mt6150569	634	1
mt6160653	634	1
mt6160654	634	1
ph1160540	634	1
mt1140045	635	1
mt1140581	635	1
mt1150182	635	1
mt1150319	635	1
mt1150375	635	1
mt1150560	635	1
mt1150581	635	1
mt1150582	635	1
mt1150583	635	1
mt1150584	635	1
mt1150585	635	1
mt1150586	635	1
mt1150587	635	1
mt1150588	635	1
mt1150589	635	1
mt1150591	635	1
mt1150592	635	1
mt1150593	635	1
mt1150594	635	1
mt1150595	635	1
mt1150596	635	1
mt1150597	635	1
mt1150598	635	1
mt1150599	635	1
mt1150601	635	1
mt1150602	635	1
mt1150603	635	1
mt1150604	635	1
mt1150605	635	1
mt1150606	635	1
mt1150607	635	1
mt1150608	635	1
mt1150609	635	1
mt1150610	635	1
mt1150611	635	1
mt1150612	635	1
mt1150613	635	1
mt1150614	635	1
mt1150615	635	1
mt1150616	635	1
mt1150617	635	1
mt1150725	635	1
mt1150870	635	1
mas167104	636	1
mas177061	636	1
mas177063	636	1
mas177064	636	1
mas177067	636	1
mas177070	636	1
mas177074	636	1
mas177077	636	1
mas177078	636	1
mas177082	636	1
mas177084	636	1
mas177095	636	1
mas177096	636	1
mas177098	636	1
mas177101	636	1
mas177102	636	1
mas177103	636	1
mas177105	636	1
mas177106	636	1
mas177110	636	1
mas177114	636	1
mt5110600	637	1
mt5110605	638	1
mt6140362	638	1
mt6140502	638	1
mt6140551	638	1
mt6140553	638	1
mt6140555	638	1
mt6140557	638	1
mt6140559	638	1
mt6140560	638	1
mt6140561	638	1
mt6140562	638	1
mt6140563	638	1
mt6140564	638	1
mt6140566	638	1
mt6140567	638	1
mt6140568	638	1
mt6140569	638	1
mt6140570	638	1
mt6140571	638	1
mt6140663	638	1
bb1160065	639	1
bb1180001	639	1
bb1180002	639	1
bb1180004	639	1
bb1180005	639	1
bb1180006	639	1
bb1180008	639	1
bb1180012	639	1
bb1180016	639	1
bb1180017	639	1
bb1180019	639	1
bb1180020	639	1
bb1180021	639	1
bb1180023	639	1
bb1180024	639	1
bb1180025	639	1
bb1180029	639	1
bb1180030	639	1
bb1180031	639	1
bb1180032	639	1
bb1180034	639	1
bb1180036	639	1
bb1180037	639	1
bb1180038	639	1
bb1180039	639	1
bb1180041	639	1
bb1180042	639	1
bb1180044	639	1
bb1180045	639	1
bb1180046	639	1
bb5140011	639	1
bb5180051	639	1
bb5180052	639	1
bb5180053	639	1
bb5180054	639	1
bb5180056	639	1
bb5180057	639	1
bb5180058	639	1
bb5180060	639	1
bb5180063	639	1
bb5180064	639	1
bb5180066	639	1
ce1130384	639	1
ce1130386	639	1
ce1140333	639	1
ce1160256	639	1
ce1160303	639	1
ce1180074	639	1
ce1180076	639	1
ce1180078	639	1
ce1180079	639	1
ce1180083	639	1
ce1180084	639	1
ce1180085	639	1
ce1180086	639	1
ce1180090	639	1
ce1180094	639	1
ce1180095	639	1
ce1180101	639	1
ce1180104	639	1
ce1180106	639	1
ce1180108	639	1
ce1180110	639	1
ce1180112	639	1
ce1180117	639	1
ce1180118	639	1
ce1180120	639	1
ce1180124	639	1
ce1180132	639	1
ce1180133	639	1
ce1180141	639	1
ce1180146	639	1
ce1180148	639	1
ce1180149	639	1
ce1180150	639	1
ce1180151	639	1
ce1180154	639	1
ce1180157	639	1
ce1180158	639	1
ce1180163	639	1
ce1180164	639	1
ce1180165	639	1
ce1180167	639	1
ce1180168	639	1
ce1180169	639	1
ce1180177	639	1
ch1130080	639	1
ch1150085	639	1
ch1150115	639	1
ch1180187	639	1
ch1180189	639	1
ch1180191	639	1
ch1180193	639	1
ch1180194	639	1
ch1180195	639	1
ch1180197	639	1
ch1180199	639	1
ch1180200	639	1
ch1180201	639	1
ch1180202	639	1
ch1180203	639	1
ch1180205	639	1
ch1180208	639	1
ch1180210	639	1
ch1180211	639	1
ch1180213	639	1
ch1180214	639	1
ch1180215	639	1
ch1180216	639	1
ch1180218	639	1
ch1180220	639	1
ch1180221	639	1
ch1180225	639	1
ch1180227	639	1
ch1180229	639	1
ch1180230	639	1
ch1180234	639	1
ch1180239	639	1
ch1180242	639	1
ch1180247	639	1
ch1180248	639	1
ch1180249	639	1
ch1180250	639	1
ch1180251	639	1
ch1180252	639	1
ch1180253	639	1
ch1180254	639	1
ch1180255	639	1
ch1180257	639	1
ch1180259	639	1
ch1180260	639	1
ch1180261	639	1
ch7180271	639	1
ch7180272	639	1
ch7180277	639	1
ch7180278	639	1
ch7180279	639	1
ch7180280	639	1
ch7180281	639	1
ch7180282	639	1
ch7180285	639	1
ch7180287	639	1
ch7180288	639	1
ch7180290	639	1
ch7180293	639	1
ch7180295	639	1
ch7180296	639	1
ch7180297	639	1
ch7180299	639	1
ch7180301	639	1
ch7180302	639	1
ch7180304	639	1
ch7180305	639	1
ch7180306	639	1
ch7180311	639	1
ch7180315	639	1
ch7180317	639	1
cs1140216	639	1
cs1180322	639	1
cs1180323	639	1
cs1180327	639	1
cs1180330	639	1
cs1180332	639	1
cs1180334	639	1
cs1180335	639	1
cs1180340	639	1
cs1180344	639	1
cs1180345	639	1
cs1180346	639	1
cs1180348	639	1
cs1180350	639	1
cs1180351	639	1
cs1180355	639	1
cs1180360	639	1
cs1180362	639	1
cs1180366	639	1
cs1180370	639	1
cs1180372	639	1
cs1180373	639	1
cs1180374	639	1
cs1180377	639	1
cs1180380	639	1
cs1180381	639	1
cs1180385	639	1
cs1180386	639	1
cs1180389	639	1
cs1180390	639	1
cs1180392	639	1
cs1180393	639	1
cs1180394	639	1
cs1180395	639	1
cs1180397	639	1
cs5180401	639	1
cs5180402	639	1
cs5180403	639	1
cs5180404	639	1
cs5180405	639	1
cs5180408	639	1
cs5180412	639	1
cs5180413	639	1
cs5180419	639	1
cs5180420	639	1
cs5180422	639	1
cs5180425	639	1
cs5180426	639	1
ee1180433	639	1
ee1180434	639	1
ee1180436	639	1
ee1180437	639	1
ee1180439	639	1
ee1180441	639	1
ee1180443	639	1
ee1180444	639	1
ee1180446	639	1
ee1180447	639	1
ee1180452	639	1
ee1180454	639	1
ee1180456	639	1
ee1180458	639	1
ee1180459	639	1
ee1180460	639	1
ee1180467	639	1
ee1180468	639	1
ee1180469	639	1
ee1180470	639	1
ee1180473	639	1
ee1180476	639	1
ee1180482	639	1
ee1180483	639	1
ee1180485	639	1
ee1180486	639	1
ee1180489	639	1
ee1180491	639	1
ee1180492	639	1
ee1180496	639	1
ee1180497	639	1
ee1180504	639	1
ee1180505	639	1
ee1180506	639	1
ee1180509	639	1
ee1180511	639	1
ee3140526	639	1
ee3180521	639	1
ee3180523	639	1
ee3180524	639	1
ee3180525	639	1
ee3180527	639	1
ee3180528	639	1
ee3180530	639	1
ee3180531	639	1
ee3180533	639	1
ee3180535	639	1
ee3180541	639	1
ee3180542	639	1
ee3180545	639	1
ee3180546	639	1
ee3180547	639	1
ee3180549	639	1
ee3180553	639	1
ee3180554	639	1
ee3180556	639	1
ee3180557	639	1
ee3180560	639	1
ee3180562	639	1
ee3180563	639	1
ee3180565	639	1
ee3180569	639	1
me1170563	639	1
me1180581	639	1
me1180582	639	1
me1180584	639	1
me1180588	639	1
me1180589	639	1
me1180590	639	1
me1180592	639	1
me1180597	639	1
me1180599	639	1
me1180600	639	1
me1180603	639	1
me1180604	639	1
me1180606	639	1
me1180608	639	1
me1180611	639	1
me1180612	639	1
me1180614	639	1
me1180615	639	1
me1180616	639	1
me1180622	639	1
me1180624	639	1
me1180626	639	1
me1180627	639	1
me1180628	639	1
me1180630	639	1
me1180631	639	1
me1180633	639	1
me1180634	639	1
me1180641	639	1
me1180644	639	1
me1180645	639	1
me1180650	639	1
me1180651	639	1
me1180654	639	1
me1180656	639	1
me1180658	639	1
me2160799	639	1
me2170678	639	1
me2170842	639	1
me2180661	639	1
me2180663	639	1
me2180664	639	1
me2180666	639	1
me2180668	639	1
me2180670	639	1
me2180672	639	1
me2180674	639	1
me2180675	639	1
me2180676	639	1
me2180678	639	1
me2180679	639	1
me2180681	639	1
me2180682	639	1
me2180687	639	1
me2180688	639	1
me2180690	639	1
me2180691	639	1
me2180692	639	1
me2180694	639	1
me2180695	639	1
me2180696	639	1
me2180698	639	1
me2180699	639	1
me2180700	639	1
me2180701	639	1
me2180703	639	1
me2180706	639	1
me2180707	639	1
me2180709	639	1
me2180712	639	1
me2180713	639	1
me2180715	639	1
me2180716	639	1
me2180717	639	1
me2180718	639	1
me2180719	639	1
me2180722	639	1
me2180723	639	1
me2180725	639	1
me2180726	639	1
me2180728	639	1
me2180730	639	1
me2180732	639	1
me2180733	639	1
me2180736	639	1
mt1180738	639	1
mt1180739	639	1
mt1180742	639	1
mt1180744	639	1
mt1180746	639	1
mt1180748	639	1
mt1180755	639	1
mt1180757	639	1
mt1180758	639	1
mt1180760	639	1
mt1180762	639	1
mt1180770	639	1
mt6180777	639	1
mt6180783	639	1
mt6180785	639	1
mt6180790	639	1
mt6180793	639	1
mt6180794	639	1
mt6180795	639	1
mt6180797	639	1
ph1150836	639	1
ph1160585	639	1
ph1160592	639	1
ph1160597	639	1
ph1170852	639	1
ph1180801	639	1
ph1180802	639	1
ph1180803	639	1
ph1180810	639	1
ph1180812	639	1
ph1180813	639	1
ph1180814	639	1
ph1180817	639	1
ph1180820	639	1
ph1180821	639	1
ph1180822	639	1
ph1180825	639	1
ph1180826	639	1
ph1180827	639	1
ph1180828	639	1
ph1180830	639	1
ph1180831	639	1
ph1180832	639	1
ph1180833	639	1
ph1180836	639	1
ph1180838	639	1
ph1180839	639	1
ph1180843	639	1
ph1180844	639	1
ph1180845	639	1
ph1180846	639	1
ph1180848	639	1
ph1180850	639	1
ph1180851	639	1
ph1180852	639	1
ph1180854	639	1
ph1180858	639	1
ph1180859	639	1
ph1180860	639	1
tt1130911	639	1
tt1150855	639	1
tt1150887	639	1
tt1150913	639	1
tt1150916	639	1
tt1170895	639	1
tt1180866	639	1
tt1180872	639	1
tt1180874	639	1
tt1180875	639	1
tt1180876	639	1
tt1180877	639	1
tt1180879	639	1
tt1180881	639	1
tt1180882	639	1
tt1180887	639	1
tt1180888	639	1
tt1180889	639	1
tt1180890	639	1
tt1180892	639	1
tt1180894	639	1
tt1180896	639	1
tt1180897	639	1
tt1180900	639	1
tt1180901	639	1
tt1180903	639	1
tt1180905	639	1
tt1180906	639	1
tt1180910	639	1
tt1180911	639	1
tt1180912	639	1
tt1180915	639	1
tt1180920	639	1
tt1180921	639	1
tt1180922	639	1
tt1180923	639	1
tt1180925	639	1
tt1180927	639	1
tt1180928	639	1
tt1180930	639	1
tt1180933	639	1
tt1180934	639	1
tt1180936	639	1
tt1180939	639	1
tt1180940	639	1
tt1180946	639	1
tt1180947	639	1
tt1180950	639	1
tt1180951	639	1
tt1180952	639	1
tt1180954	639	1
tt1180955	639	1
tt1180956	639	1
tt1180960	639	1
tt1180962	639	1
tt1180963	639	1
tt1180964	639	1
tt1180965	639	1
tt1180967	639	1
tt1180968	639	1
tt1180969	639	1
tt1180975	639	1
bb1170036	640	1
bb1180003	640	1
bb1180007	640	1
bb1180009	640	1
bb1180010	640	1
bb1180011	640	1
bb1180013	640	1
bb1180014	640	1
bb1180015	640	1
bb1180018	640	1
bb1180022	640	1
bb1180026	640	1
bb1180027	640	1
bb1180028	640	1
bb1180033	640	1
bb1180040	640	1
bb1180043	640	1
bb5180055	640	1
bb5180059	640	1
bb5180061	640	1
bb5180065	640	1
ce1130384	640	1
ce1140395	640	1
ce1150318	640	1
ce1180071	640	1
ce1180072	640	1
ce1180073	640	1
ce1180075	640	1
ce1180077	640	1
ce1180080	640	1
ce1180081	640	1
ce1180082	640	1
ce1180087	640	1
ce1180088	640	1
ce1180089	640	1
ce1180091	640	1
ce1180092	640	1
ce1180093	640	1
ce1180096	640	1
ce1180097	640	1
ce1180098	640	1
ce1180099	640	1
ce1180100	640	1
ce1180102	640	1
ce1180103	640	1
ce1180105	640	1
ce1180107	640	1
ce1180109	640	1
ce1180111	640	1
ce1180113	640	1
ce1180114	640	1
ce1180115	640	1
ce1180116	640	1
ce1180119	640	1
ce1180121	640	1
ce1180122	640	1
ce1180123	640	1
ce1180125	640	1
ce1180126	640	1
ce1180127	640	1
ce1180128	640	1
ce1180129	640	1
ce1180130	640	1
ce1180131	640	1
ce1180134	640	1
ce1180135	640	1
ce1180137	640	1
ce1180138	640	1
ce1180139	640	1
ce1180140	640	1
ce1180142	640	1
ce1180143	640	1
ce1180144	640	1
ce1180145	640	1
ce1180147	640	1
ce1180152	640	1
ce1180153	640	1
ce1180155	640	1
ce1180156	640	1
ce1180159	640	1
ce1180160	640	1
ce1180161	640	1
ce1180162	640	1
ce1180166	640	1
ce1180170	640	1
ce1180171	640	1
ce1180172	640	1
ce1180173	640	1
ce1180174	640	1
ce1180175	640	1
ce1180176	640	1
ch1130119	640	1
ch1150078	640	1
ch1150106	640	1
ch1170230	640	1
ch1180186	640	1
ch1180188	640	1
ch1180190	640	1
ch1180192	640	1
ch1180196	640	1
ch1180198	640	1
ch1180204	640	1
ch1180206	640	1
ch1180207	640	1
ch1180209	640	1
ch1180217	640	1
ch1180219	640	1
ch1180222	640	1
ch1180223	640	1
ch1180224	640	1
ch1180226	640	1
ch1180228	640	1
ch1180231	640	1
ch1180232	640	1
ch1180233	640	1
ch1180235	640	1
ch1180236	640	1
ch1180237	640	1
ch1180238	640	1
ch1180241	640	1
ch1180243	640	1
ch1180244	640	1
ch1180245	640	1
ch1180246	640	1
ch1180256	640	1
ch1180258	640	1
ch7140166	640	1
ch7170315	640	1
ch7180273	640	1
ch7180274	640	1
ch7180275	640	1
ch7180276	640	1
ch7180283	640	1
ch7180284	640	1
ch7180289	640	1
ch7180291	640	1
ch7180294	640	1
ch7180298	640	1
ch7180300	640	1
ch7180303	640	1
ch7180307	640	1
ch7180308	640	1
ch7180309	640	1
ch7180310	640	1
ch7180312	640	1
ch7180313	640	1
ch7180314	640	1
ch7180316	640	1
cs1180321	640	1
cs1180324	640	1
cs1180325	640	1
cs1180326	640	1
cs1180328	640	1
cs1180329	640	1
cs1180331	640	1
cs1180333	640	1
cs1180336	640	1
cs1180337	640	1
cs1180338	640	1
cs1180339	640	1
cs1180341	640	1
cs1180342	640	1
cs1180343	640	1
cs1180347	640	1
cs1180349	640	1
cs1180352	640	1
cs1180353	640	1
cs1180354	640	1
cs1180356	640	1
cs1180357	640	1
cs1180358	640	1
cs1180359	640	1
cs1180361	640	1
cs1180363	640	1
cs1180364	640	1
cs1180365	640	1
cs1180367	640	1
cs1180368	640	1
cs1180369	640	1
cs1180371	640	1
cs1180375	640	1
cs1180376	640	1
cs1180378	640	1
cs1180379	640	1
cs1180382	640	1
cs1180383	640	1
cs1180384	640	1
cs1180387	640	1
cs1180388	640	1
cs1180391	640	1
cs1180396	640	1
cs5180406	640	1
cs5180407	640	1
cs5180410	640	1
cs5180411	640	1
cs5180414	640	1
cs5180415	640	1
cs5180416	640	1
cs5180417	640	1
cs5180418	640	1
cs5180421	640	1
cs5180423	640	1
cs5180424	640	1
ee1180431	640	1
ee1180432	640	1
ee1180435	640	1
ee1180438	640	1
ee1180440	640	1
ee1180442	640	1
ee1180445	640	1
ee1180448	640	1
ee1180449	640	1
ee1180450	640	1
ee1180451	640	1
ee1180453	640	1
ee1180455	640	1
ee1180457	640	1
ee1180461	640	1
ee1180462	640	1
ee1180463	640	1
ee1180464	640	1
ee1180465	640	1
ee1180466	640	1
ee1180471	640	1
ee1180472	640	1
ee1180474	640	1
ee1180475	640	1
ee1180477	640	1
ee1180478	640	1
ee1180479	640	1
ee1180480	640	1
ee1180481	640	1
ee1180484	640	1
ee1180487	640	1
ee1180488	640	1
ee1180490	640	1
ee1180493	640	1
ee1180494	640	1
ee1180495	640	1
ee1180498	640	1
ee1180499	640	1
ee1180500	640	1
ee1180501	640	1
ee1180502	640	1
ee1180503	640	1
ee1180507	640	1
ee1180508	640	1
ee1180510	640	1
ee1180512	640	1
ee1180513	640	1
ee1180514	640	1
ee1180515	640	1
ee3180522	640	1
ee3180526	640	1
ee3180529	640	1
ee3180532	640	1
ee3180534	640	1
ee3180536	640	1
ee3180537	640	1
ee3180538	640	1
ee3180539	640	1
ee3180540	640	1
ee3180543	640	1
ee3180544	640	1
ee3180548	640	1
ee3180550	640	1
ee3180551	640	1
ee3180552	640	1
ee3180555	640	1
ee3180558	640	1
ee3180559	640	1
ee3180561	640	1
ee3180564	640	1
ee3180566	640	1
ee3180567	640	1
ee3180568	640	1
me1100745	640	1
me1160728	640	1
me1180583	640	1
me1180585	640	1
me1180586	640	1
me1180587	640	1
me1180591	640	1
me1180593	640	1
me1180594	640	1
me1180595	640	1
me1180596	640	1
me1180598	640	1
me1180601	640	1
me1180602	640	1
me1180605	640	1
me1180607	640	1
me1180609	640	1
me1180610	640	1
me1180613	640	1
me1180617	640	1
me1180618	640	1
me1180619	640	1
me1180620	640	1
me1180621	640	1
me1180623	640	1
me1180625	640	1
me1180629	640	1
me1180632	640	1
me1180635	640	1
me1180636	640	1
me1180637	640	1
me1180638	640	1
me1180639	640	1
me1180640	640	1
me1180642	640	1
me1180643	640	1
me1180646	640	1
me1180647	640	1
me1180648	640	1
me1180649	640	1
me1180652	640	1
me1180653	640	1
me1180655	640	1
me1180657	640	1
me2150723	640	1
me2150743	640	1
me2160808	640	1
me2170659	640	1
me2180665	640	1
me2180667	640	1
me2180669	640	1
me2180671	640	1
me2180673	640	1
me2180677	640	1
me2180680	640	1
me2180684	640	1
me2180685	640	1
me2180686	640	1
me2180689	640	1
me2180693	640	1
me2180697	640	1
me2180702	640	1
me2180704	640	1
me2180705	640	1
me2180708	640	1
me2180710	640	1
me2180711	640	1
me2180714	640	1
me2180720	640	1
me2180721	640	1
me2180724	640	1
me2180727	640	1
me2180729	640	1
me2180731	640	1
me2180734	640	1
me2180735	640	1
mt1180736	640	1
mt1180737	640	1
mt1180740	640	1
mt1180741	640	1
mt1180743	640	1
mt1180745	640	1
mt1180747	640	1
mt1180749	640	1
mt1180750	640	1
mt1180751	640	1
mt1180752	640	1
mt1180753	640	1
mt1180754	640	1
mt1180756	640	1
mt1180759	640	1
mt1180761	640	1
mt1180763	640	1
mt1180764	640	1
mt1180765	640	1
mt1180766	640	1
mt1180767	640	1
mt1180768	640	1
mt1180769	640	1
mt1180771	640	1
mt1180772	640	1
mt1180773	640	1
mt1180774	640	1
mt6180776	640	1
mt6180778	640	1
mt6180779	640	1
mt6180780	640	1
mt6180781	640	1
mt6180782	640	1
mt6180784	640	1
mt6180786	640	1
mt6180787	640	1
mt6180788	640	1
mt6180789	640	1
mt6180791	640	1
mt6180792	640	1
mt6180796	640	1
mt6180798	640	1
ph1110846	640	1
ph1150816	640	1
ph1160588	640	1
ph1180804	640	1
ph1180805	640	1
ph1180806	640	1
ph1180808	640	1
ph1180809	640	1
ph1180811	640	1
ph1180815	640	1
ph1180816	640	1
ph1180818	640	1
ph1180819	640	1
ph1180823	640	1
ph1180824	640	1
ph1180829	640	1
ph1180834	640	1
ph1180835	640	1
ph1180837	640	1
ph1180840	640	1
ph1180841	640	1
ph1180842	640	1
ph1180847	640	1
ph1180849	640	1
ph1180853	640	1
ph1180855	640	1
ph1180856	640	1
ph1180857	640	1
tt1150944	640	1
tt1180867	640	1
tt1180868	640	1
tt1180869	640	1
tt1180871	640	1
tt1180873	640	1
tt1180878	640	1
tt1180880	640	1
tt1180883	640	1
tt1180884	640	1
tt1180885	640	1
tt1180886	640	1
tt1180895	640	1
tt1180898	640	1
tt1180899	640	1
tt1180904	640	1
tt1180907	640	1
tt1180908	640	1
tt1180909	640	1
tt1180913	640	1
tt1180914	640	1
tt1180916	640	1
tt1180917	640	1
tt1180918	640	1
tt1180919	640	1
tt1180924	640	1
tt1180926	640	1
tt1180929	640	1
tt1180931	640	1
tt1180935	640	1
tt1180937	640	1
tt1180938	640	1
tt1180941	640	1
tt1180942	640	1
tt1180943	640	1
tt1180944	640	1
tt1180945	640	1
tt1180948	640	1
tt1180949	640	1
tt1180953	640	1
tt1180957	640	1
tt1180958	640	1
tt1180959	640	1
tt1180961	640	1
tt1180966	640	1
tt1180970	640	1
tt1180971	640	1
tt1180972	640	1
tt1180974	640	1
bb1150026	641	1
bb1150030	641	1
bb1150031	641	1
bb1150032	641	1
bb1150053	641	1
bb1150061	641	1
bb1160055	641	1
bb1160058	641	1
bb1160064	641	1
bb1160065	641	1
bb1170001	641	1
bb1170002	641	1
bb1170003	641	1
bb1170004	641	1
bb1170005	641	1
bb1170006	641	1
bb1170007	641	1
bb1170008	641	1
bb1170009	641	1
bb1170011	641	1
bb1170012	641	1
bb1170013	641	1
bb1170014	641	1
bb1170015	641	1
bb1170016	641	1
bb1170017	641	1
bb1170018	641	1
bb1170020	641	1
bb1170022	641	1
bb1170023	641	1
bb1170024	641	1
bb1170025	641	1
bb1170026	641	1
bb1170027	641	1
bb1170028	641	1
bb1170029	641	1
bb1170030	641	1
bb1170031	641	1
bb1170032	641	1
bb1170033	641	1
bb1170034	641	1
bb1170035	641	1
bb1170037	641	1
bb1170038	641	1
bb1170039	641	1
bb1170040	641	1
bb1170041	641	1
bb1170042	641	1
bb1170045	641	1
bb1170046	641	1
bb1170047	641	1
bb5130002	641	1
bb5130011	641	1
bb5140002	641	1
bb5140013	641	1
bb5150009	641	1
bb5150014	641	1
bb5160007	641	1
bb5160010	641	1
bb5160014	641	1
bb5160015	641	1
bb5170051	641	1
bb5170052	641	1
bb5170053	641	1
bb5170054	641	1
bb5170055	641	1
bb5170056	641	1
bb5170057	641	1
bb5170058	641	1
bb5170059	641	1
bb5170060	641	1
bb5170062	641	1
bb5170064	641	1
bb5170065	641	1
cs1170341	641	1
cs5170422	641	1
ee1160454	641	1
ee1160457	641	1
ee1160460	641	1
ee1160462	641	1
ee1160463	641	1
ee1160571	641	1
ee3150541	641	1
mt1140584	641	1
mt1150319	641	1
mt1150560	641	1
mt1160491	641	1
mt1160621	641	1
mt1160627	641	1
mt1160638	641	1
mt1160639	641	1
mt1160640	641	1
mt1170213	641	1
mt1170287	641	1
mt1170520	641	1
mt1170530	641	1
mt1170722	641	1
mt1170723	641	1
mt1170724	641	1
mt1170726	641	1
mt1170728	641	1
mt1170729	641	1
mt1170730	641	1
mt1170731	641	1
mt1170732	641	1
mt1170733	641	1
mt1170735	641	1
mt1170736	641	1
mt1170737	641	1
mt1170738	641	1
mt1170739	641	1
mt1170740	641	1
mt1170741	641	1
mt1170742	641	1
mt1170743	641	1
mt1170744	641	1
mt1170745	641	1
mt1170747	641	1
mt1170748	641	1
mt1170749	641	1
mt1170750	641	1
mt1170752	641	1
mt1170754	641	1
mt1170755	641	1
mt1170756	641	1
mt1170772	641	1
mt5120593	641	1
mt6150570	641	1
mt6160645	641	1
mt6160646	641	1
mt6160648	641	1
mt6160649	641	1
mt6160650	641	1
mt6160653	641	1
mt6160655	641	1
mt6160659	641	1
mt6160661	641	1
mt6160664	641	1
mt6170078	641	1
mt6170207	641	1
mt6170250	641	1
mt6170499	641	1
mt6170771	641	1
mt6170774	641	1
mt6170775	641	1
mt6170777	641	1
mt6170778	641	1
mt6170779	641	1
mt6170780	641	1
mt6170781	641	1
mt6170782	641	1
mt6170783	641	1
mt6170784	641	1
mt6170785	641	1
mt6170786	641	1
mt6170787	641	1
mt6170788	641	1
mt6170789	641	1
mt6170855	641	1
ph1160577	641	1
cs1140227	642	1
cs1150202	642	1
cs1150206	642	1
cs1150211	642	1
cs1150225	642	1
cs1150238	642	1
cs1150256	642	1
cs1150259	642	1
cs1150264	642	1
cs1150268	642	1
cs1150424	642	1
cs1150461	642	1
cs1160087	642	1
cs1160294	642	1
cs1160310	642	1
cs1160311	642	1
cs1160312	642	1
cs1160314	642	1
cs1160316	642	1
cs1160317	642	1
cs1160318	642	1
cs1160319	642	1
cs1160320	642	1
cs1160321	642	1
cs1160322	642	1
cs1160323	642	1
cs1160326	642	1
cs1160327	642	1
cs1160328	642	1
cs1160332	642	1
cs1160333	642	1
cs1160335	642	1
cs1160336	642	1
cs1160337	642	1
cs1160339	642	1
cs1160340	642	1
cs1160342	642	1
cs1160343	642	1
cs1160344	642	1
cs1160345	642	1
cs1160347	642	1
cs1160348	642	1
cs1160349	642	1
cs1160350	642	1
cs1160351	642	1
cs1160352	642	1
cs1160355	642	1
cs1160357	642	1
cs1160358	642	1
cs1160359	642	1
cs1160363	642	1
cs1160364	642	1
cs1160365	642	1
cs1160366	642	1
cs1160368	642	1
cs1160371	642	1
cs1160372	642	1
cs1160373	642	1
cs1160374	642	1
cs1160378	642	1
cs1160385	642	1
cs1160395	642	1
cs1160396	642	1
cs1160412	642	1
cs1160513	642	1
cs1160523	642	1
cs1160680	642	1
cs1160701	642	1
cs5140276	642	1
cs5140286	642	1
cs5140288	642	1
cs5140289	642	1
cs5140292	642	1
cs5150102	642	1
cs5150276	642	1
cs5150277	642	1
cs5150280	642	1
cs5150283	642	1
cs5150284	642	1
cs5150285	642	1
cs5150286	642	1
cs5150287	642	1
cs5150289	642	1
cs5150292	642	1
cs5150293	642	1
cs5150294	642	1
cs5150295	642	1
cs5150296	642	1
cs5160386	642	1
cs5160388	642	1
cs5160389	642	1
cs5160391	642	1
cs5160393	642	1
cs5160394	642	1
cs5160398	642	1
cs5160402	642	1
cs5160403	642	1
cs5160404	642	1
cs5160414	642	1
cs5160433	642	1
cs5160615	642	1
cs5160625	642	1
cs5160789	642	1
ee1150474	642	1
ee1160825	642	1
mt1140581	642	1
mt1140584	642	1
mt1150611	642	1
mt1160413	642	1
mt1160492	642	1
mt1160607	642	1
mt1160610	642	1
mt1160613	642	1
mt1160616	642	1
mt1160617	642	1
mt1160619	642	1
mt1160620	642	1
mt1160622	642	1
mt1160623	642	1
mt1160624	642	1
mt1160628	642	1
mt1160629	642	1
mt1160633	642	1
mt1160636	642	1
mt1160637	642	1
mt1160638	642	1
mt1160640	642	1
mt1170520	642	1
mt1170724	642	1
mt1170727	642	1
mt1170731	642	1
mt1170742	642	1
mt1170744	642	1
mt1170745	642	1
mt1170746	642	1
mt1170747	642	1
mt1170749	642	1
mt1170754	642	1
mt1170756	642	1
mt1170772	642	1
mt5110585	642	1
mt6130586	642	1
mt6130602	642	1
mt6150552	642	1
mt6150570	642	1
mt6160751	642	1
mt6170078	642	1
mt6170499	642	1
mt6170773	642	1
mt6170776	642	1
mt6170777	642	1
mt6170779	642	1
mt6170780	642	1
mt6170781	642	1
mt6170782	642	1
mt6170787	642	1
mt6170855	642	1
bb1150038	643	1
ch1160105	643	1
ch1160109	643	1
cs1170341	643	1
cs5170418	643	1
ee1130445	643	1
ee1130515	643	1
ee1150450	643	1
ee1170093	643	1
ee1170249	643	1
ee1170306	643	1
ee1170431	643	1
ee1170432	643	1
ee1170433	643	1
ee1170434	643	1
ee1170435	643	1
ee1170436	643	1
ee1170437	643	1
ee1170438	643	1
ee1170439	643	1
ee1170440	643	1
ee1170441	643	1
ee1170442	643	1
ee1170443	643	1
ee1170444	643	1
ee1170445	643	1
ee1170446	643	1
ee1170447	643	1
ee1170448	643	1
ee1170449	643	1
ee1170450	643	1
ee1170451	643	1
ee1170452	643	1
ee1170453	643	1
ee1170454	643	1
ee1170455	643	1
ee1170456	643	1
ee1170457	643	1
ee1170458	643	1
ee1170459	643	1
ee1170460	643	1
ee1170461	643	1
ee1170462	643	1
ee1170463	643	1
ee1170464	643	1
ee1170465	643	1
ee1170466	643	1
ee1170467	643	1
ee1170468	643	1
ee1170469	643	1
ee1170470	643	1
ee1170471	643	1
ee1170472	643	1
ee1170473	643	1
ee1170474	643	1
ee1170475	643	1
ee1170476	643	1
ee1170477	643	1
ee1170478	643	1
ee1170479	643	1
ee1170480	643	1
ee1170482	643	1
ee1170483	643	1
ee1170484	643	1
ee1170485	643	1
ee1170486	643	1
ee1170490	643	1
ee1170491	643	1
ee1170492	643	1
ee1170494	643	1
ee1170495	643	1
ee1170496	643	1
ee1170497	643	1
ee1170498	643	1
ee1170500	643	1
ee1170501	643	1
ee1170502	643	1
ee1170504	643	1
ee1170505	643	1
ee1170536	643	1
ee1170544	643	1
ee1170565	643	1
ee1170584	643	1
ee1170597	643	1
ee1170599	643	1
ee1170608	643	1
ee1170704	643	1
ee1170809	643	1
ee1170937	643	1
ee1170938	643	1
ee3130546	643	1
ee3130571	643	1
ee3150518	643	1
ee3150529	643	1
ee3150536	643	1
ee3150538	643	1
ee3160496	643	1
ee3160501	643	1
ee3160515	643	1
ee3160521	643	1
ee3160525	643	1
ee3160528	643	1
ee3160530	643	1
ee3160531	643	1
ee3160533	643	1
ee3170010	643	1
ee3170019	643	1
ee3170149	643	1
ee3170221	643	1
ee3170245	643	1
ee3170511	643	1
ee3170512	643	1
ee3170513	643	1
ee3170514	643	1
ee3170515	643	1
ee3170516	643	1
ee3170517	643	1
ee3170518	643	1
ee3170522	643	1
ee3170523	643	1
ee3170524	643	1
ee3170525	643	1
ee3170526	643	1
ee3170527	643	1
ee3170528	643	1
ee3170529	643	1
ee3170531	643	1
ee3170532	643	1
ee3170534	643	1
ee3170535	643	1
ee3170537	643	1
ee3170538	643	1
ee3170539	643	1
ee3170541	643	1
ee3170542	643	1
ee3170543	643	1
ee3170545	643	1
ee3170546	643	1
ee3170547	643	1
ee3170548	643	1
ee3170549	643	1
ee3170550	643	1
ee3170551	643	1
ee3170552	643	1
ee3170553	643	1
ee3170554	643	1
ee3170555	643	1
ee3170654	643	1
ee3170872	643	1
mt1160608	643	1
mt1160618	643	1
mt1160627	643	1
mt1160632	643	1
mt1160635	643	1
mt1160639	643	1
mt1170213	643	1
mt1170287	643	1
mt1170530	643	1
mt1170721	643	1
mt1170722	643	1
mt1170723	643	1
mt1170725	643	1
mt1170726	643	1
mt1170728	643	1
mt1170729	643	1
mt1170730	643	1
mt1170732	643	1
mt1170733	643	1
mt1170734	643	1
mt1170735	643	1
mt1170736	643	1
mt1170737	643	1
mt1170738	643	1
mt1170739	643	1
mt1170740	643	1
mt1170741	643	1
mt1170743	643	1
mt1170748	643	1
mt1170750	643	1
mt1170751	643	1
mt1170752	643	1
mt1170753	643	1
mt1170755	643	1
mt6140552	643	1
mt6160078	643	1
mt6160645	643	1
mt6160646	643	1
mt6160648	643	1
mt6160649	643	1
mt6160650	643	1
mt6160652	643	1
mt6160655	643	1
mt6160656	643	1
mt6160657	643	1
mt6160658	643	1
mt6160659	643	1
mt6160660	643	1
mt6160661	643	1
mt6160662	643	1
mt6160664	643	1
mt6160677	643	1
mt6170207	643	1
mt6170250	643	1
mt6170771	643	1
mt6170774	643	1
mt6170775	643	1
mt6170778	643	1
mt6170783	643	1
mt6170784	643	1
mt6170785	643	1
mt6170786	643	1
mt6170788	643	1
mt6170789	643	1
ph1150805	643	1
ph1150827	643	1
ph1160560	643	1
ph1160561	643	1
ph1160575	643	1
tt1150928	643	1
tt1160834	643	1
tt1170896	643	1
tt1170913	643	1
tt1170917	643	1
tt1170924	643	1
tt1170930	643	1
tt1170954	643	1
bb1150040	644	1
bb1160022	644	1
bb1160043	644	1
ce1150325	644	1
ce1160215	644	1
ce1160223	644	1
ch1150109	644	1
cs1120236	644	1
ee3150506	644	1
ee3150509	644	1
me1130654	644	1
me1130721	644	1
me1140633	644	1
me1140651	644	1
me1140667	644	1
me1150643	644	1
me1150674	644	1
me1160728	644	1
me1170021	644	1
me1170061	644	1
me1170158	644	1
me1170561	644	1
me1170562	644	1
me1170564	644	1
me1170566	644	1
me1170567	644	1
me1170568	644	1
me1170569	644	1
me1170570	644	1
me1170571	644	1
me1170572	644	1
me1170573	644	1
me1170574	644	1
me1170575	644	1
me1170576	644	1
me1170578	644	1
me1170579	644	1
me1170580	644	1
me1170581	644	1
me1170582	644	1
me1170583	644	1
me1170585	644	1
me1170586	644	1
me1170587	644	1
me1170588	644	1
me1170590	644	1
me1170591	644	1
me1170592	644	1
me1170593	644	1
me1170594	644	1
me1170595	644	1
me1170596	644	1
me1170598	644	1
me1170600	644	1
me1170601	644	1
me1170603	644	1
me1170604	644	1
me1170605	644	1
me1170606	644	1
me1170607	644	1
me1170609	644	1
me1170610	644	1
me1170611	644	1
me1170612	644	1
me1170613	644	1
me1170614	644	1
me1170615	644	1
me1170616	644	1
me1170617	644	1
me1170618	644	1
me1170619	644	1
me1170620	644	1
me1170621	644	1
me1170622	644	1
me1170623	644	1
me1170624	644	1
me1170625	644	1
me1170626	644	1
me1170627	644	1
me1170628	644	1
me1170651	644	1
me1170698	644	1
me1170702	644	1
me1170950	644	1
me1170960	644	1
me1170967	644	1
me2140721	644	1
me2140735	644	1
me2140761	644	1
me2140772	644	1
me2150716	644	1
me2150743	644	1
me2150751	644	1
me2150758	644	1
me2160779	644	1
me2160791	644	1
me2160798	644	1
me2160802	644	1
me2160804	644	1
me2160808	644	1
me2170641	644	1
me2170642	644	1
me2170643	644	1
me2170644	644	1
me2170645	644	1
me2170646	644	1
me2170647	644	1
me2170648	644	1
me2170649	644	1
me2170650	644	1
me2170652	644	1
me2170653	644	1
me2170655	644	1
me2170656	644	1
me2170657	644	1
me2170658	644	1
me2170660	644	1
me2170661	644	1
me2170662	644	1
me2170663	644	1
me2170664	644	1
me2170665	644	1
me2170666	644	1
me2170667	644	1
me2170668	644	1
me2170669	644	1
me2170670	644	1
me2170671	644	1
me2170672	644	1
me2170673	644	1
me2170674	644	1
me2170675	644	1
me2170676	644	1
me2170677	644	1
me2170678	644	1
me2170679	644	1
me2170680	644	1
me2170681	644	1
me2170683	644	1
me2170684	644	1
me2170685	644	1
me2170686	644	1
me2170687	644	1
me2170688	644	1
me2170689	644	1
me2170690	644	1
me2170691	644	1
me2170692	644	1
me2170693	644	1
me2170694	644	1
me2170695	644	1
me2170696	644	1
me2170697	644	1
me2170699	644	1
me2170700	644	1
me2170701	644	1
me2170703	644	1
me2170705	644	1
me2170706	644	1
me2170707	644	1
me2170842	644	1
ph1140840	644	1
ph1160543	644	1
ph1160549	644	1
tt1150853	644	1
tt1160896	644	1
ce1160292	645	1
cs1150207	645	1
cs1150237	645	1
me1150636	645	1
mt1160637	645	1
mt1160639	645	1
mt1160640	645	1
mt1170213	645	1
mt1170287	645	1
mt1170520	645	1
mt1170530	645	1
mt1170721	645	1
mt1170722	645	1
mt1170723	645	1
mt1170724	645	1
mt1170725	645	1
mt1170726	645	1
mt1170727	645	1
mt1170728	645	1
mt1170729	645	1
mt1170730	645	1
mt1170731	645	1
mt1170732	645	1
mt1170733	645	1
mt1170734	645	1
mt1170735	645	1
mt1170736	645	1
mt1170737	645	1
mt1170738	645	1
mt1170739	645	1
mt1170740	645	1
mt1170741	645	1
mt1170742	645	1
mt1170743	645	1
mt1170744	645	1
mt1170745	645	1
mt1170746	645	1
mt1170747	645	1
mt1170748	645	1
mt1170749	645	1
mt1170750	645	1
mt1170751	645	1
mt1170752	645	1
mt1170753	645	1
mt1170754	645	1
mt1170755	645	1
mt1170756	645	1
mt1170772	645	1
mt6130586	645	1
mt6140558	645	1
mt6160661	645	1
mt6170078	645	1
mt6170207	645	1
mt6170250	645	1
mt6170499	645	1
mt6170771	645	1
mt6170773	645	1
mt6170774	645	1
mt6170775	645	1
mt6170776	645	1
mt6170778	645	1
mt6170779	645	1
mt6170780	645	1
mt6170781	645	1
mt6170782	645	1
mt6170783	645	1
mt6170784	645	1
mt6170785	645	1
mt6170786	645	1
mt6170787	645	1
mt6170788	645	1
mt6170789	645	1
mt6170855	645	1
ph1150805	645	1
ph1170806	645	1
tt1170947	645	1
ch7170281	646	1
cs1150202	646	1
cs1150212	646	1
cs1150217	646	1
cs1150250	646	1
cs1150255	646	1
cs1150268	646	1
cs1160318	646	1
cs1160324	646	1
cs1160342	646	1
cs1160344	646	1
cs1160370	646	1
cs1170330	646	1
cs1170334	646	1
cs1170335	646	1
cs1170353	646	1
cs1170363	646	1
cs1170369	646	1
cs1170503	646	1
cs5150281	646	1
cs5170405	646	1
cs5170406	646	1
ee1150428	646	1
ee1150463	646	1
ee1150465	646	1
ee1150481	646	1
ee1150781	646	1
me1150383	646	1
me1150390	646	1
me1150644	646	1
me1150663	646	1
me1150675	646	1
me1150680	646	1
me1170564	646	1
me2170663	646	1
me2170679	646	1
mt1140045	646	1
mt1140584	646	1
mt1150375	646	1
mt1150582	646	1
mt1150583	646	1
mt1150586	646	1
mt1150591	646	1
mt1150593	646	1
mt1150597	646	1
mt1150601	646	1
mt1150602	646	1
mt1150604	646	1
mt1150607	646	1
mt1150610	646	1
mt1150611	646	1
mt1150612	646	1
mt1150614	646	1
mt1150615	646	1
mt1150617	646	1
mt1160492	646	1
mt1160582	646	1
mt1160605	646	1
mt1160606	646	1
mt1160607	646	1
mt1160608	646	1
mt1160609	646	1
mt1160610	646	1
mt1160611	646	1
mt1160618	646	1
mt1160621	646	1
mt1160627	646	1
mt1160632	646	1
mt1160634	646	1
mt1170725	646	1
mt1170746	646	1
mt1170749	646	1
mt1170752	646	1
mt1170772	646	1
mt5120616	646	1
mt6130581	646	1
mt6130582	646	1
mt6130608	646	1
mt6140564	646	1
mt6150113	646	1
mt6150373	646	1
mt6150551	646	1
mt6150559	646	1
mt6150561	646	1
mt6150562	646	1
mt6150563	646	1
mt6150564	646	1
mt6150565	646	1
mt6150567	646	1
mt6150569	646	1
mt6160078	646	1
mt6160645	646	1
mt6160646	646	1
mt6160648	646	1
mt6160649	646	1
mt6160650	646	1
mt6160659	646	1
mt6160662	646	1
mt6160677	646	1
mt6170777	646	1
bb1160033	647	1
ch7160162	647	1
cs1150237	647	1
ee1150442	647	1
ee1150443	647	1
ee1150454	647	1
ee1150455	647	1
ee1150463	647	1
ee1150465	647	1
ee1150479	647	1
ee1150481	647	1
ee1150488	647	1
ee1150490	647	1
ee1150494	647	1
ee1160411	647	1
ee1160421	647	1
ee1160427	647	1
ee1160437	647	1
ee3150505	647	1
ee3150506	647	1
ee3150510	647	1
ee3150544	647	1
mt1150560	647	1
mt1150588	647	1
mt1150602	647	1
mt1150603	647	1
mt1150606	647	1
mt1150608	647	1
mt1150612	647	1
mt1150615	647	1
mt1150616	647	1
mt1150725	647	1
mt1160268	647	1
mt1160413	647	1
mt1160491	647	1
mt1160492	647	1
mt1160546	647	1
mt1160582	647	1
mt1160605	647	1
mt1160606	647	1
mt1160607	647	1
mt1160609	647	1
mt1160610	647	1
mt1160611	647	1
mt1160613	647	1
mt1160614	647	1
mt1160616	647	1
mt1160617	647	1
mt1160619	647	1
mt1160620	647	1
mt1160621	647	1
mt1160622	647	1
mt1160623	647	1
mt1160624	647	1
mt1160626	647	1
mt1160628	647	1
mt1160629	647	1
mt1160630	647	1
mt1160631	647	1
mt1160633	647	1
mt1160634	647	1
mt1160636	647	1
mt1160637	647	1
mt1160638	647	1
mt1160647	647	1
mt5120593	647	1
mt6140556	647	1
mt6150552	647	1
mt6150553	647	1
mt6150559	647	1
mt6150564	647	1
mt6150570	647	1
mt6160651	647	1
mt6160653	647	1
mt6160654	647	1
mt6160751	647	1
ph1150812	647	1
mt1140581	648	1
mt1140584	648	1
mt1150319	648	1
mt1150375	648	1
mt1150560	648	1
mt1150581	648	1
mt1150582	648	1
mt1150583	648	1
mt1150584	648	1
mt1150586	648	1
mt1150588	648	1
mt1150589	648	1
mt1150591	648	1
mt1150592	648	1
mt1150593	648	1
mt1150595	648	1
mt1150597	648	1
mt1150598	648	1
mt1150601	648	1
mt1150602	648	1
mt1150604	648	1
mt1150605	648	1
mt1150606	648	1
mt1150608	648	1
mt1150610	648	1
mt1150611	648	1
mt1150612	648	1
mt1150613	648	1
mt1150614	648	1
mt1150616	648	1
mt1150617	648	1
mt1160268	648	1
mt1160413	648	1
mt1160491	648	1
mt1160492	648	1
mt1160546	648	1
mt1160605	648	1
mt1160606	648	1
mt1160607	648	1
mt1160608	648	1
mt1160609	648	1
mt1160610	648	1
mt1160611	648	1
mt1160613	648	1
mt1160614	648	1
mt1160616	648	1
mt1160617	648	1
mt1160618	648	1
mt1160619	648	1
mt1160620	648	1
mt1160621	648	1
mt1160622	648	1
mt1160624	648	1
mt1160626	648	1
mt1160627	648	1
mt1160628	648	1
mt1160629	648	1
mt1160630	648	1
mt1160631	648	1
mt1160632	648	1
mt1160633	648	1
mt1160635	648	1
mt1160636	648	1
mt1160638	648	1
mt5110585	648	1
mt6130581	648	1
mt6130602	648	1
mt6140556	648	1
mt6150373	648	1
mt6150551	648	1
mt6150557	648	1
mt6150558	648	1
mt6150561	648	1
mt6150562	648	1
mt6150563	648	1
mt6150565	648	1
mt6150567	648	1
mt6150569	648	1
mt6160645	648	1
mt6160646	648	1
mt6160648	648	1
mt6160649	648	1
mt6160650	648	1
mt6160655	648	1
mt6160656	648	1
mt6160658	648	1
mt6160659	648	1
mt6160660	648	1
mt6160662	648	1
mt6160677	648	1
mt6160751	648	1
mas157092	649	1
mas177062	649	1
mas177071	649	1
mas177076	649	1
mas177081	649	1
mas177087	649	1
mas177092	649	1
mas177099	649	1
mas177109	649	1
mas187057	649	1
mas187058	649	1
mas187059	649	1
mas187061	649	1
mas187062	649	1
mas187063	649	1
mas187064	649	1
mas187065	649	1
mas187066	649	1
mas187067	649	1
mas187068	649	1
mas187069	649	1
mas187070	649	1
mas187073	649	1
mas187074	649	1
mas187075	649	1
mas187076	649	1
mas187077	649	1
mas187078	649	1
mas187079	649	1
mas187080	649	1
mas187081	649	1
mas187082	649	1
mas187083	649	1
mas187084	649	1
mas187085	649	1
mas187086	649	1
mas187087	649	1
mas187089	649	1
mas187090	649	1
mas187091	649	1
mas187092	649	1
mas187093	649	1
mas187095	649	1
mas187096	649	1
mas187097	649	1
mas187098	649	1
mas187099	649	1
mas187100	649	1
mas187101	649	1
mas187102	649	1
mas187103	649	1
mas187104	649	1
mas187105	649	1
mas187106	649	1
mas187107	649	1
mas187109	649	1
mas187110	649	1
mas157092	650	1
mas177065	650	1
mas177087	650	1
mas177090	650	1
mas177092	650	1
mas177109	650	1
mas187057	650	1
mas187058	650	1
mas187059	650	1
mas187061	650	1
mas187062	650	1
mas187063	650	1
mas187064	650	1
mas187065	650	1
mas187066	650	1
mas187067	650	1
mas187068	650	1
mas187069	650	1
mas187070	650	1
mas187073	650	1
mas187074	650	1
mas187075	650	1
mas187076	650	1
mas187077	650	1
mas187078	650	1
mas187079	650	1
mas187080	650	1
mas187081	650	1
mas187082	650	1
mas187083	650	1
mas187084	650	1
mas187085	650	1
mas187086	650	1
mas187087	650	1
mas187089	650	1
mas187090	650	1
mas187091	650	1
mas187092	650	1
mas187093	650	1
mas187095	650	1
mas187096	650	1
mas187097	650	1
mas187098	650	1
mas187099	650	1
mas187100	650	1
mas187101	650	1
mas187102	650	1
mas187103	650	1
mas187104	650	1
mas187105	650	1
mas187106	650	1
mas187107	650	1
mas187109	650	1
mas187110	650	1
mas177062	651	1
mas177068	651	1
mas177069	651	1
mas177072	651	1
mas177073	651	1
mas177085	651	1
mas177087	651	1
mas177092	651	1
mas177097	651	1
mas177113	651	1
mas187057	651	1
mas187058	651	1
mas187059	651	1
mas187061	651	1
mas187062	651	1
mas187063	651	1
mas187064	651	1
mas187065	651	1
mas187066	651	1
mas187067	651	1
mas187068	651	1
mas187069	651	1
mas187070	651	1
mas187073	651	1
mas187074	651	1
mas187075	651	1
mas187076	651	1
mas187077	651	1
mas187078	651	1
mas187079	651	1
mas187080	651	1
mas187081	651	1
mas187082	651	1
mas187083	651	1
mas187084	651	1
mas187085	651	1
mas187086	651	1
mas187087	651	1
mas187089	651	1
mas187090	651	1
mas187091	651	1
mas187092	651	1
mas187093	651	1
mas187095	651	1
mas187096	651	1
mas187097	651	1
mas187098	651	1
mas187099	651	1
mas187100	651	1
mas187101	651	1
mas187102	651	1
mas187103	651	1
mas187104	651	1
mas187105	651	1
mas187106	651	1
mas187107	651	1
mas187109	651	1
mas187110	651	1
mas157092	652	1
mas177087	652	1
mas177092	652	1
mas187057	652	1
mas187058	652	1
mas187059	652	1
mas187061	652	1
mas187062	652	1
mas187063	652	1
mas187064	652	1
mas187065	652	1
mas187066	652	1
mas187067	652	1
mas187068	652	1
mas187069	652	1
mas187070	652	1
mas187073	652	1
mas187074	652	1
mas187075	652	1
mas187076	652	1
mas187077	652	1
mas187078	652	1
mas187079	652	1
mas187080	652	1
mas187081	652	1
mas187082	652	1
mas187083	652	1
mas187084	652	1
mas187085	652	1
mas187086	652	1
mas187087	652	1
mas187089	652	1
mas187090	652	1
mas187091	652	1
mas187092	652	1
mas187093	652	1
mas187095	652	1
mas187096	652	1
mas187097	652	1
mas187098	652	1
mas187099	652	1
mas187100	652	1
mas187101	652	1
mas187102	652	1
mas187103	652	1
mas187104	652	1
mas187105	652	1
mas187106	652	1
mas187107	652	1
mas187109	652	1
mas187110	652	1
mas157092	653	1
mas177087	653	1
mas177092	653	1
mas187057	653	1
mas187058	653	1
mas187059	653	1
mas187061	653	1
mas187062	653	1
mas187063	653	1
mas187064	653	1
mas187065	653	1
mas187066	653	1
mas187067	653	1
mas187068	653	1
mas187069	653	1
mas187070	653	1
mas187073	653	1
mas187074	653	1
mas187075	653	1
mas187076	653	1
mas187077	653	1
mas187078	653	1
mas187079	653	1
mas187080	653	1
mas187081	653	1
mas187082	653	1
mas187083	653	1
mas187084	653	1
mas187085	653	1
mas187086	653	1
mas187087	653	1
mas187089	653	1
mas187090	653	1
mas187091	653	1
mas187092	653	1
mas187093	653	1
mas187095	653	1
mas187096	653	1
mas187097	653	1
mas187098	653	1
mas187099	653	1
mas187100	653	1
mas187101	653	1
mas187102	653	1
mas187103	653	1
mas187104	653	1
mas187105	653	1
mas187106	653	1
mas187107	653	1
mas187109	653	1
mas187110	653	1
vst189744	653	1
vst189749	653	1
ee1150442	654	1
ee1150455	654	1
ee1150490	654	1
mas167062	654	1
mas177062	654	1
mas177065	654	1
mas177068	654	1
mas177075	654	1
mas177110	654	1
maz188445	654	1
mt1140581	654	1
mt1140584	654	1
mt1150584	654	1
mt1150586	654	1
mt1150588	654	1
mt1150589	654	1
mt1150596	654	1
mt1150597	654	1
mt1150598	654	1
mt1150606	654	1
mt1150607	654	1
mt1150611	654	1
mt1150612	654	1
mt1150613	654	1
mt1150616	654	1
mt1160582	654	1
mt6130608	654	1
mt6140362	654	1
mt6140551	654	1
mt6140552	654	1
mt6140556	654	1
mt6140557	654	1
mt6140558	654	1
mt6140560	654	1
mt6140562	654	1
mt6140566	654	1
mt6140569	654	1
mt6140570	654	1
mt6140571	654	1
mt6150551	654	1
mt6150553	654	1
mt6150554	654	1
mt6150556	654	1
mt6150558	654	1
mt6150561	654	1
mt6150563	654	1
mt6150566	654	1
mt6150569	654	1
mt6160078	654	1
tt1150940	654	1
ch1150077	655	1
cs1150201	655	1
cs1150202	655	1
cs1150203	655	1
cs1150204	655	1
cs1150206	655	1
cs1150209	655	1
cs1150212	655	1
cs1150217	655	1
cs1150246	655	1
ee1150469	655	1
ee1150473	655	1
eet172291	655	1
mas157092	655	1
mas167062	655	1
mas177061	655	1
mas177062	655	1
mas177063	655	1
mas177064	655	1
mas177067	655	1
mas177069	655	1
mas177070	655	1
mas177071	655	1
mas177072	655	1
mas177073	655	1
mas177074	655	1
mas177075	655	1
mas177076	655	1
mas177078	655	1
mas177080	655	1
mas177081	655	1
mas177082	655	1
mas177083	655	1
mas177084	655	1
mas177085	655	1
mas177086	655	1
mas177089	655	1
mas177090	655	1
mas177091	655	1
mas177094	655	1
mas177097	655	1
mas177098	655	1
mas177099	655	1
mas177100	655	1
mas177101	655	1
mas177102	655	1
mas177104	655	1
mas177105	655	1
mas177106	655	1
mas177107	655	1
mas177108	655	1
mas177109	655	1
mas177110	655	1
mas177111	655	1
mas177113	655	1
mas177114	655	1
maz178433	655	1
maz178436	655	1
maz188235	655	1
maz188253	655	1
maz188255	655	1
maz188260	655	1
maz188444	655	1
maz188447	655	1
maz188450	655	1
mt1140045	655	1
mt1140584	655	1
mt1150182	655	1
mt1150581	655	1
mt1150582	655	1
mt1150589	655	1
mt1150591	655	1
mt1150592	655	1
mt1150593	655	1
mt1150595	655	1
mt1150598	655	1
mt1150599	655	1
mt1150602	655	1
mt1150603	655	1
mt1150604	655	1
mt1150605	655	1
mt1150606	655	1
mt1150607	655	1
mt1150608	655	1
mt1150609	655	1
mt1150610	655	1
mt1150611	655	1
mt1150613	655	1
mt1150614	655	1
mt1150725	655	1
mt1150870	655	1
mt1160582	655	1
mt1160613	655	1
mt1160619	655	1
mt1160621	655	1
mt1160622	655	1
mt1160637	655	1
mt5110585	655	1
mt5120605	655	1
mt5120616	655	1
mt6130581	655	1
mt6130582	655	1
mt6130586	655	1
mt6130602	655	1
mt6130608	655	1
mt6140362	655	1
mt6140552	655	1
mt6140553	655	1
mt6140556	655	1
mt6140558	655	1
mt6140559	655	1
mt6140560	655	1
mt6140561	655	1
mt6140562	655	1
mt6140563	655	1
mt6140564	655	1
mt6140566	655	1
mt6140567	655	1
mt6140568	655	1
mt6140569	655	1
mt6140570	655	1
mt6140571	655	1
mt6140663	655	1
mt6150358	655	1
mt6150555	655	1
mt6150556	655	1
mt6150557	655	1
mt6150558	655	1
mt6160646	655	1
mt6160751	655	1
tt1150868	655	1
tt1150872	655	1
tt1150927	655	1
tt1150930	655	1
vst189736	655	1
vst189737	655	1
cs1150237	656	1
cs5140435	656	1
mas177065	656	1
mas177068	656	1
mas177077	656	1
mt1150560	656	1
mt1160268	656	1
mt1160491	656	1
mt1160546	656	1
mt1160605	656	1
mt1160606	656	1
mt1160608	656	1
mt1160609	656	1
mt1160611	656	1
mt1160614	656	1
mt1160618	656	1
mt1160626	656	1
mt1160631	656	1
mt1160635	656	1
mt1160647	656	1
mt5120593	656	1
mt6130583	656	1
mt6140551	656	1
mt6150113	656	1
mt6150373	656	1
mt6150551	656	1
mt6150553	656	1
mt6150554	656	1
mt6150559	656	1
mt6150561	656	1
mt6150562	656	1
mt6150564	656	1
mt6150566	656	1
mt6150567	656	1
mt6150569	656	1
mt6160078	656	1
mt6160645	656	1
mt6160648	656	1
mt6160650	656	1
mt6160651	656	1
mt6160652	656	1
mt6160653	656	1
mt6160654	656	1
mt6160655	656	1
mt6160656	656	1
mt6160657	656	1
mt6160658	656	1
mt6160659	656	1
mt6160660	656	1
mt6160662	656	1
mt6160664	656	1
mt6160677	656	1
mas157092	657	1
mas177061	657	1
mas177068	657	1
mas177069	657	1
mas177070	657	1
mas177071	657	1
mas177073	657	1
mas177076	657	1
mas177078	657	1
mas177080	657	1
mas177081	657	1
mas177083	657	1
mas177086	657	1
mas177095	657	1
mas177096	657	1
mas177101	657	1
mas177103	657	1
mas177104	657	1
mas177111	657	1
maz188254	657	1
maz188255	657	1
maz188258	657	1
maz188259	657	1
maz188260	657	1
maz188443	657	1
maz188446	657	1
maz188447	657	1
maz188448	657	1
maz188449	657	1
maz188450	657	1
maz188451	657	1
maz188452	657	1
mt1150615	657	1
mt6130608	657	1
vst189744	657	1
vst189749	657	1
ee1150494	658	1
mas177062	658	1
mas177063	658	1
mas177070	658	1
mas177072	658	1
mas177073	658	1
mas177075	658	1
mas177076	658	1
mas177078	658	1
mas177083	658	1
mas177085	658	1
mas177089	658	1
mas177090	658	1
mas177091	658	1
mas177094	658	1
mas177097	658	1
mas177099	658	1
mas177100	658	1
mas177101	658	1
mas177107	658	1
mas177108	658	1
mas177109	658	1
mas177113	658	1
maz188235	658	1
maz188253	658	1
maz188258	658	1
maz188259	658	1
maz188443	658	1
maz188446	658	1
maz188447	658	1
maz188448	658	1
maz188450	658	1
maz188451	658	1
mt1150182	658	1
mt1150587	658	1
mt1150599	658	1
mt1150606	658	1
mt6130581	658	1
mt6130582	658	1
mt6130608	658	1
mt6140560	658	1
mt6140566	658	1
mt6140569	658	1
mt6140570	658	1
mt6150373	658	1
vst189736	658	1
cs1150219	659	1
cs1150257	659	1
cs1150266	659	1
cs5150288	659	1
ee1150492	659	1
mas167062	659	1
mas177062	659	1
mas177065	659	1
mas177067	659	1
mas177069	659	1
mas177071	659	1
mas177072	659	1
mas177077	659	1
mas177078	659	1
mas177080	659	1
mas177081	659	1
mas177083	659	1
mas177085	659	1
mas177086	659	1
mas177089	659	1
mas177090	659	1
mas177091	659	1
mas177094	659	1
mas177097	659	1
mas177099	659	1
mas177100	659	1
mas177101	659	1
mas177102	659	1
mas177104	659	1
mas177105	659	1
mas177107	659	1
mas177108	659	1
mas177109	659	1
mas177110	659	1
mas177111	659	1
mas177113	659	1
mas177114	659	1
maz188444	659	1
me2150717	659	1
me2150755	659	1
mt1150584	659	1
mt1150588	659	1
mt1150594	659	1
mt1150596	659	1
mt1150605	659	1
mt1150613	659	1
mt1150616	659	1
mt1160413	659	1
mt1160613	659	1
mt1160614	659	1
mt1160617	659	1
mt5120593	659	1
mt6130583	659	1
mt6130602	659	1
mt6140553	659	1
mt6140558	659	1
mt6140567	659	1
mt6140663	659	1
mt6150553	659	1
mt6150554	659	1
mt6150556	659	1
mt6150557	659	1
mt6150558	659	1
mt6150566	659	1
mt6160651	659	1
mt6160654	659	1
mt6160751	659	1
vst189737	659	1
eet182561	660	1
mas177065	660	1
maz188445	660	1
mt1150560	660	1
mt1150605	660	1
mt1160268	660	1
mt1160413	660	1
mt1160491	660	1
mt1160492	660	1
mt1160546	660	1
mt1160582	660	1
mt1160605	660	1
mt1160606	660	1
mt1160607	660	1
mt1160609	660	1
mt1160611	660	1
mt1160613	660	1
mt1160614	660	1
mt1160616	660	1
mt1160617	660	1
mt1160618	660	1
mt1160619	660	1
mt1160620	660	1
mt1160621	660	1
mt1160622	660	1
mt1160623	660	1
mt1160626	660	1
mt1160627	660	1
mt1160628	660	1
mt1160629	660	1
mt1160630	660	1
mt1160631	660	1
mt1160632	660	1
mt1160633	660	1
mt1160637	660	1
mt1160647	660	1
mt5120593	660	1
mt6130583	660	1
mt6130602	660	1
mt6140556	660	1
mt6150559	660	1
mt6150561	660	1
mt6150564	660	1
mt6160078	660	1
mt6160645	660	1
mt6160646	660	1
mt6160648	660	1
mt6160649	660	1
mt6160650	660	1
mt6160651	660	1
mt6160652	660	1
mt6160653	660	1
mt6160654	660	1
mt6160655	660	1
mt6160656	660	1
mt6160657	660	1
mt6160658	660	1
mt6160659	660	1
mt6160660	660	1
mt6160662	660	1
mt6160664	660	1
mt6160677	660	1
mt6160751	660	1
mas167104	661	1
mas177075	661	1
mas177076	661	1
mas177095	661	1
maz188254	661	1
maz188255	661	1
maz188443	661	1
maz188446	661	1
maz188448	661	1
maz188449	661	1
maz188451	661	1
maz188452	661	1
vst189744	661	1
vst189749	661	1
mt1140584	662	1
mt1160640	662	1
mt1170213	662	1
mt1170287	662	1
mt1170520	662	1
mt1170530	662	1
mt1170721	662	1
mt1170722	662	1
mt1170723	662	1
mt1170724	662	1
mt1170725	662	1
mt1170726	662	1
mt1170727	662	1
mt1170728	662	1
mt1170729	662	1
mt1170730	662	1
mt1170731	662	1
mt1170732	662	1
mt1170733	662	1
mt1170734	662	1
mt1170735	662	1
mt1170736	662	1
mt1170737	662	1
mt1170738	662	1
mt1170739	662	1
mt1170740	662	1
mt1170741	662	1
mt1170742	662	1
mt1170743	662	1
mt1170744	662	1
mt1170745	662	1
mt1170746	662	1
mt1170747	662	1
mt1170748	662	1
mt1170749	662	1
mt1170750	662	1
mt1170751	662	1
mt1170752	662	1
mt1170753	662	1
mt1170754	662	1
mt1170755	662	1
mt1170756	662	1
mt1170772	662	1
mt5120593	662	1
mt6130586	662	1
mt6170078	662	1
mt6170207	662	1
mt6170250	662	1
mt6170499	662	1
mt6170771	662	1
mt6170774	662	1
mt6170775	662	1
mt6170776	662	1
mt6170777	662	1
mt6170778	662	1
mt6170779	662	1
mt6170780	662	1
mt6170781	662	1
mt6170782	662	1
mt6170783	662	1
mt6170784	662	1
mt6170785	662	1
mt6170786	662	1
mt6170787	662	1
mt6170788	662	1
mt6170789	662	1
mt6170855	662	1
bb1170036	663	1
bb1180001	663	1
bb1180002	663	1
bb1180003	663	1
bb1180004	663	1
bb1180005	663	1
bb1180006	663	1
bb1180007	663	1
bb1180008	663	1
bb1180009	663	1
bb1180010	663	1
bb1180011	663	1
bb1180012	663	1
bb1180013	663	1
bb1180014	663	1
bb1180015	663	1
bb1180016	663	1
bb1180017	663	1
bb1180018	663	1
bb1180019	663	1
bb1180020	663	1
bb1180021	663	1
bb1180022	663	1
bb1180023	663	1
bb1180024	663	1
bb1180025	663	1
bb1180026	663	1
bb1180027	663	1
bb1180028	663	1
bb1180029	663	1
bb1180030	663	1
bb1180031	663	1
bb1180032	663	1
bb1180033	663	1
bb1180034	663	1
bb1180036	663	1
bb1180037	663	1
bb1180038	663	1
bb1180039	663	1
bb1180040	663	1
bb1180041	663	1
bb1180042	663	1
bb1180043	663	1
bb1180044	663	1
bb1180045	663	1
bb1180046	663	1
bb5180051	663	1
bb5180052	663	1
bb5180053	663	1
bb5180054	663	1
bb5180055	663	1
bb5180056	663	1
bb5180057	663	1
bb5180058	663	1
bb5180059	663	1
bb5180060	663	1
bb5180061	663	1
bb5180063	663	1
bb5180064	663	1
bb5180065	663	1
bb5180066	663	1
ce1180071	663	1
ce1180072	663	1
ce1180073	663	1
ce1180074	663	1
ce1180075	663	1
ce1180076	663	1
ce1180077	663	1
ce1180078	663	1
ce1180079	663	1
ce1180080	663	1
ce1180081	663	1
ce1180082	663	1
ce1180083	663	1
ce1180084	663	1
ce1180085	663	1
ce1180086	663	1
ce1180087	663	1
ce1180088	663	1
ce1180089	663	1
ce1180090	663	1
ce1180091	663	1
ce1180092	663	1
ce1180093	663	1
ce1180094	663	1
ce1180095	663	1
ce1180096	663	1
ce1180097	663	1
ce1180098	663	1
ce1180099	663	1
ce1180100	663	1
ce1180101	663	1
ce1180102	663	1
ce1180103	663	1
ce1180104	663	1
ce1180105	663	1
ce1180106	663	1
ce1180107	663	1
ce1180108	663	1
ce1180109	663	1
ce1180110	663	1
ce1180111	663	1
ce1180112	663	1
ce1180113	663	1
ce1180114	663	1
ce1180115	663	1
ce1180116	663	1
ce1180117	663	1
ce1180118	663	1
ce1180119	663	1
ce1180120	663	1
ce1180121	663	1
ce1180122	663	1
ce1180123	663	1
ce1180124	663	1
ce1180125	663	1
ce1180126	663	1
ce1180127	663	1
ce1180128	663	1
ce1180129	663	1
ce1180130	663	1
ce1180131	663	1
ce1180132	663	1
ce1180133	663	1
ce1180134	663	1
ce1180135	663	1
ce1180137	663	1
ce1180138	663	1
ce1180139	663	1
ce1180140	663	1
ce1180141	663	1
ce1180142	663	1
ce1180143	663	1
ce1180144	663	1
ce1180145	663	1
ce1180146	663	1
ce1180147	663	1
ce1180148	663	1
ce1180149	663	1
ce1180150	663	1
ce1180151	663	1
ce1180152	663	1
ce1180153	663	1
ce1180154	663	1
ce1180155	663	1
ce1180156	663	1
ce1180157	663	1
ce1180158	663	1
ce1180159	663	1
ce1180160	663	1
ce1180161	663	1
ce1180162	663	1
ce1180163	663	1
ce1180164	663	1
ce1180165	663	1
ce1180166	663	1
ce1180167	663	1
ce1180168	663	1
ce1180169	663	1
ce1180170	663	1
ce1180171	663	1
ce1180172	663	1
ce1180173	663	1
ce1180174	663	1
ce1180175	663	1
ce1180176	663	1
ce1180177	663	1
ch1140121	663	1
ch1160138	663	1
ch1170230	663	1
ch1180186	663	1
ch1180187	663	1
ch1180188	663	1
ch1180189	663	1
ch1180190	663	1
ch1180191	663	1
ch1180192	663	1
ch1180193	663	1
ch1180194	663	1
ch1180195	663	1
ch1180196	663	1
ch1180197	663	1
ch1180198	663	1
ch1180199	663	1
ch1180200	663	1
ch1180201	663	1
ch1180202	663	1
ch1180203	663	1
ch1180204	663	1
ch1180205	663	1
ch1180206	663	1
ch1180207	663	1
ch1180208	663	1
ch1180209	663	1
ch1180210	663	1
ch1180211	663	1
ch1180213	663	1
ch1180214	663	1
ch1180215	663	1
ch1180216	663	1
ch1180217	663	1
ch1180218	663	1
ch1180219	663	1
ch1180220	663	1
ch1180221	663	1
ch1180222	663	1
ch1180223	663	1
ch1180224	663	1
ch1180225	663	1
ch1180226	663	1
ch1180227	663	1
ch1180228	663	1
ch1180229	663	1
ch1180230	663	1
ch1180231	663	1
ch1180232	663	1
ch1180233	663	1
ch1180234	663	1
ch1180235	663	1
ch1180236	663	1
ch1180237	663	1
ch1180238	663	1
ch1180239	663	1
ch1180241	663	1
ch1180242	663	1
ch1180243	663	1
ch1180244	663	1
ch1180245	663	1
ch1180246	663	1
ch1180247	663	1
ch1180248	663	1
ch1180249	663	1
ch1180250	663	1
ch1180251	663	1
ch1180252	663	1
ch1180253	663	1
ch1180254	663	1
ch1180255	663	1
ch1180256	663	1
ch1180257	663	1
ch1180258	663	1
ch1180259	663	1
ch1180260	663	1
ch1180261	663	1
ch7180271	663	1
ch7180272	663	1
ch7180273	663	1
ch7180274	663	1
ch7180275	663	1
ch7180276	663	1
ch7180277	663	1
ch7180278	663	1
ch7180279	663	1
ch7180280	663	1
ch7180281	663	1
ch7180282	663	1
ch7180283	663	1
ch7180284	663	1
ch7180285	663	1
ch7180287	663	1
ch7180288	663	1
ch7180289	663	1
ch7180290	663	1
ch7180291	663	1
ch7180293	663	1
ch7180294	663	1
ch7180295	663	1
ch7180296	663	1
ch7180297	663	1
ch7180298	663	1
ch7180299	663	1
ch7180300	663	1
ch7180301	663	1
ch7180302	663	1
ch7180303	663	1
ch7180304	663	1
ch7180305	663	1
ch7180306	663	1
ch7180307	663	1
ch7180308	663	1
ch7180309	663	1
ch7180310	663	1
ch7180311	663	1
ch7180312	663	1
ch7180313	663	1
ch7180314	663	1
ch7180315	663	1
ch7180316	663	1
ch7180317	663	1
cs1180321	663	1
cs1180322	663	1
cs1180323	663	1
cs1180324	663	1
cs1180325	663	1
cs1180326	663	1
cs1180327	663	1
cs1180328	663	1
cs1180329	663	1
cs1180330	663	1
cs1180331	663	1
cs1180332	663	1
cs1180333	663	1
cs1180334	663	1
cs1180335	663	1
cs1180336	663	1
cs1180337	663	1
cs1180338	663	1
cs1180339	663	1
cs1180340	663	1
cs1180341	663	1
cs1180342	663	1
cs1180343	663	1
cs1180344	663	1
cs1180345	663	1
cs1180346	663	1
cs1180347	663	1
cs1180348	663	1
cs1180349	663	1
cs1180350	663	1
cs1180351	663	1
cs1180352	663	1
cs1180353	663	1
cs1180354	663	1
cs1180355	663	1
cs1180356	663	1
cs1180357	663	1
cs1180358	663	1
cs1180359	663	1
cs1180360	663	1
cs1180361	663	1
cs1180362	663	1
cs1180363	663	1
cs1180364	663	1
cs1180365	663	1
cs1180366	663	1
cs1180367	663	1
cs1180368	663	1
cs1180369	663	1
cs1180370	663	1
cs1180371	663	1
cs1180372	663	1
cs1180373	663	1
cs1180374	663	1
cs1180375	663	1
cs1180376	663	1
cs1180377	663	1
cs1180378	663	1
cs1180379	663	1
cs1180380	663	1
cs1180381	663	1
cs1180382	663	1
cs1180383	663	1
cs1180384	663	1
cs1180385	663	1
cs1180386	663	1
cs1180387	663	1
cs1180388	663	1
cs1180389	663	1
cs1180390	663	1
cs1180391	663	1
cs1180392	663	1
cs1180393	663	1
cs1180394	663	1
cs1180395	663	1
cs1180396	663	1
cs1180397	663	1
cs5180401	663	1
cs5180402	663	1
cs5180403	663	1
cs5180404	663	1
cs5180405	663	1
cs5180406	663	1
cs5180407	663	1
cs5180408	663	1
cs5180410	663	1
cs5180411	663	1
cs5180412	663	1
cs5180413	663	1
cs5180414	663	1
cs5180415	663	1
cs5180416	663	1
cs5180417	663	1
cs5180418	663	1
cs5180419	663	1
cs5180420	663	1
cs5180421	663	1
cs5180422	663	1
cs5180423	663	1
cs5180424	663	1
cs5180425	663	1
cs5180426	663	1
ee1180431	663	1
ee1180432	663	1
ee1180433	663	1
ee1180434	663	1
ee1180435	663	1
ee1180436	663	1
ee1180437	663	1
ee1180438	663	1
ee1180439	663	1
ee1180440	663	1
ee1180441	663	1
ee1180442	663	1
ee1180443	663	1
ee1180444	663	1
ee1180445	663	1
ee1180446	663	1
ee1180447	663	1
ee1180448	663	1
ee1180449	663	1
ee1180450	663	1
ee1180451	663	1
ee1180452	663	1
ee1180453	663	1
ee1180454	663	1
ee1180455	663	1
ee1180456	663	1
ee1180457	663	1
ee1180458	663	1
ee1180459	663	1
ee1180460	663	1
ee1180461	663	1
ee1180462	663	1
ee1180463	663	1
ee1180464	663	1
ee1180465	663	1
ee1180466	663	1
ee1180467	663	1
ee1180468	663	1
ee1180469	663	1
ee1180470	663	1
ee1180471	663	1
ee1180472	663	1
ee1180473	663	1
ee1180474	663	1
ee1180475	663	1
ee1180476	663	1
ee1180477	663	1
ee1180478	663	1
ee1180479	663	1
ee1180480	663	1
ee1180481	663	1
ee1180482	663	1
ee1180483	663	1
ee1180484	663	1
ee1180485	663	1
ee1180486	663	1
ee1180487	663	1
ee1180488	663	1
ee1180489	663	1
ee1180490	663	1
ee1180491	663	1
ee1180492	663	1
ee1180493	663	1
ee1180494	663	1
ee1180495	663	1
ee1180496	663	1
ee1180497	663	1
ee1180498	663	1
ee1180499	663	1
ee1180500	663	1
ee1180501	663	1
ee1180502	663	1
ee1180503	663	1
ee1180504	663	1
ee1180505	663	1
ee1180506	663	1
ee1180507	663	1
ee1180508	663	1
ee1180509	663	1
ee1180510	663	1
ee1180511	663	1
ee1180512	663	1
ee1180513	663	1
ee1180514	663	1
ee1180515	663	1
ee3180521	663	1
ee3180522	663	1
ee3180523	663	1
ee3180524	663	1
ee3180525	663	1
ee3180526	663	1
ee3180527	663	1
ee3180528	663	1
ee3180529	663	1
ee3180530	663	1
ee3180531	663	1
ee3180532	663	1
ee3180533	663	1
ee3180534	663	1
ee3180535	663	1
ee3180536	663	1
ee3180537	663	1
ee3180538	663	1
ee3180539	663	1
ee3180540	663	1
ee3180541	663	1
ee3180542	663	1
ee3180543	663	1
ee3180544	663	1
ee3180545	663	1
ee3180546	663	1
ee3180547	663	1
ee3180548	663	1
ee3180549	663	1
ee3180550	663	1
ee3180551	663	1
ee3180552	663	1
ee3180553	663	1
ee3180554	663	1
ee3180555	663	1
ee3180556	663	1
ee3180557	663	1
ee3180558	663	1
ee3180559	663	1
ee3180560	663	1
ee3180561	663	1
ee3180562	663	1
ee3180563	663	1
ee3180564	663	1
ee3180565	663	1
ee3180566	663	1
ee3180567	663	1
ee3180568	663	1
ee3180569	663	1
me1150643	663	1
me1170563	663	1
me1180581	663	1
me1180582	663	1
me1180583	663	1
me1180584	663	1
me1180585	663	1
me1180586	663	1
me1180587	663	1
me1180588	663	1
me1180589	663	1
me1180590	663	1
me1180591	663	1
me1180592	663	1
me1180593	663	1
me1180594	663	1
me1180595	663	1
me1180596	663	1
me1180597	663	1
me1180598	663	1
me1180599	663	1
me1180600	663	1
me1180601	663	1
me1180602	663	1
me1180603	663	1
me1180604	663	1
me1180605	663	1
me1180606	663	1
me1180607	663	1
me1180608	663	1
me1180609	663	1
me1180610	663	1
me1180611	663	1
me1180612	663	1
me1180613	663	1
me1180614	663	1
me1180615	663	1
me1180616	663	1
me1180617	663	1
me1180618	663	1
me1180619	663	1
me1180620	663	1
me1180621	663	1
me1180622	663	1
me1180623	663	1
me1180624	663	1
me1180625	663	1
me1180626	663	1
me1180627	663	1
me1180628	663	1
me1180629	663	1
me1180630	663	1
me1180631	663	1
me1180632	663	1
me1180633	663	1
me1180634	663	1
me1180635	663	1
me1180636	663	1
me1180637	663	1
me1180638	663	1
me1180639	663	1
me1180640	663	1
me1180641	663	1
me1180642	663	1
me1180643	663	1
me1180644	663	1
me1180645	663	1
me1180646	663	1
me1180647	663	1
me1180648	663	1
me1180649	663	1
me1180650	663	1
me1180651	663	1
me1180652	663	1
me1180653	663	1
me1180654	663	1
me1180655	663	1
me1180656	663	1
me1180657	663	1
me1180658	663	1
me2170659	663	1
me2180661	663	1
me2180663	663	1
me2180664	663	1
me2180665	663	1
me2180666	663	1
me2180667	663	1
me2180668	663	1
me2180669	663	1
me2180670	663	1
me2180671	663	1
me2180672	663	1
me2180673	663	1
me2180674	663	1
me2180675	663	1
me2180676	663	1
me2180677	663	1
me2180678	663	1
me2180679	663	1
me2180680	663	1
me2180681	663	1
me2180682	663	1
me2180684	663	1
me2180685	663	1
me2180686	663	1
me2180687	663	1
me2180688	663	1
me2180689	663	1
me2180690	663	1
me2180691	663	1
me2180692	663	1
me2180693	663	1
me2180694	663	1
me2180695	663	1
me2180696	663	1
me2180697	663	1
me2180698	663	1
me2180699	663	1
me2180700	663	1
me2180701	663	1
me2180702	663	1
me2180703	663	1
me2180704	663	1
me2180705	663	1
me2180706	663	1
me2180707	663	1
me2180708	663	1
me2180709	663	1
me2180710	663	1
me2180711	663	1
me2180712	663	1
me2180713	663	1
me2180714	663	1
me2180715	663	1
me2180716	663	1
me2180717	663	1
me2180718	663	1
me2180719	663	1
me2180720	663	1
me2180721	663	1
me2180722	663	1
me2180723	663	1
me2180724	663	1
me2180725	663	1
me2180726	663	1
me2180727	663	1
me2180728	663	1
me2180729	663	1
me2180730	663	1
me2180731	663	1
me2180732	663	1
me2180733	663	1
me2180734	663	1
me2180735	663	1
me2180736	663	1
mt1160640	663	1
mt1180736	663	1
mt1180737	663	1
mt1180738	663	1
mt1180739	663	1
mt1180740	663	1
mt1180741	663	1
mt1180742	663	1
mt1180743	663	1
mt1180744	663	1
mt1180745	663	1
mt1180746	663	1
mt1180747	663	1
mt1180748	663	1
mt1180749	663	1
mt1180750	663	1
mt1180751	663	1
mt1180752	663	1
mt1180753	663	1
mt1180754	663	1
mt1180755	663	1
mt1180756	663	1
mt1180757	663	1
mt1180758	663	1
mt1180759	663	1
mt1180760	663	1
mt1180761	663	1
mt1180762	663	1
mt1180763	663	1
mt1180764	663	1
mt1180765	663	1
mt1180766	663	1
mt1180767	663	1
mt1180768	663	1
mt1180769	663	1
mt1180770	663	1
mt1180771	663	1
mt1180772	663	1
mt1180773	663	1
mt1180774	663	1
mt6180776	663	1
mt6180777	663	1
mt6180778	663	1
mt6180779	663	1
mt6180780	663	1
mt6180781	663	1
mt6180782	663	1
mt6180783	663	1
mt6180784	663	1
mt6180785	663	1
mt6180786	663	1
mt6180787	663	1
mt6180788	663	1
mt6180789	663	1
mt6180790	663	1
mt6180791	663	1
mt6180792	663	1
mt6180793	663	1
mt6180794	663	1
mt6180795	663	1
mt6180796	663	1
mt6180797	663	1
mt6180798	663	1
ph1170852	663	1
ph1180801	663	1
ph1180802	663	1
ph1180803	663	1
ph1180804	663	1
ph1180805	663	1
ph1180806	663	1
ph1180808	663	1
ph1180809	663	1
ph1180810	663	1
ph1180811	663	1
ph1180812	663	1
ph1180813	663	1
ph1180814	663	1
ph1180815	663	1
ph1180816	663	1
ph1180817	663	1
ph1180818	663	1
ph1180819	663	1
ph1180820	663	1
ph1180821	663	1
ph1180822	663	1
ph1180823	663	1
ph1180824	663	1
ph1180825	663	1
ph1180826	663	1
ph1180827	663	1
ph1180828	663	1
ph1180829	663	1
ph1180830	663	1
ph1180831	663	1
ph1180832	663	1
ph1180833	663	1
ph1180834	663	1
ph1180835	663	1
ph1180836	663	1
ph1180837	663	1
ph1180838	663	1
ph1180839	663	1
ph1180840	663	1
ph1180841	663	1
ph1180842	663	1
ph1180843	663	1
ph1180844	663	1
ph1180845	663	1
ph1180846	663	1
ph1180847	663	1
ph1180848	663	1
ph1180849	663	1
ph1180850	663	1
ph1180851	663	1
ph1180852	663	1
ph1180853	663	1
ph1180854	663	1
ph1180855	663	1
ph1180856	663	1
ph1180857	663	1
ph1180858	663	1
ph1180859	663	1
ph1180860	663	1
tt1140944	663	1
tt1150878	663	1
tt1170895	663	1
tt1180866	663	1
tt1180867	663	1
tt1180868	663	1
tt1180869	663	1
tt1180871	663	1
tt1180872	663	1
tt1180873	663	1
tt1180874	663	1
tt1180875	663	1
tt1180876	663	1
tt1180877	663	1
tt1180878	663	1
tt1180879	663	1
tt1180880	663	1
tt1180881	663	1
tt1180882	663	1
tt1180883	663	1
tt1180884	663	1
tt1180885	663	1
tt1180886	663	1
tt1180887	663	1
tt1180888	663	1
tt1180889	663	1
tt1180890	663	1
tt1180892	663	1
tt1180894	663	1
tt1180895	663	1
tt1180896	663	1
tt1180897	663	1
tt1180898	663	1
tt1180899	663	1
tt1180900	663	1
tt1180901	663	1
tt1180903	663	1
tt1180904	663	1
tt1180905	663	1
tt1180906	663	1
tt1180907	663	1
tt1180908	663	1
tt1180909	663	1
tt1180910	663	1
tt1180911	663	1
tt1180912	663	1
tt1180913	663	1
tt1180914	663	1
tt1180915	663	1
tt1180916	663	1
tt1180917	663	1
tt1180918	663	1
tt1180919	663	1
tt1180920	663	1
tt1180921	663	1
tt1180922	663	1
tt1180923	663	1
tt1180924	663	1
tt1180925	663	1
tt1180926	663	1
tt1180927	663	1
tt1180928	663	1
tt1180929	663	1
tt1180930	663	1
tt1180931	663	1
tt1180933	663	1
tt1180934	663	1
tt1180935	663	1
tt1180936	663	1
tt1180937	663	1
tt1180938	663	1
tt1180939	663	1
tt1180940	663	1
tt1180941	663	1
tt1180942	663	1
tt1180943	663	1
tt1180944	663	1
tt1180945	663	1
tt1180946	663	1
tt1180947	663	1
tt1180948	663	1
tt1180949	663	1
tt1180950	663	1
tt1180951	663	1
tt1180952	663	1
tt1180953	663	1
tt1180954	663	1
tt1180955	663	1
tt1180956	663	1
tt1180957	663	1
tt1180958	663	1
tt1180959	663	1
tt1180960	663	1
tt1180961	663	1
tt1180962	663	1
tt1180963	663	1
tt1180964	663	1
tt1180965	663	1
tt1180966	663	1
tt1180967	663	1
tt1180968	663	1
tt1180969	663	1
tt1180970	663	1
tt1180971	663	1
tt1180972	663	1
tt1180974	663	1
tt1180975	663	1
bb1160058	664	1
bb1170036	664	1
bb1180001	664	1
bb1180002	664	1
bb1180003	664	1
bb1180004	664	1
bb1180005	664	1
bb1180006	664	1
bb1180007	664	1
bb1180008	664	1
bb1180009	664	1
bb1180010	664	1
bb1180011	664	1
bb1180012	664	1
bb1180013	664	1
bb1180014	664	1
bb1180015	664	1
bb1180016	664	1
bb1180017	664	1
bb1180018	664	1
bb1180019	664	1
bb1180020	664	1
bb1180021	664	1
bb1180022	664	1
bb1180023	664	1
bb1180024	664	1
bb1180025	664	1
bb1180026	664	1
bb1180027	664	1
bb1180028	664	1
bb1180029	664	1
bb1180030	664	1
bb1180031	664	1
bb1180032	664	1
bb1180033	664	1
bb1180034	664	1
bb1180036	664	1
bb1180037	664	1
bb1180038	664	1
bb1180039	664	1
bb1180040	664	1
bb1180041	664	1
bb1180042	664	1
bb1180043	664	1
bb1180044	664	1
bb1180045	664	1
bb1180046	664	1
bb5180051	664	1
bb5180052	664	1
bb5180053	664	1
bb5180054	664	1
bb5180055	664	1
bb5180056	664	1
bb5180057	664	1
bb5180058	664	1
bb5180059	664	1
bb5180060	664	1
bb5180061	664	1
bb5180063	664	1
bb5180064	664	1
bb5180065	664	1
bb5180066	664	1
ce1160279	664	1
ce1160303	664	1
ce1170090	664	1
ce1170109	664	1
ce1170123	664	1
ce1170131	664	1
ce1180071	664	1
ce1180072	664	1
ce1180073	664	1
ce1180074	664	1
ce1180075	664	1
ce1180076	664	1
ce1180077	664	1
ce1180078	664	1
ce1180079	664	1
ce1180080	664	1
ce1180081	664	1
ce1180082	664	1
ce1180083	664	1
ce1180084	664	1
ce1180085	664	1
ce1180086	664	1
ce1180087	664	1
ce1180088	664	1
ce1180089	664	1
ce1180090	664	1
ce1180091	664	1
ce1180092	664	1
ce1180093	664	1
ce1180094	664	1
ce1180095	664	1
ce1180096	664	1
ce1180097	664	1
ce1180098	664	1
ce1180099	664	1
ce1180100	664	1
ce1180101	664	1
ce1180102	664	1
ce1180103	664	1
ce1180104	664	1
ce1180105	664	1
ce1180106	664	1
ce1180107	664	1
ce1180108	664	1
ce1180109	664	1
ce1180110	664	1
ce1180111	664	1
ce1180112	664	1
ce1180113	664	1
ce1180114	664	1
ce1180115	664	1
ce1180116	664	1
ce1180117	664	1
ce1180118	664	1
ce1180119	664	1
ce1180120	664	1
ce1180121	664	1
ce1180122	664	1
ce1180123	664	1
ce1180124	664	1
ce1180125	664	1
ce1180126	664	1
ce1180127	664	1
ce1180128	664	1
ce1180129	664	1
ce1180130	664	1
ce1180131	664	1
ce1180132	664	1
ce1180133	664	1
ce1180134	664	1
ce1180135	664	1
ce1180137	664	1
ce1180138	664	1
ce1180139	664	1
ce1180140	664	1
ce1180141	664	1
ce1180142	664	1
ce1180143	664	1
ce1180144	664	1
ce1180145	664	1
ce1180146	664	1
ce1180147	664	1
ce1180148	664	1
ce1180149	664	1
ce1180150	664	1
ce1180151	664	1
ce1180152	664	1
ce1180153	664	1
ce1180154	664	1
ce1180155	664	1
ce1180156	664	1
ce1180157	664	1
ce1180158	664	1
ce1180159	664	1
ce1180160	664	1
ce1180161	664	1
ce1180162	664	1
ce1180163	664	1
ce1180164	664	1
ce1180165	664	1
ce1180166	664	1
ce1180167	664	1
ce1180168	664	1
ce1180169	664	1
ce1180170	664	1
ce1180171	664	1
ce1180172	664	1
ce1180173	664	1
ce1180174	664	1
ce1180175	664	1
ce1180176	664	1
ce1180177	664	1
ch1170230	664	1
ch1180186	664	1
ch1180187	664	1
ch1180188	664	1
ch1180189	664	1
ch1180190	664	1
ch1180191	664	1
ch1180192	664	1
ch1180193	664	1
ch1180194	664	1
ch1180195	664	1
ch1180196	664	1
ch1180197	664	1
ch1180198	664	1
ch1180199	664	1
ch1180200	664	1
ch1180201	664	1
ch1180202	664	1
ch1180203	664	1
ch1180204	664	1
ch1180205	664	1
ch1180206	664	1
ch1180207	664	1
ch1180208	664	1
ch1180209	664	1
ch1180210	664	1
ch1180211	664	1
ch1180213	664	1
ch1180214	664	1
ch1180215	664	1
ch1180216	664	1
ch1180217	664	1
ch1180218	664	1
ch1180219	664	1
ch1180220	664	1
ch1180221	664	1
ch1180222	664	1
ch1180223	664	1
ch1180224	664	1
ch1180225	664	1
ch1180226	664	1
ch1180227	664	1
ch1180228	664	1
ch1180229	664	1
ch1180230	664	1
ch1180231	664	1
ch1180232	664	1
ch1180233	664	1
ch1180234	664	1
ch1180235	664	1
ch1180236	664	1
ch1180237	664	1
ch1180238	664	1
ch1180239	664	1
ch1180241	664	1
ch1180242	664	1
ch1180243	664	1
ch1180244	664	1
ch1180245	664	1
ch1180246	664	1
ch1180247	664	1
ch1180248	664	1
ch1180249	664	1
ch1180250	664	1
ch1180251	664	1
ch1180252	664	1
ch1180253	664	1
ch1180254	664	1
ch1180255	664	1
ch1180256	664	1
ch1180257	664	1
ch1180258	664	1
ch1180259	664	1
ch1180260	664	1
ch1180261	664	1
ch7170273	664	1
ch7180271	664	1
ch7180272	664	1
ch7180273	664	1
ch7180274	664	1
ch7180275	664	1
ch7180276	664	1
ch7180277	664	1
ch7180278	664	1
ch7180279	664	1
ch7180280	664	1
ch7180281	664	1
ch7180282	664	1
ch7180283	664	1
ch7180284	664	1
ch7180285	664	1
ch7180287	664	1
ch7180288	664	1
ch7180289	664	1
ch7180290	664	1
ch7180291	664	1
ch7180293	664	1
ch7180294	664	1
ch7180295	664	1
ch7180296	664	1
ch7180297	664	1
ch7180298	664	1
ch7180299	664	1
ch7180300	664	1
ch7180301	664	1
ch7180302	664	1
ch7180303	664	1
ch7180304	664	1
ch7180305	664	1
ch7180306	664	1
ch7180307	664	1
ch7180308	664	1
ch7180309	664	1
ch7180310	664	1
ch7180311	664	1
ch7180312	664	1
ch7180313	664	1
ch7180314	664	1
ch7180315	664	1
ch7180316	664	1
ch7180317	664	1
cs1180321	664	1
cs1180322	664	1
cs1180323	664	1
cs1180324	664	1
cs1180325	664	1
cs1180326	664	1
cs1180327	664	1
cs1180328	664	1
cs1180329	664	1
cs1180330	664	1
cs1180331	664	1
cs1180332	664	1
cs1180333	664	1
cs1180334	664	1
cs1180335	664	1
cs1180336	664	1
cs1180337	664	1
cs1180338	664	1
cs1180339	664	1
cs1180340	664	1
cs1180341	664	1
cs1180342	664	1
cs1180343	664	1
cs1180344	664	1
cs1180345	664	1
cs1180346	664	1
cs1180347	664	1
cs1180348	664	1
cs1180349	664	1
cs1180350	664	1
cs1180351	664	1
cs1180352	664	1
cs1180353	664	1
cs1180354	664	1
cs1180355	664	1
cs1180356	664	1
cs1180357	664	1
cs1180358	664	1
cs1180359	664	1
cs1180360	664	1
cs1180361	664	1
cs1180362	664	1
cs1180363	664	1
cs1180364	664	1
cs1180365	664	1
cs1180366	664	1
cs1180367	664	1
cs1180368	664	1
cs1180369	664	1
cs1180370	664	1
cs1180371	664	1
cs1180372	664	1
cs1180373	664	1
cs1180374	664	1
cs1180375	664	1
cs1180376	664	1
cs1180377	664	1
cs1180378	664	1
cs1180379	664	1
cs1180380	664	1
cs1180381	664	1
cs1180382	664	1
cs1180383	664	1
cs1180384	664	1
cs1180385	664	1
cs1180386	664	1
cs1180387	664	1
cs1180388	664	1
cs1180389	664	1
cs1180390	664	1
cs1180391	664	1
cs1180392	664	1
cs1180393	664	1
cs1180394	664	1
cs1180395	664	1
cs1180396	664	1
cs1180397	664	1
cs5180401	664	1
cs5180402	664	1
cs5180403	664	1
cs5180404	664	1
cs5180405	664	1
cs5180406	664	1
cs5180407	664	1
cs5180408	664	1
cs5180410	664	1
cs5180411	664	1
cs5180412	664	1
cs5180413	664	1
cs5180414	664	1
cs5180415	664	1
cs5180416	664	1
cs5180417	664	1
cs5180418	664	1
cs5180419	664	1
cs5180420	664	1
cs5180421	664	1
cs5180422	664	1
cs5180423	664	1
cs5180424	664	1
cs5180425	664	1
cs5180426	664	1
ee1180431	664	1
ee1180432	664	1
ee1180433	664	1
ee1180434	664	1
ee1180435	664	1
ee1180436	664	1
ee1180437	664	1
ee1180438	664	1
ee1180439	664	1
ee1180440	664	1
ee1180441	664	1
ee1180442	664	1
ee1180443	664	1
ee1180444	664	1
ee1180445	664	1
ee1180446	664	1
ee1180447	664	1
ee1180448	664	1
ee1180449	664	1
ee1180450	664	1
ee1180451	664	1
ee1180452	664	1
ee1180453	664	1
ee1180454	664	1
ee1180455	664	1
ee1180456	664	1
ee1180457	664	1
ee1180458	664	1
ee1180459	664	1
ee1180460	664	1
ee1180461	664	1
ee1180462	664	1
ee1180463	664	1
ee1180464	664	1
ee1180465	664	1
ee1180466	664	1
ee1180467	664	1
ee1180468	664	1
ee1180469	664	1
ee1180470	664	1
ee1180471	664	1
ee1180472	664	1
ee1180473	664	1
ee1180474	664	1
ee1180475	664	1
ee1180476	664	1
ee1180477	664	1
ee1180478	664	1
ee1180479	664	1
ee1180480	664	1
ee1180481	664	1
ee1180482	664	1
ee1180483	664	1
ee1180484	664	1
ee1180485	664	1
ee1180486	664	1
ee1180487	664	1
ee1180488	664	1
ee1180489	664	1
ee1180490	664	1
ee1180491	664	1
ee1180492	664	1
ee1180493	664	1
ee1180494	664	1
ee1180495	664	1
ee1180496	664	1
ee1180497	664	1
ee1180498	664	1
ee1180499	664	1
ee1180500	664	1
ee1180501	664	1
ee1180502	664	1
ee1180503	664	1
ee1180504	664	1
ee1180505	664	1
ee1180506	664	1
ee1180507	664	1
ee1180508	664	1
ee1180509	664	1
ee1180510	664	1
ee1180511	664	1
ee1180512	664	1
ee1180513	664	1
ee1180514	664	1
ee1180515	664	1
ee3180521	664	1
ee3180522	664	1
ee3180523	664	1
ee3180524	664	1
ee3180525	664	1
ee3180526	664	1
ee3180527	664	1
ee3180528	664	1
ee3180529	664	1
ee3180530	664	1
ee3180531	664	1
ee3180532	664	1
ee3180533	664	1
ee3180534	664	1
ee3180535	664	1
ee3180536	664	1
ee3180537	664	1
ee3180538	664	1
ee3180539	664	1
ee3180540	664	1
ee3180541	664	1
ee3180542	664	1
ee3180543	664	1
ee3180544	664	1
ee3180545	664	1
ee3180546	664	1
ee3180547	664	1
ee3180548	664	1
ee3180549	664	1
ee3180550	664	1
ee3180551	664	1
ee3180552	664	1
ee3180553	664	1
ee3180554	664	1
ee3180555	664	1
ee3180556	664	1
ee3180557	664	1
ee3180558	664	1
ee3180559	664	1
ee3180560	664	1
ee3180561	664	1
ee3180562	664	1
ee3180563	664	1
ee3180564	664	1
ee3180565	664	1
ee3180566	664	1
ee3180567	664	1
ee3180568	664	1
ee3180569	664	1
me1170563	664	1
me1180581	664	1
me1180582	664	1
me1180583	664	1
me1180584	664	1
me1180585	664	1
me1180586	664	1
me1180587	664	1
me1180588	664	1
me1180589	664	1
me1180590	664	1
me1180591	664	1
me1180592	664	1
me1180593	664	1
me1180594	664	1
me1180595	664	1
me1180596	664	1
me1180597	664	1
me1180598	664	1
me1180599	664	1
me1180600	664	1
me1180601	664	1
me1180602	664	1
me1180603	664	1
me1180604	664	1
me1180605	664	1
me1180606	664	1
me1180607	664	1
me1180608	664	1
me1180609	664	1
me1180610	664	1
me1180611	664	1
me1180612	664	1
me1180613	664	1
me1180614	664	1
me1180615	664	1
me1180616	664	1
me1180617	664	1
me1180618	664	1
me1180619	664	1
me1180620	664	1
me1180621	664	1
me1180622	664	1
me1180623	664	1
me1180624	664	1
me1180625	664	1
me1180626	664	1
me1180627	664	1
me1180628	664	1
me1180629	664	1
me1180630	664	1
me1180631	664	1
me1180632	664	1
me1180633	664	1
me1180634	664	1
me1180635	664	1
me1180636	664	1
me1180637	664	1
me1180638	664	1
me1180639	664	1
me1180640	664	1
me1180641	664	1
me1180642	664	1
me1180643	664	1
me1180644	664	1
me1180645	664	1
me1180646	664	1
me1180647	664	1
me1180648	664	1
me1180649	664	1
me1180650	664	1
me1180651	664	1
me1180652	664	1
me1180653	664	1
me1180654	664	1
me1180655	664	1
me1180656	664	1
me1180657	664	1
me1180658	664	1
me2170659	664	1
me2180661	664	1
me2180663	664	1
me2180664	664	1
me2180665	664	1
me2180666	664	1
me2180667	664	1
me2180668	664	1
me2180669	664	1
me2180670	664	1
me2180671	664	1
me2180672	664	1
me2180673	664	1
me2180674	664	1
me2180675	664	1
me2180676	664	1
me2180677	664	1
me2180678	664	1
me2180679	664	1
me2180680	664	1
me2180681	664	1
me2180682	664	1
me2180684	664	1
me2180685	664	1
me2180686	664	1
me2180687	664	1
me2180688	664	1
me2180689	664	1
me2180690	664	1
me2180691	664	1
me2180692	664	1
me2180693	664	1
me2180694	664	1
me2180695	664	1
me2180696	664	1
me2180697	664	1
me2180698	664	1
me2180699	664	1
me2180700	664	1
me2180701	664	1
me2180702	664	1
me2180703	664	1
me2180704	664	1
me2180705	664	1
me2180706	664	1
me2180707	664	1
me2180708	664	1
me2180709	664	1
me2180710	664	1
me2180711	664	1
me2180712	664	1
me2180713	664	1
me2180714	664	1
me2180715	664	1
me2180716	664	1
me2180717	664	1
me2180718	664	1
me2180719	664	1
me2180720	664	1
me2180721	664	1
me2180722	664	1
me2180723	664	1
me2180724	664	1
me2180725	664	1
me2180726	664	1
me2180727	664	1
me2180728	664	1
me2180729	664	1
me2180730	664	1
me2180731	664	1
me2180732	664	1
me2180733	664	1
me2180734	664	1
me2180735	664	1
me2180736	664	1
mt1180736	664	1
mt1180737	664	1
mt1180738	664	1
mt1180739	664	1
mt1180740	664	1
mt1180741	664	1
mt1180742	664	1
mt1180743	664	1
mt1180744	664	1
mt1180745	664	1
mt1180746	664	1
mt1180747	664	1
mt1180748	664	1
mt1180749	664	1
mt1180750	664	1
mt1180751	664	1
mt1180752	664	1
mt1180753	664	1
mt1180754	664	1
mt1180755	664	1
mt1180756	664	1
mt1180757	664	1
mt1180758	664	1
mt1180759	664	1
mt1180760	664	1
mt1180761	664	1
mt1180762	664	1
mt1180763	664	1
mt1180764	664	1
mt1180765	664	1
mt1180766	664	1
mt1180767	664	1
mt1180768	664	1
mt1180769	664	1
mt1180770	664	1
mt1180771	664	1
mt1180772	664	1
mt1180773	664	1
mt1180774	664	1
mt6180776	664	1
mt6180777	664	1
mt6180778	664	1
mt6180779	664	1
mt6180780	664	1
mt6180781	664	1
mt6180782	664	1
mt6180783	664	1
mt6180784	664	1
mt6180785	664	1
mt6180786	664	1
mt6180787	664	1
mt6180788	664	1
mt6180789	664	1
mt6180790	664	1
mt6180791	664	1
mt6180792	664	1
mt6180793	664	1
mt6180794	664	1
mt6180795	664	1
mt6180796	664	1
mt6180797	664	1
mt6180798	664	1
ph1160590	664	1
ph1170858	664	1
ph1180801	664	1
ph1180802	664	1
ph1180803	664	1
ph1180804	664	1
ph1180805	664	1
ph1180806	664	1
ph1180808	664	1
ph1180809	664	1
ph1180810	664	1
ph1180811	664	1
ph1180812	664	1
ph1180813	664	1
ph1180814	664	1
ph1180815	664	1
ph1180816	664	1
ph1180817	664	1
ph1180818	664	1
ph1180819	664	1
ph1180820	664	1
ph1180821	664	1
ph1180822	664	1
ph1180823	664	1
ph1180824	664	1
ph1180825	664	1
ph1180826	664	1
ph1180827	664	1
ph1180828	664	1
ph1180829	664	1
ph1180830	664	1
ph1180831	664	1
ph1180832	664	1
ph1180833	664	1
ph1180834	664	1
ph1180835	664	1
ph1180836	664	1
ph1180837	664	1
ph1180838	664	1
ph1180839	664	1
ph1180840	664	1
ph1180841	664	1
ph1180842	664	1
ph1180843	664	1
ph1180844	664	1
ph1180845	664	1
ph1180846	664	1
ph1180847	664	1
ph1180848	664	1
ph1180849	664	1
ph1180850	664	1
ph1180851	664	1
ph1180852	664	1
ph1180853	664	1
ph1180854	664	1
ph1180855	664	1
ph1180856	664	1
ph1180857	664	1
ph1180858	664	1
ph1180859	664	1
ph1180860	664	1
tt1160913	664	1
tt1160921	664	1
tt1170895	664	1
tt1170973	664	1
tt1180866	664	1
tt1180867	664	1
tt1180868	664	1
tt1180869	664	1
tt1180871	664	1
tt1180872	664	1
tt1180873	664	1
tt1180874	664	1
tt1180875	664	1
tt1180876	664	1
tt1180877	664	1
tt1180878	664	1
tt1180879	664	1
tt1180880	664	1
tt1180881	664	1
tt1180882	664	1
tt1180883	664	1
tt1180884	664	1
tt1180885	664	1
tt1180886	664	1
tt1180887	664	1
tt1180888	664	1
tt1180889	664	1
tt1180890	664	1
tt1180892	664	1
tt1180894	664	1
tt1180895	664	1
tt1180896	664	1
tt1180897	664	1
tt1180898	664	1
tt1180899	664	1
tt1180900	664	1
tt1180901	664	1
tt1180903	664	1
tt1180904	664	1
tt1180905	664	1
tt1180906	664	1
tt1180907	664	1
tt1180908	664	1
tt1180909	664	1
tt1180910	664	1
tt1180911	664	1
tt1180912	664	1
tt1180913	664	1
tt1180914	664	1
tt1180915	664	1
tt1180916	664	1
tt1180917	664	1
tt1180918	664	1
tt1180919	664	1
tt1180920	664	1
tt1180921	664	1
tt1180922	664	1
tt1180923	664	1
tt1180924	664	1
tt1180925	664	1
tt1180926	664	1
tt1180927	664	1
tt1180928	664	1
tt1180929	664	1
tt1180930	664	1
tt1180931	664	1
tt1180933	664	1
tt1180934	664	1
tt1180935	664	1
tt1180936	664	1
tt1180937	664	1
tt1180938	664	1
tt1180939	664	1
tt1180940	664	1
tt1180941	664	1
tt1180942	664	1
tt1180943	664	1
tt1180944	664	1
tt1180945	664	1
tt1180946	664	1
tt1180947	664	1
tt1180948	664	1
tt1180949	664	1
tt1180950	664	1
tt1180951	664	1
tt1180952	664	1
tt1180953	664	1
tt1180954	664	1
tt1180955	664	1
tt1180956	664	1
tt1180957	664	1
tt1180958	664	1
tt1180959	664	1
tt1180960	664	1
tt1180961	664	1
tt1180962	664	1
tt1180963	664	1
tt1180964	664	1
tt1180965	664	1
tt1180966	664	1
tt1180967	664	1
tt1180968	664	1
tt1180969	664	1
tt1180970	664	1
tt1180971	664	1
tt1180972	664	1
tt1180974	664	1
tt1180975	664	1
jpt182472	665	1
jpt182473	665	1
jpt182474	665	1
jpt182475	665	1
jpt182476	665	1
jpt182477	665	1
jpt182478	665	1
jpt182479	665	1
jpt182480	665	1
jpt182481	665	1
jpt182482	665	1
jpt182484	665	1
jpt182485	665	1
jpt182486	665	1
jpt182487	665	1
msz188508	665	1
qiz188613	665	1
ttz188456	665	1
jpt182472	666	1
jpt182473	666	1
jpt182474	666	1
jpt182475	666	1
jpt182476	666	1
jpt182477	666	1
jpt182478	666	1
jpt182479	666	1
jpt182480	666	1
jpt182481	666	1
jpt182482	666	1
jpt182484	666	1
jpt182485	666	1
jpt182486	666	1
jpt182487	666	1
msz188505	666	1
msz188508	666	1
ttz188456	666	1
jpt182472	667	1
jpt182473	667	1
jpt182474	667	1
jpt182475	667	1
jpt182476	667	1
jpt182477	667	1
jpt182478	667	1
jpt182479	667	1
jpt182480	667	1
jpt182481	667	1
jpt182482	667	1
jpt182484	667	1
jpt182485	667	1
jpt182486	667	1
jpt182487	667	1
msz188024	667	1
msz188505	667	1
msz188506	667	1
msz188508	667	1
chz178260	668	1
jpt172613	668	1
jpt182472	668	1
jpt182473	668	1
jpt182474	668	1
jpt182475	668	1
jpt182476	668	1
jpt182477	668	1
jpt182478	668	1
jpt182479	668	1
jpt182480	668	1
jpt182481	668	1
jpt182482	668	1
jpt182484	668	1
jpt182485	668	1
jpt182486	668	1
jpt182487	668	1
msz188506	668	1
msz188507	668	1
ttz188454	668	1
ttz188455	668	1
ttz188458	668	1
ttz188459	668	1
jpt182472	669	1
jpt182473	669	1
jpt182474	669	1
jpt182475	669	1
jpt182476	669	1
jpt182477	669	1
jpt182478	669	1
jpt182479	669	1
jpt182480	669	1
jpt182481	669	1
jpt182482	669	1
jpt182484	669	1
jpt182485	669	1
jpt182486	669	1
jpt182487	669	1
bb1160044	670	1
bb1160054	670	1
jpt172603	670	1
jpt172606	670	1
jpt172611	670	1
jpt172613	670	1
jpt172617	670	1
jpt172684	670	1
jpt182473	670	1
jpt182475	670	1
jpt182476	670	1
jpt182479	670	1
jpt182480	670	1
jpt182481	670	1
jpt182482	670	1
jpt182484	670	1
msz188022	670	1
ph1100849	671	1
ph1110855	671	1
ph1130849	671	1
ph1150787	671	1
ph1150804	671	1
ph1150811	671	1
ph1150816	671	1
ph1150820	671	1
ph1150825	671	1
ph1150827	671	1
ph1150788	672	1
ph1150789	672	1
ph1150790	672	1
ph1150800	672	1
ph1150806	672	1
ph1150814	672	1
ph1150818	672	1
ph1150826	672	1
ph1150829	672	1
ph1150831	672	1
ph1150833	672	1
ph1150834	672	1
ph1150837	672	1
ph1150786	673	1
phs177121	674	1
phs177122	674	1
phs177123	674	1
phs177127	674	1
phs177128	674	1
phs177129	674	1
phs177130	674	1
phs177131	674	1
phs177132	674	1
phs177133	674	1
phs177135	674	1
phs177138	674	1
phs177139	674	1
phs177140	674	1
phs177141	674	1
phs177142	674	1
phs177143	674	1
phs177144	674	1
phs177145	674	1
phs177146	674	1
phs177147	674	1
phs177148	674	1
phs177149	674	1
phs177150	674	1
phs177151	674	1
phs177152	674	1
phs177153	674	1
phs177154	674	1
phs177155	674	1
phs177156	674	1
phs177158	674	1
phs177159	674	1
phs177160	674	1
phs177161	674	1
phs177162	674	1
phs177163	674	1
phs177164	674	1
phs177165	674	1
phs177166	674	1
phs177168	674	1
phs177169	674	1
phs177170	674	1
phs177172	674	1
phs177173	674	1
phs177151	675	1
phs177154	675	1
phs177161	675	1
phs177164	675	1
phs177165	675	1
phs177168	675	1
phs177170	675	1
ph1140790	676	1
phm172210	676	1
phm172211	676	1
phm172212	676	1
phm172213	676	1
phm172215	676	1
phm172216	676	1
phm172218	676	1
phm172219	676	1
phm172220	676	1
phm172221	676	1
phm172224	676	1
phm172225	676	1
phm172226	676	1
phm172688	676	1
phm172898	676	1
pha172189	677	1
pha172190	677	1
pha172192	677	1
pha172194	677	1
pha172196	677	1
pha172198	677	1
pha172200	677	1
pha172201	677	1
pha172203	677	1
pha172204	677	1
pha172205	677	1
pha172206	677	1
pha172207	677	1
pha172208	677	1
pha172828	677	1
pha172829	677	1
pha172852	677	1
bb1150025	678	1
bb1150064	678	1
bb1180001	678	1
bb1180002	678	1
bb1180004	678	1
bb1180005	678	1
bb1180006	678	1
bb1180008	678	1
bb1180012	678	1
bb1180016	678	1
bb1180017	678	1
bb1180019	678	1
bb1180020	678	1
bb1180021	678	1
bb1180023	678	1
bb1180024	678	1
bb1180025	678	1
bb1180029	678	1
bb1180030	678	1
bb1180031	678	1
bb1180032	678	1
bb1180034	678	1
bb1180036	678	1
bb1180037	678	1
bb1180038	678	1
bb1180039	678	1
bb1180041	678	1
bb1180042	678	1
bb1180044	678	1
bb1180045	678	1
bb1180046	678	1
bb5120047	678	1
bb5130002	678	1
bb5130011	678	1
bb5130029	678	1
bb5160014	678	1
bb5180051	678	1
bb5180052	678	1
bb5180053	678	1
bb5180054	678	1
bb5180056	678	1
bb5180057	678	1
bb5180058	678	1
bb5180060	678	1
bb5180063	678	1
bb5180064	678	1
bb5180066	678	1
ce1140395	678	1
ce1150315	678	1
ce1150343	678	1
ce1150398	678	1
ce1150405	678	1
ce1160286	678	1
ce1160295	678	1
ce1160305	678	1
ce1170088	678	1
ce1180074	678	1
ce1180076	678	1
ce1180078	678	1
ce1180079	678	1
ce1180083	678	1
ce1180084	678	1
ce1180085	678	1
ce1180086	678	1
ce1180090	678	1
ce1180094	678	1
ce1180095	678	1
ce1180101	678	1
ce1180104	678	1
ce1180106	678	1
ce1180108	678	1
ce1180110	678	1
ce1180112	678	1
ce1180117	678	1
ce1180118	678	1
ce1180120	678	1
ce1180124	678	1
ce1180132	678	1
ce1180133	678	1
ce1180141	678	1
ce1180146	678	1
ce1180148	678	1
ce1180149	678	1
ce1180150	678	1
ce1180151	678	1
ce1180154	678	1
ce1180157	678	1
ce1180158	678	1
ce1180163	678	1
ce1180164	678	1
ce1180165	678	1
ce1180167	678	1
ce1180168	678	1
ce1180169	678	1
ce1180177	678	1
ch1130080	678	1
ch1160134	678	1
ch1160138	678	1
ch1180187	678	1
ch1180189	678	1
ch1180191	678	1
ch1180193	678	1
ch1180194	678	1
ch1180195	678	1
ch1180197	678	1
ch1180199	678	1
ch1180200	678	1
ch1180201	678	1
ch1180202	678	1
ch1180203	678	1
ch1180205	678	1
ch1180208	678	1
ch1180210	678	1
ch1180211	678	1
ch1180213	678	1
ch1180214	678	1
ch1180215	678	1
ch1180216	678	1
ch1180218	678	1
ch1180220	678	1
ch1180221	678	1
ch1180225	678	1
ch1180227	678	1
ch1180229	678	1
ch1180230	678	1
ch1180234	678	1
ch1180239	678	1
ch1180242	678	1
ch1180247	678	1
ch1180248	678	1
ch1180249	678	1
ch1180250	678	1
ch1180251	678	1
ch1180252	678	1
ch1180253	678	1
ch1180254	678	1
ch1180255	678	1
ch1180257	678	1
ch1180259	678	1
ch1180260	678	1
ch1180261	678	1
ch7160189	678	1
ch7180271	678	1
ch7180272	678	1
ch7180277	678	1
ch7180278	678	1
ch7180279	678	1
ch7180280	678	1
ch7180281	678	1
ch7180282	678	1
ch7180285	678	1
ch7180287	678	1
ch7180288	678	1
ch7180290	678	1
ch7180293	678	1
ch7180295	678	1
ch7180296	678	1
ch7180297	678	1
ch7180299	678	1
ch7180301	678	1
ch7180302	678	1
ch7180304	678	1
ch7180305	678	1
ch7180306	678	1
ch7180311	678	1
ch7180315	678	1
ch7180317	678	1
cs1180322	678	1
cs1180323	678	1
cs1180327	678	1
cs1180330	678	1
cs1180332	678	1
cs1180334	678	1
cs1180335	678	1
cs1180340	678	1
cs1180344	678	1
cs1180345	678	1
cs1180346	678	1
cs1180348	678	1
cs1180350	678	1
cs1180351	678	1
cs1180355	678	1
cs1180360	678	1
cs1180362	678	1
cs1180366	678	1
cs1180370	678	1
cs1180372	678	1
cs1180373	678	1
cs1180374	678	1
cs1180377	678	1
cs1180380	678	1
cs1180381	678	1
cs1180385	678	1
cs1180386	678	1
cs1180389	678	1
cs1180390	678	1
cs1180392	678	1
cs1180393	678	1
cs1180394	678	1
cs1180395	678	1
cs1180397	678	1
cs5110297	678	1
cs5180401	678	1
cs5180402	678	1
cs5180403	678	1
cs5180404	678	1
cs5180405	678	1
cs5180408	678	1
cs5180412	678	1
cs5180413	678	1
cs5180419	678	1
cs5180420	678	1
cs5180422	678	1
cs5180425	678	1
cs5180426	678	1
ee1180433	678	1
ee1180434	678	1
ee1180436	678	1
ee1180437	678	1
ee1180439	678	1
ee1180441	678	1
ee1180443	678	1
ee1180444	678	1
ee1180446	678	1
ee1180447	678	1
ee1180452	678	1
ee1180454	678	1
ee1180456	678	1
ee1180458	678	1
ee1180459	678	1
ee1180460	678	1
ee1180467	678	1
ee1180468	678	1
ee1180469	678	1
ee1180470	678	1
ee1180473	678	1
ee1180476	678	1
ee1180482	678	1
ee1180483	678	1
ee1180485	678	1
ee1180486	678	1
ee1180489	678	1
ee1180491	678	1
ee1180492	678	1
ee1180496	678	1
ee1180497	678	1
ee1180504	678	1
ee1180505	678	1
ee1180506	678	1
ee1180509	678	1
ee1180511	678	1
ee3180521	678	1
ee3180523	678	1
ee3180524	678	1
ee3180525	678	1
ee3180527	678	1
ee3180528	678	1
ee3180530	678	1
ee3180531	678	1
ee3180533	678	1
ee3180535	678	1
ee3180541	678	1
ee3180542	678	1
ee3180545	678	1
ee3180546	678	1
ee3180547	678	1
ee3180549	678	1
ee3180553	678	1
ee3180554	678	1
ee3180556	678	1
ee3180557	678	1
ee3180560	678	1
ee3180562	678	1
ee3180563	678	1
ee3180565	678	1
ee3180569	678	1
me1130721	678	1
me1150673	678	1
me1170563	678	1
me1180581	678	1
me1180582	678	1
me1180584	678	1
me1180588	678	1
me1180589	678	1
me1180590	678	1
me1180592	678	1
me1180597	678	1
me1180599	678	1
me1180600	678	1
me1180603	678	1
me1180604	678	1
me1180606	678	1
me1180608	678	1
me1180611	678	1
me1180612	678	1
me1180614	678	1
me1180615	678	1
me1180616	678	1
me1180622	678	1
me1180624	678	1
me1180626	678	1
me1180627	678	1
me1180628	678	1
me1180630	678	1
me1180631	678	1
me1180633	678	1
me1180634	678	1
me1180641	678	1
me1180644	678	1
me1180645	678	1
me1180650	678	1
me1180651	678	1
me1180654	678	1
me1180656	678	1
me1180658	678	1
me2140761	678	1
me2160799	678	1
me2180661	678	1
me2180663	678	1
me2180664	678	1
me2180666	678	1
me2180668	678	1
me2180670	678	1
me2180672	678	1
me2180674	678	1
me2180675	678	1
me2180676	678	1
me2180678	678	1
me2180679	678	1
me2180681	678	1
me2180682	678	1
me2180687	678	1
me2180688	678	1
me2180690	678	1
me2180691	678	1
me2180692	678	1
me2180694	678	1
me2180695	678	1
me2180696	678	1
me2180698	678	1
me2180699	678	1
me2180700	678	1
me2180701	678	1
me2180703	678	1
me2180706	678	1
me2180707	678	1
me2180709	678	1
me2180712	678	1
me2180713	678	1
me2180715	678	1
me2180716	678	1
me2180717	678	1
me2180718	678	1
me2180719	678	1
me2180722	678	1
me2180723	678	1
me2180725	678	1
me2180726	678	1
me2180728	678	1
me2180730	678	1
me2180732	678	1
me2180733	678	1
me2180736	678	1
mt1180738	678	1
mt1180739	678	1
mt1180742	678	1
mt1180744	678	1
mt1180746	678	1
mt1180748	678	1
mt1180755	678	1
mt1180757	678	1
mt1180758	678	1
mt1180760	678	1
mt1180762	678	1
mt1180770	678	1
mt6180777	678	1
mt6180783	678	1
mt6180785	678	1
mt6180790	678	1
mt6180793	678	1
mt6180794	678	1
mt6180795	678	1
mt6180797	678	1
ph1150841	678	1
ph1160552	678	1
ph1160597	678	1
ph1170852	678	1
ph1180801	678	1
ph1180802	678	1
ph1180803	678	1
ph1180810	678	1
ph1180812	678	1
ph1180813	678	1
ph1180814	678	1
ph1180817	678	1
ph1180820	678	1
ph1180821	678	1
ph1180822	678	1
ph1180825	678	1
ph1180826	678	1
ph1180827	678	1
ph1180828	678	1
ph1180830	678	1
ph1180831	678	1
ph1180832	678	1
ph1180833	678	1
ph1180836	678	1
ph1180838	678	1
ph1180839	678	1
ph1180843	678	1
ph1180844	678	1
ph1180845	678	1
ph1180846	678	1
ph1180848	678	1
ph1180850	678	1
ph1180851	678	1
ph1180852	678	1
ph1180854	678	1
ph1180858	678	1
ph1180859	678	1
ph1180860	678	1
tt1150857	678	1
tt1150887	678	1
tt1150896	678	1
tt1150916	678	1
tt1150932	678	1
tt1150947	678	1
tt1160886	678	1
tt1160916	678	1
tt1170895	678	1
tt1180866	678	1
tt1180872	678	1
tt1180874	678	1
tt1180875	678	1
tt1180876	678	1
tt1180877	678	1
tt1180879	678	1
tt1180881	678	1
tt1180882	678	1
tt1180887	678	1
tt1180888	678	1
tt1180889	678	1
tt1180890	678	1
tt1180892	678	1
tt1180894	678	1
tt1180896	678	1
tt1180897	678	1
tt1180900	678	1
tt1180901	678	1
tt1180903	678	1
tt1180905	678	1
tt1180906	678	1
tt1180910	678	1
tt1180911	678	1
tt1180912	678	1
tt1180915	678	1
tt1180920	678	1
tt1180921	678	1
tt1180922	678	1
tt1180923	678	1
tt1180925	678	1
tt1180927	678	1
tt1180928	678	1
tt1180930	678	1
tt1180933	678	1
tt1180934	678	1
tt1180936	678	1
tt1180939	678	1
tt1180940	678	1
tt1180946	678	1
tt1180947	678	1
tt1180950	678	1
tt1180951	678	1
tt1180952	678	1
tt1180954	678	1
tt1180955	678	1
tt1180956	678	1
tt1180960	678	1
tt1180962	678	1
tt1180963	678	1
tt1180964	678	1
tt1180965	678	1
tt1180967	678	1
tt1180968	678	1
tt1180969	678	1
tt1180975	678	1
cs1150265	679	1
cs1170321	679	1
cs1170360	679	1
cs5170401	679	1
cs5170405	679	1
ee1130483	679	1
ee1140421	679	1
ee1150080	679	1
ee1150421	679	1
ee1150422	679	1
ee1150432	679	1
ee1150436	679	1
ee1150441	679	1
ee1150443	679	1
ee1150445	679	1
ee1150447	679	1
ee1150449	679	1
ee1150450	679	1
ee1150451	679	1
ee1150456	679	1
ee1150463	679	1
ee1150475	679	1
ee1150487	679	1
ee1150492	679	1
ee1150493	679	1
ee1150691	679	1
ee1150730	679	1
ee1150908	679	1
ee1160050	679	1
ee1160071	679	1
ee1160107	679	1
ee1160411	679	1
ee1160415	679	1
ee1160416	679	1
ee1160417	679	1
ee1160419	679	1
ee1160420	679	1
ee1160422	679	1
ee1160423	679	1
ee1160425	679	1
ee1160426	679	1
ee1160427	679	1
ee1160428	679	1
ee1160429	679	1
ee1160430	679	1
ee1160431	679	1
ee1160432	679	1
ee1160434	679	1
ee1160435	679	1
ee1160437	679	1
ee1160438	679	1
ee1160439	679	1
ee1160440	679	1
ee1160441	679	1
ee1160442	679	1
ee1160443	679	1
ee1160444	679	1
ee1160445	679	1
ee1160446	679	1
ee1160447	679	1
ee1160448	679	1
ee1160450	679	1
ee1160451	679	1
ee1160452	679	1
ee1160453	679	1
ee1160454	679	1
ee1160455	679	1
ee1160456	679	1
ee1160457	679	1
ee1160458	679	1
ee1160459	679	1
ee1160460	679	1
ee1160461	679	1
ee1160462	679	1
ee1160463	679	1
ee1160464	679	1
ee1160465	679	1
ee1160466	679	1
ee1160468	679	1
ee1160469	679	1
ee1160470	679	1
ee1160471	679	1
ee1160473	679	1
ee1160474	679	1
ee1160475	679	1
ee1160476	679	1
ee1160477	679	1
ee1160478	679	1
ee1160479	679	1
ee1160481	679	1
ee1160482	679	1
ee1160483	679	1
ee1160484	679	1
ee1160499	679	1
ee1160571	679	1
ee1160825	679	1
ee1160835	679	1
ee1170448	679	1
ee1170452	679	1
ee1170565	679	1
ee3140503	679	1
ee3150522	679	1
ee3150523	679	1
ee3150535	679	1
ee3150536	679	1
ee3150898	679	1
ee3160042	679	1
ee3160220	679	1
ee3160240	679	1
ee3160490	679	1
ee3160493	679	1
ee3160494	679	1
ee3160495	679	1
ee3160496	679	1
ee3160497	679	1
ee3160498	679	1
ee3160500	679	1
ee3160501	679	1
ee3160502	679	1
ee3160503	679	1
ee3160504	679	1
ee3160507	679	1
ee3160508	679	1
ee3160509	679	1
ee3160510	679	1
ee3160511	679	1
ee3160514	679	1
ee3160515	679	1
ee3160516	679	1
ee3160517	679	1
ee3160518	679	1
ee3160519	679	1
ee3160520	679	1
ee3160521	679	1
ee3160522	679	1
ee3160524	679	1
ee3160525	679	1
ee3160526	679	1
ee3160527	679	1
ee3160529	679	1
ee3160530	679	1
ee3160531	679	1
ee3160532	679	1
ee3160533	679	1
ee3160534	679	1
ee3170525	679	1
ee3170549	679	1
ee3170555	679	1
mt1140593	679	1
mt1150587	679	1
mt1150602	679	1
mt1170755	679	1
mt6130583	679	1
mt6150552	679	1
mt6150557	679	1
mt6150562	679	1
mt6150570	679	1
cs1170346	680	1
ph1090715	680	1
ph1130836	680	1
ph1150814	680	1
ph1150823	680	1
ph1160563	680	1
ph1160564	680	1
ph1160586	680	1
ph1160596	680	1
ph1160599	680	1
ph1170801	680	1
ph1170802	680	1
ph1170803	680	1
ph1170804	680	1
ph1170805	680	1
ph1170806	680	1
ph1170807	680	1
ph1170808	680	1
ph1170810	680	1
ph1170811	680	1
ph1170812	680	1
ph1170813	680	1
ph1170814	680	1
ph1170815	680	1
ph1170816	680	1
ph1170818	680	1
ph1170819	680	1
ph1170820	680	1
ph1170821	680	1
ph1170822	680	1
ph1170823	680	1
ph1170824	680	1
ph1170826	680	1
ph1170827	680	1
ph1170828	680	1
ph1170829	680	1
ph1170830	680	1
ph1170831	680	1
ph1170832	680	1
ph1170833	680	1
ph1170834	680	1
ph1170835	680	1
ph1170838	680	1
ph1170839	680	1
ph1170840	680	1
ph1170841	680	1
ph1170843	680	1
ph1170844	680	1
ph1170845	680	1
ph1170846	680	1
ph1170847	680	1
ph1170848	680	1
ph1170849	680	1
ph1170850	680	1
ph1170851	680	1
ph1170853	680	1
ph1170854	680	1
ph1170856	680	1
ph1170857	680	1
ph1170858	680	1
ph1170860	680	1
ph1170942	680	1
tt1150877	680	1
tt1150938	680	1
cs1170362	681	1
cs5150284	681	1
cs5150285	681	1
ee1160429	681	1
ee1160455	681	1
ph1090715	681	1
ph1110855	681	1
ph1130836	681	1
ph1140835	681	1
ph1150789	681	1
ph1150790	681	1
ph1150791	681	1
ph1150795	681	1
ph1150798	681	1
ph1150799	681	1
ph1150803	681	1
ph1150804	681	1
ph1150809	681	1
ph1150810	681	1
ph1150811	681	1
ph1150814	681	1
ph1150816	681	1
ph1150817	681	1
ph1150818	681	1
ph1150819	681	1
ph1150825	681	1
ph1150836	681	1
ph1150841	681	1
ph1160540	681	1
ph1160542	681	1
ph1160547	681	1
ph1160552	681	1
ph1160554	681	1
ph1160557	681	1
ph1160560	681	1
ph1160563	681	1
ph1160564	681	1
ph1160570	681	1
ph1160574	681	1
ph1160578	681	1
ph1160579	681	1
ph1160581	681	1
ph1160583	681	1
ph1160584	681	1
ph1160585	681	1
ph1160586	681	1
ph1160588	681	1
ph1160589	681	1
ph1160590	681	1
ph1160591	681	1
ph1160592	681	1
ph1160593	681	1
ph1160594	681	1
ph1160595	681	1
ph1160596	681	1
ph1160599	681	1
ph1170801	681	1
ph1170802	681	1
ph1170803	681	1
ph1170804	681	1
ph1170805	681	1
ph1170806	681	1
ph1170807	681	1
ph1170808	681	1
ph1170810	681	1
ph1170811	681	1
ph1170812	681	1
ph1170813	681	1
ph1170814	681	1
ph1170815	681	1
ph1170816	681	1
ph1170818	681	1
ph1170819	681	1
ph1170820	681	1
ph1170821	681	1
ph1170822	681	1
ph1170823	681	1
ph1170824	681	1
ph1170826	681	1
ph1170827	681	1
ph1170828	681	1
ph1170829	681	1
ph1170830	681	1
ph1170831	681	1
ph1170832	681	1
ph1170833	681	1
ph1170834	681	1
ph1170835	681	1
ph1170838	681	1
ph1170839	681	1
ph1170840	681	1
ph1170841	681	1
ph1170843	681	1
ph1170844	681	1
ph1170845	681	1
ph1170846	681	1
ph1170847	681	1
ph1170848	681	1
ph1170849	681	1
ph1170850	681	1
ph1170851	681	1
ph1170853	681	1
ph1170854	681	1
ph1170856	681	1
ph1170857	681	1
ph1170858	681	1
ph1170859	681	1
ph1170860	681	1
ph1170942	681	1
tt1160842	681	1
ee3150532	682	1
ph1130827	682	1
ph1140796	682	1
ph1140824	682	1
ph1150803	682	1
ph1160552	682	1
ph1160599	682	1
ph1170801	682	1
ph1170802	682	1
ph1170803	682	1
ph1170804	682	1
ph1170805	682	1
ph1170806	682	1
ph1170807	682	1
ph1170808	682	1
ph1170810	682	1
ph1170811	682	1
ph1170812	682	1
ph1170813	682	1
ph1170814	682	1
ph1170815	682	1
ph1170816	682	1
ph1170818	682	1
ph1170819	682	1
ph1170820	682	1
ph1170821	682	1
ph1170822	682	1
ph1170823	682	1
ph1170824	682	1
ph1170826	682	1
ph1170827	682	1
ph1170828	682	1
ph1170829	682	1
ph1170830	682	1
ph1170831	682	1
ph1170832	682	1
ph1170833	682	1
ph1170834	682	1
ph1170835	682	1
ph1170838	682	1
ph1170839	682	1
ph1170840	682	1
ph1170841	682	1
ph1170843	682	1
ph1170844	682	1
ph1170845	682	1
ph1170846	682	1
ph1170847	682	1
ph1170848	682	1
ph1170849	682	1
ph1170850	682	1
ph1170851	682	1
ph1170853	682	1
ph1170854	682	1
ph1170856	682	1
ph1170857	682	1
ph1170858	682	1
ph1170859	682	1
ph1170860	682	1
ph1170942	682	1
ee1150436	683	1
ph1140824	683	1
ph1150791	683	1
ph1150792	683	1
ph1150801	683	1
ph1150802	683	1
ph1150804	683	1
ph1150806	683	1
ph1150810	683	1
ph1150815	683	1
ph1150816	683	1
ph1150817	683	1
ph1150819	683	1
ph1150823	683	1
ph1150828	683	1
ph1150829	683	1
ph1150832	683	1
ph1150833	683	1
ph1160086	683	1
ph1160540	683	1
ph1160544	683	1
ph1160547	683	1
ph1160548	683	1
ph1160550	683	1
ph1160551	683	1
ph1160553	683	1
ph1160555	683	1
ph1160557	683	1
ph1160560	683	1
ph1160561	683	1
ph1160563	683	1
ph1160564	683	1
ph1160566	683	1
ph1160568	683	1
ph1160570	683	1
ph1160572	683	1
ph1160574	683	1
ph1160575	683	1
ph1160577	683	1
ph1160578	683	1
ph1160581	683	1
ph1160583	683	1
ph1160585	683	1
ph1160586	683	1
ph1160587	683	1
ph1160589	683	1
ph1160590	683	1
ph1160591	683	1
ph1160593	683	1
ph1160594	683	1
ph1160595	683	1
ph1160596	683	1
ph1160599	683	1
ph1170802	683	1
ph1170804	683	1
ph1170826	683	1
ph1120883	684	1
ph1140796	684	1
ph1150790	684	1
ph1150791	684	1
ph1150796	684	1
ph1150798	684	1
ph1150801	684	1
ph1150803	684	1
ph1150807	684	1
ph1150808	684	1
ph1150819	684	1
ph1150831	684	1
ph1150833	684	1
ph1150838	684	1
ph1160540	684	1
ph1160542	684	1
ph1160543	684	1
ph1160544	684	1
ph1160548	684	1
ph1160549	684	1
ph1160550	684	1
ph1160551	684	1
ph1160553	684	1
ph1160554	684	1
ph1160555	684	1
ph1160557	684	1
ph1160561	684	1
ph1160563	684	1
ph1160565	684	1
ph1160566	684	1
ph1160567	684	1
ph1160569	684	1
ph1160570	684	1
ph1160572	684	1
ph1160573	684	1
ph1160574	684	1
ph1160575	684	1
ph1160577	684	1
ph1160580	684	1
ph1160581	684	1
ph1170805	684	1
ph1170807	684	1
ph1170815	684	1
ph1170823	684	1
ph1170826	684	1
ph1170830	684	1
ph1170833	684	1
ph1170838	684	1
ph1170839	684	1
ph1170840	684	1
ph1170841	684	1
ph1170846	684	1
ph1170847	684	1
ph1170850	684	1
ph1170856	684	1
ph1170859	684	1
ph1170942	684	1
ee3150532	685	1
ph1140795	685	1
ph1150782	685	1
ph1150783	685	1
ph1150785	685	1
ph1150792	685	1
ph1150793	685	1
ph1150794	685	1
ph1150797	685	1
ph1150821	685	1
ph1150823	685	1
ph1160562	685	1
ph1160566	685	1
ph1160568	685	1
ph1160573	685	1
ph1160580	685	1
ph1090715	686	1
ph1120826	686	1
ph1120883	686	1
ph1150783	686	1
ph1150785	686	1
ph1150792	686	1
ph1150794	686	1
ph1150795	686	1
ph1150809	686	1
ph1150811	686	1
ph1150818	686	1
ph1150820	686	1
ph1150824	686	1
ph1150825	686	1
ph1150827	686	1
ph1150828	686	1
ph1150834	686	1
ph1150839	686	1
ph1090715	687	1
ph1120826	687	1
ph1120883	687	1
ph1130827	687	1
ph1140795	687	1
ph1140800	687	1
ph1150785	687	1
ph1150792	687	1
ph1150794	687	1
ph1150795	687	1
ph1150816	687	1
ph1150820	687	1
ph1150821	687	1
ph1150828	687	1
ph1150834	687	1
ph1150836	687	1
ph1150838	687	1
ph1160540	687	1
ph1160542	687	1
ph1160548	687	1
ph1160579	687	1
ph1160581	687	1
ph1160584	687	1
ph1160589	687	1
ph1160591	687	1
ph1160593	687	1
ph1160595	687	1
ph1160596	687	1
ph1090715	688	1
ph1120883	688	1
ph1150783	688	1
ph1150785	688	1
ph1150794	688	1
ph1150796	688	1
ph1150804	688	1
ph1150807	688	1
ph1150809	688	1
ph1150811	688	1
ph1150816	688	1
ph1150820	688	1
ph1150821	688	1
ph1150824	688	1
ph1150840	688	1
ph1160548	688	1
ph1160562	688	1
ph1160565	688	1
ph1160572	688	1
ph1160574	688	1
ph1160583	688	1
ph1160584	688	1
ph1160586	688	1
ph1160591	688	1
ph1160596	688	1
ph1140800	689	1
ph1150812	689	1
ph1160543	689	1
ph1160544	689	1
ph1160550	689	1
ph1160551	689	1
ph1160555	689	1
ph1160568	689	1
ph1160587	689	1
tt1160842	689	1
phs177167	690	1
phs187111	690	1
phs187112	690	1
phs187113	690	1
phs187114	690	1
phs187115	690	1
phs187116	690	1
phs187117	690	1
phs187118	690	1
phs187119	690	1
phs187120	690	1
phs187121	690	1
phs187123	690	1
phs187124	690	1
phs187126	690	1
phs187127	690	1
phs187128	690	1
phs187129	690	1
phs187130	690	1
phs187133	690	1
phs187134	690	1
phs187135	690	1
phs187136	690	1
phs187137	690	1
phs187138	690	1
phs187139	690	1
phs187140	690	1
phs187141	690	1
phs187142	690	1
phs187143	690	1
phs187144	690	1
phs187145	690	1
phs187146	690	1
phs187147	690	1
phs187148	690	1
phs187149	690	1
phs187150	690	1
phs187151	690	1
phs187152	690	1
phs187153	690	1
phs187154	690	1
phs187155	690	1
phs187156	690	1
phs187157	690	1
phs187158	690	1
phs187159	690	1
phs187160	690	1
phs187161	690	1
phs187162	690	1
phs187163	690	1
phs187164	690	1
phs187165	690	1
phs177123	691	1
phs177137	691	1
phs177142	691	1
phs177159	691	1
phs177160	691	1
phs177165	691	1
phs177170	691	1
phs177173	691	1
phs177173	692	1
phs187111	692	1
phs187112	692	1
phs187113	692	1
phs187114	692	1
phs187115	692	1
phs187116	692	1
phs187117	692	1
phs187118	692	1
phs187119	692	1
phs187120	692	1
phs187121	692	1
phs187123	692	1
phs187124	692	1
phs187126	692	1
phs187127	692	1
phs187128	692	1
phs187129	692	1
phs187130	692	1
phs187133	692	1
phs187134	692	1
phs187135	692	1
phs187136	692	1
phs187137	692	1
phs187138	692	1
phs187139	692	1
phs187140	692	1
phs187141	692	1
phs187142	692	1
phs187143	692	1
phs187144	692	1
phs187145	692	1
phs187146	692	1
phs187148	692	1
phs187149	692	1
phs187150	692	1
phs187151	692	1
phs187152	692	1
phs187153	692	1
phs187154	692	1
phs187155	692	1
phs187156	692	1
phs187158	692	1
phs187159	692	1
phs187160	692	1
phs187161	692	1
phs187162	692	1
phs187163	692	1
phs187164	692	1
phs187165	692	1
phs167153	693	1
phs177167	693	1
phs177173	693	1
phs187111	693	1
phs187112	693	1
phs187113	693	1
phs187114	693	1
phs187115	693	1
phs187116	693	1
phs187117	693	1
phs187118	693	1
phs187119	693	1
phs187120	693	1
phs187121	693	1
phs187123	693	1
phs187124	693	1
phs187126	693	1
phs187127	693	1
phs187128	693	1
phs187129	693	1
phs187130	693	1
phs187133	693	1
phs187134	693	1
phs187135	693	1
phs187136	693	1
phs187137	693	1
phs187138	693	1
phs187139	693	1
phs187140	693	1
phs187141	693	1
phs187142	693	1
phs187143	693	1
phs187144	693	1
phs187145	693	1
phs187146	693	1
phs187147	693	1
phs187148	693	1
phs187149	693	1
phs187150	693	1
phs187151	693	1
phs187152	693	1
phs187153	693	1
phs187154	693	1
phs187155	693	1
phs187156	693	1
phs187157	693	1
phs187158	693	1
phs187159	693	1
phs187160	693	1
phs187161	693	1
phs187162	693	1
phs187163	693	1
phs187164	693	1
phs187165	693	1
phs167153	694	1
phs177160	694	1
phs187111	694	1
phs187112	694	1
phs187113	694	1
phs187114	694	1
phs187115	694	1
phs187116	694	1
phs187117	694	1
phs187118	694	1
phs187119	694	1
phs187120	694	1
phs187121	694	1
phs187123	694	1
phs187124	694	1
phs187126	694	1
phs187127	694	1
phs187128	694	1
phs187129	694	1
phs187130	694	1
phs187133	694	1
phs187134	694	1
phs187135	694	1
phs187136	694	1
phs187137	694	1
phs187138	694	1
phs187139	694	1
phs187140	694	1
phs187141	694	1
phs187142	694	1
phs187143	694	1
phs187144	694	1
phs187145	694	1
phs187146	694	1
phs187147	694	1
phs187148	694	1
phs187149	694	1
phs187150	694	1
phs187151	694	1
phs187152	694	1
phs187153	694	1
phs187154	694	1
phs187155	694	1
phs187156	694	1
phs187157	694	1
phs187158	694	1
phs187159	694	1
phs187160	694	1
phs187161	694	1
phs187162	694	1
phs187163	694	1
phs187164	694	1
phs187165	694	1
phs177168	695	1
phs177170	695	1
phs187111	695	1
phs187112	695	1
phs187113	695	1
phs187114	695	1
phs187115	695	1
phs187116	695	1
phs187117	695	1
phs187118	695	1
phs187119	695	1
phs187120	695	1
phs187121	695	1
phs187123	695	1
phs187124	695	1
phs187126	695	1
phs187127	695	1
phs187128	695	1
phs187129	695	1
phs187130	695	1
phs187133	695	1
phs187134	695	1
phs187135	695	1
phs187136	695	1
phs187137	695	1
phs187138	695	1
phs187139	695	1
phs187140	695	1
phs187141	695	1
phs187142	695	1
phs187143	695	1
phs187144	695	1
phs187145	695	1
phs187146	695	1
phs187147	695	1
phs187148	695	1
phs187149	695	1
phs187150	695	1
phs187151	695	1
phs187152	695	1
phs187153	695	1
phs187154	695	1
phs187155	695	1
phs187156	695	1
phs187157	695	1
phs187158	695	1
phs187159	695	1
phs187160	695	1
phs187161	695	1
phs187162	695	1
phs187163	695	1
phs187164	695	1
phs187165	695	1
phs177122	696	1
phs177139	696	1
phs177142	696	1
phs177153	696	1
phs177159	696	1
phs177167	696	1
phs177123	697	1
phs177128	697	1
phs177129	697	1
phs177130	697	1
phs177131	697	1
phs177133	697	1
phs177135	697	1
phs177138	697	1
phs177140	697	1
phs177142	697	1
phs177143	697	1
phs177144	697	1
phs177146	697	1
phs177148	697	1
phs177151	697	1
phs177152	697	1
phs177154	697	1
phs177158	697	1
phs177164	697	1
phs177166	697	1
phs177170	697	1
cs5110290	698	1
mez188266	698	1
mez188273	698	1
phm182421	698	1
phm182422	698	1
phm182423	698	1
phm182424	698	1
phm182425	698	1
phm182426	698	1
phm182427	698	1
phm182428	698	1
phm182430	698	1
phm182431	698	1
phm182432	698	1
phm182433	698	1
phm182434	698	1
phm182435	698	1
phm182436	698	1
phm182438	698	1
phm182439	698	1
phm182441	698	1
phm182442	698	1
phm182443	698	1
phs167153	698	1
phs177122	698	1
phs177129	698	1
phs177133	698	1
phs177139	698	1
phs177140	698	1
phs177141	698	1
phs177153	698	1
phz188323	698	1
phz188344	698	1
phz188346	698	1
phz188353	698	1
phz188358	698	1
phz188410	698	1
phz188411	698	1
phz188415	698	1
phz188419	698	1
phz188421	698	1
phz188422	698	1
phz188423	698	1
phz188428	698	1
cyz188196	699	1
cyz188376	699	1
eez178656	699	1
eez188138	699	1
eez188163	699	1
esz188516	699	1
esz188518	699	1
phm182421	699	1
phm182422	699	1
phm182423	699	1
phm182424	699	1
phm182425	699	1
phm182426	699	1
phm182427	699	1
phm182428	699	1
phm182430	699	1
phm182431	699	1
phm182432	699	1
phm182433	699	1
phm182434	699	1
phm182435	699	1
phm182436	699	1
phm182438	699	1
phm182439	699	1
phm182441	699	1
phm182442	699	1
phm182443	699	1
phs177122	699	1
phs177139	699	1
phs177141	699	1
phs177153	699	1
phz188332	699	1
phz188334	699	1
phz188344	699	1
phz188411	699	1
phz188422	699	1
srz188606	699	1
eez188162	700	1
jop182842	700	1
ph1150815	700	1
phs177167	700	1
phz188326	700	1
phz188332	700	1
phz188344	700	1
phz188409	700	1
phz188410	700	1
phz188412	700	1
phz188413	700	1
phz188414	700	1
phz188415	700	1
phz188416	700	1
phz188417	700	1
phz188419	700	1
phz188420	700	1
phz188421	700	1
phz188422	700	1
phz188423	700	1
phz188424	700	1
phz188426	700	1
phz188427	700	1
phz188428	700	1
phz188429	700	1
phz188430	700	1
phz188435	700	1
srz188606	700	1
cyz188210	701	1
cyz188474	701	1
eez188139	701	1
ph1150806	701	1
ph1150824	701	1
ph1150836	701	1
phm172211	701	1
phm172221	701	1
phm182421	701	1
phm182422	701	1
phm182423	701	1
phm182425	701	1
phm182426	701	1
phm182427	701	1
phm182428	701	1
phm182430	701	1
phm182431	701	1
phm182432	701	1
phm182433	701	1
phm182434	701	1
phm182435	701	1
phm182436	701	1
phm182438	701	1
phm182439	701	1
phm182441	701	1
phm182443	701	1
phz188410	701	1
phz188419	701	1
phz188426	701	1
phz188428	701	1
ph1150806	702	1
phm182423	702	1
phm182424	702	1
phm182425	702	1
phm182426	702	1
phm182428	702	1
phm182430	702	1
phm182431	702	1
phm182432	702	1
phm182434	702	1
phm182438	702	1
phm182441	702	1
phm182442	702	1
phm182443	702	1
phz188416	702	1
phz188423	702	1
jop182842	703	1
ph1150790	703	1
ph1150798	703	1
ph1150816	703	1
ph1150825	703	1
phm182421	703	1
phm182422	703	1
phm182424	703	1
phm182427	703	1
phm182433	703	1
phm182435	703	1
phm182436	703	1
phm182439	703	1
phm182442	703	1
phz188418	703	1
phz188426	703	1
srz188382	703	1
cs1150207	704	1
ee1150464	704	1
ee1170485	704	1
ee3160519	704	1
eez188138	704	1
me1130682	704	1
me1160703	704	1
me2150739	704	1
mt1140045	704	1
ph1150801	704	1
ph1150802	704	1
ph1150819	704	1
ph1150838	704	1
ph1160086	704	1
ph1160543	704	1
ph1160544	704	1
ph1160550	704	1
ph1160551	704	1
ph1160555	704	1
ph1160567	704	1
ph1160568	704	1
ph1160569	704	1
ph1160577	704	1
ph1160587	704	1
ph1170850	704	1
ph1170851	704	1
ph1170860	704	1
phs177142	704	1
phs177145	704	1
phs177147	704	1
phs177150	704	1
phs177155	704	1
phs177160	704	1
phs177162	704	1
phs177163	704	1
phs177169	704	1
phs177173	704	1
phz188352	704	1
maz188258	705	1
maz188259	705	1
ph1150828	705	1
ph1160086	705	1
ph1160544	705	1
ph1160550	705	1
ph1160551	705	1
ph1160555	705	1
ph1160562	705	1
ph1160584	705	1
ph1160587	705	1
phs177121	705	1
phs177122	705	1
phs177123	705	1
phs177127	705	1
phs177128	705	1
phs177129	705	1
phs177130	705	1
phs177131	705	1
phs177132	705	1
phs177133	705	1
phs177135	705	1
phs177138	705	1
phs177139	705	1
phs177140	705	1
phs177143	705	1
phs177144	705	1
phs177145	705	1
phs177146	705	1
phs177147	705	1
phs177148	705	1
phs177150	705	1
phs177151	705	1
phs177152	705	1
phs177154	705	1
phs177155	705	1
phs177156	705	1
phs177159	705	1
phs177160	705	1
phs177161	705	1
phs177162	705	1
phs177163	705	1
phs177164	705	1
phs177165	705	1
phs177166	705	1
phs177168	705	1
phs177170	705	1
phs177172	705	1
phs177173	705	1
phs187114	705	1
phs187116	705	1
phs187118	705	1
phs187119	705	1
phs187120	705	1
phs187126	705	1
phs187129	705	1
phs187135	705	1
phs187138	705	1
phz188340	705	1
phz188352	705	1
phz188356	705	1
phz188412	705	1
phz188427	705	1
phz188435	705	1
srz188382	705	1
tt1160842	705	1
eez188138	706	1
ph1150782	706	1
ph1150787	706	1
ph1150801	706	1
ph1150805	706	1
ph1150808	706	1
ph1150812	706	1
ph1150826	706	1
ph1150837	706	1
ph1160086	706	1
ph1160551	706	1
ph1160568	706	1
ph1160577	706	1
ph1170810	706	1
phs177123	706	1
phs177127	706	1
phs177131	706	1
phs177145	706	1
phs177147	706	1
phs177150	706	1
phs177155	706	1
phs177156	706	1
phs177162	706	1
phs177163	706	1
phs177169	706	1
phs177173	706	1
phs187135	706	1
phz188325	706	1
phz188326	706	1
phz188340	706	1
phz188412	706	1
chz188316	707	1
ph1150782	707	1
ph1150787	707	1
ph1150826	707	1
ph1150837	707	1
phs177148	707	1
phs177149	707	1
phs177150	707	1
phs177172	707	1
phz188338	707	1
phz188357	707	1
phz188362	707	1
phz188435	707	1
srz188382	707	1
eez188138	708	1
pha182345	708	1
pha182347	708	1
pha182348	708	1
phs177121	708	1
phs177130	708	1
phs177131	708	1
phs177132	708	1
phs177135	708	1
phs177138	708	1
phs177143	708	1
phs177144	708	1
phs177145	708	1
phs177146	708	1
phs177148	708	1
phs177155	708	1
phs177156	708	1
phs177160	708	1
phs177161	708	1
phs177162	708	1
phs177163	708	1
phz188320	708	1
phz188328	708	1
phz188333	708	1
phz188363	708	1
phz188434	708	1
ph1150802	709	1
ph1150806	709	1
ph1150828	709	1
pha182345	709	1
pha182347	709	1
pha182348	709	1
pha182349	709	1
pha182350	709	1
pha182352	709	1
pha182353	709	1
pha182354	709	1
pha182355	709	1
pha182356	709	1
pha182358	709	1
pha182359	709	1
pha182360	709	1
pha182362	709	1
pha182365	709	1
pha182366	709	1
pha182867	709	1
phs177123	709	1
phz182357	709	1
phz188326	709	1
phz188332	709	1
phz188361	709	1
phz188431	709	1
phz188433	709	1
jop172313	710	1
jop172627	710	1
ph1150828	710	1
ph1160583	710	1
pha182345	710	1
pha182347	710	1
pha182348	710	1
pha182349	710	1
pha182350	710	1
pha182352	710	1
pha182353	710	1
pha182354	710	1
pha182355	710	1
pha182356	710	1
pha182358	710	1
pha182359	710	1
pha182360	710	1
pha182362	710	1
pha182365	710	1
pha182366	710	1
pha182867	710	1
phs177158	710	1
phz182357	710	1
phz188333	710	1
phz188345	710	1
phz188350	710	1
phz188364	710	1
phz188365	710	1
phz188413	710	1
phz188424	710	1
phz188432	710	1
bmt182308	711	1
bmz188298	711	1
jop172622	711	1
jop172679	711	1
jop172833	711	1
jop172844	711	1
jop172845	711	1
jop172846	711	1
jop182819	711	1
jop182841	711	1
jop182860	711	1
jop182866	711	1
jop182877	711	1
ph1150789	711	1
ph1150797	711	1
ph1150798	711	1
ph1150841	711	1
ph1160549	711	1
pha172192	711	1
pha172194	711	1
pha172203	711	1
pha172204	711	1
pha172208	711	1
pha172852	711	1
pha182349	711	1
pha182355	711	1
pha182358	711	1
pha182359	711	1
pha182365	711	1
phm172898	711	1
phs177158	711	1
phz188319	711	1
phz188357	711	1
phz188370	711	1
phz188424	711	1
jop172622	712	1
jop172627	712	1
pha172190	712	1
pha172828	712	1
pha182345	712	1
pha182347	712	1
pha182353	712	1
pha182365	712	1
pha182366	712	1
phs177149	712	1
phs177158	712	1
phz162024	712	1
phz162025	712	1
phz178375	712	1
phz178620	712	1
phz182357	712	1
phz188320	712	1
phz188328	712	1
phz188363	712	1
phz188413	712	1
jop172622	713	1
jop172625	713	1
jop172627	713	1
jop172679	713	1
jop172833	713	1
jop172844	713	1
jop172845	713	1
jop172846	713	1
pha182347	713	1
pha182350	713	1
pha182352	713	1
pha182354	713	1
pha182356	713	1
pha182359	713	1
pha182360	713	1
pha182362	713	1
pha182365	713	1
pha182867	713	1
phz188336	713	1
phz188341	713	1
phz188345	713	1
phz188350	713	1
phz188430	713	1
phz188434	713	1
pha182349	714	1
pha182350	714	1
pha182354	714	1
pha182355	714	1
pha182359	714	1
pha182360	714	1
pha182362	714	1
pha182867	714	1
idz178095	715	1
ph1150806	715	1
pha172189	715	1
pha172201	715	1
pha172203	715	1
pha172204	715	1
pha172205	715	1
pha172206	715	1
pha172207	715	1
pha172829	715	1
pha182345	715	1
pha182352	715	1
pha182353	715	1
pha182355	715	1
pha182358	715	1
phm172226	715	1
phz188350	715	1
jop182037	716	1
jop182090	716	1
jop182091	716	1
jop182444	716	1
jop182445	716	1
jop182448	716	1
jop182449	716	1
jop182450	716	1
jop182451	716	1
jop182452	716	1
jop182453	716	1
jop182454	716	1
jop182710	716	1
jop182711	716	1
jop182712	716	1
jop182819	716	1
jop182841	716	1
jop182860	716	1
jop182866	716	1
jop182871	716	1
jop182877	716	1
jop182880	716	1
phz188359	716	1
phz188425	716	1
phz188431	716	1
phz188433	716	1
eey187526	717	1
esz188515	717	1
mas177063	717	1
mas177069	717	1
mas177073	717	1
mas177075	717	1
mas177080	717	1
mas177083	717	1
mas177084	717	1
mas177085	717	1
mas177086	717	1
mas177089	717	1
mas177091	717	1
mas177094	717	1
mas177097	717	1
mas177098	717	1
mas177100	717	1
mas177101	717	1
mas177102	717	1
mas177104	717	1
mas177106	717	1
mas177107	717	1
mas177108	717	1
mas177111	717	1
mas177114	717	1
maz188259	717	1
maz188260	717	1
phs177128	717	1
phs177152	717	1
phs177158	717	1
phs177159	717	1
phs177165	717	1
phs177166	717	1
phs177168	717	1
phs177169	717	1
phz188329	717	1
phz188330	717	1
phz188348	717	1
phz188364	717	1
phz188365	717	1
phz188369	717	1
phz188409	717	1
phz188410	717	1
phz188412	717	1
phz188413	717	1
phz188414	717	1
phz188415	717	1
phz188416	717	1
phz188417	717	1
phz188418	717	1
phz188419	717	1
phz188420	717	1
phz188422	717	1
phz188423	717	1
phz188424	717	1
phz188425	717	1
phz188426	717	1
phz188429	717	1
phz188430	717	1
phz188431	717	1
phz188432	717	1
phz188433	717	1
phz188361	718	1
jop172313	719	1
jop172622	719	1
jop172624	719	1
jop172627	719	1
jop172679	719	1
jop172833	719	1
jop172844	719	1
jop172845	719	1
jop172846	719	1
jop182841	719	1
jop182871	719	1
jop182877	719	1
phz188359	719	1
phz188361	719	1
phz188425	719	1
phz188434	719	1
bb1180001	720	1
bb1180002	720	1
bb1180004	720	1
bb1180005	720	1
bb1180006	720	1
bb1180008	720	1
bb1180012	720	1
bb1180016	720	1
bb1180017	720	1
bb1180019	720	1
bb1180020	720	1
bb1180021	720	1
bb1180023	720	1
bb1180024	720	1
bb1180025	720	1
bb1180029	720	1
bb1180030	720	1
bb1180031	720	1
bb1180032	720	1
bb1180034	720	1
bb1180036	720	1
bb1180037	720	1
bb1180038	720	1
bb1180039	720	1
bb1180041	720	1
bb1180042	720	1
bb1180044	720	1
bb1180045	720	1
bb1180046	720	1
bb5180051	720	1
bb5180052	720	1
bb5180053	720	1
bb5180054	720	1
bb5180056	720	1
bb5180057	720	1
bb5180058	720	1
bb5180060	720	1
bb5180063	720	1
bb5180064	720	1
bb5180066	720	1
ce1130384	720	1
ce1180074	720	1
ce1180076	720	1
ce1180078	720	1
ce1180079	720	1
ce1180083	720	1
ce1180084	720	1
ce1180085	720	1
ce1180086	720	1
ce1180090	720	1
ce1180094	720	1
ce1180095	720	1
ce1180101	720	1
ce1180104	720	1
ce1180106	720	1
ce1180108	720	1
ce1180110	720	1
ce1180112	720	1
ce1180117	720	1
ce1180118	720	1
ce1180120	720	1
ce1180124	720	1
ce1180132	720	1
ce1180133	720	1
ce1180141	720	1
ce1180146	720	1
ce1180148	720	1
ce1180149	720	1
ce1180150	720	1
ce1180151	720	1
ce1180154	720	1
ce1180157	720	1
ce1180158	720	1
ce1180163	720	1
ce1180164	720	1
ce1180165	720	1
ce1180167	720	1
ce1180168	720	1
ce1180169	720	1
ce1180177	720	1
ch1180187	720	1
ch1180189	720	1
ch1180191	720	1
ch1180193	720	1
ch1180194	720	1
ch1180195	720	1
ch1180197	720	1
ch1180199	720	1
ch1180200	720	1
ch1180201	720	1
ch1180202	720	1
ch1180203	720	1
ch1180205	720	1
ch1180208	720	1
ch1180210	720	1
ch1180211	720	1
ch1180213	720	1
ch1180214	720	1
ch1180215	720	1
ch1180216	720	1
ch1180218	720	1
ch1180220	720	1
ch1180221	720	1
ch1180225	720	1
ch1180227	720	1
ch1180229	720	1
ch1180230	720	1
ch1180234	720	1
ch1180239	720	1
ch1180242	720	1
ch1180247	720	1
ch1180248	720	1
ch1180249	720	1
ch1180250	720	1
ch1180251	720	1
ch1180252	720	1
ch1180253	720	1
ch1180254	720	1
ch1180255	720	1
ch1180257	720	1
ch1180259	720	1
ch1180260	720	1
ch1180261	720	1
ch7180271	720	1
ch7180272	720	1
ch7180277	720	1
ch7180278	720	1
ch7180279	720	1
ch7180280	720	1
ch7180281	720	1
ch7180282	720	1
ch7180285	720	1
ch7180287	720	1
ch7180288	720	1
ch7180290	720	1
ch7180293	720	1
ch7180295	720	1
ch7180296	720	1
ch7180297	720	1
ch7180299	720	1
ch7180301	720	1
ch7180302	720	1
ch7180304	720	1
ch7180305	720	1
ch7180306	720	1
ch7180311	720	1
ch7180315	720	1
ch7180317	720	1
cs1180322	720	1
cs1180323	720	1
cs1180327	720	1
cs1180330	720	1
cs1180332	720	1
cs1180334	720	1
cs1180335	720	1
cs1180340	720	1
cs1180344	720	1
cs1180345	720	1
cs1180346	720	1
cs1180348	720	1
cs1180350	720	1
cs1180351	720	1
cs1180355	720	1
cs1180360	720	1
cs1180362	720	1
cs1180366	720	1
cs1180370	720	1
cs1180372	720	1
cs1180373	720	1
cs1180374	720	1
cs1180377	720	1
cs1180380	720	1
cs1180381	720	1
cs1180385	720	1
cs1180386	720	1
cs1180389	720	1
cs1180390	720	1
cs1180392	720	1
cs1180393	720	1
cs1180394	720	1
cs1180395	720	1
cs1180397	720	1
cs5180401	720	1
cs5180402	720	1
cs5180403	720	1
cs5180404	720	1
cs5180405	720	1
cs5180408	720	1
cs5180412	720	1
cs5180413	720	1
cs5180419	720	1
cs5180420	720	1
cs5180422	720	1
cs5180425	720	1
cs5180426	720	1
ee1130515	720	1
ee1180433	720	1
ee1180434	720	1
ee1180436	720	1
ee1180437	720	1
ee1180439	720	1
ee1180441	720	1
ee1180443	720	1
ee1180444	720	1
ee1180446	720	1
ee1180447	720	1
ee1180452	720	1
ee1180454	720	1
ee1180456	720	1
ee1180458	720	1
ee1180459	720	1
ee1180460	720	1
ee1180467	720	1
ee1180468	720	1
ee1180469	720	1
ee1180470	720	1
ee1180473	720	1
ee1180476	720	1
ee1180482	720	1
ee1180483	720	1
ee1180485	720	1
ee1180486	720	1
ee1180489	720	1
ee1180491	720	1
ee1180492	720	1
ee1180496	720	1
ee1180497	720	1
ee1180504	720	1
ee1180505	720	1
ee1180506	720	1
ee1180509	720	1
ee1180511	720	1
ee2110522	720	1
ee3180521	720	1
ee3180523	720	1
ee3180524	720	1
ee3180525	720	1
ee3180527	720	1
ee3180528	720	1
ee3180530	720	1
ee3180531	720	1
ee3180533	720	1
ee3180535	720	1
ee3180541	720	1
ee3180542	720	1
ee3180545	720	1
ee3180546	720	1
ee3180547	720	1
ee3180549	720	1
ee3180553	720	1
ee3180554	720	1
ee3180556	720	1
ee3180557	720	1
ee3180560	720	1
ee3180562	720	1
ee3180563	720	1
ee3180565	720	1
ee3180569	720	1
me1170563	720	1
me1180581	720	1
me1180582	720	1
me1180584	720	1
me1180588	720	1
me1180589	720	1
me1180590	720	1
me1180592	720	1
me1180597	720	1
me1180599	720	1
me1180600	720	1
me1180603	720	1
me1180604	720	1
me1180606	720	1
me1180608	720	1
me1180611	720	1
me1180612	720	1
me1180614	720	1
me1180615	720	1
me1180616	720	1
me1180622	720	1
me1180624	720	1
me1180626	720	1
me1180627	720	1
me1180628	720	1
me1180630	720	1
me1180631	720	1
me1180633	720	1
me1180634	720	1
me1180641	720	1
me1180644	720	1
me1180645	720	1
me1180650	720	1
me1180651	720	1
me1180654	720	1
me1180656	720	1
me1180658	720	1
me2140721	720	1
me2150717	720	1
me2160799	720	1
me2180661	720	1
me2180663	720	1
me2180664	720	1
me2180666	720	1
me2180668	720	1
me2180670	720	1
me2180672	720	1
me2180674	720	1
me2180675	720	1
me2180676	720	1
me2180678	720	1
me2180679	720	1
me2180681	720	1
me2180682	720	1
me2180687	720	1
me2180688	720	1
me2180690	720	1
me2180691	720	1
me2180692	720	1
me2180694	720	1
me2180695	720	1
me2180696	720	1
me2180698	720	1
me2180699	720	1
me2180700	720	1
me2180701	720	1
me2180703	720	1
me2180706	720	1
me2180707	720	1
me2180709	720	1
me2180712	720	1
me2180713	720	1
me2180715	720	1
me2180716	720	1
me2180717	720	1
me2180718	720	1
me2180719	720	1
me2180722	720	1
me2180723	720	1
me2180725	720	1
me2180726	720	1
me2180728	720	1
me2180730	720	1
me2180732	720	1
me2180733	720	1
me2180736	720	1
mt1160640	720	1
mt1180738	720	1
mt1180739	720	1
mt1180742	720	1
mt1180744	720	1
mt1180746	720	1
mt1180748	720	1
mt1180755	720	1
mt1180757	720	1
mt1180758	720	1
mt1180760	720	1
mt1180762	720	1
mt1180770	720	1
mt6180777	720	1
mt6180783	720	1
mt6180785	720	1
mt6180790	720	1
mt6180793	720	1
mt6180794	720	1
mt6180795	720	1
mt6180797	720	1
ph1160597	720	1
ph1170801	720	1
ph1170852	720	1
ph1180801	720	1
ph1180802	720	1
ph1180803	720	1
ph1180810	720	1
ph1180812	720	1
ph1180813	720	1
ph1180814	720	1
ph1180817	720	1
ph1180820	720	1
ph1180821	720	1
ph1180822	720	1
ph1180825	720	1
ph1180826	720	1
ph1180827	720	1
ph1180828	720	1
ph1180830	720	1
ph1180831	720	1
ph1180832	720	1
ph1180833	720	1
ph1180836	720	1
ph1180838	720	1
ph1180839	720	1
ph1180843	720	1
ph1180844	720	1
ph1180845	720	1
ph1180846	720	1
ph1180848	720	1
ph1180850	720	1
ph1180851	720	1
ph1180852	720	1
ph1180854	720	1
ph1180858	720	1
ph1180859	720	1
ph1180860	720	1
tt1150937	720	1
tt1170895	720	1
tt1180866	720	1
tt1180872	720	1
tt1180874	720	1
tt1180875	720	1
tt1180876	720	1
tt1180877	720	1
tt1180879	720	1
tt1180881	720	1
tt1180882	720	1
tt1180887	720	1
tt1180888	720	1
tt1180889	720	1
tt1180890	720	1
tt1180892	720	1
tt1180894	720	1
tt1180896	720	1
tt1180897	720	1
tt1180900	720	1
tt1180901	720	1
tt1180903	720	1
tt1180905	720	1
tt1180906	720	1
tt1180910	720	1
tt1180911	720	1
tt1180912	720	1
tt1180915	720	1
tt1180920	720	1
tt1180921	720	1
tt1180922	720	1
tt1180923	720	1
tt1180925	720	1
tt1180927	720	1
tt1180928	720	1
tt1180930	720	1
tt1180933	720	1
tt1180934	720	1
tt1180936	720	1
tt1180939	720	1
tt1180940	720	1
tt1180946	720	1
tt1180947	720	1
tt1180950	720	1
tt1180951	720	1
tt1180952	720	1
tt1180954	720	1
tt1180955	720	1
tt1180956	720	1
tt1180960	720	1
tt1180962	720	1
tt1180963	720	1
tt1180964	720	1
tt1180965	720	1
tt1180967	720	1
tt1180968	720	1
tt1180969	720	1
tt1180975	720	1
ph1140800	721	1
ph1140824	721	1
ph1150798	721	1
ph1170802	721	1
ph1170803	721	1
ph1170804	721	1
ph1170805	721	1
ph1170806	721	1
ph1170807	721	1
ph1170808	721	1
ph1170810	721	1
ph1170811	721	1
ph1170812	721	1
ph1170813	721	1
ph1170814	721	1
ph1170815	721	1
ph1170816	721	1
ph1170820	721	1
ph1170821	721	1
ph1170822	721	1
ph1170824	721	1
ph1170826	721	1
ph1170829	721	1
ph1170830	721	1
ph1170832	721	1
ph1170833	721	1
ph1170834	721	1
ph1170838	721	1
ph1170839	721	1
ph1170840	721	1
ph1170841	721	1
ph1170843	721	1
ph1170844	721	1
ph1170845	721	1
ph1170846	721	1
ph1170847	721	1
ph1170849	721	1
ph1170850	721	1
ph1170851	721	1
ph1170853	721	1
ph1170854	721	1
ph1170856	721	1
ph1170857	721	1
ph1170858	721	1
ph1170859	721	1
ph1170860	721	1
ph1170942	721	1
ph1140794	722	1
ph1140800	722	1
ph1150799	722	1
ph1150801	722	1
ph1150810	722	1
ph1150817	722	1
ph1150819	722	1
ph1150833	722	1
ph1160086	722	1
ph1160540	722	1
ph1160542	722	1
ph1160543	722	1
ph1160544	722	1
ph1160547	722	1
ph1160548	722	1
ph1160549	722	1
ph1160550	722	1
ph1160551	722	1
ph1160553	722	1
ph1160554	722	1
ph1160555	722	1
ph1160557	722	1
ph1160560	722	1
ph1160561	722	1
ph1160562	722	1
ph1160563	722	1
ph1160564	722	1
ph1160565	722	1
ph1160566	722	1
ph1160567	722	1
ph1160568	722	1
ph1160569	722	1
ph1160570	722	1
ph1160572	722	1
ph1160573	722	1
ph1160574	722	1
ph1160575	722	1
ph1160577	722	1
ph1160578	722	1
ph1160579	722	1
ph1160580	722	1
ph1160581	722	1
ph1160583	722	1
ph1160584	722	1
ph1160585	722	1
ph1160586	722	1
ph1160587	722	1
ph1160589	722	1
ph1160590	722	1
ph1160591	722	1
ph1160592	722	1
ph1160593	722	1
ph1160594	722	1
ph1160595	722	1
ph1160596	722	1
ph1160599	722	1
phs187111	723	1
phs187112	723	1
phs187113	723	1
phs187114	723	1
phs187115	723	1
phs187116	723	1
phs187117	723	1
phs187118	723	1
phs187119	723	1
phs187120	723	1
phs187121	723	1
phs187123	723	1
phs187124	723	1
phs187126	723	1
phs187127	723	1
phs187128	723	1
phs187129	723	1
phs187130	723	1
phs187133	723	1
phs187134	723	1
phs187135	723	1
phs187136	723	1
phs187137	723	1
phs187138	723	1
phs187139	723	1
phs187140	723	1
phs187141	723	1
phs187142	723	1
phs187143	723	1
phs187144	723	1
phs187145	723	1
phs187146	723	1
phs187147	723	1
phs187148	723	1
phs187149	723	1
phs187150	723	1
phs187151	723	1
phs187152	723	1
phs187153	723	1
phs187154	723	1
phs187155	723	1
phs187156	723	1
phs187157	723	1
phs187158	723	1
phs187159	723	1
phs187160	723	1
phs187161	723	1
phs187162	723	1
phs187163	723	1
phs187164	723	1
phs187165	723	1
phm182421	724	1
phm182422	724	1
phm182423	724	1
phm182424	724	1
phm182425	724	1
phm182426	724	1
phm182427	724	1
phm182428	724	1
phm182430	724	1
phm182431	724	1
phm182432	724	1
phm182433	724	1
phm182434	724	1
phm182435	724	1
phm182436	724	1
phm182438	724	1
phm182439	724	1
phm182441	724	1
phm182442	724	1
phm182443	724	1
pha182345	725	1
pha182347	725	1
pha182348	725	1
pha182349	725	1
pha182350	725	1
pha182352	725	1
pha182353	725	1
pha182354	725	1
pha182355	725	1
pha182356	725	1
pha182358	725	1
pha182359	725	1
pha182360	725	1
pha182362	725	1
pha182365	725	1
pha182366	725	1
pha182867	725	1
phz182357	725	1
pha182356	726	1
bb1150042	727	1
bb5140012	727	1
bb5150003	727	1
bb5160002	727	1
bb5160010	727	1
ch7140194	727	1
cs1150237	727	1
cs1160379	727	1
cs5150281	727	1
ee1150462	727	1
ee1160040	727	1
ee1160160	727	1
ee3150509	727	1
me1160224	727	1
me1160678	727	1
me1160693	727	1
me1160829	727	1
me2150772	727	1
mt6130581	727	1
mt6150570	727	1
ph1130827	727	1
ph1130867	727	1
ph1140795	727	1
ph1140796	727	1
ph1140800	727	1
ph1140835	727	1
ph1150782	727	1
ph1150784	727	1
ph1150785	727	1
ph1150786	727	1
ph1150788	727	1
ph1150791	727	1
ph1150797	727	1
ph1150801	727	1
ph1150802	727	1
ph1150803	727	1
ph1150808	727	1
ph1150811	727	1
ph1150813	727	1
ph1150818	727	1
ph1150821	727	1
ph1150825	727	1
ph1150838	727	1
ph1160542	727	1
ph1160544	727	1
ph1160553	727	1
ph1160554	727	1
ph1160557	727	1
ph1160560	727	1
ph1160564	727	1
ph1160568	727	1
ph1160581	727	1
ph1160585	727	1
ph1160586	727	1
ph1160587	727	1
ph1160589	727	1
ph1160590	727	1
ph1160591	727	1
ph1160593	727	1
ph1160594	727	1
ph1160595	727	1
ph1160597	727	1
ph1160599	727	1
ph1170802	727	1
ph1170805	727	1
ph1170808	727	1
ph1170811	727	1
ph1170814	727	1
ph1170820	727	1
ph1170824	727	1
ph1170838	727	1
ph1170840	727	1
ph1170850	727	1
ph1170854	727	1
ph1170856	727	1
tt1130975	727	1
ph1140824	728	1
ph1150787	728	1
ch1150107	729	1
bb1150046	730	1
ce1160219	730	1
ce1160230	730	1
ce1170118	730	1
ce1170156	730	1
ch1130071	730	1
ch1150140	730	1
ch1160121	730	1
ch1160125	730	1
ch7120152	730	1
ch7130156	730	1
ch7150163	730	1
ch7150171	730	1
ch7150175	730	1
ee1100479	730	1
ee1130447	730	1
ee1150462	730	1
ee1150464	730	1
ee1160456	730	1
ee1160465	730	1
ee1160475	730	1
ee3130571	730	1
ee3150501	730	1
ee3150511	730	1
ee3160510	730	1
ee3160515	730	1
ee3160516	730	1
ee3160517	730	1
ee3160524	730	1
ee3160527	730	1
jes172168	730	1
jes172173	730	1
mas177068	730	1
me1120651	730	1
me1150684	730	1
me1160705	730	1
me2140761	730	1
me2150709	730	1
mt1150591	730	1
ph1140805	730	1
ph1150824	730	1
ph1150829	730	1
rdz188641	730	1
rdz188646	730	1
rdz188648	730	1
rdz188652	730	1
tt1100909	730	1
tt1120302	730	1
tt1130982	730	1
bb1150022	731	1
bb1150034	731	1
bb1150036	731	1
bb1150037	731	1
ce1150345	731	1
ce1150347	731	1
ce1150359	731	1
ce1150360	731	1
ce1150364	731	1
ce1150372	731	1
ce1150386	731	1
ce1150399	731	1
ce1150401	731	1
cs1150214	731	1
cs1150216	731	1
cs1150223	731	1
cs5140288	731	1
ee1150423	731	1
ee1160415	731	1
ee1160416	731	1
ee1160417	731	1
ee1160420	731	1
ee1160426	731	1
ee1160428	731	1
ee1160445	731	1
ee1160451	731	1
ee1160458	731	1
ee1160459	731	1
ee1160461	731	1
ee1160464	731	1
ee1160468	731	1
ee1160473	731	1
ee1160480	731	1
ee1160484	731	1
ee1160835	731	1
ee3160240	731	1
ee3160512	731	1
eep182107	731	1
eep182108	731	1
jid172539	731	1
mas177064	731	1
mas177065	731	1
mas177068	731	1
me1130653	731	1
me1150627	731	1
me1150628	731	1
me1150630	731	1
me1150631	731	1
me1150684	731	1
me1150687	731	1
me1150692	731	1
me2140761	731	1
me2140772	731	1
me2150742	731	1
mt1150595	731	1
mt1150598	731	1
mt1150603	731	1
mt1150607	731	1
mt1150610	731	1
mt1150725	731	1
mt1160268	731	1
mt1160620	731	1
mt1160623	731	1
mt1160624	731	1
mt1160626	731	1
mt1160628	731	1
mt1160629	731	1
mt1160630	731	1
mt1160631	731	1
mt1160635	731	1
mt6150551	731	1
mt6150552	731	1
mt6150556	731	1
mt6150557	731	1
mt6150558	731	1
mt6150562	731	1
mt6150563	731	1
mt6150565	731	1
ph1150805	731	1
ph1160572	731	1
phs177138	731	1
rdz188637	731	1
rdz188638	731	1
rdz188647	731	1
rdz188649	731	1
rdz188651	731	1
tt1150859	731	1
tt1150883	731	1
tt1150896	731	1
tt1150905	731	1
tt1150928	731	1
tt1150948	731	1
tt1160838	731	1
tt1160840	731	1
tt1160841	731	1
tt1160869	731	1
tt1160913	731	1
tt1160919	731	1
tt1160923	731	1
bb1150028	732	1
ce1150315	732	1
ce1150331	732	1
ce1150386	732	1
ce1150387	732	1
ce1150398	732	1
ce1150401	732	1
ce1150403	732	1
ce1160200	732	1
ce1160202	732	1
ce1160203	732	1
ce1160205	732	1
ce1160207	732	1
ce1160211	732	1
ce1160212	732	1
ce1160214	732	1
ce1160243	732	1
ce1160254	732	1
ce1160266	732	1
ce1160271	732	1
ce1170090	732	1
cev172475	732	1
ch1150092	732	1
ch1150094	732	1
ch1160120	732	1
ch7150160	732	1
cs1150260	732	1
cs5150459	732	1
cys177014	732	1
ee1150426	732	1
ee3150513	732	1
ee3150898	732	1
mas177063	732	1
mas177064	732	1
mas177073	732	1
mas177075	732	1
mas177077	732	1
mas177082	732	1
mas177083	732	1
mas177090	732	1
mas177096	732	1
mas177099	732	1
mas177103	732	1
mas177104	732	1
mas177105	732	1
mas177109	732	1
mas177111	732	1
mas177113	732	1
me1130653	732	1
me1150687	732	1
ph1150841	732	1
ph1160589	732	1
ph1160593	732	1
ph1160595	732	1
phs177147	732	1
phs177151	732	1
phs177156	732	1
phs177160	732	1
qiz188617	732	1
rdz188644	732	1
rdz188649	732	1
rdz188651	732	1
tt1150942	732	1
tt1150952	732	1
bb1140024	733	1
bb1150032	733	1
bb5120033	733	1
ce1140333	733	1
ce1140395	733	1
ce1150313	733	1
ce1150345	733	1
ce1150355	733	1
ce1160207	733	1
ce1160214	733	1
ce1160222	733	1
ce1160242	733	1
ce1160273	733	1
ce1160274	733	1
ce1160277	733	1
ce1160278	733	1
ce1160282	733	1
ce1160283	733	1
ce1160285	733	1
ce1160286	733	1
ce1160290	733	1
ce1160291	733	1
ce1160295	733	1
ce1160297	733	1
ce1160298	733	1
ch1150087	733	1
ch1150096	733	1
cs1150216	733	1
cs1150258	733	1
cs1150260	733	1
cs1160313	733	1
cys177001	733	1
ee1150423	733	1
ee1150477	733	1
ee1150483	733	1
ee3150535	733	1
mas167104	733	1
mas177069	733	1
mas177071	733	1
mas177072	733	1
mas177074	733	1
mas177076	733	1
mas177080	733	1
mas177081	733	1
mas177082	733	1
mas177085	733	1
mas177086	733	1
mas177089	733	1
mas177090	733	1
mas177091	733	1
mas177094	733	1
mas177095	733	1
mas177096	733	1
mas177097	733	1
mas177098	733	1
mas177099	733	1
mas177100	733	1
mas177103	733	1
mas177106	733	1
mas177107	733	1
mas177108	733	1
mas177109	733	1
mas177113	733	1
me1150630	733	1
me1150656	733	1
me1150676	733	1
me1160681	733	1
me1160717	733	1
me1160720	733	1
me1160732	733	1
me1160733	733	1
me1160734	733	1
me1160735	733	1
me1160736	733	1
me1160737	733	1
me2150709	733	1
me2150734	733	1
me2160783	733	1
me2160803	733	1
mt6150552	733	1
ph1150814	733	1
rdz188637	733	1
rdz188638	733	1
rdz188640	733	1
rdz188644	733	1
rdz188645	733	1
rdz188646	733	1
rdz188651	733	1
tt1150864	733	1
tt1150872	733	1
tt1150876	733	1
tt1150883	733	1
tt1150930	733	1
tt1150936	733	1
tt1160663	733	1
tt1160876	733	1
tt1160886	733	1
tt1160912	733	1
tt1160913	733	1
tt1160916	733	1
tt1160919	733	1
tt1160923	733	1
bb1150046	734	1
bb1160056	734	1
bb5150013	734	1
ce1140303	734	1
ce1150347	734	1
ce1150376	734	1
ce1160263	734	1
ch1140121	734	1
ch1150107	734	1
ch1160076	734	1
ch7150188	734	1
chz188091	734	1
cs1160348	734	1
cyz188206	734	1
ee1140437	734	1
ee1160475	734	1
ee3160516	734	1
ee3160517	734	1
me1130653	734	1
me1150665	734	1
mt6140557	734	1
ph1150792	734	1
rdz188247	734	1
rdz188639	734	1
rdz188642	734	1
rdz188643	734	1
rdz188647	734	1
rdz188650	734	1
tt1140932	734	1
tt1150892	734	1
bb1150032	735	1
bb5130006	735	1
ce1150347	735	1
ch1150083	735	1
ch1150107	735	1
ch7140159	735	1
ch7140172	735	1
ch7150151	735	1
cs1160341	735	1
cs1160367	735	1
cs1160372	735	1
cs1160373	735	1
cs1160374	735	1
cs1160375	735	1
cs1160523	735	1
cyz188472	735	1
ee1150432	735	1
ee1150477	735	1
ee1150483	735	1
ee1150494	735	1
ee3160161	735	1
me1130653	735	1
me1150396	735	1
me1150678	735	1
me1150684	735	1
me2150706	735	1
me2150749	735	1
mt1150606	735	1
mt6140557	735	1
mt6140562	735	1
mt6140566	735	1
mt6140568	735	1
rdz188247	735	1
rdz188641	735	1
rdz188642	735	1
rdz188652	735	1
tt1120302	735	1
tt1140169	735	1
tt1140185	735	1
tt1150856	735	1
tt1150859	735	1
tt1150897	735	1
tt1150934	735	1
tt1150942	735	1
bb5120024	736	1
ce1150336	736	1
ce1150376	736	1
ce1160256	736	1
ce1160275	736	1
ce1160279	736	1
ce1160287	736	1
ce1160303	736	1
cev172436	736	1
cev172439	736	1
cev172716	736	1
ch1150105	736	1
ch1150133	736	1
ch1160070	736	1
ch1160083	736	1
ch1160110	736	1
ch1160111	736	1
ch1160118	736	1
ch1160122	736	1
ch1160126	736	1
ch1160129	736	1
ch1160138	736	1
ch7160188	736	1
ch7160193	736	1
cs1160378	736	1
ee1160430	736	1
ee1160444	736	1
ee3150509	736	1
ee3160161	736	1
ee3160240	736	1
ee3160496	736	1
ee3160498	736	1
mas177062	736	1
mas177069	736	1
mas177071	736	1
mas177076	736	1
mas177081	736	1
me1150228	736	1
me1150678	736	1
me1150690	736	1
me1160710	736	1
me1160714	736	1
me2120795	736	1
me2150710	736	1
me2150742	736	1
me2160792	736	1
me2160807	736	1
me2160809	736	1
me2160811	736	1
mt6160658	736	1
rdz188642	736	1
rdz188647	736	1
rdz188650	736	1
tt1150897	736	1
tt1160908	736	1
bey187511	737	1
bez188240	737	1
ce1150392	737	1
chz188091	737	1
rdz188639	737	1
rdz188642	737	1
rdz188643	737	1
rdz188645	737	1
rdz188647	737	1
rdz188648	737	1
rdz188650	737	1
rdz188652	737	1
tt1140890	737	1
bb1150041	738	1
bb5140005	738	1
ch1150076	738	1
ch1150087	738	1
ch7140154	738	1
ch7140179	738	1
cs1150246	738	1
cs1150261	738	1
cs5150285	738	1
ee1150481	738	1
me1150633	738	1
me1160674	738	1
me1160689	738	1
me2160749	738	1
mt1150319	738	1
mt6140561	738	1
ph1140800	738	1
tt1140905	738	1
tt1140944	738	1
tt1150883	738	1
tt1150918	738	1
tt1160860	738	1
tt1160875	738	1
tt1160877	738	1
tt1160883	738	1
tt1160896	738	1
tt1160904	738	1
tt1160906	738	1
tt1160907	738	1
tt1160912	738	1
tt1170874	738	1
tt1170876	738	1
bb1150056	739	1
ce1140381	739	1
ce1150345	739	1
ce1150348	739	1
ce1150366	739	1
ce1160213	739	1
ce1160293	739	1
ch1130070	739	1
ch1150106	739	1
ch1150135	739	1
ch1160109	739	1
ch1160111	739	1
ch1160113	739	1
ch1160114	739	1
ch7140155	739	1
ch7140198	739	1
cs1150255	739	1
ee3150512	739	1
mt1160647	739	1
mt6140571	739	1
mt6150373	739	1
mt6160653	739	1
ph1160589	739	1
ph1160593	739	1
ph1160595	739	1
tt1140932	739	1
tt1150854	739	1
tt1150863	739	1
tt1150887	739	1
tt1150901	739	1
tt1150939	739	1
tt1160866	739	1
tt1160919	739	1
bb1150037	740	1
bb1150041	740	1
bb1150056	740	1
ce1140243	740	1
ch1160077	740	1
ch1160099	740	1
ch1160100	740	1
ch1160675	740	1
ch7140154	740	1
ch7160158	740	1
cs5150102	740	1
ee1150451	740	1
ee1150478	740	1
ee1150487	740	1
ee1150489	740	1
ee1150490	740	1
ee1160410	740	1
ee3160501	740	1
me1150633	740	1
me2150753	740	1
me2160783	740	1
tt1140887	740	1
tt1150886	740	1
tt1160852	740	1
tt1160854	740	1
tt1160861	740	1
tt1160863	740	1
tt1160870	740	1
tt1160871	740	1
tt1160882	740	1
tt1160885	740	1
tt1160886	740	1
tt1160887	740	1
tt1160926	740	1
bb1150025	741	1
bb1150034	741	1
bb1160057	741	1
ch1160112	741	1
ch7140170	741	1
ch7150162	741	1
ch7150189	741	1
cs1150203	741	1
cs1150259	741	1
cs1150264	741	1
cs1160339	741	1
cs5140280	741	1
cs5140282	741	1
cs5150286	741	1
ee1150477	741	1
ee1160428	741	1
ee3150512	741	1
me1150228	741	1
me1150633	741	1
me2150715	741	1
me2150758	741	1
me2150760	741	1
me2150771	741	1
me2160793	741	1
mt6160652	741	1
ph1150797	741	1
tt1150853	741	1
tt1150932	741	1
tt1160822	741	1
tt1160823	741	1
tt1160898	741	1
bb1150038	742	1
bb1150040	742	1
bb5140013	742	1
bb5140015	742	1
ce1150338	742	1
ch1150078	742	1
ch1150105	742	1
ch1150133	742	1
ch1150142	742	1
cs5140286	742	1
cs5140288	742	1
cs5160789	742	1
ee1150492	742	1
ee1150691	742	1
ee1160450	742	1
ee1160454	742	1
ee1160461	742	1
ee3150112	742	1
ee3160240	742	1
me1150631	742	1
me1150633	742	1
me1150662	742	1
me1150688	742	1
me1160688	742	1
me2160792	742	1
me2160806	742	1
ph1150800	742	1
ph1150809	742	1
tt1150861	742	1
tt1150869	742	1
tt1150882	742	1
tt1150888	742	1
tt1150891	742	1
tt1150894	742	1
tt1150896	742	1
tt1150897	742	1
tt1150925	742	1
tt1150935	742	1
tt1160895	742	1
tt1160900	742	1
tt1160908	742	1
tt1160910	742	1
tt1160911	742	1
tt1170887	742	1
bly187520	743	1
bly187545	743	1
blz188277	743	1
blz188278	743	1
blz188462	743	1
blz188463	743	1
blz188464	743	1
blz188465	743	1
blz188466	743	1
blz188467	743	1
blz188468	743	1
blz188469	743	1
blz188470	743	1
bb1160029	744	1
bb1160039	744	1
ch1160112	744	1
bly177509	745	1
bly177510	745	1
bly177511	745	1
bly177512	745	1
bly177541	745	1
bb5110049	746	1
bb5170052	746	1
ce1140303	746	1
ce1150329	746	1
ce1150350	746	1
ce1160206	746	1
ce1160207	746	1
ch1150141	746	1
ch1160128	746	1
ch1170086	746	1
ch1170087	746	1
ch1170186	746	1
ch1170187	746	1
ch1170188	746	1
ch1170191	746	1
ch1170192	746	1
ch1170193	746	1
ch1170195	746	1
ch1170196	746	1
ch1170197	746	1
ch1170199	746	1
ch1170202	746	1
ch1170203	746	1
ch1170204	746	1
ch1170205	746	1
ch1170206	746	1
ch1170208	746	1
ch1170209	746	1
ch1170210	746	1
ch1170211	746	1
ch1170214	746	1
ch1170215	746	1
ch1170216	746	1
ch1170218	746	1
ch1170222	746	1
ch1170223	746	1
ch1170224	746	1
ch1170225	746	1
ch1170226	746	1
ch1170227	746	1
ch1170228	746	1
ch1170229	746	1
ch1170231	746	1
ch1170232	746	1
ch1170233	746	1
ch1170234	746	1
ch1170236	746	1
ch1170237	746	1
ch1170238	746	1
ch1170239	746	1
ch1170240	746	1
ch1170241	746	1
ch1170242	746	1
ch1170243	746	1
ch1170244	746	1
ch1170246	746	1
ch1170247	746	1
ch1170248	746	1
ch1170251	746	1
ch1170252	746	1
ch1170253	746	1
ch1170254	746	1
ch1170255	746	1
ch1170256	746	1
ch1170257	746	1
ch1170258	746	1
ch1170259	746	1
ch1170260	746	1
ch1170309	746	1
ch7150161	746	1
ch7170271	746	1
ch7170272	746	1
ch7170273	746	1
ch7170274	746	1
ch7170276	746	1
ch7170277	746	1
ch7170279	746	1
ch7170280	746	1
ch7170282	746	1
ch7170283	746	1
ch7170284	746	1
ch7170285	746	1
ch7170286	746	1
ch7170288	746	1
ch7170289	746	1
ch7170290	746	1
ch7170292	746	1
ch7170293	746	1
ch7170294	746	1
ch7170295	746	1
ch7170296	746	1
ch7170298	746	1
ch7170299	746	1
ch7170300	746	1
ch7170301	746	1
ch7170302	746	1
ch7170303	746	1
ch7170304	746	1
ch7170305	746	1
ch7170307	746	1
ch7170308	746	1
ch7170310	746	1
ch7170312	746	1
ch7170314	746	1
cs1170219	746	1
cs1170336	746	1
cs1170339	746	1
cs1170341	746	1
cs1170487	746	1
cs1170503	746	1
cs1170589	746	1
cs5120299	746	1
cs5160414	746	1
ee1150080	746	1
ee1150431	746	1
ee1150441	746	1
ee1150447	746	1
ee1150467	746	1
ee1150471	746	1
ee1150475	746	1
ee1150908	746	1
ee1160441	746	1
ee1160442	746	1
ee1170093	746	1
ee1170249	746	1
ee1170306	746	1
ee1170345	746	1
ee1170434	746	1
ee1170435	746	1
ee1170438	746	1
ee1170439	746	1
ee1170442	746	1
ee1170443	746	1
ee1170444	746	1
ee1170446	746	1
ee1170447	746	1
ee1170448	746	1
ee1170449	746	1
ee1170450	746	1
ee1170451	746	1
ee1170457	746	1
ee1170460	746	1
ee1170462	746	1
ee1170463	746	1
ee1170466	746	1
ee1170467	746	1
ee1170469	746	1
ee1170470	746	1
ee1170471	746	1
ee1170473	746	1
ee1170474	746	1
ee1170475	746	1
ee1170477	746	1
ee1170478	746	1
ee1170479	746	1
ee1170480	746	1
ee1170483	746	1
ee1170486	746	1
ee1170494	746	1
ee1170495	746	1
ee1170496	746	1
ee1170498	746	1
ee1170500	746	1
ee1170501	746	1
ee1170502	746	1
ee1170505	746	1
ee1170584	746	1
ee1170597	746	1
ee1170599	746	1
ee1170608	746	1
ee1170809	746	1
ee1170937	746	1
me1150651	746	1
me1150653	746	1
me1150680	746	1
me1150689	746	1
me1170021	746	1
me1170061	746	1
me1170158	746	1
me1170561	746	1
me1170562	746	1
me1170566	746	1
me1170568	746	1
me1170569	746	1
me1170571	746	1
me1170572	746	1
me1170573	746	1
me1170574	746	1
me1170575	746	1
me1170576	746	1
me1170578	746	1
me1170579	746	1
me1170580	746	1
me1170581	746	1
me1170582	746	1
me1170583	746	1
me1170585	746	1
me1170586	746	1
me1170587	746	1
me1170588	746	1
me1170590	746	1
me1170591	746	1
me1170592	746	1
me1170593	746	1
me1170594	746	1
me1170595	746	1
me1170596	746	1
me1170598	746	1
me1170600	746	1
me1170601	746	1
me1170603	746	1
me1170604	746	1
me1170605	746	1
me1170607	746	1
me1170611	746	1
me1170612	746	1
me1170613	746	1
me1170614	746	1
me1170615	746	1
me1170616	746	1
me1170617	746	1
me1170618	746	1
me1170619	746	1
me1170620	746	1
me1170621	746	1
me1170622	746	1
me1170623	746	1
me1170624	746	1
me1170625	746	1
me1170626	746	1
me1170627	746	1
me1170628	746	1
me1170651	746	1
me1170698	746	1
me1170702	746	1
me1170950	746	1
me1170960	746	1
me1170967	746	1
me2150739	746	1
me2170641	746	1
me2170642	746	1
me2170643	746	1
me2170644	746	1
me2170645	746	1
me2170646	746	1
me2170647	746	1
me2170649	746	1
me2170650	746	1
me2170652	746	1
me2170653	746	1
me2170655	746	1
me2170656	746	1
me2170657	746	1
me2170658	746	1
me2170660	746	1
me2170661	746	1
me2170662	746	1
me2170663	746	1
me2170664	746	1
me2170665	746	1
me2170666	746	1
me2170667	746	1
me2170668	746	1
me2170669	746	1
me2170670	746	1
me2170672	746	1
me2170673	746	1
me2170675	746	1
me2170676	746	1
me2170677	746	1
me2170678	746	1
me2170680	746	1
me2170681	746	1
me2170683	746	1
me2170684	746	1
me2170685	746	1
me2170686	746	1
me2170687	746	1
me2170689	746	1
me2170690	746	1
me2170691	746	1
me2170692	746	1
me2170693	746	1
me2170694	746	1
me2170695	746	1
me2170696	746	1
me2170697	746	1
me2170699	746	1
me2170700	746	1
me2170701	746	1
me2170703	746	1
me2170705	746	1
me2170706	746	1
me2170707	746	1
me2170842	746	1
mt1170721	746	1
mt1170725	746	1
mt1170726	746	1
mt1170728	746	1
mt1170730	746	1
mt1170742	746	1
mt1170751	746	1
mt5100631	746	1
mt5120593	746	1
mt6160652	746	1
mt6170773	746	1
mt6170776	746	1
ph1140796	746	1
ph1150784	746	1
ph1150817	746	1
ph1150819	746	1
ph1160540	746	1
ph1160542	746	1
ph1160553	746	1
ph1160561	746	1
ph1160579	746	1
ph1160585	746	1
ph1160586	746	1
ph1160589	746	1
ph1160590	746	1
ph1160591	746	1
ph1160592	746	1
ph1160593	746	1
ph1160594	746	1
ph1160595	746	1
ph1160597	746	1
ph1160599	746	1
ph1170801	746	1
ph1170822	746	1
tt1150927	746	1
tt1160917	746	1
tt1160918	746	1
tt1160921	746	1
tt1160922	746	1
tt1160924	746	1
tt1170875	746	1
tt1170876	746	1
tt1170878	746	1
tt1170879	746	1
tt1170880	746	1
tt1170881	746	1
tt1170882	746	1
tt1170883	746	1
tt1170884	746	1
tt1170886	746	1
tt1170888	746	1
tt1170889	746	1
tt1170890	746	1
tt1170892	746	1
tt1170897	746	1
tt1170898	746	1
tt1170899	746	1
tt1170904	746	1
tt1170905	746	1
tt1170906	746	1
tt1170907	746	1
tt1170908	746	1
tt1170911	746	1
tt1170912	746	1
tt1170913	746	1
tt1170914	746	1
tt1170915	746	1
tt1170916	746	1
tt1170917	746	1
tt1170919	746	1
tt1170921	746	1
tt1170922	746	1
tt1170923	746	1
tt1170925	746	1
tt1170926	746	1
tt1170927	746	1
tt1170928	746	1
tt1170931	746	1
tt1170932	746	1
tt1170933	746	1
tt1170934	746	1
tt1170935	746	1
tt1170936	746	1
tt1170939	746	1
tt1170940	746	1
tt1170941	746	1
tt1170944	746	1
tt1170945	746	1
tt1170947	746	1
tt1170949	746	1
tt1170951	746	1
tt1170952	746	1
tt1170953	746	1
tt1170955	746	1
tt1170957	746	1
tt1170959	746	1
tt1170962	746	1
tt1170963	746	1
tt1170964	746	1
tt1170965	746	1
tt1170966	746	1
tt1170970	746	1
tt1170972	746	1
tt1170973	746	1
tt1170974	746	1
tt1170975	746	1
tt1170976	746	1
bb1150031	747	1
ch1140071	747	1
ch1160112	747	1
ch1160117	747	1
ee3150521	747	1
ee3150526	747	1
me2140721	747	1
mt5120605	747	1
mt6150559	747	1
mt6150564	747	1
ph1130827	747	1
tt1140115	747	1
tt1140228	747	1
tt1150857	747	1
bly187520	748	1
blz188466	748	1
blz188467	748	1
ch1160117	748	1
chz188079	748	1
ee3150538	748	1
ee3150541	748	1
mt1150582	748	1
mt1150589	748	1
srz188304	748	1
bb1150021	749	1
bez188441	749	1
bly187545	749	1
blz188462	749	1
blz188463	749	1
blz188464	749	1
blz188465	749	1
blz188466	749	1
blz188467	749	1
blz188468	749	1
blz188469	749	1
blz188470	749	1
cyz188213	749	1
ee3150538	749	1
bb1150056	750	1
bb5140015	750	1
bb5160004	750	1
bly187545	750	1
blz188463	750	1
blz188464	750	1
blz188465	750	1
blz188469	750	1
blz188470	750	1
ce1130323	750	1
ee1120464	750	1
ee3150538	750	1
bly187545	751	1
blz188462	751	1
blz188463	751	1
blz188465	751	1
blz188467	751	1
blz188468	751	1
blz188469	751	1
blz188470	751	1
chz188074	751	1
chz188079	751	1
chz188497	751	1
cyz188203	751	1
cyz188206	751	1
cyz188213	751	1
cyz188218	751	1
cyz188279	751	1
cyz188472	751	1
ee1120464	751	1
srz188304	751	1
bb5110029	752	1
bb1150051	753	1
bb1150053	753	1
bb1150064	753	1
bb1150065	753	1
blz188464	753	1
ch1160117	754	1
ch1170297	754	1
cs1170375	754	1
cs1170387	754	1
ee1120464	754	1
ee3150538	754	1
mt1170753	754	1
chz188074	755	1
bb5140005	756	1
blz188462	756	1
blz188468	756	1
ce1150312	756	1
ce1150359	756	1
ce1150372	756	1
ch1150089	756	1
ch1150098	756	1
ch1160346	756	1
cs1160338	756	1
ee1130445	756	1
jpt172617	756	1
me1120658	756	1
me1150678	756	1
me1150692	756	1
tt1130982	756	1
tt1150883	756	1
tt1150896	756	1
tt1150901	756	1
tt1160869	756	1
tt1160891	756	1
bb1140039	757	1
bey177533	757	1
bly187520	757	1
blz188466	757	1
ch1150098	757	1
cs5140278	757	1
ee1120464	757	1
ee3160505	757	1
siy167532	759	1
siy177545	759	1
siy177546	759	1
siy187502	759	1
cs5140281	760	1
cs5140282	760	1
cs5150276	760	1
cs5150279	760	1
cs5150293	760	1
cs5150294	760	1
cs5150297	760	1
csy187551	760	1
mcs172075	760	1
mcs182009	760	1
mcs182011	760	1
mcs182013	760	1
mcs182014	760	1
mcs182016	760	1
mcs182017	760	1
mcs182019	760	1
mcs182020	760	1
mcs182021	760	1
mcs182024	760	1
mcs182092	760	1
mcs182093	760	1
mcs182094	760	1
mcs182095	760	1
mcs182120	760	1
mcs182140	760	1
mcs182141	760	1
mcs182142	760	1
mcs182143	760	1
mcs182144	760	1
mcs182839	760	1
mcs182840	760	1
siy187538	760	1
vst189735	760	1
cs5140278	761	1
tt1100909	762	1
tt1100974	762	1
tt1100909	763	1
tt1100974	763	1
tt1160915	764	1
tt1150929	765	1
tt1130911	766	1
tt1130937	766	1
tt1140887	766	1
tt1140896	766	1
tt1150855	766	1
tt1150878	766	1
tt1150879	766	1
tt1150892	766	1
tt1150901	766	1
tt1150903	766	1
tt1150904	766	1
tt1150907	766	1
tt1150939	766	1
tt1150948	766	1
tt1130979	767	1
tt1130982	767	1
tt1150852	767	1
tt1150862	767	1
tt1150863	767	1
tt1150869	767	1
tt1150874	767	1
tt1150900	767	1
tt1150909	767	1
tt1150916	767	1
tt1150917	767	1
tt1150920	767	1
tt1150921	767	1
tt1150922	767	1
tt1150926	767	1
tt1150933	767	1
tt1150941	767	1
tt1150943	767	1
tt1150947	767	1
tte162228	768	1
tte172042	768	1
tte172043	768	1
tte172044	768	1
tte172049	768	1
tte172050	768	1
tte172051	768	1
tte172052	768	1
tte172053	768	1
tte172054	768	1
tte172055	768	1
tte172056	768	1
tte172057	768	1
tte172058	768	1
tte172059	768	1
tte172516	768	1
tte172519	768	1
tte172520	768	1
tte172522	768	1
tte172523	768	1
tte172524	768	1
tte172691	768	1
ttf172026	769	1
ttf172027	769	1
ttf172028	769	1
ttf172029	769	1
ttf172031	769	1
ttf172032	769	1
ttf172033	769	1
ttf172034	769	1
ttf172035	769	1
ttf172036	769	1
ttf172037	769	1
ttf172038	769	1
ttf172039	769	1
ttf172040	769	1
ttf172690	769	1
ttc172061	770	1
ttc172062	770	1
ttc172063	770	1
ttc172064	770	1
ttc172066	770	1
ttc172067	770	1
ttc172068	770	1
ttc172069	770	1
ttc172070	770	1
ttc172830	770	1
bb5140004	771	1
tt1130937	771	1
tt1130982	771	1
tt1140169	771	1
tt1140185	771	1
tt1140588	771	1
tt1140911	771	1
tt1140912	771	1
tt1140932	771	1
tt1140937	771	1
tt1140944	771	1
tt1150866	771	1
tt1150867	771	1
tt1150872	771	1
tt1150875	771	1
tt1150878	771	1
tt1150883	771	1
tt1150884	771	1
tt1150886	771	1
tt1150917	771	1
tt1150919	771	1
tt1150921	771	1
tt1150924	771	1
tt1150926	771	1
tt1150934	771	1
tt1150951	771	1
tt1150952	771	1
tt1160821	771	1
tt1160831	771	1
tt1160909	771	1
tt1160914	771	1
tt1160917	771	1
tt1160918	771	1
tt1160921	771	1
tt1160922	771	1
tt1160924	771	1
tt1170871	771	1
tt1170873	771	1
tt1170874	771	1
tt1170875	771	1
tt1170876	771	1
tt1170877	771	1
tt1170878	771	1
tt1170879	771	1
tt1170880	771	1
tt1170881	771	1
tt1170882	771	1
tt1170883	771	1
tt1170884	771	1
tt1170885	771	1
tt1170886	771	1
tt1170887	771	1
tt1170888	771	1
tt1170889	771	1
tt1170890	771	1
tt1170891	771	1
tt1170892	771	1
tt1170893	771	1
tt1170897	771	1
tt1170898	771	1
tt1170899	771	1
tt1170900	771	1
tt1170901	771	1
tt1170902	771	1
tt1170903	771	1
tt1170904	771	1
tt1170905	771	1
tt1170906	771	1
tt1170907	771	1
tt1170908	771	1
tt1170909	771	1
tt1170910	771	1
tt1170911	771	1
tt1170912	771	1
tt1170914	771	1
tt1170915	771	1
tt1170916	771	1
tt1170918	771	1
tt1170919	771	1
tt1170920	771	1
tt1170921	771	1
tt1170922	771	1
tt1170923	771	1
tt1170925	771	1
tt1170926	771	1
tt1170927	771	1
tt1170928	771	1
tt1170929	771	1
tt1170931	771	1
tt1170932	771	1
tt1170933	771	1
tt1170934	771	1
tt1170935	771	1
tt1170936	771	1
tt1170939	771	1
tt1170940	771	1
tt1170941	771	1
tt1170943	771	1
tt1170944	771	1
tt1170945	771	1
tt1170947	771	1
tt1170948	771	1
tt1170949	771	1
tt1170951	771	1
tt1170952	771	1
tt1170953	771	1
tt1170955	771	1
tt1170956	771	1
tt1170957	771	1
tt1170958	771	1
tt1170959	771	1
tt1170961	771	1
tt1170962	771	1
tt1170963	771	1
tt1170964	771	1
tt1170965	771	1
tt1170966	771	1
tt1170968	771	1
tt1170969	771	1
tt1170970	771	1
tt1170972	771	1
tt1170973	771	1
tt1170974	771	1
tt1170975	771	1
tt1170976	771	1
tt1140905	772	1
tt1150882	772	1
tt1150913	772	1
tt1150924	772	1
tt1160821	772	1
tt1160831	772	1
tt1160909	772	1
tt1160914	772	1
tt1160917	772	1
tt1160918	772	1
tt1160921	772	1
tt1160922	772	1
tt1160924	772	1
tt1170871	772	1
tt1170873	772	1
tt1170874	772	1
tt1170875	772	1
tt1170876	772	1
tt1170877	772	1
tt1170878	772	1
tt1170879	772	1
tt1170880	772	1
tt1170881	772	1
tt1170882	772	1
tt1170883	772	1
tt1170884	772	1
tt1170885	772	1
tt1170886	772	1
tt1170887	772	1
tt1170888	772	1
tt1170889	772	1
tt1170890	772	1
tt1170891	772	1
tt1170892	772	1
tt1170893	772	1
tt1170896	772	1
tt1170897	772	1
tt1170898	772	1
tt1170899	772	1
tt1170900	772	1
tt1170901	772	1
tt1170902	772	1
tt1170903	772	1
tt1170904	772	1
tt1170905	772	1
tt1170906	772	1
tt1170907	772	1
tt1170908	772	1
tt1170909	772	1
tt1170910	772	1
tt1170911	772	1
tt1170912	772	1
tt1170913	772	1
tt1170914	772	1
tt1170915	772	1
tt1170916	772	1
tt1170917	772	1
tt1170918	772	1
tt1170919	772	1
tt1170920	772	1
tt1170921	772	1
tt1170922	772	1
tt1170923	772	1
tt1170924	772	1
tt1170925	772	1
tt1170926	772	1
tt1170927	772	1
tt1170928	772	1
tt1170929	772	1
tt1170930	772	1
tt1170931	772	1
tt1170932	772	1
tt1170933	772	1
tt1170934	772	1
tt1170935	772	1
tt1170936	772	1
tt1170939	772	1
tt1170940	772	1
tt1170941	772	1
tt1170943	772	1
tt1170944	772	1
tt1170945	772	1
tt1170947	772	1
tt1170948	772	1
tt1170949	772	1
tt1170951	772	1
tt1170952	772	1
tt1170953	772	1
tt1170954	772	1
tt1170955	772	1
tt1170956	772	1
tt1170957	772	1
tt1170958	772	1
tt1170959	772	1
tt1170961	772	1
tt1170962	772	1
tt1170963	772	1
tt1170964	772	1
tt1170965	772	1
tt1170966	772	1
tt1170968	772	1
tt1170969	772	1
tt1170970	772	1
tt1170971	772	1
tt1170972	772	1
tt1170973	772	1
tt1170974	772	1
tt1170975	772	1
tt1170976	772	1
bb5140004	773	1
tt1140115	773	1
tt1140169	773	1
tt1140228	773	1
tt1140912	773	1
tt1150857	773	1
tt1150867	773	1
tt1150878	773	1
tt1150882	773	1
tt1150913	773	1
tt1150924	773	1
tt1160821	773	1
tt1160831	773	1
tt1160840	773	1
tt1160846	773	1
tt1160848	773	1
tt1160890	773	1
tt1160909	773	1
tt1160914	773	1
tt1160917	773	1
tt1160918	773	1
tt1160921	773	1
tt1160922	773	1
tt1160924	773	1
tt1170871	773	1
tt1170873	773	1
tt1170874	773	1
tt1170875	773	1
tt1170876	773	1
tt1170877	773	1
tt1170878	773	1
tt1170879	773	1
tt1170880	773	1
tt1170881	773	1
tt1170882	773	1
tt1170883	773	1
tt1170884	773	1
tt1170885	773	1
tt1170886	773	1
tt1170887	773	1
tt1170888	773	1
tt1170889	773	1
tt1170890	773	1
tt1170891	773	1
tt1170892	773	1
tt1170893	773	1
tt1170896	773	1
tt1170897	773	1
tt1170898	773	1
tt1170899	773	1
tt1170900	773	1
tt1170901	773	1
tt1170902	773	1
tt1170903	773	1
tt1170904	773	1
tt1170905	773	1
tt1170906	773	1
tt1170907	773	1
tt1170908	773	1
tt1170909	773	1
tt1170910	773	1
tt1170911	773	1
tt1170912	773	1
tt1170913	773	1
tt1170914	773	1
tt1170915	773	1
tt1170916	773	1
tt1170917	773	1
tt1170918	773	1
tt1170919	773	1
tt1170920	773	1
tt1170921	773	1
tt1170922	773	1
tt1170923	773	1
tt1170924	773	1
tt1170925	773	1
tt1170926	773	1
tt1170927	773	1
tt1170928	773	1
tt1170929	773	1
tt1170930	773	1
tt1170931	773	1
tt1170932	773	1
tt1170933	773	1
tt1170934	773	1
tt1170935	773	1
tt1170936	773	1
tt1170939	773	1
tt1170940	773	1
tt1170941	773	1
tt1170943	773	1
tt1170944	773	1
tt1170945	773	1
tt1170947	773	1
tt1170948	773	1
tt1170949	773	1
tt1170951	773	1
tt1170952	773	1
tt1170953	773	1
tt1170954	773	1
tt1170955	773	1
tt1170956	773	1
tt1170957	773	1
tt1170958	773	1
tt1170959	773	1
tt1170961	773	1
tt1170962	773	1
tt1170963	773	1
tt1170964	773	1
tt1170965	773	1
tt1170968	773	1
tt1170969	773	1
tt1170970	773	1
tt1170971	773	1
tt1170972	773	1
tt1170973	773	1
tt1170974	773	1
tt1170975	773	1
tt1170976	773	1
tt1140905	774	1
tt1140937	774	1
tt1150903	774	1
tt1150905	774	1
tt1150913	774	1
tt1150924	774	1
tt1160821	774	1
tt1160823	774	1
tt1160826	774	1
tt1160831	774	1
tt1160837	774	1
tt1160839	774	1
tt1160840	774	1
tt1160842	774	1
tt1160845	774	1
tt1160846	774	1
tt1160847	774	1
tt1160849	774	1
tt1160850	774	1
tt1160854	774	1
tt1160857	774	1
tt1160858	774	1
tt1160859	774	1
tt1160860	774	1
tt1160864	774	1
tt1160867	774	1
tt1160868	774	1
tt1160890	774	1
tt1160893	774	1
tt1160903	774	1
tt1160909	774	1
tt1160914	774	1
tt1160917	774	1
tt1160918	774	1
tt1160921	774	1
tt1160922	774	1
tt1160924	774	1
tt1170871	774	1
tt1170873	774	1
tt1170874	774	1
tt1170875	774	1
tt1170876	774	1
tt1170877	774	1
tt1170878	774	1
tt1170879	774	1
tt1170880	774	1
tt1170881	774	1
tt1170882	774	1
tt1170883	774	1
tt1170884	774	1
tt1170885	774	1
tt1170886	774	1
tt1170887	774	1
tt1170888	774	1
tt1170889	774	1
tt1170890	774	1
tt1170891	774	1
tt1170892	774	1
tt1170893	774	1
tt1170897	774	1
tt1170898	774	1
tt1170899	774	1
tt1170900	774	1
tt1170901	774	1
tt1170902	774	1
tt1170903	774	1
tt1170904	774	1
tt1170905	774	1
tt1170906	774	1
tt1170907	774	1
tt1170908	774	1
tt1170909	774	1
tt1170910	774	1
tt1170911	774	1
tt1170912	774	1
tt1170913	774	1
tt1170914	774	1
tt1170915	774	1
tt1170916	774	1
tt1170917	774	1
tt1170918	774	1
tt1170919	774	1
tt1170920	774	1
tt1170921	774	1
tt1170922	774	1
tt1170923	774	1
tt1170924	774	1
tt1170925	774	1
tt1170926	774	1
tt1170927	774	1
tt1170928	774	1
tt1170929	774	1
tt1170930	774	1
tt1170931	774	1
tt1170932	774	1
tt1170933	774	1
tt1170934	774	1
tt1170935	774	1
tt1170936	774	1
tt1170939	774	1
tt1170940	774	1
tt1170941	774	1
tt1170943	774	1
tt1170944	774	1
tt1170945	774	1
tt1170948	774	1
tt1170949	774	1
tt1170951	774	1
tt1170952	774	1
tt1170953	774	1
tt1170954	774	1
tt1170955	774	1
tt1170956	774	1
tt1170957	774	1
tt1170958	774	1
tt1170959	774	1
tt1170961	774	1
tt1170962	774	1
tt1170963	774	1
tt1170964	774	1
tt1170966	774	1
tt1170968	774	1
tt1170969	774	1
tt1170970	774	1
tt1170971	774	1
tt1170972	774	1
tt1170973	774	1
tt1170974	774	1
tt1170975	774	1
tt1140115	775	1
tt1140228	775	1
tt1140905	775	1
tt1150857	775	1
tt1150882	775	1
tt1150905	775	1
tt1150931	775	1
tt1160663	775	1
tt1160822	775	1
tt1160823	775	1
tt1160826	775	1
tt1160827	775	1
tt1160832	775	1
tt1160836	775	1
tt1160837	775	1
tt1160838	775	1
tt1160839	775	1
tt1160840	775	1
tt1160841	775	1
tt1160842	775	1
tt1160843	775	1
tt1160844	775	1
tt1160845	775	1
tt1160846	775	1
tt1160847	775	1
tt1160848	775	1
tt1160849	775	1
tt1160850	775	1
tt1160852	775	1
tt1160853	775	1
tt1160854	775	1
tt1160855	775	1
tt1160857	775	1
tt1160858	775	1
tt1160859	775	1
tt1160860	775	1
tt1160861	775	1
tt1160862	775	1
tt1160863	775	1
tt1160864	775	1
tt1160865	775	1
tt1160866	775	1
tt1160867	775	1
tt1160868	775	1
tt1160869	775	1
tt1160870	775	1
tt1160871	775	1
tt1160872	775	1
tt1160873	775	1
tt1160874	775	1
tt1160875	775	1
tt1160876	775	1
tt1160877	775	1
tt1160878	775	1
tt1160879	775	1
tt1160880	775	1
tt1160881	775	1
tt1160882	775	1
tt1160883	775	1
tt1160884	775	1
tt1160885	775	1
tt1160886	775	1
tt1160887	775	1
tt1160888	775	1
tt1160889	775	1
tt1160891	775	1
tt1160892	775	1
tt1160893	775	1
tt1160894	775	1
tt1160895	775	1
tt1160897	775	1
tt1160898	775	1
tt1160899	775	1
tt1160900	775	1
tt1160902	775	1
tt1160903	775	1
tt1160904	775	1
tt1160905	775	1
tt1160906	775	1
tt1160907	775	1
tt1160908	775	1
tt1160910	775	1
tt1160911	775	1
tt1160912	775	1
tt1160913	775	1
tt1160915	775	1
tt1160916	775	1
tt1160919	775	1
tt1160923	775	1
tt1160925	775	1
tt1160926	775	1
tt1160927	775	1
tt1100909	776	1
tt1130937	776	1
tt1130982	776	1
tt1140115	776	1
tt1140169	776	1
tt1140185	776	1
tt1140228	776	1
tt1140588	776	1
tt1140905	776	1
tt1140912	776	1
tt1140937	776	1
tt1140944	776	1
tt1150851	776	1
tt1150853	776	1
tt1150854	776	1
tt1150855	776	1
tt1150856	776	1
tt1150857	776	1
tt1150858	776	1
tt1150862	776	1
tt1150863	776	1
tt1150864	776	1
tt1150865	776	1
tt1150866	776	1
tt1150867	776	1
tt1150872	776	1
tt1150878	776	1
tt1150879	776	1
tt1150882	776	1
tt1150884	776	1
tt1150886	776	1
tt1150888	776	1
tt1150889	776	1
tt1150896	776	1
tt1150897	776	1
tt1150904	776	1
tt1150905	776	1
tt1150907	776	1
tt1150916	776	1
tt1150918	776	1
tt1150921	776	1
tt1150926	776	1
tt1150933	776	1
tt1150934	776	1
tt1150936	776	1
tt1150937	776	1
tt1150939	776	1
tt1150941	776	1
tt1150943	776	1
tt1150947	776	1
tt1150948	776	1
tt1150953	776	1
tt1160663	776	1
tt1160822	776	1
tt1160823	776	1
tt1160826	776	1
tt1160827	776	1
tt1160832	776	1
tt1160834	776	1
tt1160836	776	1
tt1160837	776	1
tt1160838	776	1
tt1160839	776	1
tt1160840	776	1
tt1160841	776	1
tt1160842	776	1
tt1160843	776	1
tt1160844	776	1
tt1160845	776	1
tt1160846	776	1
tt1160847	776	1
tt1160848	776	1
tt1160849	776	1
tt1160850	776	1
tt1160852	776	1
tt1160854	776	1
tt1160855	776	1
tt1160857	776	1
tt1160858	776	1
tt1160859	776	1
tt1160862	776	1
tt1160865	776	1
tt1160866	776	1
tt1160868	776	1
tt1160869	776	1
tt1160870	776	1
tt1160871	776	1
tt1160873	776	1
tt1160874	776	1
tt1160875	776	1
tt1160876	776	1
tt1160877	776	1
tt1160878	776	1
tt1160879	776	1
tt1160880	776	1
tt1160881	776	1
tt1160882	776	1
tt1160883	776	1
tt1160884	776	1
tt1160885	776	1
tt1160886	776	1
tt1160887	776	1
tt1160888	776	1
tt1160889	776	1
tt1160891	776	1
tt1160894	776	1
tt1160895	776	1
tt1160896	776	1
tt1160897	776	1
tt1160899	776	1
tt1160900	776	1
tt1160902	776	1
tt1160903	776	1
tt1160904	776	1
tt1160905	776	1
tt1160906	776	1
tt1160907	776	1
tt1160908	776	1
tt1160911	776	1
tt1160912	776	1
tt1160913	776	1
tt1160915	776	1
tt1160916	776	1
tt1160919	776	1
tt1160923	776	1
tt1160925	776	1
tt1160926	776	1
tt1160927	776	1
tt1130937	777	1
tt1130975	777	1
tt1140115	777	1
tt1140228	777	1
tt1140588	777	1
tt1140870	777	1
tt1140911	777	1
tt1150857	777	1
tt1150865	777	1
tt1150866	777	1
tt1150867	777	1
tt1150882	777	1
tt1150883	777	1
tt1150884	777	1
tt1150886	777	1
tt1150892	777	1
tt1150894	777	1
tt1150900	777	1
tt1150905	777	1
tt1150926	777	1
tt1150939	777	1
tt1150943	777	1
tt1150946	777	1
tt1150947	777	1
tt1160663	777	1
tt1160822	777	1
tt1160823	777	1
tt1160826	777	1
tt1160827	777	1
tt1160832	777	1
tt1160834	777	1
tt1160836	777	1
tt1160837	777	1
tt1160838	777	1
tt1160840	777	1
tt1160841	777	1
tt1160842	777	1
tt1160843	777	1
tt1160844	777	1
tt1160845	777	1
tt1160846	777	1
tt1160847	777	1
tt1160848	777	1
tt1160849	777	1
tt1160850	777	1
tt1160852	777	1
tt1160854	777	1
tt1160855	777	1
tt1160857	777	1
tt1160858	777	1
tt1160859	777	1
tt1160860	777	1
tt1160861	777	1
tt1160862	777	1
tt1160863	777	1
tt1160865	777	1
tt1160866	777	1
tt1160867	777	1
tt1160868	777	1
tt1160871	777	1
tt1160872	777	1
tt1160873	777	1
tt1160874	777	1
tt1160875	777	1
tt1160876	777	1
tt1160877	777	1
tt1160878	777	1
tt1160879	777	1
tt1160881	777	1
tt1160882	777	1
tt1160883	777	1
tt1160884	777	1
tt1160885	777	1
tt1160886	777	1
tt1160887	777	1
tt1160888	777	1
tt1160889	777	1
tt1160891	777	1
tt1160894	777	1
tt1160895	777	1
tt1160896	777	1
tt1160897	777	1
tt1160898	777	1
tt1160899	777	1
tt1160900	777	1
tt1160902	777	1
tt1160903	777	1
tt1160904	777	1
tt1160905	777	1
tt1160906	777	1
tt1160907	777	1
tt1160910	777	1
tt1160911	777	1
tt1160912	777	1
tt1160913	777	1
tt1160915	777	1
tt1160916	777	1
tt1160919	777	1
tt1160923	777	1
tt1160925	777	1
tt1160926	777	1
tt1160927	777	1
ce1150315	778	1
ce1150377	778	1
ce1150388	778	1
ch1150098	778	1
me1150678	778	1
mez188284	778	1
mez188589	778	1
mez188590	778	1
qiz188613	778	1
srz188606	778	1
tt1150883	778	1
tt1150886	778	1
tt1150892	778	1
tt1150920	778	1
tt1160892	778	1
ttc172068	778	1
ttc182038	778	1
ttc182041	778	1
ttc182042	778	1
ttc182043	778	1
ttc182045	778	1
ttc182047	778	1
ttf182067	778	1
ttf182068	778	1
ttf182069	778	1
ttf182070	778	1
ttf182071	778	1
ttf182072	778	1
ttf182073	778	1
ttf182074	778	1
ttf182075	778	1
ttf182076	778	1
ttf182077	778	1
ttf182078	778	1
ttf182079	778	1
ttf182080	778	1
ttf182081	778	1
ttf182082	778	1
ttz178479	778	1
ttz188453	778	1
ttf182067	779	1
ttf182068	779	1
ttf182069	779	1
ttf182070	779	1
ttf182071	779	1
ttf182072	779	1
ttf182073	779	1
ttf182074	779	1
ttf182075	779	1
ttf182076	779	1
ttf182077	779	1
ttf182078	779	1
ttf182079	779	1
ttf182080	779	1
ttf182081	779	1
ttf182082	779	1
ttz188453	779	1
tte182048	780	1
tte182049	780	1
tte182051	780	1
tte182052	780	1
tte182053	780	1
tte182054	780	1
tte182055	780	1
tte182056	780	1
tte182057	780	1
tte182058	780	1
tte182059	780	1
tte182060	780	1
tte182061	780	1
tte182062	780	1
tte182063	780	1
tte182064	780	1
tte182065	780	1
tte182066	780	1
qiz188613	781	1
srz188381	781	1
tt1130975	781	1
tt1140169	781	1
tt1140185	781	1
tt1140911	781	1
tt1140932	781	1
tt1140937	781	1
tt1140944	781	1
tt1150852	781	1
tt1150855	781	1
tt1150856	781	1
tt1150857	781	1
tt1150861	781	1
tt1150862	781	1
tt1150865	781	1
tt1150866	781	1
tt1150880	781	1
tt1150881	781	1
tt1150900	781	1
tt1150931	781	1
tt1150951	781	1
tt1150952	781	1
tt1150953	781	1
tt1160663	781	1
tt1160827	781	1
tt1160834	781	1
tt1160852	781	1
tt1160855	781	1
tt1160857	781	1
tt1160858	781	1
tt1160859	781	1
tt1160863	781	1
tt1160865	781	1
tt1160870	781	1
tt1160871	781	1
tt1160872	781	1
tt1160873	781	1
tt1160874	781	1
tt1160875	781	1
tt1160878	781	1
tt1160879	781	1
tt1160881	781	1
tt1160882	781	1
tt1160883	781	1
tt1160888	781	1
tt1160891	781	1
tt1160892	781	1
tt1160893	781	1
tt1160894	781	1
tt1160895	781	1
tt1160896	781	1
tt1160897	781	1
tt1160898	781	1
tt1160900	781	1
tt1160904	781	1
tt1160906	781	1
tt1160907	781	1
tt1160908	781	1
tt1160910	781	1
tt1160911	781	1
tt1160912	781	1
tt1160925	781	1
ttf182067	781	1
ttf182068	781	1
ttf182070	781	1
ttf182071	781	1
ttf182072	781	1
ttf182073	781	1
ttf182074	781	1
ttf182075	781	1
ttf182076	781	1
ttf182077	781	1
ttf182079	781	1
ttf182080	781	1
ttf182082	781	1
ttz188456	781	1
tt1150866	782	1
ttc182038	782	1
ttc182039	782	1
ttc182040	782	1
ttc182041	782	1
ttc182042	782	1
ttc182043	782	1
ttc182044	782	1
ttc182045	782	1
ttc182046	782	1
ttc182047	782	1
ttc182088	782	1
ttf182067	782	1
ttf182068	782	1
ttf182069	782	1
ttf182070	782	1
ttf182071	782	1
ttf182072	782	1
ttf182073	782	1
ttf182074	782	1
ttf182075	782	1
ttf182076	782	1
ttf182077	782	1
ttf182078	782	1
ttf182079	782	1
ttf182080	782	1
ttf182081	782	1
ttf182082	782	1
ttz188455	782	1
ttz188458	782	1
ttc182038	783	1
ttc182039	783	1
ttc182040	783	1
ttc182041	783	1
ttc182042	783	1
ttc182043	783	1
ttc182044	783	1
ttc182045	783	1
ttc182046	783	1
ttc182047	783	1
ttc182088	783	1
tt1150877	784	1
tt1150944	784	1
ttc182038	784	1
ttc182039	784	1
ttc182040	784	1
ttc182041	784	1
ttc182042	784	1
ttc182043	784	1
ttc182044	784	1
ttc182045	784	1
ttc182046	784	1
ttc182047	784	1
ttc182088	784	1
tt1130937	785	1
tt1130975	785	1
tt1140890	785	1
tt1140911	785	1
tt1140932	785	1
tt1150853	785	1
tt1150854	785	1
tt1150856	785	1
tt1150861	785	1
tt1150862	785	1
tt1150868	785	1
tt1150875	785	1
tt1150877	785	1
tt1150879	785	1
tt1150884	785	1
tt1150891	785	1
tt1150892	785	1
tt1150896	785	1
tt1150901	785	1
tt1150903	785	1
tt1150906	785	1
tt1150911	785	1
tt1150912	785	1
tt1150919	785	1
tt1150926	785	1
tt1150928	785	1
tt1150930	785	1
tt1150931	785	1
tt1150932	785	1
tt1150934	785	1
tt1150938	785	1
tt1150941	785	1
tt1150944	785	1
tt1150946	785	1
tt1150948	785	1
tt1150955	785	1
tt1160826	785	1
tt1160827	785	1
tt1160832	785	1
tt1160837	785	1
tt1160838	785	1
tt1160841	785	1
tt1160847	785	1
tt1160855	785	1
tt1160873	785	1
tt1160877	785	1
tt1160881	785	1
tt1160886	785	1
tt1160887	785	1
tt1160895	785	1
tt1160906	785	1
tt1160907	785	1
tt1160912	785	1
tt1160926	785	1
tte182048	785	1
tte182051	785	1
tte182052	785	1
tte182053	785	1
tte182054	785	1
tte182055	785	1
tte182057	785	1
tte182058	785	1
tte182059	785	1
tte182060	785	1
tte182061	785	1
tte182062	785	1
tte182063	785	1
tte182065	785	1
tte182066	785	1
ce1150395	786	1
ce1150405	786	1
cs5140285	786	1
me1150679	786	1
me1150685	786	1
me1150688	786	1
mt1150584	786	1
mt1150596	786	1
mt1150609	786	1
mt6150373	786	1
ph1150785	786	1
ph1150797	786	1
ph1150832	786	1
tt1130979	786	1
tt1140169	786	1
tt1140185	786	1
tt1140890	786	1
tt1140932	786	1
tt1140934	786	1
tt1150851	786	1
tt1150855	786	1
tt1150856	786	1
tt1150859	786	1
tt1150864	786	1
tt1150868	786	1
tt1150872	786	1
tt1150875	786	1
tt1150878	786	1
tt1150879	786	1
tt1150887	786	1
tt1150888	786	1
tt1150889	786	1
tt1150891	786	1
tt1150895	786	1
tt1150896	786	1
tt1150903	786	1
tt1150904	786	1
tt1150906	786	1
tt1150907	786	1
tt1150911	786	1
tt1150919	786	1
tt1150925	786	1
tt1150928	786	1
tt1150929	786	1
tt1150930	786	1
tt1150931	786	1
tt1150932	786	1
tt1150934	786	1
tt1150935	786	1
tt1150937	786	1
tt1150940	786	1
tt1150948	786	1
tt1150953	786	1
tte182056	786	1
tt1130975	787	1
tt1140870	787	1
tt1150859	787	1
tt1150862	787	1
tt1150879	787	1
tt1150892	787	1
tt1150927	787	1
tt1150937	787	1
tt1150948	787	1
tt1150954	787	1
ttc182038	787	1
ttc182039	787	1
ttc182040	787	1
ttc182041	787	1
ttc182042	787	1
ttc182043	787	1
ttc182044	787	1
ttc182045	787	1
ttc182046	787	1
ttc182047	787	1
ttc182088	787	1
tte182048	787	1
tte182049	787	1
tte182051	787	1
tte182052	787	1
tte182053	787	1
tte182054	787	1
tte182055	787	1
tte182056	787	1
tte182057	787	1
tte182058	787	1
tte182059	787	1
tte182060	787	1
tte182061	787	1
tte182062	787	1
tte182063	787	1
tte182064	787	1
tte182065	787	1
tte182066	787	1
ttf182067	787	1
ttf182068	787	1
ttf182069	787	1
ttf182070	787	1
ttf182071	787	1
ttf182072	787	1
ttf182073	787	1
ttf182074	787	1
ttf182075	787	1
ttf182076	787	1
ttf182077	787	1
ttf182078	787	1
ttf182079	787	1
ttf182080	787	1
ttf182081	787	1
ttf182082	787	1
ttz188457	787	1
ttz188461	787	1
tt1130975	788	1
tt1140185	788	1
tt1140920	788	1
tt1150861	788	1
tt1150877	788	1
tt1150883	788	1
tt1150886	788	1
tt1150888	788	1
tt1150944	788	1
tt1150948	788	1
tt1160663	788	1
tt1160831	788	1
tt1160843	788	1
tt1160881	788	1
tt1160894	788	1
tt1160897	788	1
tt1160899	788	1
tt1160905	788	1
tt1160913	788	1
tt1160915	788	1
tt1160919	788	1
tt1160923	788	1
tte172057	788	1
tte172058	788	1
tte172059	788	1
tte182064	788	1
ttz188457	788	1
tt1130937	789	1
tt1140169	789	1
tt1140870	789	1
tt1140911	789	1
tt1140920	789	1
tt1140932	789	1
tt1150855	789	1
tt1150858	789	1
tt1150859	789	1
tt1150868	789	1
tt1150875	789	1
tt1150878	789	1
tt1150881	789	1
tt1150882	789	1
tt1150886	789	1
tt1150888	789	1
tt1150889	789	1
tt1150892	789	1
tt1150894	789	1
tt1150895	789	1
tt1150897	789	1
tt1150904	789	1
tt1150906	789	1
tt1150907	789	1
tt1150911	789	1
tt1150926	789	1
tt1150931	789	1
tt1150932	789	1
tt1150939	789	1
tt1150946	789	1
tt1150951	789	1
tt1150953	789	1
tt1160832	789	1
tt1160834	789	1
tt1160836	789	1
tt1160838	789	1
tt1160841	789	1
tt1160844	789	1
tt1160848	789	1
tt1160855	789	1
tt1160877	789	1
tt1160878	789	1
tt1160884	789	1
tt1160892	789	1
tt1160897	789	1
tt1160900	789	1
tt1160904	789	1
tt1160915	789	1
tt1160926	789	1
tte172044	789	1
tte172054	789	1
tte172524	789	1
tte182049	789	1
mez188587	790	1
mez188588	790	1
mez188599	790	1
ptz178042	790	1
tt1130937	790	1
tt1150853	790	1
tt1150854	790	1
tt1150876	790	1
tt1150877	790	1
tt1150889	790	1
tt1150892	790	1
tt1150893	790	1
tt1150897	790	1
tt1150907	790	1
tt1150909	790	1
tt1150911	790	1
tt1150918	790	1
tt1150925	790	1
tt1150930	790	1
tt1150938	790	1
tt1150946	790	1
tt1150947	790	1
tt1150955	790	1
tt1160822	790	1
tt1160823	790	1
tt1160826	790	1
tt1160836	790	1
tt1160844	790	1
tt1160850	790	1
tt1160853	790	1
tt1160854	790	1
tt1160860	790	1
tt1160861	790	1
tt1160864	790	1
tt1160866	790	1
tt1160877	790	1
tt1160885	790	1
tt1160887	790	1
tt1160889	790	1
ttc182038	790	1
ttc182039	790	1
ttc182040	790	1
ttc182041	790	1
ttc182042	790	1
ttc182043	790	1
ttc182044	790	1
ttc182045	790	1
ttc182046	790	1
ttc182047	790	1
ttc182088	790	1
tte182048	790	1
tte182049	790	1
tte182051	790	1
tte182052	790	1
tte182053	790	1
tte182054	790	1
tte182055	790	1
tte182056	790	1
tte182057	790	1
tte182058	790	1
tte182059	790	1
tte182060	790	1
tte182061	790	1
tte182062	790	1
tte182063	790	1
tte182064	790	1
tte182065	790	1
tte182066	790	1
ttf182069	790	1
ttf182078	790	1
ttf182081	790	1
bb5130023	791	1
tt1100909	791	1
tt1140115	791	1
tt1140228	791	1
tt1140912	791	1
tt1140944	791	1
tt1150857	791	1
tt1150882	791	1
tt1150905	791	1
tt1150913	791	1
tt1160663	791	1
tt1160822	791	1
tt1160823	791	1
tt1160826	791	1
tt1160827	791	1
tt1160832	791	1
tt1160834	791	1
tt1160836	791	1
tt1160837	791	1
tt1160838	791	1
tt1160839	791	1
tt1160840	791	1
tt1160841	791	1
tt1160842	791	1
tt1160843	791	1
tt1160844	791	1
tt1160845	791	1
tt1160846	791	1
tt1160847	791	1
tt1160848	791	1
tt1160849	791	1
tt1160850	791	1
tt1160852	791	1
tt1160853	791	1
tt1160854	791	1
tt1160855	791	1
tt1160857	791	1
tt1160858	791	1
tt1160859	791	1
tt1160860	791	1
tt1160861	791	1
tt1160862	791	1
tt1160863	791	1
tt1160864	791	1
tt1160865	791	1
tt1160866	791	1
tt1160867	791	1
tt1160868	791	1
tt1160869	791	1
tt1160870	791	1
tt1160871	791	1
tt1160872	791	1
tt1160873	791	1
tt1160874	791	1
tt1160875	791	1
tt1160876	791	1
tt1160877	791	1
tt1160878	791	1
tt1160879	791	1
tt1160880	791	1
tt1160881	791	1
tt1160882	791	1
tt1160883	791	1
tt1160884	791	1
tt1160885	791	1
tt1160886	791	1
tt1160887	791	1
tt1160888	791	1
tt1160889	791	1
tt1160890	791	1
tt1160891	791	1
tt1160892	791	1
tt1160893	791	1
tt1160894	791	1
tt1160895	791	1
tt1160896	791	1
tt1160897	791	1
tt1160898	791	1
tt1160899	791	1
tt1160900	791	1
tt1160902	791	1
tt1160903	791	1
tt1160904	791	1
tt1160905	791	1
tt1160906	791	1
tt1160907	791	1
tt1160908	791	1
tt1160910	791	1
tt1160911	791	1
tt1160912	791	1
tt1160913	791	1
tt1160915	791	1
tt1160916	791	1
tt1160919	791	1
tt1160923	791	1
tt1160925	791	1
tt1160926	791	1
tt1160927	791	1
tt1170906	791	1
tt1170918	791	1
tt1170947	791	1
tt1140905	792	1
tt1150913	792	1
tt1150924	792	1
tt1160821	792	1
tt1160831	792	1
tt1160867	792	1
tt1160909	792	1
tt1160914	792	1
tt1160917	792	1
tt1160918	792	1
tt1160921	792	1
tt1160922	792	1
tt1160924	792	1
tt1170871	792	1
tt1170873	792	1
tt1170874	792	1
tt1170875	792	1
tt1170876	792	1
tt1170877	792	1
tt1170878	792	1
tt1170879	792	1
tt1170880	792	1
tt1170881	792	1
tt1170882	792	1
tt1170883	792	1
tt1170884	792	1
tt1170885	792	1
tt1170886	792	1
tt1170887	792	1
tt1170888	792	1
tt1170889	792	1
tt1170890	792	1
tt1170891	792	1
tt1170892	792	1
tt1170893	792	1
tt1170896	792	1
tt1170897	792	1
tt1170898	792	1
tt1170899	792	1
tt1170900	792	1
tt1170901	792	1
tt1170902	792	1
tt1170903	792	1
tt1170904	792	1
tt1170905	792	1
tt1170906	792	1
tt1170907	792	1
tt1170908	792	1
tt1170909	792	1
tt1170910	792	1
tt1170911	792	1
tt1170912	792	1
tt1170913	792	1
tt1170914	792	1
tt1170915	792	1
tt1170916	792	1
tt1170917	792	1
tt1170918	792	1
tt1170919	792	1
tt1170920	792	1
tt1170921	792	1
tt1170922	792	1
tt1170923	792	1
tt1170924	792	1
tt1170925	792	1
tt1170926	792	1
tt1170927	792	1
tt1170928	792	1
tt1170929	792	1
tt1170930	792	1
tt1170931	792	1
tt1170932	792	1
tt1170933	792	1
tt1170934	792	1
tt1170935	792	1
tt1170936	792	1
tt1170939	792	1
tt1170940	792	1
tt1170941	792	1
tt1170943	792	1
tt1170944	792	1
tt1170945	792	1
tt1170947	792	1
tt1170948	792	1
tt1170949	792	1
tt1170951	792	1
tt1170952	792	1
tt1170953	792	1
tt1170954	792	1
tt1170955	792	1
tt1170956	792	1
tt1170957	792	1
tt1170958	792	1
tt1170959	792	1
tt1170961	792	1
tt1170962	792	1
tt1170963	792	1
tt1170964	792	1
tt1170965	792	1
tt1170966	792	1
tt1170968	792	1
tt1170969	792	1
tt1170970	792	1
tt1170971	792	1
tt1170972	792	1
tt1170973	792	1
tt1170974	792	1
tt1170975	792	1
tt1170976	792	1
bb5140004	793	1
tt1140870	793	1
tt1140896	793	1
tt1140905	793	1
tt1140912	793	1
tt1140937	793	1
tt1150924	793	1
tt1160821	793	1
tt1160831	793	1
tt1160867	793	1
tt1160872	793	1
tt1160890	793	1
tt1160909	793	1
tt1160914	793	1
tt1160917	793	1
tt1160918	793	1
tt1160921	793	1
tt1160922	793	1
tt1160924	793	1
tt1170871	793	1
tt1170873	793	1
tt1170874	793	1
tt1170875	793	1
tt1170876	793	1
tt1170877	793	1
tt1170878	793	1
tt1170879	793	1
tt1170880	793	1
tt1170881	793	1
tt1170882	793	1
tt1170883	793	1
tt1170884	793	1
tt1170885	793	1
tt1170886	793	1
tt1170887	793	1
tt1170888	793	1
tt1170889	793	1
tt1170890	793	1
tt1170891	793	1
tt1170892	793	1
tt1170893	793	1
tt1170896	793	1
tt1170897	793	1
tt1170898	793	1
tt1170899	793	1
tt1170900	793	1
tt1170901	793	1
tt1170902	793	1
tt1170903	793	1
tt1170904	793	1
tt1170905	793	1
tt1170906	793	1
tt1170907	793	1
tt1170908	793	1
tt1170909	793	1
tt1170910	793	1
tt1170911	793	1
tt1170912	793	1
tt1170913	793	1
tt1170914	793	1
tt1170915	793	1
tt1170916	793	1
tt1170917	793	1
tt1170918	793	1
tt1170919	793	1
tt1170920	793	1
tt1170921	793	1
tt1170922	793	1
tt1170923	793	1
tt1170924	793	1
tt1170925	793	1
tt1170926	793	1
tt1170927	793	1
tt1170928	793	1
tt1170929	793	1
tt1170930	793	1
tt1170931	793	1
tt1170932	793	1
tt1170933	793	1
tt1170934	793	1
tt1170935	793	1
tt1170936	793	1
tt1170939	793	1
tt1170940	793	1
tt1170941	793	1
tt1170943	793	1
tt1170944	793	1
tt1170945	793	1
tt1170947	793	1
tt1170948	793	1
tt1170949	793	1
tt1170951	793	1
tt1170952	793	1
tt1170953	793	1
tt1170954	793	1
tt1170955	793	1
tt1170956	793	1
tt1170957	793	1
tt1170958	793	1
tt1170959	793	1
tt1170961	793	1
tt1170962	793	1
tt1170963	793	1
tt1170964	793	1
tt1170965	793	1
tt1170968	793	1
tt1170969	793	1
tt1170970	793	1
tt1170971	793	1
tt1170972	793	1
tt1170973	793	1
tt1170974	793	1
tt1170975	793	1
tt1170976	793	1
tt1140905	794	1
tt1150903	794	1
tt1150924	794	1
tt1160821	794	1
tt1160823	794	1
tt1160826	794	1
tt1160831	794	1
tt1160837	794	1
tt1160839	794	1
tt1160846	794	1
tt1160847	794	1
tt1160849	794	1
tt1160850	794	1
tt1160858	794	1
tt1160860	794	1
tt1160867	794	1
tt1160868	794	1
tt1160890	794	1
tt1160909	794	1
tt1160914	794	1
tt1160917	794	1
tt1160918	794	1
tt1160921	794	1
tt1160922	794	1
tt1160924	794	1
tt1170871	794	1
tt1170873	794	1
tt1170874	794	1
tt1170875	794	1
tt1170876	794	1
tt1170877	794	1
tt1170878	794	1
tt1170879	794	1
tt1170880	794	1
tt1170881	794	1
tt1170882	794	1
tt1170883	794	1
tt1170884	794	1
tt1170885	794	1
tt1170886	794	1
tt1170887	794	1
tt1170888	794	1
tt1170889	794	1
tt1170890	794	1
tt1170891	794	1
tt1170892	794	1
tt1170893	794	1
tt1170896	794	1
tt1170897	794	1
tt1170898	794	1
tt1170899	794	1
tt1170900	794	1
tt1170901	794	1
tt1170902	794	1
tt1170903	794	1
tt1170904	794	1
tt1170905	794	1
tt1170906	794	1
tt1170907	794	1
tt1170908	794	1
tt1170909	794	1
tt1170910	794	1
tt1170911	794	1
tt1170912	794	1
tt1170913	794	1
tt1170914	794	1
tt1170915	794	1
tt1170916	794	1
tt1170917	794	1
tt1170918	794	1
tt1170919	794	1
tt1170920	794	1
tt1170921	794	1
tt1170922	794	1
tt1170923	794	1
tt1170924	794	1
tt1170925	794	1
tt1170926	794	1
tt1170927	794	1
tt1170928	794	1
tt1170929	794	1
tt1170930	794	1
tt1170931	794	1
tt1170932	794	1
tt1170933	794	1
tt1170934	794	1
tt1170935	794	1
tt1170936	794	1
tt1170939	794	1
tt1170940	794	1
tt1170941	794	1
tt1170943	794	1
tt1170944	794	1
tt1170945	794	1
tt1170947	794	1
tt1170948	794	1
tt1170949	794	1
tt1170951	794	1
tt1170952	794	1
tt1170953	794	1
tt1170954	794	1
tt1170955	794	1
tt1170956	794	1
tt1170957	794	1
tt1170958	794	1
tt1170959	794	1
tt1170961	794	1
tt1170962	794	1
tt1170963	794	1
tt1170964	794	1
tt1170966	794	1
tt1170968	794	1
tt1170969	794	1
tt1170970	794	1
tt1170971	794	1
tt1170972	794	1
tt1170973	794	1
tt1170974	794	1
tt1170975	794	1
tt1170976	794	1
tt1140115	795	1
tt1140228	795	1
tt1140905	795	1
tt1140944	795	1
tt1150857	795	1
tt1150867	795	1
tt1150882	795	1
tt1150905	795	1
tt1150931	795	1
tt1160663	795	1
tt1160822	795	1
tt1160823	795	1
tt1160826	795	1
tt1160827	795	1
tt1160832	795	1
tt1160834	795	1
tt1160836	795	1
tt1160837	795	1
tt1160838	795	1
tt1160839	795	1
tt1160840	795	1
tt1160841	795	1
tt1160842	795	1
tt1160843	795	1
tt1160844	795	1
tt1160845	795	1
tt1160846	795	1
tt1160847	795	1
tt1160848	795	1
tt1160849	795	1
tt1160850	795	1
tt1160852	795	1
tt1160853	795	1
tt1160854	795	1
tt1160855	795	1
tt1160857	795	1
tt1160858	795	1
tt1160859	795	1
tt1160860	795	1
tt1160861	795	1
tt1160862	795	1
tt1160863	795	1
tt1160864	795	1
tt1160865	795	1
tt1160866	795	1
tt1160867	795	1
tt1160868	795	1
tt1160869	795	1
tt1160870	795	1
tt1160871	795	1
tt1160872	795	1
tt1160873	795	1
tt1160874	795	1
tt1160875	795	1
tt1160876	795	1
tt1160877	795	1
tt1160878	795	1
tt1160879	795	1
tt1160880	795	1
tt1160881	795	1
tt1160882	795	1
tt1160883	795	1
tt1160884	795	1
tt1160885	795	1
tt1160886	795	1
tt1160887	795	1
tt1160888	795	1
tt1160889	795	1
tt1160891	795	1
tt1160892	795	1
tt1160893	795	1
tt1160894	795	1
tt1160895	795	1
tt1160896	795	1
tt1160897	795	1
tt1160898	795	1
tt1160899	795	1
tt1160900	795	1
tt1160902	795	1
tt1160903	795	1
tt1160904	795	1
tt1160905	795	1
tt1160906	795	1
tt1160907	795	1
tt1160908	795	1
tt1160910	795	1
tt1160911	795	1
tt1160912	795	1
tt1160913	795	1
tt1160915	795	1
tt1160916	795	1
tt1160919	795	1
tt1160923	795	1
tt1160925	795	1
tt1160926	795	1
tt1160927	795	1
ttf182067	796	1
ttf182068	796	1
ttf182069	796	1
ttf182070	796	1
ttf182071	796	1
ttf182072	796	1
ttf182073	796	1
ttf182074	796	1
ttf182075	796	1
ttf182076	796	1
ttf182077	796	1
ttf182078	796	1
ttf182079	796	1
ttf182080	796	1
ttf182081	796	1
ttf182082	796	1
ttz188453	796	1
tte182048	797	1
tte182049	797	1
tte182051	797	1
tte182052	797	1
tte182053	797	1
tte182054	797	1
tte182055	797	1
tte182056	797	1
tte182057	797	1
tte182058	797	1
tte182059	797	1
tte182060	797	1
tte182061	797	1
tte182062	797	1
tte182063	797	1
tte182064	797	1
tte182065	797	1
tte182066	797	1
tt1150868	798	1
tt1150875	798	1
tt1150928	798	1
tt1150930	798	1
tt1150952	798	1
ttc182038	798	1
ttc182039	798	1
ttc182040	798	1
ttc182041	798	1
ttc182042	798	1
ttc182043	798	1
ttc182044	798	1
ttc182045	798	1
ttc182046	798	1
ttc182047	798	1
ttc182088	798	1
ttz188455	798	1
tte182048	799	1
tte182049	799	1
tte182051	799	1
tte182052	799	1
tte182053	799	1
tte182054	799	1
tte182055	799	1
tte182056	799	1
tte182057	799	1
tte182058	799	1
tte182059	799	1
tte182060	799	1
tte182061	799	1
tte182062	799	1
tte182063	799	1
tte182064	799	1
tte182065	799	1
tte182066	799	1
ttf182080	799	1
bb1150050	800	1
bb1150061	800	1
bb1150063	800	1
ce1140333	800	1
ce1140381	800	1
ce1150302	800	1
ce1150313	800	1
ce1150317	800	1
ce1150318	800	1
ce1150322	800	1
ce1150326	800	1
ce1150344	800	1
ce1150395	800	1
ch1130080	800	1
ch1150072	800	1
ch1150077	800	1
ch1150081	800	1
ch1150083	800	1
ch1150120	800	1
ch1150144	800	1
ch7140179	800	1
cs1150215	800	1
cs1150230	800	1
cs1150237	800	1
cs1150241	800	1
cs1150667	800	1
cs5130286	800	1
ee1150430	800	1
ee1150434	800	1
ee1150449	800	1
ee1150452	800	1
ee1150454	800	1
ee1150455	800	1
ee1150457	800	1
ee1150458	800	1
ee1150463	800	1
ee1150465	800	1
ee1150468	800	1
ee1150469	800	1
ee1150470	800	1
ee1150472	800	1
ee1150473	800	1
ee1150479	800	1
ee1150485	800	1
ee1150486	800	1
ee1150488	800	1
ee1150493	800	1
ee1150504	800	1
ee1150534	800	1
ee3150502	800	1
ee3150503	800	1
ee3150512	800	1
ee3150514	800	1
ee3150517	800	1
ee3150518	800	1
ee3150520	800	1
ee3150529	800	1
ee3150530	800	1
ee3150536	800	1
ee3150539	800	1
ee3150540	800	1
ee3150542	800	1
ee3150543	800	1
ee3150649	800	1
ee3150750	800	1
me1150101	800	1
me1150628	800	1
me1150642	800	1
me1150650	800	1
me1150652	800	1
me1150653	800	1
me1150663	800	1
me1150668	800	1
me1150684	800	1
me1150687	800	1
me1150689	800	1
me2150707	800	1
mt1140584	800	1
mt1150583	800	1
mt1150584	800	1
mt1150585	800	1
mt1150587	800	1
mt1150596	800	1
ph1150783	800	1
ph1150788	800	1
ph1150792	800	1
ph1150805	800	1
ph1150823	800	1
ph1150839	800	1
tt1130982	800	1
tt1140588	800	1
tt1140911	800	1
tt1140937	800	1
tt1140944	800	1
tt1150853	800	1
tt1150858	800	1
tt1150864	800	1
tt1150866	800	1
tt1150867	800	1
tt1150878	800	1
tt1150882	800	1
tt1150888	800	1
tt1150889	800	1
tt1150895	800	1
tt1150896	800	1
tt1150905	800	1
tt1150917	800	1
tt1150919	800	1
tt1150926	800	1
tt1150928	800	1
tt1150935	800	1
tt1150939	800	1
tt1150941	800	1
tt1150946	800	1
tt1150947	800	1
tt1150948	800	1
tt1160827	800	1
tt1160836	800	1
tt1160844	800	1
tt1160847	800	1
tt1160858	800	1
tt1160873	800	1
tt1160884	800	1
tt1160888	800	1
tt1160893	800	1
tt1160902	800	1
tt1160925	800	1
tt1170945	800	1
bb1160028	802	1
bb1160049	802	1
bb5160010	802	1
ce1150302	802	1
ce1150306	802	1
ce1150312	802	1
ce1160219	802	1
ch1130071	802	1
ch1150094	802	1
ch1160121	802	1
ch7130170	802	1
cs1150255	802	1
cs1160318	802	1
cs1160364	802	1
cs1160375	802	1
cs5150279	802	1
ee1150447	802	1
ee1160427	802	1
ee1160436	802	1
ee1160458	802	1
ee3150898	802	1
ee3160161	802	1
ee3160524	802	1
jit172122	802	1
jit172123	802	1
jit172782	802	1
mas177084	802	1
me1150636	802	1
me1150642	802	1
me1150647	802	1
me1150655	802	1
me1160901	802	1
me2150719	802	1
me2150737	802	1
me2160775	802	1
me2160780	802	1
mez178318	802	1
mt6140559	802	1
nrz188579	802	1
phs177121	802	1
phs177132	802	1
phs177135	802	1
phs177143	802	1
phs177149	802	1
phs177168	802	1
phs177170	802	1
phs177172	802	1
rdz188651	802	1
tt1150863	802	1
tt1150897	802	1
tt1160853	802	1
tt1160869	802	1
tt1160908	802	1
tt1160915	802	1
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.events (id, alias, name, linkto) FROM stdin;
1	cs117	col216 help session	
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (gid, alias) FROM stdin;
1	2013_NGU
2	2014_NGU
3	2015_ngu
4	2016_NGU
5	2017-ngu
6	2018_ngu
7	ace_iitd
8	acinf
9	acss
10	adeanird
11	aditya
12	admin_cstaff
13	admin_head
14	adminird
15	admin_staff
16	admissionee
17	alldeans
18	allfaculty
19	allhods
20	allpd
21	allscst
22	alumni
23	ama17
24	ama18
25	am_adjunct
26	amat-coe
27	am_cstaff
28	amd15
29	amd16
30	AMD310
31	AMD811
32	AMD812
33	AMD813
34	AMD814
35	AMD895
36	AMD897
37	ame15
38	ame16
39	am_emeritus
40	am_exfaculty
41	amfaculty
42	am_faculty
43	am_irdstaff
44	AML702
45	AML706
46	AML731
47	AML793
48	AML795
49	AML831
50	AML832
51	AML835
52	AMP776
53	am_retfaculty
54	am_staff
55	am_vfaculty
56	am_vstudent
57	amx17
58	amx18
59	amy16
60	amy17
61	amy18
62	amz10
63	amz11
64	amz12
65	amz13
66	amz14
67	amz15
68	amz16
69	amz17
70	amz18
71	analytics
72	anz10
73	anz11
74	anz12
75	anz13
76	anz14
77	anz15
78	anz16
79	anz17
80	anz18
81	APL100
82	APL102
83	APL105
84	APL300
85	APL705
86	APL711
87	APL713
88	APL720
89	APL750
90	APL767
91	APL774
92	APL796
93	APL871
94	appm
95	APV707
96	are1
97	are2
98	arg
\.
