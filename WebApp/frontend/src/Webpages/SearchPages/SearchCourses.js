import React from 'react';
import ReactDOM from 'react-dom';
import Query from '../QueryComponent/Query.js'
import {Bu, ButtonttButton} from 'react-bootstrap'

export default class SearchCourses extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            code : "",
            name : "",
            slot : "",
            year : "",
            semester : "",
            courses: [],
            urlpath: "/courses/"
        };
    }

    queryCourses = (e) => {
        let cq = "?code="+this.state.code+'&name='+this.state.name+'&slot='+this.state.slot+'&year='+this.state.year+'&semester='+this.state.semester
        fetch('http://localhost:5000/findcourses/'+cq, {
            method: 'GET',
            dataType: 'json'
          })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                this.setState({
                  isLoaded: true,
                  courses: jsres.results
                });
              },
              (error) => {
                this.setState({
                  isLoaded: true,
                  error
                });
              }
            )
    }

    render() {
        return (
        <div className="search_div">
            <input type="text" onChange={ (e) => this.setState({code: e.target.value}) } value={ this.state.code } placeholder="Course Code"/>
            <input type="text" onChange={ (e) => this.setState({name: e.target.value}) } value={ this.state.name } placeholder="Course"/>
            <input type="text" onChange={ (e) => this.setState({slot: e.target.value}) } value={ this.state.slot } placeholder="Slot"/>
            <input type="text" onChange={ (e) => this.setState({year: e.target.value}) } value={ this.state.year } placeholder="Year"/>
            <input type="text" onChange={ (e) => this.setState({semester: e.target.value}) } value={ this.state.semester } placeholder="Semester"/>
            <br/>
            <Button onClick={this.queryCourses}> Search </Button>
            <Query results={this.state.courses} urlpath={this.state.urlpath} hyperlink={true}/>
        </div>
        )
    }
}