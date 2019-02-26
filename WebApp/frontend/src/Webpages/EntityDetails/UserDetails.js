import React from 'react';
import {Button,Tabs,Tab} from 'react-bootstrap'
import Query from '../QueryComponent/Query';

export default class UserDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: false,
        all_events: [],
        type: 1,
        cur_course_registered: [],
        cur_courses_taken: [],
        old_courses_registered: [],
        user_details: {},
        events_hosted: [],
        in_groups: [],
        username: "",
        old_courses_taken: [],
        alias: "",
      };
    }
    componentDidMount() {
      const { alias } = this.props.match.params
      console.log(alias)
      fetch('http://localhost:5000/user_details/?alias='+alias, {
        method: 'GET',
        dataType: 'json'
      })
        .then(res => res.json())
        .then((rjson) => {
            console.log(rjson)
            this.setState({
              isLoaded: true,
              user_details: rjson,
              all_events: rjson.all_events,
              alias: rjson.alias,
              type: rjson.type,
              cur_course_registered: rjson.cur_course_registered,
              cur_courses_taken: rjson.cur_courses_taken,
              events_hosted: rjson.events_hosted,
              in_groups: rjson.in_groups,
              username: rjson.username,
              old_courses_registered: rjson.old_courses_registered,
              old_courses_taken: rjson.old_courses_taken,
              userwebpage: "",
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
      const { error, isLoaded, user_details, type1 } = this.state;
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
        return (
          <div>
              {/* <h3>Update User: &nbsp; {this.state.alias.toUpperCase()} </h3> */}
              <br/>
            {/* {  JSON.stringify(this.state.user_details,null,2) } */}
            <h4>{"Alias :    "+this.state.alias}</h4>
            <span> &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Update <a href={"/update_user/"+this.state.alias}>User</a></span>
            <Tabs defaultActiveKey="profile" id="uncontrolled-tab-example">
              <Tab eventKey="Details" title="Details">
              <div className="update_div">
                <h6>{"Username : "+this.state.username} </h6>
                <h6>{"Username Webpage : "+this.state.userwebpage} </h6>
                <h6>{this.state.type == 1 && "Usertype: Student"}</h6>
                <h6>{this.state.type == 2 && "Usertype: Professor"}</h6>
              </div>
              </Tab>
              <Tab eventKey="All events" title="All events">
                <Query results={this.state.all_events} urlpath="/event/" hyperlink={true}/>
              </Tab>
              { this.state.type == 1 &&
              <Tab eventKey="454" title="Current Courses">
                <Query results={this.state.cur_course_registered} urlpath="/course/" hyperlink={true}/>
              </Tab> }
              { this.state.type == 2 &&
              <Tab eventKey="455" title="Current Courses Taken">
                <Query results={this.state.cur_courses_taken} urlpath="/course/" hyperlink={true}/>
              </Tab> }
              <Tab eventKey="456" title="Events Hosted">
                <Query results={this.state.events_hosted} urlpath="/course/" hyperlink={true}/>
              </Tab>
                { this.state.type == 1 &&
              <Tab eventKey="545" title="Old Courses">
                <Query results={this.state.old_courses_registered} urlpath="/course/" hyperlink={true}/>
              </Tab> }
              { this.state.type == 2  && 
              <Tab eventKey="3463" title="Old Courses Taken">
                <Query results={this.state.old_courses_taken} urlpath="/course/" hyperlink={true}/>
              </Tab> }
              <Tab eventKey="64" title="In Groups">
                <Query results={this.state.in_groups} urlpath={this.state.urlpath} hyperlink={true}/>
              </Tab>
              {/* <Tab eventKey="UpdateUser" title="Update User Details">
                <Query results={this.state.Student_registered} urlpath={this.state.urlpath} hyperlink={true}/>
              </Tab> */}
            </Tabs>
          </div>
        );
      }
    }
  }