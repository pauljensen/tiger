function [tiger] = read_rules(tiger,filename,varargin)
% READ_RULES  Add rules from a text file
%
%   [TIGER] = READ_RULES(TIGER,FILENAME,...params...)
%
%
%   Inputs
%   TIGER     TIGER model structure.  If empty, a new TIGER structure will
%             be created.
%   FILENAME  Name of a text file of rules to be added.
%
%   Outputs
%   TIGER   TIGER model structure with rules added.
%
%   Parameters
%   ...params...    See ADD_RULE for parameter documentation. All
%                   parameters are passed to ADD_RULE for each rule.
%
%   File Format
%   - Each rule appears on its own line.
%   - Each rule is terminated with a newline (i.e. no semicolon or other
%     terminator.
%   - Lines that begin with a '#' character are skipped.
%   - Blank lines are skipped.
%   - Leading and trailing whitespace is removed.

assert(ischar(filename), 'FILENAME must be a character string');

% if there is no starting model, start with a blank model
if isempty(tiger)
    tiger = create_empty_tiger();
end

fid = fopen(filename);
lines = textscan(fid,'%s', ...
                 'Delimiter','\n', ...
                 'MultipleDelimsAsOne',true, ...
                 'CommentStyle','#');
fclose(fid);

% textscan return a cell array containing the cell array of the lines
lines = lines{1};

for i = 1 : length(lines)
    lines{i} = strip(lines{i});
end

tiger = add_rule(tiger,lines,varargin{:});
