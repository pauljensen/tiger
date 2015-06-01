classdef Reaction
    properties
        id
        name
        
        reactants
        products
        reversible
        
        ub
        lb
        
        gpr
    end
    
    properties (Dependent)
        compounds
        genes
        equation
        compartments
        localizedCompounds
        reactables
    end
    
    methods
        function obj = Reaction(varargin)
            defaults = {'id',[], ...
                        'equation',[], ...
                        'name','', ...
                        'gpr','', ...
                        'lb',-1000, 'ub',1000,};
            fields = defaults(1:2:end);
            reqfields = fields(1:2);
            S = make_validated_struct(varargin,reqfields,defaults);
            
            % equation is a dynamic property; remove it
            equation = S.equation;
            S = rmfield(S,'equation');
            
            for field = fieldnames(S)'
                obj.(field{1}) = S.(field{1});
            end
            
            parts = parse_reaction_equation(equation);
            for field = fieldnames(parts)'
                obj.(field{1}) = parts.(field{1});
            end
            
            % parse gpr
            obj.gpr = parse_gpr_string(obj.gpr);
        end
        
        function reactables = get.reactables(obj)
            reactables = [obj.reactants obj.products];
        end
        
        function genes = get.genes(obj)
            genes = variableIDs(obj.gpr);
        end
        
        function cpds = get.compounds(obj)
            cpds = unique({obj.reactables.compound});
        end
        
        function comps = get.compartments(obj)
            comps = unique({obj.reactables.compartment});
        end
        
        function tf = isTransport(obj)
            tf = length(obj.compartments) > 1;
        end
        
        function tf = isExchange(obj)
            tf = isempty(obj.reactants) | isempty(obj.products);
        end
        
        function locals = get.localizedCompounds(obj)
            locals = unique({obj.reactables.localizedCompound});
        end
    end
    
    methods (Static)
        function obj = from_kbase_reaction(rxnstruct)
            gpr = rxnstruct.gpr;
            
            if strcmpi(gpr,'None')
                gpr = '';
            end
            
            rxnstruct = rmfield(rxnstruct,{'direction','compartment', ...
                                           'enzyme','pathway','reference'});
            % remove () genes
            gpr = regexprep(gpr, '\(\) and ', '');
            gpr = regexprep(gpr, ' and \(\)', '');

            gpr = regexprep(gpr, '\||\.', '_');
            gpr = regexprep(gpr, {'or','and'}, {'|', '&'});
            
            rxnstruct.gpr = gpr;
            
            obj = Reaction(rxnstruct);
        end
    end
    
end
        
        