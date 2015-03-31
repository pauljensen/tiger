function str = objMatrixToString(obj,indent,spacing)
% objMatrixToString  Create string representation of 2D object array.
%
%   [STR] = objMatrixToString(OBJ)
%   [STR] = objMatrixToString(OBJ,INDENT,SPACING)
%
%   Convert an object array to a string using a grid layout.  OBJ must
%   have a valid toString method that will be called on each entry.
%
%   Returns a single character array.  All entries are right-aligned.
%
%   INDENT is a string that appears at the start of each row.
%   SPACING is a string that appears between each column.

if nargin < 2
    indent = '    ';
end
if nargin < 3
    spacing = '    ';
end

[m,n] = size(obj);
strs = cell(m,n);
for j = 1:n
    for i = 1:m
        strs{i,j} = toString(obj(i,j));
    end
end

maxColLengths = zeros(1,n);
for j = 1:n
    maxColLengths(j) = max(cellfun(@length,strs(:,j)));
end

for j = 1:n
    for i = 1:m
        len = length(strs{i,j});
        padding = repmat(' ', 1, maxColLengths(j) - len);
        strs{i,j} = [padding strs{i,j}];
    end
end

rows = cell(1,m);
for i = 1:m
    rows{i} = [indent strjoin(strs(i,:),spacing)];
end

str = strjoin(rows,'\n');
