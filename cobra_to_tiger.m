function [tiger] = cobra_to_tiger(cobra,varargin)
% COBRA_TO_TIGER  Convert a COBRA model to a TIGER model
%
%   [TIGER] = COBRA_TO_TIGER(COBRA,...params...)
%
%   Convert a COBRA model structure to a TIGER model structure.
%
%   Parameters
%   'add_gpr'       If true (default), the GPR is converted into a set of
%                   inequalities and added as constraints.
%   'fast_gpr'      If true, use the 'fast GPR' conversion method (default
%                   is false)
%
%   Parameters (passed to CONVERT_GPR)
%   'status'        If true (default = false), display progress indicators
%                   for the conversion.
%   'parse_string'  Cell of parameters to pass to PARSE_STRING.
%   'add_rule'      Cell of parameters to pass to ADD_RULE.

p = inputParser;
p.addParamValue('add_gpr',true);
p.addParamValue('fast_gpr',false);
p.KeepUnmatched = true;
p.parse(varargin{:});
convert_gpr_params = struct2list(p.Unmatched);

add_gpr = p.Results.add_gpr;
fast_gpr = p.Results.fast_gpr;
if fast_gpr
    add_gpr = false;
end

tiger = rmfield(cobra,'c');

% get default params
empty_tiger = create_empty_tiger();
tiger.param = empty_tiger.param;
tiger.bounds = empty_tiger.bounds;

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

% some Cobra models do not have the RHS vector b; add it
if ~isfield(tiger,'b')
    tiger.b = zeros(size(m,1));
end

tiger.obj = cobra.c(:);
tiger.ctypes = repmat('=',m,1);
tiger.vartypes = repmat('c',n,1);

tiger.gpr = cobra.grRules(:);
tiger.genes = cobra.genes(:);

tiger.ind = zeros(m,1);
tiger.indtypes = repmat(' ',m,1);

if add_gpr
    % reset bounds
    orig_N = size(cobra.S,2);
    orig_lb = tiger.lb;
    orig_ub = tiger.ub;

    tiger.lb(:) = min(tiger.lb);
    tiger.ub(:) = max(tiger.ub);

    if isa(add_gpr,'char') && strcmp(add_gpr,'v1.3')
        tiger = convert_gpr(tiger,convert_gpr_params{:});
    else
        tiger = convert_simpl_gpr(tiger,convert_gpr_params{:});
    end

    tiger.lb(1:orig_N) = orig_lb;
    tiger.ub(1:orig_N) = orig_ub;
end

if fast_gpr
    for i = 1 : size(tiger.S,2)
        if tiger.gpr{i}
            tiger = add_fast_gpr(tiger,parse_string(tiger.gpr{i}),i);
        end
    end
end


    
