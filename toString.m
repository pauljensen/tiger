function str = toString(obj)

MAX_CELL_LENGTH = 5;

if ismember('toString',methods(obj))
    str = toString(obj);
elseif ischar(obj)
    str = obj;
elseif isnumeric(obj)
    if isscalar(obj)
        str = num2str(obj);
    else
        str = mat2str(obj);
    end
elseif iscell(obj) && length(obj) < MAX_CELL_LENGTH
    if isempty(obj)
        str = '{}';
    else
        str = evalc('disp(obj)');
        str = [strprefix('{',str(1:end-2)) ' }'];
    end
else
    [m,n] = size(obj);
    str = sprintf('[%ix%i %s]',m,n,class(obj));
end
