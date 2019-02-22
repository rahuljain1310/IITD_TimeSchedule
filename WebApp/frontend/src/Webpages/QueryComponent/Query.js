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
                <a href={this.props.hyperlink && this.props.urlpath+"/?x="+row[0]}><Row tr={row}></Row></a>
            ))}
        </table>
        )
    }
}
