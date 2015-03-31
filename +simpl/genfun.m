function array = genfun(fun,A)
% a replacement for arrayfun when custom object are returned with
% uniform size.

s = arrayfun(fun,A,'Uniform',false);
array = [s{:}];
