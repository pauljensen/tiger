classdef stack < handle
% STACK  First-in, last-out stacks.
%
%   STACK creates a polymorphic stack with first-in, last-out (FILO)
%   behavior.
    
properties (Dependent)
    is_another  % true is stack contains another value
    is_empty    % true if stack is empty
    length      % number of items on stack
end
properties (Dependent,Hidden)
    N   % number of items on stack
end

properties (SetAccess = private)
    values  % cell of stack values
end

methods
    function [obj] = stack(array)
        % STACK  Create a FILO stack.
        %
        %   [OBJ] = STACK(ARRAY)
        %
        %   Creates a new stack.  ARRAY is an optional cell of initial
        %   values for the stack.  (The last item in the cell is the
        %   first item to be removed with POP.
        
        if nargin == 0
            obj.values = {};
        elseif isa(array,'cell')
            obj.values = array;
        else
            N = length(array);
            obj.values = cell(1,N);
            for i = 1 : N
                obj.values{i} = array(i);
            end
        end
    end

    function [item] = pop(obj)
        % POP  Remove the last object added to the stack.
        assert(obj.is_another, 'stack is empty');
        item = obj.values{end};
        obj.values = obj.values(1:end-1);
    end

    function push(obj,item)
        % PUSH  Add an item to the stack.
        obj.values{end+1} = item;
    end

    function [item] = peek(obj)
        % PEEK  Return the last item added to the stack,
        %       without removing it.
        assert(obj.is_another, 'stack is empty');
        item = obj.values{end};
    end

    function reverse(obj)
        % REVERSE  Reverse the order of items on the stack.
        obj.values = fliplr(obj.values);
    end
    
    % ------- dependent access methods -------
    function [N] = get.length(obj)
        N = length(obj.values);
    end
    function [N] = get.N(obj)
        N = obj.length;
    end
    function [tf] = get.is_another(obj)
        tf = obj.N > 0;
    end
    function [tf] = get.is_empty(obj)
        tf = ~obj.is_another;
    end
end

end % classdef
            