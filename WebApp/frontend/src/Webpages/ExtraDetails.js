import React from 'react';
import {Button} from 'react-bootstrap'

export default class ExtraDetails extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            alias : "",
            name : "",
            code: "",
            type : 0,
            users: [],
            urlpath: "/user/"
        };
    }

    queryUsers = (e) => {
        let cq = "?alias="+this.state.alias+'&name='+this.state.name+'&type='+this.state.type+"&code="+this.state.code
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
        // let t = e.target.value
        // let x
        // if(t == 1) x = "/student/"
        // else if (t==2) x = "/faculty/"
        // else x = "/users/="
        this.setState({
            type: e.target.value,
            // urlpath: x,
        })
    }


    render() {
        return (
            <div className="row">
                <div className="search_div">
                    <h3>Search User:</h3>
                    <input type="text" onChange={ (e) => this.setState({alias: e.target.value}) } value={ this.state.alias } placeholder="alias"/>
                    <input type="text" onChange={ (e) => this.setState({name: e.target.value}) } value={ this.state.name } placeholder="name"/>
                    <input type="text" onChange={ (e) => this.setState({code: e.target.value}) } value={ this.state.code } placeholder="group alias"/>
                    <select  onChange={this.seturlpath} value={ this.state.type } >
                        <option value="0">All</option>
                        <option value="1">Student</option>
                        <option value="2">Faculty</option>
                    </select>
                    <br/><Button onClick={this.queryUsers}> Search </Button> <span>OR &nbsp;&nbsp;&nbsp; Create a <a href="/insert_user">User</a></span>
                </div>
            </div>
        )
    }
}