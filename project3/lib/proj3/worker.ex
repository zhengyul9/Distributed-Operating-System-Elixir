defmodule Project3.Workers do
	use GenServer

	def start_link(data) do
		GenServer.start_link(__MODULE__, data)
	end

	def init(data) do
		{:ok, Project3.Modules.update_neighbour(data,data["id"],data["id_no"],self())}
	end

	def handle_call({:neighbors,id,id_no,pid},_from,data) do
		data = Map.put(data,"neighbours",Map.put(data["neighbours"],id,{id_no,pid}))
		{:reply,:ok,data}
	end

	def handle_call({:pointer,id,id_no,pid,level},_from,data) do
		data = Project3.Modules.update_neighbour(data,id,id_no,pid)
		{:reply,if(level-1 >= 0,do: elem(data["pointer"],level-1),else: %{}),data}
	end
	
	def handle_call({:insert_init,id,id_no,pid},from,data) do
		root = put_elem(id,tuple_size(id)-1,rem(elem(id,tuple_size(id)-1)+tuple_size(elem(data["neighbour"],0))-1,
		tuple_size(elem(data["neighbour"],0))))
		{next,hop} = Project3.Modules.hop(data,0,root)
		GenServer.cast(next,{:insert_node,root,id,id_no,pid,hop,from})
		{:noreply,data}
	end
	
	def handle_info({:send},data) do
		if not Enum.empty?(data["target"]) do
			[head|tail] = data["target"]
			data = Map.put(data,"target",tail)
			data = Map.update(data,"AA",0,&(&1+1))
			data = Project3.Modules.routing(data,head,0,0,self(),data["id"])
			Process.send_after(self(),{:send},1000)
			{:noreply,data}
		else
			{:noreply,data}
		end
	end
	
	def handle_cast({:insert_node,root_id,id,id_no,pid,hop_count,root},data) do
		{next,hop_count} = Project3.Modules.hop(data,hop_count,root_id)
		if next == self() do
			GenServer.cast(next,{:check,id,id_no,pid,Project3.Modules.compare(id,data["id"]),self()})
			data = Map.put(data,"root",root)
			{:noreply,data}
		else
			GenServer.cast(next,{:insert_node,root_id,id,id_no,pid,hop_count,root})
			{:noreply,data}
		end
	end
	
	def handle_cast({:check,id,id_no,pid,length,from},data) do
		if data["next_node"] != {id,pid} do
			data = Map.put(data,"next_node",{id,pid})
			data = Project3.Modules.multiple_cast(data,id,id_no,pid,length)
			data = Project3.Modules.update_neighbour(data,id,id_no,pid)
			data = Map.put(data,"ori",from)
			GenServer.call(pid,{:neighbors,data["id"],data["id_no"],self()},:infinity)
			{:noreply,data}
		else
			GenServer.cast(from,{:AA})
			{:noreply,data}
		end
	end
	
	def handle_cast({:add, id, id_no, pid, level},data) do
		data = Project3.Modules.add_pointer(data,id,id_no,pid,level)
		{:noreply,data}
	end

	def handle_cast({:delete, id, level},data) do
		data = Project3.Modules.del(data,id,level)
		{:noreply,data}
	end

	def handle_cast({:AA},data) do
		data = Map.put(data,"AA",data["AA"] - 1)
		cond do
		    data["AA"] == 0 ->
                       {from,data} = Map.pop(data,"ori")
                       GenServer.cast(from,{:AA})
                       {:noreply,data}
                    data["AA"] == -1 ->
                       data = Map.put(data,"AA",0)
                       {root,data} = Map.pop(data,"root")
                       GenServer.cast(elem(data["next_node"],1),
                       {:initialize,Project3.Modules.compare(elem(data["next_node"],0),data["id"]),root})
		       {:noreply,data}
                    true-> 
                       {:noreply,data}
		end
	end

	def handle_cast({:initialize,level,root},data) do
		data = Project3.Modules.initialize_table(data,level)
		GenServer.reply(root,:ok)
		{:noreply,data}
	end

	def handle_cast({:recieve,target,hops,hop_count,from,source},data) do
		data = Project3.Modules.routing(data,target,hop_count,hops,from,source)
		{:noreply,data}
	end

	def handle_cast({:msg,hops},data) do
		data = Map.update(data,"AA",0,&(&1-1))
		data = Map.update(data,"max_hops",hops,&(if(&1<hops,do: hops,else: &1)))
		if data["AA"] == 0 and Enum.empty?(data["target"]) do
			send(data["boss"],{:ack,data["max_hops"]})
		end
		{:noreply,data}
	end
end
