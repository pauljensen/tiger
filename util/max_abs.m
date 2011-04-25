function [maxabs] = max_abs(varargin)

cands = cellfun(@(x) max(abs(x)),varargin);
maxabs = max(cands);

