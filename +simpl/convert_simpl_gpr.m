function tiger = convert_simpl_gpr(tiger,varargin)

import simpl.*

% begin parameter checking
p = inputParser;

p.addParamValue('ind_prefix','I',@ischar);
ind_width_val = @(x) validateattributes(x,{'numeric'}, ...
                                        {'scalar','integer','<=',1});
p.addParamValue('ind_width',4,ind_width_val);

bound_val = @(x) validateattributes(x,{'numeric'},{'scalar','real'});
p.addParamValue('default_lb',0,bound_val);
p.addParamValue('default_ub',1,bound_val);

p.addParamValue('bounds',[]);

p.parse(varargin{:});

IND_PRE = p.Results.ind_prefix;
IND_WIDTH = p.Results.ind_width;  % number of digits for indicator names
ind_counter = tiger.param.ind;

COMPACT = true;

default_lb = p.Results.default_lb;
default_ub = p.Results.default_ub;

nrxns = length(tiger.rxns);
parsed(nrxns) = struct('op',[]);
% convert string rules to junctions
rxn_idx_names = map(@(x) ['RXN__' x], tiger.rxns);
x = Variable(tiger.genes);
for i = 1 : nrxns
    if isempty(tiger.rules{i})
        rxn_idx_names{i} = '';
        continue;
    end
    
    rule = eval(tiger.rules{i});
    if isa(rule,'simpl.Variable')
        rxn_idx_names{i} = rule.id;
    else
        parsed(i).lhs = rxn_idx_names{i};
        parsed(i).rhs = rule;
        parsed(i).op = '=>';
    end
end

isnull = @(s) isempty(s.op);
parsed = parsed(~arrayfun(isnull,parsed));
i = 0;
while i < length(parsed)
    i = i + 1;
    if isa(parsed(i).rhs,'simpl.Variable')
        continue
    end
    for j = 1 : length(parsed(i).rhs.operands)
        if ~isa(parsed(i).rhs.operands{j},'simpl.Variable')
            ind = get_next_ind_name();
            s.lhs = ind;
            s.rhs = parsed(i).rhs.operands{j};
            s.op = '=>';  % TODO: change this for tight bounds
            parsed(i).rhs.operands{j} = Variable(ind);
            parsed(end+1) = s;
        end
    end
end

ineqs = arrayfun(@simple_rule_to_ineqs,parsed,'Uniform',false);
ineqs = cell2mat(ineqs);

tiger = add_inequalities(tiger,ineqs);
tiger = add_column(tiger,setdiff(rxn_idx_names,tiger.varnames),'b');
to_bind = ~cellfun(@isempty,rxn_idx_names);
tiger = bind_var(tiger,tiger.rxns(to_bind),rxn_idx_names(to_bind));

function [ind_name] = get_next_ind_name()
    % Get the next indicator name
    ind_counter = ind_counter + 1;
    tiger.param.ind = ind_counter;
    ind_name = sprintf([IND_PRE '%0*i'], IND_WIDTH, ind_counter);
end

function ineqs = simple_rule_to_ineqs(rule)
%  Or Junctions
%  ------------
%  1a. x1 | x2 | ... | xk =>  I   --> I >= 1/k*sum(x)
%  1b. x1 | x2 | ... | xk =>  I   --> I >= xi forall x
%  2.  I =>  x1 | x2 | ... | xk   --> I <= sum(x)
%  3.  x1 | x2 | ... | xk <=> I   --> (1a | 1b) & (2)
%
%  And Junctions
%  -------------
%  4.  x1 & x2 & ... & xk =>  I   --> sum(x) <= I + k - 1
%  5a. I =>  x1 & x2 & ... & xk   --> I <= 1/k*sum(x)
%  5b. I =>  x1 & x2 & ... & xk   --> I <= xi forall x
%  6.  x1 & x2 & ... & xk <=> I   --> (4) & (5a | 5b)

if strcmp(rule.op,'<=>')
    rule1 = rule;
    rule1.op = '=>';
    rule2 = rule1;
    rule2.lhs = rule.rhs;
    rule2.rhs = rule.lhs;
    ineqs = [simple_rule_to_ineqs(rule1) simple_rule_to_ineqs(rule2)];
    return
end

get_vars = @(junc) cellfun(@(x) x.id,junc.operands,'Uniform',false);

if isa(rule.lhs,'simpl.Junction')
    vars = get_vars(rule.lhs);
    k = length(vars);
    I = rule.rhs;
    if isOr(rule.lhs) && COMPACT
        % ... | ... => I --> I >= 1/k*sum(x)
        ineqs.vars = [{I} vars];
        ineqs.coeffs = [1 repmat(-1/k,1,k)];
        ineqs.op = '>';
        ineqs.rhs = 0;
    elseif isOr(rule.lhs) && ~COMPACT
        % ... | ... => I --> I >= xi forall x
        ineqs(k) = struct();
        for ii = 1 : k
            ineqs(ii).vars = {I, vars{ii}};
            ineqs(ii).coeffs = [1 -1];
            ineqs(ii).op = '>';
            ineqs.rhs = 0;
        end
    elseif isAnd(rule.lhs)
        % ... & ... => I --> sum(x) <= I + k - 1
        ineqs.vars = [vars {I}];
        ineqs.coeffs = [ones(1,k) -1];
        ineqs.op = '<';
        ineqs.rhs = k - 1;
    end
elseif isa(rule.rhs,'simpl.Junction')
    vars = get_vars(rule.rhs);
    k = length(vars);
    I = rule.lhs;
    if isOr(rule.rhs)
        % I => ... | ... --> I <= sum(x)
        ineqs.vars = [{I} vars];
        ineqs.coeffs = [1 -ones(1,k)];
        ineqs.op = '<';
        ineqs.rhs = 0;
    elseif isAnd(rule.rhs) && COMPACT
        % I => ... & ... --> I <= 1/k*sum(x)
        ineqs.vars = [{I} vars];
        ineqs.coeffs = [1 repmat(-1/k,1,k)];
        ineqs.op = '<';
        ineqs.rhs = 0;
    elseif isAnd(rule.rhs) && ~COMPACT
        % I => ... & ... --> I <= xi forall x
        ineqs(k) = struct();
        for ii = 1 : k
            ineqs(ii).vars = {I, vars{ii}};
            ineqs(ii).coeffs = [1 -1];
            ineqs(ii).op = '<';
            ineqs(ii).rhs = 0;
        end
    end 
end

end

end