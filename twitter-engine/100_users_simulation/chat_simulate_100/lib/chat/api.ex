defmodule Api do
  use ChatWeb, :channel  

  def send_info( msg ) do 
    [{ _, socket}] = :ets.lookup( :socket, "socket" )
    push( socket, "display", %{ msg_txt: msg } )
  end 

end 
