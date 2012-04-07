function [sol] = made(tiger,fold_change,pvals,varargin)
% MADE  Metabolic Adjustment by Differential Expression
%
%   [SOL] = MADE(TIGER,FOLD_CHANGE,PVALS,...parameters...)
%
%   Integrate gene expression data with metabolic models using the MADE
%   algorithm [Jensen & Papin (2011), Bioinformatics].
%
%   Inputs
%   TIGER       TIGER model.  COBRA models will be converted to TIGER 
%               models with a warning.  MADE also accepts a cell array of
%               models for each condition.
%   FOLD_CHANGE Measured fold change from expression data.  Columns
%               correspond to conditions, rows correspond to genes.
%   PVALS       P-values for changes.  Format is the same as for
%               FOLD_CHANGE.
%
%   Parameters
%   'gene_names' Cell array of names for genes in expression dataset.
%                These correspond to the rows in FOLD_CHANGE and PVALS.
%                If none is given, the rows correspond to TIGER.genes.
%   'obj_frac'   Fraction of metabolic objective required in the resulting 
%                model (v_obj >= frac*v_obj_max). Default is 0.3.  Input 
%                can also be a vector giving a separate fraction for each 
%                condition.
%   'weighting'  Method to convert PVALS to weights.  Options include:
%                   'log'     w(p) = -log(p)
%                   'linear'  w(p) = 1 - p
%                   'unit'    w(p) = 1
%                   'none'    No transformation -- PVALS are weights and
%                             FOLD_CHANGE is a direction matrix
%   'bounds'     Structure array of condition-specific bounds.  For
%                example, BOUNDS{i}.lb and BOUNDS{i}.ub are the lower
%                and upper bounds for the ith condition.  If not
%                specified, the bounds from MODEL are copied to each
%                condition.
%   'objs'       Cell array of condition-specific objectives.  If not
%                specified, the objective MODEL.c is copied to each
%                condition.
%   'p_thresh'   Threshold above which a P-value is not considered
%                significant.  If a gene increases with a P-value
%                p > P_THRESH, then it will be held constant with P-value
%                1 - p.  The default is 0.5.
%   'p_eps'      P-values below P_EPS are considered equal to P_EPS.  This
%                is used with log weighting to avoid taking the logarithm
%                of very small P-values.  The default is 1e-10.
%   'transition_matrix'   A matrix (T) describing the interaction between
%                conditions.  If T(i,j) = k, then the kth column in
%                FOLD_CHANGE describes the change in expression between
%                condition i to condition j.  If not given, FOLD_CHANGE
%                assumes 1 -> 2, 2 -> 3, ..., n-1 -> n.
%   'remove_rev' Remove reversibility constraints from the model before
%                converting to a MIP.  May improve performance if activity
%                cycles are not a concern.  (Default = false)
%   'theoretical_match'  Calculate the theoretical matches possible and
%                adjust the match statistics.  (Default = true)
%   'log_fold_change'  If true, onsider FOLD_CHANGE to be log fold change.
%                (Default = false)
%   'return_models'  If true, the models for each condition are returned.
%                (Default = true)
%   'verbose'    If true (default), a results table is printed.  Otherwise,
%                MADE is silent.
%   'set_IntFeasTol'  A reduced value for the IntFeasTol solver parameter
%                to avoid "integrality leaks" that return models with zero
%                objective flux.  The default value is 1e-10.  If false,
%                the parameter is not adjusted.  All solver parameters are
%                reset to previous values before the function returns.
%   'weight_thresh'  Threshold for weights on variables to be held
%                constant.  MADE only attempts to keep variables constant
%                if the weight from the P-value is above this value.
%                (Default = 1e-8.)
%   'verify'     If true (default), MADE checks that the generated models
%                are feasible for the objective flux fraction.
%   'round_states'  If true (default), binary variables in GENE_STATES are
%                rounded.
%
%   Output is a solution structure with the following fields:
%   output      Solution structure with details from the MILP solver.
%   gene_states Binary expression states calculated by MADE.  Columns
%               correspond to conditions, rows are genes in both
%               the model and the expression data.
%   opt_states  Optimal binary expression states.  If no growth constraint
%               was enforced, these would be the same as 'gene_states'.
%   genes       Cell of gene names corresponding to the rows in
%               'gene_states'.
%   models      Cell of TIGER model structures with bounds set to
%               the results of applying 'gene_states' expression levels.
%   condition   Cell array of structures with fields:
%                   max_obj_flux  Maximum objective fluxes for each
%                                 condition.
%                   adj_obj_flux  Adjusted objective fluxes after applying
%                                 expression data.
%                   flux_ratio    Ratio between adjusted and maximum
%                                 objective fluxes.
%   transition  Cell array of structures with fields:
%                   increasing, increasing_matched
%                       Number of gene increasing in transation, and the
%                       number that were matched.
%                   decreasing, decreasing_matched
%                       Number of decresing genes.
%                   constant, constant_matched
%                       Number of genes with constant expression.
%   D_data      Differences in expression in the expression data.  '1'
%               indicates a significant increase, '-1' is a significant
%               decrease in expression, and '0' is no significant change.
%   D_matched   Same as for 'D_data', but for the gene states returned by
%               MADE.
%   D_optimal   Same as for 'D_data', but for the optimal gene alignment.
%   total_transitions   Total number of transitions (number of genes times
%                       the number of transitions.
%   matched             Total number of transitions matched by MADE.
%   theoretical_matches Total number of matches in the optimal alignment.
%   match_percent           'matched' / 'total_transitions' * 100
%   adjusted_match_percent  'matched' / 'theoretical_matches' * 100
%   verified    Logical array indicating if the model for each condition
%               can carry the minimum objective flux.
%   variables   Cell array of the solution vectors for each model.

% TODO  don't compute theoretical matches when opt_match is off

% parse input param/value pairs
p = inputParser;

p.addParamValue('gene_names',[]);

p.addParamValue('obj_frac',0.3);

valid_weights = {'log','linear','unit','none'};
p.addParamValue('weighting','log',@(x) ismember(x,valid_weights));

p.addParamValue('bounds',[]);
p.addParamValue('objs',[]);

pvalidate = @(x) validateattributes(x,{'numeric'}, ...
                                    {'scalar','real','positive','<=',1});
p.addParamValue('p_thresh',0.5,pvalidate);
p.addParamValue('p_eps',1e-10,pvalidate);

p.addParamValue('transition_matrix',[]);
p.addParamValue('remove_rev',false);
p.addParamValue('theoretical_match',true);
p.addParamValue('log_fold_change',false);
p.addParamValue('return_models',true);
p.addParamValue('set_IntFeasTol',1e-10);
p.addParamValue('weight_thresh',1e-8);
p.addParamValue('verify',true);
p.addParamValue('round_states',true);

p.addParamValue('verbose',true);

p.parse(varargin{:});

verbose = p.Results.verbose;

% test inputs
assert(nargin >= 2, 'MADE requires at least three inputs.');

% check if p-values were given
if isempty(pvals)
    if verbose
        fprintf('No P-values given; applying unit weighting.\n');
    end
    pvals = ones(size(fold_change));
    p.Results.weighting = 'none';
else
    assert(all(size(pvals) == size(fold_change)), ...
       'FOLD_CHANGE and PVALS must have the same dimensions');
end

% find the number of transitions and conditions
ntrans = size(fold_change,2);   % number of transitions
ncond  = ntrans + 1;            % number of conditions
if ~isempty(p.Results.transition_matrix)
    ntrans = max(p.Results.transition_matrix(:));
    ncond = length(p.Results.transition_matrix);
end
if verbose
    fprintf('Dataset includes %i transitions between %i conditions.\n', ...
            ntrans,ncond);
end

% ============ Construct the Models ============

% check if multiple models were given
if isa(tiger,'cell')
    assert(length(tiger) == ncond, ...
           ['Number of models (%i) does not match ' ...
            'the number of conditions (%i)'], ...
            length(tiger),ncond);
    models = tiger;
else
    % replicate the single model
    models = cell(1,ncond);
    for i = 1 : ncond
        models{i} = tiger;
    end
end

% make sure each input is an TIGER model
models = map(@assert_tiger,models);

if ~isempty(p.Results.bounds)
    bounds = p.Results.bounds;
    err_msg = sprintf(['Number of bounds (%i) must match ', ...
                       'the number of conditions (%i).'], ...
                       length(bounds),ncond);
    assert(length(bounds) == ncond,err_msg);
    for i = 1 : length(bounds)
        models{i}.lb(:) = bounds{i}.lb(:);
        models{i}.ub(:) = bounds{i}.ub(:);
    end
end

if ~isempty(p.Results.objs)
    objs = p.Results.objs;
    err_msg = sprintf(['Number of objectives (%i) must match ', ...
                       'the number of conditions (%i).'], ...
                       length(objs),ncond);
    assert(length(objs) == ncond,err_msg);
    for i = 1 : length(objs)
        models{i}.obj(:) = objs{i};
    end
end

% set frac for each condition
frac = p.Results.obj_frac;
if length(frac) == 1
    frac = repmat(frac,1,ncond);
end
assert(length(frac) == ncond);

% add growth constraints
orig_models = models;
for i = 1 : length(frac)
    models{i} = add_growth_constraint(models{i},frac(i));
end

% number of variables in each model
nvars = cellfun(@(x) size(x.A,2),models);

% find the genes to match
common_vars = models{1}.varnames;
for i = 2 : ncond
    common_vars = intersect(common_vars,models{i}.varnames);
end
genes = p.Results.gene_names;
tf = ismember(genes,common_vars);
genes = genes(tf);
fold_change = fold_change(tf,:);
pvals = pvals(tf,:);
gene_locs = cell(1,ncond);  % gene locations in the tiled model
for i = 1 : ncond
    [~,gene_locs{i}] = ismember(genes,models{i}.varnames);
end
unshifted_locs = gene_locs;
offsets = cumsum(nvars);
for i = 2 : ncond
    gene_locs{i} = gene_locs{i} + offsets(i-1);
end
ngenes = length(genes);
if verbose
    fprintf('%i of %i genes were found in every model.\n', ...
            ngenes,length(p.Results.gene_names));
end

% ============ Convert P-values and Fold Change ============

p_thresh = p.Results.p_thresh;
p_eps = p.Results.p_eps;
weight_thresh = p.Results.weight_thresh;

if strcmpi(p.Results.weighting,'none')
    % fold_change is a direction matrix, pvals are weights
    d = fold_change;
    w = pvals;
else
    d = zeros(ngenes,ntrans);
    P = pvals;

    if p.Results.log_fold_change
        % correct for log fold change
        fold_change = fold_change + 1;
    end
    
    p_lower = p_thresh;
    p_upper = 1 - p_thresh;
    
    % convert significant fold changes to differences
    d(fold_change <  1.0 & pvals <= p_lower) = -1;
    d(fold_change >= 1.0 & pvals <= p_lower) =  1;

    % shift p-values above (1 - p_thresh) onto [0, 1-p_thresh]
    P(pvals >= p_upper) = 1 - pvals(pvals >= p_upper);

    % convert p-values to weights
    switch lower(p.Results.weighting)
        case 'log'
            P(P < p_eps) = p_eps;  % avoid taking log of zero
            w = -log(P);
        case 'linear'
            w = 1 - P;
        case 'unit'
            w = ones(size(P));
    end
    
    % remove weightings not within significance threshold
    w(pvals > p_lower & pvals < p_upper) = 0;
end


T = check_transition_matrix(p.Results.transition_matrix,ncond,ntrans);

% determine theoretical matches
opt_states = [];
if p.Results.theoretical_match
    if verbose, fprintf('Finding optimal matches...'); end
    opt_states = zeros(ngenes,ncond);
    opt_matched = zeros(ngenes,1);
    for i = 1 : ngenes
        [opt_states(i,:),~,opt_matched(i)] ...
            = find_optimal_states(d(i,:),T,w(i,:));
    end
    if verbose, fprintf('done\n'); end
end

mip = cmpi.tile_mip(models{:});
mip.obj(:) = 0;

n_con = count( d(:) == 0 & w(:) >= weight_thresh );
con_offset = 0;
con_idx1 = zeros(1,n_con);
con_idx2 = zeros(1,n_con);
con_objs = zeros(1,n_con);

for t = 1 : ntrans
    [cond1,cond2] = find_conditions(t,T);
    for g = 1 : ngenes
        idx1 = gene_locs{cond1}(g);
        idx2 = gene_locs{cond2}(g);
        switch d(g,t)
            case {1}
                % increasing
                mip.obj(idx1) = mip.obj(idx1) + w(g,t);
                mip.obj(idx2) = mip.obj(idx2) - w(g,t);
            case {-1}
                % decreasing
                mip.obj(idx1) = mip.obj(idx1) - w(g,t);
                mip.obj(idx2) = mip.obj(idx2) + w(g,t);
            case {0}
                % constant
                if abs(w(g,t)) >= weight_thresh
                    con_offset = con_offset + 1;
                    con_idx1(con_offset) = idx1;
                    con_idx2(con_offset) = idx2;
                    con_objs(con_offset) = w(g,t);
                end
        end
    end
end

% add the constant variables
[mip,pos_idxs,neg_idxs] = add_nonbinding_diff(mip,con_idx1,con_idx2);
mip.obj(pos_idxs) = con_objs;
mip.obj(neg_idxs) = con_objs;

% set the integer feasibility tolerance
IntFeasTol = p.Results.set_IntFeasTol;
set_IntFeasTol = isnumeric(IntFeasTol);
if set_IntFeasTol
    prev_solver_options = get_solver_options();
    set_solver_option('IntFeasTol',IntFeasTol);
end

% run MADE
mip.sense = 1;
mip_sol = cmpi.solve_mip(mip);

if isempty(mip_sol.x)
    fprintf('Error:  The model was infeasible.\n\n');
    sol = mip_sol;
    return
end

% ============ Process the results into states ============

states = zeros(ngenes,ncond);
for c = 1 : ncond
    for g = 1 : ngenes
        states(g,c) = mip_sol.x(gene_locs{c}(g));
        
        if p.Results.round_states
            if mip.vartypes(gene_locs{c}(g)) == 'b'
                states(g,c) = round(states(g,c));
            end
        end
    end
end

% create the models
models = orig_models;
for i = 1 : ncond
    % fix the gene states
    models{i}.ub(unshifted_locs{i}) = states(:,i);
    models{i}.lb(unshifted_locs{i}) = states(:,i);
end

if p.Results.verify
    sol.adj_vals = zeros(1,ncond);
    sol.obj_vals = zeros(1,ncond);
    
    for i = 1 : ncond
        fba_sol = fba(orig_models{i});
        if ~isempty(fba_sol.x)
            sol.obj_vals(i) = fba_sol.val;
        end
        ko_sol = fba(models{i});
        if ~isempty(ko_sol.x)
            sol.adj_vals(i) = ko_sol.val;
        end
    end
    sol.verified = sol.adj_vals ./ sol.obj_vals >= frac(:)';
end
    
% ============ Create the solution structure ============

sol.output = mip_sol;

sol.genes = genes;
sol.gene_states = states;
sol.opt_states = opt_states;

sol.condition = cell(1,ncond);
for i = 1 : ncond
    sol.condition{i}.max_obj_flux = sol.obj_vals(i);
    sol.condition{i}.adj_obj_flux = sol.adj_vals(i);
    sol.condition{i}.flux_ratio = sol.adj_vals(i) / sol.obj_vals(i);
end

D = zeros(size(d));
if p.Results.theoretical_match
    Dopt = zeros(size(d));
end
sol.transition = cell(1,ntrans);
for i = 1 : ntrans
    t = struct();
    [t.condition1,t.condition2] = find_conditions(i,T);
    D(:,i) = round(states(:,t.condition2) - states(:,t.condition1));
    if p.Results.theoretical_match
        Dopt(:,i) = opt_states(:,t.condition2) ...
                        - opt_states(:,t.condition1);
    end
    
    t.increasing = count( d(:,i) == 1 );
    t.increasing_matched = count( d(:,i) == 1 & D(:,i) == 1 );
    
    t.decreasing = count( d(:,i) == -1 );
    t.decreasing_matched = count( d(:,i) == -1 & D(:,i) == -1 );
    
    t.constant = count( d(:,i) == 0 );
    t.constant_matched = count( d(:,i) == 0 & D(:,i) == 0 );

    sol.transition{i} = t;
end
    
sol.D_data = d;
sol.D_matched = D;
if p.Results.theoretical_match
    sol.D_optimal = Dopt;
end

sol.total_transitions = numel(d);
sol.matches = count(D(:) - d(:) == 0);
sol.match_percent = sol.matches / sol.total_transitions * 100;

if p.Results.theoretical_match
    sol.theoretical_matches = count(Dopt(:) - d(:) == 0);
    sol.adjusted_match_percent = sol.matches / sol.theoretical_matches ...
                                    * 100;
end

if p.Results.return_models
    sol.models = models;
end

% return the solution vectors for each model
sol.variables = cell(1,ncond);
for i = 1 : ncond
    sol.variables{i} = mip_sol.x((1:nvars(i))+offsets(i)-nvars(i));
end

if verbose
    show_made_results(sol);
end

% reset the solver options
if set_IntFeasTol
    set_solver_option(prev_solver_options);
end


% =============================================
% ============ Accessory Functions ============
% =============================================

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
