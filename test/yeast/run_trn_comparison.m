
load ind750.mat
load yeast_trn_iff.mat
changeCobraSolver('cplex');

is_ex_f = @(x) length(x) >= 3 && strcmp(x(1:3),'EX_');
ex_idxs = find(cellfun(is_ex_f,cobra.rxns));

minimal_mets = {'h2o(e)','nh4(e)','o2(e)','pi(e)','so4(e)'};
minimal_idxs = [    436,     456,     458,   466,     476 ];

%carbon_sources = {'glc','gal','fruc','man','sucr','etoh','glyc','lac','pyr','rib','succ'};
%carbon_idxs    = [  428   425    423   451    481    420    432   446   470   471    480];

carbon_sources = {'glc','gal','fruc','man','sucr','etoh','glyc','pyr','rib','succ'};
carbon_idxs    = [  428   425    423   451    481    420    432   470   471    480];

ko_names = {   'ADR1',   'CAT8',   'GAL4',   'MIG1',   'MIG2',   'MTH1',   'NRG1',   'RGT1',   'SIP4'};
ko_genes = {'YDR216W','YMR280C','YPL248C','YGL035C','YGL209W','YDR277C','YDR043C','YKL038W','YJL089W'};

%   WT  adr1  cat8  gal4  mig1  mig2  mth1  nrg1  rgt1  sip4 
growth_rates = ...
[ 0.21  0.21  0.21  0.21  0.21  0.20  0.21  0.21  0.21  0.21; ... % glu
  0.13  0.13  0.13  0.03  0.12  0.13  0.11  0.14  0.08  0.13; ... % gal
  0.20  0.20  0.20  0.20  0.20  0.20  0.21  0.20  0.20  0.20; ... % fruc
  0.20  0.20  0.20  0.19  0.17  0.19  0.20  0.19  0.18  0.19; ... % man
  0.21  0.21  0.20  0.19  0.20  0.20  0.21  0.20  0.19  0.20; ... % sucr
  0.02  0.03  0.01  0.04  0.02  0.03  0.04  0.04  0.01  0.03; ... % etoh
  0.02  0.03  0.01  0.04  0.03  0.03  0.03  0.03  0.01  0.02; ... % glyc
%  0.03  0.05  0.01  0.05  0.03  0.05  0.05  0.04  0.02  0.05; ... % lac
  0.04  0.05  0.01  0.06  0.05  0.05  0.04  0.04  0.04  0.05; ... % pyr
  0.03  0.03  0.01  0.03  0.02  0.03  0.03  0.03  0.01  0.03; ... % rib
  0.03  0.04  0.01  0.04  0.04  0.04  0.04  0.03  0.04  0.04  ];  % succ

imh805_rates = ...
[ 0.21  0.21  0.21  0.21  0.21  0.21  0.21  0.21  0.21  0.21; ...
  0.13  0.13  0.13  0.03  0.13  0.13  0.11  0.13  0.09  0.13; ...
  0.20  0.20  0.19  0.20  0.20  0.20  0.20  0.20  0.20  0.20; ...
  0.19  0.19  0.19  0.19  0.17  0.19  0.19  0.19  0.19  0.19; ...
  0.20  0.20  0.20  0.20  0.20  0.20  0.20  0.20  0.20  0.20; ...
  0.03  0.03  0.02  0.03  0.03  0.03  0.03  0.03  0.03  0.03; ...
  0.03  0.03  0.01  0.03  0.03  0.03  0.03  0.03  0.03  0.03; ...
%  0.05  0.05  0.01  0.05  0.05  0.05  0.05  0.05  0.05  0.05; ...
  0.05  0.05  0.01  0.05  0.05  0.05  0.05  0.05  0.05  0.05; ...
  0.03  0.03  0.02  0.03  0.03  0.03  0.03  0.03  0.00  0.03; ...
  0.04  0.04  0.02  0.04  0.04  0.04  0.04  0.04  0.04  0.04  ];
  

%%

uptake_rates = zeros(size(carbon_idxs));

trn_con = add_growth_constraint(trn,0,'valtype','abs','ctype','=');

for i = 1 : length(carbon_sources)
    trn_con.lb(ex_idxs) = 0;
    trn_con.lb(minimal_idxs) = -1000;
    source = carbon_idxs(i);
    trn_con.obj(:) = 0;
    trn_con.obj(source) = -1;
    trn_con.lb(source) = -100;
    trn_con.b(end) = growth_rates(i,1);
    sol = solve_tiger(trn_con);
    if ~isempty(sol.x)
        uptake_rates(i) = sol.x(source);
    end
end

%%
tiger_rates = zeros(size(growth_rates));
for carbon = 1 : length(carbon_sources)
    tiger = trn;
    tiger.lb(carbon_idxs) = 0;
    tiger.lb(carbon_idxs(carbon)) = uptake_rates(carbon);
    sol = fba(tiger);
    tiger_rates(carbon,1) = sol.val;
    for i = 1 : length(ko_genes)
        [tf,loc] = ismember(ko_genes{i},tiger.varnames);
        if tf
            disp(['knocking out ' ko_genes{i} ' in ' carbon_sources{carbon}])
            tiger.ub(loc) = 0;
            sol = fba(tiger);
            if ~isempty(sol.val)
                tiger_rates(carbon,1+i) = sol.val;
            end
        else
            tiger_rates(carbon,1+i) = -1;
        end
    end
end

%%

imh805_error = abs(growth_rates - imh805_rates) ./ growth_rates;
tiger_error  = abs(growth_rates - tiger_rates) ./ growth_rates;

sum(imh805_error(:).^2)
sum(tiger_error(:).^2)

length(find(imh805_error(:) > 1e-5))
length(find(tiger_error(:) > 1e-5))

imh805_error - tiger_error

