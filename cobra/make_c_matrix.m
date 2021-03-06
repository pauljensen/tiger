function [C,model] = make_c_matrix(model,varargin)
% MAKE_C_MATRIX  Make reaction/gene correlation (C) matrix
%
%   [C,MODEL] = MAKE_C_MATRIX(MODEL,...params...)
%
%   Creates C, a |rxns| x |genes| matrix containing a correlation 
%   coefficient between a reaction and the genes in the corresponding GPR.
%   MODEL is returned with C additional fields used in the calculation
%   (rxnGeneMat and rules).
%
%   Parameters
%   'normalize'  If true, the entries for each reaction are normalized to
%                sum to one.
%   'cutoff'     If a GPR contains more than 'cutoff' genes, the
%                coefficients are estimated by Monte Carlo sampling.
%                (Default = 10)
%   'samples'    If Monte Carlo sampling is used, 'samples' number of 
%                draws are taken.  (Default = 1000)
%   'verbose'    If true (default = false), a status bar is displayed.

p = inputParser();
p.addParamValue('normalize',true);
p.addParamValue('cutoff',10);
p.addParamValue('samples',1000);
p.addParamValue('verbose',false);

p.parse(varargin{:});

normalize = p.Results.normalize;
cutoff = p.Results.cutoff;
n_samples = p.Results.samples;
verbose = p.Results.verbose;

% check for correct COBRA fields
if ~isfield(model,'rxnGeneMat')
    model.rxnGeneMat = make_rxnGeneMat(model);
end

if ~isfield(model,'rules')
    model.rules = convert_grRules(model);
end

RGM = model.rxnGeneMat;
[nrxns,ngenes] = size(RGM);
rules = model.rules;

% number of genes in each reaction
N = sum(RGM,2);

C = zeros(nrxns,ngenes);

x = zeros(ngenes,1);
statbar = statusbar(nrxns,verbose);
statbar.start('C Matrix calculation');
for r = 1 : nrxns
    statbar.update(r);
    
    if isempty(rules{r})
        continue;
    end
    
    idxs = find(RGM(r,:));
    
    if N(r) <= cutoff
        % compute coefficients manually
        s11_00 = zeros(1,N(r));
        s01_10 = zeros(1,N(r));
        
        for i = 0 : 2^N(r) - 1
            state = int2bin(i,N(r));
            x(idxs) = state;
            onoff = eval(rules{r});
            
            s11_00 = s11_00 + (state == onoff);
            s01_10 = s01_10 + (state ~= onoff);
        end
        x(idxs) = 0;
        
        C(r,idxs) = (s11_00 - s01_10) / 2^N(r);
    else
        % compute coefficients using Monte Carlo
        data = zeros(n_samples,N(r)+1);
        data(:,1:N(r)) = randi(2,n_samples,N(r)) - 1;
        for i = 1 : n_samples
            x(idxs) = data(i,1:N(r));
            data(i,end) = eval(rules{r});
        end
        x(idxs) = 0;
        
        corrm = corr(data);
        C(r,idxs) = corrm(end,1:end-1);
    end
end

if normalize
    for i = 1 : nrxns
        if all(C(i,:) == 0)
            continue;
        end
        
        Cmin = min(C(i,:));
        Cmax = max(C(i,:));
        C(i,:) = (C(i,:) - Cmin) / (Cmax - Cmin);
    end
end

if nargout > 1
    model.C = C;
end



