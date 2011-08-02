function [tiger,bounds] = open_bounds(tiger)
% OPEN_BOUNDS  Open all bounds to a max value
%
%   [TIGER,BOUNDS] = OPEN_BOUNDS(TIGER)
%
%   Converts all lower and upper bounds to the minimum and maximum bounds
%   in the respective field.  Returns the modified models and a BOUNDS
%   structure that can be used to reset the bounds to their original
%   values (see CLOSE_BOUNDS).

bounds.lb = tiger.lb;
bounds.ub = tiger.ub;
bounds.N = length(tiger.lb);

tiger.lb(:) = min(tiger.lb);
tiger.ub(:) = max(tiger.ub);
