import React from 'react'
import { Switch, Route } from 'react-router-dom'
import Home from './Home'
import Timetable from './Timetable'
import "./main.css"
import CourseDetails from './EntityDetails/CourseDetails'
import StudentDetails from './EntityDetails/StudentDetails'
import FacultyDetails from './EntityDetails/FacultyDetails'
import UserGroupDetails from './EntityDetails/UserGroupDetails'
import UserDetail from './EntityDetails/UserDetails'
import EventDetails from './EntityDetails/EventDetails'
import SearchCourses from './SearchPages/SearchCourses'
import SearchUsers from './SearchPages/SearchUsers'
import SearchUserGroups from './SearchPages/SearchUserGroups'
import SearchEvents from './SearchPages/SearchEvents'
import InsertCourse from './InsertionPages/InsertCourse'
import InsertEvent from './InsertionPages/InsertEvent';

export default function Main() {
  return (
      <main>
            <Switch>
              <Route exact path='/' component={Home}/>
              <Route path='/timetable' component={Timetable}/>
              <Route path='/courses/:code' component={CourseDetails}/>
              {/* <Route path='/student/:alias' component={StudentDetails}/>
              <Route path='/faculty/:alias' component={FacultyDetails}/> */}
              <Route path='/user/:alias' component={UserDetail}/>
              <Route path='/usergroup/:groupcode' component={UserGroupDetails}/>
              <Route path='/event/:eventid' component={EventDetails}/>
              <Route path='/search_courses' component={SearchCourses}/>
              <Route path='/search_users' component={SearchUsers}/>
              <Route path='/search_usergroups' component={SearchUserGroups}/>
              <Route path='/search_events' component={SearchEvents}/>
              <Route path='/insert_course' component={InsertCourse}/>
              <Route path='/insert_event' component={InsertEvent}/>
            </Switch>
      </main>
  );
}