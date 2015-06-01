function [A,B] = matchDims(a,b)

if ~isscalar(a) && isscalar(b)
    [m,n] = size(a);
    A = a;
    B = repmat(b,m,n);
elseif isscalar(a) && ~isscalar(b)
    [m,n] = size(b);
    A = repmat(a,m,n);
    B = b;
elseif all(size(a) == size(b))
    A = a;
    B = b;
else
    error('SIMPL:matchDims', ...
          ['inconsistent dimensions: ' ...
          sprintf('[%ix%i] vs. [%ix%i]',size(a,1),size(a,2), ...
                                        size(b,1), size(b,2))]);
end
