function [milp] = tile_milp(varargin)

% format string used for creating model-specific variable names
VARNAME_FMT = '%s[%i]';

N = length(varargin);
milps = map(@cmpi.check_mip,varargin);

if N == 0
    error('at least one MILP must be provided');
end

if N == 1
    milp = milps{1};
    return;
end

% shift the indicator indices
ns = cellfun(@(x) size(x.A,2),milps);
offsets = cumsum(ns) - ns(1);
for i = 1 : N
    milps{i}.ind = milps{i}.ind + offsets(i);
end

As = map(@(x) x.A,milps);
milp.A = blkdiag(As{:});

% make sure all MILPs have the same sense as the first MILP
if isfield(milps{1},'sense')
    milp.sense = milps{1}.sense;
else
    milp.sense = 1;
end
for i = 2 : N
    if isfield(milps{i},'sense') && milps{i}.sense ~= milps{1}.sense
        milps{i}.obj = -1*milps{i}.obj;
    end
end

% create model-specific variable names
for i = 1 : N
    milps{i}.varnames = map(@(x) sprintf(VARNAME_FMT,x,i), ...
                            milps{i}.varnames);
end

% concatenate all other fields
field_names = {'obj','b','ctypes','vartypes','lb','ub', ...
               'ind','indtypes','rownames','varnames'};
celliter(@concat_fields,field_names);

milp.options = milps{1}.options;


function concat_fields(name)
    fields = map(@(x) x.(name),milps);
    milp.(name) = vertcat(fields{:});
end

end