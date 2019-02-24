import React from 'react';

export default class CourseDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: true,
        course_details: []
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
              course_details: rjson.coursedetails
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
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
        return (
          // <ul>
          //   {course_details.map(course => (
          //     <li key={course.name}>
          //           {course.name} {course.code}
          //     </li>
          //   ))}
          // </ul>
          <div className="container">
              <header>
                  <h2>COL362 Intro. To Database</h2>
              </header>
            <article>
              <h4>Instructor : {this.props.instructor}</h4>
              <h4>Credits : {this.props.credit}</h4>
              <h4>Strength : {this.props.strngth}</h4>
              <h4>Lecture Hours :{this.props.l}</h4>
              <h4>Tutorial Hours : {this.props.t}</h4>
              <h4>Practical Hours :{this.props.p}</h4>
              <a>SLOT : {this.props.slot}</a>
              <h3> <a href="/web">Course Webpage</a> </h3>
              <div> <a href="/col216students">Registered Students</a></div>
            </article>
          </div>
        );
      }
    }
  }
