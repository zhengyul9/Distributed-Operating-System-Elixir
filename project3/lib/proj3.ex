defmodule Project3 do
	use Application
	def start(_type, args) do
    	Project3.Boss.start(args)
  	end
end
