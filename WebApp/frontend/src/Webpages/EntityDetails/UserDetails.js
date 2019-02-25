import React from 'react';

export default class UserDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: false,
        user_details: {}
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
      const { error, isLoaded, user_details } = this.state;
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
        return (
          <div>
            {  JSON.stringify(this.state.event_details,null,2) }
          </div>
        
        );
      }
    }
  }