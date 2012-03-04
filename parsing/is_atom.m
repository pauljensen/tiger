function [tf] = is_atom(e)

tf = ~isempty(e) && ~isempty(e.id);
