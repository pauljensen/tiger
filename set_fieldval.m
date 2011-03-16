function [tiger] = set_fieldval(tiger,field,id,val)
% SET_FIELDVAL  Set values in a TIGER structure field
%
%   [TIGER] = SET_FIELDVAL(TIGER,FIELD,ID,VAL)
%
%   Set TIGER.(FIELD)(ID) = VAL.  Attempts to determine if IDS refer to 
%   row or variable names based on FIELD, and raises an error if unable
%   to do so.

var_fields = {'obj','lb','ub','vartypes'};
row_fields = {'ctypes','b','ind','indtypes'};

if ismember(field,var_fields)
    [~,idxs] = convert_ids(tiger.varnames,id);
elseif ismember(field,row_fields)
    [~,idxs] = convert_ids(tiger.rownames,id);
else
    error('field not found');
end

vals = fill_to(val,length(idxs));

tiger.(field)(idxs) = vals;