function [tokens] = tokenize(str)

chars = stack(fliplr(str));
tokens = stack();

allowable_ands = {'and', 'AND'};
allowable_ors  = {'or', 'OR'};

terminators = {')', '&', '|'};

while chars.is_another
    switch chars.peek()
        case '('
            tokens.push(token('('));
            chars.pop();
        case ')'
            tokens.push(token(')'));
            chars.pop();
        case {'&'}
            tokens.push(token('and'));
            chars.pop();
            % allow && as AND
            if chars.peek() == '&'
                chars.pop();
            end
        case {'|'}
            tokens.push(token('or'));
            chars.pop();
            % allow || as OR
            if chars.peek() == '|'
                chars.pop();
            end
        case {' '}
            % ignore whitespace
            chars.pop();
        case {''''}
            chars.pop();
            tokens.push(token(eat_until('''')));
        case {'"'}
            chars.pop();
            tokens.push(token(eat_until('"')));
        otherwise
            id = eat_until(' ',true);
            if ismember(id,allowable_ands)
                tokens.push(token('and'));
            elseif ismember(id,allowable_ors)
                tokens.push(token('or'));
            else
                tokens.push(token(id));
            end
    end
end

tokens.reverse();

function [id] = eat_until(term,weak)
    if nargin < 2,  weak = false; end
    
    id = '';
    while chars.is_another
        next = chars.pop();
        if (next == term)
            break;
        elseif weak && ismember(next,terminators)
            chars.push(next);
            break;
        elseif next == '\'
            id = [id chars.pop()];
        else
            id = [id next];
        end
    end
end  % eat_until

end  % tokenize
    