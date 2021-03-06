
import React from 'react';
import Query from '../QueryComponent/Query'
import {Button} from 'react-bootstrap'

var forge = require('node-forge');
var rsa= forge.pki.rsa;
var publickey = forge.pki.publicKeyFromPem('public_key.pem');
var secretMessage = "HelloWorld";

var encrypted = publicKey.encrypt(secretMessage, "RSA-OAEP", {
            md: forge.md.sha256.create(),
            mgf1: forge.mgf1.create()
        });

var base64 = forge.util.encode64(encrypted);



export default class SearchUsers extends React.Component {
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
        <div className="search_div">
            <h3>Search User:</h3>
            <input type="text" onChange={ (e) => this.setState({alias: e.target.value}) } value={ this.state.alias } placeholder="alias"/>
            <input type="text" onChange={ (e) => this.setState({name: e.target.value}) } value={ this.state.name } placeholder="name"/>
            {/* <input type="text" onChange={ (e) => this.setState({code: e.target.value}) } value={ this.state.code } placeholder="group alias"/> */}
            <select  onChange={this.seturlpath} value={ this.state.type } >
                <option value="0">All</option>
                <option value="1">Student</option>
                <option value="2">Faculty</option>
            </select>
            <br/><Button onClick={this.queryUsers}> Search </Button> <span>OR &nbsp;&nbsp;&nbsp; Create a <a href="/insert_user">User</a></span>
            <Query urlpath={this.state.urlpath} results={this.state.users} hyperlink={true}/>
        </div>

        )
    }
}