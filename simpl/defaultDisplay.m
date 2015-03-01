function defaultDisplay(obj)

if isscalar(obj)
    fprintf(' %s\n\n',class(obj));
else
    [m,n] = size(obj);
    fprintf(' %ix%i %s array\n\n',m,n,class(obj));
end

fprintf('%s\n\n',objMatrixToString(obj));
