import React, { Component } from 'react';
import "./navigation.css"

export default class Navigation extends Component {
  render() {
    return (
        <nav>
            <ul>
                <li><a href="#home">Home</a></li>
                <li><a href="/search_courses">Courses</a></li>
                <li><a href="/user">Users</a></li>
                <li><a href="/group">Groups</a></li>
                <li><a href="/event">Events</a></li>
            </ul>
        </nav>
    );
  }
}
