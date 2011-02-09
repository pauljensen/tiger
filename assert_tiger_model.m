function [tiger] = assert_tiger_model(model)
% ASSERT_TIGER_MODEL  Assert that a structure is an TIGER model.
%
%   [TIGER] = ASSERT_TIGER_MODEL(MODEL)
%
%   Checks that the structure MODEL is a TIGER model.  If not, converts
%   MODEL to a TIGER model and warns that this procedure is not efficient
%   for repeated calls to the parent function.

fields = {'A','d','vartypes','ctypes','rownames','varnames','obj'};

if ~all(isfield(model,fields))
    % convert model
    fprintf('This model is not a TIGER model.  It will automatically\n');
    fprintf('be converted.  For repeated calls to this function, it\n');
    fprintf('is more efficient to convert beforehand.\n');
    
    % convert without adding GPR
    tiger = cobra_to_tiger(model,false);
else
    tiger = model;
end

