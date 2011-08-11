function [tiger] = cobra_to_tiger(cobra,varargin)
% COBRA_TO_TIGER  Convert a COBRA model to a TIGER model
%
%   [TIGER] = COBRA_TO_TIGER(COBRA,CONVERT_GPR,...ADD_RULE params...)
%
%   Convert a COBRA model structure to a TIGER model structure.
%
%   Params (passed to CONVERT_GPR)
%   'status'        If true (default = false), display progress indicators
%                   for the conversion.
%   'parse_string'  Cell of parameters to pass to PARSE_STRING.
%   'add_rule'      Cell of parameters to pass to ADD_RULE.

tiger = rmfield(cobra,'c');

% get default params
empty_tiger = create_empty_tiger();
tiger.param = empty_tiger.param;

[m,n] = size(tiger.S);

if isfield(cobra,'rxns')
    tiger.varnames = cobra.rxns(:);
else
    tiger.varnames = array2names('rxn',1:n)';
end

if isfield(cobra,'mets')
    tiger.rownames = cobra.mets(:);
else
    tiger.rownames = array2names('row',1:m)';
end

tiger.A = tiger.S;

tiger.obj = cobra.c(:);
tiger.ctypes = repmat('=',m,1);
tiger.vartypes = repmat('c',n,1);

tiger.gpr = cobra.grRules(:);
tiger.genes = cobra.genes(:);

tiger.ind = zeros(m,1);
tiger.indtypes = repmat(' ',m,1);

% add the GPR
% reset bounds
orig_N = size(cobra.S,2);
orig_lb = tiger.lb;
orig_ub = tiger.ub;

tiger.lb(:) = min(tiger.lb);
tiger.ub(:) = max(tiger.ub);

tiger = convert_gpr(tiger,varargin{:});

tiger.lb(1:orig_N) = orig_lb;
tiger.ub(1:orig_N) = orig_ub;



    
