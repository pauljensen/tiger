function [bin] = int2bin(num,n_bits)
% INT2BIN  Convert an integer to an array of binary values
%
%   [BIN] = INT2BIN(NUM)
%   [BIN] = INT2BIN(NUM,N_BITS)
%
%   Returns a vector BIN that is a binary encoding of the integer NUM.
%   If given, BIN has length N_BITS; otherwise, BIN is the length of the
%   fewest number of bits necessary to encode NUM.
%
%   Examples:
%   >> int2bin(10)
%   ans = 
%       1  0  1  0
%   >> int2bin(10,6)
%   ans = 
%       0  0  1  0  1  0

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
