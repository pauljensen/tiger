classdef optree < handle
    
properties (Dependent)
    is_unary
    is_binary
    is_atom
    is_op
    
    uexpr
    atoms
end

properties
    op = ''
    lexpr = []
    rexpr = []
    
    is_numeric = false
    was_quoted = false
    
    id = ''
    
    NULL = false
end

methods
    function [tf] = get.is_unary(obj)
        tf = ~isempty(obj.lexpr) || isempty(obj.rexpr);
    end
    
    function [tf] = get.is_binary(obj)
        tf = ~isempty(obj.lexpr) && ~isempty(obj.rexpr);
    end
    
    function [tf] = get.is_atom(obj)
        tf = ~obj.is_unary && ~obj.is_binary;
    end
    
    function [tf] = get.is_op(obj)
        tf = ~obj.is_atom;
    end
    
    function [e] = get.uexpr(obj)
        e = obj.lexpr;
    end
    
    function [atoms] = get.atoms(obj)
        if ~isempty(obj.lexpr) || ~isempty(obj.rexpr)
            latoms = subsref(obj.lexpr,substruct('.','atoms'));
            ratoms = subsref(obj.rexpr,substruct('.','atoms'));
            atoms = unique([latoms ratoms]);
        else
            if obj.is_numeric || isempty(obj.id)
                atoms = {};
            else
                atoms = {obj.id};
            end
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
    
end

end
    