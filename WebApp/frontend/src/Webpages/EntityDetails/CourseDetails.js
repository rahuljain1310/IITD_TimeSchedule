import React from 'react';
import ReactDOM from 'react-dom';

class CourseDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: false,
        courses: []
      };
    }
    componentDidMount() {
      const { code } = this.props.match.params
      fetch('http://localhost:5000/course_details/?='+code, {
        method: 'GET',
        dataType: 'json'
      })
        .then(res => res.json())
        .then((rjson) => {
            console.log(rjson)
            this.setState({
              isLoaded: true,
              courses: rjson.results
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
      const { error, isLoaded, courses } = this.state;
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
        return (
          <ul>
            {courses.map(course => (
              <li key={course.name}>
                    {course.name} {course.code}
              </li>
            ))}
          </ul>
        );
      }
    }
  }

  export default CourseDetails