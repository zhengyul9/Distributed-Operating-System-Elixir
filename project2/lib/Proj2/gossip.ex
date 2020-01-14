defmodule Proj2.Gossip do
  alias Proj2.{Neighbours,Topo} 
  use GenServer

  def start_link( the_num, tot_num, msg_count, topo, data, start_time ) do
    GenServer.start_link(
      __MODULE__,
      { the_num, tot_num, msg_count, start_time, topo, data, :alive },
      name: :"#{the_num}"
    )
    IO.puts( "info reached")
  end

  def init(state) do
    {:ok, state}
  end

  def spread_rumor( the_num ) do 
     GenServer.cast(  GenServer.whereis(:"#{the_num}"), {:forward} )  
     IO.puts( the_num )
  end

  def handle_cast({:forward}, state) do 
     { the_num, tot_num, msg_count, start_time, topo, data, status } = state
     cond do 
       msg_count < 10  ->
              next_node = case topo do 
                "random2d" ->  
                         Neighbours.get_2d_neighbour( the_num, tot_num, data ) 
                 _ ->
                         Neighbours.get_neighbour( the_num, tot_num, topo )
              end
              new_state = { the_num, tot_num, msg_count + 1, start_time, topo, data, :alive }
              if( next_node == -1 ) do
                 the_time = System.monotonic_time( :millisecond )
                 tot_time = the_time - start_time
                 IO.puts( "#{tot_time} ms" ) 
                 { :noreply, new_state }
              else
                  spread_rumor( next_node )
                  { :noreply, new_state }
              end
                  { :noreply, new_state } 
     
       status == :alive ->
              Neighbours.rem_actor( the_num )
              next_node = Neighbours.get_random_neighbour( tot_num, 0 , the_num  )
              new_state = { the_num, tot_num, 10, start_time, topo, data, :ended }

              if( next_node == -1 ) do
                 the_time = System.monotonic_time( :millisecond )
                 tot_time = the_time - start_time
                 IO.puts( "#{tot_time} ms" )
                 { :noreply, new_state }
              else
                  spread_rumor( next_node ) 
                  { :noreply, new_state } 
              end 
       true -> 
              { :noreply, state }
     end
  end 
end
