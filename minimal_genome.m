function [genes,sol] = minimal_genome(tiger,varargin)

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

