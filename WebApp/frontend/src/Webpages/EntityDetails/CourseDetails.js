import React from 'react';

export default class CourseDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: false,
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
              course_details: rjson.results
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
          <div class="container">
            <div class="row">
              <div class="span4">
                <div class="inner-heading">
                  <h2>{this.props.name}</h2>
                  <h4>{this.props.code}</h4>
                </div>
              </div>
              <div class="span8">
              </div>
            </div>
          </div>
        );
      }
    }
  }
