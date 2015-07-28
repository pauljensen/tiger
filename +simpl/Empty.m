classdef Empty
    methods
        function obj = Empty()
        end
        
        function tf = isempty(obj)
            tf = true;
        end
        
        function ids = variableIDs(obj)
            ids = {};
        end
        
        function str = toString(obj)
            %str = '<SIMPL.EMPTY>';
            str = '';
        end
        
        function disp(obj)
            simpl.defaultDisplay(obj);
        end
    end
end
