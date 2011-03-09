function [ziped] = cellzip(f,a,b)

ziped = arrayfun(@(i) f(a{i},b{i}),1:length(a),'Uniform',false);
