import React from 'react';
import {Tabs, Tab, Button} from 'react-bootstrap'
import Query from '../QueryComponent/Query'
export default class EventDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: false,
        event_details: [],
        e_group: "",
        e_hosts: "",
        e_id: "",
        e_linkto:"",
        e_name: "",
        e_time: [],
        e_users: [],
        e_weekly: [],
      };
    }
    componentDidMount() {
      const { eventid } = this.props.match.params
      console.log(eventid)
      fetch('http://localhost:5000/event_details/?eventid='+eventid, {
        method: 'GET',
        dataType: 'json'
      })
        .then(res => res.json())
        .then((rjson) => {
            console.log(rjson)
            this.setState({
              isLoaded: true,
              event_details: rjson,
              e_group: rjson.e_group,
              e_hosts: rjson.e_hosts,
              e_id: rjson.e_id,
              e_linkto: rjson.e_linkto,
              e_name: rjson.e_name,
              e_time: rjson.e_time,
              e_users: rjson.e_users,
              e_weekly: rjson.e_weekly,
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
      let weekly = ""
      this.state.e_weekly.map((slot) => weekly+=slot+", ")
      const { error, isLoaded, event_details } = this.state;
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
        return (
          <div>
            {/* {  JSON.stringify(this.state.event_details,null,2) } */}
          <h6>{"Event: "+this.state.e_name}</h6>
          <h6>{"Host: "+this.state.e_hosts}</h6>
          <h6>{"Usergroup: "+this.state.e_group}</h6>
          <h6>{"Slot:"+weekly}</h6>
          <h6>{"Link To:  "}<a href={this.state.e_linkto}>{this.state.e_linkto}</a></h6>
          {/* <h6>{"Time: "+this.state.e_time}</h6> */}
          <h6></h6>
          <span> &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Update <a href={"/update_event/"+this.state.e_id}>Event</a></span>
          <h1></h1><br/>
          <Tabs defaultActiveKey="profile" id="uncontrolled-tab-example">
            <Tab eventKey="Users" title="Users">
              <Query results={this.state.e_users} urlpath="/user/" hyperlink={true}/>
            </Tab>
            <Tab eventKey="Users" title="Users">
              <Query results={this.state.e_users} urlpath="/user/" hyperlink={true}/>
            </Tab>
            <Tab eventKey="454" title="Time">
              <Query results={this.state.e_time} urlpath="/course/" hyperlink={false}/>
            </Tab> 
            { this.state.type == 2 &&
            <Tab eventKey="455" title="Current Courses Taken">
              <Query results={this.state.cur_courses_taken} urlpath={this.state.urlpath} hyperlink={true}/>
            </Tab> }
          </Tabs>
            </div>
            
        );
      }
    }
  }

  