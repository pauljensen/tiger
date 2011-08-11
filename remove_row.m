function [tiger] = remove_row(tiger,row_ids)
% REMOVE_ROW  Remove row(s) from a TIGER model
%
%   [TIGER] = REMOVE_ROW(TIGER,ROW_IDS)
%
%   Remove rows ROW_IDS from a TIGER model and return the modified
%   structure.  ROW_IDS are any valid IDs (see CONVERT_IDS).

ids = ~convert_ids(tiger.rownames,row_ids,'logical');

tiger.A = tiger.A(ids,:);
tiger.b = tiger.b(ids);

tiger.rownames = tiger.rownames(ids);
tiger.ctypes = tiger.ctypes(ids);

tiger.ind = tiger.ind(ids);
tiger.indtypes = tiger.indtypes(ids);

tiger.param.rule_id = tiger.param.rule_id(ids);

