% test inequalities

N = 25;

for xbar = 0 : N
    for ybar = 0 : N
        % x >= y
%         A = [ 1 -1 -(xbar+1);
%              -1  1  (ybar+1)];
%         b = [-1; ybar+1];
%         test = @(x,y) x >= y;
        
        % x > y
%         A = [ 1 -1 -(xbar+1);
%              -1  1  (ybar+1)];
%         b = [0; ybar];
%         test = @(x,y) x > y;
        
        % x <= y
%         A = [-1  1 -(1-xbar);
%               1 -1  (1-ybar)];
%         b = [-1; 1-ybar];
%         test = @(x,y) x <= y;
        
        % x > y
        A = [-1  1 -(1-xbar);
              1 -1  (2-ybar)];
        b = [0; -ybar];
        test = @(x,y) x < y;
        
        for x = 0 : xbar
            for y = 0 : ybar
                for I = 0 : 1
                    v = [x; y; I];
                    
                    feasible = all(A*v <= b);
                    
                    if feasible && ~(I == test(x,y))
                        disp([xbar ybar x y]);
                    end
                end
            end
        end
    end
end

disp('done')