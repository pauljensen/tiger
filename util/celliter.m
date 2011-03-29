function celliter(f,C)
% CELLITER  Iterate over elements in a cell
%
%   CELLITER(F,C) iterates over each element in cell C, calling F(C{i}).

for i = 1 : length(C)
    f(C{i});
end

