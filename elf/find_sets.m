function [sets] = find_sets(I)

I = logical(I);
[n_samples,n_vars] = size(I);

sets = zeros(0,n_vars);

for i = 1 : n_samples
    row = double(I(i,:));
    dups = (sets * row') > 0;
    if any(dups)
        new_set = row;
        for dup = find(dups(:)')
            new_set = new_set | sets(dup,:);
            sets(dup,:) = 0;
        end
        sets = [sets(~dups,:); new_set];
    else
        sets(end+1,:) = row;
    end
end
