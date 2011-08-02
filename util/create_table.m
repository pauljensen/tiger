function [table] = create_table(data,varargin)
% CREATE_TABLE  Format and display tabular data
%
%   [TABLE] = CREATE_TABLE(DATA,...params...)
%
%   Create and display a matrix or cell array DATA in tabular form.
%   Parameters are:
%       'spacer'    String placed between columns of data.  Default is ''.
%       'numfmt'    If DATA is a matrix, this format string is used to
%                   convert the entries to strings.  Default is '%f'.
%       'rowfmt'    A cell array of format strings, one for each column in
%                   DATA.  Must have the same number of columns as DATA.
%                   This parameter overrides 'numfmt'.
%       'columnlabels'  A cell array of string labels for each column.  If
%                       empty, the column index is used.
%       'rowlabels'     A cell array of string labels for each column.  If
%                       empty, the row index is used.

[m,n] = size(data);

p = inputParser;
p.addParamValue('spacer','  ');
p.addParamValue('numfmt','%f');
p.addParamValue('rowfmt',{});
p.addParamValue('columnlabels',array2names('%i',1:n));
p.addParamValue('rowlabels',array2names('%i',1:m));
p.parse(varargin{:});

spacer = p.Results.spacer;
numfmt = p.Results.numfmt;
rowfmt = p.Results.rowfmt;
col_headings = p.Results.columnlabels;
row_headings = p.Results.rowlabels;

if ~isa(data,'cell')
    X = cell(m,n);
    for i = 1 : m
        for j = 1 : n
            if isempty(rowfmt)
                X{i,j} = sprintf(numfmt,data(i,j));
            else
                X{i,j} = sprintf(rowfmt{j},data(i,j));
            end
        end
    end
    data = X;
end

columns = cell(1,n);
columns{1} = textframe(' ');
for i = 1 : n
    columns{i+1} = textframe(col_headings{i});
end
for i = 1 : m
    columns{1}.add_line(row_headings{i});
    for j = 1 : n
        columns{j+1}.add_line(data{i,j});
    end
end

tfs = map(@(x) x.make_block('halign','right'),columns);

table = hcat(tfs{:},'spacer',spacer);

    