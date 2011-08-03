function [sol] = moma(tiger,flux_vals,flux_ids)
% MOMA  Minimization of Metabolic Adjustment
%
%   [SOL] = MOMA(TIGER,FLUX_VALS)
%   [SOL] = MOMA(TIGER,FLUX_VALS,FLUX_IDS)
%
%   Calculates and returns a CMPI solution structure for the MOMA
%   algorithm:
%       minimize (v - FLUX_VALS)^2
%       s.t.  Sv = 0
%             lb <= v <= ub
%
%   If only a subset of fluxes are specified, the indices can be given in
%   the vector FLUX_IDS.  The corresponding objective is then:
%       minimize (v(FLUX_IDS) - FLUX_VALS)^2

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
