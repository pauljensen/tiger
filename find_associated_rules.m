function [assoc] = find_associated_rules(exprs,start,max_iter)
% FIND_ASSOCIATED_RULES  Find rules associated with an atom
%
%   [ASSOC] = FIND_ASSOCIATED_RULES(EXPRS,START,MAX_ITER)
%
%   Retruns ASSOC, an array of indices for expressions EXPRS that may
%   depend on the atoms in START.
%
%   The function begins by finding all EXPRS that contain atoms in START.
%   Any other atom that appears in one of these expressions is appended to
%   START, and the process is continued for a maximum of MAX_ITER
%   iterations (by default, MAX_ITER is one larger than the number of
%   expressions in EXPRS, allowing all associated rules to be found).  If
%   MAX_ITER = 1, only expressions that contain a member of START are
%   returned.

assert(~isempty(start),'a list of starting atoms must be given');

if nargin < 3
    max_iter = length(exprs) + 1;
end

rules = exprs;
atoms = map(@(x) x.atoms,rules);

assoc = false(size(rules));

prev_count = -1;
current_imp = assert_cell(start);

curr_iter = 0;
while prev_count < count(assoc) && curr_iter < max_iter
    curr_iter = curr_iter + 1;
    
    prev_count = count(assoc);
    f = @(x) any(ismember(current_imp,x));
    to_add = cellfun(f,atoms);
    assoc = assoc | to_add;
    new_atoms = atoms(to_add);
    current_imp = [current_imp{:},new_atoms{:}];
end

assoc = find(assoc);
