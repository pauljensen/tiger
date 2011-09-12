function write_csv(filename,data,col_names,row_names)

[nrow,ncol] = size(data);

is_col_names = nargin >= 3 && ~isempty(col_names);
is_row_names = nargin == 4 && ~isempty(row_names);

if is_col_names
    assert( length(col_names) == ncol, ...
            'incorrect number of column names' );
end
if is_row_names
    assert( length(row_names) == nrow, ...
            'incorrect number of row names' );
end

fid = fopen(filename,'w');

if is_col_names
    for i = 1 : ncol
        fprintf(fid,'"%s"',col_names{i});
        if i < ncol
            fprintf(fid,',');
        end
    end
    fprintf(fid,'\n');
end

for i = 1 : nrow
    if is_row_names
        fprintf(fid,'"%s",',row_names{i});
    end
    for j = 1 : ncol
        fprintf(fid,'%f',data(i,j));
        if j < ncol
            fprintf(fid,',');
        else
            fprintf(fid,'\n');
        end
    end
end

fclose(fid);
