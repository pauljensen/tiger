function [results] = vectorize(f,A,constructor)

if nargin < 3
    constructor = @zeros;
end

[m,n] = size(A);
results = constructor(m,n);
for j = 1:n
    for i = 1:m
        results(i,j) = f(A(i,j));
    end
end
