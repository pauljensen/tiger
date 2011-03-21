classdef expr < handle
% EXPR  Expression objects for describing TIGER rules.
    
properties (Dependent)
    is_junc     % true if EXPR is a junction (AND or OR)
    is_cond     % true if EXPR is a conditional (<=, <, etc.)
    is_rule     % true if EXPR is a rule (=> or <=>)
    is_atom     % true if EXPR is an atom (variable name)
    
    is_simple   % is a simple rule; does not require substitution
    
    atoms       % list of all atoms appearing in a rule
end

properties
    AND = false   % is an AND junction
    OR = false    % is an OR junction
    cond_op = ''  % operator for conditional expressions
    IFF = false   % is an IFF rule
    IF  = false   % is an IF rule
    lexpr         % left-hand-side expression
    rexpr         % right-hand-side expression

    negated = false  % true if actual rule preceeded by a NOT
    
    is_numeric = false  % true if EXPR is a numeric constant
    was_quoted = false  % true if original id was quoted

    id = ''       % atom name
    display_id    % atom name prefaced by '~' if negated

    NULL = false  % not an EXPR (returned by parsing empty strings)
end

methods
    function [tf] = get.is_junc(obj)
        tf = (obj.AND || obj.OR);
    end
    
    function [tf] = get.is_cond(obj)
        tf = ~isempty(obj.cond_op);
    end
    
    function [tf] = get.is_rule(obj)
        tf = (obj.IFF || obj.IF);
    end
    
    function [tf] = get.is_atom(obj)
        tf = ~isempty(obj.id);
    end

    function [atoms] = get.atoms(obj)
        if ~isempty(obj.lexpr) || ~isempty(obj.rexpr)
            latoms = subsref(obj.lexpr,substruct('.','atoms'));
            ratoms = subsref(obj.rexpr,substruct('.','atoms'));
            atoms = unique([latoms ratoms]);
        else
            atoms = {obj.id};
        end
    end
    
    function [tf] = get.is_simple(obj)
        tf =    obj.is_atom ...
             || (obj.is_cond && ~obj.negated) ...
             || (obj.is_junc && obj.lexpr.is_atom ...
                             && obj.rexpr.is_atom);
    end  
    
    function [new] = copy(obj)
        % perform a deep copy of the handle
        new = expr();
        props = properties(obj);
        for p = 1 : length(props)
            p_meta = findprop(expr,props{p});
            if ~p_meta.Dependent
                new.(props{p}) = obj.(props{p});
            end
        end
        
        % deep copy
        if ~isempty(obj.lexpr)
            new.lexpr = obj.lexpr.copy;
        end
        if ~isempty(obj.rexpr)
            new.rexpr = obj.rexpr.copy;
        end
    end
    
    % ------------ manipulation ------------
    
    function iterif(e,test,f)
        % Iterate over every part of the expression, applying function
        % handle F if function handle TEST is true.  Modifies the 
        % expression in place.
        if test(e)
            f(e);
        end
        if ~isempty(e.lexpr)
            e.lexpr.iterif(test,f);
        end
        if ~isempty(e.rexpr)
            e.rexpr.iterif(test,f);
        end
    end
    
    function [new_e] = mapif(e,test,f)
        % Map function F over each part of the expression where function
        % handle TEST is true.  Returns a new copy of the expression.
        new_e = e.copy;
        new_e.iterif(test,f);
    end
    
    function iter(e,f)
        % Apply function handle F to every part of the expression,
        % modifying the expression in place.
        e.iterif(@(x) true,f);
    end
    
    function [new_e] = map(e,f)
        % Map function F over each part of the expression, returning a new
        % copy of the expression.
        new_e = e.mapif(@(x) true,f);
    end
    
    function demorgan(obj)
        % Apply DeMorgan's rule to the expression:
        %       NOT (x AND y) -> (NOT x) OR (NOT y)
        %       NOT (x OR y)  -> (NOT x) AND (NOT y)
        %       NOT (NOT x)   -> x
        if obj.negated && obj.is_junc
            obj.AND = ~obj.AND;
            obj.OR  = ~obj.OR;
            obj.negated = false;
            
            obj.lexpr.negated = ~obj.lexpr.negated;
            obj.rexpr.negated = ~obj.rexpr.negated;
        elseif obj.negated && obj.is_cond
            obj.negated = false;
            switch obj.cond_op
                case '='
                    obj.cond_op = '~=';
                case '~='
                    obj.cond_op = '=';
                case '>='
                    obj.cond_op = '<';
                case '<'
                    obj.cond_op = '>=';
                case '<='
                    obj.cond_op = '>';
                case '>'
                    obj.cond_op = '<=';
            end
        end
        
        if obj.lexpr.is_junc || obj.lexpr.is_cond
            obj.lexpr.demorgan();
        end
        if obj.rexpr.is_junc || obj.rexpr.is_cond
            obj.rexpr.demorgan();
        end
    end
    
    % ------------ display routines ------------
    
    function [str] = get.display_id(obj)
        if obj.negated
            str = ['~' obj.id];
        else
            str = obj.id;
        end
    end
    
    function [str] = to_string(obj)
        % Format an expression as a one-line string.
        if obj.is_atom
            str = obj.id;
        elseif obj.AND
            str = make_cons(' & ');
        elseif obj.OR
            str = make_cons(' | ');
        elseif obj.IF
            str = make_cons(' => ');
        elseif obj.IFF
            str = make_cons(' <=> ');
        elseif obj.is_cond
            str = obj.cond_to_str();
        else
            str = '';
        end
        
        if obj.negated
            str = ['~' str];
        end
        
        function [s] = make_cons(sep)
            s = ['(' obj.lexpr.to_string() sep obj.rexpr.to_string() ')'];
        end
    end
    
    function [str] = cond_to_str(obj)
        % Format a conditional as a one-line string.
        str = [obj.lexpr.display_id ' ' ...
               obj.cond_op ' ' ...
               obj.rexpr.display_id];
        if obj.negated
            str = ['(' str ')'];
        end
    end
    
    function [frame] = make_textframe(obj,indent,pipe)
        % Converts an expression (not a rule) into a textframe containing
        % a tree structure.
        frame = textframe();
        if obj.NULL
            return
        end
        
        TOPLEVEL_INDENT = '   ';
        TIGHT_DISPLAY = false;

        if TIGHT_DISPLAY
            BASE_INDENT = '     ';
            EXTRA_SPACER = '';
        else
            BASE_INDENT = '      ';
            EXTRA_SPACER = '-';
        end

        toplevel = (nargin < 2);

        if obj.AND
            name = 'AND';
        elseif obj.OR
            name = 'OR';
        elseif obj.is_atom
            name = obj.id;
        elseif obj.is_cond
            name = obj.cond_to_str;
        else % rule?
            name = '';
        end

        if obj.negated
            spacer = [EXTRA_SPACER '- ~'];
        else
            spacer = [EXTRA_SPACER '-- '];
        end

        if toplevel
            indent = TOPLEVEL_INDENT;
            if obj.negated
                frame.add_line('%s~%s',indent(1:end-1),name);
            else
                frame.add_line('%s%s',indent,name);
            end
        else
            if pipe
                frame.add_line('%s |%s%s',indent,spacer,name);
                indent = [indent ' |' BASE_INDENT(3:end)];
            else
                frame.add_line('%s +%s%s',indent,spacer,name);
                indent = [indent BASE_INDENT];
            end
        end
        if ~isempty(obj.lexpr) && ~obj.is_cond
            frame = frame.vcat(obj.lexpr.make_textframe(indent,true));
            if ~TIGHT_DISPLAY
                frame.add_line('%s |',indent);
            end
            frame = frame.vcat(obj.rexpr.make_textframe(indent,false));
        end
    end
    
    function display(obj)
        % Show a rule or expression as a true structure, overriding the
        % builtin display as a structure.
        if obj.is_rule
            l = obj.lexpr.make_textframe();
            r = obj.rexpr.make_textframe();
            sign = textframe();
            if obj.IFF
                sign.add_line('   <==> ');
            else
                sign.add_line('    ==> ');
            end
            l.hcat(sign,r,'valign','middle').display();
        else
            obj.make_textframe().display();
        end
    end
end

end % classdef

                