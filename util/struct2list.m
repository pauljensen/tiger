function [list] = struct2list(s)

names = fieldnames(s);
Nnames = length(names);

list = cell(1,2*Nnames);
for i = 1 : Nnames
    list{2*(i-1)+1} = names{i};
    list{2*i} = s.(names{i});
end

