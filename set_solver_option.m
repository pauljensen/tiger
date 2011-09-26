function set_solver_option(option,val)
% SET_SOLVER_OPTION  Set a default solver option
%
%   SET_SOLVER_OPTION(OPTION,VAL)
%
%   Sets an option in the default option structure.  For a
%   description of the solver options, see the documentation
%   for SOLVE_MIP.

cmpi.set_option(option,val);
