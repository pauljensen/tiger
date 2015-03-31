function [drainflux] = check_metabolite_drains(tiger,mets)

if nargin < 2
    mets = tiger.mets;
end

drainflux = zeros(size(mets));

[t,varname] = add_column(tiger,[],'c',0,max(tiger.ub));
drain_idx = convert_ids(t.varnames,varname{1},'index');
t.obj(:) = 0;
t.obj(drain_idx) = 1;
met_idxs = convert_ids(t.rownames,mets,'index');

statbar = statusbar(length(met_idxs));
statbar.start('Metabolite Drain status');
for i = 1 : length(met_idxs)
    t.A(:,drain_idx) = 0;
    t.A(met_idxs(i),drain_idx) = -1;
    sol = solve_tiger(t,'max');
    drainflux(i) = sol.val;
    
    statbar.update(i);
end

