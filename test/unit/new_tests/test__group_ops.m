
e = parse_string('a | b & c | d & (e & f | g)');
display_expr(e);
eg = group_ops(e);
display_expr(eg);
egf = group_ops(e,true);
display_expr(egf)

