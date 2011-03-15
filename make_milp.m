function [milp] = make_milp(tiger,sense)
% MAKE_MILP  Convert a TIGER structure to a CMPI MILP.
%
%   [MILP] = MAKE_MILP(TIGER,SENSE)
%
%   Create a CMPI MILP structure froma TIGER model.  SENSE can be either
%   a numerical sense (1 -> min, -1 -> max), or a string ('max' or 'min').

if nargin < 2 || isempty(sense)
    sense = 1;
end
if isa(sense,'char')
    switch sense
        case {'max','maximize'}
            milp.sense = -1;
        case {'min','minimize'}
            milp.sense =  1;
    end
else
    milp.sense = sense;
end

milp.obj = tiger.obj;
milp.A = tiger.A;
milp.b = tiger.b;

milp.lb = tiger.lb;
milp.ub = tiger.ub;

milp.ctypes = tiger.ctypes';
milp.vartypes = upper(tiger.vartypes');

milp.colnames = tiger.varnames;
milp.rownames = tiger.rownames;

