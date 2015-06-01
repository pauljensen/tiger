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
        
        function vars = variableIDs(obj)
            vars = uniqueflatmap(@variableIDs,obj.operands);
            vars = cellfilter(@isempty,vars,true);
        end
        
        function str = toString(obj)
            ops = cellfun(@toString, obj.operands, 'Uniform', false);
            str = ['(' strjoin(ops,[' ' obj.operator ' ']) ')'];
        end
        
        function disp(obj)
            simpl.defaultDisplay(obj);
        end
    end
    
    methods (Access=private)
        function new = combine(obj,op,a)
            if strcmp(op,obj.operator)
                new = simpl.Junction(op,[obj.operands,{a}]);
            else
                new = simpl.Junction(op,{obj,a});
            end
        end
    end
end
