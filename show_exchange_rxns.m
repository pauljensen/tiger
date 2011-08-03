function show_exchange_rxns(model,sol)
% SHOW_EXCHANGE_RXNS  Show exchange reactions (and fluxes)
%
%   SHOW_EXCHANGE_RXNS(MODEL)
%   SHOW_EXCHANGE_RXNS(MODEL,SOL)
%
%   Shows the metabolite name and index of exchange reactions in MODEL.
%   If a solution structure or flux vector SOL is given, only nonzero
%   fluxes are displayed (with the corresponding flux value).

show_flux = nargin >= 2;

if show_flux && isa(sol,'struct')
    sol = sol.x;
end

ex_rxns = find_exchange_rxns(model);

% find corresponding metabolite
if isfield(model,'metNames')
    mets = model.metNames;
elseif isfield(model,'mets')
    mets = model.mets;
else
    mets = model.varnames;
end
    
metnamef = @(x) mets{model.S(:,x) ~= 0};
metnames = map(metnamef,ex_rxns);

max_length = max(cellfun(@length,metnames));

if show_flux
    fmt = '%*s (%4i):  %+08f\n';
else
    fmt = '%*s (%4i)\n';
end

fprintf('\n\n');
for i = 1 : length(ex_rxns)
    if show_flux && sol(ex_rxns(i)) ~= 0
        fprintf(fmt,max_length,metnames{i},ex_rxns(i),sol(ex_rxns(i)));
    elseif ~show_flux
        fprintf(fmt,max_length,metnames{i},ex_rxns(i));
    end
end
fprintf('\n\n');
