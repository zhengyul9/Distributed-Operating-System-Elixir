defmodule Proj2.Pushsum do  
 @name __MODULE__ 
 alias Proj2.Neighbours

 use GenServer
 
 def init( state ) do 
    {:ok, state }
 end 	
 
 def start_link( the_num, tot_num, {s_val, w_val, count}, topo, data, start_time ) do
    GenServer.start_link( 
      __MODULE__,
      { the_num, tot_num, { s_val, w_val, count}, topo, data, start_time, :alive } ,
      name: :"#{the_num}"
    )
 end

 def pushsum( the_num, s_val, w_val ) do 
    GenServer.cast( GenServer.whereis(:"#{the_num}"), {:forward, the_num, s_val, w_val} )
    IO.puts( the_num ) 
 end 

 def handle_cast( {:forward, _from, s_val, w_val }, state )  do 
      { the_num, tot_num, { s_old, w_old, count }, topo, data, start_time, status } = state
      s_new = s_old + s_val 
      w_new = w_old + w_val 
      
      old_ratio = s_old/w_old
      new_ratio = s_new/w_new 
      
      diff_ratio = abs( new_ratio - old_ratio ) 
    
      cond do 
          count < 3 ->
              next_node = case topo do 
                   "random2d" ->
                          Neighbours.get_2d_neighbour( the_num, tot_num, data )       
                   _ -> 
                          Neighbours.get_neighbour( the_num, tot_num, topo ) 
              end  
              cond do 
                   diff_ratio <= :math.pow( 10, -10 ) -> 
                           pushsum( next_node, s_new / 2, w_new/ 2 )    
                           new_state = { the_num, tot_num, { s_new/2, w_new/2, count+1}, topo, data, start_time, :alive }  
                           {:noreply,new_state}
                   true -> 
                           pushsum( next_node, s_new / 2, w_new/ 2 )     
                           new_state = { the_num, tot_num, { s_new/2, w_new/2, count}, topo, data, start_time, :alive }
                           {:noreply,new_state} 
              end 
          true ->
              cond do 
                 status == :alive ->
                     the_time = System.monotonic_time( :millisecond )
                     tot_time = the_time - start_time
                     IO.puts( "#{tot_time} ms" ) 
                     Neighbours.rem_actor( the_num )
                     new_state = { the_num, tot_num, { s_old, w_old, 3 }, topo, data, start_time, :ended } 
                     {:noreply,new_state} 
                 true ->
                     {:noreply,state}
                 end 
      end 
  end
end
