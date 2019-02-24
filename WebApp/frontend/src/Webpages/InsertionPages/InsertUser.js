import React from 'react';
import Query from '../QueryComponent/Query.js'
import {Button} from 'react-bootstrap'

export default class InsertUser extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            name : "",
            alias: "",
            UserAdded: [],
            message: ""
        };
    }

    insert = (e) => {
        let {name, alias ,UserAdded} = this.state;
        let y = {alias,name}
        if(name==="" || alias==="" ) {
            this.setState ({
                message : "Fill the field"                
            })
            return
        }
        this.setState ({
            message : "Adding User to the database"                
        })
        let cq = "?name="+this.state.name+"&alias="+alias
        fetch('http://localhost:5000/ins_user/'+cq, {
            method: 'GET',
            dataType: 'json'
          })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                let x = jsres.results
                UserAdded.push(y)
                this.setState({
                    UserAdded: UserAdded,
                    message: "User Added !",
                    name: "",
                    alias:"",
                })
              },
              (message) => {
                this.setState({
                  message:"User Not Added, Check Field",
                  name: "",
                  alias:""
                });
              }
            )
        setTimeout(()=> this.setState({message:""}),2000)
    }

    render() {
        return (
        <div className="search_div">
            <h3>Insert User </h3>
            <label>Name :  </label> 
            <input type="text" onChange={ (e) => this.setState({name: e.target.value}) } value={ this.state.name } placeholder="E.g. Rahul Jain"/>
            <br/>
            <label>Alias :  </label> 
            <input type="text" onChange={ (e) => this.setState({alias: e.target.value}) } value={ this.state.alias } placeholder="E.g. ee1170476"/>
            <br/>
            <Button onClick={this.insert}> Add User </Button> 
            <br/>
            <span>{this.state.message}</span>
            <Query results={this.state.UserAdded} urlpath="/user/" hyperlink={true}/>
        </div>
        )
    }
}