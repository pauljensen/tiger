function [sol] = made(tiger,fold_change,pvals,varargin)
% MADE  Metabolic Adjustment by Differential Expression
%
%   [GENE_STATES,GENES,SOL,MODELS] = 
%       MADE(TIGER,FOLD_CHANGE,PVALS,...parameters...)
%
%   Integrate gene expression data with metabolic models using the MADE
%   algorithm [Jensen & Papin (2011), Bioinformatics].
%
%   Inputs
%   TIGER       TIGER model.  COBRA models will be converted to TIGER 
%               models with a warning.
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
%
%   Outputs
%   GENE_STATES Binary expression states calculated by MADE.  Columns
%               correspond to conditions, rows are genes in both
%               the model and the expression data.
%   GENES       Cell of gene names corresponding to the rows in
%               GENE_STATES.
%   SOL         Solution structure with details from the MILP solver.
%   MODELS      Cell of Cobra model structures with bounds set to
%               the results of applying GENE_STATES expression levels.

% TODO  don't compute theoretical matches when opt_match is off

% test inputs
assert(nargin >= 3, 'MADE requires at least three inputs.');

% make sure the input was an TIGER model
tiger = assert_tiger(tiger);

ntrans = size(fold_change,2);   % number of transitions
ncond  = ntrans + 1;            % number of conditions

assert(all(size(pvals) == size(fold_change)), ...
       'FOLD_CHANGE and PVALS must have the same dimensions');

% parse input param/value pairs
p = inputParser;

p.addParamValue('gene_names',tiger.genes);

p.addParamValue('obj_frac',0.3);

valid_weights = {'log','linear','unit','none'};
p.addParamValue('weighting','log',@(x) ismember(x,valid_weights));

p.addParamValue('bounds',[]);
p.addParamValue('objs',[]);

pvalidate = @(x) validateattributes(x,'numeric', ...
                                    {'scalar','real','positive','<=',1});
p.addParamValue('p_thresh',0.5,pvalidate);
p.addParamValue('p_eps',1e-10,pvalidate);

p.addParamValue('transition_matrix',[]);
p.addParamValue('remove_rev',false);
p.addParamValue('theoretical_match',true);
p.addParamValue('log_fold_change',true);
p.addParamValue('return_models',true);

p.addParamValue('verbose',true);

p.parse(varargin{:});

verbose = p.Results.verbose;

find_theor = p.Results.theoretical_match;

% find the genes to match
genes = p.Results.gene_names;
[tf,gene_locs] = ismember(genes,tiger.varnames);
genes = genes(tf);
gene_locs = gene_locs(tf);
fold_change = fold_change(tf,:);
pvals = pvals(tf,:);

ngenes = length(genes);

% set frac for each condition
frac = p.Results.obj_frac;
if length(frac) == 1
    fracs = repmat(frac,1,ncond);
end

p_thresh = p.Results.p_thresh;
p_eps = p.Results.p_eps;

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
    
    % convert significant fold changes to differences
    d(fold_change <  1.0 & pvals <= p_thresh) = -1;
    d(fold_change >= 1.0 & pvals <= p_thresh) =  1;

    % shift p-values above p_thresh onto [0, 1-p_thresh]
    P(pvals > p_thresh) = 1 - pvals(pvals > p_thresh);

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
end

bounds = p.Results.bounds;
objs = p.Results.objs;

T = check_transition_matrix(p.Results.transition_matrix,ncond,ntrans);

% determine theoretical matches
if find_theor
    if verbose, fprintf('Finding optimal matches...'); end
    opt_states = zeros(ngenes,ncond);
    opt_matched = zeros(ngenes,1);
    for i = 1 : ngenes
        [opt_states(i,:),~,opt_matched(i)] ...
            = find_optimal_states(d(i,:),T,w(i,:));
    end
    if verbose, fprintf('done\n'); end
end

% run MADE
[gene_states,diffadj_sol,diffadj_error,milps] ...
    = diffadj(tiger,gene_locs,d,w,T,bounds,objs,fracs);

if diffadj_error
    fprintf('Error:  The model was infeasible.\n\n');
    sol = diffadj_sol;
    return
end

sol.genes = genes;
sol.gene_states = gene_states;
sol.opt_states = opt_states;

sol.condition = cell(1,ncond);
for i = 1 : ncond
    sol.condition{i}.max_obj_flux = diffadj_sol.obj_vals(i);
    sol.condition{i}.adj_obj_flux = diffadj_sol.adj_vals(i);
    sol.condition{i}.flux_ratio = diffadj_sol.adj_vals(i) ...
                                      / diffadj_sol.obj_vals(i);
end

T = diffadj_sol.T;
D = zeros(size(d));
if find_theor
    Dopt = zeros(size(d));
end
sol.transition = cell(1,ntrans);
for i = 1 : ntrans
    [t.condition1,t.condition2] = find_conditions(i,T);
    D(:,i) = round(gene_states(:,t.condition2) ...
                       - gene_states(:,t.condition1));
    if find_theor
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
sol.D_optimal = Dopt;

sol.total_transitions = numel(d);
sol.matches = count(D(:) - d(:) == 0);
sol.theoretical_matches = count(Dopt(:) - d(:) == 0);
sol.match_percent = sol.matches / sol.total_transitions * 100;
sol.adjusted_match_percent = sol.matches / sol.theoretical_matches * 100;

if p.Results.return_models
    sol.models = milps;
end
sol.verified = diffadj_sol.verified;

if verbose
    show_made_results(sol);
end



