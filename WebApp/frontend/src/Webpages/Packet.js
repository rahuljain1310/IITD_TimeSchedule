import React from 'react'
export default class Packet extends React.Component {
    render() {
        let x = this.props.data
        // begintime = this.props.data.begintime
        // endtime = this.props.data.endtime
        return (
            <span className="Packet">
                {x[1] + x[2]+x[3]+x[4]} <br/> 
            </span>
        )
    }
}
