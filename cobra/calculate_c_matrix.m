function [C] = calculate_c_matrix(model,normalize,cutoff,n_samples,show_rxn_number)

if ( nargin < 5 )  show_rxn_number = false; end
if ( nargin < 4 )  n_samples = 1000; end
if ( nargin < 3 )  cutoff = 10; end
normalize = (nargin >= 2) && normalize;
    
R = model.rxnGeneMat;
[n_rxns,n_genes] = size(R);
rules = model.rules;

N = sum(R, 2);

C = zeros(n_rxns, n_genes);

x = zeros(1, n_genes);
for r = 1 : n_rxns
    if show_rxn_number,  disp(int2str(r)); end
    
    if isempty(rules{r})
        continue;
    end
         
    idxs = find(R(r,:));
    
    if N(r) <= cutoff       
        s11_00 = zeros(1, N(r));
        s01_10 = zeros(1, N(r));
        
        for i = 0 : 2^N(r) - 1
            state = int2bin(i, N(r));
            x(idxs) = state;
            onoff = eval(rules{r});
            
            s11_00 = s11_00 + (state == onoff);
            s01_10 = s01_10 + (state ~= onoff);
            
            x(idxs) = 0;
        end
        
        C(r,idxs) = (s11_00 - s01_10) / 2^N(r);
    else
        data = zeros(n_samples, N(r)+1);
        for i = 1 : n_samples
            data(i,1:end-1) = randi(2, 1, N(r)) - 1;
            x(idxs) = data(i,1:end-1);
            data(i,end) = eval(rules{r});
            x(idxs) = 0;
        end
        corrm = corr(data);
        
        C(r,idxs) = corrm(end,1:end-1);
    end
end

if normalize
    C = C ./ repmat(sum(C,2), 1, size(C,2));
end

end

function bin = int2bin(num, n_bits)
    N = floor(log2(num)) + 1;
    if ( nargin == 2 )
        N = max(N, n_bits);
    end

    bin = zeros(1, N);

    for i = N : -1 : 1
        k = 2^(i-1);
        if ( num >= k )
            num = num - k;
            bin(N+1-i) = 1;
        end
    end
end
            
        