defmodule Project3.Modules do

	def hop(data,count,target) do
           me = self()
           if count == data["depth"] do
             {me,count}
           else
             j = elem( data["neighbour"], count )
             pid = elem( target, count)
             next = Enum.reduce_while(0..15,me, fn i,_ ->
                x = elem( j, rem(pid+i,16)) 
                if tuple_size( x )!=0 do
                  {:halt,elem( x,2)}
                else
                  {:cont,me}
                end
              end)
              if next == me do
                hop(data,count+1,target)
              else
                {next,count+1}
              end
           end
	end

	def multiple_cast(data,id,id_no,pid,length) do
           count = Enum.reduce(length..data["depth"]-1,data["AA"], fn the_num,count ->
             Enum.reduce(0..15, count, fn i, count -> 
                if tuple_size(elem(elem(data["neighbour"],the_num),i)) != 0 do
                  GenServer.cast(elem(elem(elem(data["neighbour"],the_num),i),2),{:check,id,id_no,pid,length,self()})
                  count+1
                else
                  count
                end
	     end)
	   end)
	   Map.put(data, "AA", count)
	end
	
	def routing(data,target,count,hops,from,source) do
           {next,count} = hop(data,count,target)
           if next == self() do
             GenServer.cast(from,{:msg,hops})
             data
           else
             GenServer.cast(next,{:recieve,target,hops+1,count,from,source})
             data
           end
	end
	
	def update_arr(data,the_num,new_id,new_id_no,pid) do	
           neighbour = data["neighbour"]
	   id = data["id"]
	   id_no = data["id_no"]
           entry = elem(elem(neighbour,the_num),elem(new_id,the_num))
           {neighbour,data} = if tuple_size(entry) == 0 or the_num == tuple_size(id)-1 do
              data = if new_id_no == data["id_no"] do
                 add_pointer(data,id,id_no,pid,the_num)
              else
                 GenServer.cast(pid,{:add,id,id_no,self(),the_num})
                 data
              end
              { put_elem( neighbour,the_num, put_elem(elem(neighbour,the_num),elem(new_id,the_num),{new_id,new_id_no,pid})),
              data }
	   else
	      {_current_id,current_id_no,current_pid} = entry
              if current_id_no != id_no and new_id_no < current_id_no do
                 GenServer.cast(pid,{:add,id,id_no,self(),the_num})
                 GenServer.cast(current_pid,{:delete,id,the_num})
	         { put_elem(neighbour,the_num, put_elem(elem(neighbour,the_num),elem(new_id,the_num),{new_id,new_id_no,pid})),
                   data}
              else
                 {neighbour,data}
              end
           end
           data = Map.put(data,"neighbour",neighbour)
           if the_num+1 >= tuple_size(id) or (the_num+1 < tuple_size(id) and elem(id,the_num) != elem(new_id,the_num)) do
              data
           else
              update_arr(data,the_num+1,new_id,new_id_no,pid)
           end
	end

	def initialize_table(data,the_num) do
           neighbour_bucket = Enum.reduce(data["neighbours"],%{}, fn {id,{id_no,pid}},neighbour_bucket ->
           Map.update(neighbour_bucket,elem(id,the_num),{id,id_no,pid},fn {current_id,current_id_no,current_pid} ->
	       if(id_no<current_id_no,do: {id,id_no,pid},else: {current_id,current_id_no,current_pid})
	        end)
           end)
           {data,next_neighbours} = Enum.reduce(Map.values(neighbour_bucket),{data,%{}},fn {id,id_no,pid},{data,next_neighbours} ->
               {update_neighbour(data,id,id_no,pid),
               Map.merge(next_neighbours,GenServer.call(pid,{:pointer,data["id"],data["id_no"],self(),the_num},:infinity))}
           end)
           data = Map.put(data,"neighbours",next_neighbours)
               the_num = the_num - 1
               if the_num>=0 do
                  initialize_table(data,the_num)
               else
                 data
               end
      end

      def update_neighbour(data,id,id_no,pid) do
         update_arr(data,0,id,id_no,pid)
      end

      def add_pointer(data,id,id_no,pid,the_num) do
         pointer = data["pointer"]
         pointer = put_elem(pointer,the_num,Map.put(elem(pointer,the_num),id,{id_no,pid}))
         Map.put(data,"pointer",pointer)
      end

      def del(data,id,the_num) do
         pointer = data["pointer"]
         pointer = put_elem(pointer,the_num,Map.delete(elem(pointer,the_num),id))
         Map.put(data,"pointer",pointer)
      end
	
      def compare(obj1,obj2) do
         Enum.reduce_while(0..tuple_size(obj1)-1,0,fn i,count -> 
         if elem(obj1,i) == elem(obj2,i) do
           {:cont,count+1}
	 else
	   {:halt,count}
         end
         end)
      end
end
