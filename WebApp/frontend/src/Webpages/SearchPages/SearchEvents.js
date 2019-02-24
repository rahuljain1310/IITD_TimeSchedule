import React from 'react';
import ReactDOM from 'react-dom';
import Query from '../QueryComponent/Query.js'
import {Button} from 'react-bootstrap'

export default class SearchEvents extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            host : "",
            name : "",
            group :"",
            events: [],
            urlpath: "/event/"
        };
    }

    queryEvents = (e) => {
        let cq = "?host="+this.state.host+'&name='+this.state.name+'&group='+this.state.group
        fetch('http://localhost:5000/findevents/'+cq, {
            method: 'GET',
            dataType: 'json'
          })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                this.setState({
                  isLoaded: true,
                  events: jsres.results
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
            <h3>Search Events:</h3>
            <input type="text" onChange={ (e) => this.setState({host: e.target.value}) } value={ this.state.host } placeholder="host"/>
            <input type="text" onChange={ (e) => this.setState({name: e.target.value}) } value={ this.state.name } placeholder="name"/>
            <input type="text" onChange={ (e) => this.setState({group: e.target.value}) } value={ this.state.group } placeholder="Group"/>
            <br/><Button onClick={this.queryEvents}> Search </Button> <span>OR &nbsp;&nbsp;&nbsp; Create a <a href="/insert_event">Event</a></span>
            <Query results={this.state.events} urlpath={this.state.urlpath} hyperlink={true}/>
        </div>

        )
    }
}