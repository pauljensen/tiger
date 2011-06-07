function show_made_results(sol)

fprintf(['\n\nMADE:  ', ...
         'Metabolic Adjustment by Differential Expression\n']);
fprintf('------------------------------------------------------\n\n');

fprintf('%i genes found in model with %i conditions.\n\n', ...
        length(sol.genes),length(sol.condition));

fprintf('FBA results:\n');
if ~all(sol.verified)
    fprintf('    *** Warning: At least one condition does ***\n');
    fprintf('    ***  not meet the objective constraint.  ***\n');
end
fprintf('Condition    Max Obj Flux    Adj Obj Flux    Ratio\n');
for i = 1 : length(sol.condition)
    cond = sol.condition{i};
    fprintf('    %i         %10f      %10f      %3.2f\n',...
            i,cond.max_obj_flux,cond.adj_obj_flux,cond.flux_ratio);
end

fprintf('\nGene counts:\n');
fprintf('           |  Increasing    Decreasing      Constant\n');
fprintf('Transition | Data /  Fit   Data /  Fit   Data /  Fit\n');
for i = 1 : length(sol.transition)
    t = sol.transition{i};
    fprintf(' %2i ->%2i   | %4i / %4i   %4i / %4i   %4i / %4i\n', ...
            t.condition1,t.condition2, ...
            t.increasing,t.increasing_matched, ...
            t.decreasing,t.decreasing_matched, ...
            t.constant,t.constant_matched);
end

fprintf('\nTotal match:     %i / %i (%3.1f%%)\n', ...
        sol.matches,sol.total_transitions,sol.match_percent);
    
% TODO  don't compute theoretical matches when opt_match is off
fprintf('Adjusted match:  %i / %i (%3.1f%%)\n\n', ...
        sol.matches,sol.theoretical_matches,sol.adjusted_match_percent);
