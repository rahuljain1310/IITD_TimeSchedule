import React from 'react';
import ReactDOM from 'react-dom';

export default class Row extends React.Component {
    constructor(props) {
        super(props);
    }

    render() {
        let y = this.props.tr
        let x = y[Object.keys(y)[0]];
        return (
        <tr>
            <a href={this.props.hyperlink && this.props.urlpath+x}>
                { Object.keys(y).map((key, index) => (
                    <td>{y[key]}</td>
                ))}
            </a>
        </tr>
        )
    }
}
