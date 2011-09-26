function start_tiger(solver)
% START_TIGER  Initialize the TIGER software
%
%   START_TIGER(SOLVER)
%
%   Initializes the CMPI solver.  SOLVER is an optional string with the
%   solver name ('cplex', 'gurobi', and 'glpk' are available, with
%   'cplex' by default).

cmpi.init();

if nargin == 1
    cmpi.set_solver(solver);
end
