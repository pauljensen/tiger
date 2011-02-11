function [tiger] = cobra_to_tiger(cobra,convert_gpr,numbered)
% COBRA_TO_TIGER  Convert a COBRA model to a TIGER model
%
%   [TIGER] = COBRA_TO_TIGER(COBRA,CONVERT_GPR)
%
%   Convert a COBRA model structure to a TIGER model structure.
%
%   Inputs
%   COBRA        COBRA toolbox model structure
%   CONVERT_GPR  If true, add the GPR constraints as rules.
%                (default = true)
%   NUMBERED     If true, use numbered names ('RXN1' and 'ROW1') instead
%                of the entries in COBRA.rxns and COBRA.mets.
%                (default = false)
%
%   Outputs
%   TIGER        TIGER model structure.

if nargin < 3
    numbered = false;
end

if nargin < 2 || isempty(convert_gpr)
    convert_gpr = true;
end

tiger = rmfield(cobra,{'c','b'});

[m,n] = size(tiger.S);

if isfield(cobra,'rxns') && ~numbered
    tiger.varnames = cobra.rxns(:)';
else
    tiger.varnames = array2names('rxn',1:n);
end

if isfield(cobra,'mets') && ~numbered
    tiger.rownames = cobra.mets(:)';
else
    tiger.rownames = array2names('row',1:m);
end

tiger.A = tiger.S;

tiger.obj = cobra.c;
tiger.ctypes = repmat('=',m,1);
tiger.vartypes = repmat('c',n,1);
tiger.d = cobra.b;


    
