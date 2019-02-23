import React from 'react';
import Query from '../QueryComponent/Query'

export default class UserGroupDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: false,
        usergroup_details: [],
        urlpath: "/user/"
      };
    }
    componentDidMount() {
      const { alias } = this.props.match.params
      fetch('http://localhost:5000/usergroup_details/?groupinput='+alias, {
        method: 'GET',
        dataType: 'json'
      })
        .then(res => res.json())
        .then((rjson) => {
            console.log(rjson)
            this.setState({
              isLoaded: true,
              usergroup_details: rjson.results
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
      const { error, isLoaded, usergroup_details } = this.state;
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
        return (
            <Query results={this.state.usergroup_details} urlpath={this.state.urlpath} hyperlink={true}/>
        );
      }
    }
  }
