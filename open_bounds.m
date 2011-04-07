function [tiger,bounds] = open_bounds(tiger)

bounds.lb = tiger.lb;
bounds.ub = tiger.ub;
bounds.N = length(tiger.lb);

tiger.lb(:) = min(tiger.lb);
tiger.ub(:) = max(tiger.ub);
