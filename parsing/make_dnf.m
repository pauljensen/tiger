function [and_lists] = make_dnf(ex,names_only)
% MAKE_DNF  Make lists of atoms in the Disjunctive Normal Form
%
%   [AND_LISTS] = MAKE_DNF(EX)
%   [AND_LISTS] = MAKE_DNF(EX,NAMES_ONLY)
%
%   Splits an expression EX into a series of ATOM lists.  Each list
%   corresponds to a disjunction in the form
%       EX <=> (list1) or (list2) or (list3) or ...
%   where
%       list1 <=> AND_LISTS{1}{1} & AND_LISTS{1}{2} & ...
%
%   AND_LISTS is a cell array of ATOM cells.  If NAMES_ONLY is true
%   (default = false), then only the names of the atoms are returned, not
%   the entire ATOM object.

if nargin < 2
    names_only = false;
end

ex_list = {ex.copy};

while any(cellfun(@has_or,ex_list))
    for i = 1 : length(ex_list)
        if has_or(ex_list{i})
            ex_list{end+1} = split_by_or(ex_list{i},'right');
            ex_list{i}     = split_by_or(ex_list{i},'left');
        end
    end
end

and_lists = map(@get_atoms,ex_list);

if names_only
    and_lists = map(@(x) map(@(e) e.id,x),and_lists);
end


function [tf] = has_or(ex)
    tf = ex.is_junc ...
            && (ex.OR || has_or(ex.lexpr) || has_or(ex.rexpr));
        
function [sub_ex] = split_by_or(ex,dir)
    if ~has_or(ex)
        sub_ex = ex.copy;
    elseif ex.OR
        switch dir
            case 'left'
                sub_ex = ex.lexpr.copy;
            case 'right'
                sub_ex = ex.rexpr.copy;
        end
    else % AND
        sub_ex = ex.copy;
        if has_or(ex.lexpr)
            sub_ex.lexpr = split_by_or(ex.lexpr,dir);
        else
            sub_ex.rexpr = split_by_or(ex.rexpr,dir);
        end
    end

function [atoms] = get_atoms(ex)
    if ~ex.is_junc
        atoms = {ex.copy};
    else
        atoms = [get_atoms(ex.lexpr), get_atoms(ex.rexpr)];
    end
    