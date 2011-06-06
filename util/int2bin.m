function [bin] = int2bin(num,n_bits)
    N = floor(log2(num)) + 1;
    if nargin == 2
        N = max(N,n_bits);
    end

    bin = zeros(1,N);

    for i = N : -1 : 1
        k = 2^(i-1);
        if num >= k
            num = num - k;
            bin(N+1-i) = 1;
        end
    end
