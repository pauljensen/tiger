function [cond1,cond2] = find_conditions(trans,T)

[cond1,cond2] = ind2sub(size(T),find(T(:) == trans));
