classdef converter < handle

properties
    vars
    inds
    cons
    ctypes
    
    model
    
    default_lb
    default_ub
    
    ind_counter = 0
    exprs = {}
    expr_ptr = 0
    
    not_vars = {};
    not_inds = {};
end

properties (Dependent)
    next_ind_name
end

properties (Constant)
    IND_STR = 'I'
    IND_WIDTH = 4  % number of digits for indicator
end

methods
    function [ind_name] = get.next_ind_name(obj)
        % NEXT_IND_NAME  Next available indicator name
        obj.ind_counter = obj.ind_counter + 1;
        ind_name = sprintf([obj.IND_STR '%0*i'], obj.IND_WIDTH, ...
                                                 obj.ind_counter);
    end
    
    function [ind] = make_ind(obj,e)
        % MAKE_IND  Make an indicator expr to replace an expression
        %           Input:  expr
        %           Output: expr
        ind = expr();
        ind.id = obj.next_ind_name;
        
        rule = expr();
        rule.lexpr = e.copy;
        rule.rexpr = ind.copy;
        rule.IFF = true;
        obj.register_expr(rule);
    end
    
    function [ind] = register_not(obj,e)
        % REGISTER_NOT  Register a NOT variable
        %               Input:  expr
        %               Output: expr
        [tf,loc] = ismember(e.id,obj.not_vars);
        ind = expr();
        if tf
            ind.id = obj.not_inds{loc};
        else
            ind.id = obj.next_ind_name;
            obj.not_vars{end+1} = e.id;
            obj.not_inds{end+1} = ind.id;
        end
    end
    
    function simplify_expr(obj,e)
        if e.is_rule
            if ~e.rexpr.is_atom
                e.rexpr = obj.make_ind(e.rexpr.copy);
            end
            if ~e.lexpr.is_simple
                e.lexpr = obj.make_ind(e.lexpr.copy);
            end
        end
        if e.is_junc
            if ~e.lexpr.is_atom
                e.lexpr = obj.make_ind(e.lexpr.copy);
            end
            if ~e.rexpr.is_atom
                e.rexpr = obj.make_ind(e.rexpr.copy);
            end
        end
    end
        
    function register_expr(obj,e)
        % REGISTER_EXPR  Add an expression to the parsing list
        obj.exprs{end+1} = e.copy;
        obj.simplify_expr(obj.exprs{end});
    end
    
    function convert_expr(obj,e)
        obj.register_expr(e);
        while obj.expr_ptr < length(obj.exprs)
            obj.expr_ptr = obj.expr_ptr + 1;
        end
    end
    
    function convert_exprs(obj,exprs)
        cellfun(@obj.convert_expr,exprs);
    end
end

end % classdef
