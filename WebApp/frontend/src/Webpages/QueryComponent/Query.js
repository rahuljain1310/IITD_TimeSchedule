import React from 'react';
import Row from './Row'
import './Query.css'

export default class Query extends React.Component {
    render() {
        return (
        <div id="query" className="container">
            <table className="table table-bordered table-hover">
                <tbody>
                {this.props.results.map( (row,index) => (
                    <Row tr={row} hyperlink={this.props.hyperlink} urlpath={this.props.urlpath} key={index}></Row>
                ))}
                </tbody>
            </table>
        </div>   
        )
    }
}
