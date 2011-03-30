
init_test

tiger = create_empty_tiger();
tiger = add_column(tiger,{'a','b','c','x','y','z'},'bbbiii', ...
                         [0;0;0;0;0;0],[1;1;1;2;2;3],[],[]);
tiger = add_row(tiger,3);

vars = 1:6;

%     1   2   3
d = [   1   1;  % a
       -1   1;  % b
       -1  -1;  % c
        1   0;  % x
       -1  -1;  % y
        1  -1]; % z
    
w = [   2   4;  % a
        3   1;  % b
        2   1;  % c
        1   1;  % x
        2   2;  % y
        1   1]; % z
    
[states,sol,mip_error,models] = diffadj(tiger,vars,d,w);

assert(mip_error == 0,'mip error');

optimal = [ 0     0     1
            1     0     1
            1     0     0
            0     2     2
            2     0     0
            0     3     0 ];

assert(near(states,optimal),'answer error');