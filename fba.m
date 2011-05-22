function [sol] = fba(tiger,fluxnorm,obj_frac)
% FBA  Run Flux Balance Analysis on a TIGER model.
%      Returns a CMPI solution structure.

if nargin < 3
    obj_frac = 1.0;
end

if nargin < 2
    fluxnorm = 'none';
end

switch fluxnorm
    case {'none','fba'}
        % standard FBA
        milp = make_milp(tiger);
        milp.sense = -1;
        sol = cmpi.solve_mip(milp);
    case {'euclid','two','quad'}
        % Euclidian norm
        tiger = add_growth_constraint(tiger,obj_frac);
        nS = size(tiger.S,2);
        nA = size(tiger.A,2);
        tiger.Q = spalloc(nA,nA,nS);
        tiger.Q(1:nS,1:nS) = eye(nS);
        sol = cmpi.solve_mip(tiger);
end

