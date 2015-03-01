classdef Junction
    properties
        operator = ''
        operands = {}
    end
    
    methods
        function obj = Junction(operator,operands)
            obj.operator = operator;
            obj.operands = operands;
        end
        
        function new = combine(obj,op,a)
            if strcmp(op,obj.operator)
                new = Junction(op,[obj.operands,{a}]);
            else
                new = Junction(op,{obj,a});
            end
        end
        
        function tf = isOr(obj)
            tf = strcmp(obj.operator,'|');
        end
        
        function tf = isAnd(obj)
            tf = strcmp(obj.operator,'&');
        end
        
        function new = and(obj,a)
            new = obj.combine('&',a);
        end
        
        function new = or(obj,a)
            new = obj.combine('|',a);
        end
        
        function str = toString(obj)
            ops = cellfun(@toString, obj.operands, 'Uniform', false);
            str = ['(' strjoin(ops,[' ' obj.operator ' ']) ')'];
        end
        
        function disp(obj)
            defaultDisplay(obj);
        end
    end
end
