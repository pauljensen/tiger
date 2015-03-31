classdef LQSum
    properties
        terms
    end
    
    methods
        function obj = LQSum(term)
            if nargin == 0
                return
            end
            
            if isa(term,'simpl.LQSum')
                obj = term;
                return
            end
            
            [m,n] = size(term);
            obj(m,n) = simpl.LQSum;
            for j = 1:n
                for i = 1:m
                    if isa(term(i,j),'simpl.LQSum')
                        obj(i,j).terms = term(i,j).terms;
                    else
                        obj(i,j).terms = term(i,j);
                    end
                end
            end
        end
        
        function new = plus(a,b)
            if isa(b,'simpl.LQSum')
                temp = b;
                b = a;
                a = temp;
            end
            
            new = a;
            if isa(b,'simpl.LQSum')
                new.terms = [a.terms b.terms];
            else
                new.terms = [a.terms simpl.LQTerm(b)];
            end
        end
        
        function str = toString(obj)
            strs = arrayfun(@toString,obj.terms,'Uniform',false);
            str = strjoin(strs,' + ');
        end
        
        function disp(obj)
            %fprintf(' simpl.LQSum\n\n    %s\n\n',toString(obj));
            simpl.defaultDisplay(obj);
        end
    end
end
