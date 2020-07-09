function [tiger] = add_operon(tiger,name,vars)
% ADD_OPERON  Name an operon of coupled genes
%
%   [TIGER] = ADD_OPERON(TIGER,NAME,VARS)
%
%   Inputs
%   TIGER   TIGER model structure. If empty, a new TIGER structure will
%           be created.
%   NAME    Name of the operon as a string. A binary variable will be added
%           to the model for the operon.
%   VARS    Cell array of strings naming the variables to include in the
%           operon.
%
%   Outputs
%   TIGER   TIGER model structure with the operon added.
%
%   Example
%
%       add_operon(tiger,'lac',{'lacA','lacB'})
%
%   The above example is equivalent to the command
%
%       add_rule(tiger,{'lac <=> lacA', 'lac <=> lacB'})

assert(ischar(name), 'NAME must be a character string');
assert(iscell(vars), 'VARS must be a cell array');

% if there is no starting model, start with a blank model
if isempty(tiger)
    tiger = create_empty_tiger();
end

% check that a TIGER model was given (and convert if COBRA)
tiger = assert_tiger(tiger);

for i = 1 : length(vars)
    tiger = add_rule(tiger,[name ' <=> ' vars{i}]);
end
