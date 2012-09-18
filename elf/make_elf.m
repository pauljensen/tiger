function [elf] = make_elf(cobra)

ADD_SUMMATION_CONS = true;

elf = cobra_to_tiger(cobra,'add_gpr',false);

genes = elf.genes;
ngenes = length(genes);

act_bound = max_abs(elf.lb,elf.ub);

elf = add_row(elf,[],'=',0,genes);
elf = add_column(elf,genes,'c',0,act_bound);
elf.gpr(end+(1:ngenes)) = array2names('',1:ngenes);
elf.A(end-ngenes+1:end,end-ngenes+1:end) = eye(ngenes);

conset = constraintset();

if isfield(elf,'rev')
    rev = elf.rev;
else
    rev = elf.ub > 0 & elf.lb < 0;
end
nrxns = size(elf.S,2);
gpr = elf.gpr;
for i = 1 : nrxns
    if isempty(gpr{i})
        continue
    end
    
    if rev(i)
        names = {sprintf('%s__FOR',elf.varnames{i}), ...
                 sprintf('%s__REV',elf.varnames{i})};
        Asub = [elf.A(:,i), -elf.A(:,i)];
        elf = add_column(elf,names,'c',0,act_bound,0,Asub);
        elf.A(:,i) = 0;
        gpr(end+(1:2)) = gpr([i i]);
        gpr{i} = '';
        if ADD_SUMMATION_CONS
            conset.add_ineq([1 -1 1],[elf.varnames(i),names],'=',0);
        end
        % bind the reversibility
        for_ind = sprintf('IND_FOR__%s',elf.varnames{i});
        rev_ind = sprintf('IND_REV__%s',elf.varnames{i});
        conset.add_not(for_ind,rev_ind);
        conset.add_bound(names{1},for_ind,'u');
        conset.add_bound(names{2},rev_ind,'u');
    end
end

nrxns = size(elf.A,2);
for i = 1 : nrxns
    if isempty(gpr{i})
        continue
    end
    
    ands = make_dnf2(parse_string(gpr{i}));
    if length(ands) == 1
        % put the gpr in place
        idxs = gene_idxs(ands{1});
        elf.A(idxs,i) = -1;
    else
        % create the RGBs
        Nands = length(ands);
        currN = size(elf.A,2);
        rgb_names = array2names([elf.varnames{i} '__RGB[%i]'],1:Nands);
        elf = add_column(elf,rgb_names,'c',0,act_bound,0, ...
                             repmat(elf.A(:,i),1,Nands));
        elf.A(:,i) = 0;
        for j = 1 : Nands
            elf.A(gene_idxs(ands{j}),currN+j) = -1;
        end
        conset.add_ineq([-1 ones(1,Nands)],[i currN+(1:Nands)],'=',0);
    end
end

elf = conset.compile(elf);

function [idxs] = gene_idxs(names)
    [~,idxs] = ismember(names,genes);
    idxs = idxs + size(elf.S,1);
end

end
    
