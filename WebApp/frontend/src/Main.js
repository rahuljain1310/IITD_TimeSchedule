import React from 'react'
import { Switch, Route } from 'react-router-dom'
import Home from './Home'
import Timetable from './Timetable'
import CourseDetails from './CourseDetails'

export default function Main() {
  return (
    <main>
      <Switch>
        <Route exact path='/' component={Home}/>
        <Route path='/timetable' component={Timetable}/>
        <Route path='/courses' component={CourseDetails}/>
      </Switch>
    </main>
  );
}