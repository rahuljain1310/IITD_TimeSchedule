import React from 'react';
import Query from '../QueryComponent/Query.js'
import {Button} from 'react-bootstrap'

export default class SearchUserGroups extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            groupinput : "",
            usergroups: [],
            urlpath: "/usergroup/"
        };
    }

    queryusergroups = (e) => {
        let cq = "?groupalias="+this.state.groupinput
        fetch('http://localhost:5000/findusergroups/'+cq, {
            method: 'GET',
            dataType: 'json'
          })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                this.setState({
                  isLoaded: true,
                  usergroups: jsres.results
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
            <h3>Search Usergroup:</h3>
            <input type="text" onChange={ (e) => this.setState({groupinput: e.target.value}) } value={ this.state.groupinput } placeholder="User Groups"/>
            <br/><Button onClick={this.queryusergroups}> Search </Button> <span>OR &nbsp;&nbsp;&nbsp; Create a <a href="/insert_usergroup">Usergroup</a></span>
            <Query results={this.state.usergroups} urlpath={this.state.urlpath} hyperlink={true}/>
        </div>

        )
    }
}
