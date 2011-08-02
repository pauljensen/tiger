function [T] = check_transition_matrix(T,ncond,ntrans)
% CHECK_TRANSITION_MATRIX  Validate a DIFFADJ matrix of transitions
%
%   [T] = CHECK_TRANSITION_MATRIX(T,NCOND,NTRANS)
%
%   Asserts that a transition matrix T is correct for a dataset with NCOND
%   conditions and NTRANS transitions.  An error is raised if T is
%   incorrect.  If T is empty, the default transition structure
%   (1 -> 2 -> ... -> NCOND) is created.  The validated T is returned.
%
%   See DIFFADJ and its related function for more information on the
%   transition matrix structure.

if isempty(T)
    T = zeros(ncond);
    for i = 1 : ntrans
        T(i,i+1) = i;
    end
end

assert(all(size(T) == [ncond,ncond]), 'T not square or wrong size');
assert(length(find(T)) == ntrans, 'T does not match w and d');
assert(all(ismember(1:ntrans,T(:))), 'T is missing transition indices');
