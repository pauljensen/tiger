classdef hash < handle
    
properties
    keys
    vals
end

methods
    function [h] = hash()
        h.keys = {};
        h.vals = {};
    end
    
    function set(h,ks,vs)
        h.keys = [h.keys ks];
        h.vals = [h.vals vs];
    end
    
    function [vs] = get(h,ks)
        [tf,loc] = h.isin(ks,h.keys);
        if ~all(tf)
            error(['Undefined key(s): ' hash.join(ks(~tf),' ',true)]);
        else
            vs = h.vals(loc);
        end
    end
            
    function [vs] = subsref(h,s)
        switch s(1).type
            case '{}'
                vs = h.get(s(1).subs);
                if length(s) > 1
                    s = s(2:end);
                    vs = cellfun(@(x) subsref(x,s), vs, ...
                                 'UniformOutput', false);
                end
                if length(vs) == 1
                    vs = vs{1};
                end
            case '.'
                props = {'keys','vals'};
                meths = methods(hash);
                if ismember(s(1).subs,meths)
                    if length(s) > 1
                        vs = feval(s(1).subs,h,s(2).subs);
                    else
                        vs = feval(s(1).subs,h);
                    end
                elseif ismember(s(1).subs,props)
                    vs = h.(s(1).subs);
                else
                    error(['??? No appropriate method, property,' ...
                           ' or field %s for class hash'],s(1).subs);
                end
            otherwise
                error('Use hash{''key''} to refernce hashes');
        end
    end
end

methods (Static,Access = private)
    function [str] = join(list,spacer,quote)
        if nargin < 2,  spacer = ' '; end
        if nargin == 3 && quote
            list = cellfun(@(x) ['''' x ''''],list,'UniformOutput',false);
        end
        str = '';
        for i = 1 : length(list) - 1
            str = [str list{i} spacer];
        end
        str = [str list{end}];
    end
    
    function [tf,loc] = isin(A,S)
        tf = false(size(A));
        loc = zeros(size(A));
        for i = 1 : length(A)
            for j = 1 : length(S)
                if isa(A{i},class(S{j})) && A{i} == S{j}
                    tf(i) = true;
                    loc(i) = j;
                    break;
                end
            end
        end
    end
end

end % classdef
    
