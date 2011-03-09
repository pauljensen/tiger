function [sol] = fba(tiger)

milp = make_milp(tiger);
milp.sense = -1;
sol = cmpi.solve_milp(milp);
