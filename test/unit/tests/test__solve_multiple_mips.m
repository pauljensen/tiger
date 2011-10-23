
cobra_model

tiger = cobra_to_tiger(cobra);

nrxns = size(tiger.S,2);
tiger.obj(:) = 0;
alts.obj = repmat(tiger.obj,1,2*nrxns);

for i = 1 : nrxns
    alts.obj(i,i) = 1;
    alts.obj(i,i+nrxns) = -1;
end

sols1 = cmpi.solve_multiple_mips(tiger,alts,'restart',false);

sols2 = cmpi.solve_multiple_mips(tiger,alts,'restart',true);


assert(near(sols1.flag,sols2.flag),'flag off');
assert(near(sols1.val,sols2.val),'vals off');

clear alts cobra i m n nrxns sols1 sols2 tiger
