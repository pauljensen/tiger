function [C,model] = make_c_matrix(model,varargin)

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
N = sum(R,2);

C = zeros(nrxns,ngenes);

x = zeros(ngenes,1);
for r = 1 : nrxns
    if verbose, disp(r); end
    
    if isempty(rules{r})
        continue;
    end
    
    idxs = find(RGM(r,:));
    
    if N(r) <= cutoff
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

