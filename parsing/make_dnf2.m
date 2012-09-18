function [and_lists] = make_dnf2(ex)

and_lists = dnf(group_ops(ex,true));


function [ands] = dnf(e)
    if ~has_or(e)
        ands = {get_atoms(e)};
        return
    end

    e.exprs = map(@dnf,e.exprs);
    
    if is_or(e)
        ands = flatten(e.exprs);
    else
        % e is an 'and'
        [ands,~,tf] = cellfilter(@(x) length(x) == 1,e.exprs);
        split_by = e.exprs(~tf);
        if isempty(ands)
            ands = split_by(1);
            if length(split_by) == 1
                return
            else
                split_by = split_by(2:end);
            end
        end
        ands = {flatten(ands,2)};
        for i = 1 : length(split_by)
            n = length(split_by{i});
            new_ands = cell(1,n*length(ands));
            for k = 1 : length(ands)
                for j = 1 : n
                    new_ands{j+n*(k-1)} = [ands{k},split_by{i}{j}];
                end
            end
            ands = new_ands;
        end
    end
    

function [tf] = has_or(ex)
    tf = true;
    if is_or(ex)
        return
    elseif isempty(ex.exprs)
        tf = false;
    else
        for i = 1 : length(ex.exprs)
            if has_or(ex.exprs{i})
                return
            end
        end
        tf = false;
    end
    
