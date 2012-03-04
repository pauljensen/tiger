function [s] = create_empty_expr_struct()

s.op = '';
s.lexpr = [];
s.rexpr = [];
s.exprs = [];

s.negated = false;

s.is_numeric = false;
s.was_quoted = false;
s.index = [];

s.id = '';
s.display_id = '';

s.NULL = false;
