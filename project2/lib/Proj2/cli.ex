defmodule Proj2.Cli do 
  alias Proj2.{Gossip,Neighbours,RandomGen,Pushsum} 
 
  use GenServer  

  def init(init_arg) do
      {:ok, init_arg}
    end 

  def main( argv ) do 
     argv |> parse_args |> run 
     Process.sleep( :infinity ) 
  end 
  def parse_args(args) do
     case args do 
       [tot_num, topo, algo] -> 
         { String.to_integer(tot_num), topo, algo }
     end 
  end 
  
  def run( { tot_num, topo, algo} ) do
     tot_data = case topo do 
        "random2d" ->
            IO.puts( " generating random 2d map, could be slow when n > 1000 " )  
            RandomGen.generate( tot_num ) 
         _ -> 
            for i <- 1..tot_num do
               []
            end  
     end 
     case algo do 
        "gossip" ->
            start_time = System.monotonic_time( :millisecond ) 
            Neighbours.start()  
            Enum.each( 1..tot_num, fn the_num -> 
                 Gossip.start_link( the_num, tot_num, 0, topo, Enum.at( tot_data, the_num - 1 ), start_time ) end ) 
                 Gossip.spread_rumor( Enum.random( 1..tot_num ) )
     #####       :timer.sleep( 10000 )
        "pushsum" -> 
            start_time = System.monotonic_time( :millisecond )
            Neighbours.start() 
            Enum.each( 1..tot_num, fn the_num -> 
                 Pushsum.start_link( the_num, tot_num, { 1.0 + 0.1 * the_num, 1.0, 0 }, topo, Enum.at( tot_data, the_num - 1 ), start_time ) end )
                 random_actor = Enum.random( 1..tot_num ) 
                 Pushsum.pushsum( random_actor, random_actor, 1 )   
     end  
  end 

end


# "pushsum" ->
          #  IO.puts( "good" )
         #   start_time = System.monotonic_time( :millisecond )
        #    Neighbours.start( topo, tot_num )
       #     Enum.each( 1..tot_num, fn the_num ->
      #           Pushsum.start_link( the_num, { the_num, 1.0, 0 }, start_time )  end )
     #       random_actor = Enum.random( 1..tot_num )
    #        Pushsum.pushsum( random_actor, random_actor, 1 )
        ###     :timer.sleep( 100000 ) 
