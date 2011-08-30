function [inf_rows] = find_infeasible_rows(mip,varargin)

p = inputParser;
p.addParamValue('rows',1:size(mip.A,1));
p.addParamValue('obj','count');
p.parse(varargin{:});

rows = p.Results.rows;

assert(ismember(upper(p.Results.count),{'COUNT','ABS'}), ...
       'parameter ''obj'' must be either ''count'' or ''abs''');
count_obj = strcmpi(p.Results.obj,'count');

nrows = length(rows);

slack_ub = zeros(nrows,1);
slack_lb = zeros(nrows,1);
for i = 1 : nrows
    row_up = mip.A(rows(i),:) .* mip.ub;
    row_dn = mip.A(rows(i),:) .* mip.lb;
    slack_ub(i) = sum(max(row_up,row_dn));
    slack_lb(i) = sum(min(row_up,row_dn));
end

[mip,slacks] = add_column(mip,[],'c',slack_lb,slack_ub);

