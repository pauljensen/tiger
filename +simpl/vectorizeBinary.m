function Y = vectorizeBinary(f,A,B,constructor)

if nargin < 4
    constructor = @zeros;
end

if isscalar(A) && ~isscalar(B)
    [m,n] = size(B);
    A = repmat(A,m,n);
elseif isscalar(B) && ~isscalar(A)
    [m,n] = size(A);
    B = repmat(B,m,n);
end

[m,n] = size(A);
Y(m,n) = constructor();
for j = 1:n
    for i = 1:m
        Y(i,j) = f(A(i,j),B(i,j));
    end
end
