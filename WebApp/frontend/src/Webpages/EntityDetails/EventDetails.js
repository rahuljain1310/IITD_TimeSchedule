import React from 'react';

export default class EventDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: false,
        event_details: []
      };
    }
    componentDidMount() {
      const { eventid } = this.props.match.params
      console.log(eventid)
      fetch('http://localhost:5000/event_details/?eventid='+eventid, {
        method: 'GET',
        dataType: 'json'
      })
        .then(res => res.json())
        .then((rjson) => {
            console.log(rjson)
            this.setState({
              isLoaded: true,
              event_details: rjson.results
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
      const { error, isLoaded, event_details } = this.state;
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
        return (
          <ul>
            {event_details.map(course => (
              <li key={course.name}>
                    {course.name} {course.code}
              </li>
            ))}
          </ul>
        );
      }
    }
  }

  