import React from 'react';

export default class FacultyDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: false,
        faculty_details: []
      };
    }
    componentDidMount() {
      const { alias } = this.props.match.params
      fetch('http://localhost:5000/course_details/?='+alias, {
        method: 'GET',
        dataType: 'json'
      })
        .then(res => res.json())
        .then((rjson) => {
            console.log(rjson)
            this.setState({
              isLoaded: true,
              faculty_details: rjson.results
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
      const { error, isLoaded, faculty_details } = this.state;
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
        return (
          <ul>
            {faculty_details.map(course => (
              <li key={course.name}>
                    {course.name} {course.code}
              </li>
            ))}
          </ul>
        );
      }
    }
  }

  