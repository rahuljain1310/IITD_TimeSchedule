import React from 'react';
import ReactDOM from 'react-dom';
import Row from './Row'
import './Query.css'

export default class Query extends React.Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
        <table>
            {this.props.results.map( (row) => (
                <Row tr={row} hyperlink={this.props.hyperlink} urlpath={this.props.urlpath}></Row>
            ))}
        </table>
        )
    }
}
