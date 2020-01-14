// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from "./socket"


let channel = socket.channel('room:lobby', {}); // connect to chat "room"

channel.on('shout', function (payload) { // listen to the 'shout' event
  let li = document.createElement("li"); // create new list item DOM element
  let name = payload.name || 'guest';    // get name from payload or set default
  li.innerHTML = '<b>' + name + '</b>: ' + payload.message; // set li contents
  ul.appendChild(li);                    // append to list
});


channel.on( 'display', function(payload) {
  var li = document.createElement("li");
  li.innerHTML = '<b>' + payload.msg_txt + '\n' + '</b>' ;
  console.log(ul);
  ul.appendChild(li) ;
  var len = ul.getElementsByTagName("li").length
  if( len > 10 )
  {
    console.log("max number");
    ul.removeChild( ul.childNodes[0] ) ;
  }
  console.log( ul.getElementsByTagName("li").length  ) ;
  console.log( "get it" ) ;
});





channel.join(); // join the channel.


let ul = document.getElementById('msg-list');        // list of messages.
let name = document.getElementById('name');          // name of message sender
let msg = document.getElementById('msg');            // message input field

// "listen" for the [Enter] keypress event to send a message:
start.addEventListener('click', function (event) {
    channel.push('start_simulation', { // send the message to the server on "shout" channel
      usr_num: usr_num.value,     // get value of "name" of person sending the message
      tot_times: tot_times.value    // get message text (value) from msg input field.
    });
    usr_num.value = '';
    tot_times.value = '';
});
