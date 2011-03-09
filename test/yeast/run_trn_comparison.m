
load ind750.mat
%changeCobraSolver('gurobi');

is_ex_f = @(x) length(x) >= 3 && strcmp(x(1:3),'EX_');
is_ex = cellfun(is_ex_f,cobra.rxns);

minimal_mets = {'h2o(e)','nh4(e)','o2(e)','pi(e)','so4(e)'};
minimal_idxs = [    436,     456,     458,   466,     476 ];

carbon_sources = {'glc','gal','fruc','man','sucr','etoh','glyc','lac','pyr','rib','succ'};
carbon_idxs    = [  428   425    423   451    481    420    432   446   470   471    480];

ko_genes = {'ADR1','CAT8','GAL4','GCR2','MIG2','MTH1','NRG1','RGT1','SIP4'};

%   WT  adr1  cat8  gal4  gcr2  mig1  mig2  mth1  nrg1  rgt1  sip4 
growth_rates = ...
[ 0.21  0.21  0.21  0.21  0.17  0.21  0.20  0.21  0.21  0.21  0.21; ... % glu
  0.13  0.13  0.13  0.03  0.14  0.12  0.13  0.11  0.14  0.08  0.13; ... % gal
  0.20  0.20  0.20  0.20  0.16  0.20  0.20  0.21  0.20  0.20  0.20; ... % fruc
  0.20  0.20  0.20  0.19  0.17  0.17  0.19  0.20  0.19  0.18  0.19; ... % man
  0.21  0.21  0.20  0.19  0.16  0.20  0.20  0.21  0.20  0.19  0.20; ... % sucr
  0.02  0.03  0.01  0.04  0.03  0.02  0.03  0.04  0.04  0.01  0.03; ... % etoh
  0.02  0.03  0.01  0.04  0.03  0.03  0.03  0.03  0.03  0.01  0.02; ... % glyc
  0.03  0.05  0.01  0.05  0.01  0.03  0.05  0.05  0.04  0.02  0.05; ... % lac
  0.04  0.05  0.01  0.06  0.04  0.05  0.05  0.04  0.04  0.04  0.05; ... % pyr
  0.03  0.03  0.01  0.03  0.03  0.02  0.03  0.03  0.03  0.01  0.03; ... % rib
  0.03  0.04  0.01  0.04  0.04  0.04  0.04  0.04  0.03  0.04  0.04  ];  % succ

uptake_rates = zeros(size(carbon_idxs));

obj = find(cobra.c);
m = cobra;
m.S(end+1,:) = cobra.c;
m.b(end+1) = 0;
for i = 1 : length(carbon_sources)
    m.lb(is_ex) = 0;
    m.lb(minimal_idxs) = -1000;
    source = carbon_idxs(i);
    m.c(:) = 0;
    m.c(source) = 1;
    m.lb(source) = -100;
    m.b(end) = growth_rates(i,1);
    sol = optimizeCbModel(m);
    if ~isempty(sol.x)
        uptake_rates(i) = sol.x(source);
    end
end



