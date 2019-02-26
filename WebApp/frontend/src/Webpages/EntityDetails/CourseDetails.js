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
              course_details: rjson.coursedetails,
              prof_list: rjson.profs,
              old_courses:rjson.oldcourse,
              Student_registered:rjson.students,
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
              <h2>{x[1]}: &nbsp; {x[2]} </h2>
              <span> &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Update <a href={"/update_course/"+x[1]}>Course</a></span>
             <Tabs defaultActiveKey="profile" id="uncontrolled-tab-example">
              <Tab eventKey="Current Course" title="Current Course">
                <article>
                  <h6>Credits : {x[5]}</h6>
                  <h6>Type : {x[4]}</h6>
                  <h6>Strength : {x[9]}</h6>
                  <h6>Registered: {x[10]}</h6>
                  <h6>Lecture Hours :{x[6]}</h6>
                  <h6>Tutorial Hours : {x[7]}</h6>
                  <h6>Practical Hours :{x[8]}</h6>
                  <h6>Slot :{x[3]}</h6>
                  <br/><br/>
                  <h6> <a href="/web">Course Webpage</a> </h6>
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
