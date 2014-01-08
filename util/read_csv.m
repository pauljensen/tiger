function [data,row_names,col_names] = read_csv(filename,ncol)

rnames = true;
cnames = true;

numfmt = joinwith('%f','',ncol);

if rnames
    fmt = ['%q' numfmt];
else
    fmt = numfmt;
end

fid = fopen(filename);

opts = {'Delimiter',','};

if cnames
    if rnames
        col_names = textscan(fid,joinwith('%q','',ncol+1),1,opts{:});
        col_names = col_names(2:end);
    else
        col_names = textscan(fid,joinwith('%q','',ncol),1,opts{:});
    end
end

C = textscan(fid,fmt,opts{:},'CollectOutput',true);
if rnames
    data = C(:,2:end);
    row_names = C(:,1);
    row_names = row_names{1};
else
    data = C(:,:);
end

data = data{1};

fclose(fid);
    
function [s] = joinwith(str,sep,n)
    s = '';
    for i = 1 : n
        s = [s str];
        if i < n
            s = [s sep];
        end
    end
