
t = create_empty_tiger();

t = add_column(t,'v','c');

r1 = 'a | b => c';
r2 = 'v < 0.33 => ~b';
r3 = 'c & b <=> f';

t = add_rule(t,{r1,r2,r3});
t = set_fieldval(t,'obj',{'b','v'},[-1 1]);

s = solve_tiger(t);
%show_sol(t,solve_tiger(t));

t2 = remove_rule(t,r2);
s2 = solve_tiger(t2);
%show_sol(t2,solve_tiger(t2));

assert(near(s.val,-0.67),'original obj val');
assert(near(s2.val,-1),'removed obj val');

clear r1 r2 r3 s s2 t t2
