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
            alias: "",
            groupno:"",
            update_error: "",
            register_error: "",
        };
    }

    update = (e) => {
        
        const { code } = this.props.match.params
        let cq = "?strength="+this.state.Strength+'&name='+this.state.name+'&link='+this.state.linkDescription+'&code='+code+'&type=1'
        fetch('http://localhost:5000/upd_course/'+cq, {
            method: 'GET',
            dataType: 'json'
          })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                let x = jsres
              },
              (error) => {
                this.setState({
                  error:"Not Added, Check Fields"
                });
              }
            )
    }

    registerStudent = (e) => {
        let {alias, groupno} = this.state
        this.setState({
            register_error: "Registering Student"
        })
        let cq = "?alias="+alias+"&groupno="+groupno
        fetch('http://localhost:5000/registerStudent/'+cq, {
            method: 'GET',
            dataType: 'json'
          })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                let x = jsres
                this.setState({
                    error:"Student Registered"
                })
              },
              (error) => {
                this.setState({
                  error:"Registering A Student Failed"
                });
              }
            )
        setTimeout(() => this.setState({error:""}), 2000);

    }

    render() {
        return (
        <div className="update_div">
            <h3>Update Course: &nbsp; {this.state.code} </h3>
            <br/>
            <Tabs defaultActiveKey="profile" id="uncontrolled-tab-example">
                <Tab eventKey="UpdateCourse" title="Update Course Details">
                    <div className="update_div">
                        <label>Course Name :</label><br/>
                        <input type="checkbox" onChange={ (e) => this.setState({NameDisabled: !this.state.NameDisabled,name:""} ) } name="CheckName"/> 
                        <input type="text" className="update-input" disabled={this.state.NameDisabled} onChange={ (e) => this.setState({name: e.target.value}) } value={ this.state.name } placeholder="E.g. Introduction to DBMS"/>
                        <br/>  
                        <label>Strength :</label><br/>
                        <input type="checkbox" onChange={ (e) => this.setState({StrengthDisabled: !this.state.StrengthDisabled,strength:""}) } name="CheckName"/>  
                        <input type="text" className="update-input" disabled={this.state.StrengthDisabled}  onChange={ (e) => this.setState({strength: e.target.value}) } value={ this.state.strength } placeholder="E.g. 78"/>
                        <br/>
                        <label>Link Description :</label><br/>
                        <input type="checkbox" onChange={ (e) => this.setState({lkDisabled: !this.state.lkDisabled,linkDescription:""}) } name="CheckName"/>
                        <input type="text" className="update-input" disabled={this.state.lkDisabled}  onChange={ (e) => this.setState({linkDescription: e.target.value}) } value={ this.state.linkDescription } placeholder="www..iitd.example.com"/>
                        <br/><Button onClick={this.update}> Update Course </Button> 
                        <span>{this.state.update_error}</span>
                    </div>
                </Tab>
                <Tab eventKey="Register" title="Register Student">
                    <div  className="update_div">
                        <label>Student Entry No. :</label><br/>
                        <input type="text" className="update-input" onChange={ (e) => this.setState({alias: e.target.value}) } value={ this.state.name } placeholder="EE1170476"/>
                        <br/>
                        <label>Group No. :</label><br/>
                        <input type="text" className="update-input" onChange={ (e) => this.setState({groupno: e.target.value}) } value={ this.state.groupno } placeholder="Cycle of Student"/>
                        <br/><Button onClick={this.registerStudent}> Register Stuents </Button> 
                        <br/>
                        <span>{this.state.register_error}</span>
                    </div>
                </Tab>
            </Tabs>
        </div>
        )
    }
}