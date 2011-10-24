function [sol] = solve_tiger(tiger,sense)
% SOLVE_TIGER  Solve a TIGER model.
%
%   [SOL] = SOLVE_TIGER(TIGER,SENSE)
%
%   Solve a TIGER model structure and return a CMPI solution structure.  
%   SENSE can be either 'min' for minimization (default) or 'max' for 
%   maximization.
%
%   For more information, see the documentation for SOLVE_MIP.

if nargin < 2 && ~isfield(tiger,'sense')
    sense = 'min';
end

if nargin > 1 && ~isempty(sense)
    switch sense
        case {'min','minimize'}
            tiger.sense = 1;
        case {'max','maximize'}
            tiger.sense = -1;
        otherwise
            error('invalid sense: %s',sense);
    end
end

sol = cmpi.solve_mip(tiger);
