import React from 'react';
import ReactDOM from 'react-dom';
import Query from '../QueryComponent/Query.js'
import {Button} from 'react-bootstrap'

export default class InsertCourses extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            code : "",
            name : "",
            slot : "",
            type : "",
            L : "",
            T : "",
            P: "",
            Strength : "",
            // courses: [],
            error: "",
            urlpath: "/courses/"
        };
    }

    insert = (e) => {
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
            <label>Course Code :  </label> 
            <input type="text" onChange={ (e) => this.setState({code: e.target.value}) } value={ this.state.code } placeholder="E.g. COL362"/>
            <br/><span className="error">{this.state.codeError}</span><br/>

            <label>Course Name :  </label>
            <input type="text" onChange={ (e) => this.setState({name: e.target.value}) } value={ this.state.name } placeholder="E.g. Intro. to DBMS"/>
            <br/><span className="error">{this.state.nameError}</span><br/>

            <label>Slot        :  </label>
            <input type="text" onChange={ (e) => this.setState({slot: e.target.value}) } value={ this.state.slot } placeholder=""/>
            <br/><span className="error">{this.state.slotError}</span><br/>

            <label>Type   :</label>
            <input type="text" onChange={ (e) => this.state.setState({type: e.target.value}) } value={ this.state.type } placeholder="Year"/>
            <br/><span className="error">{this.state.yearError}</span><br/>

            <label>L    :</label>
            <input type="text" onChange={ (e) => this.setState({L: e.target.value}) } value={ this.state.L } placeholder="L"/>
            <br/><span className="error">{this.state.semesterError}</span><br/>

            <label>T   :</label>
            <input type="text" onChange={ (e) => this.setState({T: e.target.value}) } value={ this.state.T } placeholder="T"/>
            <br/><span className="error">{this.state.semesterError}</span><br/>

            <label>P    :</label>
            <input type="text" onChange={ (e) => this.setState({P: e.target.value}) } value={ this.state.P } placeholder="P"/>
            <br/><span className="error">{this.state.semesterError}</span><br/>

            <label>Strength    :</label>
            <input type="text" onChange={ (e) => this.setState({strength: e.target.value}) } value={ this.state.strength } placeholder="strength"/>
            <br/><span className="error">{this.state.semesterError}</span><br/>

            <Button onClick={this.insert}> Add Course </Button> 
            <br/>
            <span>{this.state.error}</span>
        </div>
        )
    }
}