import React from 'react';

export default class UserDetails extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        error: null,
        isLoaded: false,
        user_details: []
      };
    }
    componentDidMount() {
      const { alias } = this.props.match.params
      fetch('http://localhost:5000/user_details/?='+alias, {
        method: 'GET',
        dataType: 'json'
      })
        .then(res => res.json())
        .then((rjson) => {
            console.log(rjson)
            this.setState({
              isLoaded: true,
              user_details: rjson.results
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
      const { error, isLoaded, user_details } = this.state;
      if (error) {
        return <div>Error: {error.message}</div>;
      } else if (!isLoaded) {
        return <div>Loading...</div>;
      } else {
        return (
            <div>
                 <ul>
                    {user_details.map(course => (
                    <li key={course.name}>
                            {course.name} {course.code}
                    </li>
                    ))}
                </ul>
            </div>
        
        );
      }
    }
  }
  
//   <!DOCTYPE html>
// <html lang="en">
// <head>


// <title>CSS Template</title>
// <meta charset="utf-8">
// <meta name="viewport" content="width=device-width, initial-scale=1">
// <style>
// * {
//   box-sizing: border-box;
// }

// body {
//   font-family: Arial, Helvetica, sans-serif;
// }

// /* Style the header */
// header {
//   background-color: #666;
//   padding: 30px;
//   text-align: center;
//   font-size: 35px;
//   color: white;
// }



// nav {
 
//   float: left;
//   width: 40%;
//   height: 350px; 
//   background: #ccc;
//   padding: 20px;
  
// }




// article {
//   float: left;
//   padding: 20px;
//   width: 60%;
//   background-color: #f1f1f1;
//   height: 350px; /* only for demonstration, should be removed */
// }



// .dropbtn {
//   background-color: #4CAF50;
//   color: white;
//   padding: 16px;
//   font-size: 16px;
//   border: none;
//   cursor: pointer;
// }

// .dropdown {
//   position: relative;
//   display: inline-block;
// }

// .dropdown-content {
//   display: none;
//   position: absolute;
//   background-color: #f9f9f9;
//   min-width: 160px;
//   box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
//   z-index: 1;
// }

// .dropdown-content a {
//   color: black;
//   padding: 12px 16px;
//   text-decoration: none;
//   display: block;
// }

// .dropdown-content a:hover {background-color: #f1f1f1}

// .dropdown:hover .dropdown-content {
//   display: block;
// }

// .dropdown:hover .dropbtn {
//   background-color: #3e8e41;
// }





// /* Clear floats after the columns */
// section:after {
//   content: "";
//   display: table;
//   clear: both;
// }


// /* Style the footer */
// footer {
//   background-color: #777;
//   padding: 10px;
//   text-align: center;
//   color: white;
// }

// /* Responsive layout - makes the two columns/boxes stack on top of each other instead of next to each other, on small screens */
// @media (max-width: 600px) {
//   nav, article {
//     width: 100%;
//     height: auto;
//   }
// }
// </style>
// </head>
// <body>



// <header>
//   <h3>{this.props.name}</h3>
//   <h5>{this.props.alias}</h5>
// </header>

// <nav> 
// </nav>
// <section>
  

  
//   <article>
//    <div class="dropdown">
//   <button class="dropbtn">Options</button>
//   <div class="dropdown-content">
  
//   <a href="#">Past Courses</a>
//   <a href="#">Present Courses</a>
//   <a href="#">Events Hosted</a>
//  <a href="#">Groups</a>
//  <a href="#">Student Webpage</a>
//   </tr>
//   </div>
// </div>


   
//   </article>
// </section>



// <footer>
//   <p>Footer</p>
// </footer>

// </body>
// </html>

  
