defmodule Proj2.RandomGen do
	def generate( num ) do
	    coordinates = Enum.map( 1..num, fn _x -> [ Enum.random(1..100), Enum.random(1..100) ] end ) 
            Enum.map( 1..num, fn n -> judge( coordinates, n, num ) end )	
        end
	def judge( coordinates, n, num ) do 
	    [ x, y ] = Enum.at( coordinates, n - 1 )
            IO.puts( n ) 
	    the_list = for i <- 1..num do
		    [ x_1, y_1 ] = Enum.at( coordinates, i - 1 )
 		    dist = (x-x_1)*(x-x_1)+(y-y_1)*(y-y_1) 
			cond do 
			   dist > 100 -> false
                           i == n -> false 
			   true -> true 
			end 
		end
        Enum.filter( 1..num, fn i -> Enum.at( the_list, i-1) end )		
	end 
end
