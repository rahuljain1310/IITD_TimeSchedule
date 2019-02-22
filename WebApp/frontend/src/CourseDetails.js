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
      fetch('http://localhost:5000/courses_all')
        .then(res => {
            console.log(res)
            res.json()
        })
        .then(
          (result) => {
            console.log(result)
            this.setState({
              isLoaded: true,
              courses: result.courses
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
                <a href="http://localhost:5000/">
                    {course.name} {course.code}
                </a>
              </li>
            ))}
          </ul>
        );
      }
    }
  }

  export default CourseDetails