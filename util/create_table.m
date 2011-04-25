function [table] = create_table(data,col_headings,row_headings,varargin)

p = inputParser;
p.addParamValue('spacer','  ');
p.addParamValue('numfmt','%f');
p.parse(varargin{:});

spacer = p.Results.spacer;
numfmt = p.Results.numfmt;

[m,n] = size(data);

if nargin < 4
    spacer = '  ';
end
if nargin < 3 || isempty(row_headings)
    row_headings = array2names('%i',1:m);
end

if isa(data,'double')
    X = cell(m,n);
    for i = 1 : m
        for j = 1 : n
            X{i,j} = sprintf(numfmt,data(i,j));
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

    