function [tiger] = assert_tiger(model)
% ASSERT_TIGER  Assert that a structure is an TIGER model.
%
%   [TIGER] = ASSERT_TIGER(MODEL)
%
%   Checks that the structure MODEL is a TIGER model.  If not, converts
%   MODEL to a TIGER model and warns that this procedure is not efficient
%   for repeated calls to the parent function.

fields = {'A','b','vartypes','ctypes','rownames','varnames','obj'};

if ~all(isfield(model,fields))
    % convert model
    fprintf('This model is not a TIGER model.  It will automatically\n');
    fprintf('be converted.  For repeated calls to this function, it\n');
    fprintf('is more efficient to convert beforehand.\n');
    
    if isempty(model)
        tiger = create_empty_tiger();
    else
        tiger = cobra_to_tiger(model);
    end
else
    tiger = model;
end

