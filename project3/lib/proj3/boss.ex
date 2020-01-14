defmodule Project3.Boss do
	use Supervisor
	use Application
	
	def start(_type, args) do
    	     Project3.Boss.start(args)
  	end
	
	def start(args) do
           Supervisor.start_link(__MODULE__, args, name: __MODULE__)
	end

	def init(_args) do
		child = []
		Supervisor.init(child, strategy: :one_for_one)
	end

        def get_count( numNodes ) do
           get_count( 0, 1, numNodes )
        end
        def get_count( pow, val, numNodes ) do
          cond do
            numNodes <= val ->
              pow
            true ->
                get_count( pow + 1, val * 16, numNodes )
          end
        end
	
	def terminate(nodes) do
           Enum.each(nodes, fn {id,{_,_}} -> 
              Supervisor.terminate_child({__MODULE__, Node.self()}, id)
              Supervisor.delete_child({__MODULE__, Node.self()}, id)
              end)
	end
	

        def convert_to_16( the_num, depth ) do
           {_,res}= Enum.reduce( 1..depth, { the_num - 1 , [] }, fn _,  {num,acc} ->
           new_acc = [ rem(num,16) ] ++ acc
           { div( num, 16 ), new_acc }  end )
           List.to_tuple( res )
       end

       def get_random_neighbour( depth, numNodes ) do
          the_num = :math.pow( 16, depth ) |> trunc
          List.to_tuple(  Enum.slice( Enum.shuffle( 1..the_num ), 0, numNodes ) )
       end


       def get_init_ids( numNodes, id_normal ) do
          depth = get_count(numNodes)
          depth = if( depth == 0,do: 1,else: depth)
          the_arr = Enum.map( Tuple.to_list( id_normal ), fn x -> convert_to_16( x, depth ) end )
          the_arr = List.to_tuple( the_arr ) 
          the_arr            
	end

	def generate_network(numNodes,numRequests) do
            depth = get_count( numNodes ) 
            id_normal = get_random_neighbour( depth, numNodes )
            the_ids = get_init_ids( numNodes, id_normal)
            empty_arr =  List.to_tuple(Enum.map(0..15,fn _-> {} end))
            data = %{ "neighbour" => if(depth<=0,do: {},else: List.to_tuple(Enum.map(0..depth-1,fn _-> empty_arr end))),
                      "neighbours" => %{},
                      "next_node" => {},
                      "AA" => 0,
                      "depth" => depth, 
                      "boss" => self(),
                      "pointer" =>  List.to_tuple(Enum.map(0..depth-1,fn _->%{} end)) }
	    { children_data , _ } = Enum.reduce(0..numNodes-1,{%{},:nil}, fn i, { the_data, main_node} ->
                 id = elem( the_ids, i )
                 data = Map.put( data, "id", id)
                 no = elem( id_normal, i ) 
                 data = Map.put( data, "id_no", no )
                 data = Map.put(data,"target",Enum.map(1..numRequests,fn _ -> 
                 elem( the_ids, Enum.random( 0..numNodes-1 ) ) end) )
                 specs = Supervisor.child_spec( {Project3.Workers, data}, id: no, shutdown: :infinity, restart: :transient)
                 res = Supervisor.start_child( {__MODULE__, Node.self()}, specs )
                 pid = elem( res, 1 ) 
                 if main_node == :nil do
		    { Map.put( the_data, no, { id, pid } ), pid }
                 else
		    GenServer.call( main_node, { :insert_init, id, no, pid}, :infinity )
		    { Map.put( the_data, no, { id, pid} ), main_node}
                    end
		 end)
		 children_data
	end
       	
	def sleep(pid \\ 0,max_hop \\ 0)

	def sleep(pid,max_hop) when pid <= 0 do
		{pid,max_hop}
	end

	def sleep(pid,max_hop) do
		receive do
			{:ack,hop} ->
			max_hop = if(max_hop<hop,do: hop,else: max_hop)
			sleep(pid-1,max_hop)
		end
	end
end
