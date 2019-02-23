import React from 'react';
export default class Row extends React.Component {
    redirect = () => {
        let y = this.props.tr
        let x = y[Object.keys(y)[0]];
        window.location.href=this.props.urlpath+x
    }
    render() {
        let y = this.props.tr
        return (
        <tr onClick={this.props.hyperlink && this.redirect}>
                { Object.keys(y).map((key, index) => (
                    <td key={index}>{y[key]}</td>
                ))}
        </tr>
        )
    }
}
