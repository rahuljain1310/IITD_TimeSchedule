import React from 'react';
import DeleteRow from './DeleteRow'
import './Query.css'

export default class DeleteQuery extends React.Component {
    constructor(props) {
        super(props)
        console.log(this.props)
        this.state = {
            results: this.props.results,
        }
    }

    deleterow = (index, delelement) => {
        fetch('http://localhost:5000'+this.props.deleteurl+delelement+this.props.extraparam, {
            method: 'GET',
            dataType: 'json'
            })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                    let x = jsres
                    let newresults = this.state.results
                    newresults.splice(x,1)
                    this.setState({
                        results: newresults,
                    })
                },
                (error) => {
                    return 
            })        
       
    }

    render() {
        if(!this.state.results || this.state.results.length==0)
            return (
                <div>
                    <br/>No Results Yet to be Displayed    
                </div>
            )
        return (
        <div>
            <div id="query">
                <table className="table table-bordered table-hover">
                    <tbody>
                    {this.state.results.map( (row,index) => (
                        <DeleteRow tr={row} key={index} index={index} delete={this.deleterow} text={this.props.text}/>
                    ))}
                    </tbody>
                </table>
            </div>   
        </div>
        )
    }
}
