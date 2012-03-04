function [tiger] = add_fast_gpr(tiger,expr,rxn)

rxn = convert_ids(tiger.varnames,rxn,'index');
expr = group_ops(expr,true);

simple_exprs = {expr};
indicators = {sprintf('RXN__%i',rxn)};

% convert the expressions to constraints
simple_exprs{1} = simplify_expr(simple_exprs{1});
all_vars = unique([flatten(map(@get_atoms,simple_exprs)) indicators]);
new_vars = setdiff(all_vars,tiger.varnames);
tiger = add_column(tiger,new_vars,'c',0,1);

n = length(simple_exprs);
if n > 1 || is_op(simple_exprs{1})
    for i = 1 : n
        e = simple_exprs{i};
        if strcmp(e.op,'or')
            add_or(e,indicators{i});
        else
            add_and(e,indicators{i});
        end
    end
else
    % do not create a reaction indicator; bind the gene directly
    indicators = {simple_exprs{1}.id};
end

% bind the GPR
tiger = add_binding(tiger,rxn,indicators{1});

% convert the genes to binary variables
gene_names = get_atoms(expr);
tiger.vartypes(convert_ids(tiger.varnames,gene_names,'index')) = 'b';


function [e] = simplify_expr(e)
    if ~is_op(e)
        return;
    end
    is_simple = cellfun(@is_atom,e.exprs);
    if ~all(is_simple)
        for j = find(~is_simple)
            e.exprs{j} = substitute(e.exprs{j});
        end
    end
    
    function [ind] = substitute(ex)
        next_idx = tiger.param.ind + 1;
        tiger.param.ind = tiger.param.ind + 1;
        ind = parse_string(sprintf('IND__%i',next_idx));
        simple_exprs{end+1} = simplify_expr(ex);
        indicators{end+1} = ind.id;
    end
end

function add_and(ex,ind)
    atoms = convert_ids(tiger.varnames,get_atoms(ex),'index');
    ind = convert_ids(tiger.varnames,ind,'index');
    n_atoms = length(atoms);
    m = size(tiger.A,1);
    tiger = add_row(tiger,n_atoms);
    for j = 1 : n_atoms
        tiger.A(m+j,[atoms(j),ind]) = [-1 1];
        tiger.ctypes(m+j) = '<';
    end
end

function add_or(ex,ind)
    atoms = convert_ids(tiger.varnames,get_atoms(ex),'index');
    ind = convert_ids(tiger.varnames,ind,'index');
    m = size(tiger.A,1);
    tiger = add_row(tiger,1);
    tiger.A(m+1,atoms) = -1;
    tiger.A(m+1,ind) = 1;
    tiger.ctypes(m+1) = '<';
end

end