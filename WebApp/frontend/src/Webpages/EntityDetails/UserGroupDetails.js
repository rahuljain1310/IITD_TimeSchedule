import React from 'react';
import Query from '../QueryComponent/Query'
import { Button, Tabs, Tab } from 'react-bootstrap';

export default class UserGroupDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: false,
        groupalias: "",
        grouphost: [],
        users: [],
        events: [],
        urlpath: "/user/"
      };
    }
    componentDidMount() {
      const { groupcode } = this.props.match.params
      console.log(this.props)
      fetch('http://localhost:5000/usergroup_details/?groupinput='+groupcode, {
        method: 'GET',
        dataType: 'json'
      })
        .then(res => res.json())
        .then((rjson) => {
            console.log(rjson)
            this.setState({
              isLoaded: true,
              users: rjson.users,
              groupalias: rjson.groupalias,
              events: rjson.events,
              grouphost: rjson.groups_host,
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
      const { error, isLoaded, users } = this.state;
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
        return (
          <div>
            <h2>{this.state.groupalias}</h2>
            <Tabs defaultActiveKey="profile" id="uncontrolled-tab-example">
              <Tab eventKey="Hosts" title="Hosts">
                <Query results={this.state.grouphost} urlpath="/user/" hyperlink={true}/>  
              </Tab>
              <Tab eventKey="Events" title="Events">
                <Query results={this.state.events} urlpath="/event/" hyperlink={true}/>  
              </Tab>
              <Tab eventKey="Users" title="Users">
                <Query results={this.state.users} urlpath="/user/" hyperlink={true}/>  
              </Tab>
            </Tabs>
          </div>
        );
      }
    }
  }
