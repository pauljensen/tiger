function [tokens] = lex(str,op_subs)
% LEX  Return a list of TOKENS from a string

% TODO:  documentation on op_subs

alphas = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
all_ops = [op_subs{2:2:end}];
opstart = setdiff(cellfun(@(x) {x(1)},all_ops), ...
                  arrayfun(@(x) {x}, alphas));
op_keys = op_subs(1:2:end);
op_vals = op_subs(2:2:end);    

whitespace = {' ','\t'};

chars = stackcounter(fliplr(str));
tokens = stack();


buf = strbuffer();
in_quote = false;
quote = '';
while chars.is_another
    ch = chars.pop();
    if in_quote
        if ch == '\'
            buf.append(chars.pop(),chars.last_count);
        else
            buf.append(ch,chars.last_count);
        end
        
        if ch == quote
            tokens.push(make_token());
            buf.clear;
            in_quote = false;
            quote = '';
        end
        continue;
    end
    switch ch
        case {'(',')'}
            if ~isempty(buf)
                tokens.push(make_token());
                buf.clear;
            end
            tokens.push(make_token(ch,chars.last_count));
        case whitespace
            if ~isempty(buf)
                tokens.push(make_token());
                buf.clear;
            end
        case opstart
            punc = strbuffer(ch,chars.last_count);
            while chars.is_another && is_sub_op([punc.val chars.peek()])
                punc.append(chars.pop());
            end
            % punc may contains a complete operator
            if is_op(punc.val)
                if ~isempty(buf)
                    tokens.push(make_token());
                    buf.clear;
                end
                tokens.push(make_token(punc.val,punc.index));
            else
                % this was not a complete operator
                buf.append(punc.val,chars.last_count);
            end
        case {'''','"'}
            buf.append(ch,chars.last_count);
            in_quote = true;
            quote = ch;
        otherwise
            buf.append(ch,chars.last_count);
    end
end

if ~isempty(buf)
    tokens.push(make_token());
end

tokens.reverse();

function [tf] = is_sub_op(str)
    like = @(x,s) length(x) >= length(s) && strcmp(x(1:length(s)),s);
    tf = any(cellfun(@(x) like(x,str),all_ops));
end

function [tok] = make_token(str,index)
    if nargin == 0
        str = buf.val;
        index = buf.index;
    end
    
    quoted = false;
    
    if is_op(str)
        str = op_keys{cellfun(@(x) ismember(str,x),op_vals)};
        tok = token(str,true);
    elseif str == '('
        tok = token(str,false,true);
    elseif str == ')'
        tok = token(str,false,false,true);
    else
        if str(1) == '''' || str(1) == '"'
            % strip the quotes
            str = str(2:end-1);
            quoted = true;
        end
        tok = token(str);
    end
    
    tok.quoted = quoted;
    tok.index = index;
end

function [tf] = is_op(str)
    if nargin == 0
        str = buf.val;
    end
    tf = ismember(str,all_ops);
end

end % function
