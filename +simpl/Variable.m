classdef Variable < simpl.Comparable
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
                obj(m,n) = simpl.Variable;
                for i = 1:m
                    for j = 1:n
                        obj(i,j) = simpl.Variable(ids{i,j});
                    end
                end
            end
        end
        
        function tf = isequal(v1,v2)
            % two variables are equal if and only if they have 
            % identical IDs
            tf = isa(v1,'simpl.Variable') && ...
                    isa(v2,'simpl.Variable') && ...
                    isequal(v1.id,v2.id);
        end
        
        function vars = variableIDs(obj)
            vars = obj.id;
        end
        
        % =============== dynamic properties ===============
        function ordr = order(obj)
            ordr = ones(size(obj));
        end
        
        % =============== arithmetic operators ===============
        function new = plus(a,b)
            fprintf('Calling Variable.plus\n');
            if isequal(a,b)
                new = 2*a;
            else
                new = simpl.LQSum(a) + b;
            end
        end
        
        function new = times(a,b)
            fprintf('Calling Variable.times\n');
            if isa(a,'simpl.Variable')
                new = times(simpl.LQTerm(a),b);
            else
                new = times(a,simpl.LQTerm(b));
            end
        end
        
        function new = mtimes(a,b)
            new = times(a,b);
        end
        
        function new = and(a,b)
            new = simpl.Junction('&',{a,b});
        end
        
        function new = or(a,b)
            new = simpl.Junction('|',{a,b});
        end
        
        % =============== conversion functions ===============
        function new = LQTerm(obj)
            fprintf('using convertor\n');
            [m,n] = size(obj);
            new(m,n) = LQTerm;
            for j = 1:n
                for i = 1:m
                    new(i,j).c = 1;
                    new(i,j).v1 = obj(i,j);
                end
            end
        end
        
        % =============== display functions ===============
        function str = toString(obj)
            str = obj.id;
        end
        
        function disp(obj)
            simpl.defaultDisplay(obj);
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
            obj = simpl.Variable(names);
        end
    end
            
end
