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
        user_details: {},
        events_hosted: [],
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
              // type: rjson.type,
              cur_course_registered: rjson.cur_course_registered,
              cur_courses_taken: rjson.cur_courses_taken,
              events_hosted: rjson.events_hosted,

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
      const { error, isLoaded, user_details } = this.state;
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
        return (
          <div>
              {/* <h3>Update User: &nbsp; {this.state.alias.toUpperCase()} </h3> */}
              <br/>
            {  JSON.stringify(this.state.user_details,null,2) }
          
            <Tabs defaultActiveKey="profile" id="uncontrolled-tab-example">
              <Tab eventKey="All events" title="All events">
                <Query results={this.state.all_events} urlpath={this.state.urlpath} hyperlink={true}/>
              </Tab>
              { this.state.type == 1 &&
              <Tab eventKey="454" title="Current Courses">
                <Query results={this.state.cur_course_registered} urlpath={this.state.urlpath} hyperlink={true}/>
              </Tab> }
              { this.state.type == 2 &&
              <Tab eventKey="455" title="Current Courses Taken">
                <Query results={this.state.cur_courses_taken} urlpath={this.state.urlpath} hyperlink={true}/>
              </Tab> }
              <Tab eventKey="456" title="Events Hosted">
                <Query results={this.state.events_hosted} urlpath={this.state.urlpath} hyperlink={true}/>
                { this.state.type == 1 &&
              <Tab eventKey="454" title="Current Courses">
                <Query results={this.state.cur_course_registered} urlpath={this.state.urlpath} hyperlink={true}/>
              </Tab> }
              </Tab><Tab eventKey="UpdateUser" title="Update User Details">
                <Query results={this.state.Student_registered} urlpath={this.state.urlpath} hyperlink={true}/>
              </Tab><Tab eventKey="UpdateUser" title="Update User Details">
                <Query results={this.state.Student_registered} urlpath={this.state.urlpath} hyperlink={true}/>
              </Tab><Tab eventKey="UpdateUser" title="Update User Details">
                <Query results={this.state.Student_registered} urlpath={this.state.urlpath} hyperlink={true}/>
              </Tab><Tab eventKey="UpdateUser" title="Update User Details">
                <Query results={this.state.Student_registered} urlpath={this.state.urlpath} hyperlink={true}/>
              </Tab><Tab eventKey="UpdateUser" title="Update User Details">
                <Query results={this.state.Student_registered} urlpath={this.state.urlpath} hyperlink={true}/>
              </Tab><Tab eventKey="UpdateUser" title="Update User Details">
                <Query results={this.state.Student_registered} urlpath={this.state.urlpath} hyperlink={true}/>
              </Tab>
            </Tabs>
          </div>
        );
      }
    }
  }