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
            venue : "",
            linkDescription : "",
            error: "",
        };
    }

    insert = (e) => {
        let {usergroup, eventname,venue, linkDescription} = this.state;
        if(usergroup==="" || eventname=="" || venue=="") {
            this.setState ({
                error : "Fill the fields completely"                
            })
            return
        }
        this.setState ({
            error : "Adding Event"                
        })
        let cq = "?usergroup="+this.state.usergroup+'&eventname='+this.state.eventname+'&venue='+this.state.venue+'&linkDescription='+this.state.linkDescription
        fetch('http://localhost:5000/ins_event/'+cq, {
            method: 'GET',
            dataType: 'json'
          })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                let x = jsres.results
                this.setState({
                    error: "Event Added !"
                })
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

            <label>Venue :  </label>
            <input type="text" onChange={ (e) => this.setState({venue: e.target.value}) } value={ this.state.venue } placeholder=""/>
            <br/>

            <label>Any linkDescription:</label>
            <input type="text" onChange={ (e) => this.setState({linkDescription: e.target.value}) } value={ this.state.linkDescription } placeholder="Year"/>
            <br/>

            {/* <label>L    :</label>
            <input linkDescription="text" onChange={ (e) => this.setState({L: e.target.value}) } value={ this.state.L } placeholder="L"/>
            <br/><span className="error">{this.state.semesterError}</span><br/>

            <label>T   :</label>
            <input linkDescription="text" onChange={ (e) => this.setState({T: e.target.value}) } value={ this.state.T } placeholder="T"/>
            <br/><span className="error">{this.state.semesterError}</span><br/>

            <label>P    :</label>
            <input linkDescription="text" onChange={ (e) => this.setState({P: e.target.value}) } value={ this.state.P } placeholder="P"/>
            <br/><span className="error">{this.state.semesterError}</span><br/>

            <label>Strength    :</label>
            <input linkDescription="text" onChange={ (e) => this.setState({strength: e.target.value}) } value={ this.state.strength } placeholder="strength"/>
            <br/><span className="error">{this.state.semesterError}</span><br/> */}

            <Button onClick={this.insert}> Add Event </Button> 
            <br/>
            <span>{this.state.error}</span>
        </div>
        )
    }
}