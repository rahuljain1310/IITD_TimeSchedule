import React from 'react';
import ReactDOM from 'react-dom';
import Query from '../QueryComponent/Query'

export default class SearchCourses extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            alias : "",
            name : "",
            type : 0,
            users: [],
            urlpath: "/user/"
        };
    }

    queryUsers = (e) => {
        let cq = "?alias="+this.state.alias+'&name='+this.state.name+'&type='+this.state.type
        fetch('http://localhost:5000/findusers/'+cq, {
            method: 'GET',
            dataType: 'json'
          })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                this.setState({
                  isLoaded: true,
                  users: jsres.results
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

    seturlpath = (e) => {
        let t = e.target.value
        let x
        if(t == 1) x = "/student/"
        else if (t==2) x = "/faculty/"
        else x = "/users/="
        this.setState({
            type: e.target.value,
            urlpath: x,
        })
    }


    render() {
        return (
        <div>
            <input type="text" onChange={ (e) => this.setState({alias: e.target.value}) } value={ this.state.alias } placeholder="alias"/>
            <input type="text" onChange={ (e) => this.setState({name: e.target.value}) } value={ this.state.name } placeholder="name"/>
            <select  onChange={this.seturlpath} value={ this.state.type }>
                <option selected="select" value="0">All</option>
                <option value="1">Student</option>
                <option value="2">Faculty</option>
            </select>
            <button onClick={this.queryUsers}> Go </button>
            <Query urlpath={this.state.urlpath} results={this.state.users} hyperlink={true}/>
        </div>

        )
    }
}