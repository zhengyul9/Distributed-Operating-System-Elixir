args = System.argv()
args = Enum.map(args,fn arg -> String.to_integer(arg) end)
[numNodes,numRequests] = args

if numNodes > 0 || numRequests > 0 do
	tapestry = Project3.Boss.generate_network(numNodes,numRequests)
	count = Enum.reduce(tapestry,0, fn{_,{_,pid}},count -> send(pid,{:send})  
                    count+1 
                end)
	{_,max_hops} = Project3.Boss.sleep(count)
	IO.puts("Maximum number of hops (node jump times): #{max_hops}")
	Project3.Boss.terminate(tapestry)
else
	IO.puts("Invalid Input")
end

