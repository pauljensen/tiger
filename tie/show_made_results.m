function show_made_results(sol,varargin)
% SHOW_MADE_RESULTS  


SUMMARY = 1;
DEBUG = 2;
GENES = 3;

to_show = false(1,3);
to_show(SUMMARY) = ismember('summary',varargin) || isempty(varargin);
to_show(DEBUG)   = ismember('debug',varargin);
to_show(GENES)   = ismember('genes',varargin);
if ismember('all',varargin)
    to_show = true(1,3);
end

if to_show(SUMMARY)
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
    fprintf('Transition |  Fit / Data    Fit / Data    Fit / Data\n');
    for i = 1 : length(sol.transition)
        t = sol.transition{i};
        fprintf(' %2i ->%2i   | %4i / %4i   %4i / %4i   %4i / %4i\n', ...
                t.condition1,t.condition2, ...
                t.increasing_matched,t.increasing, ...
                t.decreasing_matched,t.decreasing, ...
                t.constant_matched,t.constant);
    end

    fprintf('\nTotal match:     %i / %i (%3.1f%%)\n', ...
            sol.matches,sol.total_transitions, ...
            sol.match_percent);

    % TODO  don't compute theoretical matches when opt_match is off
    fprintf('Adjusted match:  %i / %i (%3.1f%%)\n\n', ...
            sol.matches,sol.theoretical_matches, ...
            sol.adjusted_match_percent);
end

if to_show(DEBUG)
    % debuging reactions
    vars = sol.variables{1};
    off_rxns = round(vars.rxn) == 0 & vars.flux ~= 0.0;
    fluxes = vars.flux;
    fluxes(~off_rxns) = 0;
    [~,I] = sort(abs(fluxes(:)),1,'descend');
    for i = 1 : 10
        fprintf('%i  %1.10f  %1.10f\n',I(i),fluxes(I(i)),vars.rxn(I(i)));
    end
    
end

if to_show(GENES)
    % show condition lists
end


