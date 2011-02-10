function [names] = array2names(pre,array)

names = arrayfun(@(x) [pre num2str(x)],array,'Uniform',false);
