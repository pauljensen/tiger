function [minact,maxact] = eva(elf,varargin)
% EVA  Enzyme variability analysis
%
%   [MINACT,MAXACT] = EVA(ELF,...params...)
%
%   Calculates the minimium (MINACT) and maximum (MAXACT) enzyme 
%   activities at a specified optimal flux value.  Parameters are the same
%   as for FVA.  If the parameter 'vars' is not specified, the default is
%   ELF.genes.

p = inputParser;
p.addParamValue('vars',elf.genes);
p.KeepUnmatched = true;
p.parse(varargin{:});
unmatched = struct2list(p.Unmatched);

[minact,maxact] = fva(elf,'vars',p.Results.vars,unmatched{:});
