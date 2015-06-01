classdef (Abstract) Comparable
    methods (Access = private)
        function cons = makeCons(a,op,b)
            [A,B] = simpl.matchDims(a,b);
            [m,n] = size(A);
            cons(m,n) = simpl.LQConstraint;
            for j = 1:n
                for i = 1:m
                    cons(i,j).lhs = A(i,j);
                    cons(i,j).op = op;
                    cons(i,j).rhs = B(i,j);
                end
            end
        end
    end
    
    methods
        function cons = eq(a,b)
            cons = makeCons(a,'==',b);
        end
        
        function cons = ne(a,b)
            cons = makeCons(a,'~=',b);
        end
        
        function cons = lt(a,b)
            cons = makeCons(a,'<',b);
        end
        
        function cons = gt(a,b)
            cons = makeCons(a,'>',b);
        end
        
        function cons = le(a,b)
            cons = makeCons(a,'<=',b);
        end
        
        function cons = ge(a,b)
            cons = makeCons(a,'>=',b);
        end
    end
end
            