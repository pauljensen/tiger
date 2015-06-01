classdef (InferiorClasses = {?simpl.LQTerm}) LQSum < simpl.Comparable
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
        
        function new = collectTerms(obj)
            keys = unique(arrayfun(@keyName,obj.terms,'Uniform',false));
            n_common = length(unique(keys));
            
            new = obj;
            new.terms = new.terms(1:n_common);
            
            for i = 1:n_common
                key = keys{i};
                is_common = arrayfun(@(x) strcmp(key,keyName(x)), ...
                                     obj.terms);
                common = obj.terms(is_common);
                new.terms(i) = common(1);
                new.terms(i).c = sum(arrayfun(@(x) x.c, common));
            end
        end     
        
        function simp = simplify(obj)
            simp = collectTerms(obj);
            
            % remove all zero entries
            simp.terms = simp.terms(arrayfun(@(x) x.c ~= 0,simp.terms));
            if isempty(simp.terms)
                % everything was removed; put back a constant zero
                simp.terms = simpl.LQTerm(0);
            end
        end
        
        % =============== arithmetic operators ===============
        function new = plus(a,b)
            fprintf('Calling LQSum.plus\n');
            new = simpl.LQSum;
            if isa(a,'simpl.LQSum') && isa(b,'simpl.LQSum')
                new.terms = [a.terms b.terms];
            elseif isa(a,'simpl.LQSum')
                new.terms = [a.terms b];
            elseif isa(b,'simpl.LQSum')
                new.terms = [a b.terms];
            else
                new.terms = [simpl.LQTerm(a) b];
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
