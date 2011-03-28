function show_mip(mip,varargin)
% SHOW_MIP  Show equations for a MIP structure
%
%   SHOW_MIP(MIP,...params...)
%
%   Print algebraic equations for a MIP structure.
%
%   Inputs
%   MIP      CMPI model structure
%
%   Parameters
%   'rowidxs'  Indexes of rows (constraints) to show. (default = all rows)
%   'varidxs'  Indexes of variables to show. (default = all rows)
%   'rownames' Cell array of names for each row.  Empty values are 
%              replaced with 'ROW_x'.  May be shorter than the number of 
%              rows; extra 'ROW_x' names are added automatically.
%   'varnames' Cell array of name for each column.  Format is the same as
%              for 'rownames'.
%   'showvars' If true, show bounds on each variable.  (default = true)

[nrows,nvars] = size(mip.A);

default_varnames = arrayfun(@(x) ['x(' num2str(x) ')'], 1:nvars, ...
                            'Uniform', false);
default_rownames = arrayfun(@(x) ['ROW_' num2str(x)], 1:nrows, ...
                            'Uniform', false);

p = inputParser;

p.addParamValue('rowidxs',1 : nrows);
p.addParamValue('varidxs',1 : nvars);
p.addParamValue('rownames',default_rownames);
p.addParamValue('varnames',default_varnames);
p.addParamValue('showvars',true);

p.parse(varargin{:});

showvars = p.Results.showvars;

% default ranges and names
if isfield(mip,'varnames')
    varnames = mip.varnames;
else
    varnames = p.Results.varnames;
end
if isfield(mip,'rownames')
    rownames = mip.rownames;
else
    rownames = p.Results.rownames;
end

varidxs = p.Results.varidxs;
if isa(varidxs,'logical')
    varidxs = find(varidxs);
end

rowidxs = p.Results.rowidxs;
if isa(rowidxs,'logical')
    rowidxs = find(rowidxs);
end                     

% expand the names if an incomplete list was given
varnames = zip_names(default_varnames,varnames);
rownames = zip_names(default_rownames,rownames);

% show objective
fprintf('\n\n----- Objective -----\n');
fprintf('z = ');
show_coef_list(mip.obj);

% show constraints
fprintf('\n\n----- Constraints -----\n');
for r = 1 : length(rowidxs)
    row = rowidxs(r);
    fprintf('%s:  ',rownames{row});
    show_coef_list(mip.A(row,:));
    switch mip.ctypes(r)
        case '<'
            fprintf(' <= ');
        case '>'
            fprintf(' >= ');
        case '='
            fprintf(' = ');
    end
    fprintf('%g\n',mip.b(r));
end

% show indicators
if isfield(mip,'ind') && any(mip.ind)
    fprintf('\n\n----- Indicators -----\n');
    rows = find(mip.ind);
    inds = mip.ind(rows);
    types = mip.indtypes(rows);
    for i = 1 : length(inds)
        if types(i) == 'p'
            fprintf('   %s  => %s\n',rownames{rows(i)},varnames{inds(i)});
        else
            fprintf('   %s <=> %s\n',rownames{rows(i)},varnames{inds(i)});
        end
    end
end

if showvars
    % show variable bounds
    maxlength = max(cellfun(@(x) length(x), varnames));
    fmt = ['%' num2str(maxlength + 2) 's'];
    fprintf('\n\n----- Variable bounds -----\n');
    for i = 1 : length(varidxs)
        fprintf(fmt,[varnames{varidxs(i)} ':']);
        fprintf('  %s',mip.vartypes(varidxs(i)));
        fprintf('  [%g,%g]\n', [mip.lb(varidxs(i)) mip.ub(varidxs(i))]);
    end
end


function [zipped] = zip_names(default,given)
    zipped = default;
    for j = 1 : length(given)
        if ~isempty(given{j})
            zipped{j} = given{j};
        end
    end
end
    
function show_coef_list(constraint)
    nonzeros = find(constraint(varidxs));
    for j = 1 : length(nonzeros)
        col = nonzeros(j);
        coef = constraint(col);
        if coef < 0
            if j > 1
                coef_str = ' - ';
            else
                coef_str = '-';
            end
        else
            if j > 1
                coef_str = ' + ';
            else
                coef_str = '';
            end
        end
        if abs(coef) ~= 1
            coef_str = [coef_str num2str(abs(coef)) '*'];
        end
        fprintf('%s%s',coef_str,varnames{col});
    end
end

end
    