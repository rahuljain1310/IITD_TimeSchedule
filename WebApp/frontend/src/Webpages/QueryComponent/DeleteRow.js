import React from 'react';
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
                <button type="button" class="btn btn-default btn-sm" onClick={this.props.delete(this.props.key,x)}>
                    <span class="glyphicon glyphicon-remove"></span> Remove 
                </button>
                </td>
        </tr>
        )
    }
}
