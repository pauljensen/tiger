function display_expr(expr)

frame = make_textframe(expr);
frame.display();

function [frame] = make_textframe(expr,indent,pipe)
frame = textframe();
if expr.NULL
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

if is_op(expr)
    name = ['[ ' expr.op ' ]'];
else
    name = expr.id;
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

if ~isempty(expr.exprs)
    % grouped expression
    for i = 1 : length(expr.exprs) - 1
        frame = frame.vcat(make_textframe(expr.exprs{i},indent,true));
        if ~TIGHT_DISPLAY
            frame.add_line('%s  |',indent);
        end
    end
    frame = frame.vcat(make_textframe(expr.exprs{end},indent,false));
else
    if ~isempty(expr.lexpr)
        if ~isempty(expr.rexpr)
            % binary operator; use a pipe
            frame = frame.vcat(make_textframe(expr.lexpr,indent,true));
        else
            % unary operator; use a plus
            frame = frame.vcat(make_textframe(expr.lexpr,indent,false));
        end
    end
    if ~isempty(expr.rexpr)
        if ~TIGHT_DISPLAY
            frame.add_line('%s  |',indent);
        end
        frame = frame.vcat(make_textframe(expr.rexpr,indent,false));
    end
end


        