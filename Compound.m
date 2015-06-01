classdef Compound
    properties
        id
        name
        formula
        charge
    end
    
    methods
        function obj = Compound(varargin)
            defaults = {'id',[],'name',[],'formula','','charge',NaN};
            fields = defaults(1:2:end);
            reqfields = fields(1:2);
            S = make_validated_struct(varargin,reqfields,defaults);
            for field = fields
                obj.(field{1}) = S.(field{1});
            end
        end
    end
end
