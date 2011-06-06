function [T] = check_transition_matrix(T,ncond,ntrans)

if isempty(T)
    T = zeros(ncond);
    for i = 1 : ntrans
        T(i,i+1) = i;
    end
end

assert(all(size(T) == [ncond,ncond]), 'T not square or wrong size');
assert(length(find(T)) == ntrans, 'T does not match w and d');
assert(all(ismember(1:ntrans,T(:))), 'T is missing transition indices');
