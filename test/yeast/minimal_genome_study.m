
cmpi.init();
load ind750
load yeast_tiger

is_ex_f = @(x) length(x) >= 3 && strcmp(x(1:3),'EX_');
ex_idxs = find(cellfun(is_ex_f,cobra.rxns));

minimal_mets = {'h2o(e)','nh4(e)','o2(e)','pi(e)','so4(e)'};
minimal_idxs = [    436,     456,     458,   466,     476 ];

carbon_sources = {'glc','gal','fruc','man','sucr','etoh','glyc','pyr','rib','succ'};
carbon_idxs    = [  428   425    423   451    481    420    432   470   471    480];

carbon_idxs = carbon_idxs(1:3);

biomass = 1266;


tiger.lb(ex_idxs) = 0;
tiger.lb(minimal_idxs) = -1000;
tiger.sense = -1;

Ncarbon = length(carbon_idxs);
alts.lb = repmat(tiger.lb,1,Ncarbon);
for i = 1 : Ncarbon
    alts.lb(carbon_idxs(i),i) = -10;
end

sols = cmpi.solve_multiple_mips(tiger,alts,'restart',true);

growth_rates = 0.3 * sols.val;
alts.lb(biomass,:) = growth_rates;

[~,gene_locs] = convert_ids(tiger.varnames,tiger.genes);
tiger.obj(:) = 0;
tiger.obj(gene_locs) = 1;
tiger.sense = 1;

cmpi.set_option('Display','off');
cmpi.set_option('AbsOptTol',25);
cmpi.set_option('MaxTime',30);
sols = cmpi.solve_multiple_mips(tiger,alts,'restart',false);



