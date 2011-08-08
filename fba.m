function [sol] = fba(tiger,fluxnorm,obj_frac)
% FBA  Run Flux Balance Analysis on a TIGER model.
%
%   [SOL] = FBA(TIGER)
%   [SOL] = FBA(TIGER,FLUXNORM,OBJ_FRAC)
%
%   Run Flux Balance Analysis on a TIGER model, returning a CMPI solution
%   structure.  If given, FLUXNORM specifies the norm to be minimized;
%   choices include 
%       'none' (default):
%           maximize obj*v
%           s.t. Sv = 0
%                lb <= v <= ub
%       'two' (Euclidian)
%           minimize v'*v
%           s.t. Sv = 0
%                lb <= v <= ub
%                obj*v >= OBJ_FRAC*v_max
%
%   Unless specified, OBJ_FRAC defaults to 1.0.

if nargin < 3
    obj_frac = 1.0;
end

if nargin < 2
    fluxnorm = 'none';
end

switch fluxnorm
    case {'none','fba'}
        % standard FBA
        tiger.sense = -1;
        sol = cmpi.solve_mip(tiger);
    case {'euclid','two','quad'}
        % Euclidian norm
        tiger = add_growth_constraint(tiger,obj_frac);
        nS = size(tiger.S,2);
        nA = size(tiger.A,2);
        tiger.Q = spalloc(nA,nA,nS);
        tiger.Q(1:nS,1:nS) = eye(nS);
        sol = cmpi.solve_mip(tiger);
end

