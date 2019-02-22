import React from 'react'
import { Switch, Route } from 'react-router-dom'
import Home from './Home'
import Timetable from './Timetable'
import CourseDetails from './EntityDetails/CourseDetails'
import SearchCourses from './SearchPages/SearchCourses'
import SearchUsers from './SearchPages/SearchUsers'

export default function Main() {
  return (
    <main>
      <Switch>
        <Route exact path='/' component={Home}/>
        <Route path='/timetable' component={Timetable}/>
        <Route path='/courses/:code' component={CourseDetails}/>
        <Route path='/search_courses' component={SearchCourses}/>
        <Route path='/search_users' component={SearchUsers}/>
      </Switch>
    </main>
  );
}