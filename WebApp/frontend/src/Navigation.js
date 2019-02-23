import React, { Component } from 'react';
import "./navigation.css"

export default class Navigation extends Component {
  render() {
    return (
        <nav>
            <ul>
                <li><a href="/">Home</a></li>
                <li><a href="/search_courses">Courses</a></li>
                <li><a href="/search_users">Users</a></li>
                <li><a href="/search_usergroups">Groups</a></li>
                <li><a href="/search_events">Events</a></li>
            </ul>
        </nav>
    );
  }
}
