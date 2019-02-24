import React from 'react';
import ReactDOM from 'react-dom';
import Query from '../QueryComponent/Query.js'
import {Button,Tabs,Tab} from 'react-bootstrap'

export default class UpdateCourse extends React.Component {
    constructor(props) {
        super(props);
        const { code } = this.props.match.params
        this.state = {
            code: "",
            name : "",
            NameDisabled: true,
            Strength : "",
            StrengthDisabled: true,
            linkDescription: "",
            lkDisabled: true,
            isLoaded: false,
        };
    }

    update = (e) => {
        if(this.state.code==="") {
            this.setState ({
                error : "Fill the fields completely"                
            })
            return
        }
        let cq = "?code="+this.state.code+'&name='+this.state.name+'&slot='+this.state.slot+'&type='+this.state.type+'&L='+this.state.L+'&T='+this.state.T+'&P='+this.state.P+'&strength='+this.state.strength
        fetch('http://localhost:5000/ins_course/'+cq, {
            method: 'GET',
            dataType: 'json'
          })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                let x = jsres.results
                window.location.href=this.state.urlpath+this.state.code
              },
              (error) => {
                this.setState({
                  error:"Course Not Added, Check Fields"
                });
              }
            )
    }

    render() {
        return (
        <div className="search_div">
            <h3>Update Course: &nbsp; {this.state.code} </h3>
          
            <br/>
            <Tabs defaultActiveKey="profile" id="uncontrolled-tab-example">
                <Tab eventKey="UpdateCourse" title="Update Course Details">
                    <label>Course Name :</label>
                    <input type="checkbox" onChange={ (e) => this.setState({NameDisabled: !this.state.NameDisabled}) } name="CheckName"> Change Name</input>
                    <input type="text" disabled={this.state.NameDisabled} onChange={ (e) => this.setState({name: e.target.value}) } value={ this.state.name } placeholder="E.g. Introduction to DBMS"/>
                    <br/>  
                    <label>Strength :</label>
                    <input type="checkbox" onChange={ (e) => this.setState({StrengthDisabled: !this.state.StrengthDisabled}) } name="CheckName"> Change Name</input>
                    <input type="text" disabled={this.state.StrengthDisabled}  onChange={ (e) => this.setState({strength: e.target.value}) } value={ this.state.strength } placeholder="E.g. 78"/>
                    
                    <label>Strength :</label>
                    <input type="checkbox" onChange={ (e) => this.setState({lkDisabled: !this.state.lkDisabled}) } name="CheckName"> Change Name</input>
                    <input type="text" disabled={this.state.lkDisabled}  onChange={ (e) => this.setState({strength: e.target.value}) } value={ this.state.strength } placeholder="E.g. 78"/>
               
                    <br/><Button onClick={this.update}> Update Course </Button> 
                    <span>{this.state.error}</span>
                </Tab>
                <Tab eventKey="RegisterS" title="Register Student">
                    <label>Register Student</label>
                    <br/>
                </Tab>
            </Tabs>
        </div>
        )
    }
}