function show_made_results(sol,varargin)
% SHOW_MADE_RESULTS  Summarize results from the MADE algorithm
%
%   SHOW_MADE_RESULTS(SOL,...params...)
%
%   Displays a summary of the results from the MADE algorithm.  SOL is the
%   solution structure returned by MADE.  The following parameters
%   determine the information shown:
%       'summary'  (default) Objective values for unconstrained and
%                  adjusted models, counts of transitions matched for each
%                  condition.
%       'debug'    Show reactions that are "off" which carry nonzero flux.
%                  Used to identify integrality errors.
%       'all'      Show all of the above.

SUMMARY = 1;
DEBUG = 2;
GENES = 3;

show_theoretical = isfield(sol,'D_optimal');

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

    if show_theoretical
        fprintf('Adjusted match:  %i / %i (%3.1f%%)\n\n', ...
                sol.matches,sol.theoretical_matches, ...
                sol.adjusted_match_percent);
    end
end

if to_show(DEBUG)
    N_RXNS_SHOW = 10;
    
    % debuging reactions
    vars = sol.variables{1};
    off_rxns = round(vars.rxn) == 0 & vars.flux ~= 0.0;
    if any(off_rxns)
        fluxes = vars.flux;
        fluxes(~off_rxns) = 0;
        [~,I] = sort(abs(fluxes(:)),1,'descend');
        fprintf('\nOff reactions with highest flux:\n');
        fprintf('  Rxn             Flux        Indicator\n');
        for i = 1 : min([N_RXNS_SHOW,count(off_rxns)])
            fprintf('%5i  %15f  %15f\n', ...
                    I(i),fluxes(I(i)),vars.rxn(I(i)));
        end
    else
        fprintf('\nNo flux found through non-integral reactions.\n');
    end
    fprintf('\n');
end

if to_show(GENES)
    % show condition lists
    [ngenes,ncond] = size(sol.gene_states);
    data = cell(ngenes,2*ncond - 1);
    columnlabels = cell(1,2*ncond - 1);
    for g = 1 : ngenes
        for i = 1 : ncond
            data{g,2*(i-1)+1} = num2str(sol.gene_states(g,i));
            columnlabels{2*(i-1)+1} = num2str(i);
            columnlabels{2*(i-1)+2} = ' ';
            
            if i == ncond
                break;
            end
            
            if sol.D_data(g,i) == 1
                spacer = ' / ';
            elseif sol.D_data(g,i) == -1
                spacer = ' \\ ';
            else
                spacer = ' - ';
            end
            if sol.D_matched(g,i) ~= sol.D_data(g,i)
                spacer([1 end]) = '**';
            end
            data{g,2*(i-1)+2} = spacer;
        end
    end
    
    fprintf('\nGene states (* indicates transition mismatch)\n');
    create_table(data,'rowlabels',sol.genes,'columnlabels',columnlabels)
    fprintf('\n\n');
end


