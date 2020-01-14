defmodule Boss do
  use GenServer
  alias Api
  alias User

  def start() do 
     GenServer.start_link( 
     __MODULE__,
     {  0, %{}, %{} },
     name: :boss )
  end 

  def init( data ) do 
    { :ok, data }
  end
  
  def add_user( usr_name, password ) do
    GenServer.cast( :boss, {:add_usr, usr_name, password} )  
  end  
  
  def delete_user( usr_name ) do 
    GenServer.cast( :boss, {:del_usr, usr_name} )  
  end 
  
  def get_users() do 
     GenServer.call( :boss, :get_usrs )
  end 


  def authentication( usr_name, password ) do
    GenServer.call( :boss, {:login, usr_name, password} )
  end

  def add_tag( tag ) do 
    GenServer.call( :boss, { :add_tag, tag } )
  end

  def update_tag( tag, msg, sender ) do 
    GenServer.call( :boss, { :update_tag, tag, msg, sender } ) 
  end 

  def get_tag_msg( tag ) do 
    GenServer.call( :boss, { :get_tag_msg, tag } )
  end  
 
  def print_tag() do 
    IO.inspect GenServer.call( :boss, :print_tag ) 
  end 


  def handle_cast( { :add_usr, usr_name, password }, data ) do
    { tot_num, usr_info, tag_info } = data 
    usr_info = Map.put( usr_info, usr_name, password )
    { :noreply, { tot_num + 1, usr_info, tag_info }  }   
  end
 
  def handle_cast( { :del_usr, usr_name}, data ) do 
    { tot_num, usr_info, tag_info } = data
    usr_info = Map.delete( usr_info, usr_name ) 
    { :noreply, { tot_num - 1, usr_info, tag_info }  }
  end  

  def handle_call( :get_usrs, _from, data ) do 
    { _tot_num, usrinfo, _tag_info } = data
    usrs = Map.keys( usrinfo ) 
    { :reply, usrs, data }
  end  

  def handle_call( :print_tag, _from, data )  do
    { _tot_num, _usr_info, tag_info } = data
    { :reply, Map.keys( tag_info ) , data }
  end

 
  def handle_call( :num_usr, _from, data )  do 
    { tot_num, _usr_info, _tag_info } = data
    { :reply, tot_num, data }
  end 

  def handle_call( {:add_tag, tag }, _from, data ) do   
    { tot_num, usr_info, tag_info } = data
    tag_info = Map.put( tag_info, tag, {} ) 
    { :reply, :ok, { tot_num, usr_info, tag_info } }
  end

  def handle_call( {:update_tag, tag, msg, sender }, _from, data ) do 
    { tot_num, usr_info, tag_info } = data 
    tag_info = if Map.get( tag_info, tag ) == nil do 
       Api.send_info( "no such tag" )
       tag_info
    else  
       Map.update!( tag_info, tag, &( Tuple.append( &1, { msg, sender } ) ) )
    end
    { :reply, :ok, { tot_num, usr_info, tag_info } }
  end 

  def handle_call( {:get_tag_msg, tag }, _from, data ) do
    { tot_num, usr_info, tag_info } = data
    msg = Map.get( tag_info, tag ) 
    { :reply, msg, data } 
  end 
  
  def handle_call( {:login, usr_name, password}, _from, data ) do 
    { tot_num, usr_info, tag_info } = data
    key = Map.get( usr_info, usr_name ) 
    { :reply, key == password, data }
  end 

end 
