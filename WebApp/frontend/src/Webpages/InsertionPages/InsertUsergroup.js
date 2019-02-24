import React from 'react';
import ReactDOM from 'react-dom';
import Query from '../QueryComponent/Query.js'
import {Button} from 'react-bootstrap'

export default class InsertUsergroup extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            usergroup : "",
            usergroup_added: [],
            message: ""
        };
    }

    insert = (e) => {
        let {usergroup,usergroup_added} = this.state;
        let y = {usergroup}
        if(usergroup==="" ) {
            this.setState ({
                message : "Fill the field"                
            })
            return
        }
        this.setState ({
            message : "Adding Usergroup"                
        })
        let cq = "?usergroup="+this.state.usergroup
        fetch('http://localhost:5000/ins_usergroup/'+cq, {
            method: 'GET',
            dataType: 'json'
          })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                let x = jsres.results
                usergroup_added.push(y)
                this.setState({
                    usergroup_added: usergroup_added,
                    message: "Usergroup Added !",
                    usergroup: ""
                })
              },
              (message) => {
                // console.log(usergroup_added)
                // usergroup_added.push(y)
                this.setState({
                  usergroup_added: usergroup_added,
                  message:"Usergroup Not Added, Check Field",
                  usergroup: ""
                });
                // console.log(usergroup_added)
              }
            )
        setTimeout(()=> this.setState({message:""}),2000)
    }

    render() {
        return (
        <div className="search_div">
            <label>Usergroup :  </label> 
            <input type="text" onChange={ (e) => this.setState({usergroup: e.target.value}) } value={ this.state.usergroup } placeholder="E.g. COL362"/>
            <br/>
            <Button onClick={this.insert}> Add Usergroup </Button> 
            <br/>
            <span>{this.state.message}</span>
            <Query results={this.state.usergroup_added} urlpath="/usergroup/" hyperlink={true}/>
        </div>
        )
    }
}