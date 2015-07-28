function s = strprefix(s,prefix)

if size(s,1) > 1
    % flatten into single string
    s = s';
    s = s(:)';
end

second = blanks(length(prefix));
s = [prefix regexprep(s,'\n',['\n' second])];
