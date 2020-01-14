defmodule Manager do 
  use GenServer 
  alias Boss 
  alias Modules
  alias User 

  
  def start() do
     GenServer.start_link(
     __MODULE__,
     {},
     name: :manager )
  end

  def init( data ) do
    { :ok, data }
  end

  def handle_call( {:socket_init, socket }, _from, data ) do 
    :ets.new( :socket, [ :set, :public, :named_table  ] ) 
    :ets.insert( :socket, { "socket", socket } ) 
    { :reply, :good, data } 
  end

  def handle_cast( {:start_simulation, usr_num, tot_time }, data ) do 
    Boss.start()
    usrs = Enum.map( 1..usr_num, fn x -> "usr_" <> Integer.to_string(x) end )
    password = "123456" 
    tags = [ "COP5615isgreat", "ufisgood", "floridaisgood", "studentsaregood", "professorisgood", "TAsaregreat" ]
    Enum.each( tags, fn tag ->
      Boss.add_tag( tag ) end ) 

    Enum.each( usrs, fn x ->
       Boss.add_user( x, password )
       end ) 
    Enum.each( usrs, fn x ->
       User.login(  x, password ) 
       end )  

    Enum.each( usrs, fn x ->
            User.random_behaviour_control( x, tot_time ) end ) 
    IO.puts "test"   
    { :noreply, data } 
  end

end   
