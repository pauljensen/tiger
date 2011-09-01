classdef strbuffer < handle
% STRBUFFER  Extensible string buffer
%
%   Charater strings that can be easily extended.

properties
    val   % string value
    index % optional index for starting character
end

methods
    function [obj] = strbuffer(c,idx)
        % STRBUFFER  Create a string buffer with an optional
        %            initial value.
        if nargin < 2
            obj.val = '';
            obj.index = [];
        else
            obj.val = c;
            obj.index = idx;
        end
    end

    function append(obj,c,idx)
        % APPEND  Add a string to the end of the buffer.
        if nargin == 3 && isempty(obj)
            obj.index = idx;
        end
        obj.val = [obj.val c];
    end

    function [tf] = isempty(obj)
        % ISEMPTY  Overload behavior for builtin ISEMPTY function.
        tf = isempty(obj.val);
    end

    function clear(obj)
        % CLEAR  Empty the string buffer.
        obj.val = '';
        obj.index = [];
    end
end

end % classdef
