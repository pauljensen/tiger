function [cobra] = extract_cobra(tiger)
% EXTRACT_COBRA  Extract the original COBRA model from a TIGER structure.
%
%   [COBRA] = EXTRACT_COBRA(TIGER)
%
%   Returns the original COBRA model structure from a TIGER model.

tiger_fields = {'A','obj','ctypes','vartypes','gpr','ind','indtypes', ...
                'varnames','rownames','param'};

to_remove = tiger_fields(isfield(tiger,tiger_fields));
cobra = rmfield(tiger,to_remove);

[m,n] = size(cobra.S);
cobra.b = cobra.b(1:m);
cobra.lb = cobra.lb(1:n);
cobra.ub = cobra.ub(1:n);

if ~isfield(cobra,'c')
    cobra.c = tiger.obj(1:n);
end
