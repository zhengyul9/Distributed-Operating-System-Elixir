defmodule Proj2.Honeycomb do
	def generate( node, num ) do
		lineElementNum = :math.sqrt( num) 	|> trunc
		case rem(round(Float.floor((node-1)/lineElementNum)),2) do
                     0 -> #odd line
                        case rem(node,2) do    
                           1 -> #odd element
                              temp = []  
                                temp = if(node - 1 > 0 && rem(node, lineElementNum) != 1) do
                                   temp ++ [node - 1]
                                else 
                               	   temp
                                end
                               	   
                                temp = if(node - lineElementNum > 0) do
                                    temp ++ [node - lineElementNum]
                                else 
                                    temp
                                end
         
                                if(node + lineElementNum < num) do
                                    temp ++ [node + lineElementNum]
                                else  
                                    temp
                                end
                                     
                           0 -> #even element
			      temp = []
                              temp = if(node + 1 < num && rem(node, lineElementNum) != 0) do
	                           temp ++ [node + 1]
                              else  
	                           temp
                              end
                              temp = if(node - lineElementNum > 0) do
	                           temp ++ [node - lineElementNum]
                              else  
	                           temp
                              end

                              if(node + lineElementNum < num) do
	                           temp ++ [node + lineElementNum]
                              else  
	                           temp
                              end
			   end
                     1 -> #even line
                        case rem(node,2) do
                           1 -> #odd element in even line
                              temp = []
                              temp = if(node + 1 < num) do
                                   temp ++ [node + 1]
		              else 
                                   temp
                              end
		           
                              temp = if(node - lineElementNum > 0) do
                                   temp ++ [node - lineElementNum]
                              else  
                                   temp
                              end
 
                              if(node + lineElementNum < num) do
                                   temp ++ [node + lineElementNum]
                              else  
                                   temp
                              end
                          
                           0 -> #even element in even line 
	                      temp = []  
		              temp = if(node - 1 > 0) do
                                   temp ++ [node - 1]
                              else 
			           temp
                              end
		              temp = if(node - lineElementNum > 0) do
			          temp ++ [node - lineElementNum]
		              else 
			          temp
		              end
		              if(node + lineElementNum < num) do
		                  temp ++ [node + lineElementNum]
		              else  
			          temp
		              end
		          end
		end
		
	end
end
