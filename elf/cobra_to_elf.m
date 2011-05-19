function [elf] = cobra_to_elf(cobra)

make_gene_inds = false;

elf = cobra_to_tiger(cobra,false);
genes = elf.genes;
ngenes = length(genes);

elf = add_row(elf,[],'=',0,genes);
nmets = size(elf.A,1);
elf = make_irreversible_rxns(elf);
nrxns = size(elf.A,2);

act_bound = max(max(abs(elf.lb),abs(elf.ub)));

% define gene activities
elf = add_column(elf,genes,'c',0,act_bound);
elf.A(size(cobra.S,1)+(1:ngenes),end-ngenes+1:end) = eye(ngenes);

% define binary gene indicators
if make_gene_inds
    elf.indof = @(x) ['I_' x];
    gene_inds = map(elf.indof,genes);
    elf = add_column(elf,gene_inds,'b');
    elf = bind_var(elf,genes,gene_inds);
end
    
% at this point, only irreversible reactions have GPRs

gpr = elf.gpr;
for i = 1 : nrxns
    if isempty(gpr{i})
        continue;
    end
    
    e = parse_string(gpr{i});
    ands = make_dnf(e,true);
    if length(ands) == 1
        add_reactants(ands{1},i);
    else
        N = length(ands);
        n = size(elf.A,2);
        rgb_names = array2names(['RGB(%i)_' elf.varnames{i}],1:N);
        elf = add_column(elf,rgb_names,'c',0,act_bound);
        for j = 1 : N
            elf.A(1:nmets,n+j) = elf.A(1:nmets,i);
            add_reactants(ands{j},n+j);
        end
        elf.A(1:nmets,i) = 0;
        elf = add_row(elf,[],'=',0,['SUM_RGB_' elf.varnames{i}]);
        elf.A(end,i) = -1;
        elf.A(end,n+1:n+j) = 1;
    end
end

function add_reactants(names,rxn_idx)
    [~,locs] = ismember(names,elf.rownames);
    elf.A(locs,rxn_idx) = -1;
end

end
     

function [tiger] = make_irreversible_rxns(tiger)
    if ~isfield(tiger,'rev')
        rev = tiger.lb < 0;
    else
        rev = tiger.rev;
    end
    
    n = size(tiger.A,2);
    for i = 1 : n
        if rev(i)
            % add forward and reverse reactions
            f = size(tiger.A,2) + 1;
            r = f + 1;
            tiger = add_column(tiger, ...
                               [tiger.varnames{i} '__f'], ...
                               'c',0,tiger.ub(i));
            tiger.A(:,f) = tiger.A(:,i);
            tiger = add_column(tiger, ...
                               [tiger.varnames{i} '__r'], ...
                               'c',0,-tiger.lb(i));
            tiger.A(:,r) = -tiger.A(:,i);
            
            % move the GPR onto the new reactions
            tiger.gpr{f} = tiger.gpr{i};
            tiger.gpr{r} = tiger.gpr{i};
            tiger.gpr{i} = '';
            
            % sum the forward and reverse rxns into the original
            tiger.A(:,i) = 0;
            tiger = add_row(tiger,[],'=',0,['SUM_FR_' tiger.varnames{i}]);
            tiger.A(end,[i f r]) = [-1 1 -1];
            
            % add indicator to avoid flux loops
            f_ind = f + 2;
            r_ind = f + 3;
            ind_names = {[tiger.varnames{i} '_FOR_IND'], ...
                         [tiger.varnames{i} '_REV_IND']};
            tiger = add_column(tiger,ind_names);
            tiger = add_row(tiger,[],'<<=',[],'ELF_REV_CON%i');
            tiger.A(end-2,[f f_ind]) = [1 -tiger.ub(f)];
            tiger.A(end-1,[r r_ind]) = [1 -tiger.ub(r)];
            tiger.A(end,[f_ind r_ind]) = [1 1];
            tiger.b(end) = 1;
            
            % hack TODO: move indicators to end of reaction list
            tiger.gpr{f_ind} = '';
            tiger.gpr{r_ind} = '';
        end
    end
end

            