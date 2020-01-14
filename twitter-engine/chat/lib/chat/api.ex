defmodule Api do
  use ChatWeb, :channel  
  def send_msg( socket, my_name,  msg ) do
    msg =  my_name <> " just tweeted : " <> msg 
    push( socket, "display", %{ msg_txt: msg } )
  end

  def send_at_msg( socket, my_name,  msg ) do
    msg =  "User " <> my_name  <> " just @ you : " <> msg
    push( socket, "display", %{ msg_txt: msg } )
  end

  def send_info( socket, msg ) do 
    push( socket, "display", %{ msg_txt: msg } )
  end 
  
  
  def search_msg( socket, tag, msgs ) do
    push( socket, "display", %{ msg_txt: "tweeted msg with tag <" <> tag <> ">" <> ":" } )
    Enum.each( msgs, fn x -> 
       push( socket, "display", %{ msg_txt: x } ) 
       end )
  end 


 
end 
