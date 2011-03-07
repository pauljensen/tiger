classdef strbuffer < handle
% STRBUFFER  Extensible string buffer
%
%   Charater strings that can be easily extended.

properties
    val  % string value
end

methods
    function [obj] = strbuffer(c)
        % STRBUFFER  Create a string buffer with an optional
        %            initial value.
        if nargin < 1
            obj.val = '';
        else
            obj.val = c;
        end
    end

    function append(obj,c)
        % APPEND  Add a string to the end of the buffer.
        obj.val = [obj.val c];
    end

    function [tf] = isempty(obj)
        % ISEMPTY  Overload behavior for builtin ISEMPTY function.
        tf = isempty(obj.val);
    end

    function clear(obj)
        % CLEAR  Empty the string buffer.
        obj.val = '';
    end
end

end % classdef
