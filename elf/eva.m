function [minact,maxact] = eva(elf,varargin)

p = inputParser;
p.addParamValue('vars',elf.genes);
p.KeepUnmatched = true;
p.parse(varargin{:});
unmatched = struct2list(p.Unmatched);

[minact,maxact] = fva(elf,'vars',p.Results.vars,unmatched{:});
