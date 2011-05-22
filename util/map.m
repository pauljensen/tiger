function [mapped] = map(f,C)

if isa(C,'cell')
    mapped = cellfun(f,C,'Uniform',false);
elseif isa(C,'double') || length(C) > 1
    mapped = arrayfun(f,C,'Uniform',false);
else
    mapped = cellfun(f,{C},'Uniform',false);
end


