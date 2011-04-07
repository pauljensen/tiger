function [tiger] = close_bounds(tiger,bounds)

tiger.lb(1:bounds.N) = bounds.lb;
tiger.ub(1:bounds.N) = bounds.ub;
