defmodule Disk do 


  def init() do 
    :ets.new( :id_socket, [ :set, :public, :named_table ] )
    :ets.new( :id_password, [ :set, :public, :named_table ] )
    :ets.new( :follower, [ :set, :public, :named_table ] )
    :ets.new( :tag, [ :set, :public, :named_table ] )
    :ets.new( :inbox, [ :set, :public, :named_table ] )
    :ets.new( :send_box, [ :set, :public, :named_table ] )  
 end 

  def register( usr_name, password, socket ) do 
    :ets.insert( :id_socket,  { usr_name, socket }  )
    :ets.insert( :id_password, { usr_name, password } ) 
    :ets.insert( :follower, { usr_name, [] } ) 
    :ets.insert( :inbox, { usr_name, [] } )
    :ets.insert( :send_box, { usr_name, [] } )
  end

  def match_password( usr_name, new_password ) do 
    [{_,old_password}] = :ets.lookup( :id_password, usr_name ) 
    ( new_password == old_password ) 
  end 


  def id_to_socket( id ) do 
    [{_, socket}] = :ets.lookup( :id_socket, id )
    socket
  end 

  def set_tag( taglist ) do
    Enum.each( taglist, fn x -> 
        :ets.insert( :tag, { x, [] } ) 
        end ) 
  end 

  def update_tag( tag, msg ) do
    [{ _, msgs }] = :ets.lookup( :tag, tag ) 
    msgs = msgs ++ [ msg ]  
    :ets.insert( :tag, { tag, msgs } ) 
  end  
  
  def search_tag( tag ) do 
    [{ _, msgs }] = :ets.lookup( :tag, tag )
    msgs 
  end  

 
  def get_inbox( usr_name ) do 
    [{ _, inbox }] = :ets.lookup( :inbox, usr_name )
    inbox 
  end 

  def save_to_inbox( usr_name, msg ) do 
    [{ _,inbox }] = :ets.lookup( :inbox, usr_name ) 
    inbox = inbox ++ [ msg ] 
    :ets.insert( :inbox, { usr_name, inbox } )
  end 

  def subscribe( my_name, usr_name ) do 
    [ {_, follower} ] = :ets.lookup( :follower, usr_name )
    exist = Enum.member?( follower, my_name )
    follower = if( exist, do: follower, else: follower ++ [ my_name ] ) 
    :ets.insert( :follower, { usr_name,  follower } )
  end 

  def get_follower( my_name ) do 
   [ {_,follower} ] = :ets.lookup( :follower, my_name ) 
   Enum.map( follower, fn x ->
        [ {_, socket} ] = :ets.lookup( :id_socket, x )  
        socket end )
  end 
  
  def get_follower_list( my_name ) do 
   [ {_,follower} ] = :ets.lookup( :follower, my_name )
   follower 
  end



  def hello( x ) do
    IO.puts x 
  end

 
end 
