function [sol] = moma(tiger,flux_vals,flux_ids)

N = size(tiger.A,2);

if nargin < 3
    flux_ids = 1 : size(tiger.S,2);
end

flux_idxs = convert_ids(tiger.varnames,flux_ids,'index');

tiger.Qc.w = zeros(N,1);
tiger.Qc.c = zeros(N,1);

tiger.Qc.w(flux_idxs) = 1;
tiger.Qc.c(flux_idxs) = flux_vals;

tiger.obj(:) = 0;

sol = cmpi.solve_mip(tiger);
