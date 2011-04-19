function [elf] = cobra_to_elf(cobra)

elf = cobra_to_tiger(cobra,false);
elf = make_irreversible_rxns(elf);
nrxns = size(elf.A,2);

gpr = tiger.gpr;
genes = tiger.genes;
ngenes = length(genes);

act_of = @(x) ['ACT_' x];
act_names = map(act_of,genes);
act_bound = max(max(abs(tiger.lb),abs(tiger.ub)));

% define gene indicators and activities
elf = add_column(elf,genes,'b');
elf = add_column(elf,act_names,'c',0,act_bound);
elf = add_row(elf,[],'=',0,genes);
elf.A(end-ngenes+1:end,end-ngenes+1:end) = eye(ngenes);
elf = bind_var(elf,act_names,genes);

% at this point, only irreversible reactions have GPRs

for i = 1 : nrxns
    if isempty(gpr{i})
        continue;
    end
    
    e = parse_string(gpr{i});
    ands = make_dnf(e);
    if length(ands) == 1
        add_reactants(ands{1},i);
    else
        N = length(ands);
        n = size(elf.A,2);
        elf = add_column(elf,N);
        for j = 1 : N
            elf.A(:,n+j) = elf.A(i);
            add_reactants(ands{j},n+j);
        end
        elf.A(:,i) = 0;
        elf = add_row(elf,1);
        elf.A(end,i) = -1;
        elf.A(end,n+1:n+j) = 1;
    end
end
     

function make_irreversible_rxns(tiger)
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
            tiger = add_row(tiger,1);
            tiger.A(end,[i f r]) = [-1 1 -1];
            
            % add indicator to avoid flux loops
            ind_f = f + 2;
            ind_r = r + 2;
            tiger = add_column(tiger,2);
            tiger = add_row(tiger,[],'<<');
            tiger.A(end-1,[f ind_f]) = [1 -tiger.ub(f)];
            tiger.A(end  ,[r ind_r]) = [1  tiger.ub(r)];
            tiger.b(end) = tiger.ub(r);
        end
    end

            
