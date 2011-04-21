function [tiger] = scale_bounds(tiger,scaling)
% SCALE_BOUNDS  Apply a scaling factor to upper and lower bounds
%
%   [TIGER] = SCALE_BOUNDS(TIGER,SCALING)
%
%   Scales TIGER.lb and TIGER.ub by SCALING and returns the modified
%   model.  The scaling can be useful for avoiding numerical stabilities
%   from Big-M constraints.

tiger.lb = scaling * tiger.lb;
tiger.ub = scaling * tiger.ub;
