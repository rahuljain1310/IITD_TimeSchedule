import React from 'react'
import { Switch, Route } from 'react-router-dom'
import Home from './Home'
import Timetable from './Timetable'
import CourseDetails from './EntityDetails/CourseDetails'
import StudentDetails from './EntityDetails/StudentDetails'
import FacultyDetails from './EntityDetails/FacultyDetails'
import UserGroupDetails from './EntityDetails/UserGroupDetails'
import SearchCourses from './SearchPages/SearchCourses'
import SearchUsers from './SearchPages/SearchUsers'
import SearchUserGroups from './SearchPages/SearchUserGroups.js'

export default function Main() {
  return (
    <main>
      <Switch>
        <Route exact path='/' component={Home}/>
        <Route path='/timetable' component={Timetable}/>
        <Route path='/courses/:code' component={CourseDetails}/>
        <Route path='/student/:alias' component={StudentDetails}/>
        <Route path='/faculty/:alias' component={FacultyDetails}/>
        <Route path='/usergroup/:groupcode' component={UserGroupDetails}/>
        <Route path='/search_courses' component={SearchCourses}/>
        <Route path='/search_users' component={SearchUsers}/>
        <Route path='/search_usergroups' component={SearchUserGroups}/>
      </Switch>
    </main>
  );
}