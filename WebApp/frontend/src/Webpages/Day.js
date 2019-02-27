import React from 'react'
import './Day.css'
import Packet from './Packet.js'
export default class Day extends React.Component {
    render() {
        let {events} = this.props;
        console.log(events)
        let day = "Monday"
        let date = "13/10/1999"
        return (
            <div className="EventsinDay">
                <div className="Header">
                    {day}<br/>
                    {date}
                </div>
                {/* {this.props.events.map((object) => 
                    <Packet data={object} />
                )} */}
            </div>
        )
    }
}
