function [states,sol,mip_error,models] = ...
                        diffadj(milp,vars,d,w,I,bounds,objs,fracs)
% DIFFADJ  Formulate and solve the differential adjustment problem
%
%   [STATES,SOL] = DIFFADJ(MILP,VARS,W,D,I,BOUNDS,OBJS,FRACS,METHOD)
%
%   Attempts to match changes between different conditions while
%   retaining functional models.
%
%   Inputs
%   MILP    MILP model
%   VARS    List of indices for variables to adjust
%   D       List of differences for each transition:
%                1 -> x(t) < x(t')
%                0 -> x(t) = x(t')
%               -1 -> x(t) > x(t')
%           Columns correspond to conditions.  Each row 'i' is a variable
%           with index VARS(i).
%   W       List of weights for each transition.  Structure is the same
%           as for D.
%   I       Interaction matrix.  If I(i,j) = k, then the kth column in
%           D and W describe the transition between conditions i and j.
%           The number of nonzero entries in I should equal the number
%           of columns in D and W.
%   BOUNDS  Structure array of bounds for each condition:
%               BOUNDS{i}.lb
%               BOUNDS{i}.ub
%           If empty, the bounds in MILP are used.
%   OBJS    Cell array of objective coefficients for each condition.  If
%           empty, MILP.obj is used.
%   FRACS   Fractions of optimal growth that must be possible in each
%           condition:
%               obj'x >= FRACS(i)*obj'x_max
%           If only a single number is given, it is used for every
%           condition.  If empty, the default is 0.3.
%
%   Outputs
%   STATES     A |variables| x |conditions| matrix of states (levels) for
%              each variable in each condition.
%   SOL        Solution object from CMPI.  Contains the additional fields
%                  'obj_vals' Objective values through original models
%                  'adj_vals' Objective values through adjusted models
%                  'verified' True if obj_val(i) >= FRAC(i)*c'x_max
%   MIP_ERROR  True if an error was encourtered during the optimization.
%   MODELS     Models with STATES applied to VARS.


if nargin < 6 || isempty(bounds)
    bounds = [];
end

if nargin < 7 || isempty(objs)
    objs = [];
end

if nargin < 8 || isempty(fracs)
    fracs = 0.3;
end

[nvars,ntrans] = size(w);
ncond = ntrans + 1;

% check interaction matrix
if nargin < 5 || isempty(I)
    % no matrix given; assume 1 -> 2, 2 -> 3, ...
    I = zeros(ncond);
    for i = 1 : ntrans
        I(i,i+1) = i;
    end
end
assert(all(size(I) == [ncond,ncond]), 'I not square or wrong size');
assert(length(find(I)) == ntrans, 'I does not match w and d');
assert(all(ismember(1:ntrans,I(:))), 'I is missing transition indices');

% fill out fracs
fracs = fill_to(fracs,ncond,0.3);

% fill out bounds
if length(bounds) <= 1
    for i = 1 : ncond
        if isempty(bounds)
            bounds{i}.lb = milp.lb;
            bounds{i}.ub = milp.ub;
        else
            % one provided; replicate it
            bounds{i}.lb = bounds{1}.lb;
            bounds{i}.ub = bounds{1}.ub;
        end
    end
end

% fill out objs
if length(objs) <= 1
    for i = 1 : ncond
        if isempty(objs)
            objs{i} = milp.obj;
        else
            % one provided; replicate it
            objs{i} = objs{1};
        end
    end
end     
    
% make MILPs for each condition
milps = cell(1,ncond);
obj_vals = zeros(1,ncond);
for i = 1 : ncond
    milps{i} = milp;
    milps{i}.obj = objs{i};
    milps{i}.lb = bounds{i}.lb;
    milps{i}.ub = bounds{i}.ub;
    
    [milps{i},sol] = add_growth_constraint(milps{i},fracs(i));
    obj_vals(i) = sol.val;
end

colsA = size(milp.A,2);
mip = cmpi.tile_milp(milps{:});

% compute the index of variable V in condition C
idxof = @(v,c) colsA*(c-1) + v;

n_con = count(d(:) == 0);
con_idx1 = zeros(1,n_con);
con_idx2 = zeros(1,n_con);
con_objs = zeros(1,n_con);
con_offset = 0;
% create the objective function
for t = 1 : ntrans
    % find the interacting conditions
    [cond1,cond2] = ind2sub(size(I),find(I(:) == t));
    for v = 1 : nvars
        idx1 = idxof(vars(v),cond1);
        idx2 = idxof(vars(v),cond2);
        switch d(v,t)
            case {1}
                % increasing
                mip.obj(idx1) = mip.obj(idx1) + w(v,t);
                mip.obj(idx2) = mip.obj(idx2) - w(v,t);
            case {-1}
                % decreasing
                mip.obj(idx1) = mip.obj(idx1) - w(v,t);
                mip.obj(idx2) = mip.obj(idx2) + w(v,t);
            case {0}
                % constant
                con_offset = con_offset + 1;
                con_idx1(con_offset) = idx1;
                con_idx2(con_offset) = idx2;
                con_objs(con_offset) = w(v,t);
        end
    end
end

% create constant variables
[mip,con_vars] = add_diff(mip,con_idx1,con_idx2);
[~,con_idxs] = convert_ids(mip.varnames,con_vars);
mip.obj(con_idxs) = con_objs;

sol = cmpi.solve_mip(mip);
sol.mip = mip;

mip_error = ~cmpi.is_acceptable_exit(sol);
if ~mip_error
    states = zeros(nvars,ncond);
    for c = 1 : ncond
        for v = 1 : nvars
            states(v,c) = sol.x(idxof(vars(v),c));
        end
    end

    % round binary variables
    [~,bins] = intersect(vars,find(mip.vartypes == 'b'));
    states(bins,:) = round(states(bins,:));
    
    % verify solutions
    sol.verified = false(1,ncond);
    sol.adj_vals = zeros(1,ncond);
    sol.obj_vals = obj_vals;
    for i = 1 : ncond
        % copy models and apply gene states
        models{i} = milps{i};
        models{i}.lb(vars) = states(:,i);
        models{i}.ub(vars) = states(:,i);
        
        % run FBA to verify the solution
        kosol = fba(models{i});
        sol.verified(i) = cmpi.is_acceptable_exit(kosol);
        if ~isempty(kosol.val)
            sol.adj_vals(i) = kosol.val;
        end
    end
else
    % solver did not return a solution
    states = [];
    models = {};
end

                






    