function [table] = create_table(data,varargin)

[m,n] = size(data);

p = inputParser;
p.addParamValue('spacer','  ');
p.addParamValue('numfmt','%f');
p.addParamValue('columnlabels',array2names('%i',1:n));
p.addParamValue('rowlabels',array2names('%i',1:m));
p.parse(varargin{:});

spacer = p.Results.spacer;
numfmt = p.Results.numfmt;
col_headings = p.Results.columnlabels;
row_headings = p.Results.rowlabels;

if ~isa(data,'cell')
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

    