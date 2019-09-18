defmodule VampireNumber do 
 # algorithm of calculating vampire number, return a list	
  defmacro __using__(_opts) do
	[]#IO.puts "inside Vampire module"
  end
  
  def factor_pairs(n) do #called in vampire_factors function, preprocessing
    first = trunc(n / :math.pow(10, div(length(to_charlist(n)), 2)))# move dot to the middle of n 100000 -> 100
    last  = :math.sqrt(n) |> round #square root of the number
    for i <- first .. last, rem(n, i) == 0, do: {i, div(n, i)}
  end

  def vampire_factors(n) do #called in task function
    if rem(length(to_charlist(n)), 2) == 1 do # it is not a vampire number if it is an odd number
      [""]
    else
      half = div(length(to_charlist(n)), 2)	#half length
      sorted = Enum.sort(String.codepoints("#{n}"))
      list = Enum.filter(factor_pairs(n), fn {a, b} ->
        length(to_charlist(a)) == half && length(to_charlist(b)) == half &&
        Enum.count([a,b], fn x -> rem(x, 10) == 0 end) != 2 &&
        Enum.sort(String.codepoints("#{a}#{b}")) == sorted
      end)
	  string_list = Enum.map(list, fn {a,b} -> " #{a} #{b}" end)
	  ["#{n}"] ++ string_list
    end
  end
end

defmodule Boss do 
# Supervisor
  use GenServer
  defmacro __using__(_opts) do
     [] 
  end
  def start(data) do
    GenServer.start_link(__MODULE__, data)
  end
  def add( pid, i, val ) do
    GenServer.call( pid, {:add, i, val} )
  end 
  def get_val( pid, i ) do
    GenServer.call( pid, {:get_val, i} )
  end 
  ###########################
  def init(data) do
    {:ok, data}
  end
  def handle_call({:add, i, val}, _from, data ) do
     data = Map.put( data, i, val )  
	 {:noreply,data}
  end 
  def handle_call({:get_val, i}, _from, data) do
	val = Map.get( data, i, 0 ) 
    {:reply, val, data }
  end
end   

defmodule Worker do
# actor
  use GenServer
  use VampireNumber
  use Boss
  defmacro __using__(_opts) do
	[]
  end

  def start(data, opt \\ []) do
    GenServer.start_link(__MODULE__, data, opt)
  end 

  # start a process by name
  def process_start(pid, i, low, high, boss_id ) do
    GenServer.cast(pid, {:start, i, low, high, boss_id })
  end

  def init(data) do
    {:ok, data}
  end

  def handle_cast({:start, i, low, high, boss_id }, data) do
	tmp = for i <- low..high, do: {
		VampireNumber.vampire_factors(i) }
	tmp = Enum.filter( tmp, fn {[ _head | tail ]} ->
	tail != [] 
	end )
	tmp = Enum.map( tmp, fn {x} -> Enum.join(x) <> "\n"end )
    tmp = Enum.join( tmp ) 	
	Boss.add( boss_id, i, tmp ) 
	#tmp = data 
    {:noreply, data }
  end
end 


defmodule Main do 
#execution
  def task() do # main program
	args = System.argv()
	l = String.to_integer(Enum.at(args,0))
	h = String.to_integer(Enum.at(args,1))
	{:ok, boss_id } = Boss.start( Map.new )
	num_of_proc = 8
	step = div( h-l+1, num_of_proc ) 
	Enum.each( 1..num_of_proc, fn i -> 
	low = ( i - 1 ) * step + l 
	high = low + step - 1 
	{:ok, worker_id } = Worker.start( Map.new )	
	Worker.process_start( worker_id, i, low, high, boss_id ) 	
    end )
	:timer.sleep(800) 
	Enum.map( 1..num_of_proc, fn i -> Boss.get_val( boss_id, i ) end )
  end 
end
res = Main.task 

IO.puts Enum.join( res )
