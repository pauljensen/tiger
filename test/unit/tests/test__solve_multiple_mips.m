

init_test

load ind750

%tiger = cobra_to_tiger(cobra);

N = length(tiger.genes);
alts.lb = repmat(tiger.lb,1,N);
alts.ub = repmat(tiger.ub,1,N);

[~,locs] = convert_ids(tiger.varnames,tiger.genes);
for i = 1 : N
    alts.lb(locs(i),i) = 0;
    alts.ub(locs(i),i) = 0;
end

% t = tic;
% sols = cmpi.solve_multiple_mips(tiger,alts,'restart',false);
% toc(t)

t = tic;
sols = cmpi.solve_multiple_mips(tiger,alts,'restart',true);
toc(t)