function [tiger,diff_vars] = add_diff(tiger,var1,var2)

assert(length(var1) == length(var2), ...
       'var1 and var2 must have same length');

[names1,idx1] = convert_ids(tiger.varnames,var1);
[names2,idx2] = convert_ids(tiger.varnames,var2);

binary = tiger.vartypes(idx1) == 'b' & tiger.vartypes(idx2) == 'b';
multi = ~binary;

make_name = @(x,y) ['diff__' x '_' y];
diff_vars = cellzip(make_name,names1,names2);

if count(binary) > 0
    make_binary_rule = @(x,y) sprintf('(%s | %s) & ~(%s & %s) <=> %s', ...
                                      x,y,x,y,make_name(x,y));

    % add the binary rules as 'x XOR y <=> d'
    tiger = add_rule(tiger,cellzip(make_binary_rule,names1(binary), ...
                                                    names2(binary)));
end

N = count(multi);
if N > 0
    idx1 = idx1(multi);
    idx2 = idx2(multi);
    fp = map(@(x) ['fp__' x],diff_vars(multi));
    fn = map(@(x) ['fm__' x],diff_vars(multi));
    
    fp_lb = tiger.lb(idx1) - tiger.ub(idx2);
    fp_ub = tiger.ub(idx1) - tiger.lb(idx2);
    fn_lb = tiger.lb(idx2) - tiger.ub(idx1);
    fn_ub = tiger.ub(idx2) - tiger.lb(idx1);
    
    d_lb = zeros(N,1);
    d_ub = max(tiger.ub(idx1),tiger.ub(idx2)) ...
            - min(tiger.lb(idx1),tiger.lb(idx2));
    
    [m,n] = size(tiger.A);
    tiger = add_column(tiger,[fp fn diff_vars(multi)],'c', ...
                       [fp_lb; fn_lb; d_lb],[fp_ub; fn_ub; d_ub]);
    

    tiger = add_row(tiger,[],repmat('=',2*N,1));
    for i = 1 : N
        % fp = x - y
        tiger.A(  m+i,[idx1(i) idx2(i) n+i]  ) = [ 1 -1 -1];
        % fn = y - x
        tiger.A(m+N+i,[idx1(i) idx2(i) n+N+i]) = [-1  1 -1];
    end
    or_rules = cellzip(@(x,y) [x ' OR ' y],fp,fn);
    rules = cellzip(@(x,y) [x ' <=> ' y],or_rules,diff_vars(multi));
    % fp OR fn <=> d
    tiger = add_rule(tiger,rules);
end


    

