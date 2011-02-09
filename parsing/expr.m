classdef expr < handle
    
properties (Dependent)
    is_junc
    is_cond
    is_rule
    is_atom
    
    is_simple
end

properties
    AND = false
    OR = false
    cond_op = ''
    IFF = false
    IF  = false
    lexpr
    rexpr

    negated = false

    id = ''
    display_id

    NULL = false
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

    function [atoms] = get_atoms(obj)
        if obj.is_junc
            atoms = [obj.lexpr.get_atoms obj.rexpr.get_atoms];
        else
            atoms = {obj.id};
        end
    end
    
    function [new] = copy(obj)
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
    
    function demorgan(obj)
        if obj.negated && obj.is_junc
            obj.AND = ~obj.AND;
            obj.OR  = ~obj.OR;
            obj.negated = false;
            
            obj.lexpr.negated = ~obj.lexpr.negated;
            obj.rexpr.negated = ~obj.rexpr.negated;
        end
        
        if obj.lexpr.is_junc
            obj.lexpr.demorgan();
        end
        if obj.rexpr.is_junc
            obj.rexpr.demorgan();
        end
    end
    
    function [tf] = get.is_simple(obj)
        tf =    obj.is_atom ...
             || obj.is_cond ...
             || (obj.is_junc && obj.lexpr.is_atom ...
                             && obj.rexpr.is_atom);
    end
    
    % ------------ display routines ------------
    
    function [str] = get.display_id(obj)
        if obj.negated
            str = ['~' obj.id];
        else
            str = obj.id;
        end
    end
    
    function [str] = cond_to_str(obj)
        str = [obj.lexpr.display_id ' ' ...
               obj.cond_op ' ' ...
               obj.rexpr.display_id];
        if obj.negated
            str = ['(' str ')'];
        end
    end
    
    function [frame] = make_textframe(obj,indent,pipe)
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

                