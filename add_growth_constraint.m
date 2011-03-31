function [tiger,sol] = add_growth_constraint(tiger,val,varargin)
% ADD_GROWTH_CONSTRAINT  Add minimum growth constraint to a model.
%
%   [TIGER] = ADD_GROWTH_CONSTRAINT(TIGER,VAL,...params...)
%
%   Adds a constraint that requires a minimum flux through the objective
%   reaction.
%
%   Inputs
%   TIGER   TIGER model structure.
%   VAL     Constraining value (see the 'valtype' parameter for details).
%
%   Outputs
%   TIGER   TIGER model with growth constraint added.
%   SOL     CMPI solution object from the FBA calculation.
%
%   Parameters
%   'ctype'     Character indicating the type of constraint to add:
%                   '>'  -->  v_obj >= VAL  (default)
%                   '='  -->  v_obj  = VAL
%   'valtype'   If set to 'frac' (default), the argument VAL is a fraction
%               of maximum objective flux that must be acheived.  FBA is
%               run to determine the maximum value.  If set to 'abs', the
%               argument VAL is interpreted as an actual flux value to be
%               acheived.

if nargin < 2
    error('two inputs required');
end

p = inputParser;
p.addParamValue('ctype','>');
p.addParamValue('valtype','frac');
p.parse(varargin{:});

switch p.Results.valtype
    case 'frac'
        sol = fba(tiger);
%         if sol.val > 1e-8
%             warning('FBA objective near zero.');
%         end
        value = val*sol.val;
    case 'abs'
        value = val;
end

tiger = add_row(tiger,1);

tiger.A(end,:) = tiger.obj';
tiger.b(end) = value;
tiger.ctypes(end) = p.Results.ctype;
tiger.rownames{end} = 'GROWTH';

