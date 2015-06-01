classdef Reactable
    properties
        coefficient
        compound
        compartment
    end
    
    properties (Dependent)
        localizedCompound
    end
    
    methods
        function obj = Reactable(coefficient,compound,compartment)
            if nargin == 0
                return
            end
            
            obj.coefficient = coefficient;
            obj.compound = compound;
            obj.compartment = compartment;
        end
        
        function str = toMet(obj)
            str = [obj.compound '[' obj.compartment ']'];
        end
        
        function str = get.localizedCompound(obj)
            str = toMet(obj);
        end
        
        function str = toString(obj)
            str = ['(' num2str(obj.coefficient) ') ' toMet(obj)];
        end
    end
end
