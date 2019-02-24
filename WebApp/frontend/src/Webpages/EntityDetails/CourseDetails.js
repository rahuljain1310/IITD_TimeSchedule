import React from 'react';
import Query from '../QueryComponent/Query'
import { Button, Tabs, Tab } from 'react-bootstrap';

export default class CourseDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: true,
        course_details: {},
        prof_list :[],
        Student_registered:[],
        old_courses: [],
      };
    }
    componentDidMount() {
      const { code } = this.props.match.params
      console.log(code)
      fetch('http://localhost:5000/course_details/?code='+code, {
        method: 'GET',
        dataType: 'json'
      })
        .then(res => res.json())
        .then((rjson) => {
            console.log(rjson)
            this.setState({
              isLoaded: true,
              course_details: rjson.curcourse,
              prof_list: rjson.profs,
              old_courses:rjson.oldcourses,
              Student_registered:rjson.registered,
            });
          },
          (error) => {
            this.setState({
              isLoaded: true,
              // error
            });
          }
        )
    }
  
    render() {
      const { error, isLoaded, course_details } = this.state;
      let x = course_details
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
        return (
          <div className="container">
              <h2>{x.curcode}: &nbsp; {x.curname} </h2>
             <Tabs defaultActiveKey="profile" id="uncontrolled-tab-example">
              <Tab eventKey="Current Course" title="Current Course">
                <article>
                  <h5>Credits : {x.curcredits}</h5>
                  <h5>Type : {x.curtype}</h5>
                  <h5>Strength : {x.curstrength}</h5>
                  <h5>Registered: {x.curregist}</h5>
                  <h5>Lecture Hours :{x.curlec}</h5>
                  <h5>Tutorial Hours : {x.curtut}</h5>
                  <h5>Practical Hours :{x.curprac}</h5>
                  <h5>Slot :{x.curslott}</h5>
                  <br/><br/>
                  <h5> <a href="/web">Course Webpage</a> </h5>
                </article>
              </Tab>
              <Tab eventKey="Old Courses" title="Old Courses">
                <Query results={this.state.old_courses} urlpath={this.state.urlpath} hyperlink={true}/>  
              </Tab>
              <Tab eventKey="Professor" title="Professor">
                <Query results={this.state.prof_list} urlpath={this.state.urlpath} hyperlink={true}/>  
              </Tab>
              <Tab eventKey="Registered Students" title="Registered Students">
                <Query results={this.state.Student_registered} urlpath={this.state.urlpath} hyperlink={true}/>  
              </Tab>
            </Tabs>
          </div>
        );
      }
    }
  }
