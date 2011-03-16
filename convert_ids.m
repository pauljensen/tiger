function [names,idxs,logic] = convert_ids(all_names,ids)
% CONVERT_IDS  Create name, indices, and logical indices from an array
%
%   [NAMES,IDXS,LOGIC] = CONVERT_IDS(ALL_NAMES,IDS)
%
%   Creates a cell of names (NAMES), linear indices (IDXS), and logical
%   indices (LOGIC) for the values IDS in the cell ALL_NAMES.  IDS can be 
%   any of the forms previously mentioned.
%
%   Example:
%       all_names = {'a','b','c','d'};
%       ids = [2 4];
%       [n,i,l] = convert_ids(all_names,ids);
%           n = {'b','d'};
%           i = [2 4];
%           l = [0 1 0 1];

if isa(ids,'logical')
    logic = ids;
    names = all_names(logic);
    idxs  = find(logic);
elseif isa(ids,'double')
    idxs  = ids;
    logic = ismember(1:length(all_names),idxs);
    names = all_names(logic);
else
    names = ids;
    logic = ismember(all_names,names);
    [~,idxs] = ismember(names,all_names);
end
