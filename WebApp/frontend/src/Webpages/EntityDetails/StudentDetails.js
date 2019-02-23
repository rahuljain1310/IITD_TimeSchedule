import React from 'react';

export default class StudentDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: false,
        student_details: []
      };
    }
    componentDidMount() {
      const { alias } = this.props.match.params
      fetch('http://localhost:5000/student_details/?alias='+alias, {
        method: 'GET',
        dataType: 'json'
      })
        .then(res => res.json())
        .then((rjson) => {
            console.log(rjson)
            this.setState({
              isLoaded: true,
              student_details: rjson.results
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
      const { error, isLoaded, student_details } = this.state;
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
        return (
          <ul>
            {student_details.map(course => (
              <li key={course.name}>
                    {course.name} {course.code}
              </li>
            ))}
          </ul>
        );
      }
    }
  }
