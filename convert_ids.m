function [names,idxs,logic] = convert_ids(all_names,ids)

if isa(ids,'logical')
    logic = ids;
    names = all_names(logic);
    idxs = find(logic);
elseif isa(ids,'cell')
    names = ids;
    [logic,idxs] = ismember(all_names,names);
    idxs = idxs(logic);
else
    idxs = ids;
    logic = ismember(1:length(all_names),idxs);
    names = all_names(logic);
end
