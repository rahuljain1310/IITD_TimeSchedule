import React from 'react';
import ReactDOM from 'react-dom';

export default class Row extends React.Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
        <tr>
            { Object.keys(this.props.tr).map((key, index) => (
                <td>{this.props.tr[key]}</td>
            ))}
        </tr>
        )
    }
}
