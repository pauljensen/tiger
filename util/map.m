function [mapped] = map(f,C)

if isa(C,'cell')
    mapped = cellfun(f,C,'Uniform',false);
else
    mapped = cellfun(f,{C},'Uniform',false);
end


