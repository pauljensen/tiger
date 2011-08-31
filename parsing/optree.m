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
        tf = ~isempty(obj.lexpr) && isempty(obj.rexpr);
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
        spacer = [EXTRA_SPACER '-- '];
        
        if obj.is_op
            name = ['[ ' obj.op ' ]'];
        else
            name = obj.id;
        end

        if toplevel
            indent = TOPLEVEL_INDENT;
            frame.add_line('%s%s',indent,name);
        else
            if pipe
                frame.add_line('%s  |%s%s',indent,spacer,name);
                indent = [indent '  |' BASE_INDENT(3:end)];
            else
                frame.add_line('%s  +%s%s',indent,spacer,name);
                indent = [indent ' ' BASE_INDENT];
            end
        end
        if ~isempty(obj.lexpr)
            if ~isempty(obj.rexpr)
                % binary operator; use a pipe
                frame = frame.vcat(obj.lexpr.make_textframe(indent,true));
            else
                % unary operator; use a plus
                frame = frame.vcat(obj.lexpr.make_textframe(indent,false));
            end
        end
        if ~isempty(obj.rexpr)
            if ~TIGHT_DISPLAY
                frame.add_line('%s  |',indent);
            end
            frame = frame.vcat(obj.rexpr.make_textframe(indent,false));
        end
    end
    
    function display(obj)
        obj.make_textframe().display();
    end
end

end
    