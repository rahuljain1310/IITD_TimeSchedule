import React from 'react'
import './Day.css'
import Packet from './Packet.js'
export default class Day extends React.Component {
    render() {
        let {information} = this.props;
        let date = "13/10/1999"
        console.log(information)
        return (
            <div className="EventsinDay">
                <div className="Header">
                    {this.props.day}<br/>
                </div>
                {this.props.information.map((object) => 
                    <Packet data={object} />
                )}
            </div>
        )
    }
}
