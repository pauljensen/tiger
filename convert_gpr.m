function [tiger] = convert_gpr(tiger,varargin)
% CONVERT_GPR  Add the GPR rules as constraints to the model.
%
%   [TIGER] = CONVERT_GPR(TIGER,...ADD_RULE params...)
%
%   Each GPR expression is converted to a rule and added to the model.
%
%   Parameters
%   'status'        If true (default = false), display progress indicators
%                   for the conversion.
%   'parse_string'  Cell of parameters to pass to PARSE_STRING.
%   'add_rule'      Cell of parameters to pass to ADD_RULE.

p = inputParser;
p.addParamValue('status',false);
p.addParamValue('parse_string',{});
p.addParamValue('add_rule',{});
p.parse(varargin{:});

parse_string_params = p.Results.parse_string;
add_rule_params = p.Results.add_rule;

status = p.Results.status;

tiger = assert_tiger(tiger);

RXN_PRE = 'RXN__';

Ngenes = length(tiger.genes);
[m,n] = size(tiger.A);

rxns  = find(~cellfun(@isempty,tiger.gpr));
Nrxns = length(rxns);

rxn_names = map(@(x) [RXN_PRE x],tiger.varnames(rxns));
gpr_rules = cellzip(@(x,y) [x ' <=> "' y '"'],tiger.gpr(rxns),rxn_names);

%tiger.obj = [tiger.obj; zeros(Nrxns+Ngenes,1)];
%tiger.A = [tiger.A sparse(m,Nrxns+Ngenes)];
%tiger.varnames = [tiger.varnames; tiger.genes; rxn_names];
%tiger.vartypes = [tiger.vartypes; repmat('b',Nrxns+Ngenes,1)];
%tiger.lb = [tiger.lb; zeros(Nrxns+Ngenes,1)];
%tiger.ub = [tiger.ub;  ones(Nrxns+Ngenes,1)];

args = {add_rule_params{:}, ...
        'parse_string',{parse_string_params{:},'status',status}, ...
        'status',status};
tiger = add_rule(tiger,gpr_rules,args{:});
tiger = bind_var(tiger,tiger.varnames(rxns),rxn_names);
