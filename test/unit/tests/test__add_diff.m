
init_test();

tiger = create_empty_tiger();

% TODO  find out why this is infeasible
% tiger = add_column(tiger,{'x','y','z','w'},'cbib',[0,0,0,1],[6.3,1,3,1]);
% tiger = add_diff(tiger,{'x','y','z','w'},{'y','x','x','y'});

tiger = add_column(tiger,{'x','y','z','w'},'cbib',[0,0,0,0],[6.3,1,3,1]);
tiger = add_diff(tiger,{'x','y','z','w'},{'y','x','x','y'});


t = set_var(tiger,'x',2.67');
t = set_var(t,'z',2);

t1min = set_fieldval(t,'obj','diff__x_y',-1);
t1max = set_fieldval(t,'obj','diff__x_y', 1);
t2min = set_fieldval(t,'obj','diff__y_x',-1);
t2max = set_fieldval(t,'obj','diff__y_x', 1);
t3min = set_fieldval(t,'obj','diff__z_x',-1);
t3max = set_fieldval(t,'obj','diff__z_x', 1);
t4min = set_fieldval(t,'obj','diff__w_y',-1);
t4max = set_fieldval(t,'obj','diff__w_y', 1);

sol1min = fba(t1min);
sol1max = fba(t1max);
%show_sol(t1,sol1)
assert(near(-sol1min.val,1.67),'sol1 min');
assert(near( sol1max.val,2.67),'sol1 max');

sol2min = fba(t2min);
sol2max = fba(t2max);
%show_sol(t2,sol2)
assert(near(-sol2min.val,1.67),'sol2 min');
assert(near( sol2max.val,2.67),'sol2 max');

sol3min = fba(t3min);
sol3max = fba(t3max);
%show_sol(t3,sol3)
assert(near(-sol3min.val,0.67),'sol3 min');
assert(near( sol3max.val,0.67),'sol3 max');

sol4min = fba(t4min);
sol4max = fba(t4max);
%show_sol(t4,sol4)
assert(near(-sol4min.val,0),'sol4 min');
assert(near( sol4max.val,1),'sol4 max');
