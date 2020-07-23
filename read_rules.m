function [rules] = read_rules(filename)
% READ_RULES  Read rules from a text file
%
%   [TIGER] = READ_RULES(FILENAME)
%
%
%   Inputs
%   FILENAME  Name of a text file of rules to be added.
%
%   Outputs
%   RULES     Cell array of rules as strings.
%
%
%   File Format
%   - Each rule appears on its own line.
%   - Each rule is terminated with a newline (i.e. no semicolon or other
%     terminator.
%   - Lines that begin with a '#' character are skipped.
%   - Blank lines are skipped.
%   - Leading and trailing whitespace is removed.

assert(ischar(filename), 'FILENAME must be a character string');

fid = fopen(filename);
lines = textscan(fid,'%s', ...
                 'Delimiter','\n', ...
                 'MultipleDelimsAsOne',true, ...
                 'CommentStyle','#');
fclose(fid);

% textscan return a cell array containing the cell array of the lines
rules = lines{1};

for i = 1 : length(rules)
    rules{i} = strip(rules{i});
end

