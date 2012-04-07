function show_tiger(tiger,varargin)
% SHOW_TIGER  Show a TIGER model as a MIP
%
%   SHOW_TIGER(TIGER,...params...)
%
%   Displays a TIGER model in equation form.  The following parameters can
%   be given:
%       'bounds'  Show the bounds and type for each variable.
%       'rxns'    Treat continuous variables as "reactions" and display 
%                 the chemical reaction.

showvars = ismember('bounds',varargin);
showrxns = ismember('rxns',varargin);

cmpi.show_mip(tiger,'showvars',showvars);

if showrxns
    [m,n] = size(tiger.A);
    % find metabolite rows
    is_met = false(m,1);
    for i = 1 : m
        is_met(i) = all(tiger.vartypes(tiger.A(i,:) ~= 0) == 'c');
    end
    
    fprintf('\n\n----- Reactions -----\n');
    for i = 1 : n
        if tiger.vartypes(i) == 'c'
            show_reaction(i);
        end
    end
end

function show_reaction(idx)
    reacts = find(is_met & tiger.A(:,idx) < 0);
    prods  = find(is_met & tiger.A(:,idx) > 0);
    
    fprintf('%s : ',tiger.varnames{idx});
    print_moieties(reacts);
    if (tiger.lb(idx) < 0) || (isfield(tiger,'rev') && tiger.rev(idx))
        fprintf(' <-> ');
    else
        fprintf(' -> ');
    end
    print_moieties(prods);
    fprintf('\n');

    function print_moieties(idxs)
        for j = 1 : length(idxs)
            if abs(tiger.A(idxs(j),idx)) == 1
                fprintf(tiger.rownames{idxs(j)});
            else
                fprintf('%f %s',num2str(abs(tiger.A(idxs(j),idx))), ...
                                tiger.rownames{idxs(j)});
            end
            
            if j < length(idxs)
                fprintf(' + ');
            end
        end
    end
end

end
    
    