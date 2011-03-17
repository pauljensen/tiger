function [sol] = fba(tiger)
% FBA  Run Flux Balance Analysis on a TIGER model.
%      Returns a CMPI solution structure.

milp = make_milp(tiger);
milp.sense = -1;
sol = cmpi.solve_mip(milp);
