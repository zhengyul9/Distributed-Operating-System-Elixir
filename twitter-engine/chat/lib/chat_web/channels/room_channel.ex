defmodule ChatWeb.RoomChannel do
  use ChatWeb, :channel

  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end
 
  def handle_in("shout", payload, socket) do
    Chat.Message.changeset(%Chat.Message{}, payload) |> Chat.Repo.insert  
    broadcast socket, "shout", payload
    {:noreply, socket}
  end


  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  def handle_in("register", payload, socket ) do
     usr_name = payload["username"]
     password = payload["password"]
     val = GenServer.call( :boss, { :register, usr_name, password, socket } ) 
     cur_datetime = DateTime.to_string( DateTime.utc_now ) 
     msg_back = if( val == :success, 
                  do: "User  " <> usr_name <> " registerd successfully " 
                  <> "    "  <> cur_datetime , 
                  else: "Server not online" ) 
     push( socket, "display", %{ msg_txt: msg_back } )
     {:noreply, socket}
  end 

  def handle_in("login", payload, socket ) do 
    usr_name = payload["username"]
    password = payload["password"]
    cur_datetime = DateTime.to_string( DateTime.utc_now )
    val = GenServer.call( :boss, { :login, usr_name, password } )
    msg = if( val,  do: " Successfully logged in "
              <> "    "  <> cur_datetime ,
              else: " Wrong password, please try again" )
    msg_back = if( val,  do: "ok", else: "wrong" ) 
    push( socket, "display", %{ msg_txt: msg } )
    push( socket, "unlock", %{ msg_txt: msg_back} ) 
    {:noreply, socket} 
  end 


  def handle_in("subscribe", payload, socket ) do 
     subscribe_name = payload["subscribe_name"] 
     my_name = payload["username"]
     #IO.puts( subscribe_name )
     GenServer.call( :boss, {:subscribe, my_name, subscribe_name})
     push( socket, "display", %{ msg_txt: "Successfully suscribe to  " 
         <> subscribe_name } )  
     {:noreply, socket }
  end
  
  def handle_in("send_twitter", payload, socket ) do 
     msg = payload["msg"]
     my_name = payload["username"]  
     GenServer.call( :boss, { :send_msg, my_name, msg } )     
     push( socket, "display", %{ msg_txt: "Sended : " <> msg } )
     {:noreply, socket }
  end 

  def handle_in("search_tag", payload, socket ) do 
     tag = payload["tag"]
     GenServer.call( :boss, {:search_tag, socket, tag} )
     {:noreply, socket }
  end  

  def handle_in( "retweet", payload, socket ) do 
     [retweet_num] = String.split( payload["retweet_num"] )
     push( socket, "display", %{ msg_txt: "You just retweeted message" } ) 
     my_name = payload["username"]
     retweet_num = String.to_integer( retweet_num )
     GenServer.call( :boss, {:retweet, my_name, retweet_num } ) 
     {:noreply, socket }
  end 

  def handle_in("error", _payload, socket ) do 
     push( socket, "display", %{ msg_txt: "Please log in first"} )
     {:noreply, socket }
  end 
 
  
  def handle_info(:after_join, socket) do
     push( socket, "display", %{ msg_txt: "Welcome to twitter! "} )
  #  Chat.Message.get_messages()
  #  |> Enum.each(fn msg -> push(socket, "shout", %{
  #       name: msg.name,
   #     message: msg.message,
#      }) end)
     {:noreply, socket} # :noreply
  end





end
