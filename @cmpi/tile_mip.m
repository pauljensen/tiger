function [mip] = tile_mip(varargin)
% TILE_MIP  Combine several MIPs into a single structure
%
%   [MIP] = TILE_MIP(MIP1,MIP2,...)
%
%   Combines N MIP problem structures into a single structure.  The
%   resulting A matrix is a block-diagonal tiling of the individual A
%   matrices.
%
%   Variable names for each problem are appended with '[i]'.  For example,
%   if three structures were given, each with a variable 'x', the 
%   resulting variable names would be 'x[1]', 'x[2]', and 'x[3]'.

% format string used for creating model-specific variable names
VARNAME_FMT = '%s[%i]';

N = length(varargin);
mips = map(@cmpi.check_mip,varargin);

if N == 0
    error('at least one mip must be provided');
end

if N == 1
    mip = mips{1};
    return;
end

% shift the indicator indices
ns = cellfun(@(x) size(x.A,2),mips);
offsets = cumsum(ns) - ns(1);
for i = 1 : N
    mips{i}.ind = mips{i}.ind + offsets(i);
end

As = map(@(x) x.A,mips);
mip.A = blkdiag(As{:});

% make sure all mips have the same sense as the first mip
if isfield(mips{1},'sense')
    mip.sense = mips{1}.sense;
else
    mip.sense = 1;
end
for i = 2 : N
    if isfield(mips{i},'sense') && mips{i}.sense ~= mips{1}.sense
        mips{i}.obj = -1*mips{i}.obj;
    end
end

% create model-specific variable names
for i = 1 : N
    mips{i}.varnames = map(@(x) sprintf(VARNAME_FMT,x,i), ...
                            mips{i}.varnames);
end

% concatenate all other fields
field_names = {'obj','b','ctypes','vartypes','lb','ub', ...
               'ind','indtypes','rownames','varnames'};
celliter(@concat_fields,field_names);

mip.options = mips{1}.options;

% start over the indicator counter
mip.param.ind = 0;

% convert the quadratic terms
switch miqp_type(mips{1})
    case 'Q'
        Qs = map(@(x) x.Q,mips);
        mip.Q = blkdiag(Qs{:});
    case 'Qd'
        Qds = map(@(x) x.Qd,mips);
        mip.Qd = blkdiag(Qds{:});
    case 'Qc'
        Qcws = map(@(x) x.Qc.w(:),mips);
        Qccs = map(@(x) x.Qc.c(:),mips);
        mip.Qc.w = vertcat(Qcws{:});
        mip.Qc.c = vertcat(Qccs{:});
end
        

function concat_fields(name)
    fields = map(@(x) x.(name),mips);
    mip.(name) = vertcat(fields{:});
end

end
