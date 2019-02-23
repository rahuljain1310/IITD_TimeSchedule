import React from 'react';
import Query from '../QueryComponent/Query.js'

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
        <div>
            <input type="text" onChange={ (e) => this.setState({groupinput: e.target.value}) } value={ this.state.groupinput } placeholder="User Groups"/>
            <button onClick={this.queryusergroups}> Go </button>
            <Query results={this.state.usergroups} urlpath={this.state.urlpath} hyperlink={true}/>
        </div>

        )
    }
}
