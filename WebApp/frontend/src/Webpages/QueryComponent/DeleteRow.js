import React from 'react';
import {Button} from 'react-bootstrap'
export default class DeleteRow extends React.Component {
    redirect = () => {
        let y = this.props.tr
        let x = y[Object.keys(y)[0]];
        window.location.href=this.props.urlpath+x
    }

    render() {
        let y = this.props.tr
        let x = y[Object.keys(y)[0]];
        return (
        <tr onClick={this.props.hyperlink && this.redirect}>
                { Object.keys(y).map((key, index) => (
                    <td key={index}>{y[key]}</td>
                ))}
                <td>
                <Button type="button" className="btn btn-sm" onClick={(e) => this.props.delete(this.props.index,x)}>
                    <span className="glyphicon glyphicon-remove"></span> {this.props.text} 
                </Button>
                </td>
        </tr>
        )
    }
}
