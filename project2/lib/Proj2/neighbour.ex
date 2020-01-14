defmodule Proj2.Neighbours do 
 @name __MODULE__ 
  
 alias Proj2.{Honeycomb,Torus_3D}
 # alias Proj2.{Full,Honeycomb,Random2D, Torus_3D}
 use GenServer
  
  def init(init_arg) do
      {:ok, init_arg}
  end
 
  def start() do
    Agent.start_link( fn -> MapSet.new() end, name: @name )
  end 
  
  def rem_actor( the_num ) do
    Agent.update( @name, fn the_set -> MapSet.put( the_set, the_num ) end ) 
  end 

  def actor_num() do
    Agent.get( @name, fn the_set -> MapSet.size( the_set )  end )  
  end
 
  def get_content() do
    Agent.get( @name, fn the_set -> the_set end )
  end
  
  def check_alive( the_num ) do
    Agent.get( @name, fn the_set -> not MapSet.member?( the_set, the_num ) end )
  end
  
  def get_neighbour( the_num, tot_num, topo ) do
    case topo do 
      "full" ->
            full_neighbour( the_num, tot_num )
      "honeycomb_extra" ->
            candidate = get_neighbour_topo( the_num, tot_num, "honeycomb" )
            random_actor = get_random_neighbour( tot_num, 0, the_num )
            Enum.random( candidate ++ [ random_actor ] )  
      _ -> 
            candidate = get_neighbour_topo( the_num, tot_num, topo )
            if( candidate == [] ) do 
               get_random_neighbour( tot_num, 0, the_num ) 
            else
               Enum.random( candidate ) 
            end
    end 
  end 

  def get_2d_neighbour( the_num, tot_num, list ) do
     alive_list = Enum.filter( list, fn x -> check_alive( x ) end )
     case alive_list do
        [] ->
          get_random_neighbour( tot_num, 0, the_num )
        _ ->
          Enum.random( alive_list ) 
     end       
  end
  
   
  def get_neighbour_topo( the_num, tot_num, topo ) do 
     case topo do
        "line" ->
            Enum.filter( line_neighbour( the_num, tot_num ), fn x -> check_alive(x) end ) 
        "honeycomb" ->
            Enum.filter( Honeycomb.generate( the_num, tot_num ), fn x -> check_alive( x ) end ) 
        "3dtorus" ->
            Enum.filter( Torus_3D.generate( the_num, tot_num ), fn x -> check_alive( x ) end )      
     end
  end 
 
  def get_random_neighbour( tot_num, i, ban ) do
     cond do 
       i < 5 -> 
           res = Enum.random( 1..tot_num ) 
           if( check_alive( res ) && res != ban ) do
             res
           else 
             get_random_neighbour( tot_num, i + 1, ban )
           end 
       true -> 
           alive_set = MapSet.difference( MapSet.new( Enum.to_list(1..tot_num) --[ban] ), get_content() )
           case MapSet.size( alive_set ) do
               0 -> 
                   -1 
               _ ->
                    Enum.random( alive_set ) 
           end  
     end   
  end
  
    
  def line_neighbour( the_num, tot_num ) do
     cond do
         the_num == 1 -> 
           [ 2 ] 
         the_num == tot_num -> 
           [ tot_num-1 ] 
         true -> 
           [ the_num - 1, the_num + 1 ]
         end   
  end 

  def full_neighbour( the_num, tot_num ) do
     get_random_neighbour( tot_num, 0, the_num )   
  end  
 
end  
