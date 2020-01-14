defmodule Proj2.Torus_3D do
        def num_to_coordinate( the_num, l, w) do 
            z = div( the_num - 1, l * w )  
            xy = rem( the_num - 1 , l * w ) 
            y = div( xy, w ) 	
            x = rem( xy, w ) 
            [x, y, z]
	end
	
	def cube_neighbour( x, y, z, l, w, h ) do 
	    left_x = rem( x + l - 1, l )
            right_x = rem( x + l + 1, l )
            left_y = rem( y + w - 1, w )
            right_y = rem( y + w + 1, w )
            left_z = rem( z + h - 1, h )
            right_z = rem( z + h + 1, h )
            [[left_x, y, z ], [right_x, y, z ], [ x, left_y, z ], [ x, right_y, z ], [ x, y, left_z ], [ x, y, right_z]] 
	end 
	def coordinate_to_num( coordinate, l, w ) do
	    [ x, y, z ] = coordinate 
            x + 1 + y * l  + z * l * w ;  
	end 
	
	def generate( the_num, tot_num) do
		l = Float.ceil( :math.pow(tot_num,1/3) )  |> trunc 
		w = l 
                h = ceil(tot_num / ( l * w ))  
		[x, y, z] = num_to_coordinate(the_num, l, w)

		list = cube_neighbour( x, y, z, l, w, h)
	        the_list = Enum.map( list, fn x -> coordinate_to_num( x, l, w ) end)	
                Enum.filter( the_list, fn x -> x <= tot_num end ) 
	end
end
