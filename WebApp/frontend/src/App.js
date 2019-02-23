import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import Main from './Webpages/Main.js'
import Navigation from './Navigation.js'

class App extends Component {
  render() {
    return (
      <div>
        <Navigation/>
        <Main/>
      </div>
    );
  }
}
export default App;
