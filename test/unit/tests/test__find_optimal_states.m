
T = [ 0 1 0 0;
      0 0 2 0;
      0 0 0 3 ];

d = [ 1 -1 -1 ];
w = [ 1  3 10 ];
  
[states,score,matched,total] = find_optimal_states(d,T,w);