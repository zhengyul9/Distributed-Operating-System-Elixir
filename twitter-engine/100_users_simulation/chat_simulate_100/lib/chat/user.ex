defmodule User do
  use GenServer
  alias Api
  alias Boss
  alias Modules
 

  def login( usr_name, password ) do
    bool = Boss.authentication( usr_name, password ) 
    if bool do
      start_link( usr_name )  
    end
  end 

  def start_link( usr_name ) do 
    GenServer.start_link( 
    __MODULE__,
    { {}, {}, %{ :stranger => {}, :tot => {}, :mention => {}, :sended => {} } },
    name: :"usr#{usr_name}" )
  end

  def init( data ) do 
    { :ok, data } 
  end

  def random_subscribe( my_name, the_num ) do
    subscribed = get_subscribed( my_name )  
    usrs = ( Boss.get_users() -- [ my_name ] ) -- Tuple.to_list( subscribed )
    to_subscribe = Enum.take_random( usrs, the_num ) 
    Enum.each( to_subscribe, 
           fn x ->
           subscribe( my_name, x )
         end )  
  end 
	
  def random_behaviour_control(my_name, times) do
     Enum.map( 1..times, fn _ -> 
	x = Enum.random( 10..50 )
	:timer.sleep(x)
	random_behaviour( my_name )
     end ) 
  end
  
  def random_behaviour( my_name ) do
   msgs = [ "weather is good", "you look awesome", "hello world", "nice toy", "how are you" ]
   tags = [ "COP5615isgreat", "ufisgood", "floridaisgood", "studentsaregood", "professorisgood", "TAsaregreat" ]
   x = Enum.random( 1..20 )
   cond do 
     x == 1 ->
       Api.send_info( "subscribe" )
       random_subscribe( my_name, 1 )
     x < 15 ->
      # IO.puts 
       Api.send_info( "twitter msg:")
       cot = Enum.random( msgs )
       tag = " #" <> Enum.random( tags )
       msg = cot <> tag  
       Api.send_info( msg ) 
       twitter( my_name, msg ) 
     x < 17 ->
       Api.send_info( "twitter @ " )
       cot = Enum.random( msgs )
       tag = " #" <> Enum.random( tags )
       aite = " @" <> Enum.random( Boss.get_users() -- [ my_name ] )
       msg = cot <> aite <> tag  
       Api.send_info( msg ) 
       twitter( my_name, msg )
     true ->
       Api.send_info( "forward : " )
       random_forward( my_name ) 
   end 
   :ok    
 end 


  def twitter( my_name, msg ) do
    save_to_send_box( my_name, msg ) 
    follower = get_follower( my_name )
    follower_num = tuple_size( follower )
    { mentioned, tags } = Modules.string_processing( msg ) 
    if follower_num != 0 do
       Enum.each( Tuple.to_list( follower ), 
            fn the_one -> 
            send_msg( my_name, the_one, msg ) 
            end ) 
    else
       []
    end

    if tags != [] do 
      Enum.each( tags, fn tag ->
          Boss.update_tag( tag, msg, my_name )        
        end )
    else
      []
    end 


    if mentioned != [] do 
        Enum.each( mentioned,
            fn the_one ->
            send_mention_msg( my_name, the_one, msg )
            end )
    else
      []
    end
  end
   
  def search_tag( tag ) do 
    Boss.get_tag_msg( tag ) 
  end 


  def random_forward( my_name  ) do 
    follower = get_follower( my_name ) 
    follower_num = tuple_size( follower )
    inbox_tot = get_inbox( my_name )
    msg_num = tuple_size( inbox_tot ) 
    if follower_num != 0 && msg_num != 0  do
      the_one = Enum.random( Tuple.to_list( follower ) )
      the_msg = Enum.random( Tuple.to_list( inbox_tot ) )
      send_msg( my_name, the_one, the_msg )  
      Api.send_info( the_msg )
    else
      Api.send_info( "no msg" )
       []
    end 
  end 
  
  def send_mention_msg( my_name, usr_name, msg ) do
    GenServer.cast( :"usr#{usr_name}", {:save_to_inbox, :mention, { msg, my_name}, false } )
  end
 
 
  def send_msg( my_name, usr_name, msg ) do 
    bool = check_follower( my_name, usr_name ) 
    if bool do 
       GenServer.cast( :"usr#{usr_name}", {:save_to_inbox, my_name, msg, true } )   
    else 
       GenServer.cast( :"usr#{usr_name}", {:save_to_inbox, :stranger, { msg, my_name }, true } )  
    end
  end 
 
  def check_follower( my_name, usr_name ) do 
    GenServer.call( :"usr#{my_name}", {:check_follower, usr_name} ) 
  end

  def check_subscription( my_name, usr_name ) do
    GenServer.call( :"usr#{my_name}", {:check_subscription, usr_name} )
  end 
  
  def get_follower( my_name ) do 
    GenServer.call( :"usr#{my_name}", {:get_follower} )
  end 
 
  def get_subscribed( my_name ) do 
    GenServer.call( :"usr#{my_name}", {:get_subscribed} ) 
  end 

  def subscribe( my_name, usr_name ) do 
    GenServer.call( :"usr#{my_name}", {:subscribe, usr_name } )
    GenServer.cast( :"usr#{usr_name}", {:fol, my_name } ) 
  end

  def search_inbox( my_name, usr_name ) do 
    GenServer.call( :"usr#{my_name}", {:search_inbox, usr_name } )
  end

  def save_to_send_box( my_name, msg ) do 
    GenServer.cast( :"usr#{my_name}", {:save_to_send_box, msg} )   
  end

  def get_send_box( my_name, usr_name ) do
    if check_subscription( my_name, usr_name ) do  
       GenServer.call( :"usr#{usr_name}", {:get_send_box} )
    else
       "not subsribed" 
    end 
  end  
  
  def get_inbox( my_name ) do 
    GenServer.call( :"usr#{my_name}", {:search_inbox, :tot } )
  end  
  
  def handle_call( {:get_follower, usr_name}, _from, data ) do
    { _subscribed, follower, _inbox } = data
    { :reply, follower, data }
  end

  def handle_call( {:check_follower, usr_name}, _from, data ) do
    { _subscribed, follower, _inbox } = data
    bool = Enum.member?( Tuple.to_list( follower ), usr_name ) 
    { :reply, bool, data }
  end

  def handle_call( {:check_subscription, usr_name}, _from, data ) do
    { subscribed, _follower, _inbox } = data
    bool = Enum.member?( Tuple.to_list( subscribed ), usr_name )
    { :reply, bool, data }
  end

  def handle_call( {:subscribe, usr_name}, _from, data ) do 
    { subscribed, follower, inbox } = data 
    subscribed = Tuple.append( subscribed, usr_name ) 
    inbox = Map.put( inbox, usr_name, {} ) 
    { :reply, :ok, { subscribed, follower, inbox } }
  end 

  def handle_call( {:search_inbox, usr_name}, _from, data ) do
    { _subscribed, _follower, inbox } = data
    msg = Map.get( inbox, usr_name )
    { :reply, msg, data }
  end

  def handle_call( {:get_subscribed}, _from, data ) do
    {  subscribed, _follower, _inbox } = data
    { :reply, subscribed, data }
  end

  def handle_call( {:get_follower}, _from, data ) do
    {  _subscribed, follower, _inbox } = data 
    { :reply, follower, data }
  end
  
  def handle_call( {:get_send_box}, _from, data ) do 
    {  _subscribed, _follower, inbox } = data
    msg = Map.get( inbox, :sended ) 
    { :reply, msg, data }
  end 

  def handle_cast( {:fol, usr_name}, data ) do
    { subscribed, follower, inbox } = data
    follower = Tuple.append( follower, usr_name )
    { :noreply, { subscribed, follower, inbox } }
  end

  def handle_cast( {:save_to_send_box, msg }, data ) do
     { subscribed, follower, inbox } = data
     inbox = Map.update!( inbox, :sended, &( Tuple.append( &1, msg ) )  )
     { :noreply, { subscribed, follower, inbox } }
  end 

  def handle_cast( {:save_to_inbox, usr_name, msg, not_mention }, data ) do
    { subscribed, follower, inbox } = data
    Api.send_info( "msg recieved" ) 
    inbox = Map.update!( inbox, usr_name, &( Tuple.append( &1, msg ) )  )
    
    inbox = if not_mention do
      Map.update!( inbox, :tot, &( Tuple.append( &1, msg ) )  ) 
    else 
      inbox
    end
    { :noreply, { subscribed, follower, inbox } }  
 
  end 


 
end
