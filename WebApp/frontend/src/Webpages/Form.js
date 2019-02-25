import React from 'react'
export default class Form extends React.Component {
    constructor(props) {
        super(props)
        x = this.props.inputs.keys()
        this.state = {
            inputs: x,
            output: {}
        }
    }

    // API URL NEEDED + ARGUMENTS
    query = ()=> {
        let cq="?",i=0
        this.props.input.forEach(element => {
            cq=cq+element+"="+output[i]+"&"
            i++
        });
        fetch("http://localhost:5000"+apipath+cq, {
            method: 'GET',
            dataType: 'json'
          })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                this.setState({
                  output: jsres
                });
              },
              (error) => {
                this.setState({
                  error
                });
              }
            )
        
    }
    render() {
        return (
            <div className="search_div">
                
            </div>
        )
    }
}