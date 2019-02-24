import React from 'react';

export default class CourseDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: false,
        course_details: []
      };
    }
    componentDidMount() {
      const { code } = this.props.match.params
      console.log(code)
      fetch('http://localhost:5000/course_details/?code='+code, {
        method: 'GET',
        dataType: 'json'
      })
        .then(res => res.json())
        .then((rjson) => {
            console.log(rjson)
            this.setState({
              isLoaded: true,
              course_details: rjson.results
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
  
    render() {
      const { error, isLoaded, course_details } = this.state;
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
        return (
          <ul>
            {course_details.map(course => (
              <li key={course.name}>
                    {course.name} {course.code}
              </li>
            ))}
          </ul>
        );
      }
    }
  }

  
  <!DOCTYPE html>
<html lang="en">
<head>


<title>CSS Template</title>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
* {
  box-sizing: border-box;
}



body {
  font-family: Arial, Helvetica, sans-serif;
}

/* Style the header */
header {
  background-color: #666;
  padding: 30px;
  text-align: center;
  font-size: 35px;
  color: white;
}



nav {
 
  float: left;
  width: 30%;
  height: 350px; 
  background: #ccc;
  padding: 20px;
  
}




article {
  float: left;
  padding: 20px;
  width: 70%;
  background-color: #f1f1f1;
  height: 350px; /* only for demonstration, should be removed */
}

.second {
  float: right;
  float: above;
  padding: 20px;
  
  width: 45%;
  background-color: #f1f1f1;
  height: 350px; /* only for demonstration, should be removed */
}




/* Clear floats after the columns */
section:after {
  content: "";
  display: table;
  clear: both;
}


/* Style the footer */
footer {
  background-color: #777;
  padding: 10px;
  text-align: center;
  color: white;
}

/* Responsive layout - makes the two columns/boxes stack on top of each other instead of next to each other, on small screens */
@media (max-width: 600px) {
  nav, article {
    width: 100%;
    height: auto;
  }
}
</style>
</head>
<body>



<header>
  <h1>{this.props.code}</h1>
  <h5>{this.props.name}</h5>
</header>
<section>
  
<nav>
</nav>
  
  <article>
   <h4>Instructor : {this.props.instructor}</h4>
   <h4>Credits : {this.props.credit}</h4>
   <h4>Strength : {this.props.strngth}</h4>
   <h4>Lecture Hours :{this.props.l}</h4>
   <h4>Tutorial Hours : {this.props.t}</h4>
   <h4>Practical Hours :{this.props.p}</h4>
   <a href="/bslot">SLOT {this.props.slot}</a>
   
   
  <div>
<a href="/web">Course Webpage</a>
</div
<div>
<a href="/col216students">Registered Students</a>
</div
  
   
  </article>
</section>



<footer>
  <p>Footer</p>
</footer>

</body>
</html>

  
