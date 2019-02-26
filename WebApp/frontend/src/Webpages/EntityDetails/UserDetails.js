import React from 'react';

export default class UserDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: false,
        alias: "",
        // user_details: {},
        username: "",
        userwebpage: "",
        curr_course_registered: [],
        old_courses_registered: [],
        curr_courses_taken: [],
        old_courses_taken: [],
        events_hosted: [],
        all_events: [],
        type1: "",
        in_groups: []
      };
    }
    componentDidMount() {
      const { alias } = this.props.match.params
      fetch('http://localhost:5000/user_details/?='+alias, {
        method: 'GET',
        dataType: 'json'
      })
        .then(res => res.json())
        .then((rjson) => {
            console.log(rjson)
            this.setState({
              isLoaded: true,
              alias: rjson.alias,
              username: rjson.username,
              userwebpage: rjson.userwebpage,
              curr_courses_registered: rjson.curr_courses_registered,
              old_courses_registered: rjson.old_courses_registered,
              curr_courses_taken: rjson.curr_courses_taken,
              old_courses_taken: rjson.old_courses_taken,
              events_hosted: rjson.events_hosted,
              all_events: rjson.all_events,
              type1: rjson.type1,
              in_groups: rjson.in_groups,
              user_details: rjson
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
      const { error, isLoaded, user_details, type1 } = this.state;
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
          if (type1=='curr_stu') {

          }
          else if (type1=='old_stu'){

          }
          else if (type1=='curr_prof'){

          }
          else if (type1=='old_prof'){

          }
          else if (type1=='otheruser'){

          }
          else{
            return (
              <div>
                   {/* <ul>
                      {user_details.map(course => (
                      <li key={course.name}>
                              {course.name} {course.code}
                      </li>
                      ))}
                  </ul> */}
                  {user_details}
              </div>
          
          );
          }
        
      }
    }
  }