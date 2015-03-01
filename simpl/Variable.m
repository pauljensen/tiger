classdef Variable
    properties
        id
    end
    
    methods
        function obj = Variable(ids)
            % Variable('id') creates a new variable with ID 'id'.
            % Variable({'id1' ... 'idn'}) creates a matrix of variables
            %   with the provided names. The given cell array can be 
            %   one or two dimensional.
            % Variable() or Variable('') creates a new variable with a
            %   unique numbered ID.
            % To create an array of variables without providing IDs, see
            %   the static method Variable.array().
            
            persistent unnamed_count
            if nargin == 0 || (isa(ids,'char') && isempty(ids))
                % no name or '' given; use default name
                if isempty(unnamed_count)
                    % initialize persistent var
                    unnamed_count = 0;
                end
                obj.id = ['UNNAMED__' num2str(unnamed_count)];
                unnamed_count = unnamed_count + 1;
            elseif isa(ids,'char')
                % single name given; return scalar
                obj.id = ids;
            elseif isa(ids,'cell')
                % multiple names given; return array
                [m,n] = size(ids);
                obj(m,n) = Variable;
                for i = 1:m
                    for j = 1:n
                        obj(i,j) = Variable(ids{i,j});
                    end
                end
            end
        end
        
        function tf = isequal(v1,v2)
            % two variables are equal if and only if they have 
            % identical IDs
            tf = isequal(v1.id,v2.id);
        end
        
        function ordr = order(obj)
            ordr = ones(size(obj));
        end
        
        function new = plus(a,b)
            new = LQSum([LQTerm(a) LQTerm(b)]);
        end
        
        function new = times(a,b)
            if isa(a,'Variable')
                new = times(LQTerm(a),b);
            else
                new = times(a,LQTerm(b));
            end
        end
        
        function new = mtimes(a,b)
            new = times(a,b);
        end
        
        function new = and(a,b)
            new = Junction('&',{a,b});
        end
        
        function new = or(a,b)
            new = Junction('|',{a,b});
        end
        
        function str = toString(obj)
            str = obj.id;
        end
        
        function disp(obj)
            defaultDisplay(obj);
        end
    end
    
    methods (Static)
        function obj = array(m,n)
            % creates an MxN array of variables with default names
            names = cell(m,n);
            for i = 1:m
                for j = 1:n
                    names{i,j} = '';
                end
            end
            obj = Variable(names);
        end
    end
            
end
