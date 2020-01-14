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


  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    Chat.Message.changeset(%Chat.Message{}, payload) |> Chat.Repo.insert  
    broadcast socket, "shout", payload
    {:noreply, socket}
  end


  def handle_in( "start_simulation", payload, socket ) do
    [ usr_num ] = String.split( payload["usr_num"] )
    usr_num = String.to_integer( usr_num ) 
    [ tot_times ] = String.split( payload["tot_times"] )
    tot_times = String.to_integer( tot_times ) 
    GenServer.cast( :manager, {:start_simulation, usr_num, tot_times } ) 
    {:noreply, socket}
  end 


  def handle_in("show", payload, socket ) do 
    msg_to_show = payload["name"] <> "  : " <> payload["message"] 
    push( socket, "display", %{ msg_txt: msg_to_show } )
    {:noreply, socket}
  end 



  def handle_info(:after_join, socket) do
#    Chat.Message.get_messages()
#    |> Enum.each(fn msg -> push(socket, "shout", %{
#        name: msg.name,
 #       message: msg.message,
  #    }) end)
    GenServer.call( :manager, { :socket_init, socket } )
    push( socket, "display", %{ msg_txt: "Welcome to twitter!" } ) 
    {:noreply, socket} # :noreply
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
