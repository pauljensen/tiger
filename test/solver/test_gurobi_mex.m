

c = [-5; -4; -6];
objtype = 1;
A =  sparse([1 -1  1; 3  2  4; 3  2  0]);
b = [20; 42; 30];
lb = zeros(3,1);           % same as lb = [];
ub = [];
contypes = '<<<';
vtypes = [];               % same as vtypes = 'CCC'; [] means 'C...C'

clear opts
opts.IterationLimit = 20;
opts.FeasibilityTol = 1e-6;
opts.IntFeasTol = 1e-5;
opts.OptimalityTol = 1e-6;
opts.Method = 1;         % 0 - primal, 1 - dual
opts.Presolve = -1;        % -1 - auto, 0 - no, 1 - conserv, 2 - aggressive
opts.Display = 1;
%opts.LogFile = 'test_gurobi_mex_LP.log';     % optional
%opts.WriteToFile = 'test_gurobi_mex_LP.mps'; % optional; it can cause a long delay if problem is large

[x,val,exitflag,output,lambda] = gurobi_mex(c,objtype,A,b,contypes,lb,ub,vtypes,opts);