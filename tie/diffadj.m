function [states,sol,mip_error,models] = ...
                        diffadj(milp,vars,d,w,I,bounds,objs,fracs,verify)
% DIFFADJ  Formulate and solve the differential adjustment problem
%
%   [STATES,SOL] = DIFFADJ(MILP,VARS,D,W,I,BOUNDS,OBJS,FRACS,METHOD)
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
%   VERIFY  If true (default), resulting models are run to verify the 
%           minimum objective flux.
%
%   Outputs
%   STATES     A |variables| x |conditions| matrix of states (levels) for
%              each variable in each condition.
%   SOL        Solution object from CMPI.  Contains the additional fields
%                  'obj_vals' Objective values through original models
%                  'adj_vals' Objective values through adjusted models
%                  'verified' True if obj_val(i) >= FRAC(i)*c'x_max
%                  'mip'      Full MIP structure
%                  'I'        Interaction matrix
%   MIP_ERROR  True if an error was encourtered during the optimization.
%   MODELS     Models with STATES applied to VARS.

USE_NONBINDING_DIFF = true;

if nargin < 5
    I = [];
end

if nargin < 6 || isempty(bounds)
    bounds = [];
end

if nargin < 7 || isempty(objs)
    objs = [];
end

if nargin < 8 || isempty(fracs)
    fracs = 0.3;
end

if nargin < 9 || isempty(verify)
    verify = true;
end

vars = convert_ids(milp.varnames,vars,'index');

[nvars,ntrans] = size(w);
ncond = ntrans + 1;

I = check_transition_matrix(I,ncond,ntrans);

% fill out fracs
fracs = fill_to(fracs,ncond,0.3);

% fill out bounds
if isempty(bounds)
    bounds.lb = milp.lb;
    bounds.ub = milp.ub;
end
bounds = assert_cell(bounds);
if length(bounds) == 1
    for i = 2 : ncond
        bounds{i} = bounds{1};
    end
end

% fill out objs
if isempty(objs)
    objs = milp.obj;
end
objs = assert_cell(objs);
if length(objs) == 1
    for i = 2 : ncond
        objs{i} = objs{1};
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
    
    if fracs(i) > 0
        [milps{i},sol] = add_growth_constraint(milps{i},fracs(i));
        obj_vals(i) = sol.val;
    else
        obj_vals(i) = 0;
    end
end

colsA = size(milp.A,2);
mip = cmpi.tile_mip(milps{:});

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
if USE_NONBINDING_DIFF
    [mip,pos_idxs,neg_idxs] = add_nonbinding_diff(mip,con_idx1,con_idx2);
    mip.obj(pos_idxs) = con_objs;
    mip.obj(neg_idxs) = con_objs;
else
    [mip,con_vars] = add_diff(mip,con_idx1,con_idx2);
    [~,con_idxs] = convert_ids(mip.varnames,con_vars);
    mip.obj(con_idxs) = con_objs;
end

sol = cmpi.solve_mip(mip);
sol.mip = mip;
sol.T = I;

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
    
    models = cell(1,ncond);
    for i = 1 : ncond
        % copy models and apply gene states
        models{i} = set_var(milps{i},vars,[],states(:,i));
    end
    
    % verify solutions
    if verify
        sol.verified = false(1,ncond);
        sol.adj_vals = zeros(1,ncond);
        sol.obj_vals = obj_vals;
        for i = 1 : ncond
            % run FBA to verify the solution
            kosol = fba(models{i});
            sol.verified(i) = cmpi.is_acceptable_exit(kosol);
            if ~isempty(kosol.val)
                sol.adj_vals(i) = kosol.val;
            end
        end
    end
    
    sol.variables = deparse_sol(sol.x,milps);
else
    % solver did not return a solution
    states = [];
    models = {};
end


function [mip,pos_idxs,neg_idxs] = add_nonbinding_diff(mip,idxs1,idxs2)
    N = length(idxs1);
    
    [m,n] = size(mip.A);
    
    pos_idxs = n + (1:N);
    neg_idxs = n + N + (1:N);
    
    plb = zeros(N,1);
    pub = zeros(N,1);
    nlb = zeros(N,1);
    nub = zeros(N,1);
    varnames = [array2names('nbd_diff_pos%i',pos_idxs); ...
                array2names('nbd_diff_neg%i',neg_idxs)];
    
    for i = 1 : N
        pub(i) = mip.ub(idxs1(i)) - mip.lb(idxs2(i));
        nub(i) = mip.ub(idxs2(i)) - mip.lb(idxs1(i));
    end
    mip = add_column(mip,varnames,'c',[plb;nlb],[pub;nub]);
    
    mip = add_row(mip,N);
    for i = 1 : N
        % add constraint var1 - var2 + p_slack - n_slack = 0
        mip.A(m+i,[idxs1(i) idxs2(i) pos_idxs(i) neg_idxs(i)]) ...
            = [1 -1 1 -1];
    end
    
    
function [vars] = deparse_sol(xall,models)
    RXN_PRE = 'RXN__';
    genes = models{1}.genes;
    ncond = length(models);
    nrxns = size(models{1}.S,2);
    nvars = size(models{1}.A,2);
    
    vars = cell(1,ncond);
    
    rxn_names = map(@(x) [RXN_PRE x],models{1}.varnames(1:nrxns));
    [rxn_tf,rxn_idxs] = ismember(rxn_names,models{1}.varnames);
    [~,gene_idxs] = ismember(genes,models{1}.varnames);
    for i = 1 : ncond
        x = xall(nvars*(i-1)+(1:nvars));
        
        vars{i}.flux = x(1:nrxns);
        
        vars{i}.rxn = zeros(nrxns,1);
        vars{i}.rxn(rxn_tf) = x(rxn_idxs(rxn_tf));
        vars{i}.rxn(~rxn_tf) = -1;
        
        vars{i}.gene = x(gene_idxs);
    end
        
    
