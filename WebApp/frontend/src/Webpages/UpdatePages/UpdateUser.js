import React from 'react';
import {Button,Tabs,Tab} from 'react-bootstrap'
import Query from '../QueryComponent/Query';
import DeleteQuery from '../QueryComponent/DeleteQuery'

export default class UpdateCourse extends React.Component {
    constructor(props) {
        super(props);
        const { alias } = this.props.match.params
        this.state = {
            alias: alias,
            name : "",
            NameDisabled: true,
            UWDisabled: true,
            isLoaded: false,
            groupno: 1,
            update_error: "",
            user_type: 0,
            cur_courses: [5 ,7],
            drop_error: "",
            dropcode: "",
        };
    }

    componentDidMount() {
        const { alias } = this.props.match.params
        console.log(alias)
        fetch('http://localhost:5000/user_details/?alias='+alias, {
          method: 'GET',
          dataType: 'json'
        })
          .then(res => res.json())
          .then((rjson) => {
              console.log(rjson)
              this.setState({
                isLoaded: true,
                user_details: rjson,
                user_type: rjson.type1,
                cur_courses: rjson.cur_course_registered,
              });
            },
            (error) => {
              this.setState({
                isLoaded: true,
                error
              });
            }
          )
      }
    
    update = (e) => {
        let cq = "?alias="+this.state.alias+'&name='+this.state.name+'&groupno='+this.state.groupno
        fetch('http://localhost:5000/update_user/'+cq, {
            method: 'GET',
            dataType: 'json'
          })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                let x = jsres
                this.setState({
                    update_error : "Successfully Updated",
                })
              },
              (error) => {
                this.setState({
                  error:"Not Added, Check Fields"
                });
              }
            )
    }

    dropcourse = (e) => {
        let {alias, groupno} = this.state
        this.setState({
            drop_error: "Registering Student"
        })
        let cq = "?alias="+alias+"&code="+this.dropcode
        fetch('http://localhost:5000/dropcourse/'+cq, {
            method: 'GET',
            dataType: 'json'
          })
            .then(res => res.json())
            .then((jsres) => {
                console.log(jsres)
                let x = jsres
                this.setState({
                    drop_error:"Course Dropped"
                })
              },
              (error) => {
                this.setState({
                  drop_error:"Dropping course failed"
                });
              }
            )
        setTimeout(() => this.setState({error:""}), 2000);
    }

    render() {
        return (
        <div className="update_div">
            <h3>Update User: &nbsp; {this.state.alias.toUpperCase()} </h3>
            <br/>
            <Tabs defaultActiveKey="profile" id="uncontrolled-tab-example">
                <Tab eventKey="UpdateUser" title="Update User Details">
                    <div className="update_div">
                        <label>User Name :</label><br/>
                        <input type="checkbox" onChange={ (e) => this.setState({NameDisabled: !this.state.NameDisabled,name:""} ) } name="CheckName"/> 
                        <input type="text" className="update-input" disabled={this.state.NameDisabled} onChange={ (e) => this.setState({name: e.target.value}) } value={ this.state.name } placeholder="E.g. Introduction to DBMS"/>
                        <br/>
                        { this.state.user_type==1 &&
                        <div>
                        <label>User Webpage :</label><br/>
                        <input type="checkbox" onChange={ (e) => this.setState({UWDisabled: !this.state.UWDisabled,groupno:""} ) } name="CheckName"/> 
                        <input type="text" className="update-input" disabled={this.state.UWDisabled} onChange={ (e) => this.setState({groupno: e.target.value}) } value={ this.state.groupno } placeholder="User Webpage"/>
                        </div>
                        }
                        <br/><Button onClick={this.update}> Update User </Button> 
                        <span>{this.state.update_error}</span>
                    </div>
                </Tab>
                { this.state.user_type=='cur_stu' && 
                <Tab eventKey="Drop" title="Drop Courses">
                    <div  className="update_div">
                        <DeleteQuery results={this.state.cur_courses} deleteurl="/drop_course/" text="Drop Course" />
                        <h1></h1><br/><h1></h1>
                        {/* <h6>Drop Course: </h6>
                        <input type="text" className="update-input" onChange={ (e) => this.setState({dropcode: e.target.value}) } value={ this.state.dropcode } placeholder="E.g. COL100"/>
                        <br/>
                        <span>{this.state.drop_error}</span>
                        <br/><Button onClick={this.dropcourse}> Drop Course </Button> 
                        <br/> */}
                    </div>
                </Tab>
                }
            </Tabs>
        </div>
        )
    }
}