import React from 'react';
import ReactDOM from 'react-dom';
import Query from '../QueryComponent/Query.js'
import {Button} from 'react-bootstrap'

export default class InsertEvent extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            usergroup : "",
            eventname : "",
            user : "",
            linkDescription : "",
            error: "",
        };
    }

    insert = (e) => {
        let {usergroup, eventname,user, linkDescription} = this.state;
        if(usergroup==="" || eventname=="" || user=="") {
            this.setState ({
                error : "Fill the fields completely"                
            })
            return
        }
        this.setState ({
            error : "Adding Event"                
        })
        let cq = "?usergroup="+this.state.usergroup+'&eventname='+this.state.eventname+'&user='+this.state.user+'&linkDescription='+this.state.linkDescription
        fetch('http://localhost:5000/ins_event/'+cq, {
            method: 'GET',
            dataType: 'json'
          })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                let x = jsres.results
                console.log(x)
                try {
                    if(x!=='success')
                    throw "500"
                    this.setState({
                        error: "Event Added !"
                    })
                } catch(e) {
                    this.setState({
                        error:"Course Not Added, Check Fields"
                      });
                }
              },
              (error) => {
                this.setState({
                  error:"Course Not Added, Check Fields"
                });
              }
            )
    }

    render() {
        return (
        <div className="search_div">

            <label></label>
            
            <label>Usergroup :  </label> 
            <input type="text" onChange={ (e) => this.setState({usergroup: e.target.value}) } value={ this.state.usergroup } placeholder="E.g. COL362"/>
            <br/>

            <label>Eventname :  </label>
            <input type="text" onChange={ (e) => this.setState({eventname: e.target.value}) } value={ this.state.eventname } placeholder="E.g. Intro. to DBMS"/>
            <br/>

            <label>User :  </label>
            <input type="text" onChange={ (e) => this.setState({user: e.target.value}) } value={ this.state.user } placeholder=""/>
            <br/>

            <label>Any linkDescription:</label>
            <input type="text" onChange={ (e) => this.setState({linkDescription: e.target.value}) } value={ this.state.linkDescription } placeholder="Year"/>
            <br/>

            <Button onClick={this.insert}> Add Event </Button> 
            <br/>
            <span>{this.state.error}</span>
        </div>
        )
    }
}