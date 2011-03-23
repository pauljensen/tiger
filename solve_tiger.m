function [sol] = solve_tiger(tiger,sense)
% SOLVE_TIGER  Solve a TIGER model.
%
%   Solve a TIGER model structure and return a CMPI solution structure.  
%   SENSE can be either 'min' for minimization (default) or 'max' for 
%   maximization.

if nargin < 2
    sense = 'min';
end

milp = make_milp(tiger,sense);
sol = cmpi.solve_mip(milp);
