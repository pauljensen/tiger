function [genes,sol] = minimal_genome(tiger,varargin)
% MINIMAL_GENOME  Calculate a minimal genome
%
%   [GENES,SOL] = MINIMAL_GENOME(TIGER,...params...)
%
%   Computes GENES, a list of the minimum number of genes (in TIGER.genes)
%   that are necessary for a functioning model.  The "params" are passed
%   to ADD_GROWTH_CONSTRAINT to define the conditions for functionality.
%
%   SOL is the solution structure from CMPI.

tiger = add_growth_constraint(tiger,varargin{:});

tiger.obj(:) = 0;
tiger = set_fieldval(tiger,'obj',tiger.genes,-1);
sol = fba(tiger);
idx = convert_ids(tiger.varnames,tiger.genes,'index');
if ~isempty(sol.x)
    genes = tiger.genes(logical(round(sol.x(idx))));
else
    genes = [];
end

