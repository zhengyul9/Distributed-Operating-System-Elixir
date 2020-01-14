Group members:

Yue Yu	96141901<br>
Zhengyu Li	29453969<br>


Run the code:
1. Extract the zip file
2. mix escript.build in the folder which contains "mix.exs" file
3. (add "escript" if running on windows)./proj2 num_actors topology algorithm<br>

    num_actors  - integer<br>
    topology    - line | full | honeycomb | honeycomb_extra | random2d | 3dtorus<br>
    algorithm   - gossip | pushsum<br>
	

What is working?

All topologies are working for both algorithms.


Largest network:

Gossip:
All topologies we tested could handle 10,000 nodes. The algorithm will work with larger networks, but take much longer.

Pushsum:
All topologies we tested could handle 2000 nodes. The algorithm will work with larger networks, but take much longer.



