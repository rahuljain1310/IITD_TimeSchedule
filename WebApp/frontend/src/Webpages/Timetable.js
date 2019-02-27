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
      let {events} = this.state
      let mon = []
      let tue = []
      let wed = []
      let thurs = []
      let fri = []
      events.map((o)=> {
        if(o[0]=="Mon")
          mon.push(o)
        if(o[0]=="Tue")
          tue.push(o)
        if(o[0]=="Wed")
          wed.push(o)
        if(o[0]=="Thu")
          thurs.push(o)
        if(o[0]=="Fri")
          fri.push(o)
      })

      console.log(events)
      return (
            <div className="update_div">
                <Day information={mon} day="Monday" ></Day>
                <Day information={tue} day="Tuesday" ></Day>
                <Day information={wed} day="Wednesday" ></Day>
                <Day information={thurs} day="Thursday" ></Day>
                <Day information={fri} day="Friday" ></Day>
            </div>
        )
    }
}

export default Timetable