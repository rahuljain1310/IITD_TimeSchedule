import React from 'react';
import ReactDOM from 'react-dom';

class Timetable extends React.Component {

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
        return (
            <div>
                Hello Timetable
            </div>
        )
    }
}

export default Timetable