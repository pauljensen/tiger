function [tiger] = close_bounds(tiger,bounds)
% CLOSE_BOUNDS  Return bounds that have been opened by OPEN_BOUNDS
%
%   [TIGER] = CLOSE_BOUNDS(TIGER,BOUNDS)
%
%   Resets a model that has been opened by OPEN_BOUNDS to the original
%   bounds.  BOUNDS is theh bounds structure returned by OPEN_BOUNDS.
%   Returns the modified model.

tiger.lb(1:bounds.N) = bounds.lb;
tiger.ub(1:bounds.N) = bounds.ub;
