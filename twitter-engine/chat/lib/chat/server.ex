defmodule Boss do
  use GenServer
  alias Disk
  alias Modules 
  alias Api  
  

  def start_link() do
    GenServer.start_link(
      __MODULE__, 
      {},
      name: :boss )   
  end 
 
  def init( data ) do 
    { :ok, data } 
  end

  def handle_call( { :register, usr_name, password, socket } , _from, data ) do
    IO.puts password
    Disk.register( usr_name, password, socket )
    { :reply, :success, data } 
  end

  def handle_call( { :login, usr_name, password }, _from, data ) do 
    correct = Disk.match_password( usr_name, password ) 
    { :reply, correct, data } 
  end 
 

  def handle_call( { :subscribe, my_name, usr_name }, _from, data ) do 
    Disk.subscribe( my_name, usr_name )
    { :reply, :ok, data } 
  end
  
  def handle_call( { :send_msg, my_name, msg }, _from, data ) do
    sockets = Disk.get_follower( my_name )
    followers = Disk.get_follower_list( my_name ) 
    Enum.each( followers, fn x -> 
       Disk.save_to_inbox( x, msg ) 
       end ) 
    Enum.each( sockets, fn x ->
       Api.send_msg( x, my_name, msg ) 
       end ) 
    { mention_list, tag_list } = Modules.string_processing( msg ) 

    Enum.each( tag_list, fn x ->
       Disk.update_tag( x, msg ) 
       end ) 

    mention_sockets = Enum.map( mention_list, fn id -> Disk.id_to_socket( id ) end )  
    Enum.each(  mention_sockets, fn x ->
       Api.send_at_msg( x, my_name, msg )
       end )
    Enum.each( mention_list, fn x ->
       Disk.save_to_inbox( x, msg ) 
       end ) 
    { :reply, :ok, data } 
  end 


  def handle_call( { :search_tag, socket, tag }, _from, data ) do 
    msgs = Disk.search_tag( tag )  
    Api.search_msg( socket, tag, msgs )   
    { :reply, :ok, data }
  end
 
  def handle_call( {:retweet, my_name, retweet_num }, _from, data ) do
    IO.puts "first test"
    IO.puts my_name 
    inbox = Disk.get_inbox( my_name )
    IO.inspect inbox 
    msg = Enum.at( inbox, retweet_num - 1 )
    sockets = Disk.get_follower( my_name )
    Enum.each( sockets, fn x ->
       Api.send_msg( x, my_name, msg )
       end )
    { :reply, :ok, data }    
  end 



   
end 
