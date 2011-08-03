function [cond1,cond2] = find_conditions(trans,T)
% FIND_CONDITIONS  Find conditions corresponding to a transition
%
%   [COND1,COND2] = FIND_CONDITIONS(TRANS,T)
%
%   Finds which two conditions correspond to transition TRANS in a
%   transition matrix T, i.e., where T(COND1,COND2) = TRANS.
%
%   See DIFFADJ and its related function for more information on the
%   transition matrix structure.

[cond1,cond2] = ind2sub(size(T),find(T(:) == trans));
