classdef token
% TOKEN  Parse token.
%
%   TOKEN is a lexical token.  A list of TOKEN objects is generated
%   by the lexer (LEX).
    
properties
    is_op = false      % true if the token is a valid operator
    is_lparen = false  % true if the token is a left parenthesis '('
    is_rparen = false  % true if the token is a right parenthesis ')'
    quoted = false     % true if the value was originally quoted
    
    value   % token string
end

methods
    function [obj] = token(str,op,lparen,rparen)
        % TOKEN  Create a token from a string.
        %
        %   [OBJ] = TOKEN(STR,OP,LPAREN,RPAREN)
        %
        %   Create a token with value STR.  Optional arguments are:
        %       OP      true if token is an operator
        %       LPAREN  true if token is a left parenthesis
        %       RPAREN  true if token is a right parenthesis
        
        obj.value = str;
        
        if nargin >= 2 && op
            obj.is_op = true;
        end
        if nargin >= 3 && lparen
            obj.is_lparen = true;
        end
        if nargin >= 4 && rparen
            obj.is_rparen = true;
        end
    end
    
    function display(obj)
        % DISPLAY  Show the value of a token to the toplevel.
        indent = '   ';
        if obj.is_lparen
            disp([indent 'LPAREN']);
        elseif obj.is_rparen
            disp([indent 'RPAREN']);
        elseif obj.is_op
            disp([indent 'op: ' obj.value]);
        elseif obj.quoted
            disp([indent '"' obj.value '"']);
        else
            disp([indent '''' obj.value '''']);
        end
    end
end

end % classdef

