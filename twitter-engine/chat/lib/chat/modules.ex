defmodule Modules do
   def string_processing( s ) do
     s_arr = String.split( s ) #"hello world! @yy  #florida")
     s_mention = Enum.filter( s_arr, fn x -> String.contains?( x, "@" ) end )
     s_mention = Enum.map( s_mention, fn x -> String.slice( x, 1..-1 ) end )
     s_hashtag = Enum.filter( s_arr, fn x -> String.contains?( x, "#" ) end )
     s_hashtag = Enum.map( s_hashtag, fn x -> String.slice( x, 1..-1 ) end )
     { s_mention, s_hashtag }
  end
end 
