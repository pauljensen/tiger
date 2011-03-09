function [names,idxs,logic] = convert_ids(all_names,ids)

if isa(ids,'logical')
    logic = ids;
    names = all_names(logic);
    idxs  = find(logic);
elseif isa(ids,'cell')
    names = ids;
    logic = ismember(all_names,names);
    [~,idxs] = ismember(names,all_names);
else
    idxs  = ids;
    logic = ismember(1:length(all_names),idxs);
    names = all_names(logic);
end
