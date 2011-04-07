function [gene_levels,genes,sol,tiger] = imat(model,levels,varargin)
% IMAT  Integrative Metabolic Analysis Tool
%
%   [GENE_LEVELS,GENES,SOL,TIGER] = IMAT(MODEL,LEVELS,...parameters...)
%
%   Integrate expression levels with a metabolic model using a modified
%   iMAT algorithm [Shlomi, et al. (2008), Nat Biotechnol].  This
%   implementation uses expression levels for each gene rather than each
%   reaction.
%
%   LEVELS classifies each gene as either lowly (0), normally (1), or
%   highly (2) expressed.  If a reaction flux 'v' has bounds
%   lb <= v <= ub, then
%
%       LEVELS(i) = 0 --> -eps <= v_i <= eps
%       LEVELS(i) = 1 -->   lb <= v_i <= ub
%       LEVELS(i) = 2 --> v_i <= -eps OR v_i >= eps
%
%   Inputs
%   MODEL   TIGER or COBRA model.  If a TIGER model is given, a COBRA
%           model is extracted and re-converted to a TIGER model with
%           multilevel GPRs.
%   LEVELS  Expression state (0, 1, or 2) for each gene.
%
%   Parameters
%   'gene_names'  Cell array of names for genes in LEVELS.  If not given,
%                 the default is TIGER.genes.
%   'obj_frac'    Fraction of metabolic objective required in the 
%                 resulting model (v_obj >= frac*v_obj_max). 
%                 Default is 0.
%   'flux_eps'    Small flux value used as 'eps' in the above constraints.
%                 Default = 1e-3.
%   'weights'     Optional weighting for each gene.  The penalty for each
%                 gene is  WEIGHTS(i)*|GENES(i) - LEVELS(i)|.
%                 Default is 1 for all genes.
%
%   Outputs
%   GENE_LEVELS  Expression levels returned by IMAT.
%   GENES        Cell of gene names corresponding to GENE_LEVELS.
%   SOL          Solution structure with details from the MILP solver.
%   TIGER        TIGER model with GENE_LEVELS applied.

p = inputParser;
p.addParamValue('gene_names',model.genes);
p.addParamValue('obj_frac',0);
p.addParamValue('flux_eps',1e-3);
p.addParamValue('weights',1);
p.parse(varargin{:});

genes = p.Results.gene_names;
frac = p.Results.obj_frac;
flux_eps = p.Results.flux_eps;
weights = p.Results.weights;

RXN_PRE = 'RXN__';

model = extract_cobra(model);
tiger = cobra_to_tiger(model,true,'default_ub',2);

if frac > 0
    tiger = add_growth_constraint(tiger,frac);
end

rxn_inds = find_like(['^' RXN_PRE],tiger.varnames);
rxn_names = map(@(x) x(length(RXN_PRE)+1:end),rxn_inds);

cons = cellzip(@make_cons,rxn_inds,rxn_names);
tiger = add_rule(tiger,[cons{:}]);
   
[tiger,valnames] = add_column(tiger,[],'i',levels,levels);
[tiger,diffvars] = add_diff(tiger,genes,valnames);

tiger = set_fieldval(tiger,'obj',diffvars,weights);
sol = cmpi.solve_mip(tiger);
if cmpi.is_acceptable_exit(sol)
    gene_levels = sol.x(convert_ids(tiger.varnames,genes,'index'));
    tiger = set_var(tiger,genes,gene_levels);
else
    gene_levels = [];
end


function [cons] = make_cons(ind,rxn)
    cons = cell(1,2);
    cons{1} = sprintf('%s < 1 <=> (%s >= %f) & (%s <= %f)', ...
                      ind,rxn,-flux_eps,rxn,flux_eps);
    cons{2} = sprintf('%s > 1 <=> (%s <= %f) | (%s >= %f)', ...
                      ind,rxn,-flux_eps,rxn,flux_eps);
end

end
