classdef stackcounter < stack
    
properties (Dependent)
    last_count
    next_count
end

properties (SetAccess = private)
    start_length
end

methods
    function [obj] = stackcounter(array)
        if nargin == 0
            error('STACKCOUNTER objects must be initialized with a list');
        end
        
        obj = obj@stack(array);
        obj.start_length = obj.length;
    end
    
    function push(obj,~)
        error('items cannot be pushed onto STACKCOUNTER objects');
    end
    
    function [n] = get.last_count(obj)
        n = obj.start_length - obj.length;
    end
    
    function [n] = get.next_count(obj)
        n = obj.start_length - obj.length + 1;
    end
end

end
