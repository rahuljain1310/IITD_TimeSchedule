import React from 'react';
import ReactDOM from 'react-dom';
import Day from './Day.js'

class Timetable extends React.Component {

    constructor(props) {
      super(props)
      this.state = {
        events: [5 ,10],
      }
    }

    componentDidMount() {
      this.setState({
        events: this.props.events,
      })   
    }
    
    render() {
        console.log(this.state.events)
        return (
            <div className="update_div">
                {this.state.events.map((object) => 
                  <Day information={object}></Day>
              )}
            </div>
        )
    }
}

export default Timetable