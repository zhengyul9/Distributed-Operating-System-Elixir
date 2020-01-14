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

var channel = socket.channel('room:lobby', {}); // connect to chat "room"

channel.on('shout', function (payload) { // listen to the 'shout' event
  var li = document.createElement("li"); // create new list item DOM element
  var name = payload.name || 'guest';    // get name from payload or set default
  li.innerHTML = '<b>' + name +  '    ' + '</b>: ' + payload.message  ;
  ul.appendChild(li);                    // append to list
});


channel.on( 'display', function(payload) {
  var li = document.createElement("li");
 // li.innerHTML = "get it" ;
  //ul.appendChild(li) ;
 // var item = document.createTextNode( "Four" );
 // li.appendChild(item);
  li.innerHTML = '<b>' + payload.msg_txt + '\n' + '</b>' ;
  console.log(ul);
  ul.appendChild(li) ;
//  ul.appendChild(document.createElement("br"));
//  ul.appendChild(li) ;
  var len = ul.getElementsByTagName("li").length
  if( len > 7 ) 
  { 
    console.log("max number"); 
    ul.removeChild( ul.childNodes[0] ) ;
  }  
  console.log( ul.getElementsByTagName("li").length  ) ;
  console.log( "get it" ) ;  
}); 

channel.on( 'unlock', function(payload) {
  if( payload.msg_txt == "ok" ) {
    unlocked = true ;   }
}); 
 





channel.join(); // join the channel.


var ul = document.getElementById('msg-list');        // list of messages.
var username = document.getElementById('username');
var subscribe_name = document.getElementById('subscribe_name');          // name of message sender
var msg = document.getElementById('msg');            // message input field
var unlocked = false ; 


// "listen" for the [Enter] keypress event to send a message:
msg.addEventListener('keypress', function (event) {
  if (event.keyCode == 13 && msg.value.length > 0) { // don't sent empty msg.
    channel.push('shout', { // send the message to the server
      subscribe_name: subscribe_name.value,     // get value of "name" of person sending the message
      message: msg.value, // get message text (value) from msg input field.
    });
    msg.value = '';         // reset the message input field for next message.
  }
});


register.addEventListener('click', function(event) {
    channel.push( 'register', {  
    username: username.value,
    password: password_registration.value  
    } ) ;
    password_registration.value = '********'; 
    msg.value = '';
 } 
);

login.addEventListener('click', function(event) {
    channel.push( 'login', {
    username: username.value,
    password: password_login.value
    } ) ;
    password_login.value = ''; 
    msg.value = '';
 }
);





subscribe.addEventListener('click', function(event) {
    if( unlocked )
    {
       channel.push( 'subscribe', {
       username: username.value, 
       subscribe_name: subscribe_name.value });
    }
    else
    {
       channel.push( 'error', {} ) ;
    }
    subscribe_name.value = ''; 
}) ; 

twitter.addEventListener('click', function(event) {
    if( unlocked ) {
      channel.push( 'send_twitter', {
      msg: msg.value, 
      username: username.value
      }); 
    }
    else 
    {
     channel.push( 'error', {} ) ; 
    }
      msg.value = ''; 
}) ;

search_tag.addEventListener( 'click', function( event) {
    if( unlocked ) {
      channel.push( 'search_tag', {
      tag: tag_to_search.value } ) ;
    }
    else
    {
     channel.push( 'error', {} ) ;
    }
    tag_to_search.value = '' ; 
} ); 

retweet.addEventListener( 'click', function( event) {
    if( unlocked ) {
	channel.push( 'retweet', {
        retweet_num: retweet_num.value,
        username: username.value 
        } ) ;
    }
    else
    {
     channel.push( 'error', {} ) ;
    }
    retweet_num.value = '' ;
} );





// .receive('ok', resp => ; {
  //   console.log('Joined successfully', resp);
  // })
  // .receive('error', resp => {
  //   console.error('Unable to join', resp);
  // });
