classdef LQConstraint
    properties
        lhs
        rhs
        op
    end
    
    methods
        function obj = LQConstraint(ineqs)
            if nargin == 0
                return
            end
            
            [m,n] = size(ineqs);
            obj(m,n) = simpl.LQConstraint;
            for j = 1:n
                for i = 1:m
                    obj(i,j) = ineqs(i,j);
                end
            end
        end
      
        
        % =============== display functions ===============
        function str = toString(obj)
            str = [toString(obj.lhs) ...
                   ' ' obj.op ' ' ...
                   toString(obj.rhs)];
        end
        
        function disp(obj)
            simpl.defaultDisplay(obj);
        end
    end
end